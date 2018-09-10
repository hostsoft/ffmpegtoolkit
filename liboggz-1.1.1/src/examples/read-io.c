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
#include "oggz/oggz.h"

#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#else
#  define PRId64 "I64d"
#endif

static int got_an_eos = 0;

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;

#if 0
  if (got_an_eos) {
    printf ("[%010lu]\t%ld bytes\tgranulepos %ld\n", serialno, op->bytes,
	    (long)op->granulepos);
  }
#endif

  if (op->b_o_s) {
    printf ("%010lu: [%" PRId64 "] BOS %8s\n", serialno, op->granulepos, op->packet);
  }

  if (op->e_o_s) {
    got_an_eos = 1;
    printf ("%010lu: [%" PRId64 "] EOS\n", serialno, op->granulepos);
  }

  return 0;
}

static size_t
my_io_read (void * user_handle, void * buf, size_t n)
{
  FILE * f = (FILE *)user_handle;

  return fread (buf, 1, n, f);
}

static int
my_io_seek (void * user_handle, long offset, int whence)
{
  FILE * f = (FILE *)user_handle;

  return (fseek (f, offset, whence));
}

static long
my_io_tell (void * user_handle)
{
  FILE * f = (FILE *)user_handle;

  return ftell (f);
}

int
main (int argc, char ** argv)
{
  FILE * f;
  OGGZ * oggz;
  long n;
  ogg_int64_t units;

  if (argc < 2) {
    printf ("usage: %s filename\n", argv[0]);
  }

  if ((f = fopen ((char *)argv[1], "rb")) == NULL) {
    printf ("unable to open file %s\n", argv[1]);
    exit (1);
  }

  if ((oggz = oggz_new (OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("unable to create oggz\n");
    exit (1);
  }

  oggz_io_set_read (oggz, my_io_read, f);
  oggz_io_set_seek (oggz, my_io_seek, f);
  oggz_io_set_tell (oggz, my_io_tell, f);

  oggz_set_read_callback (oggz, -1, read_packet, NULL);

  while ((n = oggz_read (oggz, 1024)) > 0);

  units = oggz_tell_units (oggz);
  printf ("Total length: %" PRId64 " ms\n", units);

  oggz_seek_units (oggz, units/2, SEEK_SET);

  printf ("seeked to byte offset %" PRId64 "\n", oggz_tell (oggz));

  while ((n = oggz_read (oggz, 1024)) > 0);

  oggz_close (oggz);

  exit (0);
}
