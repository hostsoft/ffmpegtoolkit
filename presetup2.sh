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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package=' '
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET

cd $INSTALL_SDIR/
yum install -y mediainfo mercurial cmake \
opus opus-devel libvpx libvpx-devel  numactl numactl-devel \
re2c

wget ftp://ftp6.nero.com/tools/NeroDigitalAudio.zip
unzip NeroDigitalAudio.zip -d nero
cd nero/linux
install -D -m755 neroAacEnc /usr/bin

cd $INSTALL_SDIR/
rm -rf x265
hg clone https://bitbucket.org/multicoreware/x265
cd x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$INSTALL_DDIR -DENABLE_SHARED:bool=off ../../source
make
make install

cd $INSTALL_SDIR/
rm -rf libvpx
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix=$INSTALL_DDIR --enable-shared --enable-pic
make
make install
make clean

#cd $INSTALL_SDIR/
#wget -O http://negativo17.org/repos/epel-handbrake.repo
#wget -O HandBrake-0.10.5.tar.bz2 https://handbrake.fr/rotation.php?file=HandBrake-0.10.5.tar.bz2
#tar -jxvf HandBrake-0.10.5.tar.bz2
#cd HandBrake-0.10.5
#./configure --launch --disable-gtk
#cp build/HandBrakeCLI /usr/local/bin/

echo "/usr/local/cpffmpeg/lib/">>/etc/ld.so.conf
ldconfig

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2




