/*
   Copyright (C) 2008 Annodex Association

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

/* Kangyuan Niu: original version (Aug 2007) */
/* Conrad Parker: modified based on modify-headers example (January 2008) */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <getopt.h>

#include "oggz/oggz.h"

#include "oggz_tools.h"

#define ID_WRITE_DIRECT
/* define USE_FLUSH_NEXT */

#ifdef USE_FLUSH_NEXT
static int flush_next = 0;
#endif

#define S_SERIALNO 0x7

typedef struct {
  int do_delete;
  int do_all;
  int got_non_bos;
  OGGZ * reader;
  OGGZ * writer;
  OGGZ * storer; /* Just used for storing comments from commandline */
  FILE * outfile;
  OggzTable * seen_tracks;
  OggzTable * serialno_table;
  OggzTable * content_types_table;
} OCData;

static char * progname;

static void
usage (char * progname)
{
  printf ("Usage: %s filename [options] tagname=tagvalue ...\n", progname);
  printf ("List or edit comments in an Ogg file.\n");
  printf ("\nSee http://wiki.xiph.org/index.php/VorbisComment for usage recommendations.\n");
  printf ("Note that VorbisComment metadata cannot be used with Dirac video tracks.\n");
  printf ("\nOutput options\n");
  printf ("  -l, --list             List the comments in the given file.\n");
  printf ("\nEditing options\n");
  printf ("  -o filename, --output filename\n");
  printf ("                         Specify output filename\n");
  printf ("  -d, --delete           Delete comments before editing\n");
  printf ("  -a, --all              Edit comments for all logical bitstreams\n");
  printf ("  -c content-type, --content-type content-type\n");
  printf ("                         Edit comments of the logical bitstreams with\n");
  printf ("                         specified content-type\n");
  printf ("  -s serialno, --serialno serialno\n");
  printf ("                         Edit comments of the logical bitstream with\n");
  printf ("                         specified serialno\n");
  printf ("\nMiscellaneous options\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");
}

static OCData *
ocdata_new ()
{
  OCData *ocdata = malloc (sizeof (OCData));

  if (ocdata == NULL) return NULL;

  memset (ocdata, 0, sizeof (OCData));

  ocdata->do_all = 1;

  ocdata->storer = oggz_new (OGGZ_WRITE);
  if (ocdata->storer == NULL)
    goto err_storer;
  
  ocdata->seen_tracks = oggz_table_new ();
  if (ocdata->seen_tracks == NULL)
    goto err_seen_tracks;

  ocdata->serialno_table = oggz_table_new();
  if (ocdata->serialno_table == NULL)
    goto err_serialno_table;

  ocdata->content_types_table = oggz_table_new();
  if (ocdata->content_types_table == NULL)
    goto err_content_types_table;
  
  return ocdata;

err_content_types_table:
  free (ocdata->serialno_table);
err_serialno_table:
  free (ocdata->seen_tracks);
err_seen_tracks:
  free (ocdata->storer);
err_storer:
  free (ocdata);

  return NULL;
}

static void 
ocdata_delete (OCData *ocdata)
{
  oggz_table_delete (ocdata->seen_tracks);
  oggz_table_delete (ocdata->serialno_table);
  oggz_table_delete (ocdata->content_types_table);
  
  if (ocdata->reader)
    oggz_close (ocdata->reader);
  if (ocdata->storer)
    oggz_close (ocdata->storer);
  if (ocdata->outfile)
    fclose (ocdata->outfile);
  
  free (ocdata);
}

static void
fail_dirac (OCData *ocdata)
{
  fprintf (stderr, "oggz-comment: Error: Comments cannot be stored in Dirac\n");

  ocdata_delete (ocdata);

  exit (1);
}

static int
filter_stream_p (const OCData *ocdata, long serialno)
{
  if (oggz_table_lookup (ocdata->seen_tracks, serialno) == NULL)
    return 0;

  if (ocdata->do_all)
    return 1;

  if (oggz_table_lookup (ocdata->serialno_table, serialno) != NULL)
    return 1;

  return 0;
}

