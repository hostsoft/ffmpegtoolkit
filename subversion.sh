#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://www-us.apache.org/dist/subversion'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='subversion-1.9.4.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
subversion=$_package
ldconfig
cd $INSTALL_SDIR
echo "removing old source"
   rm -vrf $INSTALL_SDIR/subversion*
if [ -e "/etc/yum.conf" ];then
	yum -y install subversion
fi
if [ -e "/usr/bin/svn" ]; then
	ln -sf /usr/bin/svn /usr/local/cpffmpeg/bin/svn
else
   	wget $SOURCE_URL/$_package
   	tar -zxvf $_package
   	cd subversion-1.9.4/
   	./configure --prefix=$INSTALL_DDIR 
	make -j$cpu
	make install
fi
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
