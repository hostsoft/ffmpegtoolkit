## Process this file with automake to produce Makefile.in

INCLUDES = $(INCLTDL) \
           -I$(top_builddir) -I$(top_builddir)/include \
           -I$(top_srcdir)/include \
           -I$(top_srcdir)/src/liboggz \
           @OGG_CFLAGS@

EXTRA_DIST = Version_script.in

# Libraries to build
lib_LTLIBRARIES = liboggz.la

liboggz_la_SOURCES = \
	oggz.c \
	oggz_private.h oggz_byteorder.h oggz_compat.h oggz_macros.h \
	oggz_comments.c \
	oggz_io.c \
	oggz_read.c oggz_write.c \
	oggz_seek.c \
	oggz_auto.c oggz_auto.h \
	oggz_stream.c oggz_stream_private.h \
	oggz_table.c \
	oggz_vector.c oggz_vector.h \
	oggz_dlist.c oggz_dlist.h \
	metric_internal.c \
	dirac.c dirac.h

liboggz_la_LDFLAGS = -version-info @SHARED_VERSION_INFO@ @SHLIB_VERSION_ARG@
liboggz_la_LIBADD = @OGG_LIBS@
