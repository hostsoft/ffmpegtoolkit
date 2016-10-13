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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/mplayer'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='mplayer.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET

cd $INSTALL_SDIR/
rm -rf mplayer*
#wget $SOURCE_URL/$_package
#tar -xvzf $_package
wget http://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.3.0.tar.xz
tar xJfv MPlayer-1.3.0.tar.xz
cd MPlayer-1.3.0
./configure --prefix=$INSTALL_DDIR  --codecsdir=$INSTALL_DDIR/lib/codecs/   \
		--extra-cflags=-I/usr/local/cpffmpeg/include/ --extra-ldflags=-L/usr/local/cpffmpeg/lib \
		--with-freetype-config=/usr/local/cpffmpeg/bin/freetype-config   --yasm=/usr/local/cpffmpeg/bin/yasm
make -j$cpu
make install
cp -f etc/codecs.conf $INSTALL_DDIR/etc/mplayer/codecs.conf
ln -sf /usr/local/cpffmpeg/bin/mplayer /usr/local/bin/mplayer
ln -sf /usr/local/cpffmpeg/bin/mplayer /usr/bin/mplayer
ln -sf /usr/local/cpffmpeg/bin/mencoder /usr/bin/mencoder
ln -sf /usr/local/cpffmpeg/bin/mencoder /usr/local/bin/mencoder

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
