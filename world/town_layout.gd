class_name TownLayout
extends RefCounted
## The plan of Crosspath's centre. Crosspath pass, Part C: one big round market square where the roads cross, with all six shop vendors round it,
## each in its own storefront facing the fountain; the square's south side stays open and low so the camera (which looks north) sees across it.
## Streets leave it at the four points of the compass, every one five metres wide. All world coordinates (metres). Storefronts face the square or
## the street they stand on (`yaw` 0 faces +z / south, 180 north, 90 east, -90 west).
##
##                         N: Gate Road -> the Capital (the Forgotten Cave, Elder Maren's home)
##              NW house   Tilly Tonic | Foil Fenwick  ' alley (the Secret Dealer)   NE house
##      Sable's Cards                                                       Pip Threadwell
##   W: Market Street ---------------- SQUARE (the fountain) ---------------- Market Street :E (the Hall of Records)
##      Bertram's Smithy                                                    Auntie Alembic
##              notice board          (open, low south side)          Rift Express
##                         S: Champions' Road (the Chapel | the Deck Station; the Grave Road branches west)
##                                     the Undercroft cottage; the meadow road bends round it to the Gainlands

const PLAZA: Vector3 = Vector3(25.2, 0.0, 12.47)
## The paved square (it was 6.2 m before the Crosspath pass).
const PLAZA_RADIUS: float = 11.5
## Storefronts round the square stand with their front faces this far from its centre (north, west and east sides).
const FRONT_RING: float = 12.6
## Streets are paved 5.2 m wide (more than four hero widths); buildings stand 0.8 m off a street's edge.
const ROAD_WIDTH: float = 5.2
const FLANK: float = 4.5
## Where the hero arrives (on the square's open south side, facing the fountain).
const SPAWN: Vector3 = Vector3(25.2, 0.0, 19.6)
## The notice board (it opens the quest log), on the square's south-west corner facing the fountain.
const NOTICE_BOARD: Vector3 = Vector3(16.0, 0.0, 22.4)
## The Undercroft's abandoned cottage stands at the end of Champions' Road (the Grand Clashatorium stood here once).
const ARENA_CENTER: Vector3 = Vector3(25.2, 0.0, 46.5)
## The fountain basin and the ring of four Path plinths around it.
const FOUNTAIN_RADIUS: float = 2.6
const CREST_RING_RADIUS: float = 4.9
## Spacing of street lamps along the roads.
const LAMP_SPACING: float = 8.0
## The black-market alley off the square's north-east corner, between Fenwick's shop and the north-east house: x from / to, z from (the square end) / to.
const ALLEY: Rect2 = Rect2(34.6, -6.6, 2.4, 6.5)


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


## A kit building whose front face stands `front` metres from the square's centre on one side ("n", "w", "e"), centred `along` the side
## (x for the north side, z for the west and east sides), facing the square.
static func _round_square(key_value: String, preset_name: String, side: String, along: float, label_value: String, overrides: Dictionary = {}) -> Shop:
	var spec: Dictionary = BuildingPresets.spec(preset_name, overrides)
	var half_depth: float = float(spec.get("depth", 5.0)) * 0.5
	match side:
		"n":
			return _kit(key_value, preset_name, along, PLAZA.z - FRONT_RING - half_depth, 0.0, label_value, overrides)
		"w":
			return _kit(key_value, preset_name, PLAZA.x - FRONT_RING - half_depth, along, 90.0, label_value, overrides)
	return _kit(key_value, preset_name, PLAZA.x + FRONT_RING + half_depth, along, -90.0, label_value, overrides)


## Street geometry used to seat buildings: a road half width plus a gap, so the front faces stand just off the paving.
const STREET_HALF: float = 2.6
const FRONT_GAP: float = 0.8


