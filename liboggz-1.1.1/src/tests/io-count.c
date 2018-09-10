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

/*#define DEBUG*/

#define DATA_BUF_LEN 4096

static long serialno;
static int read_called = 0;

static unsigned char packet_buf[1024];
static long total_bytes_written = 0;
static long total_bytes_read = 0;

#define MAX_ITER 10

static int
hungry (OGGZ * oggz, int empty, void * user_data)
{
  ogg_packet op;
  int err;
  static long packet_bytes_w = 1;
  static int iter = 0;
  static long b_o_s = 1;
  static long e_o_s = 0;

  if (iter > MAX_ITER) return 1;

  total_bytes_written += packet_bytes_w;

  memset (packet_buf, 'a' + iter, 1024);

  op.packet = packet_buf;
  op.bytes = packet_bytes_w;
  op.b_o_s = b_o_s;
  op.e_o_s = e_o_s;
  op.granulepos = total_bytes_written-1;
  op.packetno = iter;

  if ((err = oggz_write_feed (oggz, &op, serialno, 0, NULL)) != 0) {
#ifdef DEBUG
    printf ("oggz_write_feed: error %d\n", err);
#endif
    FAIL ("Could not feed OGGZ");
  }

#ifdef DEBUG
  printf ("hungry: packet_bytes_w %ld, eos %d\n", packet_bytes_w, e_o_s);
#endif

  iter++;
  b_o_s = 0;
  if (iter == MAX_ITER) e_o_s = 1;
  packet_bytes_w *= 2;

  return 0;
}

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  static long packet_bytes_r = 1;
  static int iter = 0;
  static long b_o_s = 1;
  static long e_o_s = 0;

  if (iter > MAX_ITER) return 1;

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

  total_bytes_read += op->bytes;

#ifdef DEBUG
  printf ("packet_bytes_r expected: %ld, ", packet_bytes_r);
  printf ("op->bytes got: %ld\n", op->bytes);
#endif

  if (op->bytes != packet_bytes_r)
    FAIL ("Read incorrect length packet");

  if (op->packet[packet_bytes_r-1] != 'a' + iter)
    FAIL ("Packet contains incorrect data");

  if ((op->b_o_s == 0) != (b_o_s == 0))
    FAIL ("Packet has incorrect b_o_s");

  if ((op->e_o_s == 0) != (e_o_s == 0))
    FAIL ("Packet has incorrect e_o_s");

  if (op->granulepos != -1 && op->granulepos != total_bytes_read-1)
    FAIL ("Packet has incorrect granulepos");

  if (op->packetno != iter)
    FAIL ("Packet has incorrect packetno");

  iter++;
  b_o_s = 0;
  if (iter == MAX_ITER) e_o_s = 1;

  packet_bytes_r *= 2;

  return 0;
}

static size_t
my_io_read (void * user_handle, void * buf, size_t n)
{
  unsigned char * data_buf = (unsigned char *)user_handle;
  static int offset = 0;
  int len;

  len = MIN ((int)n, DATA_BUF_LEN - offset);
  memcpy (buf, &data_buf[offset], len);

  offset += len;

  return len;
}

int
main (int argc, char * argv[])
{
  OGGZ * reader, * writer;
  unsigned char data_buf[DATA_BUF_LEN];
  long n, nread;

  INFO ("Counting bytes read from packets written");

  writer = oggz_new (OGGZ_WRITE);
  if (writer == NULL)
    FAIL("newly created OGGZ writer == NULL");

  serialno = oggz_serialno_new (writer);

  if (oggz_write_set_hungry_callback (writer, hungry, 1, NULL) == -1)
    FAIL("Could not set hungry callback");

  reader = oggz_new (OGGZ_READ);
  if (reader == NULL)
    FAIL("newly created OGGZ reader == NULL");

  oggz_io_set_read (reader, my_io_read, data_buf);

  oggz_set_read_callback (reader, -1, read_packet, NULL);

  while ((n = oggz_write_output (writer, data_buf, DATA_BUF_LEN)) != 0) {
#ifdef DEBUG
    printf ("Wrote %ld bytes ...\n", n);
#endif

    if (n > DATA_BUF_LEN)
      FAIL("Too much data generated by writer");

    if (n > 0) {
      nread = oggz_read (reader, n);
#ifdef DEBUG
      printf ("Read %ld bytes ...\n", n);
#endif
    } else break;
  }

  if (oggz_close (writer) != 0)
    FAIL("Could not close OGGZ writer");

  while (oggz_read (reader, n) > 0);

  if (oggz_close (reader) != 0)
    FAIL("Could not close OGGZ reader");

#ifdef DEBUG
  printf ("total_bytes_written: %ld\n", total_bytes_written);
  printf ("total_bytes_read: %ld\n", total_bytes_read);
#endif

  if (total_bytes_written < total_bytes_read)
    FAIL ("Read more data than was written");

  if (total_bytes_written > total_bytes_read)
    FAIL ("Failed to read all data that was written");


  exit (0);
}
