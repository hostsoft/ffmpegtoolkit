#!/bin/bash

function _install_amrnb() {
	clear
	_file="amrnb-11.0.0.0.tar.bz2"
	_package=""
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.penguin.cz/~utx/ftp/amr//$_file
	fi
	tar -xvjf $_file
	cd amrnb-11.0.0.0/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

function _install_amrwb() {
	clear
	_file="amrwb-11.0.0.0.tar.bz2"
	_package=""
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.penguin.cz/~utx/ftp/amr//$_file
	fi
	tar -xvjf $_file
	cd amrwb-11.0.0.0/
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_amrnb
_install_amrwb
