#!/bin/bash

function _install_libao() {
	clear
	_file="libao-1.2.0.tar.gz"
	_package="Lib AO"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://downloads.xiph.org/releases/ao/$_file
	fi
	tar -xvzf $_file
	cd libao-1.2.0/
	./configure --prefix=$INSTALL_DIR
	make -j$cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_libao
