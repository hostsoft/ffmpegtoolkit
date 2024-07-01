#!/usr/bin/env bash

_Install_nv_header() {
  local name='Nv Coder Header';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [ -d nv-codec-headers ] && rm -rf "nv-codec-headers"
  git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
  cd nv-codec-headers
  make && make install
  popd > /dev/null
}

_Install_nv_cuda() {
  local name='CUDA';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
  sudo dnf clean all
  #sudo dnf -y module install nvidia-driver:latest-dkms
  sudo dnf -y install cuda
  popd > /dev/null
}

# Tools Package
_Install_nasm() {
  local name='NSAM';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "nasm-${NASM_VER}.tar.gz" && -d nasm-${NASM_VER} ]]; then
    rm -rf nasm-${NASM_VER} nasm-${NASM_VER}.tar.gz
  fi
  wget https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VER}/nasm-${NASM_VER}.tar.gz
  tar xzvf nasm-${NASM_VER}.tar.gz
  cd nasm-${NASM_VER}
  ./configure
  make -j VERBOSE=1
  make install
  make distclean
  popd > /dev/null
}

_Install_yasm() {
  local name='YSAM';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "yasm-${YASM_VER}.tar.gz" && -d yasm-${YASM_VER} ]]; then
    rm -rf nasm-${YASM_VER} nasm-${YASM_VER}.tar.gz
  fi
  wget http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VER}.tar.gz
  tar xfz yasm-${YASM_VER}.tar.gz
  cd yasm-${YASM_VER}
  ./configure
  make
  make install
  popd > /dev/null
}

# Subtitle Module
_Install_libsrt() {
  local name='LibSrt';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "srt" ]] && rm -rf "srt";
  git clone --depth 1 https://github.com/Haivision/srt.git
  cd srt
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED:bool=ON
  make
  make install
  popd > /dev/null
}

_Install_libass() {
  local name='Libass';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";

  if [[ -f "libass-${LIBASS_VER}.tar.gz" && -d libass-${LIBASS_VER}/ ]]; then
    rm -rf libass-${LIBASS_VER} libass-${LIBASS_VER}.tar.gz
  fi

  wget https://github.com/libass/libass/releases/download/${LIBASS_VER}/libass-${LIBASS_VER}.tar.gz
  tar -xvzf libass-${LIBASS_VER}.tar.gz
  cd libass-${LIBASS_VER}
  ./configure --prefix=${INSTALL_DIR}
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libaribb24() {
  local name='';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "aribb24" ]] && rm -rf "aribb24";
  git clone https://github.com/nkoriyama/aribb24
  cd aribb24
  ./bootstrap
  ./configure --prefix=${INSTALL_DIR}
  make
  make install
  popd > /dev/null
}

# Encoder or Decoder
_Install_libvid() {
  local name='LIB VID';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "vid.stab" ]] && rm -rf "vid.stab";
  git clone --depth 1 https://github.com/georgmartius/vid.stab
  cd vid.stab
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED:bool=ON
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_liba52dec() {
  local name='Lib A52Dec';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "a52dec-${LIBA52DEC_VER}" ]] && rm -rf a52dec-${LIBA52DEC_VER}
  wget https://ftp.osuosl.org/pub/blfs/conglomeration/a52dec/a52dec-${LIBA52DEC_VER}.tar.gz
  tar xfz a52dec-${LIBA52DEC_VER}.tar.gz
  cd a52dec-${LIBA52DEC_VER}
  ./bootstrap
  ./configure --prefix=${INSTALL_DIR} --enable-shared 'CFLAGS=-fPIC'
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libamrwb() {
  local name='AMRWB';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";

  if [[ -f "amrwb-${AMRWB_VER}.tar.gz" && -d amrwb-${AMRWB_VER} ]]; then
    rm -rf amrwb-*
  fi
  wget http://www.penguin.cz/~utx/ftp/amr/amrwb-${AMRWB_VER}.tar.bz2
  tar -xvjf amrwb-${AMRWB_VER}.tar.bz2
  cd amrwb-${AMRWB_VER}
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  popd > /dev/null
}

