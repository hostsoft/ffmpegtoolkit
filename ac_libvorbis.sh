#!/bin/bash

function _install_libvorbis() {
	clear
	_file="libvorbis-1.3.5.tar.gz"
	_package="Libvorbis"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://downloads.xiph.org/releases/vorbis/$_file
	fi
	tar -xvzf $_file
	cd libvorbis-1.3.5/
	./configure --prefix=$INSTALL_DIR
	make -j$cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libvorbis
