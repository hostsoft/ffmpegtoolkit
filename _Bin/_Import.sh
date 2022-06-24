#!/usr/bin/env bash

cd /home/bt/watch/_Cen/1_CHS/Done
mkdir -p {import,replace,delete}
for dir in *.*; do
INFILE="$dir";
Filename=$(basename ${dir});  # Filename
Filename2=${Filename%.*}      # Filename without extension
AVID=$(echo "$Filename2" | awk '{print toupper($0)}')
Filesize=$(wc -c "$INFILE" | awk '{print $1}')
BITRATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=nokey=1:noprint_wrappers=1 ${INFILE});
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nokey=1:noprint_wrappers=1 ${INFILE});
if [ "$BITRATE" = "N/A" ]; then
  BITRATE=$(ffprobe -hide_banner -loglevel 0 -of flat -i ${INFILE} -select_streams v -show_entries 'format=bit_rate' 2> /dev/null | sed 's/.*bit_rate="\([0-9]\+\)".*/\1/g';)
fi
APIURL="http://dev.jav.re/api/chs/cen?cmd=check&fh=${AVID}&bitrate=${BITRATE}&size=${Filesize}&height=${HEIGHT}";
echo -e "${APIURL}"; ##--resolve jav.re:443:144.76.1.75
if curl -Ss ${APIURL} | grep -q "found"; then
    echo -e "Found,Skip......";
    API_URL="http://dev.jav.re/api/chs/verify?fh=${AVID}&height=${HEIGHT}";
    echo -e "${API_URL}"; ##--resolve jav.re:443:144.76.1.75
    RESP=$(curl -Ss $API_URL);
    if [ "${RESP}" == "replace" ]; then
      echo -e "need replace";
      mv "${INFILE}" "replace/${INFILE}";
      echo "${Filename}">>_replace.txt
    else
      echo -e "remove";
      mv "${INFILE}" "delete/${INFILE}";
      echo "${Filename}">>_ok.txt
    fi
else
    echo -e "need import!";
    mv "${INFILE}" "import/${INFILE}";
fi
echo -e "${INFILE} - ${AVID} - ${BITRATE} - ${Filesize} - ${HEIGHT}";
done



# 同步新入库
cd /home/bt/watch/_Cen/1_CHS/Done/import
rclone copy -v --fast-list --ignore-existing ./ s2:/home/chs.gslb.ru/import

# 同步替换
cd /home/bt/watch/_Cen/1_CHS/Done/replace
rclone copy -v --fast-list --ignore-existing ./ s2:/home/chs.gslb.ru/replace

# Remove
cd /home/bt/watch/_Cen/1_CHS/_Watermark
rclone copy -v --fast-list --ignore-existing ./  s2:/home/wait/Need_RemoveWatermark3

rsync -av --delete /srv/ /home/bt/watch/_Cen/1_CHS/Done/Need_RemoveWatermark/
rsync -av --delete /srv/ /home/bt/watch/_Cen/1_CHS/Done/done/tmp/


## 更新 Replace
cd /home/bt/watch/_Cen/1_CHS/Done/replace

for dir in *.*; do
INFILE="$dir";
Filename=$(basename ${dir});  # Filename
Filename2=${Filename%.*}      # Filename without extension
AVID=$(echo "$Filename2" | awk '{print toupper($0)}')
HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nokey=1:noprint_wrappers=1 ${INFILE});
CALLURL="http://dev.jav.re/api/chs/cen?cmd=update&fh=${AVID}&height=${HEIGHT}";
echo -e ${CALLURL};
RESP=$(curl -Ss $CALLURL);
if [ "${RESP}" == "ok" ]; then
  echo -e "Update OK";
else
  echo -e "Update Fail";
fi
done;




cd /home/bt/watch/_Cen/1_CHS

#
# 一种判断视频文件是否具备Web播放能力的检测方式
# How to: Fix pseudo-streaming videos by moving Moov Atom
# Moving the Moov Atom using qt-faststart
#

mkdir -p _Process
for f in *.*; do
INPUT="${f}";
STATUS=$(mediainfo "--Inform=General;IsStreamable: %IsStreamable%" "$INPUT")
if grep -q "No" <<< "${STATUS}"; then
  echo -e "moving the moov atom using qt-faststart";
  mv "${INPUT}" "_Process/${INPUT}";
else
  echo -e "OK";
fi
done

cd _Process;
for f in *.*; do
INPUT="${f}";
qt-faststart "${INPUT}" "../${INPUT}"
done


cd /home/chs.gslb.ru/replace
mv *.mp4 ../public/
