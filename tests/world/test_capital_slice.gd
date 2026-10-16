extends GutTest
## The Capital layout pass (docs/art/capital_slice.md): one walkable zone in two halves joined through the great wall, its thirteen regions laid out
## by the declutter rules of the rollout playbook (section 5) before any art: wide routes that loop with nothing solid on them, open ground round
## every person and interactable, prompts that never fight, a symmetric perfect city inside with an open plaza round the Primm statue fountain,
## Primm's Castle at immense scale on its hill at the city's heart, the stand-ins clear of the routes, the paint-over cameras as layout data.

## Props that make up a region's furniture by design and are allowed at a route's kerb: the stand-in pieces of a line (headstones lining the
## Grave Row lane, the lamp lines and verge items of the avenue) are checked by their own rules below.
const KERB_KINDS: Array[String] = ["grave", "lamp_perfect", "lamp_street"]

var layout: CapitalLayout


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()


## A prop that stands at an anchor (the booth at the exit interview, the parlour by Widow Pell...) is that anchor's feature, not clutter round it.
func _anchored(prop: CapitalLayout.Prop) -> bool:
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < 4.0:
			return true
	return false


func _spot_positions() -> Dictionary:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var out: Dictionary = {}
	for entry: Dictionary in def.spots:
		var anchor_name: String = str(entry["anchor"])
		if not layout.anchors.has(anchor_name):
			continue
		out[str(entry["id"])] = (layout.anchors[anchor_name] as Vector3) + (entry["offset"] as Vector3)
	for sign_data: CapitalLayout.Sign in layout.signs:
		out[sign_data.key] = sign_data.pos
	return out


