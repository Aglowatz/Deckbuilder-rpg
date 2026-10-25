#!/usr/bin/env bash
# Performance pass Oct 25 (docs/perf/perf_state.md): every area's numbers at Low / Medium, one Godot at a time, vsync off (tools/perf_probe.gd).
# Usage: bash tools/perf_run.sh <tag> [qualities, default "0 1"] [area,area,...]   -> docs/perf/runs/<tag>.md (table) + <tag>.txt (raw lines)
# Areas: crosspath forest gainlands buffet dna heap capital_out capital_in battle dungeon_map deck_station collection vendor
cd "$(dirname "$0")/.."
tag="$1"
qualities="${2:-0 1}"
only="${3:-crosspath,forest,gainlands,buffet,dna,heap,capital_out,capital_in,battle,dungeon_map,deck_station,collection,vendor}"
mkdir -p docs/perf/runs
out="docs/perf/runs/$tag.md"
raw="docs/perf/runs/$tag.txt"
names=(Low Medium High)
: > "$raw"
echo "| Area | Q | avg fps | 1% low | avg ms | CPU ms | GPU ms | draw calls | objects | nodes | load ms | worst ms | RAM MB | VRAM MB | tex MB |" > "$out"
echo "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|" >> "$out"

val() { echo "$1" | sed -n "s/.* $2=\([-0-9.]*\).*/\1/p"; }

run() {
	local area="$1" scene="$2"; shift 2
	case ",$only," in *",$area,"*) ;; *) return ;; esac
	for q in $qualities; do
		taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
		local text line
		text=$(timeout 300 /c/Tools/Godot/Godot_v4.7.2-stable_win64.exe --path . -s res://tools/perf_probe.gd -- --scene="res://scenes/$scene.tscn" --quality="$q" --area="$area" "$@" 2>&1)
		line=$(echo "$text" | grep "^perf_probe:" | tail -1)
		echo "$line" >> "$raw"
		echo "| $area | ${names[$q]} | $(val "$line" avg_fps) | $(val "$line" low1_fps) | $(val "$line" avg_ms) | $(val "$line" cpu_ms) | $(val "$line" gpu_ms) | $(val "$line" draw_calls) | $(val "$line" objects) | $(val "$line" nodes) | $(val "$line" load_ms) | $(val "$line" worst_ms) | $(val "$line" ram_mb) | $(val "$line" vram_mb) | $(val "$line" tex_mb) |" | tee -a "$out"
	done
}

run crosspath town --pos=25.2,19.5 --quiet=true
run forest starting_area --quiet=true --pos=1.6,-2.0
run gainlands gainlands_zone
run buffet buffet_zone
run dna dna_zone
run heap heap_zone
run capital_out capital_zone
run capital_in capital_zone --gate=true --at=gate_inside
run battle battle --zone=beefcake --enemy="Cave Scavenger" --keep=true --no_tutorial=true
run dungeon_map dungeon_map --mini=necrocrat --tip=false
run deck_station town --pos=25.2,19.5 --quiet=true --open=deck
run collection town --pos=25.2,19.5 --quiet=true --open=codex
run vendor town --pos=25.2,19.5 --quiet=true --open=vendor
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
echo "written: $out"
