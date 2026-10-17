#!/usr/bin/env bash
# usage: gl2_shots.sh <phase> ; runs the fixed Gainlands v2 views one Godot at a time
cd /c/Dev/Deckbuilder-rpg
phase="$1"
S=res://scenes/gainlands_zone.tscn
run() { SHOT_RES=1280x720 bash tools/shot.sh $S "gl2_${phase}_$1" --size=1280x720 --nohud=true --wait=2.5 "${@:2}" | grep -i "saved\|error" | head -3; }
run 01_entrance --at=spawn
run 02_center --at=hub
run 03_left --pos=${LEFT:-22,52}
run 04_right --pos=${RIGHT:-84,66}
run 05_fortress --pos=${FORT:-56,22}
run 06_swolympus --pos=${SWOL:-99,28}
run 07_plan --top=${TOP:-56,40,120} --plan=true --nofog=true
