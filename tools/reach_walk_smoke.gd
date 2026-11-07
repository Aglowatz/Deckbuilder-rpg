class_name ReachWalkSmoke
extends Node
## Fix pass Nov 7 (item 2): from the spawn to every shop and exit, walked with held WASD keys like a player, in Crosspath and in each zone hub
## (the Gainlands, the D.N.A., the Endless Buffet, the Verdant Dump, the Capital). For each target the route is planned first over the area's
## own walkability (`WalkPlanner`): no route = a hard FAIL (an invisible wall or a blocked lane); then the hero walks the route's corners and
## must end with that target's [E] prompt. Roamers are removed (this smoke walks lanes, not fights). Windowed:
##   bash tools/run_reach_walk_smoke.sh            (REACH_AREAS=town,refusemancer to limit it)

const SHOT_DIR: String = "res://_screenshots/reach_walk/"
const TAG: String = "reach_walk_smoke"
## "forest" is the postgame forest: from Rip's station to the Lab's hatch (C5 F1, the postgame blocker).
const AREAS: Array[String] = ["town", "beefcake", "necrocrat", "gourmand", "refusemancer", "final", "forest"]
## Crosspath's shops and its four zone exits (the Capital road and the Rift station count as exits too).
const TOWN_TARGETS: Array[String] = ["vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "deck", "elder", "guard", "rift_station",
	"portal_beefcake", "portal_necrocrat", "portal_gourmand", "portal_refusemancer", "portal_final"]
## A zone hub's targets: its vendors, its exits, its Rift station and its healing spot (`ZoneSpot.kind`).
const ZONE_KINDS: Array[String] = ["vendor", "vendor_npc", "exit", "rift_station", "heal"]
## Extra anchors to walk to: the Dump's way north out of the Compost Commons (C2b F1) to the bridge landings.
const EXTRA_ANCHORS: Dictionary = {"refusemancer": ["land_center", "land_west"]}
## The planning body radius (the hero's is 0.3).
const PLAN_BODY: float = 0.55

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}
var _rows: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for zone_id: String in Gatekeepers.IDS:
		Session.set_flag(CorruptedNpcs.unlock_flag(zone_id))  # every road open: the exits are walked to, not fought for
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)  # past the gate exam: the castle approach is walked to
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	var wanted: String = OS.get_environment("REACH_AREAS")
	for area: String in AREAS:
		if wanted != "" and not wanted.split(",").has(area):
			continue
		await _area(area)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var report: FileAccess = FileAccess.open(SHOT_DIR + "report.md", FileAccess.WRITE)
	if report != null:
		report.store_string("# Reach walk smoke\n\n| Area | Target | Result | Route (m) | Walked (s) | Left (m) |\n|---|---|---|---:|---:|---:|\n" + "\n".join(_rows) + "\n")
		report.close()
	_finish(_failures.is_empty(), "%d targets, %d failed" % [_rows.size(), _failures.size()])


func _area(area: String) -> void:
	if area == "town":
		SceneManager.go_to_town()
	elif area == "forest":
		for name: StringName in [&"primm_defeated", &"rip_forest_tip", PathologyLab.FLAG_FOREST_OPEN, StoryStills.FLAG_WAKE_SEEN, &"awakened", &"rescuer_met"]:
			Session.set_flag(name)
		SceneManager.go_to_start_area()
	else:
		Session.enter_zone(area)
	var scene: Node = await _wait_for_world()
	if scene == null:
		_check(false, "%s: the scene loaded" % area)
		return
	await driver.seconds(3.5)  # the title card
	_clear_roamers(scene)
	await _dismiss(scene)
	if scene is HeapScene:
		# the stream is crossed by the vine bridges a Refusemancer grows (a Magic Bean, or Moss's herd quest): grown here, as in the heap smoke
		for growth: HeapGrowth.Growth in HeapGrowth.all():
			Session.set_flag(growth.flag)
			if growth.kind == "bridge":
				(scene as HeapScene).heap.set_bridge_progress(growth.id, 1.0)
			else:
				(scene as HeapScene).heap.set_ladder_progress(growth.id, 1.0)
	var player: TownPlayer = scene.get("player") as TownPlayer
	var spawn: Vector3 = player.position
	if scene is StartingAreaScene and (scene as StartingAreaScene).area.anchors.has("station"):
		spawn = (scene as StartingAreaScene).area.anchors["station"] as Vector3
	for target: Dictionary in _targets(scene, area):
		await _reach(scene, area, spawn, target)
	await _shot("%s_end" % area)


