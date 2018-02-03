#!/bin/bash

function _install_ffmpeg() {
	clear
	_file=""
	_package=""
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	rm -vrf ffmpeg*
	git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
	cd ffmpeg/
	ldconfig
	./configure --prefix=$INSTALL_DIR \
	--pkg-config-flags="--static" \
	--extra-libs=-lpthread \
	--enable-gpl --enable-shared --enable-nonfree \
	--enable-pthreads  --enable-libopencore-amrnb --enable-libopencore-amrwb \
	--enable-libmp3lame --enable-libvpx --enable-libfdk-aac --enable-libfreetype \
	--enable-libtheora --enable-libvorbis  --enable-libx264 --enable-libx265 --enable-libxvid \
	--enable-postproc --enable-swscale --enable-avfilter --enable-runtime-cpudetect \
	--extra-cflags=-I/usr/local/ffmpegtoolkit/include/ --extra-ldflags=-L/usr/local/ffmpegtoolkit/lib \
	--enable-version3
	make -j $cpu
	make tools/qt-faststart
	make install
	cp -vf tools/qt-faststart /usr/local/ffmpegtoolkit/bin/

	echo -e $RED"Installation of $_package ....... Completed"$RESET
	cd $SOURCE_DIR/
}

_install_ffmpeg
