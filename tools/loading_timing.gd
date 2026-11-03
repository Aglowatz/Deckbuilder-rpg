class_name LoadingTiming
extends Node
## Nov 2 pass, Part 3: measures every scene transition the way a player meets it - the real SceneManager (fade, loading screen, build,
## settle), windowed so shader pipelines and texture uploads count. Cold = the first time an area is built this session, warm = the second.
## For each transition: LoadTiming's load (change_scene to fade-in), the wall time from the call to `revealed`, the slowest build step, the
## step list, and the process working set after it. Zone round: town -> zone (cold), a roamer battle (zone -> battle, battle -> zone), the
## zone's side dungeon (zone -> map, map -> zone on retreat), zone -> town; then the same round warm. Writes _screenshots/loading_timing/
## <run>.json and <run>.md.   bash tools/run_loading_timing.sh [run_name] [zones=beefcake,gourmand,...]

const OUT_DIR: String = "res://_screenshots/loading_timing/"
const ZONES: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer", "final"]
const SIDE_DUNGEON: Dictionary = {"beefcake": "S-IRON", "gourmand": "S-GOUR", "necrocrat": "S-NECRO", "refusemancer": "S-REF", "final": "S-CAP"}

var run_name: String = "run"
var zones: Array[String] = ZONES.duplicate()
var rows: Array[Dictionary] = []
var _revealed: bool = false
var _peak_ram: float = 0.0
## Overnight Nov 2-3, Part 3: `--fights=1` measures only the fight returns that are not roamer fights: the arena and the graveyard (from the
## town) and a dungeon node (zone side dungeon: battle -> rewards -> map on a win, battle -> map on a loss), cold and warm.
var fights_only: bool = false


func run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--run="):
			run_name = arg.substr(6)
		elif arg.begins_with("--zones="):
			zones.assign(arg.substr(8).split(",", false))
		elif arg.begins_with("--fights="):
			fights_only = arg.substr(9) != "0"
	SceneManager.revealed.connect(func() -> void: _revealed = true)
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.set_flag(&"trial_cleared")
	DevActions.set_level(12, true)
	await _frames(5)
	await _go("title -> town (cold)", func() -> void: SceneManager.go_to_town())
	if fights_only:
		await _fight_returns()
		_write()
		get_tree().quit(0)
		return
	await _go("town -> forest (cold)", func() -> void: DevActions.travel_forest())
	await _go("forest -> town (warm)", func() -> void: DevActions.travel_town())
	await _town_battle("town")
	for pass_name: String in ["cold", "warm"]:
		for zone: String in zones:
			await _go("town -> %s (%s)" % [zone, pass_name], func() -> void: DevActions.travel_zone(zone))
			await _zone_battle(zone, pass_name)
			if SIDE_DUNGEON.has(zone) and pass_name == "cold":
				await _go("%s -> dungeon map %s" % [zone, str(SIDE_DUNGEON[zone])], func() -> void: DevActions.travel_dungeon(str(SIDE_DUNGEON[zone])))
				await _frames(10)
				await _go("dungeon map -> %s (retreat)" % zone, func() -> void: Session.abandon_run("retreat"))
			await _go("%s -> town (%s)" % [zone, pass_name], func() -> void: DevActions.travel_town())
	_write()
	get_tree().quit(0)


## The arena, the graveyard and a dungeon node fight, twice each (cold, warm).
func _fight_returns() -> void:
	for pass_name: String in ["cold", "warm"]:
		var arena: ArenaEncounter = ArenaDefs.all()[0]
		await _go("town -> arena battle (%s)" % pass_name, func() -> void: Session.start_arena_battle(arena.id))
		await _win_and_continue()
		await _go("arena battle -> town (%s)" % pass_name, func() -> void: pass)
		await _close_town_overlays()
		await _go("town -> graveyard battle (%s)" % pass_name, func() -> void: Session.challenge_graveyard_boss())
		await _win_and_continue()
		await _go("graveyard battle -> town (%s)" % pass_name, func() -> void: pass)
		await _close_town_overlays()
	await _go("town -> dungeon map S-IRON", func() -> void: DevActions.travel_dungeon("S-IRON"))
	for pass_name: String in ["first", "second"]:
		var node: DungeonMap.MapNode = null
		for candidate: DungeonMap.MapNode in Session.dungeon_map.available():
			if candidate.kind == DungeonMap.Kind.BATTLE:
				node = candidate
				break
		if node == null:
			print("loading_timing: no battle node on the map")
			return
		await _go("dungeon map -> battle (%s)" % pass_name, func() -> void: Session.start_battle(Session.make_dungeon_battle(node)))
		await _win_and_continue()
		await _go("battle -> rewards (%s)" % pass_name, func() -> void: pass)
		await _frames(20)
		await _go("rewards -> dungeon map (%s)" % pass_name, func() -> void: SceneManager.change_scene("res://scenes/dungeon_map.tscn"))


## Closes what a town result left open (the arena list, a dialogue) so the next fight starts from the plain town.
func _close_town_overlays() -> void:
	await _frames(20)
	var town: Node = get_tree().current_scene
	if town != null and town.has_method(&"_close_overlay"):
		town.call(&"_close_overlay")
	for box: Node in town.find_children("*", "DialogueBox", true, false) if town != null else []:
		(box as DialogueBox).visible = false
	if town != null and "_locked" in town:
		town.set("_locked", false)
	await _frames(10)


func _frames(n: int) -> void:
	for i: int in range(n):
		await get_tree().process_frame


