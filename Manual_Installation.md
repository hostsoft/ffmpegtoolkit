

echo root:test123456 |sudo chpasswd root
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart




yum install -y wget python3
#sudo update-alternatives --config python3
#sudo alternatives --set python /usr/bin/python3
pip3 install meson ninja


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
export PKG_CONFIG_PATH=/tmp/medka-sdk/build/__bin/release/:/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib64/pkgconfig/:/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib64/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig



systemctl daemon-reload
ldconfig


LIBMFX_VERSION=1.35
cd /opt
wget https://github.com/lu-zero/mfx_dispatch/archive/refs/tags/${LIBMFX_VERSION}.tar.gz
tar xfz ${LIBMFX_VERSION}.tar.gz
cd mfx_dispatch-${LIBMFX_VERSION}
autoreconf -i
./configure --prefix=${INSTALL_DIR}
make
make install

find / -name "libmfx.pc"
/usr/lib/pkgconfig/libmfx.pc
/usr/local/lib/pkgconfig/libmfx.pc
/usr/local/ffmpegtoolkit/lib/pkgconfig/libmfx.pc

find / -name "libmfx.a"
/usr/lib/libmfx.a
/usr/local/lib/libmfx.a

/usr/lib64/libmfx.a
/usr/local/ffmpegtoolkit/lib/libmfx.a

rm -rf /usr/lib/libmfx.*
rm -rf /usr/local/lib/libmfx.*

ln -sf /usr/local/ffmpegtoolkit/lib/libmfx.a /usr/local/lib/libmfx.a
ln -sf /usr/local/ffmpegtoolkit/lib/libmfx.a /usr/local/lib/libmfx.a

cd /opt/ffmpegtoolkit/src
git clone https://github.com/oneapi-src/oneVPL
git clone https://github.com/oneapi-src/oneVPL-intel-gpu


cd /opt/ffmpegtoolkit/src
[[ -d "ffmpeg" ]] && rm -rf "ffmpeg";
git clone https://github.com/FFmpeg/FFmpeg ffmpeg
cd ffmpeg
./configure \
--prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin \
--pkg-config-flags="--static" \
--extra-libs=-lpthread \
--extra-libs=-lm \
--extra-cflags="-I/usr/local/include -I/usr/local/cuda/include -I/include -I/usr/local/ffmpegtoolkit/include -I/tmp/medka-sdk/build/__bin/release" \
--extra-ldflags="-L/usr/local/lib -L/usr/local/cuda/lib64 -L/usr/local/ffmpegtoolkit/lib -L/usr/local/ffmpegtoolkit/lib64 -L/tmp/medka-sdk/build/__bin/release/" \
--enable-cross-compile \
--disable-debug \
--enable-fontconfig \
--enable-gray \
--enable-gpl \
--enable-version3 \
--enable-nonfree \
--enable-runtime-cpudetect \
--enable-shared \
--enable-pthreads \
--enable-libopencore-amrnb \
--enable-libopencore-amrwb \
--enable-libsoxr \
--enable-libmp3lame \
--enable-libfdk-aac \
--enable-libdav1d \
--enable-libkvazaar \
--enable-libmfx \
--enable-vaapi \
--enable-opencl \
--enable-libfreetype \
--enable-libfribidi \
--enable-libzimg \
--enable-libopus \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libx264 \
--enable-libx265 \
--enable-libaom \
--enable-libxvid \
--enable-libwebp \
--enable-postproc \
--enable-swscale \
--enable-avfilter \
--enable-libass \
--enable-libaribb24 \
--enable-libxml2
make
make install

cd /opt/ffmpegtoolkit/src

make tools/qt-faststart
\cp -Rp tools/qt-faststart ${INSTALL_DIR}/bin/
ldconfig


--enable-cuvid \
--enable-libnpp \
--enable-nvenc \
--enable-nvdec \


# Version
https://github.com/intel/libva/releases
https://github.com/intel/gmmlib/tags
https://github.com/intel/media-driver/tags
https://github.com/Intel-Media-SDK/MediaSDK/releases


## https://airensoft.gitbook.io/ovenmediaengine/transcoding/gpu-usage/manual-installation




/usr/sbin/getenforce
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
sed -i s/SELINUX=permissive/SELINUX=disabled/g /etc/selinux/config
setenforce 0

cat >/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo "fastestmirror=1">>/etc/dnf/dnf.conf
sudo dnf update -y

export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/ffmpegtoolkit/lib:/usr/lib:/usr/local/lib:$LIBRARY_PATH
export CPATH=/include:/usr/local/ffmpegtoolkit/include:/usr/include/:/usr/local/include:$CPATH
export CMAKE_INCLUDE_PATH=/include:/usr/local/ffmpegtoolkit/include:/usr/include/:/usr/local/include:$CPATH
export PKG_CONFIG_LIBDIR=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib64/pkgconfig/:/lib/pkgconfig/
export PKG_CONFIG_PATH=/usr/share/pkgconfig/:/usr/lib64/pkgconfig/:/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/:/usr/local/lib64/pkgconfig/:/lib/pkgconfig/:/usr/local/ffmpegtoolkit/lib64/pkgconfig/:/usr/local/ffmpegtoolkit/lib/pkgconfig


