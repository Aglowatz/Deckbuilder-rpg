class_name WorldLookTest
extends TownScene
## World Look Test (docs/art/world_look_test.md): a polished slice of the real main town in the chosen style - painted 2.5D character sprites, a low cinematic camera with
## tilt-shift and bloom, painted textures, a real sky, distant scenery rings and landmarks, painted water, foliage and ambient life. It IS the real town
## (`TownScene`, painted textures and all); nothing in the real game scenes changes and the save is never written.
##   F1 - F4 : the old character-test cameras   F5 : Recommended   F6 : My Preset (saved from the panel)
##   Tab     : live tuning panel      [ and ] : turn the camera view 30 degrees (to look towards each landmark)      mouse wheel : zoom
##   WASD / arrows walk, E talks to the nearest character.
## Launch: Godot --path . res://tests/world/world_look_test.tscn   (see tools/world_shots.sh for the automated screenshot and fps runs)

const SHOT_DIR: String = "res://docs/art/world_look/"
const SHOT_SIZE: Vector2i = Vector2i(1280, 720)
## Standing spots used by the screenshot set.
const SPOT_SQUARE: Vector3 = Vector3(26.8, 0.0, 15.2)
## NPC id (TownScene._npcs) -> sprite character.
const NPC_SPRITES: Dictionary = {"elder": "ELDER", "guard": "GATEKEEPER", "vendor": "SABLE", "item_vendor": "TONIC", "pack_vendor": "FENWICK"}
## An NPC turns to face the hero when closer than this (metres).
const NPC_NOTICE_RANGE: float = 4.2

var _args: Dictionary = {}
var _shot_mode: bool = false
var _params: Dictionary = {}
var _current: Dictionary = {}
var _preset_index: int = 5
var _yaw_steps: int = 0
var _yaw: float = 0.0
var _player_sprite: WorldSprite
var _npc_sprites: Dictionary = {}
var _talking_id: String = ""
var _villager: VillagerWalker
var _sun_direction: Vector3 = Vector3(0.42, -0.62, -0.67)
var _env: Environment
var _post_material: ShaderMaterial
var _post_rect: ColorRect
var _panel: TuningPanel
var _caption: Label
var _sky: WorldSky
var _scenery: WorldScenery
var _foliage: WorldFoliage
var _ambient: WorldAmbient
var _hold_dir: StringName = &""


func screenshot_prepare(args: Dictionary) -> void:
	_args = args
	super.screenshot_prepare(args)


func _ready() -> void:
	# Never touch the real save (the town saves at the end of _ready).
	Session.save_enabled = false
	Settings.camera_zoom = Settings.ZOOM_DEFAULT
	if _args.is_empty():
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--"):
				var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
				_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
		if _args.is_empty():
			_args = {"fresh": "true"}
	_args["nocull"] = "true"
	_screenshot_args = _args
	_shot_mode = _args.has("run")
	super._ready()
	player.model.visible = false
	_find_sun()
	_build_sprites()
	_build_world()
	_build_post_and_ui()
	player.position = _spot_from_args()
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	_yaw_steps = int(_args.get("yaw", 0)) / 30
	_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	player.move_yaw = _yaw
	apply_preset(int(_args.get("preset", 5)), true)
	if _shot_mode:
		_hide_hud()
		match str(_args["run"]):
			"shots":
				_run_shots.call_deferred()
			"one":
				_run_one.call_deferred()
			"perf":
				_run_perf.call_deferred()
			"probe":
				_run_probe.call_deferred()
			"probe2":
				_run_probe2.call_deferred()
			"walk":
				_run_walk.call_deferred()


func _spot_from_args() -> Vector3:
	if _args.has("pos"):
		var parts: PackedStringArray = str(_args["pos"]).split(",")
		return Vector3(float(parts[0]), 0.0, float(parts[1]))
	return SPOT_SQUARE


func _find_sun() -> void:
	if style_rig != null and style_rig.sun != null:
		_sun_direction = -style_rig.sun.global_basis.z
	if style_rig != null and style_rig.world_env != null:
		_env = style_rig.world_env.environment


# ---- Characters --------------------------------------------------------------------------------------------------------------------


