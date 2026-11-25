extends GutTest
## Fable Nov 25, Part 2 (the owner's item 13): Primm's Castle on its new map (MAP-PC of Batch 21, a portrait cutaway: the gate at
## the bottom, the Model Room at the top), the map that scrolls, and the duplicate nodes.
## The duplicates: the Batch 20 repaint of MAP-PC was painted from a screenshot of the game, and the image had the room
## medallions painted INTO it - a second set of rooms under the real ones. The new picture has plain landings; the tests
## below hold every dungeon map to one node per room, none overlapping, and the castle's landings to plain stone.

const ROOMS: Dictionary = {1: "Castle Gate", 2: "Gilded Pantry", 3: "Courtyard of Perfect Hedges", 4: "Gourmand Wing", 5: "Portrait Gallery",
	6: "Grand Foyer", 7: "Garden of Uniform Flowers", 8: "Beefcake Wing", 9: "Hall of Mirrors", 10: "Correction Ward Cells",
	11: "Necrocrat Wing", 12: "Ministry of Correction", 13: "Mirror Maze", 14: "Refusemancer Wing", 15: "Archive of Good Intentions",
	16: "Resistance Safe Room", 17: "Royal Kitchens", 18: "Primm's Private Gallery", 19: "Royal Stair", 20: "Clocktower Balcony",
	21: "Royal Vault", 22: "The Model Room"}
## plan-primm-castle-v2.jpg: the 41 links
const LINKS: String = "1-2, 1-3, 2-4, 2-5, 3-5, 3-6, 3-7, 4-8, 4-9, 5-8, 5-9, 6-9, 6-10, 7-9, 7-10, 8-11, 8-12, 9-11, 9-12, 9-13, 10-12, 10-13, 11-14, 11-15, 12-14, 12-15, 12-16, 13-16, 13-17, 14-18, 14-19, 15-19, 15-20, 16-19, 16-20, 17-20, 17-21, 18-22, 19-22, 20-22, 21-22"


func after_each() -> void:
	Session.main_dungeon_active = false
	Session.mini_active = false
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null


func test_the_castle_keeps_its_22_rooms_and_41_links() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	assert_eq(plan.nodes.size(), 22)
	var links: Array[String] = []
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		assert_true(node.node_name.begins_with(str(ROOMS[node.number])), "room %d is still %s (it is %s)" % [node.number, ROOMS[node.number], node.node_name])
		for target: int in node.next:
			links.append("%d-%d" % [node.number, target])
	links.sort_custom(func(a: String, b: String) -> bool:
		return int(a.get_slice("-", 0)) * 100 + int(a.get_slice("-", 1)) < int(b.get_slice("-", 0)) * 100 + int(b.get_slice("-", 1)))
	assert_eq(", ".join(links), LINKS)


func test_the_gate_is_at_the_bottom_and_every_link_climbs() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		assert_true(node.position.x > 0.08 and node.position.x < 0.92 and node.position.y > 0.05 and node.position.y < 0.99, "room %d is on the painting" % node.number)
		if node.number != 1:
			assert_lt(node.position.y, plan.node(1).position.y, "room %d is above the gate" % node.number)
		if node.number != 22:
			assert_gt(node.position.y, plan.node(22).position.y, "room %d is below the Model Room" % node.number)
		for target: int in node.next:
			assert_lt(plan.node(target).position.y, node.position.y, "%d -> %d climbs" % [node.number, target])


