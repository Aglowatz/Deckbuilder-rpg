#!/usr/bin/env bash
# Performance pass Oct 25 (docs/perf/perf_state.md): the same camera spots before / after each change, PNG at 1280x720, no HUD
# (UI screens with their HUD), for tools/pixel_diff.gd. Usage: bash tools/perf_shots.sh <tag> [area,area,...]  -> _screenshots/perf/<tag>/<area>.png
# Areas: crosspath forest gainlands buffet dna heap capital_out capital_in battle dungeon_map deck_station collection vendor
# Extra env as tools/shot.sh: STYLE_QUALITY=0|1|2 (default: Medium here), WAYWARD_BUILD_CACHE=off|rebuild.
cd "$(dirname "$0")/.."
tag="$1"
only="${2:-crosspath,forest,gainlands,buffet,dna,heap,capital_out,capital_in,battle,dungeon_map,deck_station,collection,vendor}"
out="_screenshots/perf/$tag"
mkdir -p "$out"
export SHOT_RES=1280x720
export STYLE_QUALITY="${STYLE_QUALITY:-1}"

shoot() {
	local area="$1" scene="$2"; shift 2
	case ",$only," in *",$area,"*) ;; *) return ;; esac
	taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
	rm -f "_screenshots/perf_$area.png"
	timeout 300 bash tools/shot.sh "res://scenes/$scene.tscn" "perf_$area" --size=1280x720 "$@" 2>&1 | grep -E "SCRIPT ERROR|Parse"
	[ -f "_screenshots/perf_$area.png" ] && mv "_screenshots/perf_$area.png" "$out/$area.png" || echo "perf_shots: no shot for $area"
}

C="--set=camera_angle:0,camera_zoom:1.5"
shoot crosspath town --nohud=true --wait=5 --pos=25.2,19.5 --quiet=true $C
shoot forest starting_area --nohud=true --wait=5 --quiet=true --pos=1.6,-2.0 $C
shoot gainlands gainlands_zone --nohud=true --wait=5 $C
shoot buffet buffet_zone --nohud=true --wait=5 $C
shoot dna dna_zone --nohud=true --wait=5 $C
shoot heap heap_zone --nohud=true --wait=5 $C
shoot capital_out capital_zone --nohud=true --wait=5 $C
shoot capital_in capital_zone --nohud=true --wait=5 --gate=true --at=gate_inside $C
shoot battle battle --wait=10 --zone=beefcake --enemy="Cave Scavenger" --keep=true --no_tutorial=true
shoot dungeon_map dungeon_map --wait=4 --mini=necrocrat --tip=false
shoot deck_station town --wait=6 --pos=25.2,19.5 --quiet=true --open=deck $C
shoot collection town --wait=8 --pos=25.2,19.5 --quiet=true --open=codex $C
shoot vendor town --wait=6 --pos=25.2,19.5 --quiet=true --open=vendor $C
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
ls "$out" | wc -l
