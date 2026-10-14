class_name SubAreaScene
extends Node3D
## One sub-area of a zone (Art Bible G-07): a connected scene that loads on its own (the hub scene is freed), built from `data/subareas/<area>/<sub>.json` by `SubAreaMap`.
## State lives in the session, not here: chests opened, lore read and shrines used are flags (`sa_<area>_<sub>_<poi>`), the zone visit (HP, defeated enemies) is the same
## `Session.zone_run`, quests and NPC flags are untouched. A save made here records "sub:<area>/<sub>" (`Session.scene_kind`).
##
## Points of interest (data `poi`, each {id, type, pos [x, z], title, prompt, lines, tier ...}):
##   chest    gold / item / card from the zone's own chest tables (`SubAreaRewards`), once
##   lore     a notice board whose lines open in the dialogue box, always repeatable; the first reading is marked
##   shrine   a rare card shrine: one card of the zone's own chest tables, once
##   vista    a viewpoint: a line of text, repeatable
##   vignette a figure with a line or two (a placeholder character model)
##   shortcut a lever that removes the barrier landmark named by `opens`, for good
## Exits (data `exits`, each {id, to, pos, label, requires?}): `to` is "hub", "<sub id>" or "area:<area>/<sub>".

const SCENE_PATH: String = "res://scenes/sub_area.tscn"
const CULL_DISTANCE: float = 60.0
const PROMPT_RADIUS: float = 2.4

## Set by `enter` and read once by `_ready`.
static var pending_area: String = ""
static var pending_sub: String = ""
static var pending_from: String = ""

var area_id: String = ""
var sub_id: String = ""
var data: Dictionary = {}
var zone_data: Dictionary = {}
var map: SubAreaMap
var player: TownPlayer
var hud: TownHud
var dialogue: DialogueBox
var camera_offset: Vector3 = WorldLookRig.base_offset()
var style_rig: StyleRig
var look_rig: WorldLookRig
var spots: Array[Dictionary] = []

var _camera: Camera3D
var _overlay_layer: Control
var _overlay: Control
var _locked: bool = false
var _near: int = -1
var _time: float = 0.0
var _barriers: Dictionary = {}
var _spinners: Array[Dictionary] = []
var _screenshot_args: Dictionary = {}


## Goes to a sub-area scene. `from_id` names where the hero came from (a hub gate id or the previous sub-area id) so the entry point can be picked.
static func enter(area: String, sub: String, from_id: String = "") -> void:
	pending_area = area
	pending_sub = sub
	pending_from = from_id
	SceneManager.change_scene(SCENE_PATH)


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args
	if args.has("area"):
		pending_area = str(args["area"])
	if args.has("sub"):
		pending_sub = str(args["sub"])


func screenshot_ready() -> bool:
	return true


func _ready() -> void:
	SceneManager.pause_allowed = true
	area_id = pending_area
	sub_id = pending_sub
	var from_id: String = pending_from
	pending_from = ""
	zone_data = SubAreaDefs.area(area_id)
	data = SubAreaDefs.sub(area_id, sub_id)
	if data.is_empty():
		push_error("SubAreaScene: no data for %s/%s" % [area_id, sub_id])
		SceneManager.go_to_town()
		return
	Session.ensure_game()
	var zone_id: String = SubAreaDefs.zone_id(area_id)
	if zone_id != "" and Session.zone_run == null:
		Session.begin_zone_visit(zone_id)
	var preset: StringName = StringName(str(zone_data.get("preset", "town")))
	ZoneStyles.use_preset(preset)
	_play_music(zone_id)
	_ensure_input_actions()
	map = SubAreaMap.new(data)
	map.build(self)
	_build_features()
	_build_player(from_id)
	_build_camera(preset)
	_build_ui()
	_apply_saved_state()
	hud.set_location(str(data.get("name", sub_id)), str(zone_data.get("name", "")))
	_show_banner(str(data.get("name", sub_id)))
	if _screenshot_args.has("at"):
		_teleport(str(_screenshot_args["at"]))
	if str(_screenshot_args.get("nohud", "false")) == "true":
		for child: Node in get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	Session.save_game()


func _play_music(zone_id: String) -> void:
	if zone_id != "":
		Audio.play_music(MusicDirector.zone_area(zone_id, Session.flags))
	elif area_id == "starting_forest":
		Audio.play_music(MusicDirector.forest())
	else:
		Audio.play_music(MusicDirector.town(Session.flags))


