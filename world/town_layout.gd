class_name TownLayout
extends RefCounted
## The plan of Crosspath's centre: a royal-crest plaza where the roads cross, two shop-lined market streets (west and east), the Gate Road
## north (the Forgotten Cave, Elder Maren's home, the Hall of Records), Champions' Road south (church, Deck Station, Wellspring) leading to the
## Grand Clashatorium, and the roads out to every zone exit. All world coordinates (metres); the hex map under it is cleared by
## `TownBuilder` along these roads. Storefronts face the street they stand on (`yaw` 0 faces +z / south, 180 north, 90 east, -90 west).
##
##                      N: Gate Road -> The Capital
##        Forgotten Cave   |   Elder Maren's home
##                         |   Hall of Records
##   W: Market Street --- PLAZA (fountain with the royal crest) --- Market Street :E
##  (Tonic, Sable /        |  notice board                    (Express, Fenwick, Alembic)
##   Pip, Bertram)         |
##        Grave Road <-    |   Church | Deck Station
##        (D.N.A.)         |   Wellspring
##                         |
##                  Grand Clashatorium  (Champions' Road ends at its gate; the south road bends round it to the Gainlands)

const PLAZA: Vector3 = Vector3(25.2, 0.0, 12.47)
const PLAZA_RADIUS: float = 6.2
## Roads are paved 4 m wide; buildings stand 4.5 m off the street's centre line (the door spot just outside the paving).
const ROAD_WIDTH: float = 4.0
const FLANK: float = 4.5
## Where the hero arrives (on the plaza's south side, facing the fountain).
const SPAWN: Vector3 = Vector3(25.2, 0.0, 17.2)
## The notice board (it opens the quest log), on the plaza's south-east edge facing the fountain.
const NOTICE_BOARD: Vector3 = Vector3(29.6, 0.0, 16.6)
## The Grand Clashatorium stands at the end of Champions' Road.
const ARENA_CENTER: Vector3 = Vector3(25.2, 0.0, 46.5)
## The fountain basin and the ring of four Path plinths around it.
const FOUNTAIN_RADIUS: float = 1.9
const CREST_RING_RADIUS: float = 3.5
## Spacing of street lamps along the roads.
const LAMP_SPACING: float = 8.0


## One building (or stall) on a street: where, which way it faces and what it is.
class Shop:
	extends RefCounted
	var key: String = ""
	var model: String = ""
	var center: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var scale_value: float = 1.25
	var radius: float = 0.9
	## How far in front of the building's centre the interaction spot is.
	var door: float = 1.1
	var label: String = ""
	## "building" (a KayKit building), "stall" (a tent with goods) or "bare" (nothing is built: the scene places the object itself).
	var kind: String = "building"

	## The unit vector the storefront faces.
	func front() -> Vector3:
		return Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))

	## The unit vector to the viewer's right when looking at the storefront.
	func right() -> Vector3:
		var f: Vector3 = front()
		return Vector3(f.z, 0.0, -f.x)

	func door_spot() -> Vector3:
		return center + front() * door


static func _shop(key_value: String, model_value: String, center: Vector3, yaw_value: float, scale_value: float, radius_value: float, door_value: float, label_value: String, kind_value: String = "building") -> Shop:
	var shop: Shop = Shop.new()
	shop.key = key_value
	shop.model = model_value
	shop.center = center
	shop.yaw = yaw_value
	shop.scale_value = scale_value
	shop.radius = radius_value
	shop.door = door_value
	shop.label = label_value
	shop.kind = kind_value
	return shop