func test_every_link_of_the_castle_has_a_line_from_room_to_room() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	var curves: Dictionary = DungeonCatalog.curves("D-PC")
	assert_eq(DungeonCatalog.curve_gaps("D-PC"), [] as Array[String])
	var count: int = 0
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		for target: int in node.next:
			var key: String = "%d>%d" % [node.number - 1, target - 1]
			assert_true(curves.has(key), "link %d-%d has a line" % [node.number, target])
			if not curves.has(key):
				continue
			var points: PackedVector2Array = curves[key] as PackedVector2Array
			count += 1
			assert_gt(points.size(), 2)
			assert_lt(points[0].distance_to(node.position), 0.01, "%d-%d starts on its room" % [node.number, target])
			assert_lt(points[points.size() - 1].distance_to(plan.node(target).position), 0.01, "%d-%d ends on its room" % [node.number, target])
	assert_eq(count, 41)
	# a route-planning map with no walkway of its own per link draws every link
	assert_false(bool(DungeonCatalog.drawn_links("D-PC")["listed"]), "the castle draws all its links again")


## The owner: "nodes are duplicated underneath". One node per room, on every dungeon map, and no two on top of each other.
func test_every_dungeon_map_has_one_node_per_room_and_none_overlap() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var texture: Texture2D = MapArt.texture_for(blueprint.map_id)
		if texture == null:
			continue
		var rect: Rect2 = DungeonMapScreen.scroll_rect(texture.get_size()) if DungeonMapScreen.is_scroll_map(texture.get_size()) else DungeonMapScreen.fit_rect(texture.get_size())
		var map: DungeonMap = MainDungeons.build_map(blueprint.id) if MainDungeons.has_def(blueprint.id) else null
		var numbers: Dictionary = {}
		for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
			assert_false(numbers.has(node.number), "%s: room %d is listed once" % [blueprint.id, node.number])
			numbers[node.number] = true
		if map != null:
			# a dungeon without a start room of its own gets a hidden way in (never drawn): one visible node per room
			var shown: Dictionary = {}
			for built: DungeonMap.MapNode in map.nodes:
				if built.hidden:
					continue
				assert_false(shown.has(built.number), "%s: one built node for room %d" % [blueprint.id, built.number])
				shown[built.number] = true
			var listed: int = 0
			for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
				if not (node.type == "start" and node.note == "hidden"):
					listed += 1
					assert_true(shown.has(node.number), "%s: room %d is on the map" % [blueprint.id, node.number])
			assert_eq(shown.size(), listed, "%s: the map shows one node per room" % blueprint.id)
		var dense: bool = blueprint.nodes.size() > DungeonMapScreen.DENSE_NODE_COUNT and not DungeonMapScreen.is_scroll_map(texture.get_size())
		var disc: float = MapNodeButton.DIAMETER * (DungeonMapScreen.DENSE_NODE_SCALE if dense else 1.0)
		for first: DungeonCatalog.BlueprintNode in blueprint.nodes:
			for second: DungeonCatalog.BlueprintNode in blueprint.nodes:
				if second.number <= first.number:
					continue
				var apart: float = ((first.position - second.position) * rect.size).length()
				assert_gt(apart, disc, "%s: rooms %d and %d do not overlap (%.0f px apart, a disc is %.0f)" % [blueprint.id, first.number, second.number, apart, disc])


## The second set of rooms was in the picture itself. Under every castle room the new painting is a plain pale landing
## (the old one had a coloured medallion there: saturation 0.46 to 0.87; the new one 0.18 to 0.29).
func test_the_castle_painting_has_no_rooms_painted_into_it() -> void:
	var image: Image = MapArt.texture_for("MAP-PC").get_image()
	if image.is_compressed():
		image.decompress()
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-PC")
	var reach: int = int(image.get_width() * 0.014)
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		var centre: Vector2i = Vector2i(node.position * Vector2(image.get_size()))
		var saturation: float = 0.0
		var value: float = 0.0
		var count: int = 0
		for y: int in range(centre.y - reach, centre.y + reach, 2):
			for x: int in range(centre.x - reach, centre.x + reach, 2):
				if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
					continue
				var colour: Color = image.get_pixel(x, y)
				saturation += colour.s
				value += colour.v
				count += 1
		assert_gt(count, 0)
		assert_lt(saturation / float(count), 0.4, "room %d stands on plain stone, not on a painted medallion" % node.number)
		assert_gt(value / float(count), 0.8, "room %d stands on a pale landing" % node.number)


