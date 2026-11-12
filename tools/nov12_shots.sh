#!/usr/bin/env bash
# Fable Nov 12 (Part 0 / Part 6): the fixed shot set, one Godot at a time, through the play-script driver.
#   bash tools/nov12_shots.sh <tag> [set ...]      -> docs/overnight_shots/nov12/<tag>/*.jpg (1280x720)
# Sets (default: all): gainlands buffet dump dna capital_before capital_after town ui dungeons battle_zone_beefcake battle_zone_gourmand
#   battle_zone_refusemancer battle_zone_necrocrat battle_tutorial battle_dungeon_d-pc battle_primm
# Scripts: docs/review/play_scripts/nov12/shots_<set>.txt (the same cameras every run: `dev tp`, `cam 0|3`, `hud off`).
# Needs the dev snapshots n6_midgame, c13castle, c13post in %APPDATA%/Deckbuilder-RPG/dev_saves. About 20 minutes for everything;
# keep it in the foreground in chunks (pass a few sets per call) so a 10-minute tool limit does not background it.
cd "$(dirname "$0")/.."
tag="$1"; shift
if [ -z "$tag" ]; then echo "usage: bash tools/nov12_shots.sh <tag> [set ...]"; exit 2; fi
sets="${*:-gainlands buffet dump dna capital_before capital_after town ui dungeons battle_zone_beefcake battle_zone_gourmand battle_zone_refusemancer battle_zone_necrocrat battle_tutorial battle_dungeon_d-pc battle_primm}"
for s in $sets; do
	taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
	rm -rf "_screenshots/play/n12_${tag}_$s"
	bash tools/play.sh "docs/review/play_scripts/nov12/shots_$s.txt" "n12_${tag}_$s" 320 2>&1 | grep -E "SCRIPT ERROR|NOT FOUND|unknown command|no anchor|exit" | grep -v "(exit 0)" | cut -c1-160
	echo "shots: $s $(ls "_screenshots/play/n12_${tag}_$s"/*.png 2>/dev/null | wc -l)"
done
python - "$tag" <<'EOF'
import glob, os, sys
from PIL import Image
tag = sys.argv[1]
out = os.path.join("docs", "overnight_shots", "nov12", tag)
os.makedirs(out, exist_ok=True)
count = 0
for path in sorted(glob.glob("_screenshots/play/n12_%s_*/*.png" % tag)):
    Image.open(path).convert("RGB").resize((1280, 720), Image.LANCZOS).save(os.path.join(out, os.path.basename(path)[:-4] + ".jpg"), quality=82)
    count += 1
print("shots: %d JPGs in %s" % (count, out))
EOF
