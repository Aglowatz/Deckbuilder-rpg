#!/usr/bin/env bash
# Fable Nov 9, Part 3: the itch.io trailer (30-60 s). Two steps, one Godot at a time:
#   bash tools/make_trailer.sh capture    - runs docs/review/play_scripts/trailer_rc1.txt under Godot's movie writer (1280x720, 30 fps, MJPEG AVI)
#                                           into _movie/trailer_rc1.avi (+ the play log with the CUT marks)
#   bash tools/make_trailer.sh cut        - ffmpeg: the clips at the CUT marks, 0.4 s fades, three title cards in the game's font, the title
#                                           theme as the only sound -> builds/trailer_rc1.mp4 (h264 720p) and a poster frame
# Needs ffmpeg on the PATH (winget Gyan.FFmpeg). Nothing is saved to the player's save slots (--no-save).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
step="${1:-cut}"
avi="_movie/trailer_rc1.avi"
play_log="_screenshots/play/trailer_rc1/play.log"
if [ "$step" = "capture" ]; then
	mkdir -p _movie _screenshots/play/trailer_rc1
	rm -f "$avi" "${avi%.avi}.wav"
	"$GODOT" --path . --write-movie "$avi" --fixed-fps 30 --resolution 1280x720 res://tools/play_script_launcher.tscn -- --no-save \
		"--script=$root/docs/review/play_scripts/trailer_rc1.txt" "--out=res://_screenshots/play/trailer_rc1" --limit=330 > _movie/capture.log 2>&1
	ls -la "$avi"; grep -E "CUT|SCRIPT ERROR" "$play_log" | head -20
	exit 0
fi
[ -f "$avi" ] || { echo "no $avi: run the capture step first"; exit 1; }
[ -f "$play_log" ] || { echo "no $play_log"; exit 1; }
# CUT marks: "  12.3   > log CUT title" -> seconds. The play log counts wall-clock seconds while the movie writer counts frames at a fixed
# 30 fps and renders slower than real time, so a log time maps to a movie time by the ratio (movie length / the log's last mark).
movie_len=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$avi")
end_mark=$(grep "CUT end\$" "$play_log" | head -1 | awk '{print $1}')
scale=$(awk -v m="$movie_len" -v e="$end_mark" 'BEGIN{ if (e > 0) printf "%.5f", m/e; else print 1 }')
echo "movie $movie_len s for a $end_mark s log: scale $scale"
cut_at() { grep "CUT $1\$" "$play_log" | head -1 | awk -v s="$scale" '{printf "%.2f", $1 * s}'; }
# a relative font path: a drive colon ("C:") would need escaping inside the filtergraph
font="assets/fonts/Cinzel/Cinzel-Variable.ttf"
fontarg="fontfile=$font"
mkdir -p _movie/parts builds
i=0
clip() {  # clip <mark> <offset> <duration>
	local at; at=$(cut_at "$1"); [ -z "$at" ] && { echo "no CUT $1 in the log"; return; }
	local start; start=$(awk -v a="$at" -v o="$2" 'BEGIN{printf "%.2f", a+o}')
	i=$((i + 1)); local out; out=$(printf "_movie/parts/%02d_%s.mp4" "$i" "$1")
	ffmpeg -y -loglevel error -ss "$start" -t "$3" -i "$avi" -an -vf "scale=1280:720,fade=t=in:st=0:d=0.4,fade=t=out:st=$(awk -v d="$3" 'BEGIN{printf "%.2f", d-0.4}'):d=0.4,format=yuv420p" -r 30 -c:v libx264 -crf 20 -preset medium "$out"
	echo "$out" >> _movie/parts/list.txt
}
card() {  # card <big text> <small text> <seconds>
	i=$((i + 1)); local out; out=$(printf "_movie/parts/%02d_card.mp4" "$i")
	ffmpeg -y -loglevel error -f lavfi -i "color=c=0x14101c:s=1280x720:d=$3:r=30" -vf "drawtext=$fontarg:text='$1':fontcolor=0xe8b04a:fontsize=64:x=(w-text_w)/2:y=(h-text_h)/2-40,drawtext=$fontarg:text='$2':fontcolor=0xf3e9d2:fontsize=30:x=(w-text_w)/2:y=(h-text_h)/2+50,fade=t=in:st=0:d=0.5,fade=t=out:st=$(awk -v d="$3" 'BEGIN{printf "%.2f", d-0.5}'):d=0.5,format=yuv420p" -c:v libx264 -crf 20 -preset medium "$out"
	echo "$out" >> _movie/parts/list.txt
}
rm -f _movie/parts/*.mp4 _movie/parts/list.txt
# The Gainlands walk ran into the gatekeeper's duel and "dev travel capital" lands inside the Crease, so those two clips are left out.
card "THE WAYWARD PATH" "a cozy deckbuilding RPG" 3.5
clip title 1.0 4
clip crosspath 1.0 6
clip deck_station -1.8 3.5
card "Four strange lands" "to walk, free and win back" 3
clip buffet 1.0 5.5
clip battle 1.5 12
clip gallery 1.0 4.5
card "Free on itch.io" "donations welcome - never needed" 4
total=$(awk 'BEGIN{t=3.5+4+6+3.5+3+5.5+12+4.5+4; print t}')
sed 's#^#file #' _movie/parts/list.txt | sed "s#file \(.*\)#file '$root/\1'#" > _movie/parts/concat.txt
ffmpeg -y -loglevel error -f concat -safe 0 -i _movie/parts/concat.txt -i assets/audio/music/MUS-TITLE.ogg \
	-filter_complex "[1:a]atrim=0:$total,afade=t=in:st=0:d=1,afade=t=out:st=$(awk -v t="$total" 'BEGIN{printf "%.2f", t-3}'):d=3,volume=0.9[a]" \
	-map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k -shortest builds/trailer_rc1.mp4
ffmpeg -y -loglevel error -ss 8 -i builds/trailer_rc1.mp4 -frames:v 1 builds/trailer_rc1_poster.jpg
ls -la builds/trailer_rc1.mp4 builds/trailer_rc1_poster.jpg
ffprobe -v error -show_entries format=duration -of csv=p=0 builds/trailer_rc1.mp4
