class_name DungeonRouteAudit
extends Node
## Fable pass Nov 10 (Part 1.2): is the way from a zone's arrival point to its main dungeon ever a guessing game? For each Path zone and the
## Capital the route is planned over the zone's own walkability (`WalkPlanner`, as the reach walk smoke does) twice: FRESH (a hero who just
## beat the gatekeeper: nothing grown, no golem gate open, no Capital gate) and OPEN (every gate of the zone granted). A zone whose fresh
## route fails names the gates that stand on the open route (a golem gate, a vine bridge, a barricade, the city gate), so the report says
## exactly what a player must do first - and the quest step that sends them there must mark it. Windowed (the zone scenes build with their
## look); it plans, it does not walk:  bash tools/run_dungeon_route_audit.sh        Report: _screenshots/dungeon_route/report.md

const OUT_DIR: String = "res://_screenshots/dungeon_route/"
const TAG: String = "dungeon_route_audit"
const ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]
const PLAN_BODY: float = 0.55
## A gate counts as "on the route" within this many metres of one of its points.
const NEAR_ROUTE: float = 3.0

var driver: UiDriver
var _rows: PackedStringArray = []
var _failures: PackedStringArray = []


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	await driver.frames(5)
	var wanted: String = OS.get_environment("ROUTE_ZONES")
	for zone_id: String in ZONES:
		if wanted != "" and not wanted.split(",").has(zone_id):
			continue
		await _zone(zone_id, false)
		await _zone(zone_id, true)
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var report: FileAccess = FileAccess.open(OUT_DIR + "report.md", FileAccess.WRITE)
	if report != null:
		report.store_string("# Dungeon route audit\n\nPlanned routes from the arrival point to the main dungeon's door, over the zone's walkability (body %.2f m).\n\n| Zone | State | Route | Length (m) | Gates on the open route (within %.0f m) |\n|---|---|---|---:|---|\n" % [PLAN_BODY, NEAR_ROUTE] + "\n".join(_rows) + "\n")
		report.close()
	_finish(_failures.is_empty(), "%d plans, %d failed" % [_rows.size(), _failures.size()])


