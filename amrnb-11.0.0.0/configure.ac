#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_INIT([amrnb],[11.0.0.0],[Stanislav Brabec <utx@penguin.cz>])
AM_INIT_AUTOMAKE([dist-bzip2])
AC_CONFIG_MACRO_DIR([m4])

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_LIBTOOL_WIN32_DLL
AM_PROG_LIBTOOL
AC_PATH_PROG([UNZIP],[unzip])
if test x"$UNZIP" = x -a ! -f "sp_enc.c" ; then
    AC_MSG_ERROR([You need unzip utility to prepare sources.])
fi
AC_PATH_PROG([PATCH],[patch])
if test x"$PATCH" = x -a ! -f "sp_enc.c" ; then
    AC_MSG_ERROR([You need patch utility to prepare sources.])
fi
AC_PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL
if test x"$PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL" = x -a ! "(" -f "26104-b00.zip" -o -f "sp_enc.c" ")" ; then
dnl number sigh cannot be a part of AC_MSG_ERROR
    NUMBER_SIGN="#"
    AC_MSG_ERROR([You need parameter expansion string replace (i. e. \${var%string} and \${var${NUMBER_SIGN}string}) capable shell (bash, ash, better sh).])
fi
AC_CHECK_DOWNLOADER_PROG
if test x"$DOWNLOADER_PROG" = x -a ! "(" -f "26104-b00.zip" -o -f "sp_enc.c" ")" ; then
    AC_MSG_ERROR([You need downloader utility to download sources (wget, fetch or curl).])
fi

# Checks for libraries.
AC_SEARCH_LIBS([sqrt],[m])

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([float.h memory.h stdint.h stdlib.h string.h],[],[
    AC_MSG_ERROR([You need standard header files.])
])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT8_T
AC_TYPE_UINT8_T
AC_C_VOLATILE

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([floor memset sqrt strtol],[],[
    AC_MSG_ERROR([You basic math functions.])
])

AC_CONFIG_FILES([Makefile amrnb.spec prepare_sources.sh])
AC_OUTPUT