func _build_sprites() -> void:
	_player_sprite = WorldSprite.new()
	add_child(_player_sprite)
	_player_sprite.setup("PLAYER", _camera, _sun_direction)
	_player_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))
	for id: String in NPC_SPRITES.keys():
		var npc: Node3D = _npcs.get(id) as Node3D
		if npc == null:
			continue
		npc.visible = false
		var sprite: WorldSprite = WorldSprite.new()
		add_child(sprite)
		sprite.setup(str(NPC_SPRITES[id]), _camera, _sun_direction)
		sprite.position = npc.position
		var heading: Vector3 = Vector3(sin(npc.rotation.y), 0.0, cos(npc.rotation.y))
		sprite.snap_heading(heading)
		sprite.set_meta("home_heading", heading)
		_npc_sprites[id] = sprite
	_villager = VillagerWalker.new()
	add_child(_villager)
	_villager.setup(town, square.center, _camera, _sun_direction)


func _face_npc(id: String) -> void:
	_talking_id = id
	super._face_npc(id)


func _update_sprites(delta: float) -> void:
	_player_sprite.follow(player.position, delta)
	# A direct press on a movement key turns the body at once (the 8-direction frame follows the camera-relative heading).
	for id: String in _npc_sprites.keys():
		var sprite: WorldSprite = _npc_sprites[id] as WorldSprite
		var npc: Node3D = _npcs[id] as Node3D
		var to_player: Vector3 = player.position - npc.position
		to_player.y = 0.0
		if id == _talking_id and dialogue.active:
			sprite.talking = true
			sprite.look_toward(to_player)
		else:
			sprite.talking = false
			if to_player.length() < NPC_NOTICE_RANGE:
				sprite.look_toward(to_player)
			else:
				sprite.look_toward(sprite.get_meta("home_heading") as Vector3)
		sprite.turn_rate_degrees = 260.0
		sprite.follow(npc.position, delta)
	if not dialogue.active:
		_talking_id = ""


# ---- World pieces ------------------------------------------------------------------------------------------------------------------


func _build_world() -> void:
	_sky = WorldSky.new()
	add_child(_sky)
	_sky.setup(_camera, _env, _sun_direction)
	_scenery = WorldScenery.new()
	add_child(_scenery)
	_scenery.setup(self, town, _camera)
	_foliage = WorldFoliage.new()
	add_child(_foliage)
	_foliage.setup(town, square, _camera, _sun_direction)
	if style_rig != null and style_rig.preset != null:
		_foliage.set_light(style_rig.preset.sun_color, style_rig.preset.ambient_color)
	_ambient = WorldAmbient.new()
	add_child(_ambient)
	_ambient.setup(self, town, _camera, player, _sun_direction)


func _build_post_and_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = -5
	add_child(layer)
	_post_rect = ColorRect.new()
	_post_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_material = ShaderMaterial.new()
	_post_material.shader = load("res://tests/world/world_post.gdshader") as Shader
	_post_rect.material = _post_material
	layer.add_child(_post_rect)
	var info_layer: CanvasLayer = CanvasLayer.new()
	info_layer.layer = 9
	add_child(info_layer)
	_caption = Label.new()
	_caption.position = Vector2(14, 8)
	_caption.add_theme_font_size_override("font_size", 13)
	_caption.add_theme_color_override("font_color", Color(1, 1, 0.9))
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_caption.add_theme_constant_override("outline_size", 5)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.visible = not _shot_mode
	info_layer.add_child(_caption)
	_panel = TuningPanel.new()
	_panel.position = Vector2(1160, 40)
	_panel.visible = false
	_panel.changed.connect(_on_panel_changed)
	_panel.save_pressed.connect(_save_my_preset)
	_panel.reset_pressed.connect(func() -> void: apply_preset(5))
	info_layer.add_child(_panel)
	_place_panel.call_deferred()


func _place_panel() -> void:
	var viewport: Vector2 = get_viewport().get_visible_rect().size
	_panel.position = Vector2(viewport.x - _panel.size.x - 12.0, 36.0)


func _hide_hud() -> void:
	hud.visible = false
	minimap.visible = false


# ---- Presets and live values -------------------------------------------------------------------------------------------------------


