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

#include <string.h>

#include "oggz/oggz.h"

#include "oggz_tests.h"

/* #define DEBUG */

#define PACKET_SIZE 3000
#define READ_SIZE 9000

static long serialno;

static int corrupt_packets = 0;

static int
hungry (OGGZ * oggz, int empty, void * user_data)
{
  unsigned char buf[PACKET_SIZE];
  ogg_packet op;
  static int iter = 0;
  static long b_o_s = 1;
  static long e_o_s = 0;

  if (iter > 10) return 1;

  memset (buf, 'a' + iter, PACKET_SIZE);

  op.packet = buf;
  op.bytes = PACKET_SIZE;
  op.b_o_s = b_o_s;
  op.e_o_s = e_o_s;
  op.granulepos = iter;
  op.packetno = iter;

  /* Main check */
   if (oggz_write_feed (oggz, &op, serialno, 0, NULL) != 0)
    FAIL ("Oggz write failed");

  iter++;
  b_o_s = 0;
  if (iter == 10) e_o_s = 1;
  
  return 0;
}

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  static int iter = 0;
  static long b_o_s = 1;
  static long e_o_s = 0;

#ifdef DEBUG
  printf ("%08" PRI_OGGZ_OFF_T "x: serialno %010lu, "
	  "granulepos %" PRId64 ", packetno %" PRId64,
	  oggz_tell (oggz), serialno, op->granulepos, op->packetno);

  if (op->b_o_s) {
    printf (" *** bos");
  }

  if (op->e_o_s) {
    printf (" *** eos");
  }

  printf ("\n");
#endif

  if (op->bytes != PACKET_SIZE)
    FAIL ("Packet has incorrect size");

  if (op->packet[0] != 'a' + iter)
    corrupt_packets++;

  if ((op->b_o_s == 0) != (b_o_s == 0))
    FAIL ("Packet has incorrect b_o_s");

#if 0
  if ((op->e_o_s == 0) != (e_o_s == 0))
    FAIL ("Packet has incorrect e_o_s");

  if (op->granulepos != -1 && op->granulepos != iter)
    FAIL ("Packet has incorrect granulepos");

  if (op->packetno != iter)
    FAIL ("Packet has incorrect packetno");
#endif

  iter++;
  b_o_s = 0;
  if (iter == 10) e_o_s = 1;

  if (iter % 3 == 0) return OGGZ_STOP_ERR;

  return OGGZ_CONTINUE;
}

int
main (int argc, char * argv[])
{
  OGGZ * reader, * writer;
  unsigned char buf[READ_SIZE];
  long n, remaining;

  INFO ("Testing ability to stop reading and purge (OGGZ_STOP_ERR)");

  writer = oggz_new (OGGZ_WRITE);
  if (writer == NULL)
    FAIL("newly created OGGZ writer == NULL");

  serialno = oggz_serialno_new (writer);

  if (oggz_write_set_hungry_callback (writer, hungry, 1, NULL) == -1)
    FAIL("Could not set hungry callback");

  reader = oggz_new (OGGZ_READ);
  if (reader == NULL)
    FAIL("newly created OGGZ reader == NULL");

  oggz_set_read_callback (reader, -1, read_packet, NULL);

  while ((remaining = oggz_write_output (writer, buf, READ_SIZE)) > 0) {
    n = oggz_read_input (reader, buf, remaining);

    if (n < remaining)
      INFO ("+ Interrupted read detected");

    remaining -= n;

    n = oggz_read_input (reader, buf+n, remaining);
    remaining -= n;
  }

  /*
   * The STOP_ERR above should have caused some packets to be incompletely
   * delivered, hence if none were corrupted, the STOP_ERR was not purging
   * correctly.
   */
  if (corrupt_packets == 0)
    FAIL("Corrupted packets not detected");

  INFO("= Corrupted packets detected correctly");

  if (oggz_close (reader) != 0)
    FAIL("Could not close OGGZ reader");

  if (oggz_close (writer) != 0)
    FAIL("Could not close OGGZ writer");

  exit (0);
}