func _ensure_input_actions() -> void:
	if not InputMap.has_action(&"interact"):
		InputMap.add_action(&"interact")
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event(&"interact", key)


# ---- Features: chests, lore boards, shrines, vistas, vignettes, levers, exits ---------------------------------------------------------


func flag_name(poi_id: String) -> StringName:
	return StringName("sa_%s_%s_%s" % [area_id, sub_id, poi_id])


func _build_features() -> void:
	for item: Variant in data.get("poi", []) as Array:
		var poi: Dictionary = item as Dictionary
		var pos: Vector3 = SubAreaMap.pos3(poi["pos"])
		var type: String = str(poi.get("type", "vista"))
		var node: Node3D = null
		match type:
			"chest":
				node = ModelKit.dungeon_prop("chest_gold")
				if node != null:
					node.scale = Vector3.ONE * 0.3
					node.rotation_degrees.y = float(poi.get("yaw", 0.0))
			"lore":
				node = PropKit.make("notice_board")
			"shrine":
				node = LandmarkKit.build({"kind": "shrine", "size": [1.8, 2.6, 1.8], "color": str(poi.get("color", "#b8b0a0")), "glow": str(poi.get("glow", "#ffd890"))})
			"vista":
				node = null
			"vignette":
				node = ModelKit.character(str(poi.get("model", "Mage")))
				if node != null:
					ModelKit.tint(node, Color.html(str(poi.get("tint", "#d8c8a8"))))
					node.scale = Vector3.ONE * TownPlayer.MODEL_SCALE
					node.rotation_degrees.y = float(poi.get("yaw", 180.0))
			"shortcut":
				node = PropKit.make("signpost")
		if node != null:
			add_child(node)
			node.position = pos
			map.add_blocker(pos, 0.5 if type != "vignette" else 0.35)
		var spot: Dictionary = {"id": str(poi.get("id", "%s_%d" % [type, spots.size()])), "type": type, "pos": pos, "radius": float(poi.get("radius", PROMPT_RADIUS)),
			"title": str(poi.get("title", type.capitalize())), "prompt": str(poi.get("prompt", _default_prompt(type))), "data": poi, "node": node}
		_add_marker(spot)
		spots.append(spot)
	for item: Variant in data.get("exits", []) as Array:
		var exit_data: Dictionary = item as Dictionary
		var pos: Vector3 = SubAreaMap.pos3(exit_data["pos"])
		var spot: Dictionary = {"id": str(exit_data.get("id", "exit")), "type": "exit", "pos": pos, "radius": float(exit_data.get("radius", 2.6)),
			"title": str(exit_data.get("label", "Leave")), "prompt": "Go to %s" % str(exit_data.get("label", "the next area")), "data": exit_data, "node": null}
		_add_exit_visual(pos, exit_data)
		_add_marker(spot)
		spots.append(spot)
	# Hero landmarks that turn (the Mill Fields wheel): meta "spinner" names the child, "spin_speed" the radians per second about its local z.
	for landmark_node: Node in map.root.get_children():
		if landmark_node.has_meta("spinner"):
			_spinners.append({"node": landmark_node.get_meta("spinner"), "speed": float(landmark_node.get_meta("spin_speed", 0.3))})
	# Barriers a lever can remove: landmark entries with "barrier": "<id>" (built by the map as landmarks; found here by name).
	for landmark_node: Node in map.root.get_children():
		if landmark_node.has_meta("barrier"):
			var barrier_id: String = str(landmark_node.get_meta("barrier"))
			if not _barriers.has(barrier_id):
				_barriers[barrier_id] = []
			(_barriers[barrier_id] as Array).append(landmark_node)


func _default_prompt(type: String) -> String:
	match type:
		"chest":
			return "Open the chest"
		"lore":
			return "Read the notes"
		"shrine":
			return "Touch the shrine"
		"vista":
			return "Take in the view"
		"vignette":
			return "Talk"
		"shortcut":
			return "Pull the lever"
	return "Use"


