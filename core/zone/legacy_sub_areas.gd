class_name LegacySubAreas
extends RefCounted
## The sub-area scenes were removed (docs/design/subarea_removal.md, SR-1): the only walkable areas are the forest, the town, the four Path zones and the
## Capital. A save made inside a sub-area recorded "sub:<area>/<sub>" as its scene; this table says where such a save loads now: the area's main scene
## ("zone:<id>", "town" or "start") and the spot in it where the hub gate to that sub-area stood (its old return point, walkable in the hub's default
## state). A sub-area that had no gate of its own (the Mill Fields hung off the Proving Grounds, the castle grounds off the Capital's Palace Approach,
## the Lab wings off the Hatch Yard) maps to the gate it was reached through. Pure data: no scene tree.

const PREFIX: String = "sub:"

const PLACES: Dictionary = {
	"main_town/residential_lanes": {"kind": "town", "x": 7.0, "z": 22.0},
	"main_town/lakeshore_docks": {"kind": "town", "x": 60.0, "z": 24.0},
	"main_town/chapel_hill": {"kind": "town", "x": -1.3, "z": 38.7},
	"main_town/arena_district": {"kind": "town", "x": 32.0, "z": 44.0},
	"starting_forest/old_path": {"kind": "start", "x": 7.0, "z": 4.6},
	"starting_forest/mossy_hollow": {"kind": "start", "x": 2.2, "z": 3.6},
	"starting_forest/cave_mouth": {"kind": "start", "x": 7.1, "z": 0.8},
	"starting_forest/hidden_tunnel": {"kind": "start", "x": 7.1, "z": 0.8},
	"gainlands/proving_grounds": {"kind": "zone:beefcake", "x": 50.0, "z": 78.0},
	"gainlands/mill_fields": {"kind": "zone:beefcake", "x": 50.0, "z": 78.0},
	"gainlands/swolympus_trailhead": {"kind": "zone:beefcake", "x": 100.5, "z": 24.5},
	"gainlands/sky_garden": {"kind": "zone:beefcake", "x": 50.0, "z": 78.0},
	"dna/cubicle_fields": {"kind": "zone:necrocrat", "x": 55.5, "z": 53.5},
	"dna/the_queue": {"kind": "zone:necrocrat", "x": 34.5, "z": 55.5},
	"dna/records_basement": {"kind": "zone:necrocrat", "x": 70.5, "z": 27.5},
	"dna/executive_approach": {"kind": "zone:necrocrat", "x": 70.5, "z": 27.5},
	"buffet/mashed_potato_hills": {"kind": "zone:gourmand", "x": 78.5, "z": 55.8},
	"buffet/broccoli_forest": {"kind": "zone:gourmand", "x": 25.0, "z": 66.0},
	"buffet/bakery_district": {"kind": "zone:gourmand", "x": 72.5, "z": 68.5},
	"buffet/omakase_cliffs": {"kind": "zone:gourmand", "x": 78.5, "z": 55.8},
	"heap/junk_mountains": {"kind": "zone:refusemancer", "x": 81.0, "z": 62.0},
	"heap/farm_rows": {"kind": "zone:refusemancer", "x": 15.0, "z": 62.0},
	"heap/wildflower_wetlands": {"kind": "zone:refusemancer", "x": 60.0, "z": 57.0},
	"heap/throne_approach": {"kind": "zone:refusemancer", "x": 81.0, "z": 62.0},
	"capital_outside/rift_fields": {"kind": "zone:final", "x": 31.9, "z": 93.2},
	"capital_outside/ruined_outpost": {"kind": "zone:final", "x": 97.0, "z": 92.0},
	"capital_outside/tunnel_entrance": {"kind": "zone:final", "x": 75.2, "z": 91.6},
	"capital_inside/transit_yards": {"kind": "zone:final", "x": 97.7, "z": 56.7},
	"capital_inside/hungry_quarter": {"kind": "zone:final", "x": 98.2, "z": 34.2},
	"capital_inside/grave_row": {"kind": "zone:final", "x": 25.0, "z": 34.0},
	"capital_inside/palace_approach": {"kind": "zone:final", "x": 59.3, "z": 20.3},
	"castle_grounds/courtyard": {"kind": "zone:final", "x": 59.3, "z": 20.3},
	"castle_grounds/mirror_colonnade": {"kind": "zone:final", "x": 59.3, "z": 20.3},
	"castle_grounds/grand_stair": {"kind": "zone:final", "x": 59.3, "z": 20.3},
	"castle_grounds/palace_gardens": {"kind": "zone:final", "x": 59.3, "z": 20.3},
	"pathology_lab/hatch_yard": {"kind": "start", "x": 5.4, "z": 5.6},
	"pathology_lab/decontamination_corridor": {"kind": "start", "x": 5.4, "z": 5.6},
	"pathology_lab/specimen_gallery": {"kind": "start", "x": 5.4, "z": 5.6},
	"pathology_lab/records_break_room": {"kind": "start", "x": 5.4, "z": 5.6},
	"pathology_lab/glass_tank_hall": {"kind": "start", "x": 5.4, "z": 5.6},
}

## The main areas a legacy token may name, and the main scene each loads ("" = the town).
const AREA_KINDS: Dictionary = {
	"main_town": "town", "starting_forest": "start", "gainlands": "zone:beefcake", "dna": "zone:necrocrat", "buffet": "zone:gourmand",
	"heap": "zone:refusemancer", "capital_outside": "zone:final", "capital_inside": "zone:final", "castle_grounds": "zone:final", "pathology_lab": "start",
}


static func is_token(value: String) -> bool:
	return value.begins_with(PREFIX)


## Where a legacy scene token loads: {} for anything that is not a "sub:" token; {"kind": "zone:<id>" | "town" | "start", "position": Vector3} for a known
## sub-area; {"kind": ...} without a position for a known area with an unknown sub-area (the hub's own spawn is used); {"kind": "town"} for the rest.
static func resolve(value: String) -> Dictionary:
	if not is_token(value):
		return {}
	var key: String = value.trim_prefix(PREFIX)
	if PLACES.has(key):
		var place: Dictionary = PLACES[key] as Dictionary
		return {"kind": str(place["kind"]), "position": Vector3(float(place["x"]), 0.0, float(place["z"]))}
	var area: String = key.get_slice("/", 0)
	if AREA_KINDS.has(area):
		return {"kind": str(AREA_KINDS[area])}
	return {"kind": "town"}
