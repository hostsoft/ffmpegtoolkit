#!/bin/bash

function _install_x265() {
	clear
	_file=""
	_package="X265"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "x265" ] && rm -rf "x265"
	hg clone http://hg.videolan.org/x265
	cd x265/build/linux
	PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DENABLE_SHARED:bool=off ../../source
	make
	make install
	make clean
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_x265

