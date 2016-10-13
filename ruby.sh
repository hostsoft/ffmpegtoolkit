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
SOURCE_URL='http://mirror.ffmpeginstaller.com/source/ruby'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='ruby-1.8.7.tar.gz' 
ruby='ruby-1.8.7.tar.gz'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET
ldconfig
if [ -e "/etc/yum.conf" ];then
yum -y install ruby
fi
if [ -e "/usr/bin/ruby" ]; then
	ln -sf /usr/bin/ruby  /usr/local/cpffmpeg/bin/ruby
elif  [ -e "/usr/local/cpanel/scripts/installruby" ]; then
	/usr/local/cpanel/scripts/installruby
else
	cd $INSTALL_SDIR
	echo "removing old source"
   	rm -vrf ruby*
   	wget $SOURCE_URL/$ruby
   	tar -xvzf  $ruby
   	cd ruby-1.8.7/
   	./configure --prefix=$INSTALL_DDIR
	make 
	make install
fi
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
