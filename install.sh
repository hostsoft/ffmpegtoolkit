#!/usr/bin/env bash
#################################################################################
# FFMPEG Toolkit Installation Scripts
# Many credits to GPL for the package repo
#
# Author : Matt Xu  (2018-2021)
# Package installers copyright IDCLayer.COM (2018-2021) where applicable.
# All other work copyright InfoCube  (2018)
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

SOURCE_URL='http://download.mirror.url' # Not use at this times
SOURCE_DIR='/opt/ffmpegtoolkit'
INSTALL_DIR='/usr/local/ffmpegtoolkit'
cpu=$(cat "/proc/cpuinfo" | grep "processor" | wc -l)
TMPDIR=~/tmp
export SOURCE_URL
export SOURCE_DIR
export INSTALL_DIR
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
export CPATH=/include:/usr/local/ffmpegtoolkit/include:/usr/include/:/usr/local/include:$CPATH
export PKG_CONFIG_LIBDIR=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib64/pkgconfig/:/lib/pkgconfig/
export PKG_CONFIG_PATH=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib64/pkgconfig/:/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib64/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig

time=$(date +"%s")
# start Time
startTime=$(date +%s)

if [[ $EUID -ne 0 ]]; then
  echo "ffmpeg package setup requires user to be root. su or sudo -s and run again ..."
  exit 1
fi

mkdir -p /opt/ffmpegtoolkit/src
mkdir -p /usr/local/ffmpegtoolkit/{bin,lib,share,include,src}

## Check OS Versions
_OSVER=`rpm --eval '%{centos_ver}'`
printf "\e[32m [Success]:\e[0m Your OS Versions is : ${_OSVER}  \n"
if [ "$_OSVER" -eq 8 ]; then
    T="sudo /usr/bin/dnf"
else
    T="sudo /usr/bin/yum"
fi

## Scripts Current Path
install_dir=$(dirname "$(readlink -f $0)")
pushd ${install_dir} >/dev/null
. ./versions.txt
. ./include.sh
. ./function.sh

### 判断是不是首次运行
if [ ! -e ~/.ffmpegtookit ]; then
  echo -e "First Time Run , Pre Define Process...."
  if [ -e "/etc/yum.conf" ]; then
    # Prerequisites
    echo "${CMSG}Installing Dependencies Packages...${CEND}"
    ${T} config-manager --set-enabled powertools
    dnf config-manager --set-enabled powertools
    yum install -y yum-utils
    yum install -y epel-release
    REQPKGS=(epel-release)
    REQPKGS+=(gcc gcc-c++ git subversion libgcc glib2 bzip2 xz unzip make cmake automake autoconf patch ruby ncurses ncurses-devel mercurial hg neon expat expat-devel alsa-lib)
    REQPKGS+=(zlib zlib-devel libjpeg libjpeg-devel libpng libpng-devel gd gd-devel gettext freetype freetype-devel ImageMagick ImageMagick-devel)
    REQPKGS+=(libstdc++ libstdc++-devel numactl numactl-devel mediainfo giflib libtiff libtiff-devel libtool libxml2 libxml2-devel re2c giflib-devel doxygen)
    REQPKGS+=(libmediainfo SDL-devel freeglut-devel openssl-devel fribidi-devel fribidi libva-devel libwayland-cursor libwayland-egl wayland-devel)
    for pkg in "${REQPKGS[@]}"; do
        if ${T} -q list installed "${pkg}" > /dev/null 2>&1; then
            printf "${CRED}Skip:\e[0m [${pkg}] is already installed \n${CEND}"
        else
            ${T} install "${pkg}" -q -y && printf "${CGREEN}Success:\e[0m [${pkg}] successfully installed \n"
        fi
    done
    # Dependencies
    printf "\e[36m Info:\e[0m Disable Selinux ...... \n"
    /usr/sbin/getenforce
    sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
    sed -i s/SELINUX=permissive/SELINUX=disabled/g /etc/selinux/config
    setenforce 0
    #active Python
    sudo /usr/sbin/alternatives --set python /usr/bin/python3
    pip3 install meson
    pip3 install ninja
    # Start Sync Time
    systemctl enable chronyd
  fi
  touch ~/.ffmpegtookit
fi

cat >/etc/ld.so.conf.d/ffmpegtoolkit.conf <<EOF
/usr/local/lib
/usr/local/lib64
/usr/local/cuda/lib64
/usr/local/ffmpegtoolkit/lib
/usr/local/ffmpegtoolkit/lib64
/usr/local/cuda-11.1/targets/x86_64-linux/lib
EOF
ldconfig -vvvv

