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

#include "fs_tests.h"

#define DEBUG

#define DEFAULT_ITER 2

static void
usage (char * progname)
{
  printf ("Usage: %s [options]\n\n", progname);
  printf ("Options:\n");
  printf ("  --iter n                  Specify iterations per test (default %d)\n", DEFAULT_ITER);
  printf ("  --nasty                   Run with large test parameters\n");
  printf ("  --disable-vorbis          Disable testing of Vorbis codec\n");
  printf ("  --disable-speex           Disable testing of Speex codec\n");
  printf ("  --disable-flac           Disable testing of Flac codec\n");
  printf ("  --disable-interleave      Disable testing of interleave\n");
  printf ("  --disable-non-interleave  Disable testing of non-interleave\n");
  exit (1);
}

/* For one-time tests, configure these by commandline args */
static int * test_blocksizes, * test_samplerates, * test_channels;
static int iter = DEFAULT_ITER;
static int test_vorbis = HAVE_VORBIS, test_speex = HAVE_SPEEX, test_flac = HAVE_FLAC;
static int test_interleave = 1, test_non_interleave = 1;

static int nasty_blocksizes[] = {128, 256, 512, 1024, 2048, 4096, 0};
static int nasty_samplerates[] = {8000, 16000, 32000, 48000, 0};
static int nasty_channels[] = {1, 2, 4, 5, 6, 8, 10, 16, 32, 0};

static int default_blocksizes[] = {128, 1024, 0};
static int default_samplerates[] = {8000, 48000, 0};
static int default_channels[] = {1, 2, 6, 16, 0};

typedef struct {
  FishSound * encoder;
  FishSound * decoder;
  int interleave;
  int channels;
  float ** pcm;
  long actual_frames_in; /* <= actual count of frames encoded */
  long reported_frames_in; /* <= encoded frameno via fish_sound_frameno() */
  long actual_frames_out; /* <= actual count of frames decoded */
  long reported_frames_out; /* <= decoded frameno via fish_sound_frameno() */
} FS_EncDec;

static int
decoded_float (FishSound * fsound, float ** pcm, long frames, void * user_data)
{
  FS_EncDec * ed = (FS_EncDec *) user_data;

  ed->actual_frames_out += frames;
  ed->reported_frames_out = fish_sound_get_frameno (ed->decoder);

  return 0;
}

static int
decoded_float_ilv (FishSound * fsound, float * pcm[], long frames,
                   void * user_data)
{
  FS_EncDec * ed = (FS_EncDec *) user_data;

  ed->actual_frames_out += frames;
  ed->reported_frames_out = fish_sound_get_frameno (ed->decoder);

  return 0;
}

static int
encoded (FishSound * fsound, unsigned char * buf, long bytes, void * user_data)
{
  FS_EncDec * ed = (FS_EncDec *) user_data;
  fish_sound_decode (ed->decoder, buf, bytes);
  return 0;
}

/* Fill a PCM buffer with a squarish wave */
static void
fs_fill_square (float * pcm, int length)
{
  float value = 0.5;
  int i;

  for (i = 0; i < length; i++) {
    pcm[i] = value;
    if ((i % 100) == 0) {
      value = -value;
    }
  }
}

static FS_EncDec *
fs_encdec_new (int samplerate, int channels, int format, int interleave,
               int blocksize)
{
  FS_EncDec * ed;
  FishSoundInfo fsinfo;
  int i;

  ed = malloc (sizeof (FS_EncDec));

  fsinfo.samplerate = samplerate;
  fsinfo.channels = channels;
  fsinfo.format = format;

  ed->encoder = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);
  ed->decoder = fish_sound_new (FISH_SOUND_DECODE, &fsinfo);

  fish_sound_set_interleave (ed->encoder, interleave);
  fish_sound_set_interleave (ed->decoder, interleave);

  fish_sound_set_encoded_callback (ed->encoder, encoded, ed);

  ed->interleave = interleave;
  ed->channels = channels;

  if (interleave) {
    fish_sound_set_decoded_float_ilv (ed->decoder, decoded_float_ilv, ed);
    ed->pcm = (float **) malloc (sizeof (float) * channels * blocksize);
    fs_fill_square ((float *)ed->pcm, channels * blocksize);
  } else {
    fish_sound_set_decoded_float (ed->decoder, decoded_float, ed);
    ed->pcm = (float **) malloc (sizeof (float *) * channels);
    for (i = 0; i < channels; i++) {
      ed->pcm[i] = (float *) malloc (sizeof (float) * blocksize);
      fs_fill_square (ed->pcm[i], blocksize);
    }
  }

  ed->actual_frames_in = 0;
  ed->reported_frames_in = 0;
  ed->actual_frames_out = 0;
  ed->reported_frames_out = 0;

  return ed;
}

