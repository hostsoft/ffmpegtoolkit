# FFmpeg Toolkit

FFmpeg 自动化编译构建系统，集成多种音视频编解码器与库。支持 Ubuntu/Debian 及 RHEL/Rocky/Alma Linux。

## 特性

- **全源码编译**：从源码编译 FFmpeg，集成 40+ 编解码器与库
- **版本统一管理**：所有组件版本定义于 `versions.txt`（单一数据源）
- **断点续编**：通过 `.done_*` 标记支持断点续编，已构建模块自动跳过
- **多系统支持**：Ubuntu 22.04、Rocky Linux 9 及兼容发行版
- **可选功能**：CUDA/NVENC、Intel QSV、静态链接、PATH/ldconfig 集成

## 克隆与部署

```bash

cd /opt

# 克隆仓库
cd /opt
# Clone repository
git clone https://github.com/wanyigroup/ffmpegtoolkit.git
cd ffmpegtoolkit
chmod +x -R ./
# 1. 安装编译依赖（需 root）
sudo ./build.sh deps
# 2. 下载所有源码包
./build.sh fetch
# 3. 编译（默认安装到 /opt/ffmpeg-toolkit）
./build.sh build
# 4. 将 ffmpeg/ffprobe 软链接到 /usr/local/bin（可选）
./build.sh --link
# 5. 注册共享库（解决 "cannot open shared object"）
./build.sh ldconfig
# 验证
ffmpeg -version
```


## FFmpeg 构建输出

编译成功后，`ffmpeg -version` 输出示例：

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

## 部署模块（versions.txt）

| 组件 | 版本 | 链接 | 说明 |
|------|------|------|------|
| ffmpeg | 8.0.1 | https://ffmpeg.org/download.html | 主程序 |
| x264 | master | https://code.videolan.org/videolan/x264 | H.264 编码器 |
| x265 | 4.1 | https://bitbucket.org/multicoreware/x265_git | HEVC/H.265 编码器 |
| libvmaf | 3.0.0 | https://github.com/Netflix/vmaf/releases | 视频质量评估 |
| openssl | 3.5.5 | https://www.openssl.org/source/ | SSL/TLS |
| nv-codec-headers | 13.0.19.0 | https://github.com/FFmpeg/nv-codec-headers/releases | NVIDIA 头文件 |
| nasm | 3.01 | https://www.nasm.us/ | 汇编器 |
| yasm | 1.3.0 | https://yasm.tortall.net/ | 汇编器 |
| libass | 0.17.4 | https://github.com/libass/libass/releases | ASS/SSA 字幕 |
| a52dec | 0.7.4 | https://liba52.sourceforge.io/ | AC3/A52 解码 |
| libao | 1.2.0 | https://xiph.org/ao/ | 音频输出 |
| libwmf | 0.2.13 | https://github.com/caolanm/libwmf | WMF 图像 |
| speex | 1.2.1 | https://speex.org/ | 语音编解码 |
| flac | 1.5.0 | https://xiph.org/flac/ | 无损音频 |
| lame | 3.100 | https://lame.sourceforge.io/ | MP3 编码器 |
| opus | 1.6.1 | https://downloads.xiph.org/releases/opus/ | 现代音频 |
| ogg (libogg) | 1.3.6 | https://xiph.org/ogg/ | Ogg 容器 |
| liboggz | 1.1.3 | https://xiph.org/oggz/ | Ogg 流操作 |
| vorbis | 1.4.3 | https://xiph.org/vorbis/ | Vorbis 工具 |
| libvorbis | 1.3.7 | https://xiph.org/vorbis/ | Vorbis 编解码 |
| amrwbenc | 0.1.3 | https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/ | AMR-WB 编码 |
| opencore-amr | 0.1.6 | https://sourceforge.net/projects/opencore-amr/files/opencore-amr/ | AMR-NB/WB 解码 |
| theora | 1.2.0 | https://ftp.osuosl.org/pub/xiph/releases/theora/ | Theora 视频 |
| libfishsound | 1.0.1 | https://xiph.org/fishsound/ | Vorbis/Speex API |
| soxr | 0.1.3 | https://sourceforge.net/projects/soxr/ | 重采样 |
| libwebp | 1.6.0 | https://developers.google.com/speed/webp | WebP 图像 |
| xvid | 1.3.7 | https://www.xvid.com/ | MPEG-4 ASP |
| svtav1 | 3.1.2 | https://gitlab.com/AOMediaCodec/SVT-AV1/-/releases | AV1 编码器 |
| openh264 | 2.6.0 | https://github.com/cisco/openh264/releases | H.264 (Cisco) |
| libilbc | 3.0.4 | https://github.com/TimothyGu/libilbc/releases | iLBC VoIP |
| libjxl | 0.11.1 | https://github.com/libjxl/libjxl | JPEG XL |

