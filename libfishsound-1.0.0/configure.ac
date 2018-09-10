# Process this file with autoconf to produce a configure script.
AC_INIT
AC_CONFIG_SRCDIR([src/libfishsound/fishsound.c])

AC_PREREQ(2.53)

AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE(libfishsound, 1.0.0)
AM_CONFIG_HEADER(config.h)

################################################################################
# Set the shared versioning info, according to section 6.3 of the libtool info #
# pages. CURRENT:REVISION:AGE must be updated immediately before each release: #
#                                                                              #
#   * If the library source code has changed at all since the last             #
#     update, then increment REVISION (`C:R:A' becomes `C:r+1:A').             #
#                                                                              #
#   * If any interfaces have been added, removed, or changed since the         #
#     last update, increment CURRENT, and set REVISION to 0.                   #
#                                                                              #
#   * If any interfaces have been added since the last public release,         #
#     then increment AGE.                                                      #
#                                                                              #
#   * If any interfaces have been removed since the last public release,       #
#     then set AGE to 0.                                                       #
#                                                                              #
################################################################################
SHARED_VERSION_INFO="4:0:3"
SHLIB_VERSION_ARG=""

# Checks for programs.
AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LIBTOOL
AC_PROG_MAKE_SET

AC_C_CONST
AC_C_BIGENDIAN

dnl Add parameters for aclocal
AC_SUBST(ACLOCAL_AMFLAGS, "-I m4")

# Checks for header files.
AC_CHECK_HEADERS([stdint.h])
AC_CHECK_TYPES([uintptr_t])

# Check for pkg-config
AC_CHECK_PROG(HAVE_PKG_CONFIG, pkg-config, yes)

# Check for doxygen
AC_CHECK_PROG(HAVE_DOXYGEN, doxygen, true, false)
AM_CONDITIONAL(HAVE_DOXYGEN,$HAVE_DOXYGEN)
if test $HAVE_DOXYGEN = "false"; then
             AC_MSG_WARN([*** doxygen not found, docs will not be built])
fi

# Check for valgrind
VALGRIND_ENVIRONMENT=""
ac_enable_valgrind=no
AC_ARG_ENABLE(valgrind-testing,
     AC_HELP_STRING([--enable-valgrind-testing], [enable running of tests inside Valgrind]),
     [ ac_enable_valgrind=yes ], [ ac_enable_valgrind=no ])

if test "x${ac_enable_valgrind}" = xyes ; then
  if test "x${enable_shared}" = xyes ; then
    VALGRIND_ENVIRONMENT="libtool --mode=execute "
  fi

  AC_CHECK_PROG(HAVE_VALGRIND, valgrind, yes, no)
  if test "x$HAVE_VALGRIND" = xyes ; then
    VALGRIND_ENVIRONMENT="$VALGRIND_ENVIRONMENT valgrind -q --leak-check=yes --show-reachable=yes --num-callers=100"
    AC_SUBST(VALGRIND_ENVIRONMENT)
    TESTS_INFO="Type 'make check' to run test suite. Tests will be run under:
  ${VALGRIND_ENVIRONMENT}"
  else
    TESTS_INFO="Type 'make check' to run test suite (Valgrind not found)"
  fi
else
  TESTS_INFO="Type 'make check' to run test suite (Valgrind testing not enabled)"
fi

dnl Overall configuration success flag
fishsound_config_ok=yes

fishsound_examples=""

dnl Optional requirements to report via pkg-config (in fishsound.pc)
fishsound_pkgdeps=""

dnl
dnl  Configuration option for building of experimental code.
dnl
  
ac_enable_experimental=no
AC_ARG_ENABLE(experimental,
     AC_HELP_STRING([--enable-experimental], [enable building of experimental code]),
     [ ac_enable_experimental=yes ])

if test "x${ac_enable_experimental}" = xyes ; then
    AC_DEFINE(FS_EXPERIMENTAL, [], [Define to build experimental code])
fi

dnl
dnl  Configuration option for building of decoding support.
dnl
  
