class_name StoryV2FinalSmoke
extends Node
## Story v2 Part I: human-input e2e of the new story flows after the opening (the opening itself is `tools/prologue_smoke.gd`). Windowed, injected input only
## (keys, clicks); debug helpers set flags to jump between stages. One Godot process. Run: `bash tools/run_story_v2_final_smoke.sh` (exit 0 = every check passed).
##  1. Crosspath: walk from the plaza to every vendor and building along the streets (path-planned, no teleport).
##  2. The deck builder refuses a second Path before a zone is freed.
##  3. A zone is freed: Maren's memory 1 plays, then the second Path opens.
##  4. The House of Gains: Stairs Down and The Iron-less Prison node (the rescue scene and the Flex boon).
##  5. The Hall of Final Approvals: Mortimer is the boss, Vellum the elite, Agnes takes the vacancy.
##  6. The castle's Model Room with fewer than four zones: Primm reveals the prince.
##  7. The ending (ten beats), Rip's forest portal, the hatch and the Path-ology Lab.

const TIME_LIMIT_SECONDS: float = 90.0
const GRID: float = 0.35

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.seconds(0.6)
	if _want("streets"):
		await _stage_streets(town)
	if _want("deck"):
		await _stage_deck_rule(town)
	if _want("memory"):
		await _stage_memory(town)
	if _want("hog"):
		await _stage_house_of_gains()
	if _want("hall"):
		await _stage_hall()
	if _want("reveal"):
		await _stage_primm_reveal()
	if _want("ending"):
		await _stage_ending()
	if _want("forest"):
		await _stage_forest_and_lab()
	_finish(_failures.is_empty(), "streets, deck rule, memory, House of Gains, Hall, Primm reveal, ending, forest portal and the Lab")


## `--only=a,b` (after `--`) runs just those stages: streets deck memory hog hall reveal ending forest.
func _want(stage: String) -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			return arg.substr(7).split(",").has(stage)
	return true


# ---- 1. Crosspath: every vendor on foot -----------------------------------------------------------------------------------------------


func _stage_streets(town: TownScene) -> void:
	var plaza: Vector3 = town.town.anchors["spawn"] as Vector3
	var wanted: Array[String] = ["vendor", "item_vendor", "equipment_vendor", "tailor", "pack_vendor", "alchemist", "deck", "elder", "codex", "notice_board", "gate", "well", "guard"]
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--target="):
			wanted = [arg.substr(9)] as Array[String]
	var reached_all: bool = true
	for id: String in wanted:
		var spot: TownScene.Spot = _spot(town, id)
		if spot == null:
			_check(false, "the %s spot exists" % id)
			continue
		town.player.position = plaza
		await driver.frames(4)
		var arrived: bool = await _walk_plan(town.player, Callable(town.town, "is_walkable"), spot.position, spot.radius * 0.7, town.town.map_bounds())
		reached_all = reached_all and arrived
		await driver.frames(6)
		var prompt_visible: bool = town.hud._prompt_panel.visible
		_check(arrived, "walked from the plaza to the %s" % id)
		_check(prompt_visible, "the %s shows an interaction prompt on arrival" % id)
	await _shot("e2e_streets_arrived")
	_check(reached_all, "every vendor and building in Crosspath is reachable on foot from the plaza")


# ---- 2. The deck rule ------------------------------------------------------------------------------------------------------------------


func _stage_deck_rule(town: TownScene) -> void:
	Session.add_cards([Session.content.card("G-01"), Session.content.card("G-01")] as Array[CardData])
	var deck_spot: TownScene.Spot = _spot(town, "deck")
	town.player.position = deck_spot.position + Vector3(0.0, 0.0, 0.8)
	await driver.frames(6)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.8)
	var screen: DeckbuilderScreen = null
	for child: Node in town._overlay_layer.get_children():
		if child is DeckbuilderScreen:
			screen = child as DeckbuilderScreen
	_check(screen != null, "the Deck Station opens")
	if screen != null:
		var gourmand: CardData = Session.content.card("G-01")
		var reason: String = screen.editor.why_not_add(gourmand)
		_check(reason.contains("too weak to walk more than one Path"), "a second Path is refused with the themed message: %s" % reason)
		await _shot("e2e_deck_station")
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.5)
	_check(DeckValidator.max_colors(Session.profile) == 1, "one Path before any zone is freed")