## A fresh hero in `zone_id`: the gatekeeper beaten (the road open), nothing else. `open`: every gate granted too.
func _zone(zone_id: String, open: bool) -> void:
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.flags[QuestDefinitions.LEGACY_FLAG] = true
	for id: String in Gatekeepers.IDS:
		Session.set_flag(CorruptedNpcs.unlock_flag(id))
	if open:
		_grant_gates(zone_id)
	Session.enter_zone(zone_id)
	var scene: ZoneScene = await _wait_for_world() as ZoneScene
	if scene == null:
		_check(false, "%s: the scene loaded" % zone_id)
		return
	await driver.seconds(3.0)
	await _dismiss(scene)
	if open and scene is HeapScene:
		for growth: HeapGrowth.Growth in HeapGrowth.all():
			if growth.kind == "bridge":
				(scene as HeapScene).heap.set_bridge_progress(growth.id, 1.0)
			else:
				(scene as HeapScene).heap.set_ladder_progress(growth.id, 1.0)
		await driver.frames(3)
	var player: TownPlayer = scene.player
	var spawn: Vector3 = player.position
	var door: ZoneSpot = null
	for spot: ZoneSpot in scene.spots:
		if spot.kind == "main_dungeon":
			door = spot
			break
	if door == null:
		_check(false, "%s: has a main dungeon door" % zone_id)
		return
	var walkable: Callable = func(at: Vector3) -> bool: return player.town.is_walkable(at, PLAN_BODY) and not _wet(player.town, at)
	var tight: Callable = func(at: Vector3) -> bool: return player.town.is_walkable(at) and not _wet(player.town, at)
	var bounds: Rect2 = player.town.map_bounds()
	var reach: float = maxf(0.6, door.radius * StorybookScale.INTERACT_FACTOR * 0.45)
	var route: PackedVector3Array = WalkPlanner.route(walkable, bounds, spawn, door.position, 0.5, reach)
	var narrow: bool = false
	if route.is_empty():
		route = WalkPlanner.route(tight, bounds, spawn, door.position, 0.5, reach)
		narrow = not route.is_empty()
	var state: String = "open" if open else "fresh"
	if route.is_empty() and OS.get_environment("ROUTE_DEBUG") != "":
		# the waypoints of the expected way (env ROUTE_DEBUG="x,z;x,z;..."): which leg breaks, and whether each point is walkable at all
		var points: Array[Vector3] = [spawn]
		for pair: String in OS.get_environment("ROUTE_DEBUG").split(";"):
			var xz: PackedStringArray = pair.split(",")
			if xz.size() == 2:
				points.append(Vector3(float(xz[0]), 0.0, float(xz[1])))
		points.append(door.position)
		for index: int in range(points.size()):
			var at: Vector3 = points[index]
			at.y = player.town.height_at(at) if player.town.has_method("height_at") else 0.0
			var why: String = ""
			if player.town is HeapBuilder:
				var heap: HeapBuilder = player.town as HeapBuilder
				why = " surface=%s edge=%.2f obstacle=%s barricade=%s" % [HeapLayout.Surface.keys()[heap.layout.surface_at(at.x, at.z)], HeapLayout.edge_distance(at.x, at.z), str(heap._hits_obstacle(at, 0.3)), str(heap._hits_barricade(at, 0.3))]
			print("%s: debug point %d %s walkable(body)=%s walkable(tight)=%s%s" % [TAG, index, str(at.snapped(Vector3(0.1, 0.1, 0.1))), str(bool(walkable.call(at))), str(bool(tight.call(at))), why])
			if index > 0:
				var leg: PackedVector3Array = WalkPlanner.route(tight, bounds, points[index - 1], at, 0.5, 1.0)
				print("%s: debug leg %d -> %d: %s" % [TAG, index - 1, index, "%.0f m" % WalkPlanner.length(leg) if not leg.is_empty() else "NO ROUTE"])
	if OS.get_environment("ROUTE_GRID") != "":
		# a character map of the walkability over a rectangle (env ROUTE_GRID="x0,x1,z0,z1", 0.25 m cells): '.' walkable, '#' not, 'c' cliff, 'b' barricade
		var box: PackedStringArray = OS.get_environment("ROUTE_GRID").split(",")
		if box.size() == 4:
			var z: float = float(box[2])
			while z <= float(box[3]):
				var line: String = "%6.2f " % z
				var x: float = float(box[0])
				while x <= float(box[1]):
					var at: Vector3 = Vector3(x, 0.0, z)
					var mark: String = "." if bool(tight.call(at)) else "#"
					if player.town is HeapBuilder and mark == "#":
						var heap: HeapBuilder = player.town as HeapBuilder
						if heap.layout.surface_at(x, z) == HeapLayout.Surface.CLIFF:
							mark = "c"
						elif heap._hits_barricade(at, 0.3):
							mark = "b"
					line += mark
					x += 0.25
				print("%s: grid %s" % [TAG, line])
				z += 0.25
	if OS.get_environment("ROUTE_WALK") != "":
		# a real walk with held keys (env ROUTE_WALK="x,z>x,z"): teleports the hero to the first point and walks toward the second for 6 s
		var ends: PackedStringArray = OS.get_environment("ROUTE_WALK").split(">")
		if ends.size() == 2:
			var a: PackedStringArray = ends[0].split(",")
			var b: PackedStringArray = ends[1].split(",")
			var from: Vector3 = Vector3(float(a[0]), 0.0, float(a[1]))
			from.y = player.town.height_at(from)
			player.position = from
			player.stop_walking()
			await driver.frames(4)
			await _walk_to(scene, Vector3(float(b[0]), 0.0, float(b[1])), 0.5, 6.0)
			print("%s: walk from %s toward %s ended at %s" % [TAG, str(from.snapped(Vector3(0.1, 0.1, 0.1))), ends[1], str(player.position.snapped(Vector3(0.1, 0.1, 0.1)))])
	var gates: PackedStringArray = _gates_on_route(scene, route)
	if route.is_empty():
		_rows.append("| %s | %s | **NO ROUTE** | - | %s |" % [zone_id, state, "-"])
		# a fresh hero with no route is expected where a gate stands in the way; the OPEN run must always find one
		_check(not open, "%s (%s): a walkable route from the arrival point to %s" % [zone_id, state, door.title])
		print("%s: %s (%s): no route from %s to %s" % [TAG, zone_id, state, str(spawn.snapped(Vector3(0.1, 0.1, 0.1))), str(door.position.snapped(Vector3(0.1, 0.1, 0.1)))])
	else:
		_rows.append("| %s | %s | %s | %.0f | %s |" % [zone_id, state, "ok (narrow)" if narrow else "ok", WalkPlanner.length(route), ", ".join(gates) if not gates.is_empty() else "none"])
		_check(true, "%s (%s): %.0f m route to %s%s; gates on it: %s" % [zone_id, state, WalkPlanner.length(route), door.title, " (narrow)" if narrow else "", ", ".join(gates) if not gates.is_empty() else "none"])
	await driver.frames(2)


