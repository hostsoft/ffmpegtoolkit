#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define HTTPDATE_FMT "%3s, %02d %s %4d %02d:%02d:%02d GMT"

static char * wdays[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
static char * months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
			  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

void
httpdate_init (void)
{
  tzset();
}

int
httpdate_snprint (char * buf, int n, time_t mtime)
{
  struct tm * g;

  g = gmtime (&mtime);

  return snprintf (buf, n, HTTPDATE_FMT,
		   wdays[g->tm_wday], g->tm_mday, months[g->tm_mon],
		   g->tm_year + 1900, g->tm_hour, g->tm_min, g->tm_sec);
}

time_t
httpdate_parse (char * s, int n)
{
  struct tm d;
  char wday[3], month[3];
  int i;

  if (n < 30) return (time_t)(-1);

  memset (&d, 0, sizeof(struct tm));

  sscanf (s, HTTPDATE_FMT,
	  wday, &d.tm_mday, month, &d.tm_year,
          &d.tm_hour, &d.tm_min, &d.tm_sec);

  for (i = 0; i < 7; i++) {
    if (!strncmp (wday, wdays[i], 3)) {
      d.tm_wday = i;
      break;
    }
  }

  for (i = 0; i < 12; i++) {
    if (!strncmp (month, months[i], 3)) {
      d.tm_mon = i;
      break;
    }
  }

  d.tm_year -= 1900;

  d.tm_sec -= timezone;

  return mktime (&d);
}
