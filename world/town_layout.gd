class_name TownLayout
extends RefCounted
## The plan of Crosspath's centre: a royal-crest plaza where the roads cross, two shop-lined market streets (west and east), the Gate Road
## north (the Forgotten Cave, Elder Maren's home, the Hall of Records), Champions' Road south (church, Deck Station, Old Well) leading to the
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
##        (D.N.A.)         |   Old Well
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
	## "building" (a KayKit building), "kit" (a BuildingKit preset), "stall" (a tent with goods) or "bare" (nothing is built: the scene places the object itself).
	var kind: String = "building"
	## Vertical slice: the BuildingKit preset, its overrides and a colour tint (kind "kit").
	var preset: String = ""
	var overrides: Dictionary = {}
	var tint: Color = Color.WHITE
	## Width x depth in metres (kit buildings): the footprint on the ground, front = +z in the building's own frame.
	var footprint: Vector2 = Vector2.ZERO
	## Metres along the front face (to the right) at which the door stands, so the door spot and the NPC stand in front of the door and not of the middle of the wall.
	var door_offset: float = 0.0

	## The unit vector the storefront faces.
	func front() -> Vector3:
		return Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))

	## The unit vector to the viewer's right when looking at the storefront.
	func right() -> Vector3:
		var f: Vector3 = front()
		return Vector3(f.z, 0.0, -f.x)

	func door_spot() -> Vector3:
		return center + front() * door + right() * door_offset

	## Where an NPC stands in front of the door (legacy buildings: 1.75 m from the centre).
	func npc_offset() -> float:
		return door + 0.65

	## Half the footprint depth (kit buildings), 1.0 for the old small models.
	func front_extent() -> float:
		return footprint.y * 0.5 if kind == "kit" else 1.0

	## True when `pos` (x / z) lies inside the building footprint grown by `margin` metres (kit buildings only).
	func covers(pos: Vector3, margin: float = 0.0) -> bool:
		if kind != "kit":
			return false
		var local: Vector3 = Basis(Vector3.UP, deg_to_rad(yaw)).inverse() * (pos - center)
		return absf(local.x) <= footprint.x * 0.5 + margin and absf(local.z) <= footprint.y * 0.5 + margin


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


## A BuildingKit building. `x`/`z` is the centre of the footprint; the door spot is 0.9 m in front of the front face.
static func _kit(key_value: String, preset_name: String, x: float, z: float, yaw_value: float, label_value: String, overrides: Dictionary = {}, tint_value: Color = Color.WHITE) -> Shop:
	var spec: Dictionary = BuildingPresets.spec(preset_name, overrides)
	var shop: Shop = Shop.new()
	shop.key = key_value
	shop.kind = "kit"
	shop.preset = preset_name
	shop.overrides = overrides
	shop.tint = tint_value
	shop.footprint = Vector2(float(spec.get("width", 6.0)), float(spec.get("depth", 5.0)))
	shop.center = Vector3(x, 0.0, z)
	shop.yaw = yaw_value
	shop.scale_value = 1.0
	shop.radius = maxf(shop.footprint.x, shop.footprint.y) * 0.5
	shop.door = shop.footprint.y * 0.5 + 0.9
	shop.door_offset = TownKit.door_u(spec)
	shop.label = label_value
	return shop


## Street geometry used to seat buildings: a road half width plus a gap, so the front faces stand just off the paving.
const STREET_HALF: float = 2.0
const FRONT_GAP: float = 0.7