### 其他构建模块（未在 versions.txt 中）

| 组件 | 链接 | 说明 |
|------|------|------|
| dav1d | https://code.videolan.org/videolan/dav1d | AV1 解码器 |
| aom (libaom) | https://aomedia.googlesource.com/aom/ | AV1 参考编解码器 |
| vpx (libvpx) | https://chromium.googlesource.com/webm/libvpx | VP8/VP9 |
| fdk-aac | https://github.com/mstorsjo/fdk-aac/releases | AAC 编解码 |
| kvazaar | https://github.com/ultravideo/kvazaar/releases | HEVC 编码器 |
| uavs3d | https://github.com/uavs3/uavs3d | AVS3 解码器 |
| zimg | https://github.com/sekrit-twc/zimg/releases | 图像缩放 |
| vidstab | https://github.com/georgmartius/vid.stab/releases | 视频稳定 |
| libsrt | https://github.com/Haivision/srt/releases | SRT 流媒体 |
| aribb24 | https://github.com/nkorber/aribb24 | ARIB 字幕 |
| faad2 | https://github.com/knik0/faad2/releases | AAC 解码 |
| gsm | https://github.com/timothytylee/libgsm | GSM 语音 |
| neroaacenc | Nero AAC（归档） | AAC 编码 |

## 命令说明

| 命令 | 说明 |
|------|------|
| `fetch` | 下载所有源码包到 `downloads/` |
| `deps` | 安装编译依赖（gcc、cmake、meson 等）– 需 root |
| `build` | 全量源码编译 |
| `dist` | 将项目打包为 `ffmpegtoolkit-YYYYMMDD-HHMMSS.tar.gz`（输出到上级目录） |
| `ldconfig` | 将 `PREFIX/lib` 注册到动态链接器 – 解决共享库加载失败 |

## 选项说明

| 选项 | 说明 |
|------|------|
| `--mode=quick` | 安装预编译二进制（johnvansickle） |
| `--mode=static` | 解压预编译静态包 |
| `--mode=compile` | 全量源码编译（默认） |
| `--with-cuda` | 启用 CUDA/NVENC 编译 |
| `--with-qsv` | 启用 Intel 核显加速 |
| `--exclude=mod` | 跳过指定模块，如 `--exclude=x265` |
| `--only=mod` | 仅编译指定模块 |
| `--force` | 强制全量重编（忽略断点标记） |
| `--link` | 将 ffmpeg/ffprobe 软链接到 /usr/local/bin |
| `--unlink` | 移除上述软链接 |
| `--link-path` | 通过 /etc/profile.d 将 PREFIX/bin 加入 PATH |
| `--clean` | 清理构建产物 |

## 使用示例

```bash
# 快速安装（预编译二进制）
./build.sh --mode=quick

# 启用 CUDA 全量编译
./build.sh --mode=compile --with-cuda

# 仅编译 ffmpeg（依赖已构建则跳过）
./build.sh build --only=ffmpeg

# 强制全量重编
./build.sh build --force

# 创建软链接并修复加载器
sudo ./build.sh --link
sudo ./build.sh ldconfig
```

## 支持的系统

- **Ubuntu/Debian**：Ubuntu 22.04、Debian 11+
- **RHEL 系列**：Rocky Linux 9、Alma Linux、CentOS 8/9、RHEL 8/9

## 目录结构

```
ffmpegtoolkit/
├── build.sh              # 主入口脚本
├── versions.txt          # 版本清单（单一数据源）
├── downloads/            # 下载的源码包
├── logs/                 # 构建日志
├── scripts/
│   ├── common.sh         # 工具函数、版本辅助
│   ├── env_check.sh      # 系统与硬件检测
│   ├── dep_manager.sh    # 依赖安装
│   ├── ldconfig_setup.sh # 动态链接器配置
│   └── build_modules/    # 各组件编译脚本
└── templates/            # 构建参数模板
```

## 版本管理

所有组件版本均在 `versions.txt` 中定义。更新步骤：

1. 修改 `versions.txt`（如 `ffmpeg=8.0.1`）
2. 执行 `./build.sh fetch` 下载新源码
3. 执行 `./build.sh build --force` 或仅重编对应模块

完整依赖清单与官方链接见 `version.md`。

## 许可证

GPL v3。使用 `--enable-gpl` 编译的 FFmpeg 遵循 GPL 许可。部分组件（如 `--enable-nonfree` 下的 fdk-aac）另有许可，详见各组件源码。
