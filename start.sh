#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
export LD_LIBRARY_PATH=/usr/local/cpffmpeg/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/cpffmpeg/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
export CPATH=/usr/local/cpffmpeg/include:/usr/include/:usr/local/include:$CPATH

#presetup
sh presetup.sh

if [ -e "/etc/yum.conf" ];then
        echo "Installer EPEL Release ........"
	yum install -y epel-release
        echo "Ensuring required RPM ........"
        yum install -y \
        gcc gcc-c++ libgcc unzip make cmake automake autoconf patch git ruby ncurses ncurses-devel mercurial hg neon expat expat-devel alsa-lib \
        zlib zlib-devel libjpeg libjpeg-devel libpng libpng-devel gd gd-devel gettext freetype freetype-devel ImageMagick ImageMagick-devel \
        libstdc++ libstdc++-devel numactl numactl-devel opus opus-devel mediainfo re2c giflib-devel giflib libtiff libtiff-devel libtool  libxml libxml2 libxml2-devel \
        #yum install samba-common* apr-util -y
	rpm -e alsa-lib --nodeps
	export ARCH=$(arch)
fi

if [ -e "/etc/csf/csf.conf" ];then
	csf -x
fi

if [ -e "/etc/debian_version" ];then
	echo "Ensuring Debian packages ....."
	apt-get install gcc libgd-dev gettext libfreetype6 libfreetype6-dev libpng-dev libstdc++-dev \
		libtiff-dev libtool libxml2 libxml2-dev mercurial automake autoconf libncurses-dev ncurses-dev patch \
		make git subversion -y
fi
#Git client
sh git.sh

if [ -e "/usr/bin/git" ]; then
        echo " "
else
        echo " "
        echo " "
        echo -e $RED"   Git client  installation Failed. Git is required for ffmpeg and mplayer . Please install it and run this script"$RESET
        echo " "
        echo " "
        exit
fi 

#Subversion client
mkdir -pv /usr/local/cpffmpeg/bin/
sh subversion.sh

if [ -e "/usr/local/cpffmpeg/bin/svn" ]; then
        echo " "
else
        echo " "
        echo " "
        echo -e $RED"   Svn  client  installation Failed.Svn  is required for mplayer . Please install it and run this script"$RESET
        echo " "
        echo " "
        exit
fi 

cd $INSTALL_SDIR/
wget ftp://ftp6.nero.com/tools/NeroDigitalAudio.zip
unzip NeroDigitalAudio.zip -d nero
cd nero/linux
install -D -m755 neroAacEnc /usr/bin

cat >>/etc/ld.so.conf <<EOF
/usr/lib
/usr/lib64
/usr/local/lib
/usr/local/lib64
/usr/local/cpffmpeg/lib
/usr/local/cpffmpeg/lib64
EOF
ldconfig

#addon
#sh presetup2.sh
#free type
sh freetype.sh
#libwmf
sh libwmf.sh
#ruby
sh ruby.sh
#flvtool
sh flvtool.sh
#lame
sh lame.sh
#codecs
sh codecs.sh
#libogg
sh libogg.sh
#libvorbis
sh libvorbis.sh
#vorbistools
sh vorbistools.sh
#libtheora
sh libtheora.sh
#fdk-aac
sh fdkaac.sh
# voaacenc
sh voaacenc.sh
# voamrwbenc
sh voamrwbenc.sh
# libspeex
sh libspeex.sh
# libflac
sh libflac.sh
# libao
sh libao.sh
# uriparser
sh uriparser.sh
# libxspf
#sh libxspf.sh
# liboggz
sh liboggz.sh
# libfishsound
#sh libfishsound.sh
# yamdi
sh yamdi.sh
#amrnb
sh amrnb.sh
#amrwb
sh amrwb.sh
#openamr
sh libopencoreamr.sh
#liba52
sh liba52.sh 
#facc
sh facc.sh
#faad2
sh faad2.sh
#yasm
sh yasm.sh
#nasm
sh nasm.sh
#xvid
sh xvid.sh
#vpx
sh libvpx.sh
#x264
sh x264.sh
#x265
sh x265.sh
#re2c
#sh re2c.sh
#Mplayer
sh mplayer.sh
if [ -e "/usr/local/cpffmpeg/bin/mplayer" ]; then
        echo " "
else
        echo " "
        echo " "
        echo -e $RED"   Mplayer installation Failed :( ,  please contact  professional support sales@syslint.com"$RESET
        echo " "
        echo " "
        exit
fi

#ffmpeg
sh ffmpeg.sh
if [ -e "/usr/local/cpffmpeg/bin/ffmpeg" ]; then
        echo " "
else
        echo " "
        echo " "
        echo -e $RED"   FFMPEG installation Failed :( ,  please contact  professional support sales@syslint.com"$RESET
        echo " "
        echo " "
        exit
fi

# preset 
sh preset.sh
#Rebuilding Mplayer
sh mplayer.sh
if [ -e "/usr/local/cpffmpeg/bin/mplayer" ]; then
        echo " "
else
        echo " "
        echo " "
        echo -e $RED"   Mplayer installation Failed :( , please contact  professional support sales@syslint.com"$RESET
        echo " "
        echo " "
        exit
fi
#Mp4Boxh
sh mp4box.sh
#post
sh post.sh

