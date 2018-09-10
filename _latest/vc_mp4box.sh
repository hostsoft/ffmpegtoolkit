#!/bin/bash

function _install_mp4box() {
	clear
	_file="v0.7.1.tar.gz"
	_package="GPAC"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	rm -rf gpac gpac*
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://github.com/gpac/gpac/archive/$_file
	fi
	tar -xvzf $_file
	cd gpac-0.7.1
	./configure --prefix=$INSTALL_DIR --extra-cflags=-I/usr/local/ffmpegtoolkit/include/ \
	--extra-ldflags=-L/usr/local/ffmpegtoolkit/lib  --disable-wx --static-mp4box
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_mp4box