## Grants every gate of `zone_id` the way the game does: the Buffet's three golem gates, the Dump's growths and barricades, the Capital's gate.
func _grant_gates(zone_id: String) -> void:
	match zone_id:
		"gourmand":
			for gate: BuffetGates.Gate in BuffetGates.gates():
				Session.set_flag(gate.flag)
		"refusemancer":
			for growth: HeapGrowth.Growth in HeapGrowth.all():
				Session.set_flag(growth.flag)
			for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
				Session.set_flag(barricade.flag)
		"final":
			Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
			Session.set_flag(CapitalZone.FLAG_INSIDE)


## The gate-like things within NEAR_ROUTE of the route: golem gates, growth spots, barricades, the Capital's gate guards, road guards.
func _gates_on_route(scene: ZoneScene, route: PackedVector3Array) -> PackedStringArray:
	var found: PackedStringArray = []
	if route.is_empty():
		return found
	var candidates: Array[Dictionary] = []
	for spot: ZoneSpot in scene.spots:
		if spot.id.begins_with("gate_") or spot.id.begins_with("grow_") or spot.id.begins_with("guard_") or spot.data.has("gate"):
			candidates.append({"name": spot.title if spot.title != "" else spot.id, "pos": spot.position})
	if scene is HeapScene:
		for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
			if scene.builder.has_anchor(barricade.anchor):
				candidates.append({"name": barricade.title, "pos": scene.builder.anchor(barricade.anchor)})
		for growth: HeapGrowth.Growth in HeapGrowth.all():
			if scene.builder.has_anchor(growth.anchor):
				candidates.append({"name": growth.title, "pos": scene.builder.anchor(growth.anchor)})
	for enemy: ZoneEnemy in scene.enemies:
		if is_instance_valid(enemy) and enemy.guard_radius > 0.0:
			candidates.append({"name": "road guard: %s" % enemy.info.display_name, "pos": enemy.position})
	for candidate: Dictionary in candidates:
		var pos: Vector3 = candidate["pos"] as Vector3
		var best: float = INF
		for index: int in range(route.size() - 1):
			var a: Vector2 = Vector2(route[index].x, route[index].z)
			var b: Vector2 = Vector2(route[index + 1].x, route[index + 1].z)
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(pos.x, pos.z), a, b)
			best = minf(best, closest.distance_to(Vector2(pos.x, pos.z)))
		if best <= NEAR_ROUTE:
			found.append(str(candidate["name"]))
	return found


## The Dump's water and pits are walkable (you can fall in, and land back on the bank): never part of a route.
func _wet(area: WalkableArea, at: Vector3) -> bool:
	var heap: HeapBuilder = area as HeapBuilder
	return heap != null and heap.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD and not heap.on_grown_bridge(at)


var _held_keys: Dictionary = {}


## Walks toward `target` with WASD (diagonals as two keys) until within `radius` or `limit` seconds pass (as the reach walk smoke does).
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
		if scene != null and scene is ZoneScene and not SceneManager.busy and scene.get("player") != null:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
