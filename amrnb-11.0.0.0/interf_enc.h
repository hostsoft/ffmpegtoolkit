/*
 * ===================================================================
 *  TS 26.104
 *  REL-5 V5.4.0 2004-03
 *  REL-6 V6.1.0 2004-03
 *  3GPP AMR Floating-point Speech Codec
 * ===================================================================
 *
 */

/*
 * interf_enc.h
 *
 *
 * Project:
 *    AMR Floating-Point Codec
 *
 * Contains:
 *    Defines interface to AMR encoder
 *
 */

#ifndef _interf_enc_h_
#define _interf_enc_h_

/*
 * include files
 */
#include"sp_enc.h"

/*
 * Function prototypes
 */
/*
 * Encodes one frame of speech
 * Returns packed octets
 */
/* Triple the code with different defines and names */
int GP3VADxEncoder_Interface_Encode( void *st, enum Mode mode, short *speech,

#if 1 /* ifndef ETSI */
      unsigned char *serial,  /* max size 31 bytes */

#else
      short *serial, /* size 500 bytes */
#endif

      int forceSpeech, char vad2_code );   /* use speech mode */
int IF2VADxEncoder_Interface_Encode( void *st, enum Mode mode, short *speech,

#if 1 /* ifndef ETSI */
      unsigned char *serial,  /* max size 31 bytes */

#else
      short *serial, /* size 500 bytes */
#endif

      int forceSpeech, char vad2_code );   /* use speech mode */
int ETSIVADxEncoder_Interface_Encode( void *st, enum Mode mode, short *speech,

#if 0 /* ifndef ETSI */
      unsigned char *serial,  /* max size 31 bytes */

#else
      short *serial, /* size 500 bytes */
#endif

      int forceSpeech, char vad2_code );   /* use speech mode */

#ifdef VAD2
#ifdef ETSI
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        ETSIVADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 1 )
#else
#ifdef IF2
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        IF2VADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 1 )
#else
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        GP3VADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 1 )
#endif
#endif
#else
#ifdef ETSI
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        ETSIVADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 0 )
#else
#ifdef IF2
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        IF2VADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 0 )
#else
#define Encoder_Interface_Encode(st, mode, speech, serial, force_speech )\
        GP3VADxEncoder_Interface_Encode(st, mode, speech, serial, force_speech, 0 )
#endif
#endif
#endif

/*
 * Reserve and init. memory
 */
void *VADxEncoder_Interface_init( int dtx, char vad2_code );
#ifdef VAD2
#define Encoder_Interface_init( dtx ) VADxEncoder_Interface_init( dtx, 1 )
#else
#define Encoder_Interface_init( dtx ) VADxEncoder_Interface_init( dtx, 0 )
#endif

/*
 * Exit and free memory
 */
void Encoder_Interface_exit( void *state );
#endif
