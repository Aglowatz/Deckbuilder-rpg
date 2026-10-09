#!/usr/bin/env bash
# Painted-texture before/after set of one zone (3 angles + one with an NPC dialogue portrait open), small JPEGs in docs/art/screens/textures/<zone>/.
# Usage: bash tools/paint_shots.sh <scene> <zone> <tag> [--dialogue=<token>] [extra shot args, e.g. --at=spawn]
#   tag = before (flat look: --tex=0) | after (painted). One Godot at a time. Output: docs/art/screens/textures/<zone>/<tag>_{a,b,c,dialogue}.jpg
cd "$(dirname "$0")/.."
scene="$1"; zone="$2"; tag="$3"; shift 3
dialogue=""
args=()
for a in "$@"; do
	case "$a" in --dialogue=*) dialogue="${a#--dialogue=}";; *) args+=("$a");; esac
done
tex=1; if [ "$tag" = "before" ]; then tex=0; export NO_PAINT=1; fi
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
taskkill //F //IM Godot_v4.7.2-stable_win64_console.exe >/dev/null 2>&1
out="docs/art/screens/textures/$zone"
mkdir -p "$out" "_screenshots/paint/$zone"
bash tools/shot.sh "$scene" "paint/$zone/${tag}_a" --wait=3 --nohud=true --jpg=true --tex=$tex "${args[@]}" 2>&1 | grep -E "SCRIPT|saved"
bash tools/shot.sh "$scene" "paint/$zone/${tag}_b" --wait=3 --nohud=true --jpg=true --tex=$tex "${args[@]}" --cam=-8,5.5,7 2>&1 | grep -E "SCRIPT|saved"
bash tools/shot.sh "$scene" "paint/$zone/${tag}_c" --wait=3 --nohud=true --jpg=true --tex=$tex "${args[@]}" --cam=6,8,-9 2>&1 | grep -E "SCRIPT|saved"
if [ -n "$dialogue" ]; then
	bash tools/dialogue_shots.sh "$scene" "paint_${zone}_${tag}" "$dialogue" --jpg=true --tex=$tex "${args[@]}"
	cp "_screenshots/dialogue/paint_${zone}_${tag}_${dialogue//[:.\/]/_}.jpg" "$out/${tag}_dialogue.jpg" 2>/dev/null
fi
cp _screenshots/paint/$zone/${tag}_*.jpg "$out/" 2>/dev/null
ls "$out" | grep "^$tag"
