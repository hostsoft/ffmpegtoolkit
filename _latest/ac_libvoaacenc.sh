#!/bin/bash

function _install_voaacenc() {
	clear
	_file=""
	_package="vo-aacenc"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "vo-aacenc" ] && rm -rf "vo-aacenc"
	git clone https://github.com/mstorsjo/vo-aacenc
	cd vo-aacenc/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_voaacenc
