extends Node
## Sub-area e2e (windowed, injected input; run alone): from each hub (town, forest after the trial, the four zones, the Capital) the hero stands at a gate, presses E and
## lands in the sub-area; there a chest is opened with E and pays once, the exit with E returns to the hub at the gate; a save made inside a sub-area resumes there with its flags.
##   Godot --path . res://tools/subarea_smoke.tscn        (SMOKE_ONLY=main_town,gainlands,... limits the areas)

const TMP: String = "user://subarea_smoke"
const STALL_LIMIT: float = 25.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _shots: int = 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	SaveSlots.dir = "%s/saves/" % TMP
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	get_tree().current_scene = null
	Session.new_game()
	Session.ensure_game()
	Session.set_flag(&"trial_cleared")
	var only: PackedStringArray = OS.get_environment("SMOKE_ONLY").split(",", false)
	var areas: Array[String] = ["main_town", "starting_forest", "gainlands", "dna", "buffet", "heap", "capital_outside", "capital_inside"]
	for area_id: String in areas:
		if not only.is_empty() and not only.has(area_id):
			continue
		await _area_round_trip(area_id)
	if only.is_empty() or only.has("save_load"):
		await _save_load_inside()
	_finish()


# ---- One area: hub -> gate -> sub-area -> chest -> exit -> hub ------------------------------------------------------------------


func _go_hub(area_id: String) -> Node:
	var hub_path: String = SubAreaDefs.hub_scene(area_id)
	var zone_id: String = SubAreaDefs.zone_id(area_id)
	if zone_id != "" and ZoneDefs.has_def(zone_id):
		Session.enter_zone(zone_id)
	else:
		Session.zone_run = null
		SceneManager.change_scene(hub_path)
	return await _wait_for_scene(hub_path)


func _area_round_trip(area_id: String) -> void:
	var label: String = area_id
	var hub: Node = await _go_hub(area_id)
	if hub == null:
		_check(false, "%s: the hub scene loads" % label)
		return
	_check(true, "%s: the hub scene loads (%s)" % [label, hub.name])
	await _dismiss_dialogue(hub)
	var gates_node: SubAreaGates = hub.find_child("SubAreaGates", true, false) as SubAreaGates
	if gates_node == null:
		_check(not SubAreaDefs.sub_ids(area_id).is_empty() and str(SubAreaDefs.area(area_id).get("requires_flag", "")) != "", "%s: no gates, only legal while its flag is unset" % label)
		return
	var mine: Array[int] = []
	for index: int in range(gates_node.gates.size()):
		if str(gates_node.gates[index]["area"]) == area_id:
			mine.append(index)
	_check(not mine.is_empty(), "%s: the hub shows %d gates" % [label, mine.size()])
	if mine.is_empty():
		return
	var gate: Dictionary = gates_node.gates[mine[0]]
	var gate_pos: Vector3 = SubAreaMap.pos3(gate["pos"])
	var player: Node3D = hub.get("player") as Node3D
	# Stand at the gate (the straight-line walk is not what this smoke tests: the walkability probe covers reachability) and press E.
	player.position = Vector3(gate_pos.x - 1.0, 0.0, gate_pos.z + 1.2)
	await driver.seconds(0.4)
	# standing by the gate may put the hero inside the Rift Express unlock radius (the D.N.A. gates stand near its station): read that speech first
	await _dismiss_dialogue(hub)
	await _shot("%s_gate" % area_id)
	await driver.tap_key(KEY_E)
	var scene: SubAreaScene = await _wait_for_scene(SubAreaScene.SCENE_PATH) as SubAreaScene
	_check(scene != null and scene.area_id == area_id and scene.sub_id == str(gate["sub"]), "%s: E at gate '%s' loads sub-area %s" % [label, str(gate["id"]), str(gate["sub"])])
	if scene == null:
		return
	await driver.seconds(0.5)
	await _shot("%s_%s" % [area_id, scene.sub_id])
	_check(scene.spots.size() > 4, "%s/%s: %d points of interest" % [label, scene.sub_id, scene.spots.size()])
	# A chest: stand next to it, E, it pays once and is remembered.
	var chest: Dictionary = _first_of(scene, "chest")
	if not chest.is_empty():
		var chest_id: StringName = scene.flag_name(str(chest["id"]))
		scene.player.position = (chest["pos"] as Vector3) + Vector3(0.0, 0.0, 1.4)
		await driver.seconds(0.3)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.8)
		_check(Session.flag(chest_id), "%s/%s: the chest opens with E and is remembered" % [label, scene.sub_id])
		await _close_reward_popup(scene)
	# The way back to the hub.
	var exit_spot: Dictionary = {}
	for spot: Dictionary in scene.spots:
		if str(spot["type"]) == "exit" and str((spot["data"] as Dictionary).get("to", "hub")) == "hub":
			exit_spot = spot
			break
	_check(not exit_spot.is_empty(), "%s/%s: has an exit back to the hub" % [label, scene.sub_id])
	if exit_spot.is_empty():
		return
	scene.player.position = (exit_spot["pos"] as Vector3) + Vector3(0.0, 0.0, 1.4)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_E)
	var back: Node = await _wait_for_scene(SubAreaDefs.hub_scene(area_id))
	_check(back != null, "%s: the exit leads back to the hub scene" % label)
	if back != null:
		await driver.seconds(0.5)
		var back_player: Node3D = back.get("player") as Node3D
		var distance: float = Vector2(back_player.position.x - gate_pos.x, back_player.position.z - gate_pos.z).length()
		_check(distance < 12.0, "%s: back in the hub the hero stands near the gate (%.1f m)" % [label, distance])


