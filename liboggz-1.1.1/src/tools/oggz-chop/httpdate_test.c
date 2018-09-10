#include "config.h"

#include <stdio.h>
#include <string.h>

#include "oggz_tests.h"

#include "httpdate.h"

int
main (int argc, char * argv[])
{
  char * d_in = "Mon, 06 Feb 2006 11:20:01 GMT";
  char d_out[30];
  time_t t;

  INFO ("Parsing date:");
  INFO (d_in);
  t = httpdate_parse (d_in, 30);

  if (t == (time_t)-1) {
    FAIL ("Parse error");
  } else {
    t -= timezone;
    httpdate_snprint (d_out, 30, t);

    INFO ("Output date:");
    INFO (d_out);

    if (strcmp (d_in, d_out)) {
      FAIL ("Mismatched dates");
    }
  }

  return 0;
}
