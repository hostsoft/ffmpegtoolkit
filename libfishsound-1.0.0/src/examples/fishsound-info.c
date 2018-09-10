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

#include <oggz/oggz.h>
#include <fishsound/fishsound.h>

static char * infilename;
static int begun = 0;
static long actual_frames_decoded = 0;

static void
read_comments (FishSound * fsound)
{
  const FishSoundComment * comment;
  const char * vendor;

  vendor = fish_sound_comment_get_vendor (fsound);
  if (vendor) puts (vendor);

  for (comment = fish_sound_comment_first (fsound); comment;
       comment = fish_sound_comment_next (fsound, comment)) {
    if (comment->value) {
      printf ("%s: %s\r\n", comment->name, comment->value);
    } else {
      printf ("%s\r\n", comment->name);
    }
  }
}

static int
decoded (FishSound * fsound, float ** pcm, long frames, void * user_data)
{
  if (!begun) {
    read_comments (fsound);
    begun = 1;
  }

  actual_frames_decoded += frames;

  return 0;
}

static int
read_packet (OGGZ * oggz, ogg_packet * op, long serialno, void * user_data)
{
  FishSound * fsound = (FishSound *)user_data;

  if (op->e_o_s) {
    fish_sound_prepare_truncation (fsound, op->e_o_s, op->granulepos);
  }

  fish_sound_decode (fsound, op->packet, op->bytes);

  return OGGZ_CONTINUE;
}

int
main (int argc, char ** argv)
{
  OGGZ * oggz;
  FishSound * fsound;
  long n;

  if (argc < 2) {
    printf ("usage: %s infilename\n", argv[0]);
    printf ("*** FishSound example program. ***\n");
    printf ("Display information about an Ogg FLAC, Speex or Ogg Vorbis file.\n");
    exit (1);
  }

  infilename = argv[1];

  fsound = fish_sound_new (FISH_SOUND_DECODE, NULL);
  fish_sound_set_interleave (fsound, 1);
  fish_sound_set_decoded_float_ilv (fsound, decoded, NULL);

  if ((oggz = oggz_open ((char *) infilename, OGGZ_READ)) == NULL) {
    printf ("unable to open file %s\n", infilename);
    exit (1);
  }

  oggz_set_read_callback (oggz, -1, read_packet, fsound);

  while ((n = oggz_read (oggz, 1024)) > 0);

  oggz_close (oggz);

  printf ("%ld frames decoded\n", actual_frames_decoded);
  printf ("%ld frames reported\n", fish_sound_get_frameno (fsound));

  fish_sound_delete (fsound);
  
  exit (0);
}

