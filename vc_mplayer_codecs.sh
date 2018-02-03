#!/bin/bash

function _install_mplayer_codecs() {
	clear
	_file="all-20110131.tar.bz2"
	_package="MPlayer Codecs"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.mplayerhq.hu/MPlayer/releases/codecs//$_file
	fi
	tar -xvjf $_file
	chown -R root.root all-20110131/
	mkdir -pv $INSTALL_DIR/lib/codecs/
	cp -vrf all-20110131/* $INSTALL_DIR/lib/codecs/
	chmod -R 755 /usr/local/ffmpegtoolkit/lib/codecs/

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_mplayer_codecs

