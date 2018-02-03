#!/bin/bash

function _install_fdkaac() {
	clear
	_file=""
	_package="fdkacc"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "fdk-aac" ] && rm -rf "fdk-aac"
	git clone https://github.com/mstorsjo/fdk-aac
	cd fdk-aac/
	./autogen.sh
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_fdkaac
