#!/bin/bash

function _install_liboggz() {
	clear
	_file="liboggz-1.1.1.tar.gz"
	_package="Libogg"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://downloads.xiph.org/releases/liboggz//$_file
	fi
   	tar -xvzf $_file
	cd liboggz-1.1.1/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_liboggz


