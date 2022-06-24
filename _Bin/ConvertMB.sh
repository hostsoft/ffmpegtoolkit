#!/usr/bin/env bash

# Multiple Bitrate Convert


DATEYMD=$(date +%Y-%m-%d)
DIRID=$2
[[ ! -z "$DIRID" ]] && WORKER_ID=$2 || WORKER_ID="input"
WORKER_DIR=$1
pushd ${WORKER_DIR} > /dev/null
INPUT_DIR="${WORKER_ID}";
OUTPUT_DIR="$3output";
BACKUP_DIR="_backup_${DATEYMD}/";
echo -e "Input directory: ${INPUT_DIR}";
echo -e "Output directory: ${OUTPUT_DIR}";
SUFFIX=".mp4";
[[ ! -d "$3logs" ]] && mkdir -p "$3logs";
[[ ! -d ${OUTPUT_DIR} ]] && mkdir -p ${OUTPUT_DIR};
[[ ! -d ${BACKUP_DIR} ]] && mkdir -p ${BACKUP_DIR};
#[[ ! -d ${INPUT_DIR} ]] && echo -e "Input Empty!!!";exit;
#[[ "$(ls -A $INPUT_DIR)" ]] && echo -e "Directory is Empty!";exit 0;

for Video in ${INPUT_DIR}/*.*; do
  #[[ ! -f "$Video" ]] || continue;
  INFILE="${Video}";               # Input Files
  BaseName="$(basename ${Video})"; # Filename
  FileName="${BaseName%.*}";       # Filename without extension
  FileVerify=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 ${INFILE})
  if [ -z "${FileVerify}" ]; then
    echo -e "May be Source Video File corruption,Skip......";
    mkdir -p "${WORKER_DIR}/fail";mv "${Video}" "${WORKER_DIR}/fail/";
    continue;
  fi
  FileInfo=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,codec_type,width,height,bit_rate,nb_frames,r_frame_rate,duration,display_aspect_ratio -of default=noprint_wrappers=1 ${INFILE} > "${WORKER_DIR}/${FileName}_parsed");
  source "${WORKER_DIR}/${FileName}_parsed";
  ORIGIN_WIDTH=${width}
  ORIGIN_HEIGHT=${height}
  ORIGIN_BITRATE=${bit_rate}
  if [ "$ORIGIN_BITRATE" = "N/A" ]; then
    ORIGIN_BITRATE=$(ffprobe -hide_banner -loglevel 0 -of flat -i ${INFILE} -select_streams v -show_entries 'format=bit_rate' 2> /dev/null | sed 's/.*bit_rate="\([0-9]\+\)".*/\1/g';)
  fi
  ORIGIN_BITRATES=$((${ORIGIN_BITRATE} / 1000 ));
  ORIGIN_FRAMERATE=$(($r_frame_rate))

  # Rest Value
  # if frame less 23 reset it 23/r, if over 60 reset it to 60/r
  [[ "${ORIGIN_FRAMERATE}" -le 23 ]] && FRAMERATE=23 || FRAMERATE=${ORIGIN_FRAMERATE};
  [[ "${FRAMERATE}" -ge 60 ]] && FRAMERATE=60

  SCALE_NAME="horizontal";
  SCALE="-2:${ORIGIN_HEIGHT}";
  [[ ! ${ORIGIN_WIDTH} -gt ${ORIGIN_HEIGHT} ]] && SCALE="${ORIGIN_WIDTH}:-2";SCALE_NAME="vertical";

  # FFMPEG Command Start

  FFMPEG_BIN=("ffmpeg -hide_banner -y -i "${INFILE}" -threads 0 ")
  FFMPEG_OPS+=(-vstats_file \"${3}logs/${FileName}.log)
#    #FFMPEG_OPS+=();
#    FFMPEG_OPS+=(); #;_${BV}p${SUFFIX})

  if [[ "${ORIGIN_WIDTH}" -ge 3840 || "${ORIGIN_HEIGHT}" -ge 2160 ]]; then
    N="2160P";CRF=21;QP=19;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=13000
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 192k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  elif [[ "${ORIGIN_WIDTH}" -ge 2560 || "${ORIGIN_HEIGHT}" -ge 1440 ]]; then
    N="1440P";CRF=22;QP=19;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=8000
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 192k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  elif [[ "${ORIGIN_WIDTH}" -ge 1920 || "${ORIGIN_HEIGHT}" -ge 1080 ]]; then
    N="1080P";CRF=22;QP=20;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=5000
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 128k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  elif [[ "${ORIGIN_WIDTH}" -ge 1080 || "${ORIGIN_HEIGHT}" -ge 720 ]]; then
    N="720P";CRF=22;QP=21;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=2800
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 128k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  elif [[ "${ORIGIN_WIDTH}" -ge 720 || "${ORIGIN_HEIGHT}" -ge 480 ]]; then
    N="480P";CRF=22;QP=22;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=1200
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 128k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  elif [[ "${ORIGIN_WIDTH}" -ge 640 || "${ORIGIN_HEIGHT}" -ge 360 ]]; then
    N="360P";CRF=22;QP=22;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=800
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 96k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  else
    N="240P";CRF=22;QP=23;SIZE=-2:${ORIGIN_HEIGHT};BitRateK=600
    [[ ${ORIGIN_BITRATES} -ge ${BitRateK} ]] && BITRATE=${BitRateK} || BITRATE=${ORIGIN_BITRATES}
    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart -c:a aac -b:a 96k ${OUTPUT_DIR}/${FileName}${SUFFIX})
  fi

  echo -e "------------- Video Parse Info --------------";
  echo -e "Work Directory: ${WORKER_DIR}";
  echo -e "File Name:${FileName} ";
  echo -e "Video Codec Name: ${codec_name} ";
  echo -e "Video Codec Type: ${codec_type} ";
  echo -e "Video Duration: ${duration} ";
  echo -e "Video Frame: ${nb_frames} ";
  echo -e "Video FrameRate: $(($r_frame_rate)) - ${r_frame_rate} ";
  echo -e "Video Bit Rate: Origin => ${BITRATE} Maxrate => ${BitRateK} ";
  echo -e "Video Dimension: ${width}x${height} ";
  echo -e "Video Ratio: ${display_aspect_ratio} ";
  echo -e "Video Scale: ${SCALE_NAME} - ${SCALE} ";
  echo -e "Video Target: ${N} ";
  echo -e "------------- Video Parse End --------------";

  COMMANDS="${FFMPEG_BIN} ${FFMPEG_OPS[@]}"
  echo -e "Command:\n ${COMMANDS} \n"
  #$(${COMMANDS});
  #unset FFMPEG_OPS;

