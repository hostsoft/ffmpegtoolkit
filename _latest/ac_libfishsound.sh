#!/bin/bash

function _install_libfish() {
	clear
	_file="libfishsound-1.0.0.tar.gz"
	_package="Lib FishSound"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://downloads.xiph.org/releases/libfishsound/$_file
	fi
	tar -xvzf $_file
	cd libfishsound-1.0.0/
	export PKG_CONFIG_LIBDIR=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig
	./configure --prefix=$INSTALL_DIR --with-vorbis=/usr/local/ffmpegtoolkit  --with-FLAC=/usr/local/ffmpegtoolkit  --with-speex=/usr/local/ffmpegtoolkit
	make -j$cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libfish



