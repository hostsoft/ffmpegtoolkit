# PORTABLE VERSIONS


这个是静态编译好的二进制文件版本, 下载后可以直接运行，无需编译
 - 静态编译的版本只支持CPU,不支持GPU, 例如 NVIDIA GPUs (CUDA(NVENC/NVDEC))  或 INTEL GPUs 的 Quick Sync (QSV)

This is a statically compiled binary file version. It can be run directly after downloading without further compilation.
- Statically compiled versions only support CPUs, not GPUs, such as NVIDIA GPUs (CUDA (NVENC/NVDEC)) or Intel GPUs' Quick Sync (QSV).

## Version
latest release: 7.0.2

## Command
```shell

# CentOS / Almalinux / RockyLinux / Redhat
cd /opt
dnf install -y epel-release
dnf config-manager --set-enabled powertools
dnf config-manager --set-enabled crb
dnf install -y wget tar xz tinyxml2 mediainfo libmediainfo bc unzip screen sshfs
dnf install -y ImageMagick ImageMagick-devel libwebp
dnf install -y screen unzip fuse fuse-common sshfs

# Ubuntu / Debian
cd /opt
sudo apt-get update
sudo apt install -y wget curl tar xz tinyxml2 mediainfo bc unzip screen fuse fuse-common sshfs
sudo apt install -y imagemagick


## FFMPEG Static Bin release: 7.0.2
cd /opt
[[ -f "ffmpeg-release-amd64-static.tar.xz" ]] && rm -rf ffmpeg-release-amd64-static.tar.xz
wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
# OR
wget https://github.com/hostsoft/ffmpegtoolkit/raw/refs/heads/main/downloads/ffmpeg-release-amd64-static.tar.xz
tar xvf ffmpeg-release-amd64-static.tar.xz
[[ -d /usr/local/ffmpeg ]] && rm -rf /usr/local/ffmpeg
mv ffmpeg-7.*-amd64-static /usr/local/ffmpeg
ln -sf /usr/local/ffmpeg/ffprobe  /usr/bin/ffprobe
ln -sf /usr/local/ffmpeg/ffmpeg /usr/bin/ffmpeg
ln -sf /usr/local/ffmpeg/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/ffmpeg/qt-faststart /usr/bin/qt-faststart


# FFMPEG latest Git Repo Version 
cd /opt
[[ -d /usr/local/ffmpeg ]] && rm -rf /usr/local/ffmpeg
[[ -f ffmpeg-git-amd64-static.tar.xz ]] && rm -rf ffmpeg-git-amd64-static.tar.xz
wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz
tar xvf ffmpeg-git-amd64-static.tar.xz
mv ffmpeg-git-2024*-amd64-static /usr/local/ffmpeg
ln -sf /usr/local/ffmpeg/ffprobe  /usr/bin/ffprobe
ln -sf /usr/local/ffmpeg/ffmpeg /usr/bin/ffmpeg
ln -sf /usr/local/ffmpeg/qt-faststart /usr/bin/qt-faststart
ln -sf /usr/local/ffmpeg/ffprobe  /usr/local/bin/ffprobe
ln -sf /usr/local/ffmpeg/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/ffmpeg/qt-faststart /usr/local/bin/qt-faststart
ln -sf /usr/bin/convert /usr/local/bin/convert


```

## Ref
 - https://www.johnvansickle.com/ffmpeg/

