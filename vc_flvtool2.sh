#!/bin/bash

function _install_flvtool2() {
	clear
	_file=""
	_package="FlvTool2"
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	[ -d "flvtool2" ] && rm -rf "flvtool2"
	git clone https://github.com/unnu/flvtool2
	cd flvtool2/
	ruby setup.rb config
	ruby setup.rb setup
	ruby setup.rb install
	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_flvtool2
