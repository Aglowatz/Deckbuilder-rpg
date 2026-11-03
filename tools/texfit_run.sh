#!/usr/bin/env bash
# Size pass Nov 3, Part 3: how large every 2D texture is drawn on each screen (tools/texfit.gd through tools/screenshot.gd --texfit=true).
# Usage: bash tools/texfit_run.sh [screen,screen,...]   -> _logs/texfit/<screen>.txt, then: node tools/texfit_report.js
# One Godot at a time, windowed 1600x900 (the canvas is 1920x1080 design pixels whatever the window; sizes are reported in design pixels).
cd "$(dirname "$0")/.."
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
only="${1:-}"
mkdir -p _logs/texfit
shot() { # <name> <scene> [args...]
	local name="$1" scene="$2"; shift 2
	if [ -n "$only" ]; then case ",$only," in *",$name,"*) ;; *) return ;; esac; fi
	rm -f "_logs/texfit/$name.txt"
	taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
	timeout 240 "$GODOT" --path . -s res://tools/screenshot.gd -- --scene="res://scenes/$scene.tscn" --name="$name" --texfit=true --jpg=true --wait=4 "$@" 2>&1 | grep -E "^texfit:|screenshot saved|SCRIPT ERROR" | head -3
}
shot title title
shot town_dialogue town --pos=25.2,19.5 --quiet=true --open=dialogue
shot town_vendor town --pos=25.2,19.5 --quiet=true --open=vendor
shot town_item_vendor town --pos=25.2,19.5 --quiet=true --open=item_vendor
shot town_equipment_vendor town --pos=25.2,19.5 --quiet=true --open=equipment_vendor
shot town_tailor town --pos=25.2,19.5 --quiet=true --open=tailor
shot town_pack_vendor town --pos=25.2,19.5 --quiet=true --open=pack_vendor
shot town_deck town --pos=25.2,19.5 --quiet=true --open=deck
shot town_deck_slots town --pos=25.2,19.5 --quiet=true --open=deck_slots
shot town_codex town --pos=25.2,19.5 --quiet=true --open=codex
shot town_codex_gear town --pos=25.2,19.5 --quiet=true --open=codex_gear
shot town_bestiary town --pos=25.2,19.5 --quiet=true --open=bestiary
shot town_bestiary_boss town --pos=25.2,19.5 --quiet=true --open=bestiary_boss
shot town_wardrobe town --pos=25.2,19.5 --quiet=true --open=wardrobe
shot town_character town --pos=25.2,19.5 --quiet=true --open=character
shot town_character_gear town --pos=25.2,19.5 --quiet=true --open=character_gear
shot town_reward_pack town --pos=25.2,19.5 --quiet=true --open=reward_pack
shot town_reward_gold town --pos=25.2,19.5 --quiet=true --open=reward_gold
shot town_pick town --pos=25.2,19.5 --quiet=true --open=pick
shot town_well town --pos=25.2,19.5 --quiet=true --open=well
shot town_gate town --pos=25.2,19.5 --quiet=true --open=gate
shot battle battle --zone=beefcake --enemy="Cave Scavenger" --keep=true --no_tutorial=true
shot battle_lights battle --zone=necrocrat --enemy="Ministry Clerk" --keep=true --no_tutorial=true --lights=true
shot dungeon_map dungeon_map --mini=necrocrat --tip=false
shot ending ending
shot rewards rewards
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
echo "done: _logs/texfit/*.txt"