## Switches to preset `index` (1-4 old cameras, 5 Recommended, 6 My Preset); `snap` jumps instead of blending.
func apply_preset(index: int, snap: bool = false) -> void:
	var values: Dictionary
	if index >= 1 and index <= 4:
		values = LookParams.old_preset(index - 1)
	elif index == 6:
		values = LookParams.load_my_preset()
		if values.is_empty():
			_panel.set_status("No saved My Preset yet: press Save as My Preset in the panel (Tab).")
			return
	else:
		values = LookParams.recommended()
	_preset_index = index
	_params = values
	_panel.bind(_params)
	if snap or _current.is_empty():
		_current = _params.duplicate()
	_apply_current()


func _on_panel_changed() -> void:
	_params["name"] = "Custom (from %s)" % str(_params.get("name", "")).trim_prefix("Custom (from ").trim_suffix(")")


func _save_my_preset() -> void:
	var error: Error = LookParams.save_my_preset(_params)
	_panel.set_status("Saved to %s (F6 loads it)." % LookParams.MY_PRESET_PATH if error == OK else "Could not save: %s" % error_string(error))
	print("world_look: saved my preset: " + LookParams.describe(_params))


func _blend_current(delta: float) -> void:
	var k: float = 1.0 - exp(-6.0 * delta)
	for key: Variant in _params.keys():
		var target: Variant = _params[key]
		if target is float or target is int:
			_current[key] = lerpf(float(_current.get(key, target)), float(target), k)
		elif key == "fog_color":
			_current[key] = Color.html(str(_current.get(key, target))).lerp(Color.html(str(target)), k).to_html(false)
		else:
			_current[key] = target


func _apply_current() -> void:
	var p: Dictionary = _current
	var pitch_rad: float = deg_to_rad(float(p["pitch"]))
	var dist: float = float(p["distance"])
	var yawed: Vector3 = Vector3(0.0, sin(pitch_rad), cos(pitch_rad)) * dist
	camera_offset = yawed.rotated(Vector3.UP, _yaw)
	_camera.fov = float(p["fov"])
	if _post_material != null:
		_post_material.set_shader_parameter("focus_y", float(p["focus"]))
		_post_material.set_shader_parameter("band", float(p["band"]))
		_post_material.set_shader_parameter("blur_far", float(p["blur_far"]))
		_post_material.set_shader_parameter("blur_near", float(p["blur_near"]))
		_post_material.set_shader_parameter("warmth", float(p["warmth"]))
		_post_material.set_shader_parameter("saturation", float(p["saturation"]))
		_post_material.set_shader_parameter("vignette", float(p["vignette"]))
	if _env != null:
		var bloom: float = float(p["bloom"])
		_env.glow_enabled = bloom > 0.01
		_env.glow_intensity = bloom
		_env.glow_strength = 1.0
		_env.glow_bloom = 0.0
		_env.glow_hdr_threshold = float(p["bloom_threshold"])
		_env.glow_hdr_scale = 1.6
		_env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
		var spread: float = float(p["glow_spread"])
		for level: int in range(0, 7):
			var centre: float = spread * 5.0 + 0.5
			_env.set_glow_level(level, clampf(1.0 - absf(float(level) - centre) * 0.32, 0.0, 1.0))
		_env.fog_enabled = true
		_env.fog_density = float(p["fog_density"])
		_env.fog_light_color = Color.html(str(p["fog_color"]))
		_env.fog_sky_affect = 0.0
	if _sky != null:
		_sky.set_cloud_speed(float(p["cloud_speed"]))
		_sky.set_haze_color(Color.html(str(p["fog_color"])))
	if _scenery != null:
		_scenery.set_haze_color(Color.html(str(p["fog_color"])))


func _update_caption() -> void:
	if _caption == null:
		return
	var p: Dictionary = _params
	_caption.text = "%s    pitch %.1f  dist %.1f x zoom %.1f  fov %.0f  height %.1f   focus %.2f band %.2f blur %.1f/%.1f   bloom %.2f thr %.2f spread %.2f   fog %.4f   warm %.2f sat %.2f vig %.2f   clouds %.1f    [F1-F6 presets, Tab panel, [ ] turn view]" % [
		str(p.get("name", "")), float(p["pitch"]), float(p["distance"]), Settings.camera_zoom, float(p["fov"]), float(p["height"]), float(p["focus"]), float(p["band"]),
		float(p["blur_far"]), float(p["blur_near"]), float(p["bloom"]), float(p["bloom_threshold"]), float(p["glow_spread"]), float(p["fog_density"]), float(p["warmth"]),
		float(p["saturation"]), float(p["vignette"]), float(p["cloud_speed"])]