_Install_libamrnb() {
  local name='AMRNB';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "amrnb-${AMRNB_VER}" && -d amrnb-${AMRNB_VER} ]]; then
    rm -rf  amrnb-${AMRNB_VER}
  fi
  wget http://www.penguin.cz/~utx/ftp/amr/amrnb-${AMRNB_VER}.tar.bz2
  tar -xvjf amrnb-${AMRNB_VER}.tar.bz2
  cd amrnb-${AMRNB_VER}
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make -j $cpu
  make install
  #make distclean
  popd > /dev/null
}

_Install_libao() {
  local name='Lib Ao';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libao-${LIBAO_VER}.tar.gz" && -d libao-${LIBAO_VER} ]]; then
    rm -rf libao-*
  fi
  wget -4 http://downloads.xiph.org/releases/ao/libao-${LIBAO_VER}.tar.gz
  tar -xvzf libao-${LIBAO_VER}.tar.gz
  cd libao-${LIBAO_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  #make distclean
  popd > /dev/null
}

_Install_libilbc() {
  local name='libilbc';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "libilbc" ]] && rm -rf "libilbc";
  git clone --depth=1 https://github.com/TimothyGu/libilbc.git
  git submodule update --init
  cmake .
  #cmake -DBUILD_SHARED_LIBS=OFF .
  cmake --build .
  # ffmpeg -f pulse -i default -f s16le -filter:a "pan=1|c0=c0+c1,aresample=8000" sample.pcm
  #ninja install or make install
  popd > /dev/null
}

_Install_libgsm() {
  local name='libgsm';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "srt" ]] && rm -rf "srt";
  git clone https://github.com/timothytylee/libgsm
  cd libgsm
  ./configure
  make
  make install
  popd > /dev/null
}

_Install_libcelt() {
  local name='CELT';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "celt" ]] && rm -rf "celt";
  git clone https://gitlab.xiph.org/xiph/celt
  cd celt
  ./autogen.sh
  ./configure --enable-fixed
  make
  make install
  popd > /dev/null
}

_Install_libfaad2() {
  local name='';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "faad2" ]] && rm -rf "faad2";
  rm -rf faad2
  git clone https://github.com/dsvensson/faad2
  cd faad2/
  ./bootstrap
  ./configure --with-mpeg4ip --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libaacenc() {
  local name='Lib AACENC';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "vo-aacenc" ]] && rm -rf "vo-aacenc";
  git clone https://github.com/mstorsjo/vo-aacenc
  cd vo-aacenc/
  autoreconf -fiv
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libwmf() {
  local name='LIB WMF';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libwmf-${LIBWMF_VER}.tar.gz" && -d libwmf-${LIBWMF_VER} ]]; then
    rm -rf libwmf-${LIBWMF_VER} libwmf-${LIBWMF_VER}.tar.gz
  fi
  wget -c https://sourceforge.net/projects/wvware/files/libwmf/0.2.8.4/libwmf-${LIBWMF_VER}.tar.gz/download -O libwmf-${LIBWMF_VER}.tar.gz
  tar -xvzf libwmf-${LIBWMF_VER}.tar.gz
  cd libwmf-${LIBWMF_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean

  popd > /dev/null
}

_Install_libspeex() {
  local name='Speex';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "speex-${SPEEX_VER}.tar.gz" && -d speex-${SPEEX_VER} ]]; then
    rm -rf speex-${SPEEX_VER}.tar.gz speex-${SPEEX_VER}
  fi
  wget http://downloads.xiph.org/releases/speex/speex-1.2.0.tar.gz
  tar -xvzf speex-${SPEEX_VER}.tar.gz
  cd speex-${SPEEX_VER}
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libflac() {
  local name='FLAC';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "flac-${FLAC_VER}.tar.xz" && -d flac-${FLAC_VER} ]]; then
    rm -rf flac-${FLAC_VER}.tar.xz flac-${FLAC_VER}
  fi
  wget https://ftp.osuosl.org/pub/xiph/releases/flac/flac-${FLAC_VER}.tar.xz
  tar -xJf flac-${FLAC_VER}.tar.xz
  cd flac-${FLAC_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_liblame() {
  local name='LAME';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "lame-${LAME_VER}.tar.gz" && -d lame-${LAME_VER} ]]; then
    rm -rf lame-${LAME_VER}.tar.gz lame-${LAME_VER}
  fi
  wget https://ftp.osuosl.org/pub/blfs/conglomeration/lame/lame-${LAME_VER}.tar.gz
  tar -zxvf lame-${LAME_VER}.tar.gz
  cd lame-${LAME_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin --enable-mp3x --enable-mp3rtp --enable-nasm --enable-pic
  make -j $cpu
  make install
  make distclean
  popd > /dev/null
}