## Every building of the centre. The `key`s are the town anchors (`TownBuilder.anchors`); fillers have an empty key. Vertical slice: the buildings are BuildingKit presets sized by
## the scale rule (the hero reaches a third of the way up a door), so rows stand `STREET_HALF + FRONT_GAP + half depth` off the centre line of their street.
static func shops() -> Array[Shop]:
	var list: Array[Shop] = []
	var street_z: float = PLAZA.z
	var off: float = STREET_HALF + FRONT_GAP
	# --- West Market Street: the potion shop and the card shop on the north side, the clothier and the smithy on the south, houses at the end ---
	var potion: Shop = _kit("item_vendor", "potion_shop", 14.6, 0.0, 0.0, "Tilly Tonic's Supplies")
	potion.center.z = street_z - off - potion.footprint.y * 0.5
	list.append(potion)
	var cards: Shop = _kit("market", "card_shop", 7.2, 0.0, 0.0, "Sable's Cards")
	cards.center.z = street_z - off - cards.footprint.y * 0.5
	list.append(cards)
	var house_w_n: Shop = _kit("", "home_a", -0.2, 0.0, 0.0, "Row house")
	house_w_n.center.z = street_z - off - house_w_n.footprint.y * 0.5
	list.append(house_w_n)
	var clothier: Shop = _kit("tailor", "clothing_shop", 14.6, 0.0, 180.0, "Pip Threadwell's Hats & Hems")
	clothier.center.z = street_z + off + clothier.footprint.y * 0.5
	list.append(clothier)
	var smithy: Shop = _kit("equipment_vendor", "equipment_shop", 6.8, 0.0, 180.0, "Bertram Beetsworth's Smithy")
	smithy.center.z = street_z + off + smithy.footprint.y * 0.5
	list.append(smithy)
	var house_w_s: Shop = _kit("", "home_b", -0.8, 0.0, 180.0, "Row house")
	house_w_s.center.z = street_z + off + house_w_s.footprint.y * 0.5
	list.append(house_w_s)
	# --- East Market Street: the Rift Express hub, the pack shop, the Alchemist; houses and a cottage opposite ---
	list.append(_shop("rift_station", "", Vector3(36.2, 0.0, street_z - 4.5), 0.0, 1.0, 1.3, 1.6, "Beefcake Rift Express", "bare"))
	var packs: Shop = _kit("pack_vendor", "pack_shop", 43.4, 0.0, 0.0, "Foil Fenwick's Sealed Goods")
	packs.center.z = street_z - off - packs.footprint.y * 0.5
	list.append(packs)
	var alchemist: Shop = _kit("alchemist", "alchemist", 50.2, 0.0, 0.0, "Auntie Alembic's")
	alchemist.center.z = street_z - off - alchemist.footprint.y * 0.5
	list.append(alchemist)
	var east_a: Shop = _kit("", "home_a", 40.0, 0.0, 180.0, "Row house")
	east_a.center.z = street_z + off + east_a.footprint.y * 0.5
	list.append(east_a)
	var east_b: Shop = _kit("", "home_b", 47.2, 0.0, 180.0, "Row house")
	east_b.center.z = street_z + off + east_b.footprint.y * 0.5
	list.append(east_b)
	var east_c: Shop = _kit("", "cottage", 54.0, 0.0, 180.0, "Cottage")
	east_c.center.z = street_z + off + east_c.footprint.y * 0.5
	list.append(east_c)
	# --- Gate Road (north): the cave gate on the west, Elder Maren's home and the Hall of Records on the east ---
	var road_x: float = PLAZA.x
	var gate: Shop = _kit("gate", "stone_hut", 0.0, 3.0, 90.0, "The Forgotten Cave")
	gate.center.x = road_x - off - gate.footprint.y * 0.5
	list.append(gate)
	var elder: Shop = _kit("elder_home", "home_a", 0.0, 3.6, -90.0, "Elder Maren's home", {"width": 6.4})
	elder.center.x = road_x + off + elder.footprint.y * 0.5
	list.append(elder)
	var codex: Shop = _kit("codex", "hall", 0.0, -2.8, -90.0, "Hall of Records", {"width": 5.8, "depth": 5.6})
	# the hall stands a little back from the road (the hex ground in front of its door and the uplands chest behind it both need room)
	codex.center.x = road_x + off + 1.3 + codex.footprint.y * 0.5
	list.append(codex)
	# --- Champions' Road (south): the church, the Deck Station, the Old Well ---
	var church: Shop = _kit("church", "chapel", 0.0, 31.8, 90.0, "Chapel of the Four Paths")
	church.center.x = road_x - off - church.footprint.y * 0.5
	list.append(church)
	var inn: Shop = _kit("deck", "inn", 0.0, 25.0, -90.0, "The Deck Station")
	inn.center.x = road_x + off + inn.footprint.y * 0.5
	list.append(inn)
	list.append(_shop("well", "", Vector3(6.2, 0.0, 23.6), 0.0, 1.5, 1.2, 0.9, "The Old Well", "bare"))
	# --- The secrets and the quiet corners ---
	list.append(_kit("hidden_vendor", "equipment_shop", 39.6, 25.6, 0.0, "A back-alley smithy", {"width": 6.0, "depth": 5.0}))
	list.append(_kit("vault", "stone_hut", 9.6, 34.8, 0.0, "The Sealed Vault"))
	return list


## True when `pos` lies inside any kit building footprint grown by `margin` (lamp posts, props and plants keep out).
static func in_footprint(pos: Vector3, margin: float = 0.0) -> bool:
	for shop: Shop in shops():
		if shop.covers(pos, margin):
			return true
	return false


