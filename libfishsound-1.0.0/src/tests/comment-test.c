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

#define ARTIST1 "Trout Junkies"
#define ARTIST2 "DJ Fugu"
#define COPYRIGHT "Copyright (C) 2004. Some Rights Reserved."
#define LICENSE "Creative Commons Attribution-ShareAlike"
#define COMMENT "Unstructured comments are evil."

static FishSound * fsound;

int
main (int argc, char * argv[])
{
  FishSoundInfo fsinfo;
  const FishSoundComment * comment, * comment2;
  FishSoundComment mycomment;
  int err;

  fsinfo.samplerate = 16000;
  fsinfo.channels = 1;
  /* The format doesn't really matter as we're not actually
   * going to encode any audio, so just ensure we can
   * set this to something that's configured.
   */
#if HAVE_VORBIS
  fsinfo.format = FISH_SOUND_VORBIS;
#elif HAVE_SPEEX
  fsinfo.format = FISH_SOUND_SPEEX;
#else
  fsinfo.format = FISH_SOUND_FLAC;
#endif

#if FS_ENCODE
  INFO ("Initializing FishSound for comments (encode)");
  fsound = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);

  INFO ("+ Adding ARTIST1 byname");
  err = fish_sound_comment_add_byname (fsound, "ARTIST", ARTIST1);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Adding COPYRIGHT byname");
  err = fish_sound_comment_add_byname (fsound, "COPYRIGHT", COPYRIGHT);
  if (err < 0) FAIL ("Operation failed");

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

  INFO ("+ Checking comments termination");
  comment2 = fish_sound_comment_next (fsound, comment);

  if (comment2 != NULL)
    FAIL ("Comments unterminated");

  INFO ("+ Adding LICENSE from local storage");
  mycomment.name = "LICENSE";
  mycomment.value = LICENSE;
  err = fish_sound_comment_add (fsound, &mycomment);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Retrieving next (expect LICENSE)");
  comment = fish_sound_comment_next (fsound, comment);

  if (comment == NULL)
    FAIL ("Recently inserted LICENSE not retrieved");

  if (comment == &mycomment)
    FAIL ("Recently inserted LICENSE not restored");

  if (strcmp (comment->name, "LICENSE"))
    FAIL ("Incorrect LICENSE name found");

  if (strcmp (comment->value, LICENSE))
    FAIL ("Incorrect LICENSE value found");

  INFO ("+ Testing add of valid plain (not key=value) COMMENT byname");
  err = fish_sound_comment_add_byname (fsound, COMMENT, NULL);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Testing add of valid plain (not key=value) COMMENT from local storage");
  mycomment.name = COMMENT;
  mycomment.value = NULL;
  err = fish_sound_comment_add (fsound, &mycomment);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Adding ARTIST2 byname");  
  err = fish_sound_comment_add_byname (fsound, "ARTIST", ARTIST2);
  if (err < 0) FAIL ("Operation failed");

  INFO ("+ Retrieving first ARTIST using wierd caps (expect ARTIST1)");
  comment = fish_sound_comment_first_byname (fsound, "ArTiSt");

  if (comment == NULL)
    FAIL ("Recently inserted ARTIST1 not retrieved");

  if (strcmp (comment->name, "ARTIST"))
    FAIL ("Incorrect ARTIST1 name found");

  if (strcmp (comment->value, ARTIST1))
    FAIL ("Incorrect ARTIST1 value found");

  INFO ("+ Retrieving next ARTIST (expect ARTIST2)");
  comment = fish_sound_comment_next_byname (fsound, comment);

  if (comment == NULL)
    FAIL ("Recently inserted ARTIST2 not retrieved");

  if (strcmp (comment->name, "ARTIST"))
    FAIL ("Incorrect ARTIST2 name found");

  if (strcmp (comment->value, ARTIST2))
    FAIL ("Incorrect ARTIST2 value found");

  INFO ("+ Removing LICENSE byname");
  err = fish_sound_comment_remove_byname (fsound, "LICENSE");
  if (err != 1) FAIL ("Operation failed");

  INFO ("+ Attempting to retrieve LICENSE");
  comment = fish_sound_comment_first_byname (fsound, "LICENSE");

  if (comment != NULL)
    FAIL ("Removed comment incorrectly retrieved");

  INFO ("+ Removing COPYRIGHT from local storage");
  mycomment.name = "COPYRIGHT";
  mycomment.value = COPYRIGHT;
  err = fish_sound_comment_remove (fsound, &mycomment);
  if (err != 1) FAIL ("Operation failed");

  INFO ("+ Attempting to retrieve COPYRIGHT");
  comment = fish_sound_comment_first_byname (fsound, "COPYRIGHT");

  if (comment != NULL)
    FAIL ("Removed comment incorrectly retrieved");

  INFO ("Deleting FishSound (encode)");
  fish_sound_delete (fsound);
#endif /* FS_ENCODE */

#if FS_DECODE
  INFO ("Initializing FishSound for comments (decode)");
  fsound = fish_sound_new (FISH_SOUND_DECODE, &fsinfo);

  INFO ("+ Adding ARTIST1 byname (invalid for decode)");
  err = fish_sound_comment_add_byname (fsound, "ARTIST", ARTIST1);

  if (err == 0)
    FAIL ("Operation disallowed");

  INFO ("+ Removing ARTIST byname (invalid for decode)");
  err = fish_sound_comment_remove_byname (fsound, "ARTIST");

  if (err == 0)
    FAIL ("Operation disallowed");

  INFO ("Deleteing FishSound (decode)");
  fish_sound_delete (fsound);
#endif

  exit (0);
}
