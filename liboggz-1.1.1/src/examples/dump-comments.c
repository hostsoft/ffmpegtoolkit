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

#include "oggz/oggz.h"

static char * infilename;
static int previous_b_o_s = 0;

static void
read_comments (OGGZ * oggz, long serialno)
{
  const OggzComment * comment;
  const char * vendor;
  const char * content_type;

  content_type = oggz_stream_get_content_type (oggz, serialno);

  printf ("%s: serial %010lu\n\n", content_type, serialno);

  vendor = oggz_comment_get_vendor (oggz, serialno);
  if (vendor) printf ("  Vendor: %s\r\n", vendor);

  for (comment = oggz_comment_first (oggz, serialno); comment;
       comment = oggz_comment_next (oggz, serialno, comment)) {
    if (comment->value) {
      printf ("  %s: %s\r\n", comment->name, comment->value);
    } else {
      printf ("  %s\r\n", comment->name);
    }
  }

  puts ("\r\n");
}

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  if (previous_b_o_s) {
    read_comments (oggz, serialno);
  }

  previous_b_o_s = zp->op.b_o_s;

  return 0;
}

int
main (int argc, char ** argv)
{
  OGGZ * oggz;

  if (argc < 2) {
    printf ("usage: %s infilename\n", argv[0]);
    printf ("*** Oggz example program. ***\n");
    printf ("Read comments from an Ogg file.\n");
    exit (1);
  }

  infilename = argv[1];

  if ((oggz = oggz_open ((char *) infilename, OGGZ_READ)) == NULL) {
    printf ("unable to open file %s\n", infilename);
    exit (1);
  }

  oggz_set_read_callback (oggz, -1 /* read all streams */, read_packet, NULL);

  oggz_run (oggz);

  oggz_close (oggz);

  exit (0);
}

