#!/bin/bash

function _install_libopus() {
	clear
	_file="opus-1.2.1.tar.gz"
	_package="OPUS"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://archive.mozilla.org/pub/opus/$_file
	fi
	tar -xvzf $_file
	cd opus-1.2.1/
	./configure --prefix=$INSTALL_DIR --disable-shared
	make -j$cpu
	make install
	make distclean
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libopus







