class_name ZoneDefs
extends RefCounted
## Registry of the playable zones (`ZoneDef`s), keyed by zone id (the same ids as `ZonePortals`). `ids()` are the four Path
## zones (the ones the player frees; `ZoneCompletion` counts them); `all_ids()` adds the Capital (the final area).

static var _cache: Dictionary = {}


## The four Path zones.
static func ids() -> Array[String]:
	return [DnaZone.ID, GainlandsZone.ID, BuffetZone.ID, HeapZone.ID]


## Every zone with a def: the four Path zones and the Capital.
static func all_ids() -> Array[String]:
	return [DnaZone.ID, GainlandsZone.ID, BuffetZone.ID, HeapZone.ID, CapitalZone.ID]


static func has_def(zone_id: String) -> bool:
	return all_ids().has(zone_id)


static func get_def(zone_id: String) -> ZoneDef:
	if not _cache.has(zone_id):
		match zone_id:
			GainlandsZone.ID:
				_cache[zone_id] = GainlandsZone.build_def()
			HeapZone.ID:
				_cache[zone_id] = HeapZone.build_def()
			BuffetZone.ID:
				_cache[zone_id] = BuffetZone.build_def()
			CapitalZone.ID:
				_cache[zone_id] = CapitalZone.build_def()
			_:
				_cache[zone_id] = DnaZone.build_def()
	return _cache[zone_id] as ZoneDef


## The def of the zone the player is in right now (the D.N.A. when not in any zone - tests).
static func current() -> ZoneDef:
	if Session.zone_run != null:
		return get_def(Session.zone_run.zone_id)
	return get_def(DnaZone.ID)
