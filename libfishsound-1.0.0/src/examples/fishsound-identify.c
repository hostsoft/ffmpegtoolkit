/**
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

#define DEBUG

static char * infilename;

static int
dump_identity (unsigned char * buf, long bytes)
{
  int format;

  format = fish_sound_identify (buf, bytes);
  switch (format) {
  case FISH_SOUND_VORBIS: printf ("Vorbis\n"); break;
  case FISH_SOUND_SPEEX: printf ("Speex\n"); break;
  case FISH_SOUND_FLAC: printf ("FLAC\n"); break;
  default: printf ("Unknown\n");
  }

  return 0;
}

static int
read_packet (OGGZ * oggz, ogg_packet * op, long serialno, void * user_data)
{

  if (op->bytes < 8) {
    printf ("too short\n");
  } else {
    printf ("Weak identity:\t");
    dump_identity (op->packet, 8);

    printf ("Strong identity:\t");
    dump_identity (op->packet, op->bytes);
  }

  oggz_set_read_callback (oggz, -1, NULL, NULL);

  return 1;
}

int
main (int argc, char ** argv)
{
  OGGZ * oggz;
  long n;

  if (argc < 2) {
    printf ("usage: %s filename\n", argv[0]);
    printf ("*** FishSound example program. ***\n");
    printf ("Checks whether a file is an Ogg FLAC, Speex or Ogg Vorbis file.\n");
    exit (1);
  }

  infilename = argv[1];

  if ((oggz = oggz_open ((char *) infilename, OGGZ_READ)) == NULL) {
    printf ("unable to open file %s\n", infilename);
    exit (1);
  }

  oggz_set_read_callback (oggz, -1, read_packet, NULL);

  while ((n = oggz_read (oggz, 1024)) > 0);

  oggz_close (oggz);

  exit (0);
}

