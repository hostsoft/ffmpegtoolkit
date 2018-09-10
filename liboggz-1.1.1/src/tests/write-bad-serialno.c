/*
   Copyright (C) 2008 Annodex Association, Inc.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   - Neither the name of the Annodex Association nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
   PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE ASSOCIATION OR
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

static const long good_serialno = 0x77L;
static const long bad_serialno = (long)0x777777777777LL;

int
main (int argc, char * argv[])
{
  OGGZ * oggz;
  unsigned char buf[1];
  ogg_packet op;
  long n;

  oggz = oggz_new (OGGZ_WRITE);
  if (oggz == NULL)
    FAIL("newly created OGGZ == NULL");

  /* Create a packet */
  buf[0] = 'x';
  op.packet = buf;
  op.bytes = 1;
  op.granulepos = 0;
  op.packetno = 0;
  op.b_o_s = 1;
  op.e_o_s = 0;
    
  /* Feed it to the Oggz packet queue, first normally, then twice with a
   * bad serialno */

  INFO ("Feeding packet with ok serialno");
  if (oggz_write_feed (oggz, &op, good_serialno, 0, NULL) != 0)
    FAIL ("Error feeding with valid serialno");

  INFO ("Feeding packet with -1 serialno");
  if (oggz_write_feed (oggz, &op, -1L, 0, NULL) != OGGZ_ERR_BAD_SERIALNO)
    FAIL ("Illegal serialno (-1) not detected");
    
  /* The following test is only active where long and int have different
   * sizes, eg. on LP64 platforms */
  if (sizeof(long) > sizeof(int)) {
    INFO ("Detected sizeof(long) > sizeof(int)")

    INFO ("Feeding packet with out-of-range serialno");
    if (oggz_write_feed (oggz, &op, bad_serialno, 0, NULL) !=
        OGGZ_ERR_BAD_SERIALNO)
      FAIL ("Out-of-range serialno not detected");
  }

  if (oggz_close (oggz) != 0)
    FAIL("Could not close OGGZ");

  exit (0);
}