static int
read_bos (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OCData * ocdata = (OCData *)user_data;
  const char * ident;
  int i, n;
  OggzStreamContent content;

  if (ogg_page_bos ((ogg_page *)og)) {
    ocdata->got_non_bos = 0;
  } else {
    ocdata->got_non_bos = 1;
    return OGGZ_CONTINUE;
  }

  /* Record this track in the seen_tracks table, unless it is Skeleton or Dirac.
   * We don't need to store any information about the track, just the fact
   * that it exists.
   * Store a dummy value (as NULL is not allowed in an OggzTable).
   */
  content = oggz_stream_get_content (oggz, serialno);
  switch (content) {
  case OGGZ_CONTENT_SKELETON:
    /* No VorbisComment for Skeleton, and no need to warn */
    break;
  case OGGZ_CONTENT_DIRAC:
    /* No VorbisComment for Dirac, see:
     * http://lists.xiph.org/pipermail/ogg-dev/2008-November/001277.html
     */
    if (ocdata->do_all) {
      fprintf (stderr, "oggz-comment: Warning: Ignoring Dirac track, serialno %010lu\n",
               serialno);
    } else {
      fail_dirac (ocdata);
    }
    break;
  default:
    oggz_table_insert (ocdata->seen_tracks, serialno, (void *)0x01);
  }

  ident = ot_page_identify (oggz, og, NULL);
  if (ident != NULL) {
    n = oggz_table_size (ocdata->content_types_table);
    for (i = 0; i < n; i++) {
      char * c = oggz_table_nth (ocdata->content_types_table, i, NULL);
      if (strcasecmp (c, ident) == 0) {
        oggz_table_insert (ocdata->serialno_table, serialno, (void *)0x7);
      }
    }
  }

  return OGGZ_CONTINUE;
}

static int
more_headers (OCData * ocdata, ogg_packet * op, long serialno)
{
  if (!ocdata->got_non_bos) return OGGZ_CONTINUE;

  /* Determine if we're finished processing headers */
  if (op->packetno+1 >= oggz_stream_get_numheaders (ocdata->reader, serialno)) {
    /* If this was the last header for this track, remove it from the
       track list */
    oggz_table_remove (ocdata->seen_tracks, serialno);

    /* If no more tracks are left in the track list, then we have processed
     * all the headers; stop processing of packets. */
    if (oggz_table_size (ocdata->seen_tracks) == 0) {
      return OGGZ_STOP_ERR;
    }
  }

  return OGGZ_CONTINUE;
}

static int
read_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OCData * ocdata = (OCData *)user_data;
  size_t n;

  n = fwrite (og->header, 1, og->header_len, ocdata->outfile);
  if (n == (size_t)og->header_len)
    n = fwrite (og->body, 1, og->body_len, ocdata->outfile);

  return OGGZ_CONTINUE;
}

static int
read_packet (OGGZ * oggz, oggz_packet * zp, long serialno, void * user_data)
{
  OCData * ocdata = (OCData *)user_data;
  ogg_packet * op = &zp->op;
  const char * vendor;
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

  /* Edit the packet data if required */
  if (filter_stream_p (ocdata, serialno) && op->packetno == 1) {
    vendor = oggz_comment_get_vendor (ocdata->reader, serialno);

    /* Copy across the comments, unless "delete comments before editing" */
    if (!ocdata->do_delete)
      oggz_comments_copy (ocdata->reader, serialno, ocdata->writer, serialno);

    /* Add stored comments from commandline */
    oggz_comments_copy (ocdata->storer, S_SERIALNO, ocdata->writer, serialno);

    /* Ensure the original vendor is preserved */
    oggz_comment_set_vendor (ocdata->writer, serialno, vendor);

    /* Generate the replacement comments packet */
    op = oggz_comments_generate (ocdata->writer, serialno, 0);
  }

  /* Feed the packet into the writer */
  if ((ret = oggz_write_feed (ocdata->writer, op, serialno, flush, NULL)) != 0) 
    fprintf (stderr, "oggz_write_feed: %d\n", ret);

  return more_headers (ocdata, op, serialno);
}

