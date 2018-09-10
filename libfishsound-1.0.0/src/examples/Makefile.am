## Process this file with automake to produce Makefile.in

AM_CFLAGS = -Wall -pedantic -g

INCLUDES = -I$(top_builddir) \
           -I$(top_srcdir)/include -I$(top_srcdir)/src/libfishsound \
           $(SNDFILE_CFLAGS) $(VORBIS_CFLAGS) $(SPEEX_CFLAGS) $(FLAC_CFLAGS) $(OGGZ_CFLAGS)

FISHSOUNDDIR = ../libfishsound
FISHSOUND_LIBS = $(FISHSOUNDDIR)/libfishsound.la \
                 $(VORBIS_LIBS) $(SPEEX_LIBS) $(FLAC_LIBS)

if HAVE_OGGZ
oggz_examples = fishsound-identify fishsound-info fishsound-decenc
endif

if HAVE_LIBSNDFILE1
sndfile_examples = fishsound-encdec
endif

if HAVE_OGGZ
if HAVE_LIBSNDFILE1
oggz_sndfile_examples = fishsound-decode fishsound-encode
endif
endif

# Programs to build
noinst_PROGRAMS = $(oggz_examples) $(sndfile_examples) $(oggz_sndfile_examples)
#bin_PROGRAMS = $(oggz_examples) $(sndfile_examples) $(oggz_sndfile_examples)

fishsound_identify_SOURCES = fishsound-identify.c
fishsound_identify_LDADD = $(FISHSOUND_LIBS) $(OGGZ_LIBS)

fishsound_info_SOURCES = fishsound-info.c
fishsound_info_LDADD = $(FISHSOUND_LIBS) $(OGGZ_LIBS)

fishsound_decode_SOURCES = fishsound-decode.c
fishsound_decode_LDADD = $(FISHSOUND_LIBS) $(OGGZ_LIBS) $(SNDFILE_LIBS)

fishsound_encode_SOURCES = fishsound-encode.c
fishsound_encode_LDADD = $(FISHSOUND_LIBS) $(OGGZ_LIBS) $(SNDFILE_LIBS)

fishsound_decenc_SOURCES = fishsound-decenc.c
fishsound_decenc_LDADD = $(FISHSOUND_LIBS) $(OGGZ_LIBS)

fishsound_encdec_SOURCES = fishsound-encdec.c
fishsound_encdec_LDADD = $(FISHSOUND_LIBS) $(SNDFILE_LIBS)
