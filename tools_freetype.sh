#!/bin/bash



function _install_freetype() {
	clear
	_file=freetype-2.9.tar.gz
	_package="FreeType"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/

	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://download.savannah.gnu.org/releases/freetype/$_file
	fi
	tar -zxvf $_file
	cd freetype-2.9/
	./configure --prefix=$INSTALL_DIR 
	make -j $cpu
	make install
	echo -e $RED"Installation of $_file ....... started"$RESET
	cd $SOURCE_DIR/
}

_install_freetype





