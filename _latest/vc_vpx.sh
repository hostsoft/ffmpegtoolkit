#!/bin/bash

function _install_vpx() {
	clear
	_file=""
	_package="Lib VPX"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "libvpx" ] && rm -rf "libvpx"
	git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
	cd libvpx
	./configure --prefix=$INSTALL_DIR --enable-shared --enable-pic --disable-examples --disable-unit-tests
	make -j $cpu
	make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_vpx