#ARG_NUM START
ARG_NUM=$#
TEMP=`getopt -o hvV --long help,version,mode: -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && show_help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      show_help; exit 0
      ;;
    -v|-V|--version)
      version; exit 0
      ;;
    --mode)
      mode=$2; shift 2
      [[ ! ${mode} =~ ^[1-3]$ ]] && { echo "${CWARNING}mode input error! Please only input number 1~3${CEND}"; exit 1; }
      ;;
    --memcached)
      memcached_flag=y; shift 1
      [ -e "${memcached_install_dir}/bin/memcached" ] && { echo "${CWARNING}memcached-server already installed! ${CEND}"; unset memcached_flag; }
      ;;
    --ssh_port)
      ssh_port=$2; shift 2
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

if [ ${ARG_NUM} == 0 ]; then
  #Select Mode
  while :; do echo
    echo 'Please Select FFMPEG Install Mode: '
    echo -e "\t${CMSG}1${CEND}. [SW] CPU Mode (Default)"
    echo -e "\t${CMSG}2${CEND}. [HW] Intel GPU Mode"
    echo -e "\t${CMSG}3${CEND}. [HW] Nvidia GPU Mode"
    read -e -p "Please input a number:(Default 1 press Enter) " mode
    mode=${mode:-1}
    if [[ ! ${mode} =~ ^[1-3]$ ]]; then
      echo "${CWARNING}input error! Please only input number 1~3${CEND}"
    else
      break
    fi
  done
fi
# ARG_NUM END


# Install Process
if [ "${memcached_flag}" == 'y' ]; then
  echo -e "";
fi

_Install_nv_header | tee -a ${install_dir}/installer.log
_Install_nv_cuda | tee -a ${install_dir}/installer.log
_Install_nasm | tee -a ${install_dir}/installer.log
_Install_yasm | tee -a ${install_dir}/installer.log
_Install_libsrt | tee -a ${install_dir}/installer.log
_Install_libass | tee -a ${install_dir}/installer.log
_Install_libaribb24 | tee -a ${install_dir}/installer.log
_Install_liba52dec | tee -a ${install_dir}/installer.log
_Install_libaacenc | tee -a ${install_dir}/installer.log
_Install_libamrnb | tee -a ${install_dir}/installer.log
_Install_libamrwb | tee -a ${install_dir}/installer.log
_Install_libamrwbenc | tee -a ${install_dir}/installer.log
_Install_libopencoreamr | tee -a ${install_dir}/installer.log
_Install_libao | tee -a ${install_dir}/installer.log
_Install_libdav1d | tee -a ${install_dir}/installer.log
_Install_libfaad2 | tee -a ${install_dir}/installer.log
_Install_libfdkaac | tee -a ${install_dir}/installer.log
_Install_libflac | tee -a ${install_dir}/installer.log
_Install_libfishsound | tee -a ${install_dir}/installer.log
_Install_libkvazaar | tee -a ${install_dir}/installer.log
_Install_liblame | tee -a ${install_dir}/installer.log
_Install_libneroaacenc | tee -a ${install_dir}/installer.log
_Install_libogg | tee -a ${install_dir}/installer.log
_Install_liboggz | tee -a ${install_dir}/installer.log
_Install_libopus | tee -a ${install_dir}/installer.log
_Install_libsoxr | tee -a ${install_dir}/installer.log
_Install_libspeex | tee -a ${install_dir}/installer.log
_Install_libcelt | tee -a ${install_dir}/installer.log
_Install_libgsm | tee -a ${install_dir}/installer.log
_Install_libtheora | tee -a ${install_dir}/installer.log
_Install_libvid | tee -a ${install_dir}/installer.log
_Install_libvorbis | tee -a ${install_dir}/installer.log
_Install_libvorbistools | tee -a ${install_dir}/installer.log
_Install_libzimg | tee -a ${install_dir}/installer.log
_Install_libwebp | tee -a ${install_dir}/installer.log
_Install_libwmf | tee -a ${install_dir}/installer.log
_Install_libuavs3d | tee -a ${install_dir}/installer.log
_Install_libxvid | tee -a ${install_dir}/installer.log
_Install_libvpx | tee -a ${install_dir}/installer.log
_Install_libaom | tee -a ${install_dir}/installer.log
_Install_libx264 | tee -a ${install_dir}/installer.log
_Install_libx265 | tee -a ${install_dir}/installer.log
_Install_ffmpeg | tee -a ${install_dir}/installer.log

echo -e "Created Soft Links"
ln -sf /usr/local/ffmpegtoolkit/bin/ffmpeg /bin/ffmpeg
ln -sf /usr/local/ffmpegtoolkit/bin/ffprobe /bin/ffprobe
ln -sf /usr/local/ffmpegtoolkit/bin/qt-faststart /bin/qt-faststart
ln -sf /usr/local/ffmpegtoolkit/bin/neroAacEnc /bin/neroAacEnc
ln -sf /usr/local/ffmpegtoolkit/bin/x264 /usr/local/bin/x264
ln -sf /usr/local/ffmpegtoolkit/bin/x265 /usr/local/bin/x265
#ldconfig -vvvv
which {ffmpeg,ffprobe,qt-faststart,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc,identify,convert,composite}
endTime=$(date +%s)
((installTime = ($endTime - $startTime) / 60))
echo "####################Congratulations########################"
echo "Deployed total time: ${CQUESTION}${installTime}${CEND} minutes"
echo -e "Install Done"!
