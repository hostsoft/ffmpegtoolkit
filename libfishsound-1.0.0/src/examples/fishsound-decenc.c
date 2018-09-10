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
#include <oggz/oggz.h>

typedef struct {
  char * infilename;
  char * outfilename;
  OGGZ * oggz_in;
  OGGZ * oggz_out;
  FishSound * decoder;
  FishSound * encoder;
  int format;
  int interleave;
  int blocksize;
  int channels;
  float ** pcm;
  int begun;
  int b_o_s;
  long serialno;
  long frames_in;
  long frames_out;
} FS_DecEnc;

static void
usage (char * progname)
{
  printf ("*** FishSound example program. ***\n");
  printf ("Duplicates an Ogg file by decoding and re-encoding\n");
  printf ("Usage: %s [options] infile outfile\n\n", progname);
  printf ("Options:\n");
  printf ("  --vorbis                  Use Vorbis as the output codec\n");
  printf ("  --speex                   Use Speex as the output codec\n");
  printf ("  --flac                    Use Flac as the output codec\n");
  printf ("  --interleave              Use interleaved PCM internally\n");
  exit (1);
}

static int
encoded (FishSound * fsound, unsigned char * buf, long bytes, void * user_data)
{
  FS_DecEnc * ed = (FS_DecEnc *) user_data;
  ogg_packet op;
  int err;

  op.packet = buf;
  op.bytes = bytes;
  op.b_o_s = ed->b_o_s;
  op.e_o_s = 0;
  op.granulepos = fish_sound_get_frameno (fsound);
  op.packetno = -1;

  err = oggz_write_feed (ed->oggz_out, &op, ed->serialno, 0, NULL);
  if (err) printf ("err: %d\n", err);

  ed->b_o_s = 0;

  return 0;
}

static int
decoded (FishSound * fsound, float ** pcm, long frames, void * user_data)
{
  FS_DecEnc * ed = (FS_DecEnc *) user_data;
  FishSoundInfo fsinfo;
  int i;

  if (!ed->begun) {
    fish_sound_command (fsound, FISH_SOUND_GET_INFO, &fsinfo,
			sizeof (FishSoundInfo));

    fsinfo.format = ed->format;
    ed->encoder = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);
    fish_sound_set_interleave (ed->encoder, ed->interleave);
    fish_sound_set_encoded_callback (ed->encoder, encoded, ed);

    ed->channels = fsinfo.channels;
    if (ed->interleave) {
      ed->pcm = (float **) malloc (sizeof (float) * ed->channels * ed->blocksize);
    } else {
      ed->pcm = (float **) malloc (sizeof (float *) * ed->channels);
      for (i = 0; i < ed->channels; i++) {
        ed->pcm[i] = (float *) malloc (sizeof (float) * ed->blocksize);
      }
    }

    ed->begun = 1;
  }

  fish_sound_encode (ed->encoder, pcm, frames);

  return 0;
}

static int
read_packet (OGGZ * oggz, ogg_packet * op, long serialno, void * user_data)
{
  FS_DecEnc * ed = (FS_DecEnc *) user_data;
  
  fish_sound_prepare_truncation (ed->decoder, op->granulepos, op->e_o_s);
  fish_sound_decode (ed->decoder, op->packet, op->bytes);

  return 0;
}

static FS_DecEnc *
fs_encdec_new (char * infilename, char * outfilename, int format,
	       int interleave, int blocksize)
{
  FS_DecEnc * ed;

  if (infilename == NULL || outfilename == NULL) return NULL;

  ed = malloc (sizeof (FS_DecEnc));

  ed->infilename = strdup (infilename);
  ed->outfilename = strdup (outfilename);

  ed->oggz_in = oggz_open (infilename, OGGZ_READ);
  ed->oggz_out = oggz_open (outfilename, OGGZ_WRITE);

  oggz_set_read_callback (ed->oggz_in, -1, read_packet, ed);
  ed->serialno = oggz_serialno_new (ed->oggz_out);

  ed->decoder = fish_sound_new (FISH_SOUND_DECODE, NULL);

  fish_sound_set_interleave (ed->decoder, interleave);

  fish_sound_set_decoded_float_ilv (ed->decoder, decoded, ed);

  ed->format = format;
  ed->interleave = interleave;
  ed->blocksize = blocksize;
  ed->begun = 0;
  ed->b_o_s = 1;

  /* Delay the setting of channels and allocation of PCM buffers until
   * the number of channels is known from decoding the headers */
  ed->channels = 0;
  ed->pcm = NULL;

  ed->frames_in = 0;
  ed->frames_out = 0;

  return ed;
}

static int
fs_encdec_delete (FS_DecEnc * ed)
{
  int i;

  if (!ed) return -1;

  free (ed->infilename);
  free (ed->outfilename);

  oggz_close (ed->oggz_in);
  oggz_close (ed->oggz_out);

  fish_sound_delete (ed->encoder);
  fish_sound_delete (ed->decoder);

  if (!ed->interleave) {
    for (i = 0; i < ed->channels; i++)
      free (ed->pcm[i]);
  }
  free (ed->pcm);
  
  free (ed);

  return 0;
}

int
main (int argc, char ** argv)
{
  int i;
  char * infilename = NULL, * outfilename = NULL;
  int format, interleave = 0;
  FS_DecEnc * ed;
  int blocksize = 1024;
  long n;

  if (argc < 3) {
    usage (argv[0]);
    exit (1);
  }

  /* Set the default output format based on what's available */
  format = HAVE_VORBIS ? FISH_SOUND_VORBIS : FISH_SOUND_SPEEX;

  for (i = 1; i < argc; i++) {
    if (!strcmp (argv[i], "--vorbis")) {
      format = FISH_SOUND_VORBIS;
    } else if (!strcmp (argv[i], "--speex")) {
      format = FISH_SOUND_SPEEX;
    } else if (!strcmp (argv[i], "--flac")) {
      format = FISH_SOUND_FLAC;
    } else if (!strcmp (argv[i], "--interleave")) {
      interleave = 1;
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
      printf ("Using Vorbis as the output codec\n");
    } else {
      fprintf (stderr, "Error: Vorbis support disabled\n");
      exit (1);
    }
  }

  if (format == FISH_SOUND_SPEEX) {
    if (HAVE_SPEEX) {
      printf ("Using Speex as the output codec\n");
    } else {
      fprintf (stderr, "Error: Speex support disabled\n");
      exit (1);
    }
  }

  if (format == FISH_SOUND_FLAC) {
    if (HAVE_FLAC) {
      printf ("Using Flac as the output codec\n");
    } else {
      fprintf (stderr, "Error: Flac support disabled\n");
      exit (1);
    }
  }

  ed = fs_encdec_new (infilename, outfilename, format, interleave, blocksize);

  while ((n = oggz_read (ed->oggz_in, 1024)) > 0)
    while (oggz_write (ed->oggz_out, 1024) > 0);

  fs_encdec_delete (ed);

  exit (0);
}