func _add_marker(spot: Dictionary) -> void:
	var pos: Vector3 = spot["pos"] as Vector3
	var marker: MeshInstance3D = MeshInstance3D.new()
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(0.2, 0.3, 0.2)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = UIStyle.GOLD
	material.emission_enabled = true
	material.emission = UIStyle.GOLD
	material.emission_energy_multiplier = 1.6
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	prism.material = material
	marker.mesh = prism
	marker.rotation_degrees.x = 180.0
	marker.position = pos + Vector3(0.0, 2.1 if str(spot["type"]) != "vista" else 1.6, 0.0)
	marker.set_meta(&"no_occlusion_fade", true)
	add_child(marker)
	spot["marker"] = marker
	var plate: Label3D = Label3D.new()
	plate.text = str(spot["title"])
	plate.font = UIStyle.font_title()
	plate.font_size = 46
	plate.pixel_size = 0.0045
	plate.outline_size = 14
	plate.outline_modulate = Color(0.04, 0.07, 0.07, 0.95)
	plate.modulate = UIStyle.PARCHMENT
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.no_depth_test = true
	plate.position = marker.position + Vector3(0, 0.34, 0)
	add_child(plate)
	spot["plate"] = plate


func _add_exit_visual(pos: Vector3, exit_data: Dictionary) -> void:
	StyleBeacon.build(self, pos, Color(0.8, 0.9, 1.0), 4.0, 0.08)
	var arch: Node3D = LandmarkKit.build({"kind": "arch", "size": [4.2, 3.4, 0.7], "color": str(exit_data.get("color", "#a89a80")), "accent": "#6a5a48", "no_fade": true})
	add_child(arch)
	arch.position = pos + Vector3(0.0, 0.0, -0.6)
	arch.rotation_degrees.y = float(exit_data.get("yaw", 0.0))
	if absf(float(exit_data.get("yaw", 0.0))) > 45.0:
		map.no_walk.append(Rect2(pos.x - 0.95, pos.z - 2.1, 0.7, 4.2))
	else:
		map.no_walk.append(Rect2(pos.x - 2.1, pos.z - 0.95, 4.2, 0.7))


func _apply_saved_state() -> void:
	for spot: Dictionary in spots:
		var type: String = str(spot["type"])
		var poi_id: String = str(spot["id"])
		if type == "chest" and Session.flag(flag_name(poi_id)):
			ChestKit.set_open(spot["node"] as Node3D, true)
		if type == "shortcut" and Session.flag(flag_name(poi_id)):
			_open_barrier(str((spot["data"] as Dictionary).get("opens", "")))
		if type == "shrine" and Session.flag(flag_name(poi_id)):
			var plate: Label3D = spot["plate"] as Label3D
			plate.modulate = Color(0.7, 0.7, 0.7, 0.6)


func _open_barrier(barrier_id: String) -> void:
	for item: Variant in _barriers.get(barrier_id, []) as Array:
		var node: Node3D = item as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var circles: Array = node.get_meta("circles", []) as Array
		var basis: Basis = Basis(Vector3.UP, node.rotation.y)
		for circle: Variant in circles:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = node.position + basis * Vector3(local.x, 0.0, local.y)
			for index: int in range(map.obstacles.size() - 1, -1, -1):
				var obstacle: Vector3 = map.obstacles[index]
				if absf(obstacle.x - world.x) < 0.01 and absf(obstacle.y - world.z) < 0.01:
					map.obstacles.remove_at(index)
		node.queue_free()
	_barriers.erase(barrier_id)


# ---- Player and camera ---------------------------------------------------------------------------------------------------------------


func _build_player(from_id: String) -> void:
	var spawn: Vector3 = map.spawn()
	var entries: Dictionary = data.get("entries", {}) as Dictionary
	if from_id != "" and entries.has(from_id):
		spawn = SubAreaMap.pos3(entries[from_id])
	player = TownPlayer.new()
	add_child(player)
	player.setup(map, "Hero", spawn)


