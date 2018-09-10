#!/bin/bash

function _install_yamdi() {
	clear
	_file=""
	_package="Yamdi - Yet Another MetaData Injector for FLV"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "yamdi" ] && rm -rf "yamdi"
	git clone https://github.com/ioppermann/yamdi
	cd yamdi/
	gcc yamdi.c -o $INSTALL_DIR/bin/yamdi -O2 -Wall
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_yamdi



