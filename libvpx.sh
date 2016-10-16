RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package='libvpx'
clear
sleep 2
echo -e $RED"Installation of $_package ....... started"$RESET

cd $INSTALL_SDIR/
rm -rf libvpx
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix=$INSTALL_DDIR --enable-shared --enable-pic
make
make install
make clean

echo -e $RED"Installation of $_package ....... Completed"$RESET
sleep 2

