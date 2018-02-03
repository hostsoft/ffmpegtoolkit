#!/bin/bash

function _install_vorbistools() {
	clear
	_file="vorbis-tools-1.4.0.tar.gz"
	_package="Vorbis Tools"
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
	cd vorbis-tools-1.4.0/
	./configure --prefix=$INSTALL_DIR
	make -j$cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_vorbistools
