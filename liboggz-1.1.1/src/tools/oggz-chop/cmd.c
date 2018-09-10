#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#include "oggz-chop.h"
#include "oggz_tools.h"
#include "timespec.h"

static char * progname;

static void
usage (char * progname)
{
  printf ("Usage: %s [options] filename\n", progname);
  printf ("Extract the part of an Ogg file between given start and/or end times.\n");
  printf ("\nOutput options\n");
  printf ("  -o filename, --output filename\n");
  printf ("                         Specify output filename\n");
  printf ("  -s start_time, --start start_time\n");
  printf ("                         Specify start time\n");
  printf ("  -e end_time, --end end_time\n");
  printf ("                         Specify end time\n");
  printf ("  -k , --no-skeleton     Do NOT include a Skeleton bitstream in the output");
  printf ("\nMiscellaneous options\n");
  printf ("  -n, --dry-run          Don't actually write the output\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("  -V, --verbose          Verbose operation, prints to stderr\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");
}

static int
version (FILE *stream)
{
    return fprintf (stream, "%s version " VERSION "\n", progname);
}

int
cmd_main (OCState * state, int argc, char * argv[])
{
  int show_version = 0;
  int show_help = 0;
  int i;

  char * optstring = "s:e:o:knhvV";

#ifdef HAVE_GETOPT_LONG
  static struct option long_options[] = {
    {"start",    required_argument, 0, 's'},
    {"end",      required_argument, 0, 'e'},
    {"output",   required_argument, 0, 'o'},
    {"no-skeleton", no_argument, 0, 'k'},
    {"dry-run",  no_argument, 0, 'n'},
    {"help",     no_argument, 0, 'h'},
    {"version",  no_argument, 0, 'v'},
    {"verbose",  no_argument, 0, 'V'},
    {0,0,0,0}
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

  memset (state, 0, sizeof(*state));
  state->end = -1.0;
  state->do_skeleton = 1;

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
    case 's': /* start */
      state->start = parse_timespec (optarg);
      break;
    case 'e': /* end */
      state->end = parse_timespec (optarg);
      break;
    case 'k': /* no-skeleton */
      state->do_skeleton = 0;
      break;
    case 'n': /* dry-run */
      state->dry_run = 1;
      break;
    case 'h': /* help */
      show_help = 1;
      break;
    case 'v': /* version */
      show_version = 1;
      break;
    case 'V': /* verbose */
      state->verbose = 1;
      break;
    case 'o': /* output */
      state->outfilename = optarg;
      break;
    default:
      break;
    }
  }

  if (show_version) {
    version (stdout);
  } else if (state->verbose) {
    version (stderr);
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

  state->infilename = argv[optind++];

  return chop (state);

exit_ok:
  return 0;

exit_err:
  return 1;
}