func _build_camera(preset: StringName) -> void:
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.current = true
	_camera.position = player.position + CameraRig.shape(camera_offset)
	_camera.look_at(player.position + Vector3(0, 0.4, 0), Vector3.UP)
	style_rig = StyleRig.install(self, preset, _camera, player, CULL_DISTANCE)
	if style_rig != null:
		look_rig = WorldLookRig.install(self, _camera, player, style_rig, map)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var host: Control = UIKit.layer_host(layer)
	host.add_child(UIKit.vignette(0.7))
	hud = TownHud.new()
	host.add_child(hud)
	hud.character_pressed.connect(_open_character_screen)
	hud.deck_pressed.connect(_open_deck_builder)
	hud.quests_pressed.connect(_open_quest_log)
	hud.wardrobe_pressed.connect(_open_wardrobe)
	hud.packs_pressed.connect(_open_packs)
	hud.set_gold(Session.gold)
	dialogue = DialogueBox.new()
	host.add_child(dialogue)
	dialogue.stand_behind(hud)
	var overlay_canvas: CanvasLayer = CanvasLayer.new()
	overlay_canvas.layer = 8
	add_child(overlay_canvas)
	_overlay_layer = UIKit.layer_host(overlay_canvas)
	EventBus.quest_notice.connect(_on_quest_notice)


func _show_banner(text: String) -> void:
	if not _screenshot_args.is_empty() and not _screenshot_args.has("card"):
		return
	hud.toast(text, UIStyle.GOLD)


func _teleport(token: String) -> void:
	for spot: Dictionary in spots:
		if str(spot["id"]) == token:
			player.position = (spot["pos"] as Vector3) + Vector3(0.0, 0.0, 2.2)
			_camera.position = player.position + CameraRig.shape(camera_offset)
			return
	if token.contains(","):
		var parts: PackedStringArray = token.split(",")
		player.position = Vector3(float(parts[0]), 0.0, float(parts[1]))
		_camera.position = player.position + CameraRig.shape(camera_offset)


# ---- Per frame -----------------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	_time += delta
	for spinner: Dictionary in _spinners:
		var node: Node3D = spinner["node"] as Node3D
		if node != null and is_instance_valid(node):
			node.rotation.z += float(spinner["speed"]) * delta
	if player == null:
		return
	var target: Vector3 = player.position + CameraRig.shape(camera_offset)
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-5.0 * delta))
	player.input_enabled = not _locked and not dialogue.active
	for spot: Dictionary in spots:
		var pos: Vector3 = spot["pos"] as Vector3
		var marker: MeshInstance3D = spot["marker"] as MeshInstance3D
		marker.position.y = pos.y + 2.1 + sin(_time * 2.4 + pos.x) * 0.08
		marker.rotation_degrees.y += 60.0 * delta
		var distance: float = Vector2(player.position.x - pos.x, player.position.z - pos.z).length()
		var plate: Label3D = spot["plate"] as Label3D
		var alpha: float = clampf(1.0 - (distance - 2.6) / 1.6, 0.0, 1.0)
		plate.modulate.a = alpha
		plate.outline_modulate.a = alpha
	_update_nearest()


func _update_nearest() -> void:
	if _locked or dialogue.active:
		hud.hide_prompt()
		_near = -1
		return
	var best: int = -1
	var best_distance: float = 1e9
	for index: int in range(spots.size()):
		var spot: Dictionary = spots[index]
		var pos: Vector3 = spot["pos"] as Vector3
		var distance: float = Vector2(player.position.x - pos.x, player.position.z - pos.z).length()
		if distance <= float(spot["radius"]) * StorybookScale.INTERACT_FACTOR and distance < best_distance:
			best = index
			best_distance = distance
	if best != _near:
		_near = best
		if best >= 0:
			hud.show_prompt("[E]  %s" % str(spots[best]["prompt"]))
		else:
			hud.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and not _locked and not dialogue.active:
		if event.is_action_pressed(&"open_character"):
			get_viewport().set_input_as_handled()
			_open_character_screen()
			return
		if event.is_action_pressed(&"open_deck"):
			get_viewport().set_input_as_handled()
			_open_deck_builder()
			return
		if event.is_action_pressed(&"open_packs"):
			get_viewport().set_input_as_handled()
			_open_packs()
			return
		if event.is_action_pressed(&"open_wardrobe"):
			get_viewport().set_input_as_handled()
			_open_wardrobe()
			return
		if event.is_action_pressed(&"open_quests"):
			get_viewport().set_input_as_handled()
			_open_quest_log()
			return
	if _locked or dialogue.active:
		return
	if event.is_action_pressed(&"interact") and _near >= 0:
		get_viewport().set_input_as_handled()
		interact(spots[_near])