## Every building of the centre. The `key`s are the town anchors (`TownBuilder.anchors`); fillers have an empty key.
static func shops() -> Array[Shop]:
	var north: float = PLAZA.z - FLANK
	var south: float = PLAZA.z + FLANK
	var west: float = PLAZA.x - FLANK
	var east: float = PLAZA.x + FLANK
	var list: Array[Shop] = []
	# --- West Market Street: two storefronts a side, a house at the end ---
	list.append(_shop("item_vendor", "barracks", Vector3(14.2, 0.0, north), 0.0, 1.2, 0.85, 1.05, "Tilly Tonic's Supplies"))
	list.append(_shop("market", "market", Vector3(8.7, 0.0, north), 0.0, 1.25, 1.1, 1.15, "Sable's Cards"))
	list.append(_shop("", "home_B", Vector3(3.2, 0.0, north), 0.0, 1.3, 0.7, 1.0, "Row house"))
	list.append(_shop("tailor", "market", Vector3(14.2, 0.0, south), 180.0, 1.2, 0.9, 1.05, "Pip Threadwell's Hats & Hems"))
	list.append(_shop("equipment_vendor", "blacksmith", Vector3(8.7, 0.0, south), 180.0, 1.25, 0.9, 1.05, "Bertram Beetsworth's Smithy"))
	list.append(_shop("", "home_A", Vector3(3.2, 0.0, south), 180.0, 1.3, 0.7, 1.0, "Row house"))
	# --- East Market Street: the Rift Express hub, the pack stall, the Alchemist ---
	list.append(_shop("rift_station", "", Vector3(36.2, 0.0, north), 0.0, 1.0, 1.3, 1.6, "Beefcake Rift Express", "bare"))
	list.append(_shop("pack_vendor", "market", Vector3(41.7, 0.0, north), 0.0, 1.1, 0.9, 1.05, "Foil Fenwick's Sealed Goods"))
	list.append(_shop("alchemist", "tower_B", Vector3(47.2, 0.0, north), 0.0, 1.15, 0.95, 1.15, "Auntie Alembic's"))
	list.append(_shop("", "home_A", Vector3(36.2, 0.0, south), 180.0, 1.3, 0.7, 1.0, "Row house"))
	list.append(_shop("", "home_B", Vector3(41.7, 0.0, south), 180.0, 1.3, 0.7, 1.0, "Row house"))
	list.append(_shop("", "home_A", Vector3(47.2, 0.0, south), 180.0, 1.3, 0.7, 1.0, "Row house"))
	# --- Gate Road (north): the cave gate on the west, Elder Maren's home and the Hall of Records on the east ---
	list.append(_shop("gate", "mine", Vector3(west, 0.0, 2.5), 90.0, 1.35, 1.0, 1.1, "The Forgotten Cave"))
	list.append(_shop("elder_home", "home_A", Vector3(east, 0.0, 2.5), -90.0, 1.4, 0.75, 1.0, "Elder Maren's home"))
	list.append(_shop("codex", "tower_A", Vector3(east, 0.0, -3.5), -90.0, 1.3, 0.85, 1.05, "Hall of Records"))
	# --- Champions' Road (south): the church, the Deck Station, the Wellspring ---
	list.append(_shop("church", "church", Vector3(west, 0.0, 23.5), 90.0, 1.2, 0.85, 1.1, "Chapel of the Four Paths"))
	list.append(_shop("deck", "tavern", Vector3(east, 0.0, 23.5), -90.0, 1.25, 0.95, 1.1, "The Deck Station"))
	list.append(_shop("well", "well", Vector3(west + 0.6, 0.0, 29.5), 90.0, 1.5, 0.6, 0.9, "The Wellspring"))
	# --- The secrets and the quiet corners ---
	list.append(_shop("hidden_vendor", "blacksmith", Vector3(39.6, 0.0, 24.9), 0.0, 1.25, 0.9, 1.05, "A back-alley smithy"))
	list.append(_shop("vault", "castle", Vector3(10.8, 0.0, 31.2), 0.0, 1.1, 1.15, 1.3, "The Sealed Vault"))
	return list


## Every road as a polyline. The first and last points are the plaza ring and the zone exits' arrival anchors.
static func roads() -> Dictionary:
	return {
		"market_west": [Vector3(-18.6, 0, 12.47), Vector3(-6.0, 0, 12.47), Vector3(6.0, 0, 12.47), Vector3(19.0, 0, 12.47)],
		"market_east": [Vector3(31.4, 0, 12.47), Vector3(45.0, 0, 12.47), Vector3(60.0, 0, 12.47), Vector3(69.0, 0, 12.47)],
		"gate_road": [Vector3(25.2, 0, 6.3), Vector3(25.2, 0, 0.0), Vector3(23.4, 0, -3.1), Vector3(19.8, 0, -9.3), Vector3(16.2, 0, -12.59)],
		"champions": [Vector3(25.2, 0, 18.4), Vector3(25.2, 0, 30.0), Vector3(25.2, 0, 40.2)],
		"south_road": [Vector3(25.2, 0, 31.5), Vector3(31.0, 0, 35.0), Vector3(35.5, 0, 40.0), Vector3(36.5, 0, 47.0), Vector3(33.5, 0, 54.0), Vector3(28.5, 0, 59.5), Vector3(25.2, 0, 63.0), Vector3(25.2, 0, 65.6)],
		"grave_road": [Vector3(20.8, 0, 16.6), Vector3(14.0, 0, 22.0), Vector3(7.0, 0, 27.5), Vector3(1.0, 0, 32.0), Vector3(-6.0, 0, 34.3), Vector3(-16.8, 0, 34.3)],
	}


