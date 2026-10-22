#!/usr/bin/env bash
# Graphics Tier 1 (docs/art/graphics_tier1.md): the same camera spots for every before/after set, 1280x720, no HUD, JPEG.
# Usage: bash tools/tier1_shots.sh <tag> [area,area,...]     output: docs/art/graphics_tier1/<tag>/<area>.jpg
# Areas: town_square town_street forest gainlands buffet dna heap capital_out capital_in battle dungeon_map
# One Godot at a time (each shot is its own run, foreground). Extra env: STYLE_QUALITY=0|1|2 (default: the saved setting).
cd "$(dirname "$0")/.."
tag="$1"
only="${2:-town_square,town_street,forest,gainlands,buffet,dna,heap,capital_out,capital_in,battle,dungeon_map}"
out="docs/art/graphics_tier1/$tag"
mkdir -p "$out"
export SHOT_RES=1280x720

shoot() {
	local area="$1" scene="$2"; shift 2
	case ",$only," in *",$area,"*) ;; *) return ;; esac
	taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
	timeout 300 bash tools/shot.sh "res://scenes/$scene.tscn" "t1_$area" --jpg=true --size=1280x720 "$@" 2>&1 | grep -E "SCRIPT ERROR|saved|Parse"
	[ -f "_screenshots/t1_$area.jpg" ] && mv "_screenshots/t1_$area.jpg" "$out/$area.jpg"
}

shoot town_square town --nohud=true --wait=5 --pos=25.2,19.5 --set=camera_angle:0,camera_zoom:1.5
shoot town_street town --nohud=true --wait=5 --pos=9,15 --set=camera_angle:0,camera_zoom:1.5
shoot forest starting_area --nohud=true --wait=5 --quiet=true --pos=1.6,-2.0 --set=camera_angle:0,camera_zoom:1.5
shoot gainlands gainlands_zone --nohud=true --wait=5 --set=camera_angle:0,camera_zoom:1.5
shoot buffet buffet_zone --nohud=true --wait=5 --set=camera_angle:0,camera_zoom:1.5
shoot dna dna_zone --nohud=true --wait=5 --set=camera_angle:0,camera_zoom:1.5
shoot heap heap_zone --nohud=true --wait=5 --set=camera_angle:0,camera_zoom:1.5
shoot capital_out capital_zone --nohud=true --wait=5 --set=camera_angle:0,camera_zoom:1.5
shoot capital_in capital_zone --nohud=true --wait=5 --gate=true --at=gate_inside --set=camera_angle:0,camera_zoom:1.5
shoot battle battle --wait=10 --zone=beefcake --enemy="Cave Scavenger" --keep=true --no_tutorial=true
shoot dungeon_map dungeon_map --wait=4 --mini=necrocrat --tip=false
ls "$out" | wc -l
