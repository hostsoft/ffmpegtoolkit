#!/bin/bash

# https://github.com/libass/libass

function _install_libass() {
	clear
	_file="libass-0.14.0.tar.gz"
	_package="Libass"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget https://github.com/libass/libass/releases/download/0.14.0/$_file
	fi
	tar -xvzf $_file
	cd  libass-0.14.0/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}
_install_libass