func test_only_the_portrait_map_scrolls() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var texture: Texture2D = MapArt.texture_for(blueprint.map_id)
		if texture != null:
			assert_eq(DungeonMapScreen.is_scroll_map(texture.get_size()), blueprint.map_id == "MAP-PC", blueprint.map_id)
	var size: Vector2 = MapArt.texture_for("MAP-PC").get_size()
	assert_eq(size, Vector2(1024, 1536))
	var rect: Rect2 = DungeonMapScreen.scroll_rect(size)
	assert_almost_eq(rect.size.x, DungeonMapScreen.SCROLL_MAP_WIDTH, 0.1)
	assert_almost_eq(rect.get_center().x, 960.0, 0.1)
	assert_gt(rect.size.y, 1080.0 * 1.5, "well over a screen tall")


func _open_castle(steps: Array[int] = []) -> DungeonMapScreen:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = CapitalZone.ID
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.dungeon_story_seen = []
	for number: int in steps:
		for node: DungeonMap.MapNode in Session.dungeon_map.available():
			if node.number == number:
				Session.dungeon_map.complete(node.id)
				break
	var screen: DungeonMapScreen = DungeonMapScreen.new()
	screen.screenshot_prepare({"quiet": true})
	add_child_autofree(screen)
	return screen


func _room(screen: DungeonMapScreen, number: int) -> MapNodeButton:
	return screen.get_node("MapLayer").get_node("Room_%d" % number) as MapNodeButton


func test_the_castle_map_scrolls_and_opens_on_the_party() -> void:
	var screen: DungeonMapScreen = _open_castle()
	await wait_frames(3)
	assert_true(screen.scrolls())
	var layer: Control = screen.get_node("MapLayer") as Control
	assert_not_null(layer.get_node_or_null("MapArt"), "the picture is in the scrolling layer")
	# one button per room, all in the layer, none left on the screen itself
	var rooms: int = 0
	for child: Node in layer.get_children():
		if child is MapNodeButton:
			rooms += 1
	assert_eq(rooms, 22)
	for child: Node in screen.get_children():
		assert_false(child is MapNodeButton, "no second set of rooms outside the layer")
	# at the gate the map is scrolled to its bottom, and the gate is on the screen
	assert_almost_eq(screen.scroll_offset(), screen.scroll_range(), 0.5, "opens at the bottom, on the Castle Gate")
	var gate_y: float = _room(screen, 1).center_point().y - screen.scroll_offset()
	assert_true(gate_y > 0.0 and gate_y < 1080.0, "the gate is in view")
	var top_y: float = _room(screen, 22).center_point().y - screen.scroll_offset()
	assert_lt(top_y, 0.0, "the Model Room is above the screen until the map is scrolled")
	# the rooms keep their full size on the larger map
	assert_eq(_room(screen, 5).scale, Vector2.ONE)


