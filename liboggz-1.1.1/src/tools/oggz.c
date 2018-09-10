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
#include <unistd.h>

/* #define DEBUG */

#define TOOLNAME_LEN 32

int
usage (char * progname)
{
  printf ("Usage: oggz <subcommand> [options] filename ...\n\n");

  printf ("oggz is a commandline tool for manipulating Ogg files. It supports\n"
          "multiplexed files conformant with RFC3533. Oggz can parse headers for\n"
          "CELT, CMML, FLAC, Kate, PCM, Speex, Theora and Vorbis, and can read and write\n"
          "Ogg Skeleton logical bitstreams.\n");

  printf ("\nCommands:\n");
  printf ("  help          Display help for a specific subcommand (eg. \"oggz help chop\")\n");

  printf ("\nReporting:\n");
  printf ("  codecs        Display the list of codecs found in one or more files and\n"
          "                their bitstreams.\n");
  printf ("  diff          Hexdump the packets of two Ogg files and output differences.\n");
  printf ("  dump          Hexdump packets of an Ogg file, or revert an Ogg file from\n"
          "                such a hexdump.\n");
  printf ("  info          Display information about one or more Ogg files and their\n"
          "                bitstreams.\n");
  printf ("  scan          Scan an Ogg file and output characteristic landmarks.\n");
  printf ("  validate      Validate the Ogg framing of one or more files.\n");


  printf ("\nExtraction:\n");
  printf ("  rip           Extract one or more logical bitstreams from an Ogg file.\n");

  printf ("\nEditing:\n");
  printf ("  chop          Extract the part of an Ogg file between given start and/or\n"
          "                end times.\n");
  printf ("  comment       List or edit comments in an Ogg file.\n");
  printf ("  merge         Merge Ogg files together, interleaving pages in order of\n"
          "                presentation time.\n");
  printf ("  sort          Sort the pages of an Ogg file in order of presentation time.\n");

  printf ("\nMiscellaneous:\n");
  printf ("  known-codecs  List codecs known by this version of oggz\n");

  printf ("\n");
  printf ("Please report bugs to <ogg-dev@xiph.org>\n");

  return 0;
}

int
main (int argc, char ** argv)
{
  char * progname = argv[0];
  char toolname[TOOLNAME_LEN];
  int ret;

  if (argc < 2) {
     usage (progname);
  } else {
    if (!strncmp (argv[1], "-v", 2) || !strncmp(argv[1], "version", 7) || !strncmp(argv[1], "--version", 9)) {
      printf ("oggz version " VERSION "\n");
    } else if (!strncmp(argv[1], "-h", 2) || !strncmp (argv[1], "help", 4) || !strncmp(argv[1], "--help", 6)) {
      if (argc == 2) {
        usage (progname);
      } else {
        sprintf (toolname, "oggz-%s", argv[2]);

        /* Try running "man toolname" */
        argv[1] = "man";
        argv[2] = toolname;
        ret = execvp ("man", &argv[1]);

        /* If that fails (ie. "man" is not installed), try running "toolname --help" */
        argv[1] = toolname;
        argv[2] = "--help";
        ret = execvp (toolname, &argv[1]);

        if (ret == -1) {
          perror (toolname);
        }
      }
    } else {
      sprintf (toolname, "oggz-%s", argv[1]);
      argv[1] = toolname;
      ret = execvp (toolname, &argv[1]);

      if (ret == -1) {
        perror (toolname);
      }
    }
  }

  exit (0);
}
