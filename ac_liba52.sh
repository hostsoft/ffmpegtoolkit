#!/bin/bash

function _install_liba52() {
	clear
	_file="a52dec-0.7.4.tar.gz"
	_package="Liba52"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://liba52.sourceforge.net/files/$_file
	fi
	tar -xvzf $_file
	cd a52dec-0.7.4/
	./bootstrap
	ARCh=`arch`
	#64bit processor bug fix
	if [[ $ARCh == 'x86_64' ]];then
		./configure --prefix=$INSTALL_DIR --enable-shared 'CFLAGS=-fPIC'	
	else
		./configure --prefix=$INSTALL_DIR  --enable-shared
	fi
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_liba52