_Install_libfdkaac() {
  local name='FDKAAC';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "fdk-aac" ]] && rm -rf "fdkaac";
  git clone https://github.com/mstorsjo/fdk-aac
  cd fdk-aac
  autoreconf -fiv
  ./configure 'CFLAGS=-fPIC' --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libopus() {
  local name='OPUS';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "opus-${OPUS_VER}.tar.gz" && -d opus-${OPUS_VER} ]]; then
    rm -rf opus-${OPUS_VER}.tar.gz opus-${OPUS_VER}
  fi
  wget https://archive.mozilla.org/pub/opus/opus-${OPUS_VER}.tar.gz
  tar -xvzf opus-${OPUS_VER}.tar.gz
  cd opus-${OPUS_VER}/
  ./configure --enable-shared --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libogg() {
  local name='';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libogg-${OGG_VER}.tar.gz" && -d libogg-${OGG_VER} ]]; then
    rm -rf libogg-${OGG_VER}.tar.gz libogg-${OGG_VER}
  fi
  wget https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-${OGG_VER}.tar.gz
  tar -xvzf libogg-${OGG_VER}.tar.gz
  cd libogg-${OGG_VER}/
  ./configure  --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_liboggz() {
  local name='oggz';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "liboggz-${LIBOGGZ_VER}.tar.gz" && -d liboggz-${LIBOGGZ_VER} ]]; then
    rm -rf liboggz-${LIBOGGZ_VER}.tar.gz liboggz-${LIBOGGZ_VER}
  fi
  wget http://downloads.xiph.org/releases/liboggz/liboggz-${LIBOGGZ_VER}.tar.gz
  tar -xvzf liboggz-${LIBOGGZ_VER}.tar.gz
  cd liboggz-${LIBOGGZ_VER}/
  ./configure  --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libvorbis() {
  local name='VORBIS';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libvorbis-${LIBVORBIS_VER}.tar.gz" && -d libvorbis-${LIBVORBIS_VER} ]]; then
    rm -rf libvorbis-${LIBVORBIS_VER} libvorbis-${LIBVORBIS_VER}.tar.gz
  fi
  wget http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VER}.tar.gz
  tar -xvzf libvorbis-${LIBVORBIS_VER}.tar.gz
  cd libvorbis-${LIBVORBIS_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libvorbistools() {
  local name='vorbis tools';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "vorbis-tools-${VORBIS_VER}.tar.gz" && -d vorbis-tools-${VORBIS_VER} ]]; then
    rm -rf vorbis-tools-${VORBIS_VER} vorbis-tools-${VORBIS_VER}.tar.gz
  fi
  wget http://downloads.xiph.org/releases/vorbis/vorbis-tools-${VORBIS_VER}.tar.gz
  tar -xvzf vorbis-tools-${VORBIS_VER}.tar.gz
  cd vorbis-tools-${VORBIS_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libamrwbenc() {
  local name='amrwbenc';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "vo-amrwbenc-${AMRWBENC_VER}.tar.gz" && -d vo-amrwbenc-${AMRWBENC_VER} ]]; then
    rm -rf vo-amrwbenc-${AMRWBENC_VER} vo-amrwbenc-${AMRWBENC_VER}.tar.gz
  fi
  wget -c https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/vo-amrwbenc-${AMRWBENC_VER}.tar.gz/download -O vo-amrwbenc-${AMRWBENC_VER}.tar.gz
  tar xfz vo-amrwbenc-${AMRWBENC_VER}.tar.gz
  cd vo-amrwbenc-${AMRWBENC_VER}
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libopencoreamr() {
  local name='amr';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";

  if [[ -f "opencore-amr-${OPENCOREAMR_VER}.tar.gz" && -d "opencore-amr-${OPENCOREAMR_VER}" ]]; then
    rm -rf opencore-amr-${OPENCOREAMR_VER}.tar.gz opencore-amr-${OPENCOREAMR_VER}
  fi
  wget -c https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-${OPENCOREAMR_VER}.tar.gz/download -O opencore-amr-${OPENCOREAMR_VER}.tar.gz
  tar -zxvf opencore-amr-${OPENCOREAMR_VER}.tar.gz
  cd opencore-amr-${OPENCOREAMR_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make -j $cpu
  make install
  #make distclean
  popd > /dev/null
}

_Install_libtheora() {
  local name='libtheora';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libtheora-${LIBTHEORA_VER}.zip" && -d libtheora-${LIBTHEORA_VER} ]]; then
    rm -rf libtheora-${LIBTHEORA_VER}.zip libtheora-${LIBTHEORA_VER}
  fi
  wget -4 https://ftp.osuosl.org/pub/xiph/releases/theora/libtheora-${LIBTHEORA_VER}.zip
  unzip -o libtheora-${LIBTHEORA_VER}.zip
  cd libtheora-${LIBTHEORA_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libneroaacenc() {
  local name='neroaacenc';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "nero" ]] && rm -rf "nero";
  wget http://techdata.mirror.gtcomm.net/sysadmin/ffmpeg-avs/NeroDigitalAudio.zip
  unzip -o NeroDigitalAudio.zip -d nero
  cd nero/linux
  install -D -m755 neroAacEnc ${INSTALL_DIR}/bin/
  install -D -m755 neroAacDec ${INSTALL_DIR}/bin/
  popd > /dev/null
}

_Install_libfishsound() {
  local name='Lib Fishsound';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libfishsound-${LIBFISHSOUND_VER}.tar.gz" && -d libfishsound-${LIBFISHSOUND_VER} ]]; then
    rm -rf libfishsound-*
  fi
  wget -4 http://downloads.xiph.org/releases/libfishsound/libfishsound-${LIBFISHSOUND_VER}.tar.gz
  tar -xvzf libfishsound-${LIBFISHSOUND_VER}.tar.gz
  cd libfishsound-${LIBFISHSOUND_VER}/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libsoxr() {
  local name='SOXR';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "soxr-${LIBSOXR_VER}-Source.tar.xz" && -d soxr-${LIBSOXR_VER}-Source ]]; then
    rm -rf soxr-*
  fi
  wget https://download.videolan.org/contrib/soxr/soxr-${LIBSOXR_VER}-Source.tar.xz
  tar -xJf soxr-${LIBSOXR_VER}-Source.tar.xz
  cd soxr-${LIBSOXR_VER}-Source
  cmake3 -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED:bool=ON
  make
  make install
  popd > /dev/null
}

