EXTRA_DIST = amrwb-any-cflags.patch amrwb-dhf-declaration.patch amrwb-includes.patch amrwb-intsizes.patch amrwb.spec

DISTCLEANFILES = 26204-b00.zip 26204-b00.doc 26204-b00_ANSI-C_source_code.zip

lib_LTLIBRARIES = \
	libamrwb.la

libamrwb_la_SOURCES = \
	dec_acelp.c \
	dec_dtx.c \
	dec_gain.c \
	dec_if.c \
	dec_lpc.c \
	dec_main.c \
	dec_rom.c \
	dec_util.c \
	enc_acelp.c \
	enc_dtx.c \
	enc_gain.c \
	enc_if.c \
	enc_lpc.c \
	enc_main.c \
	enc_rom.c \
	enc_util.c \
	if_rom.c

libamrwb_la_LDFLAGS = \
	-no-undefined -version-info 3:0:0

libamrwbdir = \
	$(includedir)/amrwb

libamrwb_HEADERS = \
	dec_acelp.h \
	dec_dtx.h \
	dec_gain.h \
	dec.h \
	dec_if.h \
	dec_lpc.h \
	dec_main.h \
	dec_util.h \
	enc_acelp.h \
	enc_dtx.h \
	enc_gain.h \
	enc.h \
	enc_if.h \
	enc_lpc.h \
	enc_main.h \
	enc_util.h \
	if_rom.h \
	typedef.h

bin_PROGRAMS = \
	amrwb-decoder \
	amrwb-encoder \
	amrwb-decoder-if2 \
	amrwb-encoder-if2

amrwb_decoder_SOURCES = \
	decoder.c

amrwb_decoder_LDADD = \
	libamrwb.la

amrwb_encoder_SOURCES = \
	encoder.c

amrwb_encoder_LDADD = \
	libamrwb.la

amrwb_decoder_if2_SOURCES = \
	decoder.c

amrwb_decoder_if2_CFLAGS = -DIF2

amrwb_decoder_if2_LDADD = \
	libamrwb.la

amrwb_encoder_if2_SOURCES = \
	encoder.c

amrwb_encoder_if2_CFLAGS = -DIF2

amrwb_encoder_if2_LDADD = \
	libamrwb.la

# NOTE: readme.txt is unpacked first and its time stamp is used as a "unpacking done" flag.
# One target prevents concurrent unpacking processes during parallel build.
$(top_srcdir)/dec_acelp.c $(top_srcdir)/dec_acelp.h $(top_srcdir)/dec_dtx.c $(top_srcdir)/dec_dtx.h $(top_srcdir)/dec_gain.c $(top_srcdir)/dec_gain.h $(top_srcdir)/dec.h $(top_srcdir)/dec_if.c $(top_srcdir)/dec_if.h $(top_srcdir)/dec_lpc.c $(top_srcdir)/dec_lpc.h $(top_srcdir)/dec_main.c $(top_srcdir)/dec_main.h $(top_srcdir)/decoder.c $(top_srcdir)/dec_rom.c $(top_srcdir)/dec_util.c $(top_srcdir)/dec_util.h $(top_srcdir)/enc_acelp.c $(top_srcdir)/enc_acelp.h $(top_srcdir)/enc_dtx.c $(top_srcdir)/enc_dtx.h $(top_srcdir)/enc_gain.c $(top_srcdir)/enc_gain.h $(top_srcdir)/enc.h $(top_srcdir)/enc_if.c $(top_srcdir)/enc_if.h $(top_srcdir)/enc_lpc.c $(top_srcdir)/enc_lpc.h $(top_srcdir)/enc_main.c $(top_srcdir)/enc_main.h $(top_srcdir)/encoder.c $(top_srcdir)/enc_rom.c $(top_srcdir)/enc_util.c $(top_srcdir)/enc_util.h $(top_srcdir)/if_rom.c $(top_srcdir)/if_rom.h $(top_srcdir)/typedef.h: $(top_srcdir)/readme.txt

$(top_srcdir)/readme.txt: $(top_builddir)/prepare_sources.sh $(top_srcdir)/amrwb-any-cflags.patch $(top_srcdir)/amrwb-dhf-declaration.patch $(top_srcdir)/amrwb-intsizes.patch
	$(MAKE) $(top_srcdir)/26204-b00_ANSI-C_source_code.zip
	$(PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL) $(top_builddir)/prepare_sources.sh $(top_srcdir)

$(top_srcdir)/26204-b00_ANSI-C_source_code.zip $(top_srcdir)/26204-b00.doc: $(top_srcdir)/26204-b00.zip
	rm -f $(top_srcdir)/26204-b00_ANSI-C_source_code.zip $(top_srcdir)/26204-b00.doc
	chmod +w $(top_srcdir)
	$(UNZIP) -d $(top_srcdir) $<
	chmod og-w $(top_srcdir)/26204-b00.doc

$(top_srcdir)/26204-b00.zip:
	cd $(top_srcdir) && $(DOWNLOADER_PROG) http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/26204-b00.zip

extraclean:
	rm -f $(distdir)/*.c $(distdir)/*.h $(distdir)/readme.txt $(distdir)/26204-b00.zip $(distdir)/26204-b00.doc $(distdir)/26204-b00_ANSI-C_source_code.zip

# WARNING: These commands use internal automake command and may fail in future version.
extradist-gzip: distdir extraclean
	tardir=$(distdir) && $(am__tar) | GZIP=$(GZIP_ENV) gzip -c >$(distdir).tar.gz
	$(am__remove_distdir)
extradist-bzip2: distdir extraclean
	tardir=$(distdir) && $(am__tar) | bzip2 -9 -c >$(distdir).tar.bz2
	$(am__remove_distdir)

extradist extradist-all: distdir extraclean
	tardir=$(distdir) && $(am__tar) | GZIP=$(GZIP_ENV) gzip -c >$(distdir).tar.gz
	tardir=$(distdir) && $(am__tar) | bzip2 -9 -c >$(distdir).tar.bz2
	$(am__remove_distdir)

ACLOCAL_AMFLAGS = -I m4
