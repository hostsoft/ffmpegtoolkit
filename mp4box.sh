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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/gpac'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='gpac-full-0.5.0.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
cd $INSTALL_SDIR/
rm -rf gpac gpac*
if [ -e "/etc/yum.conf" ];then
yum -y install freetype-devel SDL-devel freeglut-devel openssl-devel
fi

export PKG_CONFIG_PATH=/usr/local/cpffmpeg/lib/pkgconfig
ldconfig

git clone https://github.com/gpac/gpac.git
cd gpac
./configure --prefix=/usr/local/cpffmpeg/ --extra-cflags=-I/usr/local/cpffmpeg/include/ \
--extra-ldflags=-L/usr/local/cpffmpeg/lib  --disable-wx --static-mp4box
make 
make install
ln -sf /usr/local/cpffmpeg/bin/MP4Box /usr/local/bin/MP4Box
ln -sf /usr/local/cpffmpeg/bin/MP4Box /usr/bin/MP4Box
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2


#
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-0.6.1-3.el7.x86_64.rpm
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-libs-0.6.1-3.el7.x86_64.rpm
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-devel-0.6.1-3.el7.x86_64.rpm

