#!/bin/sh

VERBOSE=""
THIS="seek-stress-test.sh"
COLLECTION="$HOME"

usage () {
    echo >&2 "$THIS, stress oggz's seeking using a collection of Ogg files"
    echo >&2
    echo >&2 "Usage: $THIS [options] [directory]"
    echo >&2
    echo >&2 "If no directory is specified, $THIS defaults to reading all"
    echo >&2 "Ogg files found in your home directory."
    echo >&2
    echo >&2 "Miscellaneous options"
    echo >&2 "  -h, --help                  Display this help and exit"
    echo >&2 "  -v, --verbose               Print informative messages"
    echo >&2
    exit 1
}

GETOPTEST=`getopt --version`
SHORTOPTS="hv"

case $GETOPTEST in
getopt*) # GNU getopt
    TEMP=`getopt -l help -l verbose -- +$SHORTOPTS $@`
    ;;
*) # POSIX getopt ?
    TEMP=`getopt $SHORTOPTS $@`
    ;;
esac

if test "$?" != "0"; then
  usage
fi

eval set -- "$TEMP"

while test "X$1" != "X--"; do
    case "$1" in
	    -v|--verbose)
	    VERBOSE="--verbose"
	    ;;
	    -h|--help)
	    usage
	    ;;
    esac
    shift
done

# Check that all options parsed ok
if test "x$1" != "x--"; then
    usage
fi
shift #get rid of the "--"

if test "x$1" != "x"; then
    COLLECTION=$1
fi

echo "Stress testing Oggz seeking on all Ogg files in $COLLECTION..."

for ext in ogg spx anx; do
    CMD="find $COLLECTION -follow -name '*.$ext'"
    FILES="$FILES `eval $CMD`"
done

for i in $FILES; do
    ./seek-stress $VERBOSE $i;
done
