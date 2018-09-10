docdir=$(DESTDIR)$(prefix)/share/doc/@PACKAGE@

EXTRA_DIST = Doxyfile.in white-xifish.png

# ensure doxygen-build.stamp is included,  or else the documentation will
# not be built or distributed
noinst_DATA = doxygen-build.stamp

if HAVE_DOXYGEN
doxygen-build.stamp: Doxyfile $(top_srcdir)/include/fishsound/*.h
	doxygen
	touch doxygen-build.stamp
else
doxygen-build.stamp:
	echo "*** Warning: Doxygen not found; documentation will not be built."
	touch doxygen-build.stamp
endif

dist_docdir = $(distdir)/libfishsound

dist-hook:
	if test -d libfishsound; then \
	  mkdir $(dist_docdir); \
	  for dir in libfishsound/*; do \
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
	$(mkinstalldirs) $(docdir)
	if test -d libfishsound; then \
	  for dir in libfishsound/*; do \
	    if test -d $$dir; then \
	      b=`basename $$dir`; \
	      $(mkinstalldirs) $(docdir)/$$b; \
	      for f in $$dir/*; do \
		$(INSTALL_DATA) $$f $(docdir)/$$b; \
	      done \
	    fi \
	  done \
	fi

uninstall-local:
	rm -rf $(docdir)

clean-local:
	if test -d libfishsound; then rm -rf libfishsound; fi
	if test -f doxygen-build.stamp; then rm -f doxygen-build.stamp; fi

