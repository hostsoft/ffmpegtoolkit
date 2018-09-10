EXTRA_DIST = amrnb-any-cflags.patch amrnb-intsizes.patch amrnb-strict-aliasing.patch amrnb.spec

DISTCLEANFILES = 26104-b00.zip 26104-b00.doc 26104-b00_ANSI_C_source_code.zip

lib_LTLIBRARIES = \
	libamrnb.la

libamrnb_la_SOURCES = \
	interf_dec.c \
	interf_enc.c \
	sp_dec.c \
	sp_enc.c

libamrnb_la_LDFLAGS = \
	-no-undefined -version-info 3:0:0

libamrnbdir = \
	$(includedir)/amrnb

libamrnb_HEADERS = \
	interf_dec.h \
	interf_enc.h \
	interf_rom.h \
	rom_dec.h \
	rom_enc.h \
	sp_dec.h \
	sp_enc.h \
	typedef.h

bin_PROGRAMS = \
	amrnb-decoder \
	amrnb-encoder \
	amrnb-decoder-if2 \
	amrnb-encoder-if2 \
	amrnb-decoder-etsi \
	amrnb-encoder-etsi \
	amrnb-decoder \
	amrnb-encoder-vad2 \
	amrnb-encoder-if2-vad2 \
	amrnb-encoder-etsi-vad2

amrnb_decoder_SOURCES = \
	decoder.c

amrnb_decoder_LDADD = \
	libamrnb.la

amrnb_encoder_SOURCES = \
	encoder.c

amrnb_encoder_LDADD = \
	libamrnb.la

amrnb_decoder_if2_SOURCES = \
	decoder.c

amrnb_decoder_if2_CFLAGS = -DIF2

amrnb_decoder_if2_LDADD = \
	libamrnb.la

amrnb_encoder_if2_SOURCES = \
	encoder.c

amrnb_encoder_if2_CFLAGS = -DIF2

amrnb_encoder_if2_LDADD = \
	libamrnb.la

amrnb_decoder_etsi_SOURCES = \
	decoder.c

amrnb_decoder_etsi_CFLAGS = -DETSI

amrnb_decoder_etsi_LDADD = \
	libamrnb.la

amrnb_encoder_etsi_SOURCES = \
	encoder.c

amrnb_encoder_etsi_CFLAGS = -DETSI

amrnb_encoder_etsi_LDADD = \
	libamrnb.la

amrnb_encoder_vad2_SOURCES = \
	encoder.c

amrnb_encoder_vad2_CFLAGS = -DVAD2

amrnb_encoder_vad2_LDADD = \
	libamrnb.la

amrnb_encoder_if2_vad2_SOURCES = \
	encoder.c

amrnb_encoder_if2_vad2_CFLAGS = -DIF2 -DVAD2

amrnb_encoder_if2_vad2_LDADD = \
	libamrnb.la

amrnb_encoder_etsi_vad2_SOURCES = \
	encoder.c

amrnb_encoder_etsi_vad2_CFLAGS = -DETSI -DVAD2

amrnb_encoder_etsi_vad2_LDADD = \
	libamrnb.la

# NOTE: readme.txt is unpacked first and its time stamp is used as a "unpacking done" flag.
# One target prevents concurrent unpacking processes during parallel build.
$(top_srcdir)/decoder.c $(top_srcdir)/encoder.c $(top_srcdir)/interf_dec.c $(top_srcdir)/interf_dec.h $(top_srcdir)/interf_enc.c $(top_srcdir)/interf_enc.h $(top_srcdir)/interf_rom.h $(top_srcdir)/rom_dec.h $(top_srcdir)/rom_enc.h $(top_srcdir)/sp_dec.c $(top_srcdir)/sp_dec.h $(top_srcdir)/sp_enc.c $(top_srcdir)/sp_enc.h $(top_srcdir)/typedef.h: $(top_srcdir)/readme.txt

$(top_srcdir)/readme.txt: $(top_builddir)/prepare_sources.sh $(top_srcdir)/amrnb-any-cflags.patch $(top_srcdir)/amrnb-intsizes.patch $(top_srcdir)/amrnb-strict-aliasing.patch
	$(MAKE) $(top_srcdir)/26104-b00_ANSI_C_source_code.zip
	$(PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL) $(top_builddir)/prepare_sources.sh $(top_srcdir)

$(top_srcdir)/26104-b00_ANSI_C_source_code.zip $(top_srcdir)/26104-b00.doc: $(top_srcdir)/26104-b00.zip
	rm -f $(top_srcdir)/26104-b00_ANSI_C_source_code.zip $(top_srcdir)/26104-b00.doc
	chmod +w $(top_srcdir)
	$(UNZIP) -d $(top_srcdir) $<
	chmod og-w $(top_srcdir)/26104-b00.doc

$(top_srcdir)/26104-b00.zip:
	cd $(top_srcdir) && $(DOWNLOADER_PROG) http://www.3gpp.org/ftp/Specs/archive/26_series/26.104/26104-b00.zip

extraclean:
	rm -f $(distdir)/*.c $(distdir)/*.h $(distdir)/readme.txt $(distdir)/26104-b00.zip $(distdir)/26104-b00.doc $(distdir)/26104-b00_ANSI_C_source_code.zip

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
