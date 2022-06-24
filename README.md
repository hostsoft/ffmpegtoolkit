
# FFMPEG Toolkit
The script is written in Bash language  
it's can automatically install ffmpeg and related on you system
Current version **V2**

	Notice: Current Only Work CentOS 8 64bit, other system include centos 7 not testing

### Requirements

| Name | Version |
|--|--|
| CentOS | 8 or higher |


### Features

* install ffmpeg ffprobe qt-faststart
* install mp4box flvtool2 yamdi
* install mediainfo neroaccenc
* install imagemagick

### Changelog

* remove mplayer mencoder (v2)
* add libass support (16/03/2018)
* add NVIDIA CUDA   (New versions wait add it)
* add aom
* add x265
* add x264
* add libvpx
* update something soft and library to latest version

### Usage
```
yum install -y git wget
cd /opt
git clone https://github.com/hostsoft/ffmpegtoolkit.git ffmpegtoolkit
cd ffmpegtoolkit
bash install.sh

mkdir -p /opt/ffmpegtoolkit
cd /opt/ffmpegtoolkit
bash install.sh


```

### Verify
* verify and check path, included *ImageMagick*
```
which {ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc}  
```

* Return
```
[root@dev ~]# which {ffmpeg,ffprobe,qt-faststart,neroAacEnc,x264,x265}
/usr/local/bin/ffmpeg
/usr/local/bin/ffprobe
/usr/local/bin/qt-faststart
/usr/local/bin/neroAacEnc
/usr/local/bin/x264
/usr/local/bin/x265
      
[root@dev ~]# which {identify,convert,composite}
/usr/bin/identify
/usr/bin/convert
/usr/bin/composite

[root@dev ~]# ffmpeg
ffmpeg version N-102560-g4718d74c58 Copyright (c) 2000-2021 the FFmpeg developers
  built with gcc 8 (GCC)
  configuration: --prefix=/usr/local/ffmpegtoolkit --bindir=/usr/local/ffmpegtoolkit/bin --pkg-config-flags=--static --extra-libs=-lpthread --extra-libs=-lm --extra-cflags='-I/usr/local/include -I/usr/local/cuda/include -I/include' --extra-ldflags='-L/usr/local/lib -L/usr/local/cuda/lib64' --enable-cross-compile --disable-debug --enable-fontconfig --enable-gray --enable-gpl --enable-version3 --enable-cuvid --enable-libnpp --enable-nvenc --enable-nvdec --enable-nonfree --enable-runtime-cpudetect --enable-shared --enable-pthreads --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libsoxr --enable-libmp3lame --enable-libfdk-aac --enable-libdav1d --enable-libkvazaar --enable-vaapi --enable-libfreetype --enable-libfribidi --enable-libzimg --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-libaom --enable-libxvid --enable-libwebp --enable-postproc --enable-swscale --enable-avfilter --enable-libass --enable-libaribb24 --enable-libxml2
  libavutil      57.  0.100 / 57.  0.100
  libavcodec     59.  1.100 / 59.  1.100
  libavformat    59.  2.100 / 59.  2.100
  libavdevice    59.  0.100 / 59.  0.100
  libavfilter     8.  0.101 /  8.  0.101
  libswscale      6.  0.100 /  6.  0.100
  libswresample   4.  0.100 /  4.  0.100
  libpostproc    56.  0.100 / 56.  0.100
Hyper fast Audio and Video encoder
usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...

Use -h to get full help or, even better, run 'man ffmpeg'


[root@dev ~]# ls /usr/local/ffmpegtoolkit/bin -l
total 14340
-rwxr-xr-x. 1 root root   38440 May 18 09:32 a52dec
-rwxr-xr-x. 1 root root   23048 May 18 09:33 amrnb-decoder
-rwxr-xr-x. 1 root root   22200 May 18 09:33 amrnb-decoder-etsi
-rwxr-xr-x. 1 root root   22648 May 18 09:33 amrnb-decoder-if2
-rwxr-xr-x. 1 root root   25896 May 18 09:33 amrnb-encoder
-rwxr-xr-x. 1 root root   25560 May 18 09:33 amrnb-encoder-etsi
-rwxr-xr-x. 1 root root   25560 May 18 09:33 amrnb-encoder-etsi-vad2
-rwxr-xr-x. 1 root root   25816 May 18 09:33 amrnb-encoder-if2
-rwxr-xr-x. 1 root root   25816 May 18 09:33 amrnb-encoder-if2-vad2
-rwxr-xr-x. 1 root root   25896 May 18 09:33 amrnb-encoder-vad2
-rwxr-xr-x. 1 root root   23312 May 18 09:33 amrwb-decoder
-rwxr-xr-x. 1 root root   22920 May 18 09:33 amrwb-decoder-if2
-rwxr-xr-x. 1 root root   25488 May 18 09:33 amrwb-encoder
-rwxr-xr-x. 1 root root   25440 May 18 09:33 amrwb-encoder-if2
-rwxr-xr-x. 1 root root  600696 May 18 09:57 aomdec
-rwxr-xr-x. 1 root root  628328 May 18 09:58 aomenc
-rwxr-xr-x. 1 root root  238840 May 18 09:47 cwebp
-rwxr-xr-x. 1 root root  131280 May 18 09:47 dwebp
-rwxr-xr-x. 1 root root   17912 May 18 09:32 extract_a52
-rwxr-xr-x. 1 root root  269680 May 18 09:36 faad
-rwxr-xr-x. 1 root root  259696 May 18 10:16 ffmpeg
-rwxr-xr-x. 1 root root  144056 May 18 10:16 ffprobe
-rwxr-xr-x. 1 root root 1023248 May 18 09:40 flac
-rwxr-xr-x. 1 root root  106320 May 18 09:47 gif2webp
-rwxr-xr-x. 1 root root  181792 May 18 09:47 img2webp
-rwxr-xr-x. 1 root root  130920 May 18 09:41 kvazaar
-rwxr-xr-x. 1 root root  514176 May 18 09:41 lame
-rwxr-xr-x. 1 root root    2411 May 18 09:47 libwmf-config
-rwxr-xr-x. 1 root root   13143 May 18 09:47 libwmf-fontmap
-rwxr-xr-x. 1 root root  677544 May 18 09:40 metaflac
-rwxr-xr-x. 1 root root  514624 May 18 09:41 mp3rtp
-rwxr-xr-x. 1 root root  369584 May 18 09:44 ogg123
-rwxr-xr-x. 1 root root   48768 May 18 09:44 oggdec
-rwxr-xr-x. 1 root root  279392 May 18 09:44 oggenc
-rwxr-xr-x. 1 root root  117888 May 18 09:44 ogginfo
-rwxr-xr-x. 1 root root   22440 May 18 09:41 oggz
-rwxr-xr-x. 1 root root  142288 May 18 09:41 oggz-chop
-rwxr-xr-x. 1 root root   68504 May 18 09:41 oggz-codecs
-rwxr-xr-x. 1 root root   84776 May 18 09:41 oggz-comment
-rwxr-xr-x. 1 root root    5671 May 18 09:41 oggz-diff
-rwxr-xr-x. 1 root root   89280 May 18 09:41 oggz-dump
-rwxr-xr-x. 1 root root  100056 May 18 09:41 oggz-info
-rwxr-xr-x. 1 root root   18848 May 18 09:41 oggz-known-codecs
-rwxr-xr-x. 1 root root   75616 May 18 09:41 oggz-merge
-rwxr-xr-x. 1 root root   76168 May 18 09:41 oggz-rip
-rwxr-xr-x. 1 root root   70544 May 18 09:41 oggz-scan
-rwxr-xr-x. 1 root root   75968 May 18 09:41 oggz-sort
-rwxr-xr-x. 1 root root   83128 May 18 09:41 oggz-validate
-rwxr-xr-x. 1 root root   69616 May 18 09:43 speexdec
-rwxr-xr-x. 1 root root   86512 May 18 09:43 speexenc
-rwxr-xr-x. 1 root root     797 May 18 09:30 srt-ffplay
-rwxr-xr-x. 1 root root 1125448 May 18 09:31 srt-file-transmit
-rwxr-xr-x. 1 root root 1122072 May 18 09:31 srt-live-transmit
-rwxr-xr-x. 1 root root 1151416 May 18 09:31 srt-tunnel
-rwxr-xr-x. 1 root root   54904 May 18 09:44 vcut
-rwxr-xr-x. 1 root root  118400 May 18 09:44 vorbiscomment
-rwxr-xr-x. 1 root root   77464 May 18 09:47 vwebp
-rwxr-xr-x. 1 root root  139680 May 18 09:47 webpinfo
-rwxr-xr-x. 1 root root  106200 May 18 09:47 webpmux
-rwxr-xr-x. 1 root root   47824 May 18 09:47 wmf2eps
-rwxr-xr-x. 1 root root   44896 May 18 09:47 wmf2fig
-rwxr-xr-x. 1 root root   44264 May 18 09:47 wmf2gd
-rwxr-xr-x. 1 root root   44696 May 18 09:47 wmf2svg
-rwxr-xr-x. 1 root root   47000 May 18 09:47 wmf2x
-rwxr-xr-x. 1 root root 2565704 May 18 10:01 x264
-rwxr-xr-x. 1 root root  164592 May 18 10:05 x265


```
