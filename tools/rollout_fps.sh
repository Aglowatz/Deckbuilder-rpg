#!/usr/bin/env bash
# Frame times of every overworld area at the rolled-out look (docs/art/world_rollout.md), one Godot at a time, vsync off.
# Usage: bash tools/rollout_fps.sh [quality 0-2, default 1 = Medium]
cd "$(dirname "$0")/.."
q="${1:-1}"
run() {
	local label="$1" scene="$2"; shift 2
	local line
	line=$(bash tools/fps.sh "res://scenes/$scene.tscn" "$q" --seconds=5 "$@" | grep "fps_probe:" | sed 's/.*quality=[0-9]* //')
	echo "$label|$line"
}
run start starting_area --quiet=true
run town_square town --pos=26.8,15.2
run town_water town --pos=-18,12.5
run dna dna_zone
run gainlands gainlands_zone
run buffet buffet_zone
run heap heap_zone
run capital_out capital_zone
run capital_in capital_zone --gate=true --at=gate_inside
