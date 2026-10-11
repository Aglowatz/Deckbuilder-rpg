#!/usr/bin/env bash
# Vendor screen screenshots (Part B of the art integration round): all 12 vendor screens at the default window and a smaller one, plus hover/purchase flourishes.
# Usage: bash tools/vendor_shots.sh [WxH ...]   (default: 1600x900 1024x768)  ->  _screenshots/vendors/<vendor>_<WxH>.png
cd "$(dirname "$0")/.."
mkdir -p _screenshots/vendors
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	shot() { # name scene args...
		local name="$1" scene="$2"; shift 2
		bash tools/shot.sh "$scene" "vendors/${name}_${size}" --size="$size" --wait=3 "$@" | grep -E "SCRIPT ERROR|Parse Error|saved"
	}
	shot sable res://scenes/town.tscn --open=vendor
	shot tonic res://scenes/town.tscn --open=item_vendor
	shot beetsworth res://scenes/town.tscn --open=equipment_vendor
	shot threadwell res://scenes/town.tscn --open=tailor
	shot fenwick res://scenes/town.tscn --open=pack_vendor
	shot alembic res://scenes/town.tscn --open=alchemist
	shot bellows res://scenes/town.tscn --open=arena
	shot benchley res://scenes/gainlands_zone.tscn --open=vendor
	shot ledgerbone res://scenes/dna_zone.tscn --open=vendor
	shot mirepoix res://scenes/buffet_zone.tscn --open=vendor
	shot gristle res://scenes/heap_zone.tscn --open=vendor
	shot figsly res://scenes/capital_zone.tscn --open=vendor
	shot figsly_crate res://scenes/capital_zone.tscn --open=supplies
done
