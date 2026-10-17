extends GutTest
## Crosspath pass, Part C: the bigger square with every shop vendor round it, the wide streets, and the Secret Dealer's alley.

const VENDORS: Array[String] = ["market", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist"]
## The playbook's route width: four hero widths (4.2 m outdoors).
const ROUTE_WIDTH: float = 4.2

var _town: TownBuilder


func before_each() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	_town = TownBuilder.new()
	_town.build(root, false)
	TownSquare.build(root, _town, GraphicsQuality.Level.MEDIUM)


func _shop(key: String) -> TownLayout.Shop:
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.key == key:
			return shop
	return null


func _npc(key: String) -> Vector3:
	return _town.anchors["npc_%s" % key] as Vector3


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func test_the_square_is_noticeably_bigger() -> void:
	assert_gte(TownLayout.PLAZA_RADIUS, 10.0, "the square was a 6.2 m circle")
	assert_gte(TownLayout.FOUNTAIN_RADIUS, 2.4, "and the fountain grew with it")


func test_every_vendor_has_a_storefront_round_the_square_facing_in() -> void:
	for key: String in VENDORS:
		var shop: TownLayout.Shop = _shop(key)
		assert_not_null(shop, key)
		var npc: Vector3 = _npc(key)
		assert_lt(_flat(npc, TownLayout.PLAZA), TownLayout.PLAZA_RADIUS + 4.0, "%s stands on the square's rim" % key)
		var inward: Vector3 = (TownLayout.PLAZA - shop.center)
		inward.y = 0.0
		assert_gt(shop.front().dot(inward.normalized()), 0.6, "%s faces the square" % key)
		assert_true(_town.is_walkable(npc + (TownLayout.PLAZA - npc).normalized() * 1.0, 0.3), "%s can be walked up to from the square" % key)


func test_vendors_have_breathing_room() -> void:
	for i: int in range(VENDORS.size()):
		for j: int in range(i + 1, VENDORS.size()):
			assert_gte(_flat(_npc(VENDORS[i]), _npc(VENDORS[j])), 5.0, "%s and %s keep apart" % [VENDORS[i], VENDORS[j]])
	# and no other interact spot crowds a vendor's prompt
	for key: String in _town.anchors.keys():
		if key.begins_with("npc_") or key in VENDORS or key == "plaza" or key == "fountain" or key.begins_with("tailor") or key == "alchemist_door" or key == "spawn":
			continue
		for vendor: String in VENDORS:
			assert_gte(_flat(_town.anchors[key] as Vector3, _npc(vendor)), 2.5, "%s keeps 2.5 m from %s" % [key, vendor])


func test_the_streets_into_the_square_are_wide_and_clear() -> void:
	assert_gte(TownLayout.ROAD_WIDTH, ROUTE_WIDTH)
	var roads: Dictionary = TownLayout.roads()
	for id: String in ["market_west", "market_east", "gate_road", "champions"]:
		var points: Array[Vector3] = TownLayout.sample(roads[id] as Array, 1.0)
		for index: int in range(points.size() - 1):
			var p: Vector3 = points[index]
			if _flat(p, TownLayout.PLAZA) > 26.0 or _flat(p, TownLayout.PLAZA) < TownLayout.PLAZA_RADIUS:
				continue
			var along: Vector3 = (points[index + 1] - p).normalized()
			var across: Vector3 = Vector3(-along.z, 0.0, along.x)
			for offset: float in [-ROUTE_WIDTH * 0.5 + 0.35, 0.0, ROUTE_WIDTH * 0.5 - 0.35]:
				assert_true(_town.is_walkable(p + across * offset, 0.3), "%s is clear %.1f m off its centre at %s" % [id, offset, str(p)])


func test_the_square_holds_only_the_fountain_and_a_few_low_things() -> void:
	var inside: Array[Vector3] = []
	for circle: Vector3 in _town.obstacles:
		if Vector2(circle.x - TownLayout.PLAZA.x, circle.y - TownLayout.PLAZA.z).length() < TownLayout.PLAZA_RADIUS - 0.3:
			inside.append(circle)
	# the fountain, four crest plinths, four lamps, four benches
	assert_lte(inside.size(), 13, "the square is easy to cross: %s" % str(inside))
	for circle: Vector3 in inside:
		if circle.z > 1.0:
			assert_lt(Vector2(circle.x - TownLayout.PLAZA.x, circle.y - TownLayout.PLAZA.z).length(), 0.1, "only the fountain is big")


func test_the_black_market_alley_is_hidden_but_reachable() -> void:
	var dealer: Vector3 = _town.anchors["hidden_vendor"] as Vector3
	assert_true(TownLayout.ALLEY.has_point(Vector2(dealer.x, dealer.z)), "the Secret Dealer stands in the alley")
	assert_lt(TownLayout.ALLEY.size.x, 3.0, "a narrow alley")
	# walked from the square's corner up the alley with a 1 m body
	var mouth: Vector3 = Vector3(TownLayout.ALLEY.get_center().x, 0.0, TownLayout.ALLEY.end.y + 0.8)
	var steps: int = 12
	for i: int in range(steps + 1):
		var p: Vector3 = mouth.lerp(dealer + Vector3(0.0, 0.0, 1.2), float(i) / float(steps))
		assert_true(_town.is_walkable(p, 0.5), "the alley is open at %s" % str(p))
	assert_lt(_flat(mouth, TownLayout.PLAZA), TownLayout.PLAZA_RADIUS + 6.0, "it opens off the square")
	# dim: no street lamp near it
	for lamp: Vector3 in TownLayout.lamps():
		assert_gt(_flat(lamp, dealer), 6.0, "no street lamp lights the dealer")
	# not a storefront: the old back-alley smithy is gone
	assert_false(_town.kit_buildings.has("hidden_vendor"))
