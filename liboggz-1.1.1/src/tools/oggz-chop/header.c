#include "config.h"

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h> /* For off_t not found in stdio.h */
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "httpdate.h"

#define CONTENT_TYPE_OGG "Content-Type: application/ogg\n"
#define ACCEPT_TIMEURI_OGG "X-Accept-TimeURI: application/ogg\n"

int
header_last_modified (time_t mtime)
{
  char buf[30];

  httpdate_snprint (buf, 30, mtime);
  return printf ("Last-Modified: %s\n", buf);
}

int
header_not_modified (void)
{
  fprintf (stderr, "304 Not Modified\n");
  return printf ("Status: 304 Not Modified\n");
}

int
header_content_type_ogg (void)
{
  return printf (CONTENT_TYPE_OGG);
}

int
header_accept_timeuri_ogg (void)
{
  return printf (ACCEPT_TIMEURI_OGG);
}

int
header_content_length (off_t len)
{
  return printf ("Content-Length: %ld\n", (long)len);
}

int
header_end (void)
{
  putchar('\n');
  fflush (stdout);
  return 0;
}