# ---- 3. Memory 1 and the second Path ---------------------------------------------------------------------------------------------


func _stage_memory(town: TownScene) -> void:
	Session.set_flag(&"elder_greeted")
	Session.complete_zone("beefcake")
	await driver.frames(4)
	_check(Session.pending_memory() == 1, "the first zone frees fragment 1")
	var elder: TownScene.Spot = _spot(town, "elder")
	town.player.position = town.town.anchors["plaza"] as Vector3 + Vector3(0.0, 0.0, 6.0)
	await driver.frames(4)
	await _walk_plan(town.player, Callable(town.town, "is_walkable"), elder.position, elder.radius * 0.7, town.town.map_bounds())
	await driver.tap_key(KEY_E)
	var memory: MemoryScreen = null
	var guard: int = 0
	while memory == null and guard < 40:
		guard += 1
		await driver.seconds(0.3)
		memory = _find(town._overlay_layer, MemoryScreen) as MemoryScreen
		if memory == null and town.dialogue.active:
			await driver.tap_key(KEY_E)
	_check(memory != null, "talking to Maren plays the memory screen")
	if memory != null:
		await driver.seconds(2.4)
		await _shot("e2e_memory_1")
		guard = 0
		while is_instance_valid(memory) and guard < 30:
			guard += 1
			await driver.tap_key(KEY_E)
			await driver.seconds(0.9)
	guard = 0
	var popup: AnnouncementScreen = null
	while popup == null and guard < 40:
		guard += 1
		popup = _find(town._overlay_layer, AnnouncementScreen) as AnnouncementScreen
		if popup == null:
			if town.dialogue.active:
				await driver.tap_key(KEY_E)
			await driver.seconds(0.4)
	_check(popup != null, "the second Path announcement appears after her answer")
	if popup != null:
		await driver.seconds(1.2)
		await _shot("e2e_second_path")
		await driver.click_button("Continue")
		await driver.seconds(0.6)
	_check(Session.flag(&"memory_1") and Session.memories_recovered() == 1, "fragment 1 is recovered")
	_check(DeckValidator.max_colors(Session.profile) == 2, "two Paths are allowed now")


# ---- 4. The House of Gains: Stairs Down and the Iron-less Prison ----------------------------------------------------------------


func _stage_house_of_gains() -> void:
	Session.begin_zone_visit("beefcake")
	Session.enter_main_dungeon()
	var screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	if screen == null:
		_check(false, "the House of Gains map opens")
		return
	var map: DungeonMap = Session.dungeon_map
	_check(_node_titled(map, 7).title == "Stairs Down" and _node_titled(map, 9).title == "The Iron-less Prison", "nodes 7 and 9 are Stairs Down and The Iron-less Prison")
	_clear_numbers(map, [1, 2, 4, 6])
	screen = await _reload_map()
	await _click_node(screen, 7)
	await driver.seconds(0.6)
	await _pick_event_choice(0)
	_clear_numbers(map, [8])
	screen = await _reload_map()
	await _click_node(screen, 9)
	var guard: int = 0
	while guard < 40 and _find(get_tree().current_scene, EventScreen) == null:
		guard += 1
		var cutscene: Node = _find(get_tree().current_scene, CutsceneScreen)
		if cutscene != null:
			await driver.click(Vector2(960, 500))
		elif screen._dialogue != null and screen._dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.5)
	await _shot("e2e_iron_less_prison")
	await _pick_event_choice(0)
	_check(HouseOfGainsDungeon.rescued(Session.run), "freeing Grandmaster Flex in the Iron-less Prison grants his boon")
	await _leave_dungeon()


# ---- 5. The Hall: Mortimer, Vellum and Agnes -----------------------------------------------------------------------------------


func _stage_hall() -> void:
	await _settle()
	var map: DungeonMap = MainDungeons.build_map("necrocrat")
	var found_boss: bool = false
	var found_elite: bool = false
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BOSS and node.enemy_name == "Mortimer Grimsby, CE-No":
			found_boss = true
		if node.kind == DungeonMap.Kind.ELITE and node.enemy_name == "Undersecretary Vellum" and node.title == "Appeals Court":
			found_elite = true
	_check(found_boss, "Mortimer Grimsby, CE-No is the boss of the Office of Final Approval")
	_check(found_elite, "Undersecretary Vellum is the elite at the Appeals Court")
	Session.begin_zone_visit("necrocrat")
	Session.dungeon_key = "necrocrat"
	var scene: CutsceneScreen = CutsceneScreen.make("vacancy")
	var done: Array = [false]
	scene.finished.connect(func() -> void: done[0] = true)
	get_tree().current_scene.add_child(scene)
	await driver.seconds(0.6)
	await _shot("e2e_vacancy_start")
	var guard: int = 0
	while not bool(done[0]) and guard < 60:
		guard += 1
		await driver.click(Vector2(960, 500))
		await driver.seconds(0.45)
	_check(bool(done[0]), "Agnes's vacancy scene plays through by clicking")