func _targets(scene: Node, area: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if scene is TownScene:
		for spot: TownScene.Spot in (scene as TownScene).spots:
			if spot.id in TOWN_TARGETS:
				result.append({"id": spot.id, "pos": spot.position, "radius": spot.radius * StorybookScale.INTERACT_FACTOR})
	elif scene is StartingAreaScene:
		var anchors: Dictionary = (scene as StartingAreaScene).area.anchors
		if anchors.has("lab"):
			result.append({"id": "lab", "pos": anchors["lab"] as Vector3, "radius": 1.6})
	elif scene is ZoneScene:
		for anchor_id: Variant in EXTRA_ANCHORS.get(area, []) as Array:
			result.append({"id": str(anchor_id), "pos": (scene as ZoneScene).builder.anchor(str(anchor_id)), "radius": 1.5, "anchor": true})
		for spot: ZoneSpot in (scene as ZoneScene).spots:
			if (spot.kind in ZONE_KINDS or spot.id == "last_shop") and not bool(spot.data.get("hidden", false)):
				result.append({"id": spot.id, "pos": spot.position, "radius": spot.radius * StorybookScale.INTERACT_FACTOR})
	if result.is_empty():
		_check(false, "%s: has targets" % area)
	return result


func _reach(scene: Node, area: String, spawn: Vector3, target: Dictionary) -> void:
	var player: TownPlayer = scene.get("player") as TownPlayer
	var id: String = str(target["id"])
	var goal: Vector3 = target["pos"] as Vector3
	var radius: float = float(target["radius"])
	player.position = spawn
	player.stop_walking()
	await driver.frames(4)
	# the route keeps a margin round everything (a wider body than the hero's), so held keys that drift a little still pass
	var walkable: Callable = func(at: Vector3) -> bool: return player.town.is_walkable(at, PLAN_BODY) and not _wet(player.town, at)
	var tight: Callable = func(at: Vector3) -> bool: return player.town.is_walkable(at) and not _wet(player.town, at)
	var bounds: Rect2 = player.town.map_bounds()
	# the Crease is reached by its ladder, shafts and tunnel, never on foot from the Outskirts: its targets start from its own spawn
	if scene is CapitalScene and goal.z >= CapitalBuilder.CREASE_Z:
		spawn = (scene as CapitalScene).builder.anchor("crease_spawn")
		player.position = spawn
		await driver.frames(3)
	var route: PackedVector3Array = WalkPlanner.route(walkable, bounds, spawn, goal, 0.5, maxf(0.6, radius * 0.45))
	if route.is_empty():
		route = WalkPlanner.route(tight, bounds, spawn, goal, 0.5, maxf(0.6, radius * 0.45))  # a narrow way through still counts
	if route.is_empty():
		_rows.append("| %s | %s | **NO ROUTE** | - | - | %.1f |" % [area, id, Vector2(spawn.x - goal.x, spawn.z - goal.z).length()])
		_check(false, "%s: %s - no walkable route from the spawn" % [area, id])
		return
	var started: int = Time.get_ticks_msec()
	for index: int in range(1, route.size()):
		var leg: float = Vector2(route[index].x - player.position.x, route[index].z - player.position.z).length()
		await _walk_to(scene, route[index], 0.35 if index < route.size() - 1 else 0.5, leg / 2.5 + 2.5)
		if OS.get_environment("REACH_DEBUG") != "":
			print("%s: leg %d -> %s, at %s" % [TAG, index, str(route[index]), str(player.position)])
	await driver.frames(8)
	var left: float = Vector2(player.position.x - goal.x, player.position.z - goal.z).length()
	var near: Variant = scene.get("_near")
	var near_id: String = ""
	if near is TownScene.Spot:
		near_id = (near as TownScene.Spot).id
	elif near is ZoneSpot:
		near_id = (near as ZoneSpot).id
	if scene is StartingAreaScene:
		near_id = str(scene.get("_post_near"))
	var dialogue: DialogueBox = scene.get("dialogue") as DialogueBox
	var talked: bool = dialogue != null and dialogue.active  # walking up opened its conversation (a Rift station unlocking itself)
	var ok: bool = near_id == id or (left <= radius + 0.2 and (near_id != "" or bool(target.get("anchor", false)))) or (talked and left <= radius + 6.0)
	if not ok:
		print("%s: debug %s locked=%s input=%s dialogue=%s pos=%s" % [TAG, id, str(scene.get("_locked")), str(player.input_enabled), str(talked), str(player.position)])
	if talked:
		await _dismiss(scene)
	var seconds: float = float(Time.get_ticks_msec() - started) / 1000.0
	_rows.append("| %s | %s | %s | %.0f | %.0f | %.1f |" % [area, id, "ok" if ok else "**FAIL** (prompt: %s)" % near_id, WalkPlanner.length(route), seconds, left])
	_check(ok, "%s: %s walked from the spawn (%.0f m route, %.0f s, %.1f m left, prompt %s)" % [area, id, WalkPlanner.length(route), seconds, left, near_id])
	if not ok:
		await _shot("%s_%s_fail" % [area, id])


## The Dump's water and pits are walkable (you can fall in, and land back on the bank): never part of a route.
func _wet(area: WalkableArea, at: Vector3) -> bool:
	var heap: HeapBuilder = area as HeapBuilder
	return heap != null and heap.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD and not heap.on_grown_bridge(at)


func _clear_roamers(scene: Node) -> void:
	var enemies: Variant = scene.get("enemies")
	if enemies is Array:
		for enemy: Variant in (enemies as Array).duplicate():
			if enemy is Node and is_instance_valid(enemy):
				(enemy as Node).queue_free()
		(enemies as Array).clear()


func _dismiss(scene: Node) -> void:
	var dialogue: DialogueBox = scene.get("dialogue") as DialogueBox
	var guard: int = 0
	while dialogue != null and dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)
	guard = 0
	while driver.find_button("Continue") != null and guard < 10:
		guard += 1
		await driver.tap_key(KEY_ENTER)
		await driver.seconds(0.4)


func _wait_for_world() -> Node:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene != null and (scene is TownScene or scene is ZoneScene or scene is StartingAreaScene) and not SceneManager.busy and scene.get("player") != null:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


## Walks toward `target` with WASD (diagonals as two keys) until within `radius` or `limit` seconds pass.
func _walk_to(scene: Node, target: Vector3, radius: float, limit: float) -> void:
	var player: Node3D = scene.get("player") as Node3D
	var elapsed: float = 0.0
	while elapsed < limit and get_tree().current_scene == scene:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius:
			break
		var dir: Vector3 = offset.normalized()
		await _hold(KEY_W, dir.z < -0.3)
		await _hold(KEY_S, dir.z > 0.3)
		await _hold(KEY_A, dir.x < -0.3)
		await _hold(KEY_D, dir.x > 0.3)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _shot(shot_name: String) -> void:
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture != null:
		texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
