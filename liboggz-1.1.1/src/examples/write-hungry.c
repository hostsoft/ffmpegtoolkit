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

#include <stdlib.h> /* exit */
#include "oggz/oggz.h"

static long serialno;
static ogg_int64_t granulepos = 0;
static ogg_int64_t packetno = 0;

static int
hungry (OGGZ * oggz, int empty, void * user_data)
{
  ogg_packet op;
  unsigned char buf[1];

  buf[0] = 'A' + (int)packetno;

  op.packet = buf;
  op.bytes = 1;
  op.granulepos = granulepos;
  op.packetno = packetno;

  if (packetno == 0) op.b_o_s = 1;
  else op.b_o_s = 0;

  if (packetno == 9) op.e_o_s = 1;
  else op.e_o_s = 0;

  oggz_write_feed (oggz, &op, serialno, OGGZ_FLUSH_AFTER, NULL);

  granulepos += 100;
  packetno++;

  return 0;
}

int
main (int argc, char * argv[])
{
  char * progname, * filename = NULL;
  OGGZ * oggz;
  long n;

  progname = argv[0];
  if (argc > 1) filename = argv[1];

  if (filename) {
    oggz = oggz_open (filename, OGGZ_WRITE);
  } else {
    oggz = oggz_open_stdio (stdout, OGGZ_WRITE);
  }

  if (oggz == NULL) {
    fprintf (stderr, "%s: Error creating oggz\n", progname);
    exit (1);
  }

  serialno = oggz_serialno_new (oggz);

  if (oggz_write_set_hungry_callback (oggz, hungry, 1, NULL) == -1) {
    fprintf (stderr, "%s: Error setting OggzHungry callback\n", progname);
    exit (1);
  }

  while ((n = oggz_write (oggz, 32)) > 0);

  oggz_close (oggz);

  exit (0);
}