# ---- 6. Primm with fewer than four zones: the reveal -----------------------------------------------------------------------------


func _stage_primm_reveal() -> void:
	_check(Session.completed_zone_count() < ZoneCompletion.TOTAL_ZONES and not Session.flag(MemoryDefs.FLAG_REVEALED), "the prince is not known yet")
	Session.begin_zone_visit("final")
	Session.enter_main_dungeon()
	var screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	if screen == null:
		_check(false, "the castle map opens")
		return
	var map: DungeonMap = Session.dungeon_map
	_clear_numbers(map, [1, 2, 3, 4, 5, 6, 7, 8, 9])
	screen = await _reload_map()
	var boss: DungeonMap.MapNode = map.boss()
	await _click_node(screen, boss.number)
	var saw_reveal: bool = false
	var guard: int = 0
	while guard < 90 and get_tree().current_scene is DungeonMapScreen:
		guard += 1
		var cutscene: CutsceneScreen = _find(get_tree().current_scene, CutsceneScreen) as CutsceneScreen
		if cutscene != null:
			if cutscene.scene_id == "primm_reveal":
				saw_reveal = true
				await _shot("e2e_primm_reveal")
			await driver.click(Vector2(960, 500))
		elif screen._dialogue != null and screen._dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.45)
	_check(saw_reveal, "Primm reveals the prince's identity when fewer than four zones are freed")
	_check(Session.flag(MemoryDefs.FLAG_REVEALED), "the reveal sets prince_revealed")
	_check(RoyalFamily.wanderer_name() == RoyalFamily.data().prince_name, "the Wanderer is now addressed by the prince's name")
	await _leave_dungeon()


# ---- 7. The ending, Rip's portal and the Lab -------------------------------------------------------------------------------------------


func _stage_ending() -> void:
	await _settle()
	Session.set_flag(&"primm_defeated")
	SceneManager.change_scene(Session.ENDING_SCENE)
	var ending: EndingScreen = await _wait_for(EndingScreen) as EndingScreen
	if ending == null:
		_check(false, "the ending screen opens")
		return
	var beats_seen: int = 0
	var guard: int = 0
	while guard < 80 and not ending._credits_running:
		guard += 1
		await driver.seconds(0.4)
		if ending._index > beats_seen - 1:
			beats_seen = ending._index + 1
		if guard == 8:
			await _shot("e2e_ending_beat")
		await driver.click(Vector2(960, 400))
	_check(beats_seen == EndingDefs.BEATS.size(), "all %d ending beats were shown (saw %d)" % [EndingDefs.BEATS.size(), beats_seen])
	_check(ending._credits_running, "the credits start after the last beat")
	Session.save_enabled = false
	SceneManager.go_to_town()


