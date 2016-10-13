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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/libogg'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='libogg-1.3.1.tar.gz'
echo -e $RED"Installation of $_package ....... started"$RESET
libogg_source=$_package
ldconfig
    cd $INSTALL_SDIR
echo "removing old source"
   	rm -vrf libogg*
   	wget $SOURCE_URL/$libogg_source
   	tar -xvzf $_package
   	cd libogg-1.3.1/
	./configure --prefix=$INSTALL_DDIR
	make -j$cpu
	make install

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
