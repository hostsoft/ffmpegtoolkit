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

#include "oggz/oggz.h"

#include "oggz_tests.h"

static long serialno;
static int b_o_s = 1;
static ogg_int64_t granulepos = 0;
static ogg_int64_t packetno = 100;

static int
hungry (OGGZ * oggz, int empty, void * user_data)
{
  unsigned char buf[1];
  ogg_packet op;
  int err;

  buf[0] = 'x';
  op.packet = buf;
  op.bytes = 1;
  op.b_o_s = b_o_s;
  op.e_o_s = 0;
  op.granulepos = granulepos;
  op.packetno = packetno;
  
  err = oggz_write_feed (oggz, &op, serialno, 0, NULL);
  if (packetno == 100) {
    if (err != 0)
      FAIL ("Could not feed OGGZ");
  } else {
    INFO ("Feeding packet with decreasing packetno");
    if (err != OGGZ_ERR_BAD_PACKETNO)
      FAIL ("Bad packetno not detected");

    return 1; /* Cancel write */
  }

  b_o_s = 0;
  granulepos++;
  packetno--;
  
  return 0;
}

int
main (int argc, char * argv[])
{
  OGGZ * oggz;
  unsigned char buf[1];
  long n;

  oggz = oggz_new (OGGZ_WRITE);
  if (oggz == NULL)
    FAIL("newly created OGGZ == NULL");

  serialno = oggz_serialno_new (oggz);

  if (oggz_write_set_hungry_callback (oggz, hungry, 1, NULL) != 0)
    FAIL("Could not set hungry callback");

  while ((n = oggz_write_output (oggz, buf, 1)) > 0);

  if (oggz_close (oggz) != 0)
    FAIL("Could not close OGGZ");

  exit (0);
}
