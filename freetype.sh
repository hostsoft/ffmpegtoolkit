#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://download.savannah.gnu.org/releases/freetype/'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='freetype-2.7.tar.gz'
clear
echo -e $RED"Installation of $_package ....... started"$RESET
subversion=$_package
ldconfig
cd $INSTALL_SDIR
echo "removing old source"
   rm -vrf freetype*
   wget $SOURCE_URL/$_package
   tar -zxvf $_package
   cd freetype-2.7/
   ./configure --prefix=$INSTALL_DDIR 

make -j$cpu
make install

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
