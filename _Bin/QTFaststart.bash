



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
