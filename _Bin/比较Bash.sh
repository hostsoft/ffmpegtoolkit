#!/usr/bin/env bash


INFILE=/home/bt/watch/_CN/_Resource/天美传媒TM0100父子俩的援交学生妹-尤莉.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,codec_type,width,height,bit_rate,nb_frames,r_frame_rate,duration,display_aspect_ratio -of default=noprint_wrappers=1 ${INFILE}

set -x
BitRateK=13000
ORIGIN_BITRATE=$((2040583 / 1000 ))
echo -e $ORIGIN_BITRATE;
[[ ${ORIGIN_BITRATE}  -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATE}
# 如果片源码率大于转码设置的最大码率就使用设置的,否者使用片源的码率
#if [ "${ORIGIN_BITRATE}" -ge "${BitRateK}" ] ; then
#  BITRATE=${BitRateK}
#else
#  BITRATE=${ORIGIN_BITRATE}
#fi
echo -e ${BITRATE};








# Calculation Resolution
[[ -z ${BITRATE} ]] && BITRATE="1024000"
ORIGIN_BITRATE=$[${BITRATE}/1024]

ORIGIN_WIDTH=
ORIGIN_HEIGHT=

SCALE="horizontal";
[[ ! ${ORIGIN_WIDTH} -gt ${ORIGIN_HEIGHT} ]] && SCALE="vertical";

if [[ "${ORIGIN_WIDTH}" -ge 3840 || "${ORIGIN_HEIGHT}" -ge 2160 ]]; then
  CRF=21;QP=19;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=13000
elif [[ "${ORIGIN_WIDTH}" -ge 2560 || "${ORIGIN_HEIGHT}" -ge 1440 ]]; then
  CRF=22;QP=19;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=8000
elif [[ "${ORIGIN_WIDTH}" -ge 1920 || "${ORIGIN_HEIGHT}" -ge 1080 ]]; then
  CRF=22;QP=20;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=5000
elif [[ "${ORIGIN_WIDTH}" -ge 1080 || "${ORIGIN_HEIGHT}" -ge 720 ]]; then
  CRF=22;QP=20;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=2800
elif [[ "${ORIGIN_WIDTH}" -ge 720 || "${ORIGIN_HEIGHT}" -ge 480 ]]; then
  CRF=22;QP=20;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=1200
elif [[ "${ORIGIN_WIDTH}" -ge 640 || "${ORIGIN_HEIGHT}" -ge 360 ]]; then
  CRF=22;QP=20;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=800
else
  CRF=22;QP=23;SIZE=-2:${ORIGIN_HEIGHT};BITRATE=600
fi


    if [[ ${ORIGIN_BITRATE} -ge 40000 ]]; then  #2160P
        BV="2160"
        QP="19"
        BR="25000"
    elif [[ ${ORIGIN_BITRATE} -ge 10000 ]]; then  #1440P
        BV="1440"
        QP="19"
        BR="10240"
    elif [[ ${ORIGIN_BITRATE} -ge 8000 ]]; then  #1080P
        BV="1080"
        QP="20"
        BR="8000"
    elif [[ ${ORIGIN_BITRATE} -ge 5000 ]]; then  #720P
        BV="720"
        QP="21"
        BR="5000"
    elif [[ ${ORIGIN_BITRATE} -ge 2500 ]]; then  #480P
        BV="480"
        QP="22"
        BR="2500"
    elif [[ ${ORIGIN_BITRATE} -ge 1000 ]]; then #360P
        BV="360"
        QP="22"
        BR="1024"
    else
        BV="240"
        QP="23"
        BR="512"
    fi


