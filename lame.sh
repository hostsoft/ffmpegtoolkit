#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/lame'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='lame-3.99.5.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
lame_source=$_package
ldconfig
cd $INSTALL_SDIR
echo "removing old source"
   rm -vrf lame*
   wget $SOURCE_URL/$lame_source
   tar -zxvf $_package
   cd lame-3.99.5/
   ./configure --prefix=$INSTALL_DDIR --enable-mp3x --enable-mp3rtp

make -j$cpu
make install

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
