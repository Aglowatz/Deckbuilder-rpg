#!/usr/bin/env bash
# The cosmetics importer (docs/art/world_rollout.md): the six hats and four cloak sets of the clothing vendor.
#   hats    COS-HAT-<WIZARD|WIDEBRIM|TRICORN|LEAFCROWN|CHEF|BOWLER>-<FRONT|FRONTSIDE|SIDE|BACKSIDE|BACK>.png          -> assets/art/cosmetics/hats/<NAME>/<DIR>.png
#   cloaks  SPR-PLAYER-CLOAK-<REDCAPE|TATTERED|ROYAL|PATCHWORK>-<DIR>_<IDLE|WALK>.png (same layout as the default SPR-PLAYER set) -> assets/art/world_test/sprites/PLAYER_CLOAK_<NAME>/
# COPIES only (Drive folders from data/source/art_config.cfg are never modified), then slices / trims, measures head anchors and cloak hues, re-imports and reports which items
# are still missing (those show as "arriving soon" in the shop). Run from the project root: bash tools/import_cosmetics.sh
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
cfg() { sed -n "s/^$1=\"\(.*\)\"/\1/p" data/source/art_config.cfg | head -1; }
SRC_A="${COSMETICS_SOURCE_DIR:-$(cfg cosmetics_dir)}"
SRC_B="$(cfg worldtest_dir)"
INBOX="_art_inbox/cosmetics"
mkdir -p "$INBOX"
copied=0
for dir in "$SRC_A" "$SRC_B"; do
	[ -d "$dir" ] || continue
	for file in "$dir"/COS-HAT-*.png "$dir"/SPR-PLAYER-CLOAK-*.png; do
		[ -f "$file" ] || continue
		cp -f "$file" "$INBOX/" && copied=$((copied + 1))
	done
done
echo "cosmetics: copied $copied file(s) into $INBOX (from: $SRC_A | $SRC_B)"
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/world_test_import.gd -- --cosmetics 2>&1 | grep -E "COS-HAT|PLAYER_CLOAK|PLAYER-CLOAK|Cosmetics inbox|NOTE|canvas" 
"$GODOT" --headless --path . -s res://tools/sprite_anchors.gd 2>&1 | grep "sprite_anchors: PLAYER_CLOAK"
"$GODOT" --headless --path . --import >/dev/null 2>&1
echo "--- status of the ten items"
for hat in WIZARD WIDEBRIM TRICORN LEAFCROWN CHEF BOWLER; do
	n=$(ls assets/art/cosmetics/hats/$hat/*.png 2>/dev/null | wc -l)
	if [ "$n" -ge 5 ]; then echo "hat   $hat: ready"; else echo "hat   $hat: arriving soon ($n of 5 directions)"; fi
done
for cloak in REDCAPE TATTERED ROYAL PATCHWORK; do
	n=$(ls assets/art/world_test/sprites/PLAYER_CLOAK_$cloak/*_IDLE.png 2>/dev/null | wc -l)
	if [ "$n" -ge 5 ]; then echo "cloak $cloak: ready"; else echo "cloak $cloak: arriving soon ($n of 5 idle directions)"; fi
done
