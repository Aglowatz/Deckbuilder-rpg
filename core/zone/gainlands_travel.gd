class_name GainlandsTravel
extends RefCounted
## The Gainlands' travel network. THROWERS (`kind = "throw"`) are Beefcakes who grab you and hurl you
## in an arc; PORTAL RIPPERS (`kind = "portal"`) physically tear open a portal. Each point has a
## destination (an anchor name in `GainlandsLayout`) and an optional unlock `Condition`. Some islands
## are reachable only by chains of these (Calf Cove only by Pec Perch's portal, Glute Garden only by
## Delt Deck's thrower). Every island has an always-open way back so the player can never be stranded.

const COUNTER_THROWS: String = "gain_throws"
const COUNTER_PORTALS: String = "gain_portals"


class Point:
	extends RefCounted
	var id: String = ""
	## "throw" or "portal".
	var kind: String = "throw"
	## Layout anchor the Beefcake stands at (the interact spot).
	var anchor: String = ""
	## Layout anchor where you land / step out of the portal.
	var dest_anchor: String = ""
	var title: String = ""
	var speaker: String = ""
	var lock: Condition
	## What the locked point tells the player (story key `travel.<id>.locked`).
	var tint: Color = Color.WHITE

	func lock_key() -> String:
		return "travel.%s.locked" % id


static func _point(id: String, kind: String, anchor: String, dest: String, title: String, speaker: String, tint: Color, lock: Condition = null) -> Point:
	var point: Point = Point.new()
	point.id = id
	point.kind = kind
	point.anchor = anchor
	point.dest_anchor = dest
	point.title = title
	point.speaker = speaker
	point.tint = tint
	point.lock = lock
	return point


static func points() -> Array[Point]:
	var throw_tint: Color = Color(1.0, 0.7, 0.5)
	var rip_tint: Color = Color(0.6, 1.0, 0.95)
	return [
		# Main land -> islands and across the map.
		_point("thrower_pec", "throw", "thrower_pec", "arrive_pec", "Brock, Heavy Heaver", "Brock", throw_tint),
		_point("ripper_delt", "portal", "ripper_delt", "arrive_delt", "Rita, Portal Ripper", "Rita", rip_tint, Condition.flag(str(GainlandsZone.FLAG_WHEEL_POWERED))),
		_point("thrower_east", "throw", "thrower_east", "land_west", "Tobias, Cross-Country Chucker", "Tobias", throw_tint, Condition.card_owned("gym_rat", 1)),
		_point("thrower_west", "throw", "thrower_west", "land_east", "Wanda, Cross-Country Chucker", "Wanda", throw_tint),
		# Pec Perch.
		_point("thrower_pec_back", "throw", "thrower_pec_back", "land_pec", "Bonnie, Return Chucker", "Bonnie", throw_tint),
		_point("ripper_calf", "portal", "ripper_calf", "arrive_calf", "Rhonda, Portal Ripper", "Rhonda", rip_tint, Condition.quest_completed(GainlandsZone.QUEST_SPOT_ME)),
		# Delt Deck.
		_point("ripper_delt_back", "portal", "ripper_delt_back", "land_delt", "Ripley, Return Ripper", "Ripley", rip_tint),
		_point("thrower_glute", "throw", "thrower_glute", "arrive_glute", "Dmitri, Long-Haul Heaver", "Dmitri", throw_tint, Condition.counter(GainlandsZone.COUNTER_ENEMIES, 2)),
		# Glute Garden and Calf Cove (the way home).
		_point("thrower_glute_back", "throw", "thrower_glute_back", "land_glute", "Greta, Return Chucker", "Greta", throw_tint),
		_point("ripper_calf_back", "portal", "ripper_calf_back", "land_calf", "Raelynn, Return Ripper", "Raelynn", rip_tint),
	] as Array[Point]


static func find(id: String) -> Point:
	for point: Point in points():
		if point.id == id:
			return point
	return null


static func is_unlocked(point: Point, state: UnlockState) -> bool:
	return Condition.met(point.lock, state)
