extends GutTest
## Vertical slice, Part E: the rebuilt town square. Layout, scale, the kit in place, no readable text in the world, nothing on a street.


var _root: Node3D
var _town: TownBuilder
var _square: TownSquare


func before_each() -> void:
	_root = Node3D.new()
	add_child_autofree(_root)
	_town = TownBuilder.new()
	_town.build(_root)
	_square = TownSquare.build(_root, _town, GraphicsQuality.Level.MEDIUM)


func _kit_shops() -> Array[TownLayout.Shop]:
	var result: Array[TownLayout.Shop] = []
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.kind == "kit":
			result.append(shop)
	return result


func test_the_square_is_built_from_kit_buildings() -> void:
	assert_gte(_kit_shops().size(), 17, "shops, houses, civic buildings")
	assert_eq(_town.kit_buildings.size(), _kit_shops().size())
	for key: String in ["item_vendor", "market", "tailor", "equipment_vendor", "pack_vendor", "alchemist", "deck", "gate", "elder_home", "codex", "church"]:
		assert_true(_town.kit_buildings.has(key), "%s is a kit building" % key)
		assert_true(_town.anchors.has(key), "%s keeps its anchor" % key)


func test_every_shop_anchor_and_npc_spot_survives() -> void:
	for key: String in ["market", "deck", "well", "gate", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist", "codex", "church", "npc_market", "npc_item_vendor", "npc_equipment_vendor", "npc_pack_vendor", "npc_tailor", "npc_alchemist", "npc_gate", "npc_elder", "notice_board", "spawn", "arena", "rift_station"]:
		assert_true(_town.anchors.has(key), "anchor %s" % key)
	var door: Vector3 = _town.anchors["market"] as Vector3
	assert_true(_town.is_walkable(door, 0.3), "the card shop door spot is a place the hero can stand")


func test_buildings_do_not_overlap_each_other_or_the_streets() -> void:
	var shops: Array[TownLayout.Shop] = _kit_shops()
	for index: int in range(shops.size()):
		var shop: TownLayout.Shop = shops[index]
		# the four corners and the edge midpoints stay off the street paving and the plaza
		var half: Vector2 = shop.footprint * 0.5
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(shop.yaw))
		for local: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]:
			var world: Vector3 = shop.center + basis * Vector3(local.x * half.x, 0.0, local.y * half.y)
			assert_false(TownLayout.is_paved(world, 0.0), "%s (%s) stays off the paving at %s" % [shop.preset, shop.key, str(world)])
		for other_index: int in range(index + 1, shops.size()):
			var other: TownLayout.Shop = shops[other_index]
			var gap: float = Vector2(shop.center.x - other.center.x, shop.center.z - other.center.z).length() - (maxf(half.x, half.y) + maxf(other.footprint.x, other.footprint.y) * 0.5)
			if gap < 0.0:
				# circles overlapped: check the real rectangles
				for local: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
					var corner: Vector3 = shop.center + basis * Vector3(local.x * half.x, 0.0, local.y * half.y)
					assert_false(other.covers(corner, -0.05), "%s overlaps %s" % [shop.preset, other.preset])


func test_door_height_follows_the_scale_rule() -> void:
	assert_between(StorybookScale.HERO_HEIGHT / BuildingKit.DOOR_H, 0.85, 0.9)
	# the tallest props follow too: a lamp post is two to three heroes tall
	var post: Node3D = PropKit.lantern_post()
	add_child_autofree(post)
	var height: float = (post.get_child(0) as MeshInstance3D).mesh.get_aabb().size.y
	assert_between(height / StorybookScale.HERO_HEIGHT, 2.0, 3.0)


func test_no_readable_text_in_the_world() -> void:
	var labels: Array[Node] = _root.find_children("*", "Label3D", true, false)
	for label: Node in labels:
		assert_eq((label as Label3D).text, "", "no lettering at %s" % str(label.get_path()))
	assert_gte(_square.streets.signpost_positions.size(), 4, "the signposts stand, as icon boards")
	for lines: Array in _square.streets.signpost_lines:
		assert_gt(lines.size(), 0, "what a signpost said is kept for its popup")


func test_the_dressing_stays_off_the_streets() -> void:
	for obstacle: Vector3 in _town.obstacles:
		if Vector2(obstacle.x - TownLayout.PLAZA.x, obstacle.y - TownLayout.PLAZA.z).length() > 12.0:
			continue
		# an obstacle in the middle of a lane would wall it off; lamps and signposts stand at the lane edges
		var d: float = TownLayout.distance_to_roads(Vector3(obstacle.x, 0.0, obstacle.y))
		if Vector2(obstacle.x - TownLayout.PLAZA.x, obstacle.y - TownLayout.PLAZA.z).length() <= TownLayout.PLAZA_RADIUS + 0.3:
			continue
		assert_gt(d, 1.0, "obstacle at %s keeps off the middle of a street" % str(obstacle))


func test_scale_of_the_whole_square_is_big_and_compact() -> void:
	# compact: every kit building within 40 m of the plaza; big: each at least 5 m tall to the ridge
	for shop: TownLayout.Shop in _kit_shops():
		assert_lt(Vector2(shop.center.x - TownLayout.PLAZA.x, shop.center.z - TownLayout.PLAZA.z).length(), 40.0, "%s stays near the square" % shop.preset)
		var building: Node3D = _town.kit_buildings.get(shop.key if shop.key != "" else "") as Node3D
		if building != null:
			assert_gt(float(building.get_meta("height")), 5.0)