static int
edit_comments (OCData * ocdata, char * outfilename)
{
  unsigned char buf[1024];
  long n;

  if (outfilename == NULL) {
    ocdata->outfile = stdout;
  } else {
    ocdata->outfile = fopen (outfilename, "wb");
    if (ocdata->outfile == NULL) {
      fprintf (stderr, "%s: unable to open output file %s\n",
	       progname, outfilename);
      return -1;
    }
  }

  /* Set up writer, filling in ocdata for callbacks */
  if ((ocdata->writer = oggz_new (OGGZ_WRITE)) == NULL) {
    fprintf (stderr, "Unable to create new writer: out of memory\n");
  }

  /* Set a page reader to process bos pages */
  oggz_set_read_page (ocdata->reader, -1, read_bos, ocdata);

  /* First, process headers packet-by-packet. */
  oggz_set_read_callback (ocdata->reader, -1, read_packet, ocdata);
  while ((n = oggz_read (ocdata->reader, 1024)) > 0) {
    long nn;
    while ((nn=oggz_write_output (ocdata->writer, buf, n)) > 0) {
      if (fwrite (buf, 1, nn, ocdata->outfile) < (size_t)nn)
        break;
    }
  }

  /* We actually don't use the writer any more from here, so close it */
  oggz_close (ocdata->writer);

  /* Now, the headers are processed. We deregister the packet reading
   * callback. */
  oggz_set_read_callback (ocdata->reader, -1, NULL, NULL);

  /* We deal with the rest of the file as pages. */
  /* Register a callback that copies page data directly across to outfile */
  oggz_set_read_page (ocdata->reader, -1, read_page, ocdata);

  if (oggz_run (ocdata->reader) == OGGZ_ERR_OK)
    return 0;
  else
    return 1;
}

static int
read_comments(OGGZ *oggz, oggz_packet * zp, long serialno, void *user_data)
{
  OCData * ocdata = (OCData *)user_data;
  ogg_packet * op = &zp->op;
  const OggzComment * comment;
  const char * codec_name;

  if (filter_stream_p (ocdata, serialno) && op->packetno == 1) {
    codec_name = oggz_stream_get_content_type(oggz, serialno);
    if (codec_name) {
      printf ("%s: serialno %010lu\n", codec_name, serialno);
    } else {
      printf ("???: serialno %010lu\n", serialno);
    }

    printf("\tVendor: %s\n", oggz_comment_get_vendor(oggz, serialno));

    for (comment = oggz_comment_first(oggz, serialno); comment;
         comment = oggz_comment_next(oggz, serialno, comment))
      printf ("\t%s: %s\n", comment->name, comment->value);
  }

  return more_headers (ocdata, op, serialno);
}

static int
list_comments (OCData * ocdata)
{
  /* Set a page reader to process bos pages */
  oggz_set_read_page (ocdata->reader, -1, read_bos, ocdata);

  /* First, process headers packet-by-packet. */
  oggz_set_read_callback (ocdata->reader, -1, read_comments, ocdata);

  if (oggz_run (ocdata->reader) == OGGZ_ERR_STOP_OK)
    return 0;
  else
    return 1;
}

static void
store_comment (OCData * ocdata, char * s)
{
  char * c, * name, * value = NULL;

  if (s == NULL) return;

  name = s;

  c = strchr (s, '=');
  if (c != NULL) {
    *c = '\0';
    value = c+1;
  }

  oggz_comment_add_byname (ocdata->storer, S_SERIALNO, name, value);
}