func _stage_forest_and_lab() -> void:
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_check(false, "back in the town")
		return
	await driver.seconds(0.6)
	var rift: TownScene.Spot = _spot(town, "rift_station")
	town.player.position = town.town.anchors["spawn"] as Vector3
	await driver.frames(4)
	var arrived: bool = await _walk_plan(town.player, Callable(town.town, "is_walkable"), rift.position, rift.radius * 0.7, town.town.map_bounds())
	_check(arrived, "walked to Rip's station")
	await driver.tap_key(KEY_E)
	var screen: FastTravelScreen = null
	var guard: int = 0
	while screen == null and guard < 40:
		guard += 1
		await driver.seconds(0.35)
		screen = _find(town._overlay_layer, FastTravelScreen) as FastTravelScreen
		if screen == null and town.dialogue.active:
			await driver.tap_key(KEY_E)
	_check(screen != null, "Rip's tip is followed by the rift menu")
	_check(Session.flag(PathologyLab.FLAG_FOREST_OPEN) and Session.flag(PathologyLab.FLAG_REVEALED), "Rip's tip opens the forest station and reveals the hatch")
	if screen == null:
		return
	await _shot("e2e_rift_menu")
	var row: Node = screen.find_child("Station_forest", true, false)
	var go: Button = driver.find_button("Rip me there", row) if row != null else null
	_check(go != null, "the forest is on the Rift Express")
	if go == null:
		return
	await driver.click(driver.button_center(go))
	guard = 0
	while guard < 60 and not (get_tree().current_scene is StartingAreaScene):
		guard += 1
		if town.dialogue.active:
			await driver.tap_key(KEY_E)
		await driver.seconds(0.4)
	var forest: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	_check(forest != null, "the rift lands in the forest")
	if forest == null:
		return
	await driver.seconds(0.8)
	_check(forest.area.lab_open, "the Lab's hatch stands revealed in the clearing")
	await _shot("e2e_forest_postgame")
	var hatch: Vector3 = forest.area.anchors["lab"] as Vector3
	var reached: bool = await _walk_plan(forest.player, Callable(forest.area, "is_walkable"), hatch, 1.0, forest.area.map_bounds())
	_check(reached, "walked to the hatch")
	await driver.frames(6)
	_check(forest._prompt_label.text.contains("Path-ology Lab"), "the hatch prompt names the Path-ology Lab")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.6)
	_check(await driver.click_button("Descend"), "the hatch asks for confirmation")
	await driver.seconds(1.2)
	guard = 0
	while guard < 20 and not Session.in_dungeon():
		guard += 1
		await driver.seconds(0.4)
		if driver.find_button("Use this deck") != null:
			await driver.click_button("Use this deck")
	_check(Session.in_dungeon() and Session.dungeon_key == PathologyLab.DUNGEON_ID, "the hatch leads into the Path-ology Lab")
	var lab_screen: DungeonMapScreen = await _wait_for(DungeonMapScreen) as DungeonMapScreen
	if lab_screen != null:
		await driver.seconds(0.8)
		await _shot("e2e_lab_map")


# ---- Helpers ---------------------------------------------------------------------------------------------------------------------------


## Leaves a debug-started dungeon run for the town without the zone scenes in between.
func _leave_dungeon() -> void:
	Session.run = null
	Session.dungeon_map = null
	Session.main_dungeon_active = false
	Session.mini_active = false
	Session.zone_run = null
	SceneManager.go_to_town()
	await _settle()
	await _wait_for(TownScene)


## Waits until no scene change is in flight.
func _settle() -> void:
	await driver.seconds(0.8)
	var guard: int = 0
	while SceneManager.busy and guard < 200:
		guard += 1
		await driver.frames(5)

func _spot(scene: TownScene, id: String) -> TownScene.Spot:
	for spot: TownScene.Spot in scene.spots:
		if spot.id == id:
			return spot
	return null


func _node_titled(map: DungeonMap, number: int) -> DungeonMap.MapNode:
	for node: DungeonMap.MapNode in map.nodes:
		if node.number == number:
			return node
	return null


func _clear_numbers(map: DungeonMap, numbers: Array[int]) -> void:
	for number: int in numbers:
		var node: DungeonMap.MapNode = _node_titled(map, number)
		if node != null:
			map.complete(node.id)


func _reload_map() -> DungeonMapScreen:
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")
	await driver.seconds(0.4)
	return await _wait_for(DungeonMapScreen) as DungeonMapScreen


func _click_node(screen: DungeonMapScreen, number: int) -> void:
	var node: DungeonMap.MapNode = _node_titled(screen.map, number)
	var button: Control = screen._buttons[node.id] as Control
	await driver.seconds(0.8)
	await driver.click(driver.center_of_control(button))
	await driver.seconds(0.5)


func _pick_event_choice(index: int) -> void:
	var guard: int = 0
	var event: EventScreen = null
	while guard < 20 and event == null:
		guard += 1
		event = _find(get_tree().current_scene, EventScreen) as EventScreen
		await driver.seconds(0.3)
	if event == null:
		return
	await driver.seconds(0.5)
	var button: Button = event._buttons[index] as Button
	await driver.click(driver.center_of_control(button))
	await driver.seconds(0.7)
	await driver.click_button("Continue")
	await driver.seconds(0.6)