## Every road as a polyline. The first and last points are the plaza ring and the zone exits' arrival anchors.
static func roads() -> Dictionary:
	return {
		"market_west": [Vector3(-18.6, 0, 12.47), Vector3(-6.0, 0, 12.47), Vector3(6.0, 0, 12.47), Vector3(19.0, 0, 12.47)],
		"market_east": [Vector3(31.4, 0, 12.47), Vector3(45.0, 0, 12.47), Vector3(60.0, 0, 12.47), Vector3(69.0, 0, 12.47)],
		"gate_road": [Vector3(25.2, 0, 6.3), Vector3(25.2, 0, 0.0), Vector3(23.4, 0, -3.1), Vector3(19.8, 0, -9.3), Vector3(16.2, 0, -12.59)],
		"champions": [Vector3(25.2, 0, 18.4), Vector3(25.2, 0, 30.0), Vector3(25.2, 0, 40.2)],
		"south_road": [Vector3(25.2, 0, 31.5), Vector3(31.0, 0, 35.0), Vector3(35.5, 0, 40.0), Vector3(36.5, 0, 47.0), Vector3(33.5, 0, 54.0), Vector3(28.5, 0, 59.5), Vector3(25.2, 0, 63.0), Vector3(25.2, 0, 65.6)],
		"grave_road": [Vector3(21.4, 0, 17.5), Vector3(20.4, 0, 22.0), Vector3(14.5, 0, 25.6), Vector3(8.5, 0, 28.6), Vector3(1.0, 0, 32.0), Vector3(-6.0, 0, 34.3), Vector3(-16.8, 0, 34.3)],
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


## Street lamp positions: along the cobbled town streets, alternating sides, plus a ring round the plaza. Crosspath pass, Part B: no lamps along the dirt
## tracks out in the fields (they lit nothing and stood alone in the meadow).
static func lamps() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for index: int in range(6):
		var angle: float = TAU * (float(index) + 0.5) / 6.0
		result.append(PLAZA + Vector3(cos(angle), 0.0, sin(angle)) * (PLAZA_RADIUS - 0.5))
	var all_roads: Dictionary = roads()
	var kinds: Dictionary = road_kinds()
	for id: String in all_roads.keys():
		if str(kinds.get(id, "dirt")) != "cobble":
			continue
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
		{"pos": Vector3(19.3, 0, 8.8), "boards": [{"text": "Market Street", "dir": "W"}, {"text": "The Verdant Dump", "dir": "W"}]},
		{"pos": Vector3(31.1, 0, 8.8), "boards": [{"text": "Market Street", "dir": "E"}, {"text": "The Endless Buffet", "dir": "E"}]},
		{"pos": Vector3(28.8, 0, 7.0), "boards": [{"text": "The Capital", "dir": "N"}, {"text": "Elder Maren's home", "dir": "N"}, {"text": "The Forgotten Cave", "dir": "N"}]},
		{"pos": Vector3(18.9, 0, 16.6), "boards": [{"text": "Grave Road: the D.N.A.", "dir": "SW"}, {"text": "The Grand Clashatorium", "dir": "S"}]},
		{"pos": Vector3(23.0, 0, 35.5), "boards": [{"text": "The Grand Clashatorium", "dir": "S"}, {"text": "The Gainlands", "dir": "SE"}]},
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


## Which surface each road gets (Part C): cobbled streets round the square and out along the Gate Road and Champions' Road, packed dirt on the tracks to the zones.
static func road_kinds() -> Dictionary:
	return {
		"market_west": "cobble", "market_east": "cobble", "gate_road": "cobble", "champions": "cobble",
		"south_road": "dirt", "grave_road": "dirt",
	}


## The yaw (degrees, 0 = +z / south, 90 = +x / east) a signpost board points to for a direction code ("W", "E", "N", "S", "SW", "SE").
static func yaw_for_direction(dir: String) -> float:
	match dir:
		"W":
			return -90.0
		"E":
			return 90.0
		"N":
			return 180.0
		"S":
			return 0.0
		"SW":
			return -45.0
		"SE":
			return 45.0
	return 0.0


## The words a signpost popup uses for a direction code.
static func direction_name(dir: String) -> String:
	match dir:
		"W":
			return "West"
		"E":
			return "East"
		"N":
			return "North"
		"S":
			return "South"
		"SW":
			return "South-west"
		"SE":
			return "South-east"
	return "Onward"
