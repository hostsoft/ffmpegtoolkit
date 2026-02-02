# FFmpeg Toolkit

Automated build system for FFmpeg with a comprehensive set of audio/video codecs and libraries. Supports Ubuntu/Debian and RHEL/Rocky/Alma Linux.

## Features

- **Full source build**: Compiles FFmpeg from source with 40+ codecs and libraries
- **Version control**: All component versions defined in `versions.txt` (Source of Truth)
- **Checkpointing**: Resumable builds via `.done_*` stamps; skips already-built modules
- **Multi-OS**: Ubuntu 22.04, Rocky Linux 9, and compatible distributions
- **Optional**: CUDA/NVENC, Intel QSV, static linking, PATH/ldconfig integration

## Clone & Deploy

```bash
cd /opt
# Clone repository
git clone https://github.com/wanyigroup/ffmpegtoolkit.git
cd ffmpegtoolkit
chmod +x -R ./
# 1. Install build dependencies (requires root)
sudo ./build.sh deps
# 2. Download all source packages
./build.sh fetch
# 3. Build (compiles to /opt/ffmpeg-toolkit by default)
./build.sh build
# 4. Symlink ffmpeg/ffprobe to /usr/local/bin (optional)
./build.sh --link
# 5. Register shared libraries (fix "cannot open shared object")
./build.sh ldconfig
# Verify
ffmpeg -version
```

## FFmpeg Build Output

After a successful build, `ffmpeg -version` shows:

```
ffmpeg version 8.0.1 Copyright (c) 2000-2025 the FFmpeg developers
built with gcc 11 (Ubuntu 11.4.0-1ubuntu1~22.04.2)
configuration: --prefix=/opt/ffmpeg-toolkit --pkg-config-flags=--static --extra-cflags=-I/opt/ffmpeg-toolkit/include --extra-ldflags='-L/opt/ffmpeg-toolkit/lib -L/opt/ffmpeg-toolkit/lib64' --extra-libs='-lstdc++ -lpthread -lm' --enable-gpl --enable-version3 --enable-static --enable-libx264 --enable-libx265 --enable-libvpx --enable-libaom --enable-libsvtav1 --enable-libopenh264 --enable-libvmaf --enable-libilbc --enable-libjxl --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libtheora --enable-libwebp --enable-libass --enable-libfreetype --enable-libfribidi --enable-libzimg --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvo-amrwbenc --enable-swscale --enable-avfilter --disable-debug --enable-runtime-cpudetect --enable-libfdk-aac --enable-nonfree
libavutil      60.  8.100 / 60.  8.100
libavcodec     62. 11.100 / 62. 11.100
libavformat    62.  3.100 / 62.  3.100
libavdevice    62.  1.100 / 62.  1.100
libavfilter    11.  4.100 / 11.  4.100
libswscale      9.  1.100 /  9.  1.100
libswresample   6.  1.100 /  6.  1.100
```

## Deployed Modules (versions.txt)

| Component | Version | Link | Description |
|-----------|---------|------|-------------|
| ffmpeg | 8.0.1 | https://ffmpeg.org/download.html | Main program |
| x264 | master | https://code.videolan.org/videolan/x264 | H.264 encoder |
| x265 | 4.1 | https://bitbucket.org/multicoreware/x265_git | HEVC/H.265 encoder |
| libvmaf | 3.0.0 | https://github.com/Netflix/vmaf/releases | Video quality assessment |
| openssl | 3.5.5 | https://www.openssl.org/source/ | SSL/TLS |
| nv-codec-headers | 13.0.19.0 | https://github.com/FFmpeg/nv-codec-headers/releases | NVIDIA headers |
| nasm | 3.01 | https://www.nasm.us/ | Assembler |
| yasm | 1.3.0 | https://yasm.tortall.net/ | Assembler |
| libass | 0.17.4 | https://github.com/libass/libass/releases | ASS/SSA subtitles |
| a52dec | 0.7.4 | https://liba52.sourceforge.io/ | AC3/A52 decode |
| libao | 1.2.0 | https://xiph.org/ao/ | Audio output |
| libwmf | 0.2.13 | https://github.com/caolanm/libwmf | WMF image |
| speex | 1.2.1 | https://speex.org/ | Speech codec |
| flac | 1.5.0 | https://xiph.org/flac/ | Lossless audio |
| lame | 3.100 | https://lame.sourceforge.io/ | MP3 encoder |
| opus | 1.6.1 | https://downloads.xiph.org/releases/opus/ | Modern audio |
| ogg (libogg) | 1.3.6 | https://xiph.org/ogg/ | Ogg container |
| liboggz | 1.1.3 | https://xiph.org/oggz/ | Ogg streams |
| vorbis | 1.4.3 | https://xiph.org/vorbis/ | Vorbis tools |
| libvorbis | 1.3.7 | https://xiph.org/vorbis/ | Vorbis codec |
| amrwbenc | 0.1.3 | https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/ | AMR-WB encode |
| opencore-amr | 0.1.6 | https://sourceforge.net/projects/opencore-amr/files/opencore-amr/ | AMR-NB/WB decode |
| theora | 1.2.0 | https://ftp.osuosl.org/pub/xiph/releases/theora/ | Theora video |
| libfishsound | 1.0.1 | https://xiph.org/fishsound/ | Vorbis/Speex API |
| soxr | 0.1.3 | https://sourceforge.net/projects/soxr/ | Resampler |
| libwebp | 1.6.0 | https://developers.google.com/speed/webp | WebP image |
| xvid | 1.3.7 | https://www.xvid.com/ | MPEG-4 ASP |
| svtav1 | 3.1.2 | https://gitlab.com/AOMediaCodec/SVT-AV1/-/releases | AV1 encoder |
| openh264 | 2.6.0 | https://github.com/cisco/openh264/releases | H.264 (Cisco) |
| libilbc | 3.0.4 | https://github.com/TimothyGu/libilbc/releases | iLBC VoIP |
| libjxl | 0.11.1 | https://github.com/libjxl/libjxl | JPEG XL |

