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

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

#include <getopt.h>
#include <errno.h>

#include "oggz/oggz.h"
#include "oggz_tools.h"

#define READ_SIZE 4096

static char * progname;

static void
usage (char * progname)
{
  printf ("Usage: %s [options] filename ...\n", progname);
  printf ("Sort the pages of an Ogg file in order of presentation time.\n");
  printf ("\nMiscellaneous options\n");
  printf ("  -o filename, --output filename\n");
  printf ("                         Specify output filename\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("  -V, --verbose          Verbose operation\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");
}

static void
exit_out_of_memory (void)
{
  fprintf (stderr, "%s: Out of memory\n", progname);
  exit (1);
}

static void
checked_fwrite (const void *data, size_t size, size_t count, FILE *stream)
{
  int n = fwrite (data, size, count, stream);
  if ((size_t)n != count) {
    perror ("write failed");
    exit (1);
  }
}

typedef struct _OSData OSData;
typedef struct _OSInput OSInput;
typedef struct _OSITrack OSITrack;

struct _OSData {
  char * infilename;
  OggzTable * inputs;
  int verbose;
};

struct _OSInput {
  OSData * osdata;
  OGGZ * reader;
  long serialno;
  const ogg_page * og;
};

struct _OSITrack {
  long output_serialno;
};

static ogg_page *
_ogg_page_copy (const ogg_page * og)
{
  ogg_page * new_og;

  new_og = malloc (sizeof (*og));
  if (new_og == NULL) return NULL;

  new_og->header = malloc (og->header_len);
  if (new_og->header == NULL) {
    free (new_og);
    return NULL;
  }
  new_og->header_len = og->header_len;
  memcpy (new_og->header, og->header, og->header_len);

  new_og->body = malloc (og->body_len);
  if (new_og->body == NULL) {
    free (new_og->header);
    free (new_og);
    return NULL;
  }
  new_og->body_len = og->body_len;
  memcpy (new_og->body, og->body, og->body_len);

  return new_og;
}

static int
_ogg_page_free (const ogg_page * og)
{
  free (og->header);
  free (og->body);
  free ((ogg_page *)og);
  return 0;
}

static void
osinput_delete (OSInput * input)
{
  oggz_close (input->reader);

  free (input);
}

static OSData *
osdata_new (void)
{
  OSData * osdata;

  osdata = (OSData *) malloc (sizeof (OSData));
  if (osdata == NULL) return NULL;

  osdata->inputs = oggz_table_new ();
  if (osdata->inputs == NULL) {
    free (osdata);
    return NULL;
  }

  osdata->verbose = 0;

  return osdata;
}

static void
osdata_delete (OSData * osdata)
{
  OSInput * input;
  int i, ninputs;

  ninputs = oggz_table_size (osdata->inputs);
  for (i = 0; i < ninputs; i++) {
    input = (OSInput *) oggz_table_nth (osdata->inputs, i, NULL);
    osinput_delete (input);
  }
  oggz_table_delete (osdata->inputs);

  free (osdata);
}

static int
read_page (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OSInput * input = (OSInput *) user_data;

  /* If this is the serialno that this input is tracking, stash it;
   * otherwise continue scanning the file */
  if (serialno == input->serialno) {
    ogg_page *iog;
    iog = _ogg_page_copy (og);
    if (iog == NULL) return OGGZ_STOP_ERR;

    /* If this page's granulepos should be -1 but isn't then fix that before
     * storing and sorting the page. */
    if(ogg_page_packets(iog)==0&&ogg_page_granulepos(iog)!=-1) {
      memset(iog->header+6,0xFF,8);
      ogg_page_checksum_set(iog);
    }
    input->og = iog;
    return OGGZ_STOP_OK;
  } else {
    return OGGZ_CONTINUE;
  }
}

static int
read_page_add_input (OGGZ * oggz, const ogg_page * og, long serialno,
                     void * user_data)
{
  OSData * osdata = (OSData *)user_data;
  OSInput * input;
  int is_bos, nfiles;

#ifdef OGG_H_CONST_CORRECT
  is_bos = ogg_page_bos (og);
#else
  is_bos = ogg_page_bos ((ogg_page *)og);
#endif

  if (is_bos) {
    input = (OSInput *) malloc (sizeof (OSInput));
    if (input == NULL) return OGGZ_STOP_ERR;

    input->osdata = osdata;
    input->reader = oggz_open (osdata->infilename, OGGZ_READ|OGGZ_AUTO);
    if (input->reader == NULL) {
      free (input);
      return OGGZ_STOP_ERR;
    }

    input->serialno = serialno;
    input->og = NULL;

    oggz_set_read_page (input->reader, -1, read_page, input);

    nfiles = oggz_table_size (osdata->inputs);
    if (!oggz_table_insert (osdata->inputs, nfiles++, input)) {
      osinput_delete (input);
      return OGGZ_STOP_ERR;
    }

    return OGGZ_CONTINUE;
  } else {
    return OGGZ_STOP_OK;
  }
}

static int
osdata_add_file (OSData * osdata, char * infilename)
{
  OGGZ * reader;

  osdata->infilename = infilename;

  if ((reader = oggz_open (infilename, OGGZ_READ|OGGZ_AUTO)) != NULL) {
    oggz_set_read_page (reader, -1, read_page_add_input, osdata);
    oggz_run (reader);
    oggz_close (reader);
    return 0;
  } else {
    return -1;
  }
}

static int
oggz_sort (OSData * osdata, FILE * outfile)
{
  OSInput * input;
  int ninputs, i, min_i;
  long key, n;
  ogg_int64_t units, min_units;
  const ogg_page * og;
  int active;

  /* For theora+vorbis, ensure theora bos is first */
  int careful_for_theora = 0;

  int v;

  if (oggz_table_size (osdata->inputs) == 2)
    careful_for_theora = 1;

  while ((ninputs = oggz_table_size (osdata->inputs)) > 0) {
    min_units = -1;
    min_i = -1;
    active = 1;

    if (osdata->verbose)
      printf ("------------------------------------------------------------\n");

    /* Reload all pages, and find the min (earliest) */
    for (i = 0; active && i < oggz_table_size (osdata->inputs); i++) {
      input = (OSInput *) oggz_table_nth (osdata->inputs, i, &key);
      if (input != NULL) {
	while (input && input->og == NULL) {
	  n = oggz_read (input->reader, READ_SIZE);
	  if (n == 0) {
	    oggz_table_remove (osdata->inputs, key);
	    osinput_delete (input);
	    input = NULL;
	  } else if (n == OGGZ_ERR_STOP_ERR) {
            exit_out_of_memory();
	  }
	}
	if (input && input->og) {
	  if (ogg_page_bos ((ogg_page *)input->og)) {
	    min_i = i;

	    if (careful_for_theora) {
	      if (i == 0 && oggz_stream_get_content (input->reader, input->serialno) == OGGZ_CONTENT_VORBIS)
		careful_for_theora = 0;
	      else
		active = 0;
	    } else {
	      active = 0;
	    }
          }
	  units = oggz_tell_units (input->reader);

	  if (osdata->verbose) {
	    ot_fprint_time (stdout, (double)units/1000);
	    printf (": Got index %d serialno %010u %lld units: ",
		    i, ogg_page_serialno ((ogg_page *)input->og), (long long) units);
	  }

	  if (min_units == -1 || units == 0 ||
	      (units > -1 && units < min_units)) {
	    min_units = units;
	    min_i = i;
	    if (osdata->verbose)
	      printf ("Min\n");
	  } else {
	    if (osdata->verbose)
	      printf ("Moo\n");
	  }
	} else if (osdata->verbose) {
	  if (input == NULL) {
	    printf ("*** index %d NULL\n", i);
	  } else {
	    printf ("*** No page from index %d\n", i);
	  }
	}
      }
    }

    if (osdata->verbose)
      printf ("Min index %d\n", min_i);

    /* Write the earliest page */
    if (min_i != -1) {
      input = (OSInput *) oggz_table_nth (osdata->inputs, min_i, &key);
      og = input->og;
      checked_fwrite (og->header, 1, og->header_len, outfile);
      checked_fwrite (og->body, 1, og->body_len, outfile);

      _ogg_page_free (og);
      input->og = NULL;
    }
  }

  return 0;
}

int
main (int argc, char * argv[])
{
  int show_version = 0;
  int show_help = 0;

  char * infilename = NULL, * outfilename = NULL;
  FILE * infile = NULL, * outfile = NULL;
  OSData * osdata;
  int i;

  char * optstring = "hvVo:";

#ifdef HAVE_GETOPT_LONG
  static struct option long_options[] = {
    {"help", no_argument, 0, 'h'},
    {"version", no_argument, 0, 'v'},
    {"verbose", no_argument, 0, 'V'},
    {"output", required_argument, 0, 'o'},
    {0,0,0,0}
  };
#endif

  ot_init ();

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

  osdata = osdata_new();
  if (osdata == NULL)
    exit_out_of_memory();

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
    case 'o': /* output */
      outfilename = optarg;
      break;
    case 'V': /* verbose */
      osdata->verbose = 1;
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

  infilename = argv[optind++];
  if (osdata_add_file (osdata, infilename) == -1) {
    fprintf (stderr, "%s: unable to open input file %s\n",
             progname, infilename);
    goto exit_err;
  }

  if (outfilename == NULL) {
    outfile = stdout;
  } else {
    outfile = fopen (outfilename, "wb");
    if (outfile == NULL) {
      fprintf (stderr, "%s: unable to open output file %s\n",
	       progname, outfilename);
      goto exit_err;
    }
  }

  oggz_sort (osdata, outfile);

 exit_ok:
  osdata_delete (osdata);
  exit (0);

 exit_err:
  osdata_delete (osdata);
  exit (1);
}