_Install_libkvazaar() {
  local name='kvazaar';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "kvazaar" ]] && rm -rf "kvazaar";
  git clone --depth 1 https://github.com/ultravideo/kvazaar.git
  cd kvazaar
  ./autogen.sh
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  popd > /dev/null
}

_Install_libdav1d() {
  local name='libdav1d';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "dav1d" ]] && rm -rf "dav1d";
  git clone --depth 1 https://code.videolan.org/videolan/dav1d.git
  mkdir dav1d/build && cd dav1d/build
  meson ..
  ninja
  #DESTDIR=${INSTALL_DIR}
  ninja install
  popd > /dev/null
}

_Install_libwebp() {
  local name='Libwebp';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "libwebp-${LIBWEBP_VER}.tar.gz" && -d "libwebp-${LIBWEBP_VER}" ]]; then
    rm -rf libwebp*
  fi
  wget -4 https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${LIBWEBP_VER}.tar.gz
  tar xfz libwebp-${LIBWEBP_VER}.tar.gz
  cd libwebp-${LIBWEBP_VER}
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin \
  --disable-wic \
  --enable-libwebpmux \
  --enable-libwebpdemux \
  --enable-libwebpdecoder \
  --enable-libwebpextras \
  --enable-swap-16bit-csp
  make
  make install
  popd > /dev/null
}

_Install_libzimg() {
  local name='LibZIMG';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "zimg" ]] && rm -rf "zimg";
  git clone https://github.com/sekrit-twc/zimg
  cd zimg
  git checkout tags/release-3.0.4 -b main
  ./autogen.sh
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make && make install
  popd > /dev/null
}

_Install_libdavs2() {
  local name='DAVS2';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "srt" ]] && rm -rf "srt";
  git clone https://github.com/pkuvcl/davs2
  cd build/linux
  ./configure
  make
  make install
  popd > /dev/null
}

# BUILD_SHARED_LIBS=1
_Install_libuavs3d() {
  local name='UAVS3D';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "srt" ]] && rm -rf "srt";
  git clone https://github.com/uavs3/uavs3d
  mkdir build/linux
  cd build/linux && cmake ../..
  make && make install

  popd > /dev/null
}

