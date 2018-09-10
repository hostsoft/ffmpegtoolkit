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

static FishSound * fsound;

static int
noop_test (int format)
{
  FishSoundInfo fsinfo;

  fsinfo.samplerate = 16000;
  fsinfo.channels = 1;
  fsinfo.format = format;

#if FS_ENCODE
  INFO ("+ Creating new FishSound (encode)");
  fsound = fish_sound_new (FISH_SOUND_ENCODE, &fsinfo);

  INFO ("+ Deleting FishSound (encode)");
  fish_sound_delete (fsound);
#endif /* FS_ENCODE */

#if FS_DECODE
  INFO ("+ Creating new FishSound (decode)");
  fsound = fish_sound_new (FISH_SOUND_DECODE, &fsinfo);

  INFO ("+ Deleteing FishSound (decode)");
  fish_sound_delete (fsound);
#endif

  return 0;
}

int
main (int argc, char * argv[])
{
#if HAVE_VORBIS
  INFO ("Testing new/delete for Vorbis");
  noop_test (FISH_SOUND_VORBIS);
#endif

#if HAVE_SPEEX
  INFO ("Testing new/delete for Speex");
  noop_test (FISH_SOUND_SPEEX);
#endif

#if HAVE_FLAC
  INFO ("Testing new/delete for FLAC");
  noop_test (FISH_SOUND_FLAC);
#endif

  exit (0);
}
