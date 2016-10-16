#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/git'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='Git'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
if [ -e "/etc/yum.conf" ];then
	yum -y install git
fi
if [ -e "/usr/bin/git" ]; then
	mkdir -pv /usr/local/cpffmpeg/bin/
	ln -sf /usr/bin/git  /usr/local/cpffmpeg/bin/git
else
	cd $INSTALL_SDIR/
	rm -rf git*
	wget https://github.com/git/git/archive/v2.10.1.tar.gz
	tar -xzf git-2.10.1.tar.gz
	cd git-2.10.1/
	./configure --prefix=/usr/
	make -j$cpu
	make install
fi

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
