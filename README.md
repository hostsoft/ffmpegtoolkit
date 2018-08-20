
##  FFMPEG Toolkit v1  this will install ffmpeg version N 3.2.11
## if you want custom version
## edit the vc_ffmpeg.sh

```
find

git clone -b 'n3.2.11' --single-branch --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
change to
git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
this will install latest version of ffmpeg

find another version you may need: 

you can search https://github.com/FFmpeg/FFmpeg/tags
to find the version you need and make changes by renaming n3.2.11 to your version.

*the n3.2.11 is versions tag

you can find it in https://github.com/FFmpeg/FFmpeg/tags

EG: if you like n3.* or n4.* (just replace n3.2.11 to n3.* or n4.* (example n3.2.11 change to n2.8 or n4.0 etc..) 
save the file then proceed to install :)
```
** Then follow install instructions **

# Automatically install ffmpeg on your system
it's free  

 * install ffmpeg ffprobe qt-faststart
 * install mplayer mencoder
 * install mp4box flvtool2 yamdi
 * install mediainfo neroaccenc 
 * working CentOS 7.* 64bit, other not tested

### Update
 * add libass support (16/03/2018)
 * add NVIDIA CUDA   (New versions wait add it)
 * add libvpx
 * add x265
 * update something soft to latest version

### Install Instructions  
```
yum install git wget -y 
cd /opt
git clone https://github.com/spirogg/ffmpegtoolkit.git ffmpegtoolkit
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
To remove - Uninstall

try this below

---------------------

if you want remove, just use
```
array=( /lib /usr/lib /usr/local/lib /lib64 /usr/lib64 /usr/local/lib64  )
for i in "${array[@]}"
do
echo "Start Remove......"
rm -rf "$i/liba52*"
rm -rf "$i//libamr*"
rm -rf "$i//libavcodec*"
rm -rf "$i//libavformat*"
rm -rf "$i//libavutil*"
rm -rf "$i//libdha*"
rm -rf "$i//libfaac*"
rm -rf "$i//libfaad*"
rm -rf "$i//libmp3lame*"
rm -rf "$i//libmp4v2*"
rm -rf "$i//libogg*"
rm -rf "$i//libtheora*"
rm -rf "$i//libvorbis*"
echo "Remove Done!"
done

array=( /bin /usr/bin /usr/local/bin  )
for i in "${array[@]}"
do
echo "Start Remove......"
rm -rf "$i/ffmpeg"
rm -rf "$i/mplayer"
rm -rf "$i/mencoder"
rm -rf "$i/flvtool2"
echo "Remove Done!"
done

rm -rf /opt/ffmpegtoolkit
rm -rf /usr/local/ffmpegtoolkit
rm -rf ~/tmp
mkdir -p ~/tmp
```
