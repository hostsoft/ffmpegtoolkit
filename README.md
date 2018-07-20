
##  FFMPEG Toolkit v1  

   [https://www.ffmpegtoolkit.com/](https://www.ffmpegtoolkit.com)
    
       
  
# Automatically installer ffmpeg on you system
it's free  

 * install ffmpeg ffprobe qt-faststart
 * install mplayer mencoder
 * install mp4box flvtool2 yamdi
 * install mediainfo neroaccenc 
 * working CentOS 7.* 64bit, other not testing

### Update
 * add AV1 /AM support (20/07/2018)
 * add libass support (16/03/2018)
 * add NVIDIA CUDA   (New versions wait add it)
 * add libvpx
 * add x265
 * update something soft to latest version

### Installer  
```
yum install git wget -y 
cd /opt
git clone https://github.com/hostsoft/ffmpegtoolkit.git ffmpegtoolkit
cd ffmpegtoolkit
sh latest.sh
```
  
### Check Path  , Included  *ImageMagick*
```
which {ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc}  
```

```
[root@dev ~]# which {ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc,x264,x265}
/usr/local/bin/ffmpeg
/usr/local/bin/ffprobe
/usr/local/bin/qt-faststart
/usr/local/bin/mplayer
/usr/local/bin/mencoder
/usr/local/bin/flvtool2
/usr/local/bin/MP4Box
/usr/local/bin/yamdi
/usr/local/bin/mediainfo
/usr/local/bin/neroAacEnc
/usr/local/bin/x264
/usr/local/bin/x265
      
[root@dev ~]# echo "ImageMagick Command Path"
ImageMagick Command Path
[root@dev ~]# which {identify,convert,composite}
/usr/bin/identify
/usr/bin/convert
/usr/bin/composite

```
