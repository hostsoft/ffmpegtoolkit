


pkg-config --modversion libmfx


PREFIX=${INSTALL_DIR} && \
TEMP_PATH=/tmp && \
LIBVA_VERSION=2.14.0 && \
DIR=${TEMP_PATH}/libva && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLf https://github.com/intel/libva/archive/refs/tags/${LIBVA_VERSION}.tar.gz | tar -xz --strip-components=1 && \
./autogen.sh --prefix="${PREFIX}" && \
make -j$(nproc) && \
sudo make install && \
rm -rf ${DIR}




#./configure --disable-documentation
#./configure --disable-documentation --prefix=${INSTALL_DIR} --libdir=/usr/lib64
#make
#make install


PREFIX=${INSTALL_DIR} && \
TEMP_PATH=/tmp && \
&& \
DIR_IMD=${TEMP_PATH}/media-driver && \
mkdir -p ${DIR_IMD} && \
cd ${DIR_IMD} && \
curl -sLf https://github.com/intel/media-driver/archive/refs/tags/intel-media-${INTEL_MEDIA_DRIVER_VERSION}.tar.gz  | tar -xz --strip-components=1 && \
DIR_GMMLIB=${TEMP_PATH}/gmmlib && \
mkdir -p ${DIR_GMMLIB} && \
cd ${DIR_GMMLIB} && \
curl -sLf https://github.com/intel/gmmlib/archive/refs/tags/intel-gmmlib-${GMMLIB_VERSION}.tar.gz | tar -xz --strip-components=1 && \
DIR=${TEMP_PATH}/build && \
mkdir -p ${DIR} && \
cd ${DIR} && \
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH} cmake3 \
$DIR_IMD \
-DBUILD_TYPE=release \
-DBS_DIR_GMMLIB="$DIR_GMMLIB/Source/GmmLib" \
-DBS_DIR_COMMON=$DIR_GMMLIB/Source/Common \
-DBS_DIR_INC=$DIR_GMMLIB/Source/inc \
-DBS_DIR_MEDIA=$DIR_IMD \
-DCMAKE_INSTALL_PREFIX=${PREFIX} \
-DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
-DINSTALL_DRIVER_SYSCONF=OFF \
-DLIBVA_DRIVERS_PATH=${PREFIX}/lib/dri && make && \
sudo make -j$(nproc) install && \
rm -rf ${DIR} && \
rm -rf ${DIR_IMD} && \
rm -rf ${DIR_GMMLIB}




PREFIX=${INSTALL_DIR} && \
TEMP_PATH=/tmp && \
INTEL_MEDIA_SDK_VERSION=22.3.0 && \
DIR=${TEMP_PATH}/medka-sdk && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLf https://github.com/Intel-Media-SDK/MediaSDK/archive/refs/tags/intel-mediasdk-${INTEL_MEDIA_SDK_VERSION}.tar.gz  | tar -xz --strip-components=1 && \
mkdir -p ${DIR}/build && \
cd ${DIR}/build && \
PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH} cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" .. && \
make -j$(nproc) && \
sudo make install && \
rm -rf ${DIR}

sudo dnf install -y 'dnf-command(config-manager)'
sudo dnf config-manager \
--add-repo \
https://repositories.intel.com/graphics/rhel/8.4/intel-graphics.repo

sudo dnf install \
intel-opencl \
intel-media intel-mediasdk \
level-zero intel-level-zero-gpu

