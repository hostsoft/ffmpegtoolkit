#!/bin/bash

function _install_flac() {
	clear
	_file="flac-1.3.2.tar.xz"
	_package="Lib Flac"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://ftp.osuosl.org/pub/xiph/releases/flac/$_file
	fi
	tar -xJf $_file
	cd flac-1.3.2/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_flac


