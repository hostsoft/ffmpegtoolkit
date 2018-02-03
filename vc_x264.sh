#!/bin/bash

function _install_x264() {
	clear
	_file="last_stable_x264.tar.bz2"
	_package="x264"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	rm -vrf x264-snapshot*
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://download.videolan.org/x264/snapshots/$_file
	fi
	tar xvjf last_stable_x264.tar.bz2
	cd x264-snapshot-*-stable/
	./configure --prefix=$INSTALL_DIR --enable-shared --enable-pic --disable-asm
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}
_install_x264
