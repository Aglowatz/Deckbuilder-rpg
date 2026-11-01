#!/usr/bin/env bash
# Overnight Oct 31 - Nov 1 (Part 2, the overlap fix): re-render EVERY MUS-/STG- score with the fixed MIDI writer.
#   bash tools/music/rerender_all.sh backup     copy each Approved_Audio/<ID>.ogg|wav to Superseded/Music_v01/<ID>_orch-v1b.<ext> (never overwrites)
#   bash tools/music/rerender_all.sh render     build.py for all IDs in chunks of 12 (log: _logs/music_rerender.log); no Godot
# Delivery afterwards: bash tools/music/deliver_part.sh "Overlap fix" ID ID ... (Godot import: never with another Godot process).
cd "$(dirname "$0")/../.."
PY="$LOCALAPPDATA/Programs/Python/Python312/python.exe"
DRIVE="${WP_DRIVE:-/g/My Drive/Card Game Art}"
mapfile -t IDS < <(ls tools/music/scores | grep -E '^(MUS|STG)-.*\.py$' | sed 's/\.py$//' | sort)
case "$1" in
	backup)
		mkdir -p "$DRIVE/Superseded/Music_v01"
		n=0
		for id in "${IDS[@]}"; do
			for ext in ogg wav; do
				src="$DRIVE/Approved_Audio/$id.$ext"
				dest="$DRIVE/Superseded/Music_v01/${id}_orch-v1b.$ext"
				if [ -f "$src" ] && [ ! -f "$dest" ]; then cp -p "$src" "$dest" && n=$((n + 1)); fi
			done
		done
		echo "backed up $n file(s) as <ID>_orch-v1b to Superseded/Music_v01 (${#IDS[@]} IDs)"
		;;
	render)
		: > _logs/music_rerender.log
		for ((i = 0; i < ${#IDS[@]}; i += 12)); do
			"$PY" tools/music/build.py "${IDS[@]:i:12}" >> _logs/music_rerender.log 2>&1
		done
		grep -c "LUFS" _logs/music_rerender.log
		grep "NEEDS ATTENTION" _logs/music_rerender.log
		;;
	*) echo "usage: bash tools/music/rerender_all.sh backup|render" ;;
esac
