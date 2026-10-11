class_name Areas
extends RefCounted
## The places the player travels between (the starting area, the main town, the four Path zones, the Capital, and dungeons) and what the art does for each:
## the loading screen shown while it loads (LOAD-*), the zone title banner shown when entering it (ZONE-TITLE-*) and the name the banner spells.
## A scene that is not an area (the title, a battle, the rewards, the ending) has the empty key "" and never shows either.

const START: String = "start"
const TOWN: String = "town"
const GAINLANDS: String = "gainlands"
const DNA: String = "dna"
const BUFFET: String = "buffet"
const DUMP: String = "dump"
const CAPITAL: String = "capital"
const DUNGEON: String = "dungeon"

const START_SCENE: String = "res://scenes/starting_area.tscn"
const TOWN_SCENE: String = "res://scenes/town.tscn"
const DUNGEON_SCENE: String = "res://scenes/dungeon_map.tscn"

## key -> {loading, banner, name}. The starting area has no loading art of its own and uses the town's (the closest fit), the Path-ology Lab uses the D.N.A.'s (see `loading_id`).
const TABLE: Dictionary = {
	START: {"loading": "LOAD-TOWN", "banner": "ZONE-TITLE-START", "name": "The Forest Clearing"},
	TOWN: {"loading": "LOAD-TOWN", "banner": "ZONE-TITLE-TOWN", "name": "Crosspath"},
	GAINLANDS: {"loading": "LOAD-GAINLANDS", "banner": "ZONE-TITLE-GAINLANDS", "name": "The Gainlands"},
	DNA: {"loading": "LOAD-DNA", "banner": "ZONE-TITLE-DNA", "name": "The Department of Necrotic Affairs"},
	BUFFET: {"loading": "LOAD-BUFFET", "banner": "ZONE-TITLE-BUFFET", "name": "The Endless Buffet"},
	DUMP: {"loading": "LOAD-DUMP", "banner": "ZONE-TITLE-DUMP", "name": "The Verdant Dump"},
	CAPITAL: {"loading": "LOAD-CAPITAL", "banner": "ZONE-TITLE-CAPITAL", "name": "The Capital"},
	DUNGEON: {"loading": "LOAD-DUNGEON", "banner": "", "name": ""},
}

const ZONE_KEYS: Dictionary = {
	"res://scenes/gainlands_zone.tscn": GAINLANDS,
	"res://scenes/dna_zone.tscn": DNA,
	"res://scenes/buffet_zone.tscn": BUFFET,
	"res://scenes/heap_zone.tscn": DUMP,
	"res://scenes/capital_zone.tscn": CAPITAL,
}


## The area a scene file is ("" for a scene that is not an area).
static func key_for_scene(path: String) -> String:
	if path == START_SCENE:
		return START
	if path == TOWN_SCENE:
		return TOWN
	if path == DUNGEON_SCENE:
		return DUNGEON
	return str(ZONE_KEYS.get(path, ""))


## The area of a zone id (`DnaZone.ID`...), "" for an unknown one.
static func key_for_zone(zone_id: String) -> String:
	match zone_id:
		GainlandsZone.ID:
			return GAINLANDS
		DnaZone.ID:
			return DNA
		BuffetZone.ID:
			return BUFFET
		HeapZone.ID:
			return DUMP
		CapitalZone.ID:
			return CAPITAL
	return ""


## The LOAD-* image for an area. `dungeon_id` matters only for `DUNGEON`: the Path-ology Lab has no art of its own and borrows the D.N.A.'s gloomy complex.
static func loading_id(key: String, dungeon_id: String = "") -> String:
	if key == DUNGEON and dungeon_id == PathologyLab.DUNGEON_ID:
		return "LOAD-DNA"
	return str((TABLE.get(key, {}) as Dictionary).get("loading", ""))


static func banner_id(key: String) -> String:
	return str((TABLE.get(key, {}) as Dictionary).get("banner", ""))


## The name the zone title banner spells ("" = no banner for this area).
static func banner_name(key: String) -> String:
	return str((TABLE.get(key, {}) as Dictionary).get("name", ""))


static func keys() -> Array[String]:
	return [START, TOWN, GAINLANDS, DNA, BUFFET, DUMP, CAPITAL, DUNGEON]
