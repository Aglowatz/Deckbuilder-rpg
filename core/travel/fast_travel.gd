class_name FastTravel
extends RefCounted
## The Beefcake Rift Express (brief 10b): fast travel between the main town and the towns (hubs) of the zones. One station stands in
## Crosspath from the start; reaching the hub of a zone for the first time unlocks that zone's station, and from then on every
## station can rip a portal to every other unlocked one. Pure rules only: the scenes build the stations (`FastTravelStation`), the
## screen lists them (`FastTravelScreen`), `Session.fast_travel_to` moves the player. All text lives in the shared story file
## (`travel.*` keys in data/story/intro_story.tres).

## The station in the main town (always unlocked).
const TOWN: String = "town"
## How close to a zone's station the player must walk for that zone's station to unlock ("you reached the town").
const UNLOCK_RADIUS: float = 9.0
## The anchor every zone layout names for its station.
const ANCHOR: String = "rift_station"
## Rip shout lines `travel.rip.1` ... `travel.rip.N`.
const RIP_LINES: int = 4


## Every station, in menu order: the town first, then the zones in the order the town lists them.
static func station_ids() -> Array[String]:
	var result: Array[String] = [TOWN]
	result.append_array(ZoneDefs.all_ids())
	return result


static func is_zone_station(station_id: String) -> bool:
	return station_id != TOWN and ZoneDefs.has_def(station_id)


static func unlock_flag(station_id: String) -> StringName:
	return StringName("rift_station_%s" % station_id)


static func is_unlocked(flags: Dictionary, station_id: String) -> bool:
	if station_id == TOWN:
		return true
	return is_zone_station(station_id) and bool(flags.get(str(unlock_flag(station_id)), false))


## Unlocks a zone's station. Returns true only the first time.
static func unlock(flags: Dictionary, station_id: String) -> bool:
	if not is_zone_station(station_id) or is_unlocked(flags, station_id):
		return false
	flags[str(unlock_flag(station_id))] = true
	return true


static func unlocked_ids(flags: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for station_id: String in station_ids():
		if is_unlocked(flags, station_id):
			result.append(station_id)
	return result


## Where `here` can rip to: every other unlocked station.
static func destinations(flags: Dictionary, here: String) -> Array[String]:
	var result: Array[String] = []
	for station_id: String in unlocked_ids(flags):
		if station_id != here:
			result.append(station_id)
	return result


static func can_travel(flags: Dictionary, here: String, destination: String) -> bool:
	return destination != here and is_unlocked(flags, destination)
