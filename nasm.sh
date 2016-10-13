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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/nasm'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='nasm-2.06rc1.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
ldconfig
cd $INSTALL_SDIR
echo "Removing old source"
if [ -e "/etc/yum.conf" ];then
yum -y install nasm
fi
if [ -e "/usr/bin/nasm" ]; then
	ln -sf /usr/bin/nasm  /usr/local/cpffmpeg/bin/nasm
else
	rm -vrf nasm*
	wget $SOURCE_URL/$_package
	tar -xvzf $_package
	cd  nasm-2.06rc1/
	./configure --prefix=/usr/local/cpffmpeg/ 
	make -j$cpu
	make install
	ln -sf /usr/local/cpffmpeg/bin/nasm /usr/local/bin/nasm
fi
ldconfig
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
