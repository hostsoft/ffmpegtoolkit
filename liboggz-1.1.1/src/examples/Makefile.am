## Process this file with automake to produce Makefile.in

INCLUDES = -I$(top_builddir) -I$(top_builddir)/include \
           -I$(top_srcdir)/include \
           @OGG_CFLAGS@

OGGZDIR = ../liboggz
OGGZ_LIBS = $(OGGZDIR)/liboggz.la @OGG_LIBS@

if OGGZ_CONFIG_READ
if OGGZ_CONFIG_WRITE
oggz_rw_programs = identity rewrite-pages fix-eos modify-headers
endif
endif

if OGGZ_CONFIG_READ
oggz_read_programs = read-file read-io dump-comments
endif

if OGGZ_CONFIG_WRITE
oggz_write_programs = write-feed write-hungry
endif

# Programs to build
noinst_PROGRAMS = $(oggz_rw_programs) $(oggz_read_programs) \
	$(oggz_write_programs)

identity_SOURCES = identity.c
identity_LDADD = $(OGGZ_LIBS)

modify_headers_SOURCES = modify-headers.c
modify_headers_LDADD = $(OGGZ_LIBS)

rewrite_pages_SOURCES = rewrite-pages.c
rewrite_pages_LDADD = $(OGGZ_LIBS)

fix_eos_SOURCES = fix-eos.c
fix_eos_LDADD = $(OGGZ_LIBS)

read_file_SOURCES = read-file.c
read_file_LDADD = $(OGGZ_LIBS)

read_io_SOURCES = read-io.c
read_io_LDADD = $(OGGZ_LIBS)

dump_comments_SOURCES = dump-comments.c
dump_comments_LDADD = $(OGGZ_LIBS)

write_feed_SOURCES = write-feed.c
write_feed_LDADD = $(OGGZ_LIBS)

write_hungry_SOURCES = write-hungry.c
write_hungry_LDADD = $(OGGZ_LIBS)