ac_enable_decode=yes
AC_ARG_ENABLE(decode,
     AC_HELP_STRING([--disable-decode], [disable building of decoding support]),
     [ ac_enable_decode=no ], [ ac_enable_decode=yes] )

if test "x${ac_enable_decode}" = xyes ; then
    AC_DEFINE(FS_DECODE, [1], [Build decoding support])
else
    AC_DEFINE(FS_DECODE, [0], [Do not build decoding support])
fi
AM_CONDITIONAL(FS_DECODE, [test "x${ac_enable_decode}" = "xyes"])

dnl
dnl  Configuration option for building of encoding support.
dnl
  
ac_enable_encode=yes
AC_ARG_ENABLE(encode,
     AC_HELP_STRING([--disable-encode], [disable building of encoding support]),
     [ ac_enable_encode=no ], [ ac_enable_encode=yes] )

if test "x${ac_enable_encode}" = xyes ; then
    AC_DEFINE(FS_ENCODE, [1], [Build encoding support])
else
    AC_DEFINE(FS_ENCODE, [0], [Do not build encoding support])
fi
AM_CONDITIONAL(FS_ENCODE, [test "x${ac_enable_encode}" = "xyes"])

dnl
dnl  Check decode/encode option sanity
dnl
if test "x${ac_enable_decode}" = xno && test "x${ac_enable_encode}" = xno ; then
  AC_MSG_ERROR([
***
*** You have attempted to explicitly disable both encoding and decoding.
***
*** If you want a fish that does nothing, try kfishd:
***
***   http://www.verge.net.au/~horms/junk/
***
*** or buy a dead one from your local pet store.
***
])
fi

dnl
dnl  Detect vorbis
dnl

HAVE_VORBIS=no
HAVE_VORBISENC=no
VORBIS_SUPPORT=no

ac_enable_vorbis=yes
AC_ARG_ENABLE(vorbis,
     AC_HELP_STRING([--disable-vorbis], [disable building of Vorbis codec support]),
     [ ac_enable_vorbis=no ], [ ac_enable_vorbis=yes] )

if test "x${ac_enable_vorbis}" = xyes ; then
  if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
    PKG_CHECK_MODULES(VORBIS, vorbis, HAVE_VORBIS="yes", HAVE_VORBIS="no")
  fi

  if test "x$HAVE_VORBIS" = "xno" ; then
    AC_CHECK_LIB(vorbis, vorbis_info_init, HAVE_VORBIS="maybe", , [-lm -logg])
    if test "x$HAVE_VORBIS" = xmaybe; then
      AC_CHECK_HEADER(vorbis/codec.h, HAVE_VORBIS="yes", HAVE_VORBIS="no")
    fi
    if test "x$HAVE_VORBIS" = xyes ; then
      VORBIS_LIBS="-lvorbis -logg -lm"
    fi
  fi

  if test "x$HAVE_VORBIS" = xyes ; then
    AC_DEFINE(HAVE_VORBIS, [1], [Define to 1 if you have libvorbis])
    fishsound_pkgdeps="$fishsound_pkgdeps vorbis"
  else
    AC_DEFINE(HAVE_VORBIS, [0], [Define to 1 if you have libvorbis])
  fi

  if test "x${ac_enable_encode}" = xyes ; then
    if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
      PKG_CHECK_MODULES(VORBISENC, vorbisenc, HAVE_VORBISENC="yes", HAVE_VORBISENC="no")
    fi

    if test "x$HAVE_VORBISENC" = "xno" ; then
      AC_CHECK_LIB(vorbisenc, vorbis_encode_init, HAVE_VORBISENC="maybe", ,
                   [-lm -logg -lvorbis])
      if test "x$HAVE_VORBISENC" = xmaybe ; then
        AC_CHECK_HEADER(vorbis/vorbisenc.h, HAVE_VORBISENC="yes",
                        HAVE_VORBISENC="no")
      fi
      if test "x$HAVE_VORBISENC" = xyes ; then
        VORBISENC_LIBS="-lvorbisenc"
      fi
    fi

    if test "x$HAVE_VORBISENC" = xyes ; then
      AC_DEFINE(HAVE_VORBISENC, [1], [Define to 1 if you have libvorbisenc])
      fishsound_pkgdeps="$fishsound_pkgdeps vorbisenc"
    else
      AC_DEFINE(HAVE_VORBISENC, [0], [Define to 1 if you have libvorbisenc])
    fi

  else
    AC_DEFINE(HAVE_VORBISENC, [0], [Define to 1 if you have libvorbisenc])
  fi

  if test "x$HAVE_VORBIS" = "xyes" && test "x$HAVE_VORBISENC" = "xyes" ; then
    VORBIS_LIBS="$VORBISENC_LIBS $VORBIS_LIBS"
    AC_SUBST(VORBIS_LIBS)
    VORBIS_SUPPORT="yes"
  elif test "x$HAVE_VORBIS" = xyes ; then
    AC_SUBST(VORBIS_LIBS)
    VORBIS_SUPPORT="decode only"
  fi
