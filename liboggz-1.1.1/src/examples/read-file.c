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
#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#else
#  define PRId64 "I64d"
#endif
 
#include "oggz/oggz.h"

static int got_an_eos = 0;

static void
print_granulepos (ogg_int64_t granulepos, int granuleshift)
{
  if (granuleshift < 1) {
    printf ("%" PRId64, granulepos);
  } else {
    ogg_int64_t iframe, pframe;
    iframe = granulepos >> granuleshift;
    pframe = granulepos - (iframe << granuleshift);

    printf ("%" PRId64 "|%" PRId64, iframe, pframe);
  }
}


static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  int granuleshift;

  granuleshift = oggz_get_granuleshift (oggz, serialno);

  printf ("%010lu: op->granulepos: ", serialno);
  print_granulepos (op->granulepos, granuleshift);
  printf ("  oggz_tell_granulepos(): ");
  print_granulepos (oggz_tell_granulepos (oggz), granuleshift);

  if (op->b_o_s) {
    printf (" *** bos");
  }

  if (op->e_o_s) {
    got_an_eos = 1;
    printf (" *** eos");
  }

  printf ("\n");

  return 0;
}

int
main (int argc, char ** argv)
{
  OGGZ * oggz;

  if (argc < 2) {
    printf ("usage: %s filename\n", argv[0]);
  }

  if ((oggz = oggz_open ((char *)argv[1], OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("unable to open file %s\n", argv[1]);
    exit (1);
  }

  oggz_set_read_callback (oggz, -1, read_packet, NULL);

  oggz_run (oggz);

  oggz_close (oggz);

  exit (0);
}