cd /opt
dnf install -y epel-release
dnf config-manager --set-enabled powertools
dnf install -y wget tar xz tinyxml2 mediainfo libmediainfo bc unzip screen sshfs
dnf install -y ImageMagick ImageMagick-devel libwebp
dnf install -y screen unzip fuse fuse-common sshfs

yum install -y \
gcc gcc-c++ git libgcc glib2 bzip2 xz unzip make cmake automake autoconf patch ruby ncurses ncurses-devel mercurial hg neon expat expat-devel alsa-lib \
zlib zlib-devel libjpeg libjpeg-devel libpng libpng-devel gd gd-devel gettext freetype freetype-devel ImageMagick ImageMagick-devel \
libstdc++ libstdc++-devel numactl numactl-devel mediainfo re2c giflib-devel giflib libtiff libtiff-devel libtool libxml2 libxml2-devel \
subversion doxygen SDL-devel SDL2 SDL2-devel freeglut-devel openssl-devel fribidi-devel fribidi libffi libffi-devel \
redhat-lsb-core libdrm-devel libX11-devel libXi-devel opencl-headers ocl-icd ocl-icd-devel \
cmake3 libpciaccess-devel intel-gpu-tools ocl-icd-* gmp-devel libxslt-devel libxslt xmlto jansson-devel \
mesa-filesystem libwayland-cursor wayland-devel libwayland-egl



sudo ln -sf /usr/lib64/libOpenCL.so.1 /usr/lib/libOpenCL.so
sudo ln -sf /usr/bin/cmake3 /usr/bin/cmake

#### yum install -y libva-devel


INSTALL_DIR='/usr/local/ffmpegtoolkit'

## Wayland
cd /opt
WAYLAND_VERSION=1.20.0
wget https://wayland.freedesktop.org/releases/wayland-${WAYLAND_VERSION}.tar.xz
tar xf wayland-${WAYLAND_VERSION}.tar.xz
cd wayland-${WAYLAND_VERSION}
meson build/ --prefix=${INSTALL_DIR}
ninja -C build/ install

## LibVA
cd /opt
wget https://github.com/intel/libva/releases/download/2.14.0/libva-2.14.0.tar.bz2
tar xvjf libva-2.14.0.tar.bz2
cd libva-2.14.0
autoreconf -i
./configure --prefix=${INSTALL_DIR}
make -j 18
make install

## Libva-utils
cd /opt
wget https://github.com/intel/libva-utils/archive/refs/tags/2.14.0.tar.gz
tar xfz 2.14.0.tar.gz
cd libva-utils-2.14.0
./autogen.sh
autoreconf -i
./configure --prefix="${INSTALL_DIR}"
make -j$(nproc)
sudo make install

## Intel VAAPI Driver
cd /opt/ffmpegtoolkit/src
wget https://github.com/intel/intel-vaapi-driver/archive/refs/tags/2.4.1.tar.gz
tar xfz 2.4.1.tar.gz
cd intel-vaapi-driver-2.4.1
./autogen.sh
autoreconf -i
./configure --prefix=${INSTALL_DIR}
make
make install

## Gmmlib
PREFIX=${INSTALL_DIR} && \
TEMP_PATH=/tmp && \
GMMLIB_VERSION=22.1.2 && \
DIR=${TEMP_PATH}/gmmlib && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLf https://github.com/intel/gmmlib/archive/refs/tags/intel-gmmlib-${GMMLIB_VERSION}.tar.gz | tar -xz --strip-components=1 && \
mkdir -p ${DIR}/build && \
cd ${DIR}/build && \
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" .. && \
make -j$(nproc) && \
sudo make install && \
rm -rf ${DIR}


修改环境变量增加搜索路径
CMAKE_INCLUDE_PATH 和CMAKE_LIBRARY_PATH
-DCMAKE_INCLUDE_PATH=/usr/local/ffmpegtoolkit/include \

# Intel Media Driver
cd /opt
wget https://github.com/intel/media-driver/archive/refs/tags/intel-media-22.3.1.tar.gz
tar xfz intel-media-22.3.1.tar.gz
#cd /opt/media-driver-intel-media-22.3.1
mkdir build_media
cd build_media
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}  cmake3 ../media-driver-intel-media-22.3.1 -DCMAKE_INSTALL_PREFIX=${PREFIX}
make -j"$(nproc)"
make install

## Intel Media SDK
export LIBVA_DRIVERS_PATH=${PREFIX}/lib
export LIBVA_DRIVER_NAME=iHD
cd /opt
INTEL_MEDIA_DRIVER_VERSION=22.3.1
git clone https://github.com/Intel-Media-SDK/MediaSDK msdk
cd msdk
mkdir build && cd build
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}  cmake3 .. -DCMAKE_INSTALL_PREFIX=${PREFIX}
make -j"$(nproc)"
make install

cd /opt/msdk/build






