#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/x264'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='x264'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
ldconfig
cd $INSTALL_SDIR
echo "Removing old source"
rm -vrf $INSTALL_SDIR/x264-snapshot*
wget https://download.videolan.org/x264/snapshots/last_stable_x264.tar.bz2
tar xvjf last_stable_x264.tar.bz2
cd x264-snapshot-*-stable/
./configure --prefix=$INSTALL_DDIR --enable-shared --enable-pic --disable-asm
make -j $cpu
make install
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