static int
fs_encdec_delete (FS_EncDec * ed)
{
  int i;

  if (!ed) return -1;

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

static int
fs_encdec_test (int samplerate, int channels, int format, int interleave,
                int blocksize)
{
  FS_EncDec * ed;
  char msg[128];
  int i;
  long expected_frames;

  snprintf (msg, 128,
            "+ %2d channel %6d Hz %s, %d frame buffer (%s)",
            channels, samplerate,
            format == FISH_SOUND_VORBIS ? "Vorbis" : (format == FISH_SOUND_FLAC ? "Flac" : "Speex"),
            blocksize,
            interleave ? "interleave" : "non-interleave");
  INFO (msg);
  
  ed = fs_encdec_new (samplerate, channels, format, interleave, blocksize);

#if 0
  fish_sound_comment_add_byname (ed->encoder, "Encoder", "encdec-audio");
  fish_sound_comment_add_byname (ed->encoder, "Format", msg);
#endif

  for (i = 0; i < iter; i++) {
    ed->actual_frames_in += blocksize;
    fish_sound_prepare_truncation (ed->encoder, ed->actual_frames_in,
                                   (i == (iter - 1)));
    fish_sound_encode (ed->encoder, ed->pcm, blocksize);
    ed->reported_frames_in = fish_sound_get_frameno (ed->encoder);
  }

  fish_sound_flush (ed->encoder);
  fish_sound_flush (ed->decoder);
  ed->reported_frames_in = fish_sound_get_frameno (ed->encoder);

  expected_frames = ed->actual_frames_in;
  if (format == FISH_SOUND_SPEEX) {
    expected_frames += (320 - (expected_frames % 320));
  }

  if (ed->actual_frames_out != expected_frames) {
    snprintf (msg, 128,
              "%ld frames encoded, %ld frames decoded",
              ed->actual_frames_in, ed->actual_frames_out);
    if (ed->actual_frames_out < ed->actual_frames_in) {
      FAIL (msg);
    } else {
      WARN (msg);
    }
  }

  expected_frames = ed->reported_frames_in;
  if (format == FISH_SOUND_SPEEX) {
    expected_frames += (320 - (expected_frames % 320));
  }

  if (ed->reported_frames_out != expected_frames) {
    snprintf (msg, 128,
              "%ld frames reported in, %ld frames reported out",
              ed->reported_frames_in, ed->reported_frames_out);
    WARN (msg);
  }

  fs_encdec_delete (ed);

  return 0;
}

static void
parse_args (int argc, char * argv[])
{
  int i;

  for (i = 1; i < argc; i++) {
    if (!strcmp (argv[i], "--nasty")) {
      test_blocksizes = nasty_blocksizes;
      test_samplerates = nasty_samplerates;
      test_channels = nasty_channels;
    } else if (!strcmp (argv[i], "--iter")) {
      i++; if (i >= argc) usage(argv[0]);
      iter = atoi (argv[i]);
    } else if (!strcmp (argv[i], "--disable-vorbis")) {
      test_vorbis = 0;
    } else if (!strcmp (argv[i], "--disable-speex")) {
      test_speex = 0;
    } else if (!strcmp (argv[i], "--disable-flac")) {
      test_flac = 0;
    } else if (!strcmp (argv[i], "--disable-interleave")) {
      test_interleave = 0;
    } else if (!strcmp (argv[i], "--disable-non-interleave")) {
      test_non_interleave = 0;
    } else if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "-h")) {
      usage(argv[0]);
    }
  }

  INFO ("Testing encode/decode pipeline for audio");

  /* Report abnormal options */

  if (test_blocksizes == nasty_blocksizes)
    INFO ("* Running NASTY large test parameters");

  if (!test_vorbis) INFO ("* DISABLED testing of Vorbis");
  if (!test_speex) INFO ("* DISABLED testing of Speex");
  if (!test_flac) INFO ("* DISABLED testing of Flac");
  if (!test_interleave) INFO ("* DISABLED testing of INTERLEAVE");
  if (!test_non_interleave) INFO ("* DISABLED testing of NON-INTERLEAVE");
}

int
main (int argc, char * argv[])
{
  int b, s, c;

  test_blocksizes = default_blocksizes;
  test_samplerates = default_samplerates;
  test_channels = default_channels;

  parse_args (argc, argv);
  
  for (b = 0; test_blocksizes[b]; b++) {
    for (s = 0; test_samplerates[s]; s++) {
      for (c = 0; test_channels[c]; c++) {

        if (test_non_interleave) {
          /* Test VORBIS */
          if (test_vorbis) {
            fs_encdec_test (test_samplerates[s], test_channels[c],
                            FISH_SOUND_VORBIS, 0, test_blocksizes[b]);
          }
          
          /* Test SPEEX */
          if (test_speex) {
            if (test_channels[c] <= 2) {
              fs_encdec_test (test_samplerates[s], test_channels[c],
                              FISH_SOUND_SPEEX, 0, test_blocksizes[b]);
            }
         }

         /* Test FLAC */
         if (test_flac) {
           if (test_channels[c] <= 8) {
             fs_encdec_test (test_samplerates[s], test_channels[c],
                             FISH_SOUND_FLAC, 0, test_blocksizes[b]);
              
           }
         }
        }

        if (test_interleave) {
          /* Test VORBIS */
          if (test_vorbis) {
            fs_encdec_test (test_samplerates[s], test_channels[c],
                            FISH_SOUND_VORBIS, 1, test_blocksizes[b]);
          }
          
          /* Test SPEEX */
          if (test_speex) {
            if (test_channels[c] <= 2) {
              fs_encdec_test (test_samplerates[s], test_channels[c],
                              FISH_SOUND_SPEEX, 1, test_blocksizes[b]);
            }      
          }

          /* Test FLAC */
          if (test_flac) {
            if (test_channels[c] <= 8) {
              fs_encdec_test (test_samplerates[s], test_channels[c],
                              FISH_SOUND_FLAC, 1, test_blocksizes[b]);
              
            }
          }
        }

      }
    }
  }

  exit (0);
}
