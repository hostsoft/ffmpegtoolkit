
# FFMPEG Toolkit
---
The script is written in Bash language，it's can automatically install ffmpeg and related on you system
Current version **V2**

	Notice: working CentOS 7/8 64bit, other system not testing

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
 * add libvpx
 * add x265
 * update something soft and library to latest version

### Usage
```
yum install -y git wget
cd /opt
git clone https://github.com/hostsoft/ffmpegtoolkit.git ffmpegtoolkit
cd ffmpegtoolkit
sh install.sh
```
  
### Verify
	verify and check path, included *ImageMagick*
```
which {ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc}  
```

	Return
```
[root@dev ~]# which {ffmpeg,ffprobe,qt-faststart,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc,x264,x265}
/usr/local/bin/ffmpeg
/usr/local/bin/ffprobe
/usr/local/bin/qt-faststart
/usr/local/bin/flvtool2
/usr/local/bin/MP4Box
/usr/local/bin/yamdi
/usr/local/bin/mediainfo
/usr/local/bin/neroAacEnc
/usr/local/bin/x264
/usr/local/bin/x265
      
[root@dev ~]# which {identify,convert,composite}
/usr/bin/identify
/usr/bin/convert
/usr/bin/composite

```
