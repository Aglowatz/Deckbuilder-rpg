#!/usr/bin/env bash
# "import env kit art": the Environment Kit art (vertical slice) from envkit_dir in data/source/art_config.cfg (read-only on the Drive) to assets/art/env_kit/*.webp,
# then re-imports. Options: --only=ENV-DOOR-01,ENV-SIGN-INN  --out=res://_art_inbox/env_kit_preview/  (see tools/import_env_kit.gd)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/import_env_kit.gd -- "$@" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