### Additional Build Modules (no versions.txt entry)

| Component | Link | Description |
|-----------|------|-------------|
| dav1d | https://code.videolan.org/videolan/dav1d | AV1 decoder |
| aom (libaom) | https://aomedia.googlesource.com/aom/ | AV1 reference |
| vpx (libvpx) | https://chromium.googlesource.com/webm/libvpx | VP8/VP9 |
| fdk-aac | https://github.com/mstorsjo/fdk-aac/releases | AAC codec |
| kvazaar | https://github.com/ultravideo/kvazaar/releases | HEVC encoder |
| uavs3d | https://github.com/uavs3/uavs3d | AVS3 decoder |
| zimg | https://github.com/sekrit-twc/zimg/releases | Image scaling |
| vidstab | https://github.com/georgmartius/vid.stab/releases | Video stabilization |
| libsrt | https://github.com/Haivision/srt/releases | SRT streaming |
| aribb24 | https://github.com/nkorber/aribb24 | ARIB subtitles |
| faad2 | https://github.com/knik0/faad2/releases | AAC decode |
| gsm | https://github.com/timothytylee/libgsm | GSM speech |
| neroaacenc | Nero AAC (archived) | AAC encode |

## Commands

| Command | Description |
|---------|-------------|
| `fetch` | Download all source packages to `downloads/` |
| `deps` | Install build dependencies (gcc, cmake, meson, etc.) – requires root |
| `build` | Full compile from source |
| `dist` | Pack project to `ffmpegtoolkit-YYYYMMDD-HHMMSS.tar.gz` (output in parent directory) |
| `ldconfig` | Register `PREFIX/lib` in dynamic loader – fix "cannot open shared object" |

## Options

| Option | Description |
|--------|-------------|
| `--mode=quick` | Install pre-built binary (johnvansickle) |
| `--mode=static` | Extract pre-compiled static package |
| `--mode=compile` | Full compile from source (default) |
| `--with-cuda` | Enable CUDA/NVENC build |
| `--with-qsv` | Enable Intel Quick Sync Video |
| `--exclude=mod` | Skip module(s), e.g. `--exclude=x265` |
| `--only=mod` | Build only this module |
| `--force` | Force rebuild all (ignore checkpoints) |
| `--link` | Symlink ffmpeg/ffprobe to /usr/local/bin |
| `--unlink` | Remove those symlinks |
| `--link-path` | Add PREFIX/bin to PATH via /etc/profile.d |
| `--clean` | Clean build artifacts |

## Examples

```bash
# Quick install (pre-built binary)
./build.sh --mode=quick

# Full build with CUDA
./build.sh --mode=compile --with-cuda

# Build only ffmpeg (skip already-built deps)
./build.sh build --only=ffmpeg

# Force rebuild everything
./build.sh build --force

# Symlink and fix loader
sudo ./build.sh --link
sudo ./build.sh ldconfig
```

## Supported Systems

- **Ubuntu/Debian**: Ubuntu 22.04, Debian 11+
- **RHEL Family**: Rocky Linux 9, Alma Linux, CentOS 8/9, RHEL 8/9

## Directory Layout

```
ffmpegtoolkit/
├── build.sh              # Main entry script
├── versions.txt          # Version manifest (Source of Truth)
├── downloads/            # Downloaded source tarballs
├── logs/                 # Build logs
├── scripts/
│   ├── common.sh         # Utilities, version helpers
│   ├── env_check.sh      # OS/hardware detection
│   ├── dep_manager.sh    # Dependency installation
│   ├── ldconfig_setup.sh # Dynamic loader config
│   └── build_modules/    # Per-component build scripts
└── templates/            # Build parameter templates
```

## Version Management

All component versions are defined in `versions.txt`. To update a component:

1. Edit `versions.txt` (e.g. `ffmpeg=8.0.1`)
2. Run `./build.sh fetch` to download new sources
3. Run `./build.sh build --force` or rebuild only that module

See `version.md` for full dependency list and official links.


## License

GPL v3. FFmpeg is licensed under GPL when built with `--enable-gpl`. Some components (e.g. fdk-aac with `--enable-nonfree`) have different licenses; see each component's source for details.
