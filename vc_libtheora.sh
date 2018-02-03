#!/bin/bash

function _install_libtheora() {
	clear
	_file="libtheora-1.1.1.zip"
	_package="Libtheora"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://downloads.xiph.org/releases/theora/$_file
	fi
	unzip -o libtheora-1.1.1.zip
	cd libtheora-1.1.1/
	./configure --prefix=$INSTALL_DIR --with-ogg=$INSTALL_DIR --with-vorbis=$INSTALL_DIR
	make -j$cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libtheora