else
  AC_DEFINE(HAVE_VORBIS, [0], [Define to 1 if you have libvorbis])
  AC_DEFINE(HAVE_VORBISENC, [0], [Define to 1 if you have libvorbisenc])
  VORBIS_SUPPORT="disabled"
fi
AM_CONDITIONAL(HAVE_VORBIS, [test "x$HAVE_VORBIS" = "xyes"])
AM_CONDITIONAL(HAVE_VORBISENC, [test "x$HAVE_VORBISENC" = "xyes"])

dnl
dnl  Detect speex
dnl

HAVE_SPEEX=no
HAVE_SPEEX_1_1=no
SPEEX_SUPPORT=no

ac_enable_speex=yes
AC_ARG_ENABLE(speex,
     AC_HELP_STRING([--disable-speex], [disable building of Speex codec support]),
     [ ac_enable_speex=no ], [ ac_enable_speex=yes] )

if test "x${ac_enable_speex}" = xyes ; then
  if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
    PKG_CHECK_MODULES(SPEEX, speex, HAVE_SPEEX="yes", HAVE_SPEEX="no")
  fi

  if test "x$HAVE_SPEEX" = "xno" ; then
    AC_CHECK_LIB(speex, speex_encoder_init, HAVE_SPEEX="maybe", , [-lm])
    if test "x$HAVE_SPEEX" = xmaybe; then
      AC_CHECK_HEADER(speex.h, HAVE_SPEEX="yes", HAVE_SPEEX="no", [])
    fi
    if test "x$HAVE_SPEEX" = "xyes" ; then
      SPEEX_CFLAGS=""
      SPEEX_LIBS="-lspeex -lm"
    fi
  fi

  if test "x$HAVE_SPEEX" = xyes ; then

    saved_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $SPEEX_CFLAGS"

    dnl Test for libspeex 1.1.x
    AC_CHECK_LIB(speex, speex_decode_int, HAVE_SPEEX_1_1="yes",
        HAVE_SPEEX_1_1="no", [$SPEEX_LIBS])
    if test "x$HAVE_SPEEX_1_1" = xyes ; then
      AC_DEFINE(HAVE_SPEEX_1_1, [1], [Define to 1 if you have libspeex 1.1.x])
      SPEEX_SUPPORT="yes (1.1.x)"

      dnl Test for speex_lib_get_mode() in libspeex 1.1
      AC_CHECK_LIB(speex, speex_lib_get_mode, HAVE_SPEEX_LIB_GET_MODE="yes",
        HAVE_SPEEX_LIB_GET_MODE="no", [$SPEEX_LIBS])
      if test "x$HAVE_SPEEX_LIB_GET_MODE" = xyes ; then
        AC_DEFINE(HAVE_SPEEX_LIB_GET_MODE, [1],
         [Define to 1 if speex_lib_get_mode() exists in libspeex])
      else
        AC_DEFINE(HAVE_SPEEX_LIB_GET_MODE, [0],
         [Define to 1 if speex_lib_get_mode() exists in libspeex])
      fi

    else
      AC_DEFINE(HAVE_SPEEX_1_1, [0], [Define to 1 if you have libspeex 1.1.x]) 
      SPEEX_SUPPORT="yes (1.0.x)"
    fi

    CFLAGS="$saved_CFLAGS"

    AC_DEFINE(HAVE_SPEEX, [1], [Define to 1 if you have libspeex])
    AC_SUBST(SPEEX_CFLAGS)
    AC_SUBST(SPEEX_LIBS)

    fishsound_pkgdeps="$fishsound_pkgdeps speex"
  else
    AC_DEFINE(HAVE_SPEEX, [0], [Define to 1 if you have libspeex])
  fi
