# Process this file with autoconf to produce a configure script.
AC_INIT
AC_CONFIG_SRCDIR([src/liboggz/oggz.c])

AC_PREREQ(2.53)

AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE(liboggz, 1.1.1)
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
SHARED_VERSION_INFO="8:0:6"
SHLIB_VERSION_ARG=""

# Checks for programs.
AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL

AC_C_CONST
AC_C_BIGENDIAN

dnl Add parameters for aclocal
AC_SUBST(ACLOCAL_AMFLAGS, "-I m4")

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([fcntl.h inttypes.h stdlib.h string.h sys/types.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_OFF_T
AC_TYPE_SIZE_T

dnl Check whether the compiler allows signed enums.
dnl Re: http://lists.xiph.org/pipermail/ogg-dev/2008-July/001108.html
dnl
dnl "The ISO C standard, in section 6.7.2.2 "enumeration specifiers",
dnl paragraph 4, says
dnl
dnl   Each enumerated type shall be compatible with *char*, a signed
dnl   integer type, or an unsigned integer type.  The choice of type is
dnl   implementation-defined, but shall be capable of representing the
dnl   values of all the members of the declaration."
dnl
dnl -- http://gcc.gnu.org/ml/gcc-bugs/2000-09/msg00271.html
AC_MSG_CHECKING([if $CC allows signed enums])

ac_save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS -Wall -Wextra -Werror"
AC_TRY_COMPILE([], [
               void t (void)
               {
                 enum {A, B} a=A;
                 if (a < 0) {}
               } ],
               [ AC_DEFINE([ALLOW_SIGNED_ENUMS], [],
                           [Define if the compiler implements enums as signed values.])
                 AC_MSG_RESULT(yes) ],
               [ AC_MSG_RESULT(no) ])
CFLAGS="$ac_save_CFLAGS"

# Checks for library functions.
AC_CHECK_FUNCS([memmove])

# Check for pkg-config
AC_CHECK_PROG(HAVE_PKG_CONFIG, pkg-config, yes)

# Check for doxygen
AC_CHECK_PROG(HAVE_DOXYGEN, doxygen, true, false)
AM_CONDITIONAL(HAVE_DOXYGEN,$HAVE_DOXYGEN)
if test $HAVE_DOXYGEN = "false"; then
             AC_MSG_WARN([*** doxygen not found, docs will not be built])
fi

# Check for man2html
AC_CHECK_PROG(HAVE_MAN2HTML, man2html, true, false)
AM_CONDITIONAL(HAVE_MAN2HTML, $HAVE_MAN2HTML)

# Check for valgrind
VALGRIND_ENVIRONMENT=""
ac_enable_valgrind=no
AC_ARG_ENABLE(valgrind-testing,
     AC_HELP_STRING([--enable-valgrind-testing], [enable running of tests inside Valgrind]),
     [ ac_enable_valgrind=yes ], [ ac_enable_valgrind=no] )

if test "x${ac_enable_valgrind}" = xyes ; then
  if test "x${enable_shared}" = xyes ; then
    VALGRIND_ENVIRONMENT="libtool --mode=execute "
  fi

  AC_CHECK_PROG(HAVE_VALGRIND, valgrind, yes, no)
  if test "x$HAVE_VALGRIND" = xyes ; then
    VALGRIND_ENVIRONMENT="$VALGRIND_ENVIRONMENT valgrind -q --leak-check=yes --show-reachable=yes --num-callers=50"
    AC_SUBST(VALGRIND_ENVIRONMENT)
    TESTS_INFO="Test suite will be run under:
    ${VALGRIND_ENVIRONMENT}"
  else
    TESTS_INFO="(Valgrind not found)"
  fi
else
  TESTS_INFO="(Valgrind testing not enabled)"
fi

dnl Checks for libraries.
LIBS=""

# check for getopt in a separate library
HAVE_GETOPT=no
AC_CHECK_LIB(getopt, getopt, HAVE_GETOPT="yes")
if test "x$HAVE_GETOPT" = xyes ; then
  GETOPT_LIBS="-lgetopt"
  AC_SUBST(GETOPT_LIBS)
fi

# check for getopt_long in standard library
HAVE_GETOPT_LONG=no
AC_CHECK_FUNC(getopt_long, HAVE_GETOPT_LONG="yes")
if test "x$HAVE_GETOPT_LONG" = xyes ; then
  AC_DEFINE(HAVE_GETOPT_LONG, [], [Define to 1 if you have the 'getopt_long' function])
fi

dnl Overall configuration success flag
oggz_config_ok=yes

oggz_read_programs=""
oggz_rw_programs=""

dnl
dnl  Configuration option for building of experimental code.
dnl

ac_enable_experimental=no
AC_ARG_ENABLE(experimental,
     AC_HELP_STRING([--enable-experimental], [enable building of experimental code]),
     [ ac_enable_experimental=yes ])

if test "x${ac_enable_experimental}" = xyes ; then
    AC_DEFINE(OGGZ_CONFIG_EXPERIMENTAL, [], [Define to build experimental code])
fi

dnl
dnl  Configuration option for building of reading support.
dnl

ac_enable_read=yes
AC_ARG_ENABLE(read,
     AC_HELP_STRING([--disable-read], [disable building of reading support]),
     [ ac_enable_read=no ], [ ac_enable_read=yes] )

if test "x${ac_enable_read}" = xyes ; then
    AC_DEFINE(OGGZ_CONFIG_READ, [1], [Build reading support])
    oggz_read_programs="oggz-dump oggz-info oggz-scan oggz-codecs"
else
    AC_DEFINE(OGGZ_CONFIG_READ, [0], [Do not build reading support]) 
fi
AM_CONDITIONAL(OGGZ_CONFIG_READ, test "x${ac_enable_read}" = xyes)

dnl
dnl  Configuration option for building of writing support.
dnl
  
ac_enable_write=yes
AC_ARG_ENABLE(write,
     AC_HELP_STRING([--disable-write], [disable building of writing support]),
     [ ac_enable_write=no ], [ ac_enable_write=yes] )

if test "x${ac_enable_write}" = xyes ; then
    AC_DEFINE(OGGZ_CONFIG_WRITE, [1], [Build writing support])
    if test "x${ac_enable_read}" = xyes ; then
      oggz_rw_programs="oggz-rip oggz-merge oggz-chop oggz-comment oggz-sort oggz-validate"
    fi
else
    AC_DEFINE(OGGZ_CONFIG_WRITE, [0], [Do not build writing support])
fi
AM_CONDITIONAL(OGGZ_CONFIG_WRITE, test "x${ac_enable_write}" = xyes)

dnl
dnl  Check read/write option sanity
dnl
if test "x${ac_enable_read}" = xno && test "x${ac_enable_write}" = xno ; then
  AC_MSG_ERROR([
***
*** You have attempted to explicitly disable both writing and reading.
***
])
fi

dnl
dnl Detect Ogg
dnl

HAVE_OGG=no
if test "x$HAVE_PKG_CONFIG" = "xyes" ; then
  PKG_CHECK_MODULES(OGG, ogg >= 1.0, HAVE_OGG=yes, HAVE_OGG=no)
fi

if test "x$HAVE_OGG" = "xno" ; then
  XIPH_PATH_OGG(HAVE_OGG="yes", HAVE_OGG="no")
  if test "x$HAVE_OGG" = xno ; then
    oggz_config_ok="no"
    AC_CHECK_LIB(ogg, ogg_stream_init, HAVE_OGG="maybe")
  fi
fi

AM_CONDITIONAL(HAVE_OGG, [test "x$HAVE_OGG" = "xyes"])

dnl Check for const-correct version of <ogg/ogg.h>
dnl In libogg changeset:14463, function prototypes like:
dnl      ogg_page_bos (ogg_page * og);
dnl were changed to:
dnl     ogg_page_bos (const ogg_page * og);
dnl If we are compiling with -Werror, we need to know this.
if test "x$HAVE_OGG" = "xyes" ; then
    AC_MSG_CHECKING([if ogg_page_bos() takes a const argument])
    ac_save_CFLAGS="$CFLAGS"
    ac_save_LIBS="$LIBS"
    CFLAGS="$CFLAGS -Wall -Werror $OGG_CFLAGS"
    LIBS="$LIBS $OGG_LIBS"

    AC_TRY_COMPILE([#include <ogg/ogg.h>],
                   [int f(const ogg_page * cog){return ogg_page_bos(cog);}],
                   [ AC_DEFINE([OGG_H_CONST_CORRECT], [], [Define if <ogg/ogg.h> is const-correct])
                     AC_MSG_RESULT(yes) ],
                   [ AC_MSG_RESULT(no) ])

    CFLAGS="$ac_save_CFLAGS"
    LIBS="$ac_save_LIBS"
fi

dnl Large file support
dnl Adapted from: libsndfile by Erik de Castro Lopo
dnl
dnl Find an appropriate type for oggz_off_t
dnl On systems supporting files larger than 2 Gig, oggz_off_t must be a
dnl 64 bit value. Unfortunately there is more than one way of ensuring
dnl this so need to do some pretty rigourous testing here.

unset ac_cv_sizeof_off_t

AC_CHECK_SIZEOF(off_t, 1)

case "$host_os" in
    mingw*)
        TYPEOF_OGGZ_OFF_T="__int64"
        OGGZ_OFF_MAX="0x7FFFFFFFFFFFFFFFLL"
        SIZEOF_OGGZ_OFF_T=8
        ;;
    *)
        if test "x$ac_cv_sizeof_off_t" = "x8" ; then
            # If sizeof (off_t) is 8, no further checking is needed.
            TYPEOF_OGGZ_OFF_T="off_t"
            OGGZ_OFF_MAX="0x7FFFFFFFFFFFFFFFLL"
            SIZEOF_OGGZ_OFF_T=8
        else
            # Check for common 64 bit file offset types.
            AC_CHECK_SIZEOF(loff_t,1)       # Fake default value.
            AC_CHECK_SIZEOF(off64_t,1)      # Fake default value.

            TYPEOF_OGGZ_OFF_T="unknown"
            if test "x$ac_cv_sizeof_loff_t" = "x8" ; then
                TYPEOF_OGGZ_OFF_T="loff_t"
                SIZEOF_OGGZ_OFF_T=8
            elif test "x$ac_cv_sizeof_off64_t" = "x8" ; then
                TYPEOF_OGGZ_OFF_T="off64_t"
                SIZEOF_OGGZ_OFF_T=8
            fi

            # Save the old sizeof (off_t) value  and then unset it to see if it
            # changes when Large File Support is enabled.

            pre_largefile_sizeof_off_t=$ac_cv_sizeof_off_t
            unset ac_cv_sizeof_off_t

            AC_SYS_EXTRA_LARGEFILE

            if test "x$ac_cv_sys_largefile_CFLAGS" = "xno" ; then
                ac_cv_sys_largefile_CFLAGS=""
            fi
            if test "x$ac_cv_sys_largefile_LDFLAGS" = "xno" ; then
                ac_cv_sys_largefile_LDFLAGS=""
            fi
            if test "x$ac_cv_sys_largefile_LIBS" = "xno" ; then
                ac_cv_sys_largefile_LIBS=""
            fi

            AC_CHECK_SIZEOF(off_t,1)        # Fake default value.

            if test "x$ac_cv_sizeof_off_t" = "x8" ; then
                    OGGZ_OFF_MAX="0x7FFFFFFFFFFFFFFFLL"
            elif test "x$ac_cv_sizeof_off_t" = "x$pre_largefile_sizeof_off_t" ; then
                AC_MSG_WARN([[This machine does not seem to support 64 bit file offsets.]])
                TYPEOF_OGGZ_OFF_T="off_t"
                SIZEOF_OGGZ_OFF_T=$ac_cv_sizeof_off_t
            elif test "x$TYPEOF_OGGZ_OFF_T" = "xunknown" ; then
                echo
                echo "*** The configure process has determined that this system is capable"
                echo "*** of Large File Support but has not been able to find a type which"
                echo "*** is an unambiguous 64 bit file offset."
                echo "*** Please contact the author to help resolve this problem."
                echo
                AC_MSG_ERROR([[Bad file offset type.]])
            fi
        fi
    ;;
    esac

if test $SIZEOF_OGGZ_OFF_T = 4 ; then
    OGGZ_OFF_MAX="0x7FFFFFFF"
    PRI_OGGZ_OFF_T="l"
elif test $SIZEOF_OGGZ_OFF_T = 8 ; then
    PRI_OGGZ_OFF_T="ll"
fi

dnl The following configured variables are written into the public header
dnl <oggz/oggz_off_t_generated.h>:
dnl   oggz_off_t (typedef)
dnl   PRI_OGGZ_OFF_T (printf format)

AC_SUBST(TYPEOF_OGGZ_OFF_T)
AC_SUBST(PRI_OGGZ_OFF_T)

dnl SIZEOF_OGGZ_OFF_T and OGGZ_OFF_MAX are only used internally by liboggz
AC_DEFINE_UNQUOTED([SIZEOF_OGGZ_OFF_T],${SIZEOF_OGGZ_OFF_T}, [Set to sizeof (long) if unknown.])
AC_SUBST(SIZEOF_OGGZ_OFF_T)

AC_DEFINE_UNQUOTED([OGGZ_OFF_MAX],${OGGZ_OFF_MAX}, [Set to maximum allowed value of sf_count_t type.])
AC_SUBST(OGGZ_OFF_MAX)

AC_CHECK_TYPES(ssize_t)
AC_CHECK_SIZEOF(ssize_t,4)

# MacOS 10.4 only declares timezone for _XOPEN_SOURCE. Check for this.
AC_MSG_CHECKING([for timezone])
AC_COMPILE_IFELSE(
  AC_LANG_PROGRAM([#include <time.h>], [
    int seconds = 1234567;
    seconds -= timezone;
  ]), AC_MSG_RESULT([ok]),
  AC_MSG_RESULT([no])
  AC_MSG_CHECKING([for timezone with _XOPEN_SOURCE])
  AC_COMPILE_IFELSE(
    AC_LANG_PROGRAM([
#define _XOPEN_SOURCE
#include <time.h>
    ], [
      int seconds = 1234567;
      seconds -= timezone;
    ]),
   dnl _XOPEN_SOURCE is required
    AC_MSG_RESULT([ok])
    AC_DEFINE([_XOPEN_SOURCE], [1], 
      [Some systems need _XOPEN_SOURCE for timezone]),
   dnl it didn't work even with _XOPEN_SOURCE; httpdate will break 
    AC_MSG_RESULT([no])
  )
)

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

# Checks for library functions.

dnl
dnl  Configuration tests complete -- provide summary of results.
dnl

if test $oggz_config_ok = no ; then

AC_MSG_RESULT([
**************************************************************

*** $PACKAGE $VERSION: Automatic configuration FAILED.

*** The file config.log has full details.

*** The following required libraries are missing or
*** misconfigured on your system:
])

if test "x$HAVE_OGG" != xyes ; then
    AC_MSG_RESULT(
[*** libogg, available from  http://www.xiph.org/ogg/])
fi
if test "x$HAVE_OGG" = xmaybe ; then
    AC_MSG_RESULT(
[      Development files missing: The libogg library binary seems to be
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

AS_AC_EXPAND(LIBDIR, ${libdir})
AS_AC_EXPAND(INCLUDEDIR, ${includedir})
AS_AC_EXPAND(BINDIR, ${bindir})
AS_AC_EXPAND(DOCDIR, ${datadir}/doc)

AC_SUBST(BINDIR)

AC_SUBST(SHLIB_VERSION_ARG)
AC_SUBST(SHARED_VERSION_INFO)

AC_OUTPUT([
Makefile
doc/Makefile
doc/Doxyfile
include/Makefile
include/oggz/Makefile
include/oggz/oggz_off_t_generated.h
src/Makefile
src/liboggz/Version_script
src/liboggz/Makefile
src/tools/Makefile
src/tools/oggz-diff
src/tools/oggz-chop/Makefile
src/tests/Makefile
src/examples/Makefile
apache/oggz-chop.conf
oggz.pc
oggz-uninstalled.pc
])

AC_MSG_RESULT([
------------------------------------------------------------------------
  $PACKAGE $VERSION:  Automatic configuration OK.

  General configuration:

    Experimental code: ........... ${ac_enable_experimental}
    Reading support: ............. ${ac_enable_read}
    Writing support: ............. ${ac_enable_write}

  Tools:

    ${oggz_read_programs}
    ${oggz_rw_programs}

  Installation paths:

    liboggz: ..................... ${LIBDIR}
    Tools: ....................... ${BINDIR}
    C header files: .............. ${INCLUDEDIR}/oggz
    Documentation: ............... ${DOCDIR}/$PACKAGE

  Building:

    Type 'make' to compile $PACKAGE.

    Type 'make install' to install $PACKAGE.

    Type 'make check' to test $PACKAGE using the unit and functional tests
    contained in the src/tests directory.
    ${TESTS_INFO}

  Example programs will be built but not installed.
------------------------------------------------------------------------
])


fi
