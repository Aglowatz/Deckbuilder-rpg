class_name MapPoi
extends RefCounted
## A point of interest on the minimap / full map. The Kind enum is deliberately a WHITELIST: there is
## no kind for hidden chests or any other secret, so a secret cannot be put on the map by accident.
## A POI is only drawn once the fog of war has revealed the cell it stands on.

enum Kind {
	VENDOR,
	HEAL,
	QUEST_GIVER,
	DUNGEON,
	MINI_DUNGEON,
	PUZZLE,
	QUIZ,
	MINIGAME,
	EXIT,
	TRAVEL_THROW,
	TRAVEL_PORTAL,
	INTERACTABLE,
}

var kind: Kind = Kind.VENDOR
var pos: Vector3 = Vector3.ZERO
var label: String = ""
## Quest givers: a "!" marker while they have a quest available (or ready to hand in).
var quest_marker: bool = false
## Travel points: locked ones draw dimmed.
var locked: bool = false


static func make(poi_kind: Kind, position: Vector3, poi_label: String, marker: bool = false, is_locked: bool = false) -> MapPoi:
	var poi: MapPoi = MapPoi.new()
	poi.kind = poi_kind
	poi.pos = position
	poi.label = poi_label
	poi.quest_marker = marker
	poi.locked = is_locked
	return poi


## Legend entry (name + a one-letter glyph) for the full map; also used to draw the icons.
static func kind_name(poi_kind: Kind) -> String:
	match poi_kind:
		Kind.VENDOR:
			return "Vendor"
		Kind.HEAL:
			return "Healing spot"
		Kind.QUEST_GIVER:
			return "Quest giver"
		Kind.DUNGEON:
			return "Dungeon entrance"
		Kind.MINI_DUNGEON:
			return "Mini dungeon"
		Kind.PUZZLE:
			return "Puzzle"
		Kind.QUIZ:
			return "Quiz master"
		Kind.MINIGAME:
			return "Minigame"
		Kind.EXIT:
			return "Exit / portal"
		Kind.TRAVEL_THROW:
			return "Thrower"
		Kind.TRAVEL_PORTAL:
			return "Portal ripper"
		Kind.INTERACTABLE:
			return "Interactable"
	return "?"


static func kind_glyph(poi_kind: Kind) -> String:
	match poi_kind:
		Kind.VENDOR:
			return "$"
		Kind.HEAL:
			return "+"
		Kind.QUEST_GIVER:
			return "Q"
		Kind.DUNGEON:
			return "D"
		Kind.MINI_DUNGEON:
			return "d"
		Kind.PUZZLE:
			return "P"
		Kind.QUIZ:
			return "?"
		Kind.MINIGAME:
			return "G"
		Kind.EXIT:
			return "E"
		Kind.TRAVEL_THROW:
			return "T"
		Kind.TRAVEL_PORTAL:
			return "O"
		Kind.INTERACTABLE:
			return "*"
	return "?"


static func kind_color(poi_kind: Kind) -> Color:
	match poi_kind:
		Kind.VENDOR:
			return Color("f2c94c")
		Kind.HEAL:
			return Color("5fd47a")
		Kind.QUEST_GIVER:
			return Color("f2994a")
		Kind.DUNGEON, Kind.MINI_DUNGEON:
			return Color("e0605a")
		Kind.PUZZLE:
			return Color("b48cf0")
		Kind.QUIZ:
			return Color("6ec1f0")
		Kind.MINIGAME:
			return Color("f06ec1")
		Kind.EXIT:
			return Color("ffffff")
		Kind.TRAVEL_THROW, Kind.TRAVEL_PORTAL:
			return Color("40e0d0")
		Kind.INTERACTABLE:
			return Color("c9c9c9")
	return Color.WHITE
