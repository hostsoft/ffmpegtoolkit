# Find for parameter expansion string replace capable shell
# (i. e. shell supporting ${VAR%bc} and ${VAR#ab})
# Result is returned in PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL
AC_DEFUN([AC_PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL],
[
    AC_ARG_WITH([parameter_expansion_string_replace_capable_shell],[AS_HELP_STRING([--with-parameter-expansion-string-replace-capable-shell],[full path to shell that supports parameter expansion string replace (i. e. ${var%string} and ${var#string}) [default=check]])],[
	ac_parameter_expansion_string_replace_capable_shell="$withval"
    ],[
	ac_parameter_expansion_string_replace_capable_shell="none"
	AC_CHECK_FILE([/bin/bash],[
	    BASH="/bin/bash"
	],[
	    AC_PATH_PROG([BASH],[bash])
	])
	if test "x$BASH" != "x" ; then
	    ac_parameter_expansion_string_replace_capable_shell="$BASH"
	else
	    AC_CHECK_FILE([/bin/ash],[
		ASH="/bin/ash"
	    ],[
		AC_PATH_PROG([ASH],[ash])
	    ])
	    if test "x$ASH" != "x" ; then
		ac_parameter_expansion_string_replace_capable_shell="$ASH"
	    fi
	fi
    ])
    AC_CACHE_CHECK([for parameter expansion string replace capable shell],
    [ac_cv_parameter_expansion_string_replace_capable_shell],[
	ac_cv_parameter_expansion_string_replace_capable_shell="none"
	if test x"$ac_parameter_expansion_string_replace_capable_shell" = xnone ; then
	    if test x`/bin/sh -c "exec 2>/dev/null ; VAR=abc ; echo \\${VAR%bc}\\${VAR#ab}"` = xac ; then
		ac_cv_parameter_expansion_string_replace_capable_shell="/bin/sh"
	    fi
	else
	    ac_cv_parameter_expansion_string_replace_capable_shell="$ac_parameter_expansion_string_replace_capable_shell"
	fi
    ])
    if test x"$ac_cv_parameter_expansion_string_replace_capable_shell" != "xnone" ; then
	PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL="$ac_cv_parameter_expansion_string_replace_capable_shell"
    else
	PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL=""
    fi
    AC_SUBST([PARAMETER_EXPANSION_STRING_REPLACE_CAPABLE_SHELL])
])