## Public so tests and the e2e smoke can drive it.
func interact(spot: Dictionary) -> void:
	Audio.sfx(&"ui_select")
	var poi: Dictionary = spot["data"] as Dictionary
	var poi_id: String = str(spot["id"])
	match str(spot["type"]):
		"exit":
			_use_exit(poi)
		"chest":
			_open_chest(spot)
		"lore":
			_say("Notes", _lines(poi, ["Nothing legible. Somebody was here, once."]))
			if not Session.flag(flag_name(poi_id)):
				Session.set_flag(flag_name(poi_id))
				Session.bump_counter("lore_pages_read")
		"shrine":
			_use_shrine(spot)
		"vista":
			_say("", _lines(poi, ["A fine view."]))
		"vignette":
			player.face(spot["pos"] as Vector3)
			_say(str(poi.get("title", "Stranger")), _lines(poi, ["..."]))
		"shortcut":
			if Session.flag(flag_name(poi_id)):
				hud.toast("The way is already open.", UIStyle.PARCHMENT)
			else:
				Session.set_flag(flag_name(poi_id))
				Audio.sfx(&"door")
				_open_barrier(str(poi.get("opens", "")))
				hud.toast("Something heavy moves out of the way.", UIStyle.GOLD)
				Session.save_game()


func _lines(poi: Dictionary, fallback: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for line: Variant in poi.get("lines", fallback) as Array:
		result.append(str(line))
	if result.is_empty():
		return fallback
	return result


func _say(speaker: String, lines: Array[String], then: Callable = Callable()) -> void:
	dialogue.start(speaker, lines, "")
	if then.is_valid():
		dialogue.finished.connect(then, CONNECT_ONE_SHOT)


# ---- Chests and shrines (existing reward tables) ------------------------------------------------------------------------------------------


func _open_chest(spot: Dictionary) -> void:
	var poi: Dictionary = spot["data"] as Dictionary
	var poi_id: String = str(spot["id"])
	player.face(spot["pos"] as Vector3)
	if Session.flag(flag_name(poi_id)):
		hud.toast("Empty.", UIStyle.PARCHMENT)
		return
	Session.set_flag(flag_name(poi_id))
	var reward: Dictionary = SubAreaRewards.reward(SubAreaDefs.zone_id(area_id), str(poi.get("tier", "small")), "%s/%s/%s" % [area_id, sub_id, poi_id])
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Hidden chest")
	hud.set_gold(Session.gold)
	Session.save_game()
	_locked = true
	player.input_enabled = false
	Audio.sfx(&"chest_open")
	ChestKit.open_animated(spot["node"] as Node3D)
	await get_tree().create_timer(0.7).timeout
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)


func _use_shrine(spot: Dictionary) -> void:
	var poi: Dictionary = spot["data"] as Dictionary
	var poi_id: String = str(spot["id"])
	player.face(spot["pos"] as Vector3)
	if Session.flag(flag_name(poi_id)):
		_say("Shrine", ["The light has gone out of it. It is warm, still."] as Array[String])
		return
	Session.set_flag(flag_name(poi_id))
	var reward: Dictionary = SubAreaRewards.reward(SubAreaDefs.zone_id(area_id), "card", "%s/%s/%s" % [area_id, sub_id, poi_id])
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Shrine offering")
	Session.save_game()
	Audio.sting(&"STG-SECRET")
	_locked = true
	var popup: RewardPopup = RewardPopup.make(summary)
	_open_overlay(popup)
	popup.finished.connect(_close_overlay)
	var plate: Label3D = spot["plate"] as Label3D
	plate.modulate = Color(0.7, 0.7, 0.7, 0.6)


# ---- Exits --------------------------------------------------------------------------------------------------------------------------------


func _use_exit(exit_data: Dictionary) -> void:
	var required: String = str(exit_data.get("requires", ""))
	if required != "" and not Session.flag(StringName(required)):
		hud.toast(str(exit_data.get("locked_text", "Not yet.")), UIStyle.PARCHMENT)
		return
	var target: String = str(exit_data.get("to", "hub"))
	if target.begins_with("dungeon:"):
		_use_dungeon_exit(target.trim_prefix("dungeon:"), exit_data)
		return
	_locked = true
	player.input_enabled = false
	Audio.sfx(&"door")
	if target == "hub":
		_go_hub(str(exit_data.get("gate", "")))
	elif target.begins_with("area:"):
		var parts: PackedStringArray = target.trim_prefix("area:").split("/", false)
		if parts.size() == 2:
			SubAreaScene.enter(parts[0], parts[1], "%s/%s" % [area_id, sub_id])
	else:
		SubAreaScene.enter(area_id, target, sub_id)


