/*
   Copyright (C) 2003 Commonwealth Scientific and Industrial Research
   Organisation (CSIRO) Australia
   Also (C) 2005 Michael Smith <msmith@xiph.org>

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
#include <ogg/ogg.h>

struct eos_fix {
  /* Output file */
  FILE *out; 

  /* Stream serial -> struct eos_fix_stream mapping */
  OggzTable * tracks;
};

/* We have one of these for each logical stream */
struct eos_fix_stream {
  long lastvalidpage; /* The pageno of the final useful page */
  int discarding; /* Once we've processed the final useful page, we throw
                     out any further non-useful streams */
};

static void clear_table(OggzTable *table) {
  int i, size = oggz_table_size(table);
  for(i = 0; i < size; i++) {
    free(oggz_table_nth(table, i, NULL));
  }
}

static int
read_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  struct eos_fix *fixer = (struct eos_fix *)user_data;
  OggzTable * tracks = fixer->tracks;
  long pageno = ogg_page_pageno((ogg_page *)og);

  /* Insert this if it's a page that completes one or more packets; each time
   * we call this it gets overwritten, the end result is that we mark the last
   * page that contains the end of one or more packets.
   */
  if(ogg_page_packets((ogg_page *)og) != 0) {
    struct eos_fix_stream *data = (struct eos_fix_stream *)oggz_table_lookup(tracks, serialno);
    if(data == NULL) {
      data = malloc(sizeof(struct eos_fix_stream));
    }
    data->lastvalidpage = pageno;
    data->discarding = 0;
    oggz_table_insert (tracks, serialno, data);
  }

  return 0;
}

static int
write_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  struct eos_fix *fixer = (struct eos_fix *)user_data;
  OggzTable * tracks = fixer->tracks;
  long pageno = ogg_page_pageno((ogg_page *)og);
  struct eos_fix_stream *data = (struct eos_fix_stream *)oggz_table_lookup(tracks, serialno);

  if(data == NULL) {
    fprintf(stderr, "Bailing out, internal consistency failure\n");
    abort();
  }

  if(data->lastvalidpage == pageno) {
    unsigned char header_type = og->header[5];
    if(!(header_type & 0x4)) {
      fprintf(stderr, "Setting EOS on final page of stream %ld\n",
		      serialno);
      header_type |= 0x4;
      og->header[5] = header_type;

      ogg_page_checksum_set((ogg_page *)og);
    }

    /* Now we want to discard any remaining partial packets at the end of this
     * page. Unfortunately, neither libogg nor liboggz have helpful
     * functions for this, so do it all in a manual way...
     *
     * We need to do this because libogg (correctly) doesn't tag the last
     * complete packet on an EOS page with EOS if there's an incomplete
     * packet following it (so you get complaints from oggz-validate).
     */
    {
      int i, segments, discard = 0;
      segments = og->header[26];
      for(i=segments-1; i >= 0; i--) {
        if(og->header[i+27] < 255)
            break;
        else
            discard += 255;
      }
      if(i != segments-1) {
        fprintf(stderr, "Discarding %d useless segments of %d, retaining %d\n", segments-1-i, segments, i+1);
        og->header[26] = i+1;
        ((ogg_page *)og)->header_len -= segments-1-i;
        ((ogg_page *)og)->body_len -= discard;
        ogg_page_checksum_set((ogg_page *)og);
      }
    }
    
    /* Write out this page, but no following ones */
    if (fwrite (og->header, 1, og->header_len, fixer->out) == (size_t)og->header_len)
      if (fwrite (og->body, 1, og->body_len, fixer->out) != (size_t)og->body_len)
        return -1;
    data->discarding = 1;
  }

  if(!data->discarding) {
    if (fwrite (og->header, 1, og->header_len, fixer->out) == (size_t)og->header_len)
      if (fwrite (og->body, 1, og->body_len, fixer->out) != (size_t)og->body_len)
        return -1;
  }

  return 0;
}

int
main (int argc, char ** argv)
{
  OGGZ * oggz;
  struct eos_fix fixer;
  long n;
  char *progname = argv[0];

  if (argc < 3) {
    printf ("usage: %s in.ogg out.ogg\n", progname);
  }

  fixer.tracks = oggz_table_new ();
  fixer.out = NULL;

  if ((oggz = oggz_open ((char *)argv[1], OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("%s: unable to open file %s\n", progname, argv[1]);
    exit (1);
  }

  oggz_set_read_page (oggz, -1, read_page, &fixer);

  while ((n = oggz_read (oggz, 1024)) > 0);

  oggz_close (oggz);

  fixer.out = fopen(argv[2], "wb");
  if(!fixer.out) {
    fprintf(stderr, "%s: Failed to open output file \"%s\"\n", progname, argv[2]);
    exit(1);
  }

  if ((oggz = oggz_open ((char *)argv[1], OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("%s: unable to open file %s\n", progname, argv[1]);
    exit (1);
  }

  oggz_set_read_page (oggz, -1, write_page, &fixer);

  while ((n = oggz_read (oggz, 1024)) > 0);

  oggz_close (oggz);

  clear_table(fixer.tracks);
  oggz_table_delete (fixer.tracks);

  fclose(fixer.out);

  exit (0);
}