#  #  GPU Mode: Intel QSV
#  FFMPEG_GBIN=("ffmpeg -hide_banner -hwaccel vaapi -hwaccel_output_format vaapi -vstats_file "${3}logs/${FileName}.log" -y -i "${INFILE}" ")
#  #FFMPEG_GOPS+=(-c:v h264_qsv -global_quality ${QP} -b:v 0k -vf "scale_vaapi=${SCALE},hwmap=derive_device=qsv,format=qsv" -preset slow -profile:v high -level 4.1 -movflags faststart)
#  FFMPEG_GOPS+=(-c:v h264_qsv -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -vf "scale_vaapi=${SCALE},hwmap=derive_device=qsv,format=qsv" -preset slow -profile:v high -level 4.1 -movflags faststart )
#  # CBR -b:v 5M -maxrate 5M -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k
#  # CQP -c:v h264_qsv -q 25
#  FFMPEG_GOPS+=(-c:a aac -strict -2 -ar 44100 -b:a 128k ${OUTPUT_DIR}/${FileName}${SUFFIX})
#  COMMANDSG="${FFMPEG_GBIN} ${FFMPEG_GOPS[@]}"
#  echo -e "Command:\n ${COMMANDSG} \n"
#  echo -e "Info: Try GPU Transcoding ${INFILE} ......."
#  $(${COMMANDSG});
#  unset FFMPEG_GOPS;

#  # if file not exists or it's empty, try use CPU re-transcoding
#  if [[ ! -f ${OUTPUT_DIR}/${FileName}${SUFFIX} && ! -s ${OUTPUT_DIR}/${FileName}${SUFFIX} ]]; then
#    FFMPEG_BIN=("ffmpeg -hide_banner -y -i "${INFILE}" -threads 0 ")
#    FFMPEG_OPS+=(-vstats_file "${3}logs/${FileName}.log")
#    FFMPEG_OPS+=(-c:v libx264 -preset slow -profile:v high -level:v 4.1 -vf "scale=${SCALE}" -b:v ${BITRATE}k -maxrate $((${BITRATE} * 2))k -bufsize $((${BITRATE}/2))k -g 50 -max_muxing_queue_size 9999 -movflags faststart) # CRF Mode
#    #FFMPEG_OPS+=();
#    FFMPEG_OPS+=(-c:a aac -b:a 128k ${OUTPUT_DIR}/${FileName}${SUFFIX}); #;_${BV}p${SUFFIX})
#    COMMANDS="${FFMPEG_BIN} ${FFMPEG_OPS[@]}"
#    echo -e "Command:\n ${COMMANDS} \n"
#    $(${COMMANDS});
#    unset FFMPEG_OPS;
#  fi

#  echo -e "${Green} Convert Done, Checking......${Reset}";
#  rm -rf "${WORKER_DIR}/${FileName}_parsed";
#  if [[ -f ${OUTPUT_DIR}/${FileName}${SUFFIX} && -s ${OUTPUT_DIR}/${FileName}${SUFFIX} ]]; then
#    echo -e "${Green} File is valid, Remove Origin File...... ${Reset}"
#    mv "${Video}" "${BACKUP_DIR}/"
#    echo -e "${Green} Mission Completed, Start Process Next......${Reset}"
#  else
#    echo -e "${Red} File is invalid, Please try Transcoding Video Again...... ${Reset}";
#  fi
#  exit;
done
popd > /dev/null
