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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/flvtool2'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='flvtool2-1.0.6.tgz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
flvtool_source=$_package
#install flvtool
ldconfig
   cd $INSTALL_SDIR
echo "removing old source"
   rm -vrf flvtool*
   wget $SOURCE_URL/$flvtool_source
   tar -zxvf  $_package
   cd flvtool2-1.0.6/
   /usr/local/cpffmpeg/bin/ruby setup.rb config
   /usr/local/cpffmpeg/bin/ruby setup.rb setup
   /usr/local/cpffmpeg/bin/ruby setup.rb install
   ln -s /usr/local/cpffmpeg/bin/flvtool2 /usr/local/bin/flvtool2
   ln -s /usr/local/cpffmpeg/bin/flvtool2 /usr/bin/flvtool2
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
