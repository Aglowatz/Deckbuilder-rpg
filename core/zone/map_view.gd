class_name MapView
extends RefCounted
## Pure rules for what a map may show (no scene tree): which points of interest are visible given the
## fog of war. Secrets (hidden chests) are not `MapPoi`s at all, so they can never pass through here.


## Fix pass Nov 7 (owner decision D5): shops, exits and travel points, quest givers with a quest, and a zone's landmarks (dungeons, the
## arena, healing spots) always show, fog or not; everything else once its ground is revealed.
const ALWAYS_SHOWN: Array[MapPoi.Kind] = [MapPoi.Kind.VENDOR, MapPoi.Kind.EXIT, MapPoi.Kind.TRAVEL_PORTAL, MapPoi.Kind.TRAVEL_THROW,
	MapPoi.Kind.DUNGEON, MapPoi.Kind.MINI_DUNGEON, MapPoi.Kind.ARENA, MapPoi.Kind.HEAL]


static func always_shown(poi: MapPoi) -> bool:
	return poi.objective or poi.quest_marker or poi.path_tint.a > 0.0 or ALWAYS_SHOWN.has(poi.kind)


## POIs that are always shown, plus the others standing on revealed ground.
static func visible_pois(pois: Array[MapPoi], fog: FogOfWar) -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for poi: MapPoi in pois:
		if always_shown(poi) or fog.is_revealed(Vector2(poi.pos.x, poi.pos.z)):
			result.append(poi)
	return result


## The legend: every POI kind that is currently visible, in enum order.
static func legend_kinds(visible: Array[MapPoi]) -> Array[MapPoi.Kind]:
	var result: Array[MapPoi.Kind] = []
	for kind_value: int in MapPoi.Kind.values():
		for poi: MapPoi in visible:
			if poi.kind == kind_value:
				result.append(kind_value as MapPoi.Kind)
				break
	return result
