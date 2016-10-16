#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='https://github.com/gpac/gpac/archive'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='v0.6.1.tar.gz'
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

#Fix lastest bug
#git clone https://github.com/gpac/gpac.git
#cd gpac
wget https://github.com/gpac/gpac/archive/v0.6.1.tar.gz
tar xfz v0.6.1.tar.gz
cd gpac-0.6.1
./configure --prefix=/usr/local/cpffmpeg/ --extra-cflags=-I/usr/local/cpffmpeg/include/ \
--extra-ldflags=-L/usr/local/cpffmpeg/lib  --disable-wx --static-mp4box
make 
make install
ln -sf /usr/local/cpffmpeg/bin/MP4Box /usr/local/bin/MP4Box
ln -sf /usr/local/cpffmpeg/bin/MP4Box /usr/bin/MP4Box
echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2


# if install fail try this.
# wget -O /etc/yum.repos.d/epel-handbrake.repo http://negativo17.org/repos/epel-handbrake.repo
# yum install gpac -y
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-0.6.1-3.el7.x86_64.rpm
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-libs-0.6.1-3.el7.x86_64.rpm
# rpm -ivh http://negativo17.org/repos/HandBrake/epel-7/x86_64/gpac-devel-0.6.1-3.el7.x86_64.rpm

