#!/usr/bin/env bash
# Fade probe on the real scenes (Fable Nov 19, Part 1): walks every walkable cell of every place in the running game (maths only) and
# lists what the occlusion fader lets go see-through, at the default and the Low camera. Fails if anything but a tall occluder can fade.
#   bash tools/run_fade_probe.sh      -> _screenshots/play/fade_probe/stdout.log, docs/review/nov19b/fade_stock_after.txt
# (The builder-level version of the same probe is the GUT test tests/world/test_fade_probe_nov19.gd.)
cd "$(dirname "$0")/.."
script="$(mktemp --suffix=.txt)"
{
	echo "wait 3"; echo "dev newgame"; echo "wait 10"; echo "skip_dialogue"; echo "dev level 12"; echo "wait 5"
	# Fable Nov 21 (Part 6): FADE_TILT=4 runs the whole probe at the steepest of the five camera presets (+14 degrees)
	[ -n "$FADE_TILT" ] && echo "tilt $FADE_TILT"
	echo "fadecat"; echo "fadescan scan_forest 0"
	for row in "crosspath:dev travel town:16" "gainlands:dev travel zone beefcake:18" "buffet:dev travel zone gourmand:18" "dump:dev travel zone refusemancer:18" "dna:dev travel zone necrocrat:18" "capital:dev travel capital:22"; do
		IFS=: read -r name cmd wait <<< "$row"
		echo "$cmd"; echo "wait $wait"; echo "skip_dialogue"; echo "calm"; echo "wait 5"; echo "fadecat"; echo "fadescan scan_$name 0"
	done
} > "$script"
bash tools/play.sh "$script" fade_probe 1500 > /dev/null 2>&1
log=_screenshots/play/fade_probe/stdout.log
mkdir -p docs/review/nov19b
out=docs/review/nov19b/fade_stock_after.txt
[ -n "$FADE_TILT" ] && out="docs/review/fade_probe_tilt${FADE_TILT}_nov21.txt"
grep -E "fadescan|fadecat|tilt:" "$log" | sed 's/^play: *//' > "$out"
grep "fadescan scan_[a-z]*:" "$log"
bad=$(grep "fadescan row" "$log" | grep -vc "tall_occluder")
errors=$(grep -c "SCRIPT ERROR" "$log")
places=$(grep -c "fadescan scan_[a-z]*:" "$log")
echo "fade_probe: $places places, $bad things other than tall occluders can fade, $errors script errors"
[ "$bad" = 0 ] && [ "$errors" = 0 ] && [ "$places" = 7 ]
