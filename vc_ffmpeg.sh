 #!/bin/bash
 
 function _install_ffmpeg() {
 	clear
 	_file=""
 	_package=""
 	echo -e $RED"Installation of $_package ....... started"$RESET
 	cd $SOURCE_DIR/
 	rm -vrf ffmpeg*
 	git clone -b 'n3.2.10' --single-branch --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
 	cd ffmpeg/
 	ldconfig
         export LD_LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
         export LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
         export CPATH=/usr/local/ffmpegtoolkit/include:/usr/include/:usr/local/include:$CPATH
 	export PKG_CONFIG_LIBDIR=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig/
	./configure --prefix=$INSTALL_DIR \
	--pkg-config-flags="--static" \
	--extra-libs=-lpthread \
	--enable-gpl --disable-stripping --enable-avresample --enable-avisynth --enable-gnutls --enable-ladspa \
	--enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libebur128 \
	--enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme \
	--enable-libgsm --enable-libmp3lame --enable-libopenjpeg --enable-libopenmpt --enable-libopus \
	--enable-libpulse --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr \
	--enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx \
	--enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxvid --enable-libzmq --enable-libzvbi \
	--enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libiec61883 \
	--enable-chromaprint --enable-frei0r --enable-libopencv --enable-libx264 --enable-shared \
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
