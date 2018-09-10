#!/bin/bash

function _install_mplayer() {
	clear
	_file="MPlayer-1.3.0.tar.xz"
	_package="mPlayer"
	echo -e $RED"Installation of $_package ....... started"$RESET

	cd $SOURCE_DIR/
	rm -rf mplayer*

	if [ -f "$_file" ]
	then
		echo "$_file found, Skip Downloads"
	else
		echo "$_file not found, Try Downloading......"
	        wget http://www.mplayerhq.hu/MPlayer/releases//$_file
	fi
	tar xJfv MPlayer-1.3.0.tar.xz
	cd MPlayer-1.3.0
	./configure --prefix=$INSTALL_DIR --codecsdir=$INSTALL_DIR/lib/codecs/   \
	--extra-cflags=-I/usr/local/ffmpegtoolkit/include/ --extra-ldflags=-L/usr/local/ffmpegtoolkit/lib \
	--with-freetype-config=/usr/local/ffmpegtoolkit/bin/freetype-config   --yasm=/usr/local/ffmpegtoolkit/bin/yasm
	make -j $cpu
	make install
	mkdir -p $INSTALL_DIR/etc/mplayer/
	cp -f etc/codecs.conf $INSTALL_DIR/etc/mplayer/codecs.conf

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_mplayer
