## Process this file with automake to produce Makefile.in

INCLUDES = -I$(top_builddir) -I$(top_builddir)/include \
           -I$(top_srcdir)/include -I$(top_srcdir)/src/tools \
           -I$(top_srcdir)/src/liboggz \
           -I$(top_srcdir)/src/tests \
           @OGG_CFLAGS@

OGGZDIR = ../../liboggz
OGGZ_LIBS = $(OGGZDIR)/liboggz.la @OGG_LIBS@

if OGGZ_CONFIG_READ
if OGGZ_CONFIG_WRITE
oggz_rw_programs = oggz-chop
endif

endif

# Programs to build
bin_PROGRAMS = $(oggz_rw_programs)
noinst_PROGRAMS = httpdate_test

TESTS_ENVIRONMENT = $(VALGRIND_ENVIRONMENT)

TESTS = httpdate_test

noinst_HEADERS = cgi.h cmd.h header.h httpdate.h oggz-chop.h timespec.h

oggz_chop_SOURCES = oggz-chop.c $(srcdir)/../oggz_tools.c $(srcdir)/../skeleton.c $(srcdir)/../mimetypes.c \
                    $(srcdir)/../../liboggz/dirac.c cmd.c cgi.c header.c httpdate.c main.c timespec.c
oggz_chop_LDADD = $(OGGZ_LIBS) -lm

httpdate_test_SOURCES = httpdate.c httpdate_test.c

