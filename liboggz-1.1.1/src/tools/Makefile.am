## Process this file with automake to produce Makefile.in

SUBDIRS = oggz-chop

EXTRA_DIST = oggz-diff

bin_SCRIPTS = oggz-diff

INCLUDES = -I$(top_builddir) -I$(top_builddir)/include \
           -I$(top_srcdir)/include \
           -I$(top_srcdir)/src/liboggz \
           @OGG_CFLAGS@

OGGZDIR = ../liboggz
OGGZ_LIBS = $(OGGZDIR)/liboggz.la @OGG_LIBS@

COMMON_SRCS=oggz_tools.c $(srcdir)/../liboggz/dirac.c

oggz_any_programs = oggz oggz-known-codecs

if OGGZ_CONFIG_READ
oggz_read_programs = oggz-dump oggz-info oggz-scan oggz-codecs
oggz_read_noinst_programs =

if OGGZ_CONFIG_WRITE
oggz_rw_programs = oggz-merge oggz-rip oggz-validate oggz-comment oggz-sort
oggz_rw_noinst_programs = oggz-basetime
endif

endif

noinst_HEADERS = oggz_tools.h oggz_tools_dirac.h skeleton.h mimetypes.h

# Programs to build
bin_PROGRAMS = $(oggz_any_programs) $(oggz_read_programs) $(oggz_rw_programs)
noinst_PROGRAMS = $(oggz_read_noinst_programs) $(oggz_rw_noinst_programs)

oggz_SOURCES = oggz.c
oggz_LDADD =

oggz_known_codecs_SOURCES = oggz-known-codecs.c
oggz_known_codecs_LDADD = $(OGGZ_LIBS)

oggz_info_SOURCES = oggz-info.c skeleton.c $(COMMON_SRCS)
oggz_info_LDADD = $(OGGZ_LIBS) -lm

oggz_comment_SOURCES = oggz-comment.c $(COMMON_SRCS)
oggz_comment_LDADD = $(OGGZ_LIBS)

oggz_dump_SOURCES = oggz-dump.c $(COMMON_SRCS)
oggz_dump_LDADD = $(OGGZ_LIBS)

oggz_merge_SOURCES = oggz-merge.c $(COMMON_SRCS)
oggz_merge_LDADD = $(OGGZ_LIBS)

oggz_rip_SOURCES = oggz-rip.c $(COMMON_SRCS)
oggz_rip_LDADD = $(OGGZ_LIBS)

oggz_validate_SOURCES = oggz-validate.c $(COMMON_SRCS)
oggz_validate_LDADD = $(OGGZ_LIBS)

oggz_basetime_SOURCES = oggz-basetime.c $(COMMON_SRCS)
oggz_basetime_LDADD = $(OGGZ_LIBS)

oggz_scan_SOURCES = oggz-scan.c $(COMMON_SRCS)
oggz_scan_LDADD = $(OGGZ_LIBS)

oggz_sort_SOURCES = oggz-sort.c $(COMMON_SRCS)
oggz_sort_LDADD = $(OGGZ_LIBS)

oggz_codecs_SOURCES = oggz-codecs.c mimetypes.c $(COMMON_SRCS)
oggz_codecs_LDADD = $(OGGZ_LIBS)

# Add symlinks for deprecated tool names, if they are already installed;
# see http://lists.xiph.org/pipermail/ogg-dev/2008-July/001083.html
install-exec-local:
	for p in dump diff info merge rip ; do \
	  if test -e $(exec_prefix)/bin/oggz$$p ; then \
	    $(RM) $(exec_prefix)/bin/oggz$$p ; \
	    $(LN_S) $(exec_prefix)/bin/oggz-$$p $(exec_prefix)/bin/oggz$$p ; \
	  fi ; \
	done

# On 'make uninstall', remove the deprecated tool -- but only if it is a
# symlink, to keep to the policy of only uninstalling what we installed.
# Note that the $(LN_S) above may be substitued with "cp -p" on systems that
# do not have ln, so the test below will fail. As a result, 'make uninstall'
# will fail to uninstall the copied versions of oggzdump, oggzdiff etc. on
# such systems.
uninstall-local:
	for p in dump diff info merge rip ; do \
	  if test -L $(exec_prefix)/bin/oggz$$p ; then \
	    $(RM) $(exec_prefix)/bin/oggz$$p ; \
	  fi ; \
	done
