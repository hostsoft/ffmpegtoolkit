#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/libfishsound'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='libfishsound-1.0.0.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET

cd $INSTALL_SDIR/
rm -rf libfish*
wget $SOURCE_URL/$_package
tar -xvzf $_package
cd libfishsound-1.0.0/
./configure --prefix=$INSTALL_DDIR --with-vorbis=/usr/local/cpffmpeg  --with-FLAC=/usr/local/cpffmpeg  --with-speex=/usr/local/cpffmpeg
make -j$cpu
make install
ldconfig
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
