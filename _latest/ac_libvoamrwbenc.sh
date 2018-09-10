#!/bin/bash

function _install_voamrwbenc() {
	clear
	_file=""
	_package="Vo-amrwbenc"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "vo-amrwbenc" ] && rm -rf "vo-amrwbenc"
	wget https://nchc.dl.sourceforge.net/project/opencore-amr/vo-amrwbenc/vo-amrwbenc-0.1.3.tar.gz
	tar xfz vo-amrwbenc-0.1.3.tar.gz
	cd vo-amrwbenc-0.1.3
	./configure --prefix=$INSTALL_DIR
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_voamrwbenc
