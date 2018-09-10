/*
   Copyright (C) 2008 Commonwealth Scientific and Industrial Research
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
#include <string.h>
#include <limits.h> /* LONG_MAX */
#include <math.h>
#include <ctype.h>

#include <getopt.h>
#include <errno.h>

#include <oggz/oggz.h>
#include "oggz_tools.h"
#include "mimetypes.h"

#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#else
#  define PRId64 "I64d"
#endif

#define READ_BLOCKSIZE 16384

static int show_all = 0;
static int show_as_mime = 0;
static int show_one_per_line = 0;
static int displayed_once = 0;
static int many_files = 0;

/* Assumes UNKNOWN is last - fair assumption I think */
static int codecs_count[OGGZ_CONTENT_UNKNOWN+1] = {0};

static void
usage (const char * progname)
{
  printf ("Usage: %s [options] filename ...\n", progname);
  printf ("List codecs in one or more Ogg files and their bitstreams. The default\n");
  printf ("comma-separated output is designed for use in an HTML5 <video> codecs\n");
  printf ("attribute.\n");
  printf ("\nDisplay options\n");
  printf ("  -a, --all              Display codec names multiple times if present in\n");
  printf ("                         multiple tracks.\n");
  printf ("  -m, --mime             Display MIME types rather than codec names\n");
  printf ("  -1, --one-per-line     Display one entry per line\n");
  printf ("\nMiscellaneous options\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");
}

#define SEP "------------------------------------------------------------"

typedef struct _OI_Info OI_Info;

/* Let's get functional */
typedef void (*OI_TrackFunc) (OI_Info * info, long serialno);

struct _OI_Info {
  OGGZ * oggz;
  OggzTable * tracks;
};

static void
oggz_info_apply (OI_TrackFunc func, OI_Info * info)
{
  long serialno;
  int n, i;

  n = oggz_table_size (info->tracks);
  for (i = 0; i < n; i++) {
    oggz_table_nth (info->tracks, i, &serialno);
    func (info, serialno);
  }
}

static void
print_codec_name (OI_Info * info, long serialno)
{
  OggzStreamContent content = oggz_stream_get_content(info->oggz, serialno);
  if (!codecs_count[content]++ || show_all) {
    if (displayed_once && !show_one_per_line) {
      printf(", ");
    }
    if (show_as_mime) {
      const char *mime_type = NULL;
      if (content < OGGZ_CONTENT_UNKNOWN)
        mime_type = mime_type_names[content];
      if (!mime_type) mime_type = "application/octet-stream";
      printf("%s%s", mime_type, show_one_per_line?"\n":"");
    }
    else {
      const char *codec_name = oggz_content_type (content), *ptr;
      if (!codec_name) codec_name = "unknown";
      for (ptr = codec_name; *ptr; ++ptr) putchar(tolower(*ptr));
      if (show_one_per_line) putchar('\n');
    }
    displayed_once = 1;
  }
}

static void
ensure_newline (void)
{
  if (many_files) {
    putchar ('\n');
  } else if (!show_one_per_line) {
    /* For single file, comma-separated output, don't put the
     * terminating newline on stdout, so that the program output
     * can be used in an HTML5 <video> codecs attribute.
     */
    fflush (stdout);
    fputc ('\n', stderr);
  }
}

static int
read_page_pass1 (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OI_Info * info = (OI_Info *)user_data;

  oggz_table_insert (info->tracks, serialno, &read_page_pass1); /* NULL makes it barf, needs anything */

  if (ogg_page_bos ((ogg_page *)og)) {
    return 0;
  }
  else {
    return OGGZ_STOP_OK;
  }
}

static int
oi_pass1 (OGGZ * oggz, OI_Info * info)
{
  long n, serialno;

  oggz_seek (oggz, 0, SEEK_SET);
  oggz_set_read_page (oggz, -1, read_page_pass1, info);

  while ((n = oggz_read (oggz, READ_BLOCKSIZE)) > 0);

  return 0;
}

int
main (int argc, char ** argv)
{
  int show_version = 0;
  int show_help = 0;

  char * progname;
  int i;

  char * infilename;
  OGGZ * oggz;
  OI_Info info;

  char * optstring = "hvam1";

#ifdef HAVE_GETOPT_LONG
  static struct option long_options[] = {
    {"help", no_argument, 0, 'h'},
    {"version", no_argument, 0, 'v'},
    {"all", no_argument, 0, 'a'},
    {"mime", no_argument, 0, 'm'},
    {"one-line", no_argument, 0, '1'},
    {NULL,0,0,0}
  };
#endif

  progname = argv[0];

  if (argc < 2) {
    usage (progname);
    return (1);
  }

  if (!strncmp (argv[1], "-?", 2)) {
#ifdef HAVE_GETOPT_LONG
    ot_print_options (long_options, optstring);
#else
    ot_print_short_options (optstring);
#endif
    exit (0);
  }

  while (1) {
#ifdef HAVE_GETOPT_LONG
    i = getopt_long (argc, argv, optstring, long_options, NULL);
#else
    i = getopt (argc, argv, optstring);
#endif
    if (i == -1) break;
    if (i == ':') {
      usage (progname);
      goto exit_err;
    }

    switch (i) {
    case 'h': /* help */
      show_help = 1;
      break;
    case 'v': /* version */
      show_version = 1;
      break;
    case 'a':
      show_all = 1;
      break;
    case 'm':
      show_as_mime = 1;
      break;
    case '1':
      show_one_per_line = 1;
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

  if (argc > optind+1) {
    many_files = 1;
  }

  while (optind < argc) {
    /* Reset state for new file */
    memset (codecs_count, 0, sizeof(codecs_count));
    displayed_once = 0;

    infilename = argv[optind++];

    if ((oggz = oggz_open (infilename, OGGZ_READ|OGGZ_AUTO)) == NULL) {
      fprintf (stderr, "%s: unable to open file %s\n", progname, infilename);
      return (1);
    }

    if (many_files)
      printf ("%s: ", infilename);

    info.oggz = oggz;
    info.tracks = oggz_table_new ();
    
    oi_pass1 (oggz, &info);

    oggz_info_apply (print_codec_name, &info);
    
    oggz_table_delete (info.tracks);

    oggz_close (oggz);

    ensure_newline ();
  }

 exit_ok:
  exit (0);

 exit_err:
  exit (1);
}
