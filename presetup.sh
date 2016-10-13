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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
#presetup
export TMPDIR=$HOME/tmp
echo -n "Removing useless libraries,please wait............."
rm -rf $INSTALL_SDIR
mkdir -p $INSTALL_SDIR

rm -rf /lib/liba52*
rm -rf /lib/libamr*
rm -rf /lib/libavcodec*
rm -rf /lib/libavformat*
rm -rf /lib/libavutil*
rm -rf /lib/libdha*
rm -rf /lib/libfaac*
rm -rf /lib/libfaad*
rm -rf /lib/libmp3lame*
rm -rf /lib/libmp4v2*
rm -rf /lib/libogg*
rm -rf /lib/libtheora*
rm -rf /lib/libvorbis*

rm -rf /usr/lib/liba52*
rm -rf /usr/lib/libamr*
rm -rf /usr/lib/libavcodec*
rm -rf /usr/lib/libavformat*
rm -rf /usr/lib/libavutil*
rm -rf /usr/lib/libdha*
rm -rf /usr/lib/libfaac*
rm -rf /usr/lib/libfaad*
rm -rf /usr/lib/libmp3lame*
rm -rf /usr/lib/libmp4v2*
rm -rf /usr/lib/libogg*
rm -rf /usr/lib/libtheora*
rm -rf /usr/lib/libvorbis*

rm -rf /usr/local/lib/liba52*
rm -rf /usr/local/lib/libamr*
rm -rf /usr/local/lib/libavcodec*
rm -rf /usr/local/lib/libavformat*
rm -rf /usr/local/lib/libavutil*
rm -rf /usr/local/lib/libdha*
rm -rf /usr/local/lib/libfaac*
rm -rf /usr/local/lib/libfaad*
rm -rf /usr/local/lib/libmp3lame*
rm -rf /usr/local/lib/libmp4v2*
rm -rf /usr/local/lib/libogg*
rm -rf /usr/local/lib/libtheora*
rm -rf /usr/local/lib/libvorbis*

unlink  /usr/bin/ffmpeg >/dev/null 2>&1
unlink /usr/local/bin/ffmpeg >/dev/null 2>&1
unlink /bin/mplayer >/dev/null 2>&1
unlink /usr/bin/mplayer >/dev/null 2>&1
unlink  /usr/local/bin/mplayer >/dev/null 2>&1
unlink /bin/mencoder >/dev/null 2>&1
unlink /usr/bin/mencoder  >/dev/null 2>&1
unlink  /usr/local/bin/mencoder >/dev/null 2>&1
unlink /bin/flvtool2 >/dev/null 2>&1
unlink /usr/bin/flvtool2 >/dev/null 2>&1
unlink  /usr/local/bin/flvtool2 >/dev/null 2>&1
rm -rf /usr/local/cpffmpeg
rm -rf $HOME/tmp
mkdir -p $HOME/tmp
echo -n ".......... done"
echo " "
echo "creating folders..........done"
echo -n "Creating ldd configurations "
cp -f ./ffmpeginstall.so.conf /etc/ld.so.conf.d/
echo -n ".......... done"
