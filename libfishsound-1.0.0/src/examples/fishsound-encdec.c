/*
   Copyright (C) 2003 Commonwealth Scientific and Industrial Research
   Organisation (CSIRO) Australia

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   - Neither the name of CSIRO Australia nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
   PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE ORGANISATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <fishsound/fishsound.h>
#include <sndfile.h>

typedef struct {
  char * infilename;
  char * outfilename;
  SNDFILE * sndfile_in;
  SNDFILE * sndfile_out;
  FishSound * encoder;
  FishSound * decoder;
  int channels;
  float * pcm;
  long frames_in;
  long frames_out;
} FS_EncDec;

static void
usage (char * progname)
{
  printf ("*** FishSound example program. ***\n");
  printf ("Duplicates a PCM sound file by encoding and decoding\n");
  printf ("Usage: %s [options] infile outfile\n\n", progname);
  printf ("Options:\n");
  printf ("  --flac                    Use FLAC as intermediate codec\n");
  printf ("  --speex                   Use Speex as intermediate codec\n");
  printf ("  --vorbis                  Use Vorbis as intermediate codec\n");
  exit (1);
}

static int
decoded (FishSound * fsound, float ** pcm, long frames, void * user_data)
{
  FS_EncDec * ed = (FS_EncDec *) user_data;

  sf_writef_float (ed->sndfile_out, (float *)pcm, frames);

  return 0;
}

static int
encoded (FishSound * fsound, unsigned char * buf, long bytes, void * user_data)
{
  FS_EncDec * ed = (FS_EncDec *) user_data;
  fish_sound_decode (ed->decoder, buf, bytes);
  return 0;
}

static FS_EncDec *
fs_encdec_new (char * infilename, char * outfilename, int format,
	       int blocksize)
{
  FS_EncDec * ed;
  SF_INFO sfinfo;
  FishSoundInfo fsinfo;

  if (infilename == NULL || outfilename == NULL) return NULL;

  ed = malloc (sizeof (FS_EncDec));

  ed->infilename = strdup (infilename);
  ed->outfilename = strdup (outfilename);

  ed->sndfile_in = sf_open (infilename, SFM_READ, &sfinfo);
  ed->sndfile_out = sf_open (outfilename, SFM_WRITE, &sfinfo);

  fsinfo.samplerate = sfinfo.samplerate;
  fsinfo.channels = sfinfo.channels;
  fsinfo.format = format;

  ed->encoder = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);
  ed->decoder = fish_sound_new (FISH_SOUND_DECODE, NULL);

  fish_sound_set_interleave (ed->encoder, 1);
  fish_sound_set_interleave (ed->decoder, 1);

  fish_sound_set_encoded_callback (ed->encoder, encoded, ed);
  fish_sound_set_decoded_float_ilv (ed->decoder, decoded, ed);

  ed->channels = fsinfo.channels;

  ed->pcm = (float *) malloc (sizeof (float) * ed->channels * blocksize);

  ed->frames_in = 0;
  ed->frames_out = 0;

  return ed;
}

static int
fs_encdec_delete (FS_EncDec * ed)
{
  if (!ed) return -1;

  free (ed->infilename);
  free (ed->outfilename);

  sf_close (ed->sndfile_in);
  sf_close (ed->sndfile_out);

  fish_sound_delete (ed->encoder);
  fish_sound_delete (ed->decoder);

  free (ed->pcm);
  
  free (ed);

  return 0;
}

int
main (int argc, char ** argv)
{
  int i;
  char * infilename = NULL, * outfilename = NULL;
  int format;
  int blocksize = 1024;
  FS_EncDec * ed;
  long n;

  if (argc < 3) {
    usage (argv[0]);
    exit (1);
  }

  /* Set the default intermediate format based on what's available */
  format = HAVE_VORBIS ? FISH_SOUND_VORBIS :
           HAVE_FLAC ? FISH_SOUND_FLAC : FISH_SOUND_SPEEX;

  for (i = 1; i < argc; i++) {
    if (!strcmp (argv[i], "--vorbis")) {
      format = FISH_SOUND_VORBIS;
    } else if (!strcmp (argv[i], "--speex")) {
      format = FISH_SOUND_SPEEX;
    } else if (!strcmp (argv[i], "--flac")) {
      format = FISH_SOUND_FLAC;
    } else if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "-h")) {
      usage(argv[0]);
    } else if (argv[i] && argv[i][0] != '-') {
      if (infilename == NULL) {
	infilename = argv[i];
      } else {
	outfilename = argv[i];
      }
    }
  }

  if (format == FISH_SOUND_VORBIS) {
    if (HAVE_VORBIS) {
      printf ("Using Vorbis as the intermediate codec\n");
    } else {
      fprintf (stderr, "Error: Vorbis support disabled\n");
      exit (1);
    }
  }

  if (format == FISH_SOUND_SPEEX) {
    if (HAVE_SPEEX) {
      printf ("Using Speex as the intermediate codec\n");
    } else {
      fprintf (stderr, "Error: Speex support disabled\n");
      exit (1);
    }
  }

  if (format == FISH_SOUND_FLAC) {
    if (HAVE_FLAC) {
      printf ("Using FLAC as the intermediate codec\n");
    } else {
      fprintf (stderr, "Error: FLAC support disabled\n");
      exit (1);
    }
  }

  ed = fs_encdec_new (infilename, outfilename, format, blocksize);

  while ((n = sf_readf_float (ed->sndfile_in, ed->pcm, blocksize)) > 0) {
    fish_sound_encode (ed->encoder, (float **)ed->pcm, n);
  }

  fs_encdec_delete (ed);

  exit (0);
}