# ---- Frame -------------------------------------------------------------------------------------------------------------------------


func _process(delta: float) -> void:
	_yaw = lerp_angle(_yaw, deg_to_rad(float(_yaw_steps) * 30.0), 1.0 - exp(-7.0 * delta))
	player.move_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	_blend_current(delta)
	_apply_current()
	super._process(delta)
	var pitch_tilt: float = atan2(float(_current["height"]), float(_current["distance"]))
	var basis: Basis = Basis.looking_at(-camera_offset, Vector3.UP)
	_camera.basis = basis.rotated(basis.x, pitch_tilt)
	_update_sprites(delta)
	if _villager != null:
		_villager.tick(delta, player.position)
	if _sky != null:
		_sky.tick(delta)
	if _ambient != null:
		_ambient.tick(delta)
	if _hold_dir != &"":
		Input.action_press(_hold_dir)
	_update_caption()


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var handled: bool = true
	match key.keycode:
		KEY_TAB:
			_panel.visible = not _panel.visible
		KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6:
			if not _locked and not dialogue.active:
				apply_preset(key.keycode - KEY_F1 + 1)
		KEY_BRACKETLEFT:
			_yaw_steps -= 1
		KEY_BRACKETRIGHT:
			_yaw_steps += 1
		_:
			handled = false
	if handled:
		get_viewport().set_input_as_handled()


# ---- Automation --------------------------------------------------------------------------------------------------------------------


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _settle_at(spot: Vector3, yaw_degrees: int = 0) -> void:
	player.position = spot
	_yaw_steps = yaw_degrees / 30
	_yaw = deg_to_rad(float(_yaw_steps) * 30.0)
	player.move_yaw = _yaw
	_apply_current()
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	_player_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))


func _save_shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.resize(SHOT_SIZE.x, SHOT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var path: String = ProjectSettings.globalize_path(SHOT_DIR + shot_name + ".jpg")
	var error: Error = image.save_jpg(path, 0.9)
	print("world_look: saved %s (%s)" % [shot_name, error_string(error)])


func _run_one() -> void:
	await _wait(1.0)
	if _args.has("birds"):
		_ambient.spawn_flock(5, true)
	await _wait(float(_args.get("wait", 2.5)))
	await _save_shot(str(_args.get("name", "one")))
	get_tree().quit(0)


func _run_shots() -> void:
	get_tree().quit(0)


func _run_perf() -> void:
	get_tree().quit(0)


func _run_walk() -> void:
	get_tree().quit(0)


func _run_probe() -> void:
	await _wait(1.0)
	print("world_look: map bounds %s" % str(town.map_bounds()))
	var shared: ShaderMaterial = StyleWater.material()
	var count: int = 0
	var lowest: float = 1e9
	var highest: float = -1e9
	for node: Node in town.root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.material_override == shared:
			count += 1
			var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
			lowest = minf(lowest, box.position.y)
			highest = maxf(highest, box.end.y)
			if count == 1:
				print("world_look: first water tile aabb %s" % str(box))
	print("world_look: water tiles %d, y %.3f .. %.3f" % [count, lowest, highest])
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		var cell: Vector2i = TownBuilder.PORTAL_CELLS[zone_id] as Vector2i
		var mouth: Vector3 = town.cell_center(cell.x, cell.y)
		var plan: Dictionary = TownConnectors.plan(mouth, TownBuilder.PORTAL_OUT[zone_id] as Vector3)
		print("world_look: portal %s mouth %s island %s" % [zone_id, str(mouth), str(plan["center"])])
	print("world_look: plaza %s camera far %.0f" % [str(TownLayout.PLAZA), _camera.far])
	get_tree().quit(0)


func _run_probe2() -> void:
	await _wait(1.0)
	for zone_id: String in ["final", "beefcake"]:
		var root: Node3D = town.root.get_node_or_null("Connector_%s" % zone_id) as Node3D
		if root == null:
			print("world_look: no connector %s" % zone_id)
			continue
		var kinds: Dictionary = {}
		for child: Node in root.get_children():
			var node: Node3D = child as Node3D
			var label: String = "%s|%s" % [child.name.rstrip("0123456789@"), child.get_class()]
			kinds[label] = int(kinds.get(label, 0)) + 1
		print("world_look: connector %s children: %s" % [zone_id, str(kinds)])
	get_tree().quit(0)
