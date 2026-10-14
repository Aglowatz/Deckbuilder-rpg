#!/usr/bin/env bash
# Before/after screenshots for the build-size work: bash tools/size_compare_shots.sh <before|after>
# -> _screenshots/sizecheck/<tag>/{title,town,battle,dialogue,vendor}.png (1920x1080). One Godot process at a time.
cd "$(dirname "$0")/.."
tag="${1:-after}"
out="_screenshots/sizecheck"
mkdir -p "$out/$tag"
S="--size=1920x1080"
bash tools/shot.sh res://scenes/title.tscn "sizecheck/$tag/title" $S --wait=3 | grep -E "saved|rror"
bash tools/shot.sh res://scenes/town.tscn "sizecheck/$tag/town" $S --wait=4 | grep -E "saved|rror"
bash tools/shot.sh res://scenes/battle.tscn "sizecheck/$tag/battle" $S --bot=0 --wait=6 --hover=960,930 | grep -E "saved|rror"
bash tools/shot.sh res://scenes/town.tscn "sizecheck/$tag/vendor" $S --wait=3 --open=vendor | grep -E "saved|rror"
bash tools/dialogue_shots.sh res://scenes/town.tscn "sz_$tag" "npc:NPC-AGNES" $S | grep -E "saved|rror"
