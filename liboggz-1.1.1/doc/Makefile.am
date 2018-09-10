docdir=$(prefix)/share/doc/@PACKAGE@

man_MANS = oggz.1 oggz-diff.1 oggz-dump.1 oggz-info.1 oggz-known-codecs.1 oggz-merge.1 oggz-chop.1 \
	oggz-sort.1 oggz-rip.1 oggz-comment.1 oggz-scan.1 oggz-validate.1 oggz-codecs.1

EXTRA_DIST = $(man_MANS) Doxyfile.in \
	forcefeed.fig forcefeed.eps forcefeed.png \
	hungry.fig hungry.eps hungry.png

# ensure doxygen-build.stamp is included,  or else the documentation will
# not be built or distributed
noinst_DATA = doxygen-build.stamp

html: oggz.1.html oggz-diff.1.html oggz-dump.1.html oggz-info.1.html oggz-known-codecs.1.html \
	oggz-merge.1.html oggz-chop.1.html oggz-sort.1.html oggz-rip.1.html oggz-comment.1.html \
	oggz-scan.1.html oggz-validate.1.html oggz-codecs.1.html oggz-codecs.1.html

if HAVE_MAN2HTML
%.1.html: %.1
	man2html $< > $@
endif

if HAVE_DOXYGEN
doxygen-build.stamp: Doxyfile $(top_srcdir)/include/oggz/*.h $(top_srcdir)/src/examples/*.c
	doxygen
	touch doxygen-build.stamp
else
doxygen-build.stamp:
	echo "*** Warning: Doxygen not found; documentation will not be built."
	touch doxygen-build.stamp
endif

dist_docdir = $(distdir)/liboggz

dist-hook:
	if test -d liboggz; then \
	  mkdir $(dist_docdir); \
	  for dir in liboggz/*; do \
            b=`basename $$dir`; \
            if test $$b != "CVS"; then \
              if test -d $$dir; then \
                mkdir $(dist_docdir)/$$b; \
	        for f in $$dir/*; do \
                  cp -p $$f $(dist_docdir)/$$b; \
                done \
              fi \
            fi \
          done \
	fi


install-data-local: doxygen-build.stamp
	$(mkinstalldirs) $(DESTDIR)$(docdir)
	if test -d liboggz; then \
	  for dir in liboggz/*; do \
	    if test -d $$dir; then \
	      b=`basename $$dir`; \
	      $(mkinstalldirs) $(DESTDIR)$(docdir)/$$b; \
	      for f in $$dir/*; do \
		$(INSTALL_DATA) $$f $(DESTDIR)$(docdir)/$$b; \
              done \
	    fi \
	  done \
	fi

uninstall-local:
	rm -rf $(DESTDIR)$(docdir)

clean-local:
	if test -d liboggz; then rm -rf liboggz; fi
	if test -f doxygen-build.stamp; then rm -f doxygen-build.stamp; fi
