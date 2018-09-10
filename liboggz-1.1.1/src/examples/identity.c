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

#include <stdio.h>
#include <stdlib.h>
#include "oggz/oggz.h"

#define ID_WRITE_DIRECT
/* define USE_FLUSH_NEXT */

#ifdef USE_FLUSH_NEXT
static int flush_next = 0;
#endif

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  OGGZ * writer = (OGGZ *)user_data;
  int flush;
  int ret;

#ifdef USE_FLUSH_NEXT
  flush = flush_next;
  if (op->granulepos == -1) {
    flush_next = 0;
  } else {
    flush_next = OGGZ_FLUSH_BEFORE;
  }
#else
  if (op->granulepos == -1) {
    flush = 0;
  } else {
    flush = OGGZ_FLUSH_AFTER;
  }
#endif

  if ((ret = oggz_write_feed (writer, op, serialno, flush, NULL)) != 0) {
    printf ("oggz_write_feed: %d\n", ret);
  }

  return 0;
}

int
main (int argc, char ** argv)
{
  char * infilename, * outfilename;
  OGGZ * reader, * writer;
#ifndef ID_WRITE_DIRECT
  FILE * outfile;
  unsigned char buf[1024];
#endif
  long n;

  if (argc < 3) {
    printf ("usage: %s infile outfile\n", argv[0]);
  }

  infilename = argv[1];
  outfilename = argv[2];

  if ((reader = oggz_open (infilename, OGGZ_READ)) == NULL) {
    printf ("unable to open file %s\n", infilename);
    exit (1);
  }

#ifdef ID_WRITE_DIRECT
  if ((writer = oggz_open (outfilename, OGGZ_WRITE)) == NULL) {
    printf ("unable to open file %s\n", outfilename);
    exit (1);
  }
#else
  if ((writer = oggz_new (OGGZ_WRITE)) == NULL) {
    printf ("Unable to create new writer\n");
  }
  outfile = fopen (outfilename, "w");
#endif

  oggz_set_read_callback (reader, -1, read_packet, writer);

  while ((n = oggz_read (reader, 1024)) > 0) {
#ifdef ID_WRITE_DIRECT
    while (oggz_write (writer, n) > 0);
#else
    while (oggz_write_output (writer, buf, n) > 0) {
      fwrite (buf, 1, n, outfile);
    }
#endif
  }

#ifndef ID_WRITE_DIRECT
  fclose (outfile);
#endif

  oggz_close (writer);
  oggz_close (reader);

  exit (0);
}
