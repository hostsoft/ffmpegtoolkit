#!/bin/bash

function _install_aom() {
	clear
	_file=""
	_package="aom"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "aom" ] && rm -rf "aom"
  git clone https://aomedia.googlesource.com/aom && \
  cmake ./aom && \
  make && \
  make install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_aom