func _find(root: Node, kind: Variant) -> Node:
	if root == null:
		return null
	for node: Node in root.find_children("*", "", true, false):
		if is_instance_of(node, kind):
			return node
	return null


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


## Plans a route over the walkable ground (4-neighbour grid flood), then walks it with the movement keys: no teleporting. True when the hero ends within `radius` of `target`.
func _walk_plan(player: Node3D, can_stand: Callable, target: Vector3, radius: float, bounds: Rect2) -> bool:
	var start: Vector3 = player.position
	# Plan with a margin round obstacles first (a real player does not hug lamps), then with the hero's bare radius.
	var route: Array[Vector3] = _plan(can_stand.bind(0.55), start, target, radius, bounds)
	if route.is_empty():
		route = _plan(can_stand.bind(0.22), start, target, radius, bounds)
	if route.is_empty():
		return false
	# One axis at a time, cell by cell: exactly the moves the planner checked (no corner cutting). When an obstacle edge stops the hero, the other axis is tried.
	for waypoint: Vector3 in route:
		var elapsed: float = 0.0
		var stalled: int = 0
		var flip: bool = false
		var last: Vector3 = player.position
		while elapsed < 1.5:
			var offset: Vector3 = waypoint - player.position
			offset.y = 0.0
			if absf(offset.x) < 0.1 and absf(offset.z) < 0.1:
				break
			var along_x: bool = absf(offset.x) >= absf(offset.z)
			if flip:
				along_x = not along_x
			if (along_x and absf(offset.x) < 0.1) or (not along_x and absf(offset.z) < 0.1):
				along_x = not along_x
			await _hold(KEY_A, along_x and offset.x < 0.0)
			await _hold(KEY_D, along_x and offset.x > 0.0)
			await _hold(KEY_W, not along_x and offset.z < 0.0)
			await _hold(KEY_S, not along_x and offset.z > 0.0)
			await driver.frames(1)
			elapsed += 1.0 / 60.0
			if player.position.distance_to(last) < 0.004:
				stalled += 1
				if stalled > 8:
					flip = not flip
					stalled = 0
			else:
				stalled = 0
			last = player.position
		if elapsed >= 1.5:
			print("story_v2_final_smoke: stuck at %s heading for %s (target %s)" % [str(player.position), str(waypoint), str(target)])
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var gap: float = Vector2(player.position.x - target.x, player.position.z - target.z).length()
	if gap > radius + 0.8:
		print("story_v2_final_smoke: walk ended %.2f m from the target (start %s, target %s, route %d cells, ended at %s)" % [gap, str(start), str(target), route.size(), str(player.position)])
	return gap <= radius + 0.8


func _plan(can_stand: Callable, from: Vector3, to: Vector3, radius: float, bounds: Rect2) -> Array[Vector3]:
	var origin: Vector2i = Vector2i(roundi(from.x / GRID), roundi(from.z / GRID))
	var parents: Dictionary = {origin: origin}
	var queue: Array[Vector2i] = [origin]
	var head: int = 0
	var padded: Rect2 = bounds.grow(2.0)
	var goal: Vector2i = Vector2i(-99999, -99999)
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		var pos: Vector3 = Vector3(float(cell.x) * GRID, 0.0, float(cell.y) * GRID)
		if Vector2(pos.x - to.x, pos.z - to.z).length() <= radius:
			goal = cell
			break
		for direction: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + direction
			if parents.has(next):
				continue
			var world: Vector3 = Vector3(float(next.x) * GRID, 0.0, float(next.y) * GRID)
			if not padded.has_point(Vector2(world.x, world.z)):
				continue
			if bool(can_stand.call(world)):
				parents[next] = cell
				queue.append(next)
	var route: Array[Vector3] = []
	if goal == Vector2i(-99999, -99999):
		return route
	var cursor: Vector2i = goal
	while cursor != origin:
		route.push_front(Vector3(float(cursor.x) * GRID, 0.0, float(cursor.y) * GRID))
		cursor = parents[cursor] as Vector2i
	return route


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) != down:
		_held[key] = down
		await driver.key(key, down)


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/storyv2"))
	image.save_png(ProjectSettings.globalize_path("res://_screenshots/storyv2/%s.png" % name))


func _check(condition: bool, message: String) -> void:
	if condition:
		print("story_v2_final_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("story_v2_final_smoke: FAIL  ", message)
		push_error("story_v2_final_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("story_v2_final_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
