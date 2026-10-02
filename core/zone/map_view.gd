class_name MapView
extends RefCounted
## Pure rules for what a map may show (no scene tree): which points of interest are visible given the
## fog of war. Secrets (hidden chests) are not `MapPoi`s at all, so they can never pass through here.


## Only POIs standing on revealed ground are visible.
static func visible_pois(pois: Array[MapPoi], fog: FogOfWar) -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for poi: MapPoi in pois:
		if fog.is_revealed(Vector2(poi.pos.x, poi.pos.z)):
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
