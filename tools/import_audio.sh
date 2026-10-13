#!/usr/bin/env bash
# The audio importer (docs/audio/music_integration.md): copies Approved_Audio from the Drive folder in art_config.cfg (read-only), converts a
# WAV-only loop to OGG with ffmpeg (FFMPEG env or ffmpeg_path in art_config.cfg), regenerates data/audio/audio_registry.json.
# Loudness / loop-seam analysis (optional, refreshes data/source/audio_levels.csv first): bash tools/import_audio.sh --analyze
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
if [ -z "$FFMPEG" ]; then
	FFMPEG="$(command -v ffmpeg 2>/dev/null || ls "$LOCALAPPDATA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin/ffmpeg.exe 2>/dev/null | head -1)"
	export FFMPEG
fi
if [ "$1" = "--analyze" ]; then
	SRC="${AUDIO_SOURCE_DIR:-$(grep '^audio_dir=' data/source/art_config.cfg | sed 's/audio_dir="\(.*\)"/\1/')}"
	FFDIR="${FFMPEG_DIR:-$(dirname "$(command -v ffmpeg 2>/dev/null || ls -d "$LOCALAPPDATA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin/ffmpeg.exe | head -1)")}"
	node tools/audio_analyze.js "$SRC" "$FFDIR" data/source/audio_levels.csv 2>/dev/null
fi
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_audio.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
