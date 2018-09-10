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

#define ARTIST1 "Trout Junkies"
#define ARTIST2 "DJ Fugu"
#define COPYRIGHT "Copyright (C) 2004. Some Rights Reserved."
#define LICENSE "Creative Commons Attribute Share-Alike v1.0"

typedef struct {
  FishSound * encoder;
  FishSound * decoder;
  float ** pcm;
} FS_EncDec;

static int
decoded (FishSound * fsound, float ** pcm, long frames, void * user_data)
{
  const FishSoundComment * comment;

  if (fsound == NULL)
    FAIL ("No Fish Found");

  INFO ("+ Retrieving first (expect ARTIST1)");
  comment = fish_sound_comment_first (fsound);

  if (comment == NULL)
    FAIL ("Recently inserted ARTIST1 not retrieved");

  if (strcmp (comment->name, "ARTIST"))
    FAIL ("Incorrect ARTIST1 name found");

  if (strcmp (comment->value, ARTIST1))
    FAIL ("Incorrect ARTIST1 value found");

  INFO ("+ Retrieving next (expect COPYRIGHT)");
  comment = fish_sound_comment_next (fsound, comment);

  if (comment == NULL)
    FAIL ("Recently inserted COPYRIGHT not retrieved");

  if (strcmp (comment->name, "COPYRIGHT"))
    FAIL ("Incorrect COPYRIGHT name found");

  if (strcmp (comment->value, COPYRIGHT))
    FAIL ("Incorrect COPYRIGHT value found");

  INFO ("+ Retrieving next (expect LICENSE)");
  comment = fish_sound_comment_next (fsound, comment);

  if (comment == NULL)
    FAIL ("Recently inserted LICENSE not retrieved");

  if (strcmp (comment->name, "LICENSE"))
    FAIL ("Incorrect LICENSE name found");

  if (strcmp (comment->value, LICENSE))
    FAIL ("Incorrect LICENSE value found");

  INFO ("+ Retrieving first ARTIST using wierd caps (expect ARTIST1)");
  comment = fish_sound_comment_first_byname (fsound, "ArTiSt");

  if (comment == NULL)
    FAIL ("First artist ARTIST1 not retrieved");

  if (strcmp (comment->name, "ARTIST"))
    FAIL ("Incorrect ARTIST1 name found");

  if (strcmp (comment->value, ARTIST1))
    FAIL ("Incorrect ARTIST1 value found");

  INFO ("+ Retrieving next ARTIST (expect ARTIST2)");
  comment = fish_sound_comment_next_byname (fsound, comment);

  if (comment == NULL)
    FAIL ("Next artist ARTIST2 not retrieved");

  if (strcmp (comment->name, "ARTIST"))
    FAIL ("Incorrect ARTIST2 name found");

  if (strcmp (comment->value, ARTIST2))
    FAIL ("Incorrect ARTIST2 value found");

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
fs_encdec_new (int format, int blocksize)
{
  FS_EncDec * ed;
  FishSoundInfo fsinfo;

  ed = malloc (sizeof (FS_EncDec));

  fsinfo.samplerate = 8000;
  fsinfo.channels = 1;
  fsinfo.format = format;

  ed->encoder = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);
  ed->decoder = fish_sound_new (FISH_SOUND_DECODE, &fsinfo);

  fish_sound_set_interleave (ed->encoder, 1);
  fish_sound_set_interleave (ed->decoder, 1);

  fish_sound_set_encoded_callback (ed->encoder, encoded, ed);
  fish_sound_set_decoded_callback (ed->decoder, decoded, ed);
  
  ed->pcm = (float **) malloc (sizeof (float) * blocksize);
  fs_fill_square ((float *)ed->pcm, blocksize);

  return ed;
}

static int
fs_encdec_delete (FS_EncDec * ed)
{
  if (!ed) return -1;

  fish_sound_delete (ed->encoder);
  fish_sound_delete (ed->decoder);
  free (ed->pcm);
  free (ed);

  return 0;
}

static int
fs_encdec_comments_test (int format, int blocksize)
{
  FS_EncDec * ed;
  FishSoundComment mycomment;
  int err;
  
  ed = fs_encdec_new (format, blocksize);

  INFO ("+ Adding ARTIST1 byname");
  err = fish_sound_comment_add_byname (ed->encoder, "ARTIST", ARTIST1);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Adding COPYRIGHT byname");
  err = fish_sound_comment_add_byname (ed->encoder, "COPYRIGHT", COPYRIGHT);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Adding LICENSE from local storage");
  mycomment.name = "LICENSE";
  mycomment.value = LICENSE;
  err = fish_sound_comment_add (ed->encoder, &mycomment);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Adding ARTIST2 byname");  
  err = fish_sound_comment_add_byname (ed->encoder, "ARTIST", ARTIST2);
  if (err < 0) FAIL ("Operation failed");

  fish_sound_encode (ed->encoder, ed->pcm, blocksize);

  fish_sound_flush (ed->encoder);
  fish_sound_flush (ed->decoder);

  fs_encdec_delete (ed);

  return 0;
}

int
main (int argc, char * argv[])
{
#if HAVE_VORBIS
  INFO ("Testing encode/decode pipeline for comments: VORBIS");
  fs_encdec_comments_test (FISH_SOUND_VORBIS, 2048);
#endif

#if HAVE_SPEEX
  INFO ("Testing encode/decode pipeline for comments: SPEEX");
  fs_encdec_comments_test (FISH_SOUND_SPEEX, 2048);
#endif

#if HAVE_FLAC
  INFO ("Testing encode/decode pipeline for comments: FLAC");
  fs_encdec_comments_test (FISH_SOUND_FLAC, 2048);
#endif

  exit (0);
}