int
main (int argc, char ** argv)
{
  char * infilename = NULL, * outfilename = NULL;
  OCData * ocdata;

  int filter_serialnos = 0;
  int filter_content_types = 0;

  int show_version = 0;
  int show_help = 0;
  int do_list = 0;

  long serialno;
  long n;
  int i = 1;

  char * optstring = "lo:dac:s:hv";

#ifdef HAVE_GETOPT_LONG
  static struct option long_options[] = {
    {"list",     no_argument, 0, 'l'},
    {"output",   required_argument, 0, 'o'},
    {"delete",   no_argument, 0, 'd'},
    {"all",      no_argument, 0, 'a'},
    {"content-type", required_argument, 0, 'c'},
    {"serialno", required_argument, 0, 's'},
    {"help",     no_argument, 0, 'h'},
    {"version",  no_argument, 0, 'v'},
    {0,0,0,0}
  };
#endif

  ot_init ();

  progname = argv[0];

  if (argc == 2 && !strncmp (argv[1], "-?", 2)) {
#ifdef HAVE_GETOPT_LONG
    ot_print_options (long_options, optstring);
#else
    ot_print_short_options (optstring);
#endif
    exit (0);
  }

  if (argc < 3) {
    usage (progname);
    return (1);
  }

  ocdata = ocdata_new ();
  if (ocdata == NULL) {
    fprintf (stderr, "oggz-comment: out of memory\n");
    exit (1);
  }

  while (1) {
#ifdef HAVE_GETOPT_LONG
    i = getopt_long(argc, argv, optstring, long_options, NULL);
#else
    i = getopt (argc, argv, optstring);
#endif
    if (i == -1) break;
    if (i == ':') {
      usage (progname);
      goto exit_err;
    }

    switch (i) {
    case 'l': /* list */
      do_list = 1;
      break;
    case 'd': /* delete */
      ocdata->do_delete = 1;
      break;
    case 'a': /* all */
      ocdata->do_all = 1;
      break;
    case 's': /* serialno */
      filter_serialnos = 1;
      ocdata->do_all = 0;
      serialno = atol (optarg);
      oggz_table_insert (ocdata->serialno_table, serialno, (void *)0x7);
      break;
    case 'c': /* content-type */
      if (strcasecmp (optarg, "dirac") == 0) {
        fail_dirac (ocdata);
      }
      filter_content_types = 1;
      ocdata->do_all = 0;
      n = oggz_table_size (ocdata->content_types_table);
      oggz_table_insert (ocdata->content_types_table, n, optarg);
      break;
    case 'h': /* help */
      show_help = 1;
      break;
    case 'v': /* version */
      show_version = 1;
      break;
    case 'o': /* output */
      outfilename = optarg;
      break;
    default:
      break;
    }
  }

  if (show_version) {
    printf ("%s version " VERSION "\n", progname);
  }

  if (show_help) {
    usage (progname);
  }

  if (show_version || show_help) {
    goto exit_ok;
  }

  if (optind >= argc) {
    usage (progname);
    goto exit_err;
  }

  /* Parse out new comments and infilename */
  for (; optind < argc; optind++) {
    char * s = argv[optind];

    if(strchr(s, '=') != NULL) {
      if (!do_list) store_comment (ocdata, s);
    } else {
      infilename = s;
    }
  }

  /* Set up reader */
  if (infilename == NULL || strcmp (infilename, "-") == 0) {
    ocdata->reader = oggz_open_stdio (stdin, OGGZ_READ|OGGZ_AUTO);
  } else {
    ocdata->reader = oggz_open (infilename, OGGZ_READ|OGGZ_AUTO);
  }

  if (ocdata->reader == NULL) {
    if (errno == 0) {
      fprintf (stderr, "%s: %s: error opening input file\n",
	      progname, infilename);
    } else {
      fprintf (stderr, "%s: %s: %s\n",
	       progname, infilename, strerror (errno));
    }
    goto exit_err;
  }

  if (do_list) {
    if (list_comments (ocdata) == 0)
      goto exit_ok;
    else
      goto exit_err;
  }

  if (edit_comments (ocdata, outfilename) == 0)
    goto exit_ok;
  else
    goto exit_err;

exit_ok:
  ocdata_delete (ocdata);
  exit (0);

exit_err:
  ocdata_delete (ocdata);
  exit (1);
}
