#!/usr/bin/env bash
# "import zone kit <zone>": one zone's approved kit art (Approved_ZoneKits/<Zone>, read-only on the Drive; zonekits_dir in data/source/art_config.cfg) to
# assets/art/zone_kits/<zone>/*.webp (surfaces with normal / roughness maps, cut-outs trimmed with pivots, sheets sliced into six, backdrops, concept references under
# docs/art/zone_kits/<zone>/concepts/), the registry data/art/zone_kits/<zone>.json and the report docs/art/zone_kits/<zone>_import_report.md; then re-imports.
#   bash tools/import_zone_kit.sh gainlands [--only=GAIN-WALL-BRICK,GAIN-SHEET-DOORS] [--out=res://_art_inbox/zone_kit_preview/]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
zone="$1"; shift
if [ -z "$zone" ]; then echo "usage: bash tools/import_zone_kit.sh <zone> [--only=ID,ID] [--out=res://...]"; exit 1; fi
"$GODOT" --headless --path . -s res://tools/import_zone_kit.gd -- --zone="$zone" "$@" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
# Folder import rules (docs/build_size_policy.md): compression and right-sizing for the new art.
node "$(dirname "$0")/apply_import_rules.js" && "$GODOT" --headless --path . --import >/dev/null 2>&1