_Install_libvpx() {
  local name='LIBVPX';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "libvpx" ]] && rm -rf "libvpx";
  git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
  cd libvpx
  #./configure ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
  # --prefix=$BUILD_DIR --enable-pic --enable-vp9-highbitdepth --as=yasm --disable-examples --disable-unit-tests --disable-install-docs
  #./configure --prefix=$BUILD_DIR --enable-pic --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
  ./configure --prefix=${INSTALL_DIR} --enable-pic --disable-examples --enable-runtime-cpu-detect --enable-vp9 --enable-vp8 \
  --enable-postproc --enable-vp9-postproc --enable-multi-res-encoding --enable-webm-io --enable-better-hw-compatibility --enable-vp9-highbitdepth --enable-onthefly-bitpacking --enable-realtime-only
  make
  make install
  popd > /dev/null
}

_Install_libxvid() {
  local name='XVID';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  if [[ -f "xvidcore-${XVIDCORE_VER}.tar.gz" && -d "xvidcore-${XVIDCORE_VER}" ]]; then
    rm -rf xvidcore-*
  fi
  wget https://downloads.xvid.com/downloads/xvidcore-${XVIDCORE_VER}.tar.gz
  tar -xvzf xvidcore-${XVIDCORE_VER}.tar.gz
  cd xvidcore/build/generic/
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libaom() {
  local name='AOM';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  rm -rf aom*
  git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom
  mkdir -p aom_build
  cd aom_build
  PATH="/usr/local/bin:$PATH" cmake3 -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED:bool=ON -DBUILD_SHARED_LIBS=ON -DENABLE_NASM=on ../aom && \
  PATH="/usr/local/bin:$PATH" make && \
  make install
  popd > /dev/null
}

_Install_libx264() {
  local name='X264';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "x264" ]] && rm -rf "x264";
  if [ "$(uname -m)" = "x86_64" ]; then
    ARCHOPTS="--enable-pic"
   else
    ARCHOPTS=""
  fi
  git clone https://code.videolan.org/videolan/x264.git
  cd x264
  ./configure --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin --enable-static $ARCHOPTS
  make
  make install
  make distclean
  popd > /dev/null
}

_Install_libx265() {
  local name='X265';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "x265_git" ]] && rm -rf "x265_git";
  git clone --branch stable --depth 2 https://bitbucket.org/multicoreware/x265_git
  cd x265_git/build/linux
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" -DENABLE_SHARED:bool=ON ../../source
  make
  make install
  #make distclean
  popd > /dev/null
}

_Install_ffmpeg() {
  local name='FFMPEG';
  pushd ${SOURCE_DIR}/src > /dev/null
  echo -e "${CBLUE} Install ${name} ${CEND}";
  [[ -d "ffmpeg" ]] && rm -rf "ffmpeg";
  #git clone https://git.ffmpeg.org/ffmpeg.git
  git clone https://github.com/FFmpeg/FFmpeg ffmpeg
  cd ffmpeg
  ./configure \
  --prefix=${INSTALL_DIR} --bindir=${INSTALL_DIR}/bin \
  --pkg-config-flags="--static" \
  --extra-libs=-lpthread \
  --extra-libs=-lm \
  --extra-cflags="-I/usr/local/include -I/usr/local/cuda/include -I/include -I/usr/local/ffmpegtoolkit/include" \
  --extra-ldflags="-L/usr/local/lib -L/usr/local/cuda/lib64 -L/usr/local/ffmpegtoolkit/lib -L/usr/local/ffmpegtoolkit/lib64" \
  --enable-cross-compile \
  --disable-debug \
  --enable-fontconfig \
  --enable-gray \
  --enable-gpl \
  --enable-version3 \
  --enable-cuvid \
  --enable-libnpp \
  --enable-nvenc \
  --enable-nvdec \
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
  #make distclean
  make tools/qt-faststart
  \cp -Rp tools/qt-faststart ${INSTALL_DIR}/bin/
  ldconfig
  popd > /dev/null
}

#--enable-libcelt \
#--enable-libilbc \
#--enable-libgsm \
#--enable-libuavs3d \

#--enable-libmfx \
#--enable-vaapi \
#--enable-opencl \
