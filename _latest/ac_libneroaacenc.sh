#!/bin/bash

function _install_neroaacenc() {
	clear
	echo "Updating system and grabbing core dependencies."
	cd $SOURCE_DIR/
	_file=NeroDigitalAudio.zip
	if [ -f "$_file" ]
	then
		echo "$file found, Skip Downloads"
	else
		echo "$file not found, Try Downloading......"
	        wget http://techdata.mirror.gtcomm.net/sysadmin/ffmpeg-avs/$_file
	fi
	unzip -o $_file -d nero
	cd nero/linux
	install -D -m755 neroAacEnc $INSTALL_DIR/bin
	echo "neroAacEnc Install Done!"
	echo -e $RED"Installation of $_file ....... started"$RESET
	cd $SOURCE_DIR/
}

_install_neroaacenc
