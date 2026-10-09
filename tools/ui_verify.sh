#!/usr/bin/env bash
# UI art kit verification shots (docs/art/ui_art_kit.md): every screen the kit touches at the default window and a smaller one. One Godot process at a time.
# Usage: bash tools/ui_verify.sh [WxH ...]   (default: 1600x900 1024x768)  ->  _screenshots/ui_verify/<screen>_<WxH>.png
cd "$(dirname "$0")/.."
mkdir -p _screenshots/ui_verify
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	shot() { # name scene args...
		local name="$1" scene="$2"; shift 2
		bash tools/shot.sh "$scene" "ui_verify/${name}_${size}" --size="$size" "$@" | grep -E "SCRIPT ERROR|Parse Error" 
	}
	shot cards res://scenes/dev/ui_cards_review.tscn
	shot battle_arena res://scenes/battle.tscn --ctx=arena --bot=2 --fast=true --wait=8
	shot battle_gainlands res://scenes/battle.tscn --ctx=zone:beefcake --bot=3 --fast=true --wait=8
	shot deck res://scenes/town.tscn --open=deck --wait=3
	shot character res://scenes/town.tscn --open=character --wait=3
	shot vendor res://scenes/town.tscn --open=vendor --wait=3
	shot pack_vendor res://scenes/town.tscn --open=pack_vendor --wait=3
	shot chest_popup res://scenes/town.tscn --open=chest_popup --wait=3
	shot quest_popup res://scenes/town.tscn --open=quest_popup --wait=3
	shot level_popup res://scenes/town.tscn --open=level_popup --wait=3
	shot pause res://scenes/town.tscn --open=pause --wait=3
	shot quests res://scenes/town.tscn --open=quests --wait=3
	shot map res://scenes/town.tscn --open=map --wait=3
	shot pack_open res://scenes/dev/pack_opening_preview.tscn --stage=pack --pack=gilded_refusemancer
	shot pack_reveal res://scenes/dev/pack_opening_preview.tscn --stage=reveal_all --pack=path_necrocrat
	bash tools/dialogue_shots.sh res://scenes/town.tscn "ui_verify/dialogue_${size}" "npc:NPC-ELDER" --size="$size" | grep -E "SCRIPT ERROR|Parse Error"
done
