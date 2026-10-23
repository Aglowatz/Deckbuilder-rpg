#!/usr/bin/env bash
# Overnight Oct 22, Part 5: the windowed bots on an EXPORTED test pack (the release export plus tools/, see tools/export_test_pack.sh),
# run by the stock Godot binary of the same version from a folder outside the project. One Godot at a time.
#   bash tools/run_exported_suite.sh <pck> <d3d12|vulkan> <0|1|2|safe> <playtest|tour|story|shot> [extra args for the shot tool]
# Quality 0 = Low, 1 = Medium, 2 = High; "safe" = Medium settings with Safe Mode forced (WAYWARD_BOOT_GUARD=1, -- --safe-mode).
# The player's settings.cfg and boot_state.cfg are backed up and restored, so a test run never changes the real game.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
pck="$1"; driver="$2"; quality="$3"; bot="$4"; shift 4
user_dir="$APPDATA/Deckbuilder-RPG"
mkdir -p _screenshots/exported "$user_dir"
for f in settings.cfg boot_state.cfg; do
	if [ -f "$user_dir/$f" ]; then cp -f "$user_dir/$f" "$user_dir/$f.suite_backup"; fi
done
q="$quality"; [ "$quality" = "safe" ] && q=1
printf "[video]\n\nquality=%s\n\n[meta]\n\nversion=2\n" "$q" > "$user_dir/settings.cfg"
rm -f "$user_dir/boot_state.cfg"
user_tail=""
env_guard=""
if [ "$quality" = "safe" ]; then user_tail="-- --safe-mode"; env_guard="1"; fi
case "$bot" in
	playtest) scene="res://tools/playtest_launcher.tscn"; limit=420; size=1600x900 ;;
	tour) scene="res://tools/tour_bot_launcher.tscn"; limit=1500; size=1280x720 ;;
	story) scene="res://tools/story_playthrough_launcher.tscn"; limit=900; size=1600x900 ;;
	shot) scene=""; limit=180; size=1600x900 ;;
	*) echo "unknown bot $bot"; exit 2 ;;
esac
tag="${bot}_${driver}_${quality}"
out="$(pwd)/_screenshots/exported/${tag}.log"
run_dir="$(mktemp -d)"
mkdir -p "$run_dir/_screenshots"  # res:// paths resolve to this folder when running a pack
start=$(date +%s)
if [ "$bot" = "shot" ]; then
	# shellcheck disable=SC2086
	(cd "$run_dir" && WAYWARD_BOOT_GUARD="$env_guard" timeout "$limit" "$GODOT" --main-pack "$pck" --resolution "${SHOT_RES:-$size}" --rendering-driver "$driver" -s "${SHOT_SCRIPT:-res://tools/screenshot.gd}" -- "$@" > "$out" 2>&1)
else
	# shellcheck disable=SC2086
	(cd "$run_dir" && WAYWARD_BOOT_GUARD="$env_guard" timeout "$limit" "$GODOT" --main-pack "$pck" --resolution "$size" --rendering-driver "$driver" "$scene" $user_tail > "$out" 2>&1)
fi
code=$?
# Shots and reports land in the run folder (res:// is the read-only pack): keep the pictures.
find "$run_dir" -name "*.png" -exec cp -f {} _screenshots/exported/ \; 2>/dev/null
rm -rf "$run_dir"
for f in settings.cfg boot_state.cfg; do
	if [ -f "$user_dir/$f.suite_backup" ]; then mv -f "$user_dir/$f.suite_backup" "$user_dir/$f"; else rm -f "$user_dir/$f"; fi
done
echo "exported_suite: $tag exit=$code $(( $(date +%s) - start ))s log=$out"
grep -E "^(playtest_smoke|tour_bot|playthrough):|SCRIPT ERROR|SAFE MODE|Rendering Driver|Device:" "$out" | grep -v "BUG: Unreferenced\|leaked\|still in use" | tail -40
exit $code
