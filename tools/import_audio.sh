#!/usr/bin/env bash
# The audio importer (docs/audio/music_integration.md): copies Approved_Audio from the Drive folder in art_config.cfg (read-only), converts a
# WAV-only loop to OGG with ffmpeg (FFMPEG env or ffmpeg_path in art_config.cfg), regenerates data/audio/audio_registry.json.
# Loudness / loop-seam analysis (optional, refreshes data/source/audio_levels.csv first): bash tools/import_audio.sh --analyze
# Overnight Oct 19-20: new or changed loops go through the drop-in pipeline (loop points, two-pass loudnorm, OGG q5; core/audio/music_drop_in.gd).
#   bash tools/import_audio.sh --dry-run      report what would be copied / processed, write nothing (no Godot re-import either)
#   bash tools/import_audio.sh --no-process   copy new loops verbatim (the pre-Oct 19 behaviour)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
if [ -z "$FFMPEG" ]; then
	FFMPEG="$(command -v ffmpeg 2>/dev/null || ls "$LOCALAPPDATA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin/ffmpeg.exe 2>/dev/null | head -1)"
	export FFMPEG
fi
PASS=()
DRY=0
for arg in "$@"; do
	case "$arg" in
		--analyze)
			SRC="${AUDIO_SOURCE_DIR:-$(grep '^audio_dir=' data/source/art_config.cfg | sed 's/audio_dir="\(.*\)"/\1/')}"
			FFDIR="${FFMPEG_DIR:-$(dirname "$(command -v ffmpeg 2>/dev/null || ls -d "$LOCALAPPDATA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin/ffmpeg.exe | head -1)")}"
			node tools/audio_analyze.js "$SRC" "$FFDIR" data/source/audio_levels.csv 2>/dev/null
			;;
		--dry-run) DRY=1; PASS+=("$arg") ;;
		*) PASS+=("$arg") ;;
	esac
done
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_audio.gd -- "${PASS[@]}" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
if [ "$DRY" = "0" ]; then
	"$GODOT" --headless --path . --import >/dev/null 2>&1
fi
