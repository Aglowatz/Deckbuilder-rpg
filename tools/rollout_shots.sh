#!/usr/bin/env bash
# Screenshot every overworld area at the rolled-out world look (docs/art/world_rollout.md), one Godot at a time.
# Usage: bash tools/rollout_shots.sh <tag> [area,area,...]     output: _screenshots/rollout/<tag>/<area>.png
# Areas: start town_square town_water dna gainlands buffet heap capital_out capital_in
cd "$(dirname "$0")/.."
tag="$1"
only="${2:-start,town_square,town_water,dna,gainlands,buffet,heap,capital_out,capital_in}"
mkdir -p "_screenshots/rollout/$tag"

shoot() {
	local area="$1" scene="$2"; shift 2
	case ",$only," in *",$area,"*) ;; *) return ;; esac
	bash tools/shot.sh "res://scenes/$scene.tscn" "rollout/$tag/$area" --nohud=true --wait=3 "$@" 2>&1 | grep -E "SCRIPT|saved|Parse"
}

shoot start starting_area --quiet=true
shoot town_square town --pos=26.8,15.2
shoot town_water town --pos=-18,12.5
shoot dna dna_zone
shoot gainlands gainlands_zone
shoot buffet buffet_zone
shoot heap heap_zone
shoot capital_out capital_zone
shoot capital_in capital_zone --gate=true --at=gate_inside
