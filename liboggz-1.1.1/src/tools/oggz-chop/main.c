#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oggz-chop.h"
#include "cgi.h"
#include "cmd.h"
 
int
main (int argc, char * argv[])
{
  OCState state;
  int err = 0; 

  if (cgi_test ()) {
    err = cgi_main (&state);
  } else {
    err = cmd_main (&state, argc, argv);
  }
  
  if (err) return 1;
  else return 0;
}
