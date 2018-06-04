#!/bin/bash

function _install_ffmpeg() {
	clear
	_file=""
	_package=""
	echo -e $RED"Installation of $_package ....... started"$RESET
	cd $SOURCE_DIR/
	rm -vrf ffmpeg*
	git clone -b 'n3.37' --single-branch --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
	cd ffmpeg/
	ldconfig
        export LD_LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
        export LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
        export CPATH=/usr/local/ffmpegtoolkit/include:/usr/include/:usr/local/include:$CPATH
	export PKG_CONFIG_LIBDIR=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig/
	./configure --prefix=$INSTALL_DIR \
	--pkg-config-flags="--static" \
	--extra-libs=-lpthread \
	--enable-gpl --enable-shared --enable-nonfree \
	--enable-pthreads  --enable-libopencore-amrnb --enable-libopencore-amrwb \
	--enable-libmp3lame --enable-libvpx --enable-libfdk-aac --enable-libfreetype \
	--enable-libtheora --enable-libvorbis  --enable-libx264 --enable-libx265 --enable-libxvid \
	--enable-postproc --enable-swscale --enable-avfilter --enable-libass --enable-runtime-cpudetect \
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
