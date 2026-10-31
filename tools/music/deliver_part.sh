#!/usr/bin/env bash
# Music Pass 3: deliver one finished part in one go (docs/loop_state.md "Delivery per part").
#   bash tools/music/deliver_part.sh "Batch 06" [--own "ID ID"] ID ID ...
# Previews -> Music Review/<batch>, Approved_Audio (old files backed up to Superseded/Music_v01, registry.json loop records rewritten),
# former aliases dropped from the Drive metadata (--own), levels re-analysed for these IDs only, "import audio", boss stings re-cut,
# the integration doc refreshed. Runs Godot (import) - never while another Godot process is running. Tests and commit are separate.
set -e
cd "$(dirname "$0")/../.."
PY="$LOCALAPPDATA/Programs/Python/Python312/python.exe"
BATCH="$1"; shift
OWN=""
if [ "$1" = "--own" ]; then OWN="$2"; shift 2; fi
IDS=("$@")
"$PY" tools/music/deliver.py --review "$BATCH" --approve "${IDS[@]}"
if [ -n "$OWN" ]; then "$PY" tools/music/deliver.py --own $OWN; fi
ONLY=""
for id in "${IDS[@]}"; do ONLY="$ONLY$id.,"; done
SRC="$(grep '^audio_dir=' data/source/art_config.cfg | sed 's/audio_dir="\(.*\)"/\1/')"
FFDIR="$(dirname "$(command -v ffmpeg 2>/dev/null || ls "$LOCALAPPDATA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin/ffmpeg.exe | head -1)")"
AUDIO_ONLY="$ONLY" node tools/audio_analyze.js "$SRC" "$FFDIR" data/source/audio_levels.csv 2>/dev/null | tail -3
# The importer's ffmpeg calls can fail transiently under load (Oct 31: 22 files dropped while three renders ran): restore the generated
# files and try once more, then stop.
for try in 1 2; do
	LOG="$(bash tools/import_audio.sh 2>&1)"
	if ! echo "$LOG" | grep -q "^Error:" && echo "$LOG" | grep -q "IDs missing a file (0)"; then break; fi
	echo "$LOG" | grep -E "^Error:|missing a file" | cut -c1-200
	git checkout data/audio/audio_registry.json data/source/audio_import_manifest.csv data/source/audio_levels_local.csv
	if [ "$try" = "2" ]; then echo "import failed twice - stopping"; exit 1; fi
done
echo "$LOG" | grep -E "Copied|aliases" | cut -c1-200
node tools/cut_stings.js | grep -E "TUNNEL|VAULT|SIPHON|FAILED" || true
node tools/audio_doc.js | tail -2
