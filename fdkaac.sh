#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='https://github.com/mstorsjo/fdk-aac/archive'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='v0.1.4.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET

cd $INSTALL_SDIR/
rm -rf fdk-aac*
wget $SOURCE_URL/$_package
tar -xvzf $_package
cd fdk-aac-0.1.4/
./autogen.sh
./configure  --prefix=$INSTALL_DDIR
make -j$cpu
make install

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
