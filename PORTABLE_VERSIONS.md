# PORTABLE VERSIONS


```shell

# CentOS / Almalinux / RockyLinux / Redhat

cd /opt
dnf install -y epel-release
dnf config-manager --set-enabled powertools
dnf config-manager --set-enabled crb
dnf install -y wget tar xz tinyxml2 mediainfo libmediainfo bc unzip screen sshfs
dnf install -y ImageMagick ImageMagick-devel libwebp
dnf install -y screen unzip fuse fuse-common sshfs

# Debian
cd /opt
sudo apt-get update
sudo apt install -y wget curl tar xz tinyxml2 mediainfo bc unzip screen fuse fuse-common sshfs
sudo apt install -y imagemagick

# FFMPEG
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




