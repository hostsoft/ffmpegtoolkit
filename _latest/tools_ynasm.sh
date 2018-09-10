#!/bin/bash

function _install_yasm() {
	clear
	_file="yasm-1.3.0.tar.gz"
	_package="YASM"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.tortall.net/projects/yasm/releases/$_file
	fi
	tar -xvzf $_file
	cd  yasm-1.3.0/
	./configure --prefix=$INSTALL_DIR
	make -j$cpu
	make install
	ln -sf /usr/local/ffmpegtoolkit/bin/yasm /usr/local/bin/yasm
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

function _install_nasm() {
	clear
	_file="nasm-2.13.02.tar.gz"
	_package="NASM"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/$_file
	fi
	tar -xvzf $_file
	cd  nasm-2.13.02/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	ln -sf /usr/local/ffmpegtoolkit/bin/nasm /usr/local/bin/nasm
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_yasm
_install_nasm




