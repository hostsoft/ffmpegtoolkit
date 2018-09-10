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

#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#else
#  define PRId64 "I64d"
#endif

#include "oggz/oggz.h"

#include "oggz_tests.h"

static int has_skeleton = 0;
static int verbose = 0;

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  unsigned char * header = op->packet;

  if (op->b_o_s) {
    if (op->bytes >= 8 && !strncmp ((char *)header, "fishead", 8))
      has_skeleton = 1;
    return OGGZ_CONTINUE;
  } else if (op->e_o_s) {
    return OGGZ_STOP_OK;
  } else {
    if (has_skeleton) return OGGZ_CONTINUE;
    else return OGGZ_STOP_OK;
  }
  return OGGZ_CONTINUE;
}

static ogg_int64_t
try_seek_units (OGGZ * oggz, ogg_int64_t units)
{
  ogg_int64_t result, diff;

  if (verbose)
    printf ("\tAttempt seek to %" PRId64 " ms:\n", units);

  result = oggz_seek_units (oggz, units, SEEK_SET);
  diff = result - units;

  if (verbose)
    printf ("\t%0" PRId64 "x: %" PRId64 " ms (%+" PRId64 " ms)\n",
	    oggz_tell (oggz), oggz_tell_units (oggz), diff);

  if (result < 0) {
    FAIL ("Seek failure\n");
  }

  if (result != oggz_tell_units (oggz))
    FAIL ("oggz_seek_units() result != oggz_tell_units()\n");

  if (units == 0 && result != 0)
    FAIL ("Failed seeking to 0");

  if (diff > 0)
    WARN ("Seek result too late");

  return units;
}

int
main (int argc, char * argv[])
{
  OGGZ * oggz;
  ogg_int64_t max_units;
  char * filename = NULL;
  int i;
  long n;

  for (i = 1; i < argc; i++) {
    if (!strcmp (argv[i], "--verbose")) {
      verbose = 1;
    } else {
      filename = argv[i];
    }
  }

  if (filename == NULL) {
    printf ("usage: %s [--verbose] filename\n", argv[0]);
    exit(1);
  }

  if ((oggz = oggz_open (filename, OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("%s: unable to open file %s\n", argv[0], filename);
    exit (1);
  }

  printf ("Testing %s ...\n", filename);

  oggz_set_read_callback (oggz, -1, read_packet, NULL);

  while ((n = oggz_read (oggz, 1024)) > 0);
  oggz_set_data_start (oggz, oggz_tell (oggz));
  
  max_units = oggz_seek_units (oggz, 0, SEEK_END);
  if (verbose)
    printf ("\t%0" PRId64 "x: %" PRId64 " ms\n",
            oggz_tell (oggz), oggz_tell_units (oggz));

  try_seek_units (oggz, max_units / 2);
  try_seek_units (oggz, 0);
  try_seek_units (oggz, max_units / 3);
  try_seek_units (oggz, 3 * max_units / 4);
  try_seek_units (oggz, 0);
  try_seek_units (oggz, 999 * max_units / 1000);
  try_seek_units (oggz, max_units / 100);

  oggz_close (oggz);

  exit (0);
}
