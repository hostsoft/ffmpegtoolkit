#!/bin/bash

function _install_opencoreamr() {
	clear
	_file="opencore-amr-0.1.5.tar.gz"
	_package="OpenCoreAMR"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://nchc.dl.sourceforge.net/project/opencore-amr/opencore-amr/$_file
	fi
	tar -zxvf $_file
	cd opencore-amr-0.1.5/
	./configure --prefix=$INSTALL_DIR 
	make -j $cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_opencoreamr