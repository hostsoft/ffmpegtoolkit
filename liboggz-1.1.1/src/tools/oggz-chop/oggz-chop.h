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

#ifndef __OGGZ_CHOP_H__
#define __OGGZ_CHOP_H__

#include <oggz/oggz.h>

#include "skeleton.h"

/************************************************************
 * OCState
 */

typedef enum {
  OC_INIT = 0, /* Done nothing yet */
  OC_GLUING,  /* Done Skeleton BOS, copying media headers */
  OC_GLUE_DONE /* Written accum pages, copy remaining data to end */
} OCStatus;

typedef struct _OCState {
  OCStatus status;

  char * infilename;
  char * outfilename;

  fishead_packet fishead;
  OggzTable * tracks;

  FILE * outfile;
  int do_skeleton; /* Boolean: should output contain skeleton? */
  OGGZ * skeleton_writer;
  long skeleton_serialno;

  double start;
  double end;

  int original_had_skeleton;

  /* Commandline options */
  int dry_run;
  int verbose;
} OCState;


int chop (OCState * state);

#endif /* __OGGZ_CHOP_H__ */
