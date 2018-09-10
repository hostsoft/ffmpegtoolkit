#!/bin/bash

set -o errexit
trap "rm -rf c-code *.c *.h readme.txt *.new *.def *.all" 0
export LC_CTYPE=C LC_ALL=

cd "$1"

rm -rf c-code *.c *.h readme.txt
/usr/bin/unzip 26104-b00_ANSI_C_source_code.zip

for FILE in readme.txt c-code/*.c  c-code/*.h ; do
    tr -d '\r\000' <$FILE >${FILE#*/}.new
    mv ${FILE#*/}.new ${FILE#*/}
done

rm -r c-code

/usr/bin/patch <amrnb-intsizes.patch
/usr/bin/patch <amrnb-strict-aliasing.patch
/usr/bin/patch <amrnb-any-cflags.patch

for FILE in interf_dec.[ch] interf_enc.[ch] ; do
    echo "modifying file $FILE"
    if test $FILE = ${FILE%.h} ; then
	ENDSTRING="^}"
    else
	ENDSTRING=");"
    fi
    sed -n "
	/^[^# ][^ ]* VADx..coder_Interface_..code/,/$ENDSTRING/p
	/^[^# ][^ ]* ..coder_Interface_..code/,/$ENDSTRING/p
	" <$FILE >$FILE.def
    sed 's/^\([^# ][^ ]*\) VADx\(..coder_Interface_..code\)/\1 GP3VADx\2/
	 s/^\([^# ][^ ]*\) \(..coder_Interface_..code\)/\1 GP3\2/
	 s:ifndef IF2:if 1 /* & */:
	 s:ifdef IF2:if 0 /* & */:
	 s:ifndef ETSI:if 1 /* & */:
	 s:ifdef ETSI:if 0 /* & */:
	' <$FILE.def >$FILE.all
    sed 's/^\([^# ][^ ]*\) VADx\(..coder_Interface_..code\)/\1 IF2VADx\2/
	 s/^\([^# ][^ ]*\) \(..coder_Interface_..code\)/\1 IF2\2/
	 s:ifndef IF2:if 0 /* & */:
	 s:ifdef IF2:if 1 /* & */:
	 s:ifndef ETSI:if 1 /* & */:
	 s:ifdef ETSI:if 0 /* & */:
	' <$FILE.def >>$FILE.all
    sed 's/^\([^# ][^ ]*\) VADx\(..coder_Interface_..code\)/\1 ETSIVADx\2/
	 s/^\([^# ][^ ]*\) \(..coder_Interface_..code\)/\1 ETSI\2/
	 s:ifndef IF2:if 1 /* & */:
	 s:ifdef IF2:if 0 /* & */:
	 s:ifndef ETSI:if 0 /* & */:
	 s:ifdef ETSI:if 1 /* & */:
	' <$FILE.def >>$FILE.all
    sed "/^[^# ][^ ]* VADx..coder_Interface_..code/,/$ENDSTRING/c\\
/* Triple the code with different defines and names */
	 /^[^# ][^ ]* ..coder_Interface_..code/,/$ENDSTRING/c\\
/* Triple the code with different defines and names */
" <$FILE |
    sed "/Triple the code with different defines and names/r $FILE.all" >$FILE.new
    mv $FILE.new $FILE
    rm $FILE.def $FILE.all
done
for FILE in sp_enc.c ; do
    echo "modifying file $FILE"
    if test $FILE = ${FILE%.h} ; then
	ENDSTRING="^}"
    else
	ENDSTRING=");"
    fi
    for FUNCTION in Lag_max Pitch_ol Lag_max_wght Pitch_ol_wgh cod_amr cod_amr_reset ol_ltp ; do
	rm -f $FILE.all
	sed -n "/^static [^ ]* $FUNCTION(/,/$ENDSTRING/p" <$FILE >$FILE.def
	sed "s/^\(static [^ ]*\) \($FUNCTION\)(/\1 VAD1\2(/
	     s:ifndef VAD2:if 1 /* & */:
	     s:ifdef VAD2:if 0 /* & */:
	     s:vadState:vad1State:g
	     s:\([= ] \)Lag_max:\1VAD1Lag_max:g
	     s:\([= ] \)ol_ltp:\1VAD1ol_ltp:g
	     s:\([= ] \)Pitch_ol:\1VAD1Pitch_ol:g
	     s:\([a-z][a-z]*\)->vadSt:((vad1State*)(\1->vadSt)):g
	    " <$FILE.def >$FILE.all
	sed "s/^\(static [^ ]*\) \($FUNCTION\)(/\1 VAD2\2(/
	     s:ifndef VAD2:if 0 /* & */:
	     s:ifdef VAD2:if 1 /* & */:
	     s:vadState:vad2State:g
	     s:\([= ] \)Lag_max:\1VAD2Lag_max:g
	     s:\([= ] \)ol_ltp:\1VAD2ol_ltp:g
	     s:\([= ] \)Pitch_ol:\1VAD2Pitch_ol:g
	     s:\([a-z][a-z]*\)->vadSt:((vad2State*)(\1->vadSt)):g
	    " <$FILE.def >>$FILE.all
	sed "/^static [^ ]* \($FUNCTION\)(/,/$ENDSTRING/c\\
/* Double the $FUNCTION code with different defines and names */
" <$FILE |
	sed "/Double the $FUNCTION code with different defines and names/r $FILE.all" >$FILE.new
	mv $FILE.new $FILE
	rm $FILE.def $FILE.all
    done
done

trap 0
