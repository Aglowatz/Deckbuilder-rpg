#!/usr/bin/env bash
# The NPC sprite importer (docs/art/world_rollout.md, "import npc sprites"): copies every SPR-<KEY>-* file from the Drive folders in data/source/art_config.cfg
# (`sprites_dir`; read-only, COPIES only), cuts them out, aligns every pose to one foot baseline and scale per character, and writes
# assets/art/world_test/sprites/<KEY>/ + manifest.json and docs/art/npc_sprite_import_report.md (missing and unmatched files).
# Run from the project root: bash tools/import_npc_sprites.sh
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
cfg() { sed -n "s/^$1=\"\(.*\)\"/\1/p" data/source/art_config.cfg | head -1; }
SRC="${SPRITES_SOURCE_DIR:-$(cfg sprites_dir)}"
INBOX="_art_inbox/npc_sprites"
mkdir -p "$INBOX"
copied=0
for file in "$SRC"/SPR-*.png; do
	[ -f "$file" ] || continue
	cp -f "$file" "$INBOX/" && copied=$((copied + 1))
done
echo "npc sprites: copied $copied file(s) into $INBOX (from: $SRC)"
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/world_test_import.gd -- --npcs 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
