# FFmpeg Toolkit - 依赖版本清单

> 用于手动验证 `versions.txt` 中的版本号是否为最新版

## Core & Codecs

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| ffmpeg | 8.0.1 | https://ffmpeg.org/download.html | 主程序 |
| x264 | master | https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.gz | H.264 编码器 (Git master) |
| x265 | 4.1 | https://bitbucket.org/multicoreware/x265_git/downloads/ | HEVC/H.265 编码器 |
| libvmaf | 3.0.0 | https://github.com/Netflix/vmaf/releases | Netflix 视频质量评估 |
| openssl | 3.5.5 | https://www.openssl.org/source/ | SSL/TLS 加密库 |
| nv-codec-headers | 13.0.19.0 | https://github.com/FFmpeg/nv-codec-headers/releases | NVIDIA 编解码头文件 |

## Build Tools

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| nasm | 3.01 | https://www.nasm.us/ | 汇编器 |
| yasm | 1.3.0 | https://yasm.tortall.net/ | 汇编器 |

## Subtitles & Containers

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| libass | 0.17.4 | https://github.com/libass/libass/releases | ASS/SSA 字幕渲染 |

## Audio Codecs

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| a52dec | 0.7.4 | https://liba52.sourceforge.io/ | AC3/A52 解码 |
| libao | 1.2.0 | https://xiph.org/ao/ | 跨平台音频输出 |
| libwmf | 0.2.13 | https://github.com/caolanm/libwmf | WMF 图像处理 |
| speex | 1.2.1 | https://speex.org/ | 语音编解码 |
| flac | 1.5.0 | https://xiph.org/flac/ | 无损音频编解码 |
| lame | 3.100 | https://lame.sourceforge.io/ | MP3 编码器 |
| opus | 1.6.1 | https://downloads.xiph.org/releases/opus/ | 现代音频编解码 |
| ogg (libogg) | 1.3.6 | https://xiph.org/ogg/ | Ogg 容器格式 |
| liboggz | 1.1.3 | https://xiph.org/oggz/ | Ogg 流操作库 |
| vorbis (vorbis-tools) | 1.4.3 | https://xiph.org/vorbis/ | Vorbis 工具集 |
| libvorbis | 1.3.7 | https://xiph.org/vorbis/ | Vorbis 编解码 |
| amrwbenc (vo-amrwbenc) | 0.1.3 | https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/ | AMR-WB 编码 |
| opencore-amr | 0.1.6 | https://sourceforge.net/projects/opencore-amr/files/opencore-amr/ | AMR-NB/WB 解码 |
| theora | 1.2.0 | https://ftp.osuosl.org/pub/xiph/releases/theora/ | Theora 视频编解码 |
| libfishsound | 1.0.1 | https://xiph.org/fishsound/ | Vorbis/Speex 简易 API |
| soxr | 0.1.3 | https://sourceforge.net/projects/soxr/ | 高质量重采样 |

## Image & Video Codecs

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| libwebp | 1.6.0 | https://developers.google.com/speed/webp/download | WebP 图像编解码 |
| xvid | 1.3.7 | https://www.xvid.com/ | MPEG-4 ASP 编解码 |

## Additional Codecs (AV1, H.264, VoIP, JPEG XL)

| 组件 | 当前版本 | 官方网站 / 仓库 | 说明 |
|------|----------|-----------------|------|
| svtav1 (SVT-AV1) | 3.1.2 | https://gitlab.com/AOMediaCodec/SVT-AV1/-/releases | AV1 编码器 (Intel) |
| openh264 | 2.6.0 | https://github.com/cisco/openh264/releases | H.264 编解码 (Cisco) |
| libilbc | 3.0.4 | https://github.com/TimothyGu/libilbc/releases | iLBC VoIP 编解码 (WebRTC) |
| libjxl | 0.11.1 | https://github.com/libjxl/libjxl (git clone --recursive) | JPEG XL 图像编解码，含 bundled highway/brotli/skcms |

---

## 其他编译依赖 (通过 build_modules 引入，未在 versions.txt 中)

| 组件 | 官方网站 / 仓库 | 说明 |
|------|-----------------|------|
| dav1d | https://code.videolan.org/videolan/dav1d | AV1 解码器 |
| aom (libaom) | https://aomedia.googlesource.com/aom/ | AV1 参考编解码器 |
| vpx (libvpx) | https://chromium.googlesource.com/webm/libvpx | VP8/VP9 编解码 |
| fdk-aac | https://github.com/mstorsjo/fdk-aac/releases | AAC 编解码 |
| kvazaar | https://github.com/ultravideo/kvazaar/releases | HEVC 编码器 |
| uavs3d | https://github.com/uavs3/uavs3d | AVS3 解码器 |
| zimg | https://github.com/sekrit-twc/zimg/releases | 图像缩放/格式转换 |
| vidstab | https://github.com/georgmartius/vid.stab/releases | 视频稳定 |
| libsrt | https://github.com/Haivision/srt/releases | SRT 流媒体协议 |
| aribb24 | https://github.com/nkorber/aribb24 | ARIB STD-B24 字幕 |
| faad2 | https://github.com/knik0/faad2/releases | AAC 解码 |
| gsm | https://github.com/timothytylee/libgsm | GSM 语音编解码 |
| celt | https://gitlab.xiph.org/xiph/celt | 超低延迟音频 |
| neroaacenc | https://web.archive.org/web/20160923100008/http://ftp6.nero.com/tools/NeroAACCodec-1.5.1.zip | Nero AAC 编码 (已停止维护) |

---

## 快速检查命令

```bash
# 检查 FFmpeg 最新版本
curl -s https://ffmpeg.org/releases/ | grep -oP 'ffmpeg-\K[0-9.]+(?=\.tar)' | sort -V | tail -1

# 检查 x265 最新版本
curl -s https://bitbucket.org/multicoreware/x265_git/downloads/ | grep -oP 'x265_\K[0-9.]+' | sort -V | tail -1
```

---

**最后手工校验:** 2026-01-31
