#!/bin/bash

function _install_aom() {
	clear
	_file=""
	_package="aom"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "aom" ] && rm -rf "aom"
	git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom
	mkdir aom_build
	cd aom_build
	PATH="$HOME/bin:$PATH" 
	cmake3 -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom
	make
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_aom
