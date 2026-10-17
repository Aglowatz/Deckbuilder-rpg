class_name Gatekeepers
extends RefCounted
## Overnight Oct 16: the four zone gatekeepers - the corrupted envoys (`CorruptedNpcs`) now stand at the obstacle that blocks their zone's road
## out of the hub. Beating one sets the same unlock flag as before (`CorruptedNpcs.unlock_flag`) and clears the obstacle for good; it is
## also the first step of that zone's MAIN quest. The Capital has no gatekeeper (its road is open from the start; the broken services are
## the challenge). Data only: the hub builds the obstacles (`HubObstacles`), dialogue lives in the intro story file ("gate.<id>.*").

enum Obstacle { BRIDGE, BARRIER, PANTRY_DOOR, THORNS }

## Zone id -> what blocks the road, the gatekeeper's epithet and the obstacle's player-facing name.
const INFO: Dictionary = {
	"beefcake": {"obstacle": Obstacle.BRIDGE, "epithet": "the Muscley Gatekeeper", "obstacle_name": "the drawn-up gorge bridge", "road": "the meadow road"},
	"necrocrat": {"obstacle": Obstacle.BARRIER, "epithet": "Checkpoint Supervisor", "obstacle_name": "the permit barrier", "road": "the cracked road"},
	"gourmand": {"obstacle": Obstacle.PANTRY_DOOR, "epithet": "Keeper of the Pantry Key", "obstacle_name": "the great pantry door", "road": "the orchard lane"},
	"refusemancer": {"obstacle": Obstacle.THORNS, "epithet": "the Corrupted Druid", "obstacle_name": "the thorn wall", "road": "the forest path"},
}
## The order the zones are listed (the Quest Log, the playthrough bot): the meadow, the office, the kitchen, the dump.
const IDS: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer"]


static func has(zone_id: String) -> bool:
	return INFO.has(zone_id)


static func display_name(zone_id: String) -> String:
	return CorruptedNpcs.display_name(zone_id)


## "Brick Bronson, the Muscley Gatekeeper".
static func full_title(zone_id: String) -> String:
	return "%s, %s" % [display_name(zone_id), str((INFO.get(zone_id, {}) as Dictionary).get("epithet", "Gatekeeper"))]


static func epithet(zone_id: String) -> String:
	return str((INFO.get(zone_id, {}) as Dictionary).get("epithet", "Gatekeeper"))


static func obstacle(zone_id: String) -> Obstacle:
	return int((INFO.get(zone_id, {}) as Dictionary).get("obstacle", Obstacle.BARRIER)) as Obstacle


static func obstacle_name(zone_id: String) -> String:
	return str((INFO.get(zone_id, {}) as Dictionary).get("obstacle_name", "the barrier"))


## True once the gatekeeper is beaten: the obstacle is gone and the road is open.
static func is_cleared(flags: Dictionary, zone_id: String) -> bool:
	return bool(flags.get(str(CorruptedNpcs.unlock_flag(zone_id)), false))


## The battleboard key a gatekeeper duel uses: its own zone's board (the duel happens at the zone's doorstep).
static func board_key(zone_id: String) -> String:
	return "zone:%s" % zone_id


## The flag set the first time the hero walks into a zone (quests read it: "Cross into the Gainlands").
static func entered_flag(zone_id: String) -> StringName:
	return StringName("entered_%s" % zone_id)
