#!/usr/bin/env bash
# Graphics Tier 1 (docs/art/graphics_tier1.md): frame time, GPU ms and draw calls of every area at Low / Medium / High, one Godot at a time, vsync off.
# Usage: bash tools/tier1_fps.sh <tag> [qualities, default "0 1 2"] [area,area,...]     -> docs/art/graphics_tier1/fps_<tag>.md (a markdown table)
# Areas: town_square town_street forest gainlands buffet dna heap capital_out capital_in battle dungeon_map
cd "$(dirname "$0")/.."
tag="$1"
qualities="${2:-0 1 2}"
only="${3:-town_square,town_street,forest,gainlands,buffet,dna,heap,capital_out,capital_in,battle,dungeon_map}"
mkdir -p docs/art/graphics_tier1
out="docs/art/graphics_tier1/fps_$tag.md"
names=(Low Medium High)
echo "| Area | Quality | avg fps | avg ms | p95 ms | min fps | GPU ms | CPU ms | draw calls | objects |" > "$out"
echo "|---|---|---|---|---|---|---|---|---|---|" >> "$out"

run() {
	local area="$1" scene="$2"; shift 2
	case ",$only," in *",$area,"*) ;; *) return ;; esac
	for q in $qualities; do
		taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
		local text
		text=$(timeout 300 bash tools/fps.sh "res://scenes/$scene.tscn" "$q" --seconds=5 "$@" 2>&1)
		local fps ms p95 mn gpu cpu dc obj
		fps=$(echo "$text" | sed -n 's/.*avg_fps=\([0-9.]*\).*/\1/p')
		ms=$(echo "$text" | sed -n 's/.*avg_ms=\([0-9.]*\).*/\1/p')
		p95=$(echo "$text" | sed -n 's/.*p95_ms=\([0-9.]*\).*/\1/p')
		mn=$(echo "$text" | sed -n 's/.*min_fps=\([0-9.]*\).*/\1/p')
		gpu=$(echo "$text" | sed -n 's/.*gpu_ms=\([0-9.]*\).*/\1/p')
		cpu=$(echo "$text" | sed -n 's/.*cpu_ms=\([0-9.]*\).*/\1/p')
		dc=$(echo "$text" | sed -n 's/.*draw_calls=\([0-9]*\).*/\1/p')
		obj=$(echo "$text" | sed -n 's/.*objects=\([0-9]*\) primitives.*/\1/p')
		echo "| $area | ${names[$q]} | ${fps:-?} | ${ms:-?} | ${p95:-?} | ${mn:-?} | ${gpu:-?} | ${cpu:-?} | ${dc:-?} | ${obj:-?} |" | tee -a "$out"
	done
}

run town_square town --pos=25.2,19.5 --quiet=true
run town_street town --pos=9,15 --quiet=true
run forest starting_area --quiet=true --pos=1.6,-2.0
run gainlands gainlands_zone
run buffet buffet_zone
run dna dna_zone
run heap heap_zone
run capital_out capital_zone
run capital_in capital_zone --gate=true --at=gate_inside
run battle battle --zone=beefcake --enemy="Cave Scavenger" --keep=true --no_tutorial=true
run dungeon_map dungeon_map --mini=necrocrat --tip=false
echo "written: $out"