else
  AC_DEFINE(HAVE_SPEEX, [0], [Define to 1 if you have libspeex])
  SPEEX_SUPPORT=disabled
fi
AM_CONDITIONAL(HAVE_SPEEX, [test "x$HAVE_SPEEX" = "xyes"])

dnl
dnl  Detect flac
dnl

HAVE_FLAC=no
HAVE_FLAC_1_1_2=no
HAVE_FLAC_1_1_3=no
FLAC_SUPPORT=no

ac_enable_flac=yes
AC_ARG_ENABLE(flac,
     AC_HELP_STRING([--disable-flac], [disable building of Flac codec support]),
     [ ac_enable_flac=no ], [ ac_enable_flac=yes] )

if test "x${ac_enable_flac}" = xyes ; then
  if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
    PKG_CHECK_MODULES(FLAC, flac, HAVE_FLAC="yes", HAVE_FLAC="no")
  fi

  if test "x$HAVE_FLAC" = "xno" ; then
    AC_CHECK_LIB(FLAC, FLAC__stream_decoder_init, HAVE_FLAC="maybe", , [-lm -logg])
    if test "x$HAVE_FLAC" = xmaybe; then
      AC_CHECK_HEADER(FLAC/all.h, HAVE_FLAC="yes", HAVE_FLAC="no")
    fi
    if test "x$HAVE_FLAC" = "xyes" ; then
      FLAC_CFLAGS=""
      FLAC_LIBS="-lFLAC -logg -lm"
    fi
  fi

  if test "x$HAVE_FLAC" = xyes ; then
    saved_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $FLAC_CFLAGS"

    dnl Test for libFLAC 1.1.3
    AC_CHECK_LIB(FLAC, FLAC__stream_decoder_init_stream, HAVE_FLAC_1_1_3="yes",
        HAVE_FLAC_1_1_3="no", [$FLAC_LIBS])
    if test "x$HAVE_FLAC_1_1_3" = xyes ; then
      AC_DEFINE(HAVE_FLAC_1_1_3, [1], [Define to 1 if you have libFLAC 1.1.3])
      FLAC_SUPPORT="yes (1.1.3)"
    else
      dnl Test for libFLAC 1.1.2
      AC_CHECK_LIB(FLAC, FLAC__stream_decoder_init, HAVE_FLAC_1_1_2="yes",
          HAVE_FLAC_1_1_2="no", [$FLAC_LIBS])
      if test "x$HAVE_FLAC_1_1_2" = xyes ; then
        AC_DEFINE(HAVE_FLAC_1_1_2, [1], [Define to 1 if you have libFLAC 1.1.2])
        FLAC_SUPPORT="yes (1.1.2)"
      fi
    fi

    CFLAGS="$saved_CFLAGS"

    AC_DEFINE(HAVE_FLAC, [1], [Define to 1 if you have libFLAC])
    AC_SUBST(FLAC_CFLAGS)
    AC_SUBST(FLAC_LIBS)

    fishsound_pkgdeps="$fishsound_pkgdeps flac"
  else
    AC_DEFINE(HAVE_FLAC, [0], [Define to 1 if you have libFLAC])
  fi
else
  AC_DEFINE(HAVE_FLAC, [0], [Define to 1 if you have libFLAC])
  FLAC_SUPPORT="disabled"
fi
AM_CONDITIONAL(HAVE_FLAC, [test "x$HAVE_FLAC" = "xyes"])

dnl
dnl  Check codec disabling sanity
dnl
if test "x${ac_enable_vorbis}" = xno && test "x${ac_enable_speex}" = xno &&
test "x${ac_enable_flac}" = xno ; then
  AC_MSG_ERROR([
***
*** You have attempted to explicitly disable support for all codecs:
*** FLAC, Speex and Vorbis.
***
*** If you want a fish that does nothing, try kfishd:
***
***   http://www.verge.net.au/~horms/junk/
***
*** or buy a live one and let it watch television.
***
])
fi

