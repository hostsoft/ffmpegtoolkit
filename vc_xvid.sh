#!/bin/bash

function _install_xvidcore() {
	clear
	_file="xvidcore-1.3.5.tar.gz"
	_package="Xvid Core"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://downloads.xvid.com/downloads/$_file
	fi
	tar -xvzf $_file
	cd xvidcore/build/generic/
	./configure --prefix=$INSTALL_DIR
	make -j$cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_xvidcore