## "dungeon:lab" (the Path-ology Lab) and "dungeon:main" (the zone's main dungeon: Primm's Castle in the Capital): the same flow as the hub's own entrances.
func _use_dungeon_exit(kind: String, exit_data: Dictionary) -> void:
	if not Session.any_deck_valid():
		var problems: Array[DeckValidator.Issue] = Session.deck_issues()
		var message: String = problems[0].message if not problems.is_empty() else "Your deck is not legal."
		_say("", ["My deck is not ready for this. %s" % message] as Array[String])
		return
	_locked = true
	var title: String = "The Path-ology Lab" if kind == "lab" else str(exit_data.get("label", "The dungeon"))
	var body: String = str(exit_data.get("body", "Go down?"))
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, title, body, "Enter", "Not yet")
	dialog.confirmed.connect(func() -> void:
		DeckPicker.guard(_overlay_layer, func() -> void:
			Audio.sfx(&"door")
			if kind == "lab":
				Session.enter_lab()
			else:
				if Session.zone_run != null:
					Session.zone_run.return_position = player.position
					Session.zone_run.has_return_position = false
				Session.enter_main_dungeon(), func() -> void: _locked = false))
	dialog.cancelled.connect(func() -> void: _locked = false)


## Back to the area's hub scene, standing at the gate the hero came through.
func _go_hub(gate_id: String) -> void:
	var gate: Dictionary = {}
	for candidate: Dictionary in SubAreaDefs.gates(area_id):
		if str(candidate.get("sub", "")) == sub_id and (gate_id == "" or str(candidate.get("id", "")) == gate_id):
			gate = candidate
			break
	var return_pos: Vector3 = Vector3.ZERO
	if not gate.is_empty():
		return_pos = SubAreaMap.pos3(gate.get("return", gate.get("pos", [0.0, 0.0])))
	var scene_path: String = SubAreaDefs.hub_scene(area_id)
	var zone_id: String = SubAreaDefs.zone_id(area_id)
	if zone_id != "" and Session.zone_run != null:
		Session.zone_run.return_position = return_pos
		Session.zone_run.has_return_position = not gate.is_empty()
		SceneManager.change_scene(scene_path)
	elif scene_path == Areas.TOWN_SCENE:
		Session.town_return_position = return_pos
		Session.has_town_return_position = not gate.is_empty()
		SceneManager.go_to_town()
	elif scene_path == Areas.START_SCENE:
		Session.start_return_position = return_pos
		Session.has_start_return_position = not gate.is_empty()
		SceneManager.go_to_start_area()
	else:
		SceneManager.change_scene(scene_path if scene_path != "" else Areas.TOWN_SCENE)


# ---- Overlays ------------------------------------------------------------------------------------------------------------------------


func _open_overlay(screen: Control) -> void:
	_close_overlay(false)
	_locked = true
	_overlay = screen
	_overlay_layer.add_child(screen)
	Audio.sfx(&"ui_open")


func _close_overlay(save: bool = true) -> void:
	if _overlay != null:
		_overlay.queue_free()
		_overlay = null
	_locked = false
	hud.set_gold(Session.gold)
	if save:
		Session.save_game()
		Audio.sfx(&"ui_close", -4.0)


func _open_character_screen() -> void:
	if _locked or dialogue.active:
		return
	var screen: CharacterScreen = CharacterScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_deck_builder() -> void:
	if _locked or dialogue.active:
		return
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_quest_log() -> void:
	if _locked or dialogue.active:
		return
	var screen: QuestLogScreen = QuestLogScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_wardrobe() -> void:
	if _locked or dialogue.active:
		return
	var screen: WardrobeScreen = WardrobeScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _open_packs() -> void:
	if _locked or dialogue.active or not Session.has_profile():
		return
	var screen: PacksScreen = PacksScreen.new()
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _on_quest_notice(text: String, is_new: bool) -> void:
	if is_new:
		hud.queue_toast(text, UIStyle.GOLD)