func test_the_wheel_keys_and_drag_scroll_it() -> void:
	var screen: DungeonMapScreen = _open_castle()
	await wait_frames(3)
	var bottom: float = screen.scroll_offset()
	var wheel: InputEventMouseButton = InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	wheel.position = Vector2(960, 540)
	screen._input(wheel)
	assert_almost_eq(screen.scroll_offset(), bottom - DungeonMapScreen.SCROLL_WHEEL_STEP, 0.5, "the wheel scrolls up")
	var key: InputEventKey = InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_HOME
	assert_true(screen._scroll_key(key))
	assert_eq(screen.scroll_offset(), 0.0, "Home goes to the top")
	assert_almost_eq((screen.get_node("MapLayer") as Control).position.y, 0.0, 0.01)
	key.keycode = KEY_PAGEDOWN
	assert_true(screen._scroll_key(key))
	assert_almost_eq(screen.scroll_offset(), 540.0, 0.5, "Page Down goes half a screen down")
	key.keycode = KEY_END
	assert_true(screen._scroll_key(key))
	assert_almost_eq(screen.scroll_offset(), screen.scroll_range(), 0.5)
	assert_almost_eq((screen.get_node("MapLayer") as Control).position.y, -screen.scroll_range(), 0.5, "the layer moves with the scroll")
	# a drag on the map: press, move 200 px down -> the map follows the hand (scrolls up by 200)
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(700, 300)
	screen._input(press)
	var move: InputEventMouseMotion = InputEventMouseMotion.new()
	move.button_mask = MOUSE_BUTTON_MASK_LEFT
	move.position = Vector2(700, 500)
	screen._input(move)
	assert_almost_eq(screen.scroll_offset(), screen.scroll_range() - 200.0, 0.5, "a drag scrolls")
	press.pressed = false
	screen._input(press)
	# never past the ends
	screen.scroll_by(-99999.0)
	assert_eq(screen.scroll_offset(), 0.0)
	screen.scroll_by(99999.0)
	assert_almost_eq(screen.scroll_offset(), screen.scroll_range(), 0.5)


func test_the_controller_brings_a_focused_room_into_view() -> void:
	var screen: DungeonMapScreen = _open_castle()
	await wait_frames(3)
	var was: InputDevice.Kind = InputDevice.kind
	InputDevice.set_kind(InputDevice.Kind.PAD)
	var far_room: MapNodeButton = _room(screen, 20)
	assert_lt(far_room.center_point().y - screen.scroll_offset(), 0.0, "the Clocktower Balcony starts off the screen")
	screen._keep_in_view(far_room.map_node.id)
	await wait_seconds(0.5)
	var on_screen: float = far_room.center_point().y - screen.scroll_offset()
	assert_true(on_screen > DungeonMapScreen.SCROLL_EDGE - 1.0 and on_screen < 1080.0 - DungeonMapScreen.SCROLL_EDGE + 1.0, "the map scrolled the focused room into view (%.0f)" % on_screen)
	InputDevice.set_kind(was)


func test_mid_run_the_map_opens_on_the_room_the_party_stands_in() -> void:
	var screen: DungeonMapScreen = _open_castle([2, 5, 9, 12])
	await wait_frames(3)
	var here: MapNodeButton = null
	for number: int in ROOMS.keys():
		if _room(screen, number).map_node.id == Session.dungeon_map.current:
			here = _room(screen, number)
	assert_not_null(here)
	assert_eq(here.map_node.number, 12, "the party stands in the Ministry of Correction")
	await wait_seconds(1.6)  # the glide that follows the marker
	assert_almost_eq(here.center_point().y - screen.scroll_offset(), 540.0, 2.0, "the party's room is in the middle of the screen")


## A dungeon in progress is not written to a save (a loaded save starts in the Capital and the castle from its gate); what a
## save does keep of the castle is the fog (the rooms seen, by node id) and the marker's room. The ids are the rooms' numbers
## minus one, as before, so a save made on the old map names the same rooms on the new one.
func test_a_save_from_the_old_map_points_at_the_same_rooms() -> void:
	var castle: DungeonMap = MainDungeons.build_map(CapitalZone.ID)
	for node: DungeonMap.MapNode in castle.nodes:
		assert_eq(node.id, node.number - 1, "room %d keeps its id" % node.number)
		assert_true(node.title.begins_with(str(ROOMS[node.number])))
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.note_dungeon_entered("D-PC")
	for id: int in [0, 1, 4, 8]:
		Session.note_node_seen("D-PC", id)
	Session.flags["map_marker"] = 8
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	Session.from_dict(saved)
	for id: int in [0, 1, 4, 8]:
		assert_true(Session.node_revealed("D-PC", id), "%s is still known" % castle.node(id).title)
	assert_false(Session.node_revealed("D-PC", 20))
	assert_eq(castle.node(int(Session.flags.get("map_marker", 0))).title, "Hall of Mirrors", "the marker's room is the same room")
