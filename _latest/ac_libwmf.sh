#!/bin/bash

function _install_libwmf() {
	clear
	_file=libwmf-0.2.8.4.tar.gz
	_package="LibWMF"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://nchc.dl.sourceforge.net/project/wvware/libwmf/0.2.8.4/$_file
	fi
	tar -xvzf $_file
	cd libwmf-0.2.8.4/
	./configure --prefix=$INSTALL_DIR --with-freetype=/usr/local/ffmpegtoolkit
	make -j $cpu
	make install
	echo -e $RED"Installation of $_file ....... started"$RESET
	cd $SOURCE_DIR/
}

_install_libwmf