## The sample points (about every `step` metres) of every road, for carving the map, keep-outs and lamps.
static func road_points(step: float = 1.2) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var all_roads: Dictionary = roads()
	for id: String in all_roads.keys():
		result.append_array(sample(all_roads[id] as Array, step))
	return result


static func sample(points: Array, step: float) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for index: int in range(points.size() - 1):
		var a: Vector3 = points[index] as Vector3
		var b: Vector3 = points[index + 1] as Vector3
		var count: int = maxi(1, int(ceil(a.distance_to(b) / step)))
		for i: int in range(count):
			result.append(a.lerp(b, float(i) / float(count)))
	result.append(points[points.size() - 1] as Vector3)
	return result


## Distance from `pos` (x/z) to the nearest road centre line (a big number when there are no roads).
static func distance_to_roads(pos: Vector3, road_dict: Dictionary = {}) -> float:
	var all_roads: Dictionary = road_dict if not road_dict.is_empty() else roads()
	var best: float = 1.0e9
	var flat: Vector2 = Vector2(pos.x, pos.z)
	for id: String in all_roads.keys():
		var points: Array = all_roads[id] as Array
		for index: int in range(points.size() - 1):
			var a: Vector3 = points[index] as Vector3
			var b: Vector3 = points[index + 1] as Vector3
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(flat, Vector2(a.x, a.z), Vector2(b.x, b.z))
			best = minf(best, flat.distance_to(closest))
	return best


## True on the paved plaza or on a road (with `margin` extra metres).
static func is_paved(pos: Vector3, margin: float = 0.0) -> bool:
	if Vector2(pos.x - PLAZA.x, pos.z - PLAZA.z).length() <= PLAZA_RADIUS + margin:
		return true
	return distance_to_roads(pos) <= ROAD_WIDTH * 0.5 + margin


## Street lamp positions: along every road, alternating sides, plus a ring round the plaza.
static func lamps() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for index: int in range(6):
		var angle: float = TAU * (float(index) + 0.5) / 6.0
		result.append(PLAZA + Vector3(cos(angle), 0.0, sin(angle)) * (PLAZA_RADIUS - 0.5))
	var all_roads: Dictionary = roads()
	for id: String in all_roads.keys():
		var points: Array[Vector3] = sample(all_roads[id] as Array, 0.5)
		var run: float = 0.0
		var side: float = 1.0
		var last: Vector3 = points[0]
		for point: Vector3 in points:
			run += point.distance_to(last)
			last = point
			if run < LAMP_SPACING:
				continue
			run = 0.0
			var next_index: int = mini(points.find(point) + 1, points.size() - 1)
			var tangent: Vector3 = (points[next_index] - point)
			if tangent.length() < 0.01:
				tangent = point - points[maxi(points.find(point) - 1, 0)]
			tangent = tangent.normalized()
			var normal: Vector3 = Vector3(-tangent.z, 0.0, tangent.x)
			var pos: Vector3 = point + normal * side * (ROAD_WIDTH * 0.5 + 0.5)
			side = -side
			if Vector2(pos.x - PLAZA.x, pos.z - PLAZA.z).length() < PLAZA_RADIUS + 1.0:
				continue
			result.append(pos)
	return result


## The signposts at the junctions: position, and the boards (text and the way the board points on screen: "W", "E", "N", "S", "SW"...).
## The text is flat and upright, readable from the town camera (which looks north), so the direction is an arrow prefix.
static func signposts() -> Array[Dictionary]:
	return [
		{"pos": Vector3(18.0, 0, 9.4), "boards": [{"text": "Market Street", "dir": "W"}, {"text": "The Verdant Dump", "dir": "W"}]},
		{"pos": Vector3(32.4, 0, 9.4), "boards": [{"text": "Market Street", "dir": "E"}, {"text": "The Endless Buffet", "dir": "E"}]},
		{"pos": Vector3(28.4, 0, 7.6), "boards": [{"text": "The Capital", "dir": "N"}, {"text": "Elder Maren's home", "dir": "N"}, {"text": "The Forgotten Cave", "dir": "N"}]},
		{"pos": Vector3(21.8, 0, 18.6), "boards": [{"text": "Grave Road: the D.N.A.", "dir": "SW"}, {"text": "The Grand Clashatorium", "dir": "S"}]},
		{"pos": Vector3(22.6, 0, 32.4), "boards": [{"text": "The Grand Clashatorium", "dir": "S"}, {"text": "The Gainlands", "dir": "SE"}]},
	]


## The arrow drawn in front of a signpost board for `dir`.
static func arrow_for(dir: String) -> String:
	match dir:
		"W":
			return "<-"
		"E":
			return "->"
		"N":
			return "^"
		"S":
			return "v"
		"SW":
			return "<- v"
		"SE":
			return "v ->"
	return "->"
