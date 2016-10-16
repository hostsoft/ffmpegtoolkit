#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='https://cache.ruby-lang.org/pub/ruby/2.3'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='ruby-2.3.1.tar.gz' 
ruby='ruby-2.3.1.tar.gz'
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
   	cd ruby-2.3.1/
   	./configure --prefix=$INSTALL_DDIR
	make 
	make install
fi
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2