## Every building of the centre. The `key`s are the town anchors (`TownBuilder.anchors`); fillers have an empty key. The buildings are BuildingKit presets
## sized by the scale rule (the hero reaches a third of the way up a door). Crosspath pass, Part C: the six shops stand round the square.
static func shops() -> Array[Shop]:
	var list: Array[Shop] = []
	var street_z: float = PLAZA.z
	var off: float = STREET_HALF + FRONT_GAP
	# --- the square: north side (either side of the Gate Road), west and east sides (either side of the market streets) ---
	list.append(_round_square("item_vendor", "potion_shop", "n", 18.8, "Tilly Tonic's Supplies"))
	list.append(_round_square("pack_vendor", "pack_shop", "n", 31.6, "Foil Fenwick's Sealed Goods"))
	list.append(_round_square("market", "card_shop", "w", 5.8, "Sable's Cards"))
	list.append(_round_square("equipment_vendor", "equipment_shop", "w", 19.6, "Bertram Beetsworth's Smithy"))
	list.append(_round_square("tailor", "clothing_shop", "e", 6.1, "Pip Threadwell's Hats & Hems"))
	list.append(_round_square("alchemist", "alchemist", "e", 18.7, "Auntie Alembic's"))
	# the corners of the square's north side: a house each, the black-market alley between Fenwick's and the north-east house
	var north_face: float = PLAZA.z - FRONT_RING
	# Oct 20, Part 4: the north-west corner house is Tilly Tonic's store room (its door starts the ghost fight; nobody walks in)
	list.append(_kit(StoreroomGhosts.SPOT_ID, "home_b", 12.3, north_face - 3.4, 0.0, "Tilly's store room"))
	list.append(_kit("", "home_a", 40.5, north_face - 3.0, 0.0, "Row house"))
	# --- West Market Street ---
	list.append(_kit("", "home_b", 1.4, street_z - off - 3.4, 0.0, "Row house"))
	list.append(_kit("", "home_a", -7.6, street_z - off - 3.0, 0.0, "Row house"))
	list.append(_kit("", "home_b", -6.6, street_z + off + 3.4, 180.0, "Row house"))
	# --- East Market Street: the Hall of Records and the houses opposite the lake ---
	list.append(_kit("codex", "hall", 47.2, street_z - off - 2.8, 0.0, "Hall of Records", {"width": 5.8, "depth": 5.6}))
	list.append(_kit("", "home_b", 54.2, street_z - off - 3.4, 0.0, "Row house"))
	list.append(_kit("", "cottage", 61.6, street_z - off - 2.4, 0.0, "Cottage"))
	list.append(_kit("", "home_a", 49.0, street_z + off + 3.0, 180.0, "Row house"))
	# --- the Rift Express on the square's south-east corner ---
	list.append(_shop("rift_station", "", Vector3(34.4, 0.0, 23.0), 0.0, 1.0, 1.3, 1.6, "Beefcake Rift Express", "bare"))
	# --- Gate Road (north): the cave gate beyond the north-west house, Elder Maren's home facing the road ---
	list.append(_kit("gate", "stone_hut", 7.4, -12.0, 90.0, "The Forgotten Cave"))
	list.append(_kit("elder_home", "home_a", 31.6, -10.6, -90.0, "Elder Maren's home", {"width": 6.4}))
	# --- Champions' Road (south): the chapel and the Deck Station; the Old Well in its yard off the west street ---
	list.append(_kit("church", "chapel", 17.3, 33.3, 90.0, "Chapel of the Four Paths"))
	list.append(_kit("deck", "inn", 32.1, 31.5, -90.0, "The Deck Station"))
	list.append(_shop("well", "", Vector3(2.4, 0.0, 21.0), 0.0, 1.5, 1.2, 0.9, "The Old Well", "bare"))
	# --- the Secret Dealer's alley and the sealed vault ---
	list.append(_shop("hidden_vendor", "", Vector3(ALLEY.get_center().x, 0.0, -3.6), 180.0, 1.0, 0.6, 0.0, "The Secret Dealer's nook", "bare"))
	list.append(_kit("vault", "stone_hut", 5.0, 37.0, 0.0, "The Sealed Vault"))
	return list


## True when `pos` lies inside any kit building footprint grown by `margin` (lamp posts, props and plants keep out).
static func in_footprint(pos: Vector3, margin: float = 0.0) -> bool:
	for shop: Shop in shops():
		if shop.covers(pos, margin):
			return true
	return false


