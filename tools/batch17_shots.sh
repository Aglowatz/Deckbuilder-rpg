#!/usr/bin/env bash
# Overnight Nov 18 (Batch 17): "in game" shots for the images that replace art under the same id - the card backs in battle, the packs,
# the tunnel map and its battle board, Maren's three portraits, the hero's two portraits, the Bestiary's Shattered Gallery entries, the
# Hollow Well node and Baron Quadzilla's cut-out. One Godot at a time. Writes docs/overnight_shots/nov18/b17_*.jpg.
cd "$(dirname "$0")/.."
OUT=docs/overnight_shots/nov18
s() { scene="$1"; name="$2"; shift 2; bash tools/shot.sh "$scene" "b17_$name" --wait=5 "$@" 2>&1 | grep -E "SCRIPT ERROR" | head -3
	python -c "from PIL import Image; Image.open('_screenshots/b17_$name.png').convert('RGB').resize((1280,720)).save('$OUT/b17_$name.jpg', quality=82)" 2>/dev/null; }
s res://scenes/town.tscn packs --open=packs --noroamers=true
s res://scenes/battle.tscn battle_backs --bot=2 --fast=true --wait=10
s res://scenes/battle.tscn board_s_cap --board=BB-S-CAP --bot=4 --fast=true --wait=14
s res://scenes/dungeon_map.tscn map_s_cap --dungeon=S-CAP
s res://scenes/dungeon_map.tscn map_tutorial_well --dungeon=D-TUT
for beast in "Echo of Chancellor Clench" "Echo of Hortensia Clipwell" "The Perfect Copy" "Echo of the Rotheart"; do
	s res://scenes/town.tscn "bestiary_${beast// /_}" --open=bestiary "--beast=${beast// /_}" --noroamers=true
done
bash tools/dialogue_shots.sh res://scenes/town.tscn b17 "portrait:NPC-ELDER,portrait:NPC-ELDER~happy,portrait:NPC-ELDER~worried,portrait:NPC-PLAYER~confused,portrait:NPC-PLAYER~determined,portrait:CUT-QUADZILLA" --jpg=true 2>&1 | grep -E "SCRIPT ERROR" | head -3
ls _screenshots | grep "^b17_\|dlg_.*b17\|b17" | head -40
