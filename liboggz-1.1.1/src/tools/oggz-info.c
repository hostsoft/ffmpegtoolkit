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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h> /* LONG_MAX */
#include <math.h>

#include <getopt.h>
#include <errno.h>

#include "oggz/oggz.h"
#include "oggz_tools.h"

#include "skeleton.h"

#ifdef HAVE_INTTYPES_H
#  include <inttypes.h>
#else
#  define PRId64 "I64d"
#endif

#define READ_BLOCKSIZE 1024000

static char * progname;

static void
usage (const char * progname)
{
  printf ("Usage: %s [options] filename ...\n", progname);
  printf ("Display information about one or more Ogg files and their bitstreams\n");
  printf ("\nDisplay options\n");
  printf ("  -l, --length           Display content lengths\n");
  printf ("  -b, --bitrate          Display bitrate information\n");
  printf ("  -g, --page-stats       Display Ogg page statistics\n");
  printf ("  -p, --packet-stats     Display Ogg packet statistics\n");
  printf ("  -k, --skeleton         Display Extra data from OggSkeleton bitstream\n");
  printf ("  -a, --all              Display all information\n");
  printf ("\nMiscellaneous options\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("\n");
  printf ("Byte lengths are displayed using the following units:\n");
  printf ("  bytes (8 bits)\n");
  printf ("  kB    kilobytes (1024 bytes)\n");
  printf ("  MB    megabytes (1024*1024 bytes)\n");
  printf ("  GB    gigabytes (1024*1024*1024 bytes)\n");
  printf ("\n");
  printf ("Bitrates are displayed using the following units:\n");
  printf ("  bps   bits per second     (bit/s)\n");
  printf ("  kbps  kilobits per second (1000 bit/s)\n");
  printf ("  Mbps  megabits per second (1000000 bit/s)\n");
  printf ("  Gbps  gigabits per second (1000000000 bit/s)\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");
}

static void
exit_out_of_memory (void)
{
  fprintf (stderr, "%s: Out of memory\n", progname);
  exit (1);
}

#define SEP "------------------------------------------------------------"

typedef struct _OI_Info OI_Info;
typedef struct _OI_Stats OI_Stats;
typedef struct _OI_TrackInfo OI_TrackInfo;

/* Let's get functional */
typedef int (*OI_TrackFunc) (OI_Info * info, OI_TrackInfo * oit, long serialno);

/* Out of memory return value from OI_TrackFunc, aborts oggz_info_apply() */
#define OIT_OOM (-1)

struct _OI_Info {
  OGGZ * oggz;
  OggzTable * tracks;
  ogg_int64_t duration;
  long length_total;
  long overhead_length_total;
};

struct _OI_Stats {
  /* Pass 1 */
  long count;
  long length_total;
  long length_min;
  long length_max;
  long overhead_length_total;

  /* Pass 2 */
  long length_avg;
  ogg_int64_t length_deviation_total;
  double length_stddev;
};

struct _OI_TrackInfo {
  OI_Stats pages;
  OI_Stats packets;
  const char * codec_name;
  char * codec_info;
  int has_fishead;
  int has_fisbone;
  fishead_packet fhInfo;
  fisbone_packet fbInfo;
};

static int show_length = 0;
static int show_bitrate = 0;
static int show_page_stats = 0;
static int show_packet_stats = 0;
static int show_extra_skeleton_info = 0;

static ogg_int64_t
gp_to_granule (OGGZ * oggz, long serialno, ogg_int64_t granulepos)
{
  int granuleshift;
  ogg_int64_t iframe, pframe, granule;

  granuleshift = oggz_get_granuleshift (oggz, serialno);

  iframe = granulepos >> granuleshift;
  pframe = granulepos - (iframe << granuleshift);
  granule = iframe + pframe;

  if (oggz_stream_get_content (oggz, serialno) == OGGZ_CONTENT_DIRAC)
    granule >>= 9;

  return granule;
}

static double
gp_to_time (OGGZ * oggz, long serialno, ogg_int64_t granulepos)
{
  ogg_int64_t gr_n, gr_d;
  ogg_int64_t granule;

  if (granulepos == -1) return -1.0;
  if (oggz_get_granulerate (oggz, serialno, &gr_n, &gr_d) != 0) return -1.0;

  granule = gp_to_granule (oggz, serialno, granulepos);

  return (double)((double)(granule * gr_d) / (double)gr_n);
}

static int
oggz_info_apply (OI_TrackFunc func, OI_Info * info)
{
  OI_TrackInfo * oit;
  long serialno;
  int n, i;

  n = oggz_table_size (info->tracks);
  for (i = 0; i < n; i++) {
    oit = oggz_table_nth (info->tracks, i, &serialno);
    if (oit) {
      if (func (info, oit, serialno) == OIT_OOM)
        exit_out_of_memory();
    }
  }

  return 0;
}

static void
oi_stats_clear (OI_Stats * stats)
{
  stats->count = 0;

  stats->length_total = 0;
  stats->length_min = LONG_MAX;
  stats->length_max = 0;
  stats->overhead_length_total = 0;

  stats->length_avg = 0;
  stats->length_deviation_total = 0;
  stats->length_stddev = 0;
}

static OI_TrackInfo *
oggz_info_trackinfo_new (void)
{
  OI_TrackInfo * oit;

  oit = malloc (sizeof (OI_TrackInfo));
  if (oit == NULL) return NULL;

  oi_stats_clear (&oit->pages);
  oi_stats_clear (&oit->packets);

  oit->codec_name = NULL;
  oit->codec_info = NULL;

  oit->has_fishead = 0;
  oit->has_fisbone = 0;

  return oit;
}

static long
oi_bitrate (long bytes, ogg_int64_t ms)
{
  if (ms == 0) return 0;
  else return (long) (((ogg_int64_t)bytes * 8 * 1000) / ms);
}

static void
oi_stats_print (OI_Info * info, OI_Stats * stats, char * label)
{
  printf ("\t%s-Length-Maximum: ", label);
  ot_fprint_bytes (stdout, stats->length_max);
  putchar ('\n');

  printf ("\t%s-Length-StdDev: ", label);
  ot_fprint_bytes (stdout, stats->length_stddev);
  putchar ('\n');

#if 0
  printf ("\t%s-Length-Maximum: %ld bytes\n", label, stats->length_max);
  /*printf ("\t%s-Length-Average: %ld bytes\n", label, stats->length_avg);*/
  printf ("\t%s-Length-StdDev: %.0f bytes\n", label, stats->length_stddev);
  /*
  printf ("\tRange: [%ld - %ld] bytes, Std.Dev. %.3f bytes\n",
	  stats->length_min, stats->length_max, stats->length_stddev);
  */
#endif
}

static void
ot_fishead_print(OI_TrackInfo *oit) {
  if (oit->has_fishead) {
    /*
    printf("\tPresentation Time: %.2f\n", (double)oit->fhInfo.ptime_n/oit->fhInfo.ptime_d);
    printf("\tBase Time: %.2f\n", (double)oit->fhInfo.btime_n/oit->fhInfo.btime_d);
    */
    printf("\tSkeleton version: %d.%d\n", oit->fhInfo.version_major, oit->fhInfo.version_minor);
    /*printf("\tUTC: %s\n", oit->fhInfo.UTC);*/
  }
}

static int
ot_fisbone_print(OI_Info * info, OI_TrackInfo *oit) {

  char *allocated, *messages, *token;
  size_t len;
  
  if (oit->has_fisbone) {
    printf("\n\tExtra information from Ogg Skeleton track:\n");
    /*printf("\tserialno: %010u\n", oit->fbInfo.serial_no);*/
    printf("\tNumber of header packets: %d\n", oit->fbInfo.nr_header_packet);
    printf("\tGranule rate: %.2f\n", (double)oit->fbInfo.granule_rate_n/oit->fbInfo.granule_rate_d);
    printf("\tGranule shift: %d\n", (int)oit->fbInfo.granule_shift);
    printf("\tStart granule: ");
    ot_fprint_granulepos(stdout, info->oggz, oit->fbInfo.serial_no, oit->fbInfo.start_granule);
    printf (" ; ");
    ot_fprint_time (stdout, gp_to_time (info->oggz, oit->fbInfo.serial_no, oit->fbInfo.start_granule));
    printf ("\n");
    printf("\tPreroll: %d\n", oit->fbInfo.preroll);

    len = oit->fbInfo.current_header_size+1;
    allocated = messages = _ogg_calloc(len, sizeof(char));
    if (messages == NULL) return OIT_OOM;
    strncpy(messages, oit->fbInfo.message_header_fields, len);
    messages[len-1] = '\0';

    printf("\tMessage Header Fields:\n");
    while (1) {
      token = strchr(messages, '\r');
      if (token == NULL)
        break;
      *token = '\0';
      printf("\t %s", token);

      token++;
      if (*token == '\n')
        token++;
      messages = token;
    }
    printf("\n");
    _ogg_free(allocated);
  }

  return 0;
}

/* oggz_info_trackinfo_print() */
static int
oit_print (OI_Info * info, OI_TrackInfo * oit, long serialno)
{
  if (oit->codec_name) {
    printf ("\n%s: serialno %010lu\n", oit->codec_name, serialno);
  } else {
    printf ("\n???: serialno %010lu\n", serialno);
  }
  printf ("\t%ld packets in %ld pages, %.1f packets/page, %.3f%% Ogg overhead\n",
	  oit->packets.count, oit->pages.count,
	  (double)oit->packets.count / (double)oit->pages.count,
          oit->pages.length_stddev == 0 ? 0.0 : 100.0*oit->pages.overhead_length_total/oit->pages.length_total);

  if (show_length) {
    fputs("\tContent-Length: ", stdout);
    ot_fprint_bytes (stdout, oit->pages.length_total);
    putchar ('\n');
  }

  if (show_bitrate) {
    fputs ("\tContent-Bitrate-Average: ", stdout);
    ot_print_bitrate (oi_bitrate (oit->pages.length_total, info->duration));
    putchar ('\n');
  }

  if (oit->codec_info != NULL) {
    fputs (oit->codec_info, stdout);
  }

  if (show_page_stats) {
    oi_stats_print (info, &oit->pages, "Page");
  }

  if (show_packet_stats) {
    oi_stats_print (info, &oit->packets, "Packet");
  }

  if (show_extra_skeleton_info && oit->has_fishead) {
    ot_fishead_print(oit);
  }
  if (show_extra_skeleton_info && oit->has_fisbone) {
    if (ot_fisbone_print(info, oit) == OIT_OOM)
      return OIT_OOM;
  }

  return 0;
 }

static void
oi_stats_average (OI_Stats * stats)
{
  if (stats->count > 0) {
    stats->length_avg = stats->length_total / stats->count;
  } else {
    stats->length_avg = 0;
  }
}

static int
oit_calc_average (OI_Info * info, OI_TrackInfo * oit, long serialno)
{
  oi_stats_average (&oit->pages);
  oi_stats_average (&oit->packets);
  return 0;
}

static void
oi_stats_stddev (OI_Stats * stats)
{
  double variance;

  if (stats->count <= 1) {
    stats->length_stddev = 0.0;
  }
  else {
    variance = (double)stats->length_deviation_total / (double)(stats->count - 1);
    stats->length_stddev = sqrt (variance);
  }
}

static int
oit_calc_stddev (OI_Info * info, OI_TrackInfo * oit, long serialno)
{
  oi_stats_stddev (&oit->pages);
  oi_stats_stddev (&oit->packets);
  return 0;
}

static int
read_page_pass1 (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OI_Info * info = (OI_Info *)user_data;
  OI_TrackInfo * oit;
  long bytes;

  oit = oggz_table_lookup (info->tracks, serialno);
  if (oit == NULL) {
    oit = oggz_info_trackinfo_new ();
    if (oit == NULL) return -1;
    oggz_table_insert (info->tracks, serialno, oit);
  }

  if (ogg_page_bos ((ogg_page *)og)) {
    oit->codec_name = ot_page_identify (oggz, og, &oit->codec_info);
  }

  bytes = og->header_len + og->body_len;

  /* Increment the total stream length */
  info->length_total += bytes;
  info->overhead_length_total += og->header_len;

  /* Increment the page statistics */
  oit->pages.count++;
  oit->pages.length_total += bytes;
  if (bytes < oit->pages.length_min)
    oit->pages.length_min = bytes;
  if (bytes > oit->pages.length_max)
    oit->pages.length_max = bytes;
  oit->pages.overhead_length_total += og->header_len;

  return 0;
}

static int
read_page_pass2 (OGGZ * oggz, const ogg_page * og, long serialno, void * user_data)
{
  OI_Info * info = (OI_Info *)user_data;
  OI_TrackInfo * oit;
  long bytes, deviation;

  oit = oggz_table_lookup (info->tracks, serialno);

  /* Increment the page length deviation squared total */
  bytes = og->header_len + og->body_len;
  deviation = bytes - oit->pages.length_avg;
  oit->pages.length_deviation_total += (deviation * deviation);

  return 0;
}

static int
read_packet_pass1 (OGGZ * oggz, oggz_packet * zp, long serialno,
		   void * user_data)
{
  OI_Info * info = (OI_Info *)user_data;
  ogg_packet * op = &zp->op;
  OI_TrackInfo * oit;

  oit = oggz_table_lookup (info->tracks, serialno);

  /* Increment the packet statistics */
  oit->packets.count++;
  oit->packets.length_total += op->bytes;
  if (op->bytes < oit->packets.length_min)
    oit->packets.length_min = op->bytes;
  if (op->bytes > oit->packets.length_max)
    oit->packets.length_max = op->bytes;

  if (!op->e_o_s && !memcmp(op->packet, FISBONE_IDENTIFIER, 8)) {
    fisbone_packet fp;
    int ret = fisbone_from_ogg(op, &fp);
    if (ret<0) return ret;
    oit = oggz_table_lookup (info->tracks, fp.serial_no);
    if (oit) {
      oit->has_fisbone = 1;
      oit->fbInfo = fp;
    }
    else {
      fprintf(stderr, "Warning: logical stream %08x referenced by skeleton was not found\n",fp.serial_no);
      fisbone_clear(&fp);
    }
  } else if (!op->e_o_s && !memcmp(op->packet, FISHEAD_IDENTIFIER, 8)) {
    fishead_packet fp;
    int ret = fishead_from_ogg(op, &fp);
    if (ret<0) return ret;
    oit->has_fishead = 1;
    oit->fhInfo = fp;    
  }

  return 0;
}

static int
read_packet_pass2 (OGGZ * oggz, oggz_packet * zp, long serialno,
		   void * user_data)
{
  OI_Info * info = (OI_Info *)user_data;
  ogg_packet * op = &zp->op;
  OI_TrackInfo * oit;
  long deviation;
  
  oit = oggz_table_lookup (info->tracks, serialno);

  /* Increment the packet length deviation squared total */
  deviation = op->bytes - oit->packets.length_avg;
  oit->packets.length_deviation_total += (deviation * deviation);

  return 0;
}

static int
oi_pass1 (OGGZ * oggz, OI_Info * info)
{
  long n, serialno;
  int ntracks, i;
  OI_TrackInfo * oit;

  oggz_seek (oggz, 0, SEEK_SET);
  oggz_set_read_page (oggz, -1, read_page_pass1, info);
  oggz_set_read_callback (oggz, -1, read_packet_pass1, info);

  while ((n = oggz_read (oggz, READ_BLOCKSIZE)) > 0);

  /* We only return an error from our user callback on OOM */
  if (n == OGGZ_ERR_STOP_ERR || n == OGGZ_ERR_OUT_OF_MEMORY)
    exit_out_of_memory ();

  oggz_info_apply (oit_calc_average, info);

  /* Now we are at the end of the file, calculate the duration */
  info->duration = oggz_tell_units (oggz);

  /* Find the Skeleton track if present, and subtract the presentation time */
  ntracks = oggz_table_size (info->tracks);
  for (i = 0; i < ntracks; i++) {
    oit = oggz_table_nth (info->tracks, i, &serialno);
    if (oit->has_fishead) {
      info->duration -= 1000 * oit->fhInfo.ptime_n / oit->fhInfo.ptime_d;
      break;
    }
  }

  return 0;
}

static int
oi_pass2 (OGGZ * oggz, OI_Info * info)
{
  long n;

  oggz_seek (oggz, 0, SEEK_SET);
  oggz_set_read_page (oggz, -1, read_page_pass2, info);
  oggz_set_read_callback (oggz, -1, read_packet_pass2, info);

  while ((n = oggz_read (oggz, READ_BLOCKSIZE)) > 0);
  if (n == OGGZ_ERR_OUT_OF_MEMORY)
    exit_out_of_memory();

  oggz_info_apply (oit_calc_stddev, info);

  return 0;
}

static int
oit_delete (OI_Info * info, OI_TrackInfo * oit, long serialno)
{
  if (oit->codec_info) {
    if (oit->has_fisbone)
      fisbone_clear (&oit->fbInfo);
    free (oit->codec_info);
  }
  free (oit);

  return 0;
}

int
main (int argc, char ** argv)
{
  int show_version = 0;
  int show_help = 0;

  int i;
  int show_all = 0;

  int many_files = 0;
  char * infilename;
  OGGZ * oggz;
  OI_Info info;

  char * optstring = "hvlbgpka";

#ifdef HAVE_GETOPT_LONG
  static struct option long_options[] = {
    {"help", no_argument, 0, 'h'},
    {"version", no_argument, 0, 'v'},
    {"length", no_argument, 0, 'l'},
    {"bitrate", no_argument, 0, 'b'},
    {"page-stats", no_argument, 0, 'g'},
    {"packet-stats", no_argument, 0, 'p'},
    {"skeleton", no_argument, 0, 'k'},
    {"all", no_argument, 0, 'a'},
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
    case 'l': /* length */
      show_length = 1;
      break;
    case 'b': /* bitrate */
      show_bitrate = 1;
      break;
    case 'g': /* page stats */
      show_page_stats = 1;
      break;
    case 'p': /* packet stats */
      show_packet_stats = 1;
      break;
    case 'k': /* extra skeleton info */
      show_extra_skeleton_info = 1;
      break;
    case 'a':
      show_all = 1;
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

  if (show_all) {
    show_length = 1;
    show_bitrate = 1;
    show_page_stats = 1;
    show_packet_stats = 1;
    show_extra_skeleton_info = 1;
  }

  if (argc > optind+1) {
    many_files = 1;
  }

  while (optind < argc) {
    infilename = argv[optind++];

    if ((oggz = oggz_open (infilename, OGGZ_READ|OGGZ_AUTO)) == NULL) {
      perror (infilename);
      return (1);
    }

    info.oggz = oggz;
    info.tracks = oggz_table_new ();
    info.length_total = 0;
    info.overhead_length_total = 0;
    
    oi_pass1 (oggz, &info);

    oi_pass2 (oggz, &info);
    
    /* Print summary information */
    if (many_files)
      printf ("Filename: %s\n", infilename);
    fputs ("Content-Duration: ", stdout);
    ot_fprint_time (stdout, (double)info.duration / 1000.0);
    putchar ('\n');
    
    if (show_length) {
      fputs ("Content-Length: ", stdout);
      ot_fprint_bytes (stdout, info.length_total);
      putchar ('\n');
    }
    
    if (show_bitrate) {
      fputs ("Content-Bitrate-Average: ", stdout);
      ot_print_bitrate (oi_bitrate (info.length_total, info.duration));
      putchar ('\n');
    }

    oggz_info_apply (oit_print, &info);
    
    oggz_info_apply (oit_delete, &info);
    oggz_table_delete (info.tracks);

    oggz_close (oggz);
    
    if (optind < argc) puts (SEP);
  }

 exit_ok:
  exit (0);

 exit_err:
  exit (1);
}
