#!/bin/bash
#################################################################################
# FFMPEG Installation Scripts
# Many credits to GPL for the package repo
# 
# Author : Matt Xu  (2018)
# Package installers copyright IDCLayer.COM (2018) where applicable.
# All other work copyright InfoCube  (2018)
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

SOURCE_URL='http://download.latest.com'
SOURCE_DIR='/opt/ffmpegtoolkit_source'
INSTALL_DIR='/usr/local/ffmpegtoolkit'
cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
TMPDIR=$HOME/tmp

export SOURCE_URL='http://download.latest.com'  ## Not Used At This Time
export SOURCE_DIR='/opt/ffmpegtoolkit_source'
export INSTALL_DIR='/usr/local/ffmpegtoolkit'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export LD_LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
export CPATH=/usr/local/ffmpegtoolkit/include:/usr/include/:usr/local/include:$CPATH
export PKG_CONFIG_LIBDIR=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig/

time=$(date +"%s")

if [[ $EUID -ne 0 ]]; then
  echo "ffmpeg package setup requires user to be root. su or sudo -s and run again ..."
  exit 1
fi

if [ -e "/etc/yum.conf" ];then
        echo "Installer EPEL Release ........"
	yum install -y epel-release
        echo "Ensuring required RPM ........"
        yum install -y \
        gcc gcc-c++ git libgcc glib glib2 bzip2 xz unzip make cmake automake autoconf patch ruby ncurses ncurses-devel mercurial hg neon expat expat-devel alsa-lib \
        zlib zlib-devel libjpeg libjpeg-devel libpng libpng-devel gd gd-devel gettext freetype freetype-devel ImageMagick ImageMagick-devel \
        libstdc++ libstdc++-devel numactl numactl-devel mediainfo re2c giflib-devel giflib libtiff libtiff-devel libtool libxml2 libxml2-devel \
	subversion doxygen SDL-devel freeglut-devel openssl-devel openjpeg-devel
	export ARCH=$(arch)
fi

mkdir -p /opt/ffmpegtoolkit_source
mkdir -p /usr/local/ffmpegtoolkit/{bin,lib}
mkdir -p $TMPDIR
cd /opt/ffmpegtoolkit_source

cat >>/etc/ld.so.conf <<EOF
/usr/lib
/usr/lib64
/usr/local/lib
/usr/local/lib64
/usr/local/ffmpegtoolkit/lib
/usr/local/ffmpegtoolkit/lib64
EOF
ldconfig

sh tools_freetype.sh
sh tools_ynasm.sh

sh vc_flvtool2.sh
sh vc_yamdi.sh
sh vc_mp4box.sh

########################    sh ac_libfacc.sh ## Removed faac in ffmpeg 2.8
sh ac_libwmf.sh
sh ac_liblame.sh
sh ac_libogg.sh
sh ac_liboggz.sh
sh ac_libamrnbwb.sh
sh ac_libopencoreamr.sh
sh ac_liba52.sh
sh ac_libflac.sh
sh ac_libfaad2.sh
sh ac_libfdkaac.sh
sh ac_libvoaacenc.sh
sh ac_libvoamrwbenc.sh
sh ac_libneroaacenc.sh
sh ac_libao.sh
sh ac_libspeex.sh
sh ac_libvorbistools.sh
sh ac_libvorbis.sh
sh ac_libfishsound.sh
sh ac_libopus.sh

#### Video Package ####
sh vc_libtheora.sh
sh vc_xvid.sh
sh vc_x264.sh
sh vc_x265.sh
sh vc_mplayer_codecs.sh
sh vc_mplayer.sh
sh vc_ffmpeg.sh

echo "Create Links"
ln -sf /usr/local/ffmpegtoolkit/bin/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/ffmpegtoolkit/bin/ffprobe /usr/local/bin/ffprobe
ln -sf /usr/local/ffmpegtoolkit/bin/qt-faststart /usr/local/bin/qt-faststart
ln -sf /usr/local/ffmpegtoolkit/bin/mplayer /usr/local/bin/mplayer
ln -sf /usr/local/ffmpegtoolkit/bin/mencoder /usr/local/bin/mencoder
ln -sf /usr/local/ffmpegtoolkit/bin/MP4Box /usr/local/bin/MP4Box
ln -sf /usr/local/ffmpegtoolkit/bin/yamdi /usr/local/bin/yamdi
ln -sf /usr/local/ffmpegtoolkit/bin/neroAacEnc /usr/local/bin/neroAacEnc
ln -sf /usr/local/ffmpegtoolkit/bin/x264 /usr/local/bin/x264
ln -sf /usr/local/ffmpegtoolkit/bin/x265 /usr/local/bin/x265
ln -sf /usr/bin/flvtool2 /usr/local/bin/flvtool2
ln -sf /usr/bin/mediainfo /usr/local/bin/mediainfo
ln -sf /usr/bin/flvtool2 /usr/local/ffmpegtoolkit/bin/flvtool2
ln -sf /usr/bin/mediainfo /usr/local/ffmpegtoolkit/bin/mediainfo

echo "All is Done"

echo "That's Path" 
which {ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc,x264,x265}

echo "ImageMagick Command Path"
which {identify,convert}

### /opt/ffmpegtoolkit_source

