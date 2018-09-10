/*
   Copyright (C) 2007 Annodex Association

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

#include <stdio.h>
#include <stdlib.h>
#include "oggz/oggz.h"

#define ID_WRITE_DIRECT
/* define USE_FLUSH_NEXT */

#ifdef USE_FLUSH_NEXT
static int flush_next = 0;
#endif

typedef struct {
  OggzTable * tracks;
  OGGZ * reader;
  OGGZ * writer;
  FILE * outfile;
} MHData;

static int
read_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  MHData * mhdata = (MHData *)user_data;

  if (fwrite (og->header, 1, og->header_len, mhdata->outfile) == (size_t)og->header_len)
    if (fwrite (og->body, 1, og->body_len, mhdata->outfile) != (size_t)og->body_len)
      return OGGZ_STOP_ERR;

  return OGGZ_CONTINUE;
}

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  ogg_packet * op = &zp->op;
  MHData * mhdata = (MHData *)user_data;
  int flush;
  int ret;

  if (op->b_o_s) {
    /* Record this track in the tracks table. We don't need to store any
     * information about the track, just the fact that it exists.
     * Store a dummy value (as NULL is not allowed in an OggzTable).
     */
    oggz_table_insert (mhdata->tracks, serialno, (void *)0x01);
  }

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

  /* Do something with the packet data */
  if (op->packetno == 1) {
    oggz_comments_copy (mhdata->reader, serialno, mhdata->writer, serialno);
    oggz_comment_add_byname (mhdata->writer, serialno,
                             "EDITOR", "modify-headers");
    op = oggz_comments_generate (mhdata->writer, serialno, 0);
  }

  /* Feed the packet into the writer */
  if ((ret = oggz_write_feed (mhdata->writer, op, serialno, flush, NULL)) != 0) {
    printf ("oggz_write_feed: %d\n", ret);
  }

  /* Determine if we're finished processing headers */
  if (op->packetno+1 >= oggz_stream_get_numheaders (mhdata->reader, serialno)) {
    /* If this was the last header for this track, remove it from the
       track list */
    oggz_table_remove (mhdata->tracks, serialno);

    /* If no more tracks are left in the track list, then we have processed
     * all the headers; stop processing of packets. */
    if (oggz_table_size (mhdata->tracks) == 0) {
      return OGGZ_STOP_ERR;
    }
  }

  return OGGZ_CONTINUE;
}


int
main (int argc, char ** argv)
{
  char * infilename, * outfilename;
  MHData mhdata;
  unsigned char buf[1024];
  long n;

  if (argc < 3) {
    printf ("usage: %s infile outfile\n", argv[0]);
    exit (1);
  }

  infilename = argv[1];
  outfilename = argv[2];

  /* Set up reader */
  if ((mhdata.reader = oggz_open (infilename, OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("unable to open file %s\n", infilename);
    exit (1);
  }

  /* Set up writer, filling in mhdata for callbacks */
  mhdata.tracks = oggz_table_new ();
  if ((mhdata.writer = oggz_new (OGGZ_WRITE)) == NULL) {
    printf ("Unable to create new writer\n");
  }
  mhdata.outfile = fopen (outfilename, "w");

  /* First, process headers packet-by-packet. */
  oggz_set_read_callback (mhdata.reader, -1, read_packet, &mhdata);
  while ((n = oggz_read (mhdata.reader, 1024)) > 0) {
    while (oggz_write_output (mhdata.writer, buf, n) > 0) {
      if (fwrite (buf, 1, n, mhdata.outfile) != (size_t)n)
        break;
    }
  }

  /* We actually don't use the writer any more from here, so close it */
  oggz_close (mhdata.writer);

  /* Now, the headers are processed. We deregister the packet reading
   * callback. */
  oggz_set_read_callback (mhdata.reader, -1, NULL, NULL);

  /* We deal with the rest of the file as pages. */
  /* Register a callbak that copies page data directly across to outfile */
  oggz_set_read_page (mhdata.reader, -1, read_page, &mhdata);
  while ((n = oggz_read (mhdata.reader, 1024)) > 0);

  oggz_close (mhdata.reader);

  oggz_table_delete (mhdata.tracks);

  fclose (mhdata.outfile);

  exit (0);
}
