#!/bin/bash
#FFMPEG installation script

#  Copyright (C) 2007-2014 Sherin.co.in. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/subversion'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='subversion-1.2.0.tar.gz'
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
   	cd subversion-1.2.0/
   	./configure --prefix=$INSTALL_DDIR 
	make -j$cpu
	make install
fi
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