## Every road as a polyline. The first and last points are the square's rim and the zone exits' arrival anchors.
static func roads() -> Dictionary:
	return {
		"market_west": [Vector3(-18.6, 0, 12.47), Vector3(-6.0, 0, 12.47), Vector3(6.0, 0, 12.47), Vector3(14.2, 0, 12.47)],
		"market_east": [Vector3(36.2, 0, 12.47), Vector3(45.0, 0, 12.47), Vector3(60.0, 0, 12.47), Vector3(69.0, 0, 12.47)],
		"gate_road": [Vector3(25.2, 0, 1.4), Vector3(25.2, 0, -7.5), Vector3(19.8, 0, -12.0), Vector3(16.2, 0, -15.6), Vector3(16.2, 0, -18.82)],
		# Crosspath pass, Part D: short paths to the doors that stand off the Gate Road
		"cave_path": [Vector3(18.6, 0, -13.2), Vector3(11.4, 0, -12.0)],
		"elder_path": [Vector3(25.2, 0, -8.6), Vector3(27.2, 0, -12.0)],
		"champions": [Vector3(25.2, 0, 23.6), Vector3(25.2, 0, 30.0), Vector3(25.2, 0, 41.0)],
		"south_road": [Vector3(25.2, 0, 41.0), Vector3(31.0, 0, 43.6), Vector3(34.4, 0, 50.0), Vector3(31.6, 0, 57.4), Vector3(27.2, 0, 62.4), Vector3(25.2, 0, 64.4), Vector3(25.2, 0, 65.6)],
		"grave_road": [Vector3(25.2, 0, 26.7), Vector3(8.0, 0, 26.7), Vector3(-2.0, 0, 31.0), Vector3(-8.0, 0, 34.3), Vector3(-16.8, 0, 34.3)],
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


## How wide a road is paved: the streets and tracks ROAD_WIDTH, the short paths to the doors off the Gate Road 2.4 m (Crosspath pass, Part D).
static func road_width(id: String) -> float:
	return 2.4 if id.ends_with("_path") else ROAD_WIDTH


## True on the paved plaza or on a road (with `margin` extra metres).
static func is_paved(pos: Vector3, margin: float = 0.0) -> bool:
	if Vector2(pos.x - PLAZA.x, pos.z - PLAZA.z).length() <= PLAZA_RADIUS + margin:
		return true
	var all_roads: Dictionary = roads()
	for id: String in all_roads.keys():
		if distance_to_roads(pos, {id: all_roads[id]}) <= road_width(id) * 0.5 + margin:
			return true
	return false


## Street lamp positions: along the cobbled town streets, alternating sides, plus four round the fountain on the square's diagonals. Crosspath pass,
## Part B: no lamps along the dirt tracks out in the fields (they lit nothing and stood alone in the meadow).
static func lamps() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for index: int in range(4):
		var angle: float = TAU * (float(index) + 0.5) / 4.0
		result.append(PLAZA + Vector3(cos(angle), 0.0, sin(angle)) * 7.6)
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
			if Vector2(pos.x - PLAZA.x, pos.z - PLAZA.z).length() < PLAZA_RADIUS + 2.0:
				continue
			result.append(pos)
	return result


## The signposts at the junctions: position, and the boards (text and the way the board points on screen: "W", "E", "N", "S", "SW"...).
## The words are never drawn: the boards carry the Path crest, and the post's popup reads the lines.
static func signposts() -> Array[Dictionary]:
	return [
		{"pos": Vector3(13.6, 0, 15.5), "boards": [{"text": "Market Street", "dir": "W"}, {"text": "The Verdant Dump", "dir": "W"}]},
		{"pos": Vector3(36.8, 0, 15.5), "boards": [{"text": "Market Street", "dir": "E"}, {"text": "The Endless Buffet", "dir": "E"}]},
		{"pos": Vector3(28.3, 0, 0.9), "boards": [{"text": "The Capital", "dir": "N"}, {"text": "Elder Maren's home", "dir": "N"}, {"text": "The Forgotten Cave", "dir": "N"}]},
		{"pos": Vector3(22.0, 0, 23.8), "boards": [{"text": "Grave Road: the D.N.A.", "dir": "SW"}, {"text": "The Undercroft", "dir": "S"}]},
		{"pos": Vector3(28.6, 0, 39.6), "boards": [{"text": "The Undercroft", "dir": "S"}, {"text": "The Gainlands", "dir": "SE"}]},
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


## Which surface each road gets: cobbled streets round the square and out along the Gate Road and Champions' Road, packed dirt on the tracks to the zones.
static func road_kinds() -> Dictionary:
	return {
		"market_west": "cobble", "market_east": "cobble", "gate_road": "cobble", "champions": "cobble",
		"south_road": "dirt", "grave_road": "dirt", "cave_path": "dirt", "elder_path": "dirt",
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