dnl
dnl Set overall configuration success to no if none of FLAC, Vorbis or Speex
dnl has been found.
dnl
if test "x$HAVE_VORBIS" = "xno" && test "x$HAVE_SPEEX" = "xno" && test "x$HAVE_FLAC" = "xno" ; then
  fishsound_config_ok=no
fi

dnl
dnl Example programs
dnl

dnl
dnl  Detect oggz
dnl

if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
  PKG_CHECK_MODULES(OGGZ, oggz >= 0.5.40,
                    HAVE_OGGZ="yes", HAVE_OGGZ="no")
fi

if test "$HAVE_OGGZ" = "yes" ; then
  AC_DEFINE(HAVE_OGGZ, [], [Define if have liboggz])
  AC_SUBST(OGGZ_LIBS)
else
  AC_CHECK_LIB(oggz, oggz_open, OGGZ_LIBS="maybe")
  if test "$OGGZ_LIBS" = "maybe" ; then  
    AC_MSG_ERROR([
***
*** liboggz-0.5.20 or greater seems to exist on your system, however
*** the pkg-config tool cannot find its build information.
***
*** Please set your PKG_CONFIG_PATH environment variable to include the
*** directory in which oggz.pc was installed. For example, oggz.pc
*** is installed in /usr/local/lib/pkgconfig by default; if that is the
*** case do:
***
***     export PKG_CONFIG_PATH="\$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"
***
*** then run this ./configure again. If you configured liboggz with a
*** different --prefix option, replace /usr/local above with that prefix.
***
])
  fi
fi
AM_CONDITIONAL(HAVE_OGGZ, [test "x$HAVE_OGGZ" = "xyes"])

dnl
dnl Detect libsndfile1
dnl
 
if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
  PKG_CHECK_MODULES(SNDFILE, sndfile >= 1.0.0,
                    HAVE_LIBSNDFILE1="yes", HAVE_LIBSNDFILE1="no")
fi

if test "x$HAVE_LIBSNDFILE1" = xyes ; then
  AC_DEFINE(HAVE_LIBSNDFILE1, [], [Define if have libsndfile])
  AC_SUBST(SNDFILE_CFLAGS)
  AC_SUBST(SNDFILE_LIBS)
fi
AM_CONDITIONAL(HAVE_LIBSNDFILE1, [test "x$HAVE_LIBSNDFILE1" = "xyes"])


# Checks for typedefs, structures, and compiler characteristics.

dnl Add some useful warnings if we have gcc.
dnl changequote(,)dnl
if test "x$ac_cv_prog_gcc" = xyes ; then
  CFLAGS="$CFLAGS -Wall -Wextra -g -std=gnu99 -Wdeclaration-after-statement -Wno-unused"
fi
dnl changequote([,])dnl

dnl
dnl  Configuration option to add -Werror to all Makefiles
dnl

AC_ARG_ENABLE(gcc-werror,
     AC_HELP_STRING([--enable-gcc-werror], [enable -Werror in all Makefiles]),
     [ ac_enable_gcc_werror=yes ], [ ac_enable_gcc_werror=no] )

if test "x${ac_enable_gcc_werror}" = xyes ; then
  CFLAGS="-Werror $CFLAGS"
fi

dnl
dnl Shared library symbol versioning and hiding
dnl

case "$target_os" in
  linux* | solaris*|k*bsd*-gnu*|gnu*)
    SHLIB_VERSION_ARG="-Wl,--version-script=Version_script"
    ;;
  *)
    ;;
esac

dnl
dnl  Configuration tests complete -- provide summary of results.
dnl

if test $fishsound_config_ok = no ; then

AC_MSG_RESULT([
**************************************************************

*** $PACKAGE $VERSION: Automatic configuration FAILED.

*** The file config.log has full details.

*** The following required libraries are missing or
*** misconfigured on your system:
])

