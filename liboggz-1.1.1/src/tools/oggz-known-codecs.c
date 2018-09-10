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

/* #define DEBUG */

typedef int (*qsort_func) (const void * p1, const void * p2);

int
usage (char * progname)
{
  printf ("Usage: oggz-known-codecs [options]\n\n");

  printf ("List codecs known by this version of oggz\n");

  printf ("\nMiscellaneous options\n");
  printf ("  -h, --help             Display this help and exit\n");
  printf ("  -v, --version          Output version information and exit\n");
  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");

  return 0;
}

static int
cmpstringp (char * const * p1, char * const * p2)
{
   /* The actual arguments to this function are "pointers to
      pointers to char", but strcmp(3) arguments are "pointers
      to char", hence the function cast plus dereference */

   if (!(*p1)) return -1;
   if (!(*p2)) return 1;

   return strcmp (*p1, *p2);
}

int
main (int argc, char ** argv)
{
  OggzStreamContent content;
  const char * content_types[OGGZ_CONTENT_UNKNOWN];

  char * progname = argv[0];

  if (argc == 2) {
    if (!strncmp (argv[1], "-?", 2)) {
      printf ("-v --version -h --help\n");
      exit (0);
    } else if (!strncmp (argv[1], "-v", 2) || !strncmp (argv[1], "--version", 9)) {
      printf ("%s version " VERSION "\n", progname);
      exit (0);
    } else if (!strncmp (argv[1], "-h", 2) || !strncmp (argv[1], "--help", 6)) {
      usage (progname);
      exit (0);
    } else {
      usage (progname);
      exit (1);
    }
  } else if (argc > 2) {
    usage (progname);
    exit (1);
  }
  
  /* Collect the content type names, filtering out deprecated and
     duplicates ones */
  for (content = 0; content < OGGZ_CONTENT_UNKNOWN; content++) {
    switch (content) {
      case OGGZ_CONTENT_FLAC0:
      case OGGZ_CONTENT_ANXDATA:
        content_types[content] = NULL;
        break;
      default:
        content_types[content] = oggz_content_type (content);
        break;
    }
  }

  /* Sort them */
  qsort (content_types, OGGZ_CONTENT_UNKNOWN, sizeof (char *),
         (qsort_func) cmpstringp);

  /* Print them */
  for (content = 0; content < OGGZ_CONTENT_UNKNOWN; content++) {
    if (content_types[content])
      puts (content_types[content]);
  }

  exit (0);
}
