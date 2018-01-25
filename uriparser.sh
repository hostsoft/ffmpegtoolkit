#!/bin/bash
#FFMPEG installation script
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/uriparser'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='uriparser-0.8.0.tar.bz2'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
cd $INSTALL_SDIR/
rm -rf uriparser*
yum -y install unzip doxygen graphviz-devel graphviz expat expat-devel qt-devel qt5-qhelpgenerator
wget https://nchc.dl.sourceforge.net/project/uriparser/Sources/0.8.4/uriparser-0.8.4.zip
unzip uriparser-0.8.4.zip
./configure  --prefix=/usr/local/cpffmpeg --disable-test
make 
make install
ldconfig
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
