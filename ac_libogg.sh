#!/bin/bash

function _install_libogg() {
	clear
	_file="libogg-1.3.3.tar.gz"
	_package="Libogg"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://ftp.osuosl.org/pub/xiph/releases/ogg/$_file
	fi
   	tar -xvzf $_file
   	cd libogg-1.3.3/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libogg

