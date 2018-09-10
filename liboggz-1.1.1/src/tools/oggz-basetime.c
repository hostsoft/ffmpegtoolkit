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

#include "oggz_tools.h"

/* #define DEBUG */

typedef struct {
  ogg_int64_t delta;
  int nr_packets;
} OBTrackData;

typedef struct {
  ogg_int64_t base_units;
  OggzTable * tracks;
} OBData;

static  ogg_int64_t
_le_64 (ogg_int64_t l)
{
  ogg_int64_t ret=l;
  unsigned char *ucptr = (unsigned char *)&ret;
#ifdef WORDS_BIGENDIAN
  unsigned char temp;

  temp = ucptr [0] ;
  ucptr [0] = ucptr [7] ;
  ucptr [7] = temp ;

  temp = ucptr [1] ;
  ucptr [1] = ucptr [6] ;
  ucptr [6] = temp ;

  temp = ucptr [2] ;
  ucptr [2] = ucptr [5] ;
  ucptr [5] = temp ;

  temp = ucptr [3] ;
  ucptr [3] = ucptr [4] ;
  ucptr [4] = temp ;

#endif
  return (*(ogg_int64_t *)ucptr);
}

#define INT64_LE_AT(x) _le_64((*(ogg_int64_t *)(x)))

/********** OBTrackData **********/

static OBTrackData *
or_track_data_new (void)
{
  OBTrackData * ort;

  ort = malloc (sizeof (OBTrackData));
  if (ort == NULL) return NULL;

  ort->delta = -1;
  ort->nr_packets = 0;

  return ort;
}

static void
or_track_data_delete (OBTrackData * ort)
{
  free (ort);
}

/********** OBData **********/

static OBData *
or_data_new (void)
{
  OBData * ord;

  ord = malloc (sizeof (OBData));
  if (ord == NULL) return NULL;

  ord->base_units = -1;
  ord->tracks = oggz_table_new ();
  if (ord->tracks == NULL) {
    free (ord);
    return NULL;
  }

  return ord;
}

static void
or_data_delete (OBData * ord)
{
  int i, n;
  OBTrackData * ort;

  n = oggz_table_size (ord->tracks);
  for (i=0; i<n; i++) {
    ort = oggz_table_nth (ord->tracks, i, NULL);
    or_track_data_delete (ort);
  }
  oggz_table_delete (ord->tracks);
}

/********** checked_fwrite **********/

static void
checked_fwrite (const void *data, size_t size, size_t count, FILE *stream)
{
  int n = fwrite (data, size, count, stream);
  if ((size_t)n != count) {
    perror ("write failed");
    exit (1);
  }
}

/********** Filter **********/

static int
filter_page (OGGZ * oggz, const ogg_page * og, long serialno, OBData * ord)
{
  OBTrackData * ort;
  ogg_int64_t granulepos, new_granulepos;
  ogg_int64_t iframe, pframe;
  int granuleshift;

  ort = oggz_table_lookup (ord->tracks, serialno);

  granulepos = ogg_page_granulepos ((ogg_page *)og);
  granuleshift = oggz_get_granuleshift (oggz, serialno);

  iframe = granulepos >> granuleshift;
  pframe = granulepos - (iframe << granuleshift);

  iframe -= ort->delta;

  new_granulepos = (iframe << granuleshift) + pframe;

#ifdef DEBUG
    fprintf (stderr, "old gp %lld, new gp %lld", granulepos, new_granulepos);
#endif

  *(ogg_int64_t *)(&og->header[6]) = _le_64(new_granulepos);

#ifdef DEBUG
  fprintf (stderr, ", totally new gp %lld\n", INT64_LE_AT(&og->header[6]));
#endif

  /* AFTER making any changes to the page, recalculate the page checksum */
  ogg_page_checksum_set ((ogg_page *)og);

  return 0;
}


static int
read_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OBData * ord = (OBData *)user_data;
  OBTrackData * ort;
  ogg_int64_t gr_n, gr_d;
  int numheaders;

  if (ogg_page_bos ((ogg_page *)og)) {
    if ((ort = or_track_data_new ()) == NULL)
      return OGGZ_STOP_ERR;
    oggz_table_insert (ord->tracks, serialno, ort);
  } else {
    ort = oggz_table_lookup (ord->tracks, serialno);
  }

#ifdef DEBUG
  fprintf (stderr, "--------\n");
#endif

  numheaders = oggz_stream_get_numheaders (oggz, serialno);

  /* If this is the first data page of any track, use its timestamp
   * as the delta by which to shift all tracks. Hence this page will
   * get shifted to timestamp 0, and all other pages in the stream will
   * be shifted relatively.
   */
  if (ord->base_units == -1 && ort->nr_packets >= numheaders) {
    ord->base_units = oggz_tell_units (oggz);
#ifdef DEBUG
    fprintf (stderr, "BASE UNITS: %lld\n", ord->base_units);
#endif
  }

  /* If this is the first data page of a track, calculate the delta
   * by which to shift all pages of this track */
  if (ord->base_units != -1 && ort->nr_packets >= numheaders && ort->delta == -1) {
    oggz_get_granulerate (oggz, serialno, &gr_n, &gr_d);
    ort->delta = (ord->base_units * gr_n) / (gr_d);
#ifdef DEBUG
    fprintf (stderr, "%010lu: DELTA %lld (gr: %lld/%lld)\n",
	     serialno, ort->delta, gr_n, gr_d);
#endif
  }

  /* header pages have a granulepos 0 and should not have it changed */
  if (ogg_page_granulepos ((ogg_page *) og) != 0) {
    filter_page (oggz, og, serialno, ord);
  }

  ort->nr_packets += ogg_page_packets ((ogg_page *)og);

#ifdef DEBUG
  fprintf (stderr, "%010lu: %d packets, gp %lld\n",
	   serialno, ort->nr_packets, ogg_page_granulepos ((ogg_page *)og));
#endif

  checked_fwrite (og->header, 1, og->header_len, stdout);
  checked_fwrite (og->body, 1, og->body_len, stdout);

  return 0;
}

int
usage (char * progname)
{
  printf ("usage: %s filename\n", progname);
  printf ("Shift timestamps on all pages such that the stream starts at 0.\n");

  return 0;
}

int
main (int argc, char ** argv)
{
  char * progname = argv[0];
  OGGZ * oggz;
  OBData * ord;
  int ret;

  if (argc < 2) {
    usage (progname);
    return (1);
  }

  if (!strncmp (argv[1], "-?", 2)) {
    printf ("-h --help\n");
    exit (0);
  }

  if (!strcmp (argv[1], "-h") || !strcmp (argv[1], "--help")) {
    usage (progname);
    return (0);
  }

  ord = or_data_new ();
  if (ord == NULL) goto oom;

  if ((oggz = oggz_open ((char *)argv[1], OGGZ_READ | OGGZ_AUTO)) == NULL) {
    printf ("unable to open file %s\n", argv[1]);
    exit (1);
  }

  oggz_set_read_page (oggz, -1, read_page, ord);

  ret = oggz_run (oggz);

  oggz_close (oggz);

  or_data_delete (ord);

  if (ret == OGGZ_ERR_STOP_ERR) goto oom;

  exit (0);

oom:
  fprintf (stderr, "%s: out of memory\n", progname);
  exit (1);
}
