#!/usr/bin/env bash
# Icon integration verification shots (docs/art/art_pipeline.md, "Icons"): every screen the icon set touches at the default window and a smaller one. One Godot process at a time.
# Usage: bash tools/icon_verify.sh [WxH ...]   (default: 1600x900 1024x768)  ->  _screenshots/icon_verify/<screen>_<WxH>.png
cd "$(dirname "$0")/.."
mkdir -p _screenshots/icon_verify
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	shot() { # name scene args...
		local name="$1" scene="$2"; shift 2
		bash tools/shot.sh "$scene" "icon_verify/${name}_${size}" --size="$size" "$@" | grep -E "SCRIPT ERROR|Parse Error" | grep -v "PackedStringArray"
	}
	shot battle res://scenes/battle.tscn --ctx=zone:beefcake --enemy="Cave Scavenger" --zone=gainlands --give=iron:2,redtape:1,ingredient:3,garbage:2,contract:2 --hand=BR-12,G-27,G-01,B-01 --field=BR-12,G-27,B-01 --mark=exhaust:0,buff:1:3 --energy=1 --keep=true --hover=hand:0 --wait=8
	shot battle_tooltip res://scenes/battle.tscn --ctx=zone:beefcake --hand=BR-12,G-27,G-01,B-01 --field=BR-12,G-27,B-01 --give=iron:1,contract:1 --energy=1 --keep=true --hover=field:0 --wait=8
	shot deck res://scenes/town.tscn --open=deck --wait=3
	shot character res://scenes/town.tscn --open=character --wait=3
	shot character_gear res://scenes/town.tscn --open=character_gear --wait=3
	shot vendor res://scenes/town.tscn --open=vendor --wait=3
	shot equipment_vendor res://scenes/town.tscn --open=equipment_vendor --wait=3
	shot item_vendor res://scenes/town.tscn --open=item_vendor --wait=3
	shot pack_vendor res://scenes/town.tscn --open=pack_vendor --wait=3
	shot alchemist res://scenes/town.tscn --open=alchemist --wait=3
	shot chest_popup res://scenes/town.tscn --open=chest_popup --wait=3
	shot quest_popup res://scenes/town.tscn --open=quest_popup --wait=3
	shot level_popup res://scenes/town.tscn --open=level_popup --wait=3
	shot pause res://scenes/town.tscn --open=pause --wait=3
	shot quests res://scenes/town.tscn --open=quests --wait=3
	shot map_town res://scenes/town.tscn --open=map_all --wait=3
	shot hud_town res://scenes/town.tscn --open=reveal --wait=3
	shot map_gainlands res://scenes/gainlands_zone.tscn --open=map_all --wait=4
	shot hud_gainlands res://scenes/gainlands_zone.tscn --open=reveal --wait=4
	shot town res://scenes/town.tscn --wait=3
	shot dungeon res://scenes/dungeon_map.tscn --progress=3 --damage=3 --wait=3
done