func test_the_thirteen_regions_are_the_brief_regions() -> void:
	var titles: Dictionary = {}
	for area: CapitalLayout.Area in layout.areas:
		titles[area.id] = area.title
	for id: String in CapitalLayout.OUTSIDE_REGIONS + CapitalLayout.INSIDE_REGIONS:
		assert_true(titles.has(id), "region %s exists" % id)
	assert_eq(str(titles.get("gate", "")), "The Gate Road")
	assert_eq(str(titles.get("plaza", "")), "The Gate Plaza")
	assert_eq(str(titles.get("approach", "")), "The Palace Approach")
	var expect: Dictionary = {
		"spawn": "gate", "spotless": "gate", "kestrel": "camp", "camp": "camp", "rift_out_a": "rifts", "rift_out_b": "rifts", "tunnel_in": "rifts",
		"old_tunnels": "tunnels", "checkpoint_b": "outpost", "wall_passage": "passage", "gate_inside": "plaza", "exit_booth": "plaza", "fountain": "plaza",
		"castle_door": "approach", "door_1": "approach", "citizen_1": "approach", "fern": "reek", "heap_2": "reek", "pell": "grave", "stamp": "grave",
		"rollo": "transit", "wheel_2": "transit", "marlo": "hungry", "dispenser": "hungry", "ward_window": "ward", "ward_patient": "ward",
	}
	for key: String in expect.keys():
		var pos: Vector3 = layout.anchors[key] as Vector3
		var area: CapitalLayout.Area = layout.area_at(pos.x, pos.z)
		assert_eq(area.id if area != null else "", str(expect[key]), "%s stands in the %s region" % [key, str(expect[key])])
	for key: String in ["spawn", "kestrel", "old_tunnels", "checkpoint_b", "tunnel_in"]:
		assert_false(CapitalLayout.is_inside_z((layout.anchors[key] as Vector3).z), "%s is outside the wall" % key)
	for key: String in ["fountain", "castle_door", "fern", "pell", "rollo", "marlo", "ward_window"]:
		assert_true(CapitalLayout.is_inside_z((layout.anchors[key] as Vector3).z), "%s is inside the wall" % key)


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	var main_roads: int = 0
	for route: Dictionary in layout.routes:
		assert_gte(float(route["width"]), CapitalLayout.SPUR_WIDTH - 0.01, "route %s is at least a spur wide" % str(route["id"]))
		if float(route["width"]) >= CapitalLayout.MAIN_ROUTE_WIDTH:
			main_roads += 1
	assert_gte(main_roads, 18, "the roads, streets and lanes are four hero-widths")
	var on_route: Array[String] = []
	for prop: CapitalLayout.Prop in layout.props:
		if prop.radius <= 0.0 or prop.kind in KERB_KINDS or _anchored(prop) or prop.pos.z >= CapitalBuilder.CREASE_Z:
			continue
		if layout.route_edge_distance(prop.pos.x, prop.pos.z) < CapitalLayout.ROUTE_CLEARANCE - 0.01:
			on_route.append("%s at (%.1f, %.1f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for building: CapitalLayout.Building in layout.buildings:
		if building.style in ["wall", "tower"]:
			continue  # the great wall is what the gate road and the avenue pass through
		if layout.rect_route_distance(building.rect) < CapitalLayout.ROUTE_CLEARANCE - 0.05:
			on_route.append("%s building at %s" % [building.style, str(building.rect)])
	assert_eq(on_route, [] as Array[String], "nothing solid within %.1f m of a route edge" % CapitalLayout.ROUTE_CLEARANCE)
	# the kerb furniture keeps out of the route itself
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind in KERB_KINDS:
			assert_gt(layout.route_edge_distance(prop.pos.x, prop.pos.z), prop.radius, "%s at (%.1f, %.1f) stands off the route" % [prop.kind, prop.pos.x, prop.pos.z])
	# the rifts never reach a route (walking a road never tears you)
	for rift: CapitalLayout.Rift in layout.rifts:
		assert_gt(layout.route_edge_distance(rift.pos.x, rift.pos.y) - rift.radius, 0.5, "rift %s keeps off the routes" % rift.id)


func test_every_region_is_reached_from_the_gate_road() -> void:
	# The gate open, every region's people and doors are reached on foot from the arrival (the loops themselves are in the plan, capital_slice.md).
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	builder.gate_open = true
	var can: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var targets: Dictionary = {}
	for key: String in ["kestrel", "seal_out_a", "old_tunnels", "fern", "pell", "rollo", "marlo", "ward_window", "castle_door", "complaint_1"]:
		targets[key] = layout.anchors[key] as Vector3
	targets["the outpost"] = Vector3(97.0, 0.0, 110.5)
	assert_eq(WalkProbe.unreachable(can, layout.anchors["spawn"] as Vector3, builder.map_bounds(), targets), [] as Array[String], "every region is reached from the Gate Road")


func test_open_ground_round_every_anchor_and_chest() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if anchor.z >= CapitalBuilder.CREASE_Z:
			continue
		for building: CapitalLayout.Building in layout.buildings:
			var rect: Rect2 = building.rect
			var dx: float = maxf(maxf(rect.position.x - anchor.x, 0.0), anchor.x - rect.end.x)
			var dz: float = maxf(maxf(rect.position.y - anchor.z, 0.0), anchor.z - rect.end.y)
			if Vector2(dx, dz).length() < 0.6:
				crowded.append("%s building on %s" % [building.style, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: CapitalLayout.Prop in layout.props:
			if prop.radius > 0.0 and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < prop.radius + 1.0:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, gate, pickup and chest stands on open ground")
	# the people have 5.5 m of open ground: no scattered solid thing (a wasteland piece, a junk pile, a crystal) that is not their own feature
	var people: Array[String] = ["kestrel", "spotless", "guard_height", "guard_queue", "guard_in_1", "guard_in_2", "fern", "pell", "rollo", "marlo", "ward_patient"]
	for person: String in people:
		var at: Vector3 = layout.anchors[person] as Vector3
		for prop: CapitalLayout.Prop in layout.props:
			if prop.kind in ["junk_pile", "rift_crystals", "wreck_stack", "toppled_statue", "tree_dead", "rock", "wreck"]:
				assert_gt(Vector2(prop.pos.x - at.x, prop.pos.z - at.z).length(), CapitalLayout.ANCHOR_CLEARANCE, "%s near %s" % [prop.kind, person])
		for spot: Vector3 in layout.wasteland_clusters:
			assert_gt(Vector2(spot.x - at.x, spot.y - at.z).length() - spot.z, 3.0, "a wasteland cluster crowds %s" % person)


func test_prompts_never_fight() -> void:
	var spots: Dictionary = _spot_positions()
	var close: Array[String] = []
	var keys: Array = spots.keys()
	for i: int in range(keys.size()):
		for j: int in range(i + 1, keys.size()):
			var a: Vector3 = spots[keys[i]] as Vector3
			var b: Vector3 = spots[keys[j]] as Vector3
			if a.z >= CapitalBuilder.CREASE_Z or b.z >= CapitalBuilder.CREASE_Z:
				continue  # the Crease kept its hall as it was
			if Vector2(a.x - b.x, a.z - b.z).length() < 2.45:
				close.append("%s ~ %s" % [str(keys[i]), str(keys[j])])
	assert_eq(close, [] as Array[String], "every interact spot and sign stands 2.5 m or more from the next")


func test_the_inside_is_perfectly_symmetric_and_the_plaza_open() -> void:
	# the identical houses mirror about the avenue (x 60), the identical row about the Hungry Quarter's lane (x 100)
	var houses: Array[Rect2] = []
	var stalls: Array[Rect2] = []
	for building: CapitalLayout.Building in layout.buildings:
		if building.style in ["house", "shop"]:
			houses.append(building.rect)
		elif building.style == "stall":
			stalls.append(building.rect)
	assert_eq(houses.size(), 16)
	for rect: Rect2 in houses:
		assert_eq(rect.size, Vector2(4.0, 4.0), "every house the same size")
		var mirror: Rect2 = Rect2(120.0 - rect.end.x, rect.position.y, rect.size.x, rect.size.y)
		assert_true(houses.has(mirror), "the house at %s has its twin across the avenue" % str(rect))
	assert_eq(stalls.size(), 6)
	for rect: Rect2 in stalls:
		assert_true(stalls.has(Rect2(200.0 - rect.end.x, rect.position.y, rect.size.x, rect.size.y)), "the stall at %s has its twin across the lane" % str(rect))
	# the plaza: nothing solid within its radius but the fountain, the hub's things on its rim
	for prop: CapitalLayout.Prop in layout.props:
		if prop.radius <= 0.0 or prop.kind == "fountain":
			continue
		assert_gt(Vector2(prop.pos.x, prop.pos.z).distance_to(CapitalLayout.PLAZA_CENTER), CapitalLayout.PLAZA_RADIUS, "%s stands on the plaza's rim, not in it" % prop.kind)
	for key: String in ["gate_inside", "exit_booth", "complaint_1", "manhole", "net_plaza", "guard_in_1", "guard_in_2"]:
		var pos: Vector3 = layout.anchors[key] as Vector3
		assert_gt(Vector2(pos.x, pos.z).distance_to(CapitalLayout.PLAZA_CENTER), CapitalLayout.PLAZA_RADIUS - 0.6, "%s stands at the rim" % key)


func test_the_castle_is_immense_on_its_hill_and_seen_from_every_inside_region() -> void:
	assert_gte(CapitalLayout.CASTLE_SIZE.x, 70.0, "immense: wider than a district")
	assert_gte(CapitalLayout.CASTLE_SIZE.y + CapitalLayout.HILL_HEIGHT, 50.0, "and taller than anything in the zone")
	# the hill is not floor: the castle stands beyond the walkable ground, its door at the stair's foot on the forecourt
	for cz: int in range(CapitalLayout.HILL.position.y, CapitalLayout.HILL.end.y):
		for cx: int in range(CapitalLayout.HILL.position.x, CapitalLayout.HILL.end.x):
			assert_ne(layout.cell_at(cx, cz), CapitalLayout.Cell.GROUND)
	var door: Vector3 = layout.anchors["castle_door"] as Vector3
	assert_lt(absf(door.x - CapitalLayout.CASTLE.x), 0.1, "the door is on the castle's axis, at the end of the avenue")
	assert_lt(door.z - float(CapitalLayout.HILL.end.y), 1.5, "at the foot of the stair")
	# the straight grand avenue runs from the gate to the door
	var avenue: Dictionary = {}
	for route: Dictionary in layout.routes:
		if str(route["id"]) == "avenue":
			avenue = route
	assert_eq((avenue["a"] as Vector2).x, (avenue["b"] as Vector2).x, "the avenue is straight")
	assert_lt((avenue["b"] as Vector2).y, door.z + 1.5)
	# the castle's 78 m front lies within the camera's frame (about 36 degrees each side of north) from every paint-over spot
	for name: String in CapitalLayout.PO_CAMERAS.keys():
		var at: Vector2 = CapitalLayout.PO_CAMERAS[name] as Vector2
		var near_edge: float = clampf(at.x, CapitalLayout.CASTLE.x - CapitalLayout.CASTLE_SIZE.x * 0.4, CapitalLayout.CASTLE.x + CapitalLayout.CASTLE_SIZE.x * 0.4)
		var bearing: float = rad_to_deg(atan2(absf(near_edge - at.x), at.y - CapitalLayout.CASTLE.z))
		assert_lt(bearing, 34.0, "%s has Primm's Castle in frame (%.0f degrees off north)" % [name, bearing])


func test_the_stand_ins_stand_clear() -> void:
	for blocker: Vector3 in CapitalLayout.LANDMARK_BLOCKERS:
		var clear: float = layout.route_edge_distance(blocker.x, blocker.y) - blocker.z
		if Vector2(blocker.x, blocker.y) == CapitalLayout.PLAZA_CENTER:
			assert_gt(clear, 3.0, "the fountain leaves the plaza open round it")
			continue
		assert_gte(clear, CapitalLayout.ROUTE_CLEARANCE - 0.01, "the stand-in at (%.0f, %.0f) keeps off the routes" % [blocker.x, blocker.y])
		for key: Variant in layout.anchors.keys():
			var anchor: Vector3 = layout.anchors[key] as Vector3
			if str(key) == "camp":
				continue  # the lean-to belongs to the camp fire
			assert_gt(Vector2(anchor.x - blocker.x, anchor.z - blocker.y).length() - blocker.z, 2.4, "the stand-in at (%.0f, %.0f) leaves %s room" % [blocker.x, blocker.y, str(key)])
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	assert_false(builder.is_walkable(Vector3(CapitalLayout.WATCHTOWER.x, 0.0, CapitalLayout.WATCHTOWER.y)), "the watchtower blocks")


func test_the_paint_over_cameras_are_layout_data_on_open_ground() -> void:
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	builder.gate_open = true
	var spots: Dictionary = _spot_positions()
	for name: String in ["po_gate_road", "po_resistance_camp", "po_rift_fields", "po_ruined_outpost", "po_gate_plaza", "po_transit_yards", "po_hungry_quarter", "po_grave_row", "po_the_reek", "po_palace_approach"]:
		assert_true(CapitalLayout.PO_CAMERAS.has(name), "%s is a camera spot" % name)
		var at: Vector2 = CapitalLayout.PO_CAMERAS[name] as Vector2
		assert_true(builder.is_walkable(Vector3(at.x, 0.0, at.y), 0.3), "%s stands on open ground" % name)
		assert_false(layout.anchors.has(name), "%s is not an anchor" % name)
		for key: Variant in spots.keys():
			var spot: Vector3 = spots[key] as Vector3
			assert_gt(Vector2(spot.x - at.x, spot.z - at.y).length(), 2.0, "%s stands off %s" % [name, str(key)])
		for spawn: Dictionary in layout.enemy_spawns:
			var home: Vector3 = spawn["home"] as Vector3
			assert_gt(Vector2(home.x - at.x, home.z - at.y).length(), float(spawn["patrol"]) * 0.5 + 1.5, "%s stands off an enemy's beat" % name)


func test_the_way_in_is_walked_and_the_wall_is_great() -> void:
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.area_at(spawn.x, spawn.z).id, "gate", "the hero arrives on the Gate Road")
	assert_gt(exit.z, spawn.z, "the way back to town is behind the hero, at the road's end")
	assert_lt(layout.route_edge_distance(spawn.x, spawn.z), 0.0, "on the road")
	for building: CapitalLayout.Building in layout.buildings:
		if building.style == "wall" and building.district != "facade":
			assert_gte(building.height, 9.0, "the great wall dominates the outside (five hero-heights)")
		if building.style == "tower":
			assert_gte(building.height, 14.0)
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_builder.gd") + FileAccess.get_file_as_string("res://world/capital/capital_props.gd")
	assert_false(source.contains("portal"), "no spinning portal anywhere in the Capital")


func test_district_states_follow_their_path_zones() -> void:
	var expected: Dictionary = {"reek": "refusemancer", "grave": "necrocrat", "transit": "beefcake", "hungry": "gourmand"}
	for district: String in expected.keys():
		assert_eq(str(MusicDirector.CAPITAL_DISTRICTS.get(district, "")), str(expected[district]), "%s follows the %s Path" % [district, str(expected[district])])
	for building: CapitalLayout.Building in layout.buildings:
		if building.district in ["refusemancer", "necrocrat", "beefcake", "gourmand"]:
			var area: CapitalLayout.Area = layout.area_at(building.rect.get_center().x, building.rect.get_center().y)
			assert_eq(str(expected.get(area.id, "")), building.district, "a %s building stands in its own district" % building.district)


func test_the_dungeon_doors_carry_no_lettered_plate() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	for id: String in ["castle_door", "old_tunnels"]:
		assert_true(bool(def.spot_def(id).get("no_plate", false)), "%s: the landmark is the sign, no lettering in the world" % id)
