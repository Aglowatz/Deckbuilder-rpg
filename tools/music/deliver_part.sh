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
bash tools/import_audio.sh | tail -6
node tools/cut_stings.js | grep -E "TUNNEL|VAULT|SIPHON|FAILED" || true
node tools/audio_doc.js | tail -2
