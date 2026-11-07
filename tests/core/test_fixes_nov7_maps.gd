extends GutTest
## Fix pass Nov 7, Part 2 (critic items 2, 7, 14 with owner decisions D5, D7): map rules, labels, the "Where to?" pick, the exit roamer's
## placement, travel prompts, the castle's neighbour reveal, heals that name their cause, the Gallery line, the Crease step, the Capital's
## named citizens and its last shop.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true
	Session.where_to_target = {}


func test_towns_are_explored_and_zones_show_their_outline() -> void:
	assert_false(MapRaster.shows_outline("town"))
	assert_false(MapRaster.shows_outline(CapitalZone.ID))
	for zone_id: String in Gatekeepers.IDS:
		assert_true(MapRaster.shows_outline(zone_id), zone_id)


func test_the_reveal_radius_is_generous() -> void:
	assert_gte(FogOfWar.REVEAL_RADIUS, 15.0)


func test_a_label_stays_inside_the_frame_and_clear_of_others() -> void:
	var frame: Rect2 = Rect2(0, 0, 400, 300)
	var taken: Array[Rect2] = []
	var first: Rect2 = FullMapScreen.place_label(Vector2(395, 290), Vector2(120, 20), 10.0, frame, taken)
	assert_true(frame.encloses(first), "pushed back inside the map: %s" % str(first))
	taken.append(first)
	var second: Rect2 = FullMapScreen.place_label(Vector2(395, 290), Vector2(120, 20), 10.0, frame, taken)
	assert_true(second.size == Vector2.ZERO or not second.intersects(first), "never on top of another name")


func test_the_exit_roamer_lives_on_walkable_ground_toward_the_hub() -> void:
	var walkable: Callable = func(at: Vector3) -> bool: return at.z > 2.0
	var home: Vector3 = ZoneScene.exit_roamer_home(Vector3.ZERO, Vector3(0, 0, 30), walkable)
	assert_ne(home, Vector3.INF)
	assert_gt(home.z, 2.0)
	assert_between(Vector2(home.x, home.z).length(), 8.5, 15.5)
	assert_eq(ZoneScene.most_common_type([{"type": "a"}, {"type": "b"}, {"type": "b"}]), "b")


func test_exits_say_where_they_go() -> void:
	assert_eq(TownScene.portal_prompt(ZonePortals.FINAL_ID), "Travel to %s" % str(ZonePortals.DESTINATION_NAMES[ZonePortals.FINAL_ID]))
	assert_string_starts_with(TownScene.portal_prompt("beefcake"), "Travel to")


func test_the_castle_shows_a_rooms_type_once_a_neighbour_is_cleared() -> void:
	var map: DungeonMap = DungeonMap.new()
	var a: DungeonMap.MapNode = map.add_node(DungeonMap.MapNode.new())
	var b: DungeonMap.MapNode = map.add_node(DungeonMap.MapNode.new())
	var c: DungeonMap.MapNode = map.add_node(DungeonMap.MapNode.new())
	map.connect_nodes(a.id, b.id)
	map.connect_nodes(b.id, c.id)
	map.current = a.id
	assert_true(map.neighbour_cleared(b.id), "next to where the party stands")
	assert_false(map.neighbour_cleared(c.id))
	assert_true(map.complete(b.id))
	assert_true(map.neighbour_cleared(c.id))
	assert_true(DungeonMapScreen.NEIGHBOUR_REVEAL.has(PrimmsCastleDungeon.DUNGEON_ID))


func test_a_nourish_heal_names_its_cause() -> void:
	var game: GameState = GameFactory.new_game(3)
	game.players[0].hp = 5
	game.gain_hp(0, 2, 77, "Nourish")
	var heal: GameEvent = null
	for event: GameEvent in game.events:
		if event.type == GameEvent.Type.HP_CHANGED and event.amount > 0:
			heal = event
	assert_not_null(heal)
	if heal != null:
		assert_eq(heal.detail, "Nourish")
		assert_eq(heal.card, 77)


func test_the_gallery_has_its_own_line_in_the_postgame() -> void:
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.GALLERY_LINE)
	assert_not_null(quest)
	if quest == null:
		return
	assert_true(quest.auto_give)
	assert_eq(quest.prerequisite.kind, Condition.Kind.POSTGAME)
	assert_eq(quest.objectives.size(), 3)
	assert_eq(quest.objectives[0].target_id, "manhole", "a pin on the way into the Crease")
	assert_eq(quest.objectives[2].target_id, "gallery_mirror")


func test_free_the_four_zones_has_a_crease_step_before_the_castle() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.FREE_ZONES)
	var crease: int = -1
	for index: int in range(quest.objectives.size()):
		if quest.objectives[index].target_id == "manhole":
			crease = index
	assert_eq(crease, quest.objectives.size() - 2, "the Crease, then the castle")


func test_the_capital_citizens_have_names_and_there_is_a_last_shop() -> void:
	var seen: Dictionary = {}
	for index: int in range(1, 10):
		var name: String = CapitalZone.citizen_name(index)
		assert_false(name.contains("Citizen"), name)
		assert_false(seen.has(name), "every name differs")
		seen[name] = true
	var ids: Array[String] = []
	for spot: Dictionary in ZoneDefs.get_def(CapitalZone.ID).spots:
		ids.append(str(spot["id"]))
		if str(spot["id"]).begins_with("shaft_"):
			assert_string_starts_with(str(spot["title"]), "Shaft to ", "a Crease door names where it leads")
	assert_true(ids.has("last_shop"))


func test_where_to_pick_is_remembered_for_the_arrow() -> void:
	var screen: FullMapScreen = FullMapScreen.new()
	screen._area_id = "town"
	screen.ping(MapPoi.make(MapPoi.Kind.VENDOR, Vector3(3, 0, 4), "Sable"))
	assert_eq(str(Session.where_to_target.get("area", "")), "town")
	assert_eq(Session.where_to_target.get("pos"), Vector3(3, 0, 4))
	screen.free()
