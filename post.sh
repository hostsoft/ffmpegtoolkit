#!/bin/bash
RED='\033[01;31m'
RESET='\033[0m'
INSTALL_SDIR='/usr/src/ffmpegscript'
SOURCE_URL='http://mirror.ffmpeginstaller.com/source'
INSTALL_DDIR='/usr/local/cpffmpeg'
export cpu=`cat "/proc/cpuinfo" | grep "processor"|wc -l`
export TMPDIR=$HOME/tmp
_package=' '
if [ -e "/scripts/rebuildhttpdconf" ];then
	/scripts/rebuildhttpdconf
fi
clear

echo " "
echo " "
echo "The ffmpeg and dependency package installation has  been completed. You can use the following"
echo "paths for the major binary locations. Make sure to configure it in your conversion scripts too."
echo ""
which {php,ffmpeg,ffprobe,qt-faststart,mplayer,mencoder,flvtool2,MP4Box,yamdi,mediainfo,neroAacEnc}
echo " "
echo "				Don't forget to do the following "
echo " "
echo " "
echo "		Edit your php.ini and increase the value of post_max_size if you need tp post big files via php scripts "
echo " 		Edit your php.ini and  increase the value of upload_max_filesize if you need to upload big vidoe file"
echo "		Restart web server(httpd/nginx,etc.)  "
echo "		Test the installation "
echo " "
echo " "
echo " "