if test "x$HAVE_VORBIS" != xyes ; then
    AC_MSG_RESULT(
[*** libvorbis, available from  http://www.vorbis.com/])
fi
if test "x$HAVE_VORBIS" = xmaybe ; then
    AC_MSG_RESULT(
[      Development files missing: The libvorbis and libvorbisenc library
      binaries seem to be installed, but building of a test program failed.
])
fi

if test "x$HAVE_SPEEX" != xyes ; then
    AC_MSG_RESULT(
[*** libspeex, available from  http://www.speex.org/])
fi
if test "x$HAVE_SPEEX" = xmaybe ; then
    AC_MSG_RESULT(
[      Development files missing: The libspeex library binary seems to be
      installed, but building of a test program failed.
])
fi

if test "x$HAVE_FLAC" != xyes ; then
    AC_MSG_RESULT(
[*** libFLAC, available from  http://flac.sourceforge.net/])
fi
if test "x$HAVE_FLAC" = xmaybe ; then
    AC_MSG_RESULT(
[      Development files missing: The libFLAC library binary seems to be
      installed, but building of a test program failed.
])
fi

AC_MSG_RESULT(
[*** If you install the required libraries from source, you
*** need to inform the dynamic linker of their location. If
*** you install them in a system-wide directory such as
*** /usr/local (the default), you must ensure that
*** /usr/local/lib is listed in /etc/ld.so.conf, then run
*** ldconfig to update the dynamic linking system.
*** Alternatively, you can set your LD_LIBRARY_PATH environment
*** variable to include the library installation directory.
])


AC_MSG_RESULT(
[**************************************************************
])


AC_MSG_ERROR([
***
*** After fixing the above problems, you must run ./configure again.
***
]) 

else

AC_SUBST(SHLIB_VERSION_ARG)
AC_SUBST(SHARED_VERSION_INFO)

AC_SUBST(fishsound_pkgdeps)

if test "x$HAVE_OGGZ" = xyes ; then
  fishsound_examples="fishsound-identify"

  if test "x$HAVE_LIBSNDFILE1" = xyes ; then
    if test "x${ac_enable_decode}" = xyes ; then
      fishsound_examples="$fishsound_examples fishsound-decode"
    fi
    if test "x${ac_enable_encode}" = xyes ; then
      fishsound_examples="$fishsound_examples fishsound-encode"
    fi
  else
    fishsound_examples="$fishsound_examples (fishsound-decode and fishsound-encode require libsndfile)"
  fi
else
  fishsound_examples="(none; liboggz and libsndfile required)"
fi

AC_OUTPUT([
Makefile
doc/Makefile
doc/Doxyfile
include/Makefile
include/fishsound/Makefile
src/Makefile
src/libfishsound/Version_script
src/libfishsound/Makefile
src/tests/Makefile
src/examples/Makefile
fishsound.pc
])

AS_AC_EXPAND(LIBDIR, ${libdir})
AS_AC_EXPAND(INCLUDEDIR, ${includedir})
AS_AC_EXPAND(BINDIR, ${bindir})
AS_AC_EXPAND(DOCDIR, ${datadir}/doc)

AC_MSG_RESULT([
------------------------------------------------------------------------
  $PACKAGE $VERSION:  Automatic configuration OK.

  General configuration:

    Experimental code: ........... ${ac_enable_experimental}
    Decoding support: ............ ${ac_enable_decode}
    Encoding support: ............ ${ac_enable_encode}

  Library configuration (./src/libfishsound):

    FLAC support: ................ $FLAC_SUPPORT
    Speex support: ............... $SPEEX_SUPPORT
    Vorbis support: .............. $VORBIS_SUPPORT

  Example programs (./src/examples):

    $fishsound_examples

  Installation paths:

    libfishsound: ................ ${LIBDIR}
    C header files: .............. ${INCLUDEDIR}/fishsound
    Documentation: ............... ${DOCDIR}/$PACKAGE

  Building:

    Type 'make' to compile $PACKAGE.

    Type 'make install' to install $PACKAGE.

    ${TESTS_INFO}

  Example programs will be built but not installed.
------------------------------------------------------------------------
])

fi
