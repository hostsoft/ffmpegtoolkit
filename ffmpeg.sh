#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/ffmpeg'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='FFMPEG'
clear
sleep 2
ffmpeg_source=$_package
ldconfig
echo -e $RED"Installation of $_package ....... started"$RESET
cd $INSTALL_SDIR
echo "Removing old source"

rm -vrf ffmpeg*
git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
cd ffmpeg/
export PKG_CONFIG_PATH=/usr/local/cpffmpeg/lib/pkgconfig
ldconfig
./configure --prefix=$INSTALL_DDIR \
--pkg-config-flags="--static" \
--enable-gpl --enable-shared --enable-nonfree \
--enable-pthreads  --enable-libopencore-amrnb \
--enable-libopencore-amrwb  --enable-libmp3lame --enable-libvpx \
--enable-libtheora --enable-libvorbis  --enable-libx264 --enable-libx265 --enable-libxvid \
--enable-libfdk-aac --enable-libfreetype \
--enable-postproc --enable-swscale --enable-avfilter --enable-runtime-cpudetect \
--extra-cflags=-I/usr/local/cpffmpeg/include/ --extra-ldflags=-L/usr/local/cpffmpeg/lib \
 --enable-version3

make -j4
make tools/qt-faststart
make install
cp -vf tools/qt-faststart /usr/local/cpffmpeg/bin/
ln -sf /usr/local/cpffmpeg/bin/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/cpffmpeg/bin/ffmpeg /usr/bin/ffmpeg
ln -sf /usr/local/cpffmpeg/bin/ffprobe /usr/local/bin/ffprobe
ln -sf /usr/local/cpffmpeg/bin/ffprobe /usr/bin/ffprobe
ln -sf /usr/local/cpffmpeg/bin/qt-faststart /usr/local/bin/qt-faststart
ln -sf /usr/local/cpffmpeg/bin/qt-faststart /usr/bin/qt-faststart
ln -sf /usr/bin/flvtool2 /usr/local/bin/flvtool2
ln -sf /usr/bin/mediainfo   /usr/local/bin/mediainfo
ln -sf /usr/bin/neroAacEnc   /usr/local/bin/neroAacEnc
ldconfig
/usr/bin/ffmpeg -formats

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