# ---- Save and load inside a sub-area ---------------------------------------------------------------------------------------------


func _save_load_inside() -> void:
	SubAreaScene.enter("gainlands", "proving_grounds", "")
	var scene: SubAreaScene = await _wait_for_scene(SubAreaScene.SCENE_PATH) as SubAreaScene
	if scene == null:
		_check(false, "save/load: the sub-area loads")
		return
	await driver.seconds(0.5)
	var flag: StringName = scene.flag_name("smoke_marker")
	Session.set_flag(flag)
	var gold: int = Session.gold
	_check(Session.scene_kind() == SubAreaDefs.token("gainlands", "proving_grounds"), "save/load: the session names the sub-area as the scene (%s)" % Session.scene_kind())
	_check(Session.save_to_slot(2, "subarea smoke"), "save/load: manual save to slot 2 inside the sub-area")
	# Leave: the Wanderer wakes up in town, the marker flag cleared and the gold changed behind the save's back.
	Session.gold = gold + 555
	Session.set_flag(flag, false)
	Session.zone_run = null
	SceneManager.go_to_town()
	await _wait_for_scene(Areas.TOWN_SCENE)
	_check(Session.load_from_slot(2), "save/load: load slot 2")
	_check(Session.gold == gold, "save/load: the saved gold is back (%d)" % Session.gold)
	_check(Session.flag(flag), "save/load: the sub-area flag survived")
	Session.resume_loaded_game()
	var again: SubAreaScene = await _wait_for_scene(SubAreaScene.SCENE_PATH) as SubAreaScene
	_check(again != null and again.area_id == "gainlands" and again.sub_id == "proving_grounds", "save/load: loading resumes inside the same sub-area")
	if again != null:
		await driver.seconds(0.5)
		_check(Session.zone_run != null and Session.zone_run.zone_id == "beefcake", "save/load: the zone visit is back (the hub gate still works)")


# ---- Helpers -----------------------------------------------------------------------------------------------------------------------


## The chest's reward box: press its (only) button until the overlay is gone.
func _close_reward_popup(scene: SubAreaScene) -> void:
	var guard: int = 0
	while guard < 20 and is_instance_valid(scene) and (scene._overlay != null or scene._locked):
		guard += 1
		if scene._overlay != null:
			var buttons: Array[Node] = scene._overlay.find_children("*", "BaseButton", true, false)
			for node: Node in buttons:
				var button: BaseButton = node as BaseButton
				if button.is_visible_in_tree() and not button.disabled:
					await driver.click(driver.center_of_control(button))
					break
		await driver.seconds(0.4)
	_check(is_instance_valid(scene) and not scene._locked, "the reward box closes and the hero is free again")


func _first_of(scene: SubAreaScene, type: String) -> Dictionary:
	for spot: Dictionary in scene.spots:
		if str(spot["type"]) == type:
			return spot
	return {}


func _wait_for_scene(path: String) -> Node:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene != null and scene.scene_file_path == path and not SceneManager.busy:
			await driver.frames(10)
			return scene
		await driver.frames(4)
		elapsed += 4.0 / 60.0
	return null


func _dismiss_dialogue(scene: Node) -> void:
	var guard: int = 0
	while guard < 40:
		var dialogue: Object = scene.get("dialogue") as Object
		var busy: bool = (dialogue != null and bool(dialogue.get("active"))) or bool(scene.get("_locked"))
		if not busy:
			return
		guard += 1
		if dialogue != null and bool(dialogue.get("active")):
			await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


func _shot(shot_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/subarea_smoke"))
	image.save_png(ProjectSettings.globalize_path("res://_screenshots/subarea_smoke/%s.png" % shot_name))
	_shots += 1


func _check(ok: bool, what: String) -> void:
	if ok:
		print("subarea_smoke: ok    %s" % what)
	else:
		_failures.append(what)
		print("subarea_smoke: FAIL  %s" % what)
		push_error("subarea_smoke: %s" % what)


func _finish() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(TMP)
	if DirAccess.dir_exists_absolute(abs_dir):
		OS.move_to_trash(abs_dir)
	if _failures.is_empty():
		print("subarea_smoke: PASSED (%d screenshots)" % _shots)
		get_tree().quit(0)
	else:
		print("subarea_smoke: FAILED - %d checks" % _failures.size())
		get_tree().quit(1)
