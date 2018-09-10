# Find web downloading utility
# Result is returned in DOWNLOADER_PROG
AC_DEFUN([AC_CHECK_DOWNLOADER_PROG],
[
    AC_ARG_WITH([downloader],[AS_HELP_STRING([--with-downloader],[http downloading command [default=check]])],[
	ac_downloader_prog="$withval"
    ],[
	AC_PATH_PROGS([DOWNLOADER_PROG_CMD],[wget fetch curl])
	ac_downloader_prog="none"
    ])
    AC_CACHE_CHECK([for web downloading command],
    [ac_cv_downloader_prog],
    [
	ac_cv_downloader_prog="$ac_downloader_prog"
	ac_downloader_prog_args=""
	if test x"$ac_cv_downloader_prog" = "xnone" ; then
	    case "$DOWNLOADER_PROG_CMD" in
		*wget*)
		    # Does wget does not support -N?
		    if wget --help 2>/dev/null | grep " -N" >/dev/null ; then
			ac_downloader_prog_args=" -N"
		    else
			ac_downloader_prog_args=""
		    fi
		;;
		*fetch*)
		    ac_downloader_prog_args=" -m"
		;;
		*curl*)
		    ac_downloader_prog_args=" -OR"
		;;
	    esac
	    ac_cv_downloader_prog="$DOWNLOADER_PROG_CMD$ac_downloader_prog_args"
	fi
    ])
    if test x"$ac_cv_downloader_prog" != xnone ; then
	DOWNLOADER_PROG="$ac_cv_downloader_prog"
    else
	DOWNLOADER_PROG=""
    fi
    AC_SUBST([DOWNLOADER_PROG])
])
