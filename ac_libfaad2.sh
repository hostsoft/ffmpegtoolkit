#!/bin/bash

function _install_faad2() {
	clear
	_file=""
	_package="FAAD2"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "faad2" ] && rm -rf "faad2"
	git clone https://github.com/dsvensson/faad2
	cd faad2/
	./bootstrap
	./configure --prefix=$INSTALL_DIR  --with-mpeg4ip      
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_faad2