## Runs `action` (a scene change) and waits for the new scene to be revealed; records the timing row.
func _go(label: String, action: Callable) -> void:
	await _frames(3)
	_revealed = false
	var started: int = Time.get_ticks_usec()
	action.call()
	var waited: float = 0.0
	while not _revealed and waited < 120.0:
		await get_tree().process_frame
		waited = float(Time.get_ticks_usec() - started) / 1000000.0
	var wall_ms: float = float(Time.get_ticks_usec() - started) / 1000.0
	await _frames(2)
	var load: Dictionary = SceneManager.last_load
	var steps: Array[String] = LoadTiming.steps()
	var slowest: Array = LoadTiming.slowest()
	var ram: float = _working_set_mb()
	_peak_ram = maxf(_peak_ram, ram)
	var row: Dictionary = {
		"label": label, "scene": str(load.get("scene", "")), "load_ms": float(load.get("load_ms", -1.0)), "wall_ms": wall_ms,
		"slowest": "%s %.0f" % [str(slowest[0]), float(slowest[1])], "steps": steps, "ram_mb": ram,
		"static_mb": float(OS.get_static_memory_usage()) / 1048576.0, "revealed": _revealed,
	}
	rows.append(row)
	print("loading_timing: %-44s load %6.0f ms  wall %6.0f ms  ram %5.0f MB  slowest: %s" % [label, row["load_ms"], wall_ms, ram, row["slowest"]])


## A roamer fight in the current zone scene: zone -> battle, win by decree, battle -> zone.
func _zone_battle(zone: String, pass_name: String) -> void:
	var scene: Node = get_tree().current_scene
	var list: Variant = scene.get("enemies")
	if not (list is Array) or (list as Array).is_empty():
		print("loading_timing: %s has no roamers to fight" % zone)
		return
	var pick: ZoneEnemy = null
	for enemy: Variant in list as Array:
		var zone_enemy: ZoneEnemy = enemy as ZoneEnemy
		if zone_enemy != null and zone_enemy.info != null and zone_enemy.info.kind != ZoneEnemyInfo.Kind.DAMAGE and not zone_enemy.peaceful:
			pick = zone_enemy
			break
	if pick == null:
		print("loading_timing: %s has no fighting roamer" % zone)
		return
	var player: Node3D = scene.get("player") as Node3D
	if Session.zone_run != null and player != null:
		Session.zone_run.return_position = player.position
		Session.zone_run.has_return_position = true
	await _go("%s -> battle (%s)" % [zone, pass_name], func() -> void: Session.start_zone_battle(pick.info.id, pick.instance_id))
	await _win_and_continue()
	await _go("battle -> %s (%s)" % [zone, pass_name], func() -> void: pass)


func _town_battle(pass_name: String) -> void:
	var scene: Node = get_tree().current_scene
	var list: Variant = scene.get("enemies")
	if not (list is Array) or (list as Array).is_empty():
		print("loading_timing: the town has no roamers to fight")
		return
	var pick: ZoneEnemy = null
	for enemy: Variant in list as Array:
		var zone_enemy: ZoneEnemy = enemy as ZoneEnemy
		if zone_enemy != null and zone_enemy.info != null and zone_enemy.info.kind != ZoneEnemyInfo.Kind.DAMAGE:
			pick = zone_enemy
			break
	if pick == null:
		return
	await _go("town -> battle (%s)" % pass_name, func() -> void: Session.start_town_battle(pick.info.id, pick.instance_id))
	await _win_and_continue()
	await _go("battle -> town (%s)" % pass_name, func() -> void: pass)


## Ends the current battle as a win and presses on; the return transition is started by the battle screen itself, so the caller's
## `_go` only waits for the reveal.
func _win_and_continue() -> void:
	var battle: BattleScreen = get_tree().current_scene as BattleScreen
	if battle == null:
		print("loading_timing: not in a battle")
		return
	await _frames(30)
	DevActions.end_battle(battle, true)
	var waited: int = 0
	while waited < 600 and not (battle.mode == BattleScreen.Mode.OVER and battle.get("_result_panel") != null):
		await get_tree().process_frame
		waited += 1
	await _frames(10)
	_revealed = false
	battle.call_deferred(&"_continue")


func _working_set_mb() -> float:
	var output: Array = []
	OS.execute("tasklist", ["/FI", "PID eq %d" % OS.get_process_id(), "/FO", "CSV", "/NH"], output)
	if output.is_empty():
		return -1.0
	var fields: PackedStringArray = str(output[0]).strip_edges().split("\",\"")
	if fields.size() < 5:
		return -1.0
	var kb: String = fields[4].replace("\"", "").replace(" K", "").replace(",", "").replace(".", "").strip_edges()
	return float(kb) / 1024.0


func _write() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var json: FileAccess = FileAccess.open(OUT_DIR + run_name + ".json", FileAccess.WRITE)
	json.store_string(JSON.stringify({"run": run_name, "peak_ram_mb": _peak_ram, "rows": rows}, "\t"))
	json.close()
	var lines: PackedStringArray = []
	lines.append("| Transition | Load (ms) | Wall (ms) | Slowest step | RAM after (MB) |")
	lines.append("|---|---|---|---|---|")
	for row: Dictionary in rows:
		lines.append("| %s | %.0f | %.0f | %s | %.0f |" % [str(row["label"]), float(row["load_ms"]), float(row["wall_ms"]), str(row["slowest"]), float(row["ram_mb"])])
	lines.append("")
	lines.append("Peak working set: %.0f MB" % _peak_ram)
	lines.append("")
	for row: Dictionary in rows:
		lines.append("- **%s**: %s" % [str(row["label"]), ", ".join(row["steps"] as Array[String])])
	var md: FileAccess = FileAccess.open(OUT_DIR + run_name + ".md", FileAccess.WRITE)
	md.store_string("\n".join(lines) + "\n")
	md.close()
	print("loading_timing: wrote %s%s.md (peak RAM %.0f MB)" % [OUT_DIR, run_name, _peak_ram])
