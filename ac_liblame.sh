#!/bin/bash

function _install_lame() {
	clear
	_file="lame-3.100.tar.gz"
	_package="Lame MP3 Lib"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://ftp.osuosl.org/pub/blfs/conglomeration/lame/$_file
	fi

	tar -zxvf $_file
	cd lame-3.100/
	./configure --prefix=$INSTALL_DIR --enable-mp3x --enable-mp3rtp
	make -j $cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_lame




