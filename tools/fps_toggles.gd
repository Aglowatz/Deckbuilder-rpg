extends SceneTree
## Frame-time experiments (run NOT headless): Godot --path . -s res://tools/fps_toggles.gd -- --scene=res://scenes/town.tscn [--quality=1]
## Switches whole categories of the scene off one at a time (all lights, shadows, particles, labels, far meshes...) and prints the fps for each.
## Needs no scene changes; use it to see which lever is worth pulling before touching the scene.

var _args: Dictionary = {}
var _scene: Node
var _timer: float = 0.0
var _frames: PackedFloat32Array = []
var _stage: int = -2
var _toggles: Array[Dictionary] = []
var _undo: Array[Callable] = []
const WARM: float = 4.0
const SPAN: float = 3.0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(1600, 900)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


func _all(node: Node, out: Array[Node]) -> void:
	out.append(node)
	for child: Node in node.get_children():
		_all(child, out)


func _nodes_of(kind: String) -> Array[Node]:
	var all: Array[Node] = []
	_all(_scene, all)
	var result: Array[Node] = []
	for node: Node in all:
		if node.is_class(kind):
			result.append(node)
	return result


## Hides every node of `kind`; the undo shows them again.
func _hide_kind(kind: String) -> void:
	for node: Node in _nodes_of(kind):
		if node.get("visible") == true:
			node.set("visible", false)
			_undo.append(func() -> void: node.set("visible", true))


func _no_shadows() -> void:
	for node: Node in _nodes_of("GeometryInstance3D"):
		var geo: GeometryInstance3D = node as GeometryInstance3D
		if geo.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			var before: int = geo.cast_shadow
			geo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_undo.append(func() -> void: geo.cast_shadow = before as GeometryInstance3D.ShadowCastingSetting)


func _far_cull(distance: float) -> void:
	for node: Node in _nodes_of("GeometryInstance3D"):
		var geo: GeometryInstance3D = node as GeometryInstance3D
		var before: float = geo.visibility_range_end
		geo.visibility_range_end = distance
		_undo.append(func() -> void: geo.visibility_range_end = before)


func _no_light_shadows() -> void:
	for node: Node in _nodes_of("Light3D"):
		var light: Light3D = node as Light3D
		if light.shadow_enabled:
			light.shadow_enabled = false
			_undo.append(func() -> void: light.shadow_enabled = true)


func _env_toggle(glow_off: bool, fog_off: bool) -> void:
	for node: Node in _nodes_of("WorldEnvironment"):
		var env: Environment = (node as WorldEnvironment).environment
		if env == null:
			continue
		var glow: bool = env.glow_enabled
		var fog: bool = env.fog_enabled
		if glow_off:
			env.glow_enabled = false
		if fog_off:
			env.fog_enabled = false
		_undo.append(func() -> void:
			env.glow_enabled = glow
			env.fog_enabled = fog)


func _no_env_effects() -> void:
	var envs: Array[Node] = _nodes_of("WorldEnvironment")
	for node: Node in envs:
		var env: Environment = (node as WorldEnvironment).environment
		if env == null:
			continue
		var glow: bool = env.glow_enabled
		var fog: bool = env.fog_enabled
		env.glow_enabled = false
		env.fog_enabled = false
		_undo.append(func() -> void:
			env.glow_enabled = glow
			env.fog_enabled = fog)


func _glow_levels(levels: Array[int]) -> void:
	for node: Node in _nodes_of("WorldEnvironment"):
		var env: Environment = (node as WorldEnvironment).environment
		if env == null or not env.glow_enabled:
			continue
		var before: Array[float] = []
		for index: int in range(7):
			before.append(env.get_glow_level(index))
			env.set_glow_level(index, 1.0 if levels.has(index) else 0.0)
		_undo.append(func() -> void:
			for index: int in range(7):
				env.set_glow_level(index, before[index]))


func _small_no_shadow(limit: float) -> void:
	var count: int = 0
	for node: Node in _nodes_of("MeshInstance3D"):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null or mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			continue
		var size: Vector3 = mesh.mesh.get_aabb().size * mesh.global_transform.basis.get_scale()
		if maxf(size.x, maxf(size.y, size.z)) < limit:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			count += 1
			_undo.append(func() -> void: mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	print("fps_toggles: %d meshes under %.1f m stop casting" % [count, limit])


func _scale(value: float) -> void:
	var before: float = root.scaling_3d_scale
	root.scaling_3d_scale = value
	_undo.append(func() -> void: root.scaling_3d_scale = before)


func _shadow_filter(quality: RenderingServer.ShadowQuality) -> void:
	RenderingServer.directional_soft_shadow_filter_set_quality(quality)
	_undo.append(func() -> void: RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW))


func _shadow_blur(value: float) -> void:
	for node: Node in _nodes_of("DirectionalLight3D"):
		var light: DirectionalLight3D = node as DirectionalLight3D
		var before: float = light.shadow_blur
		light.shadow_blur = value
		_undo.append(func() -> void: light.shadow_blur = before)


func _glow_env_report() -> void:
	for node: Node in _nodes_of("WorldEnvironment"):
		var env: Environment = (node as WorldEnvironment).environment
		print("fps_toggles: env %s glow=%s intensity=%.2f levels=%s" % [node.get_path(), str(env.glow_enabled) if env != null else "null", env.glow_intensity if env != null else 0.0, str([env.get_glow_level(0), env.get_glow_level(1), env.get_glow_level(2), env.get_glow_level(3), env.get_glow_level(4), env.get_glow_level(5), env.get_glow_level(6)]) if env != null else ""])


func _look(token: String) -> void:
	for node: Node in _nodes_of("Node"):
		var script: Script = node.get_script() as Script
		if script != null and script.get_global_name() == &"WorldLookRig":
			node.call("set_feature", token, false)
			_undo.append(func() -> void: node.call("set_feature", token, true))
			return


func _hide_named(node_name: String) -> void:
	var all: Array[Node] = []
	_all(_scene, all)
	for node: Node in all:
		if str(node.name) == node_name and node.get("visible") == true:
			node.set("visible", false)
			_undo.append(func() -> void: node.set("visible", true))


func _build_toggles() -> void:
	_toggles = [
		{"name": "lights (all Light3D)", "run": func() -> void: _hide_kind("Light3D")},
		{"name": "omni+spot lights only", "run": func() -> void:
			_hide_kind("OmniLight3D")
			_hide_kind("SpotLight3D")},
		{"name": "light shadows", "run": _no_light_shadows},
		{"name": "all mesh shadow casting", "run": _no_shadows},
		{"name": "GPUParticles3D", "run": func() -> void: _hide_kind("GPUParticles3D")},
		{"name": "Label3D", "run": func() -> void: _hide_kind("Label3D")},
		{"name": "Sprite3D / AnimatedSprite3D", "run": func() -> void:
			_hide_kind("Sprite3D")
			_hide_kind("AnimatedSprite3D")},
		{"name": "MultiMeshInstance3D", "run": func() -> void: _hide_kind("MultiMeshInstance3D")},
		{"name": "Decal", "run": func() -> void: _hide_kind("Decal")},
		{"name": "glow + fog", "run": _no_env_effects},
		{"name": "glow only", "run": func() -> void: _env_toggle(true, false)},
		{"name": "fog only", "run": func() -> void: _env_toggle(false, true)},
		{"name": "directional shadow only", "run": func() -> void:
			for node: Node in _nodes_of("DirectionalLight3D"):
				var light: Light3D = node as Light3D
				if light.shadow_enabled:
					light.shadow_enabled = false
					_undo.append(func() -> void: light.shadow_enabled = true)},
		{"name": "omni shadows only", "run": func() -> void:
			for node: Node in _nodes_of("OmniLight3D"):
				var light: Light3D = node as Light3D
				if light.shadow_enabled:
					light.shadow_enabled = false
					_undo.append(func() -> void: light.shadow_enabled = true)},
		{"name": "look: post (tilt-shift)", "run": func() -> void: _look("post")},
		{"name": "look: sky", "run": func() -> void: _look("sky")},
		{"name": "look: scenery", "run": func() -> void: _look("scenery")},
		{"name": "look: foliage", "run": func() -> void: _look("foliage")},
		{"name": "look: ambient", "run": func() -> void: _look("ambient")},
		{"name": "StyleOutline", "run": func() -> void: _hide_named("StyleOutline")},
		{"name": "scale 0.55", "run": func() -> void: _scale(0.55)},
		{"name": "scale 0.5", "run": func() -> void: _scale(0.5)},
		{"name": "shadow filter hard", "run": func() -> void: _shadow_filter(RenderingServer.SHADOW_QUALITY_HARD)},
		{"name": "shadow filter soft very low", "run": func() -> void: _shadow_filter(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)},
		{"name": "shadow blur 0", "run": func() -> void: _shadow_blur(0.0)},
		{"name": "glow levels 2,3", "run": func() -> void: _glow_levels([2, 3] as Array[int])},
		{"name": "glow level 3 only", "run": func() -> void: _glow_levels([3] as Array[int])},
		{"name": "glow levels 0,1", "run": func() -> void: _glow_levels([0, 1] as Array[int])},
		{"name": "meshes <1.0 m no shadow", "run": func() -> void: _small_no_shadow(1.0)},
		{"name": "meshes <2.0 m no shadow", "run": func() -> void: _small_no_shadow(2.0)},
		{"name": "meshes <3.5 m no shadow", "run": func() -> void: _small_no_shadow(3.5)},
		{"name": "far cull 60 m", "run": func() -> void: _far_cull(60.0)},
		{"name": "far cull 45 m", "run": func() -> void: _far_cull(45.0)},
		{"name": "far cull 32 m", "run": func() -> void: _far_cull(32.0)},
	]


func await_ready_report() -> void:
	for node: Node in _nodes_of("Light3D"):
		var light: Light3D = node as Light3D
		if light.shadow_enabled:
			print("fps_toggles: shadowed light %s (%s) energy=%.2f color=%s rot=%s mask=%d idx=%d max=%.0f" % [light.get_path(), light.get_class(), light.light_energy, str(light.light_color), str(light.rotation_degrees), light.light_cull_mask, light.get_index(), (light as DirectionalLight3D).directional_shadow_max_distance if light is DirectionalLight3D else 0.0])


func _process(delta: float) -> bool:
	if _scene == null:
		root.get_node("Session").set("save_enabled", false)
		root.get_node("Settings").set("graphics_quality", int(_args.get("quality", 1)))
		root.get_node("Settings").set("vsync", false)
		root.get_node("Settings").set("max_fps", 0)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
		var packed: PackedScene = load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		_build_toggles()
		await_ready_report.call_deferred()
		return false
	_timer += delta
	var limit: float = WARM if _stage < 0 else SPAN
	if _timer < limit:
		if _stage >= 0 and _timer > 0.8:
			_frames.append(delta)
		return false
	var fps: float = 0.0
	if not _frames.is_empty():
		var total: float = 0.0
		for value: float in _frames:
			total += value
		fps = float(_frames.size()) / total
	if _stage >= 0:
		print("fps_toggles: %-30s -> %5.1f fps  (draw calls %d, primitives %d)" % [str(_toggles[_stage - 1]["name"]) if _stage > 0 else "baseline", fps, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	if _stage == 0:
		_glow_env_report()
	for undo: Callable in _undo:
		undo.call()
	_undo.clear()
	_stage += 1
	_timer = 0.0
	_frames.clear()
	if _stage > _toggles.size():
		quit(0)
		return true
	# stage 0 is a baseline pass (nothing switched); stage n runs toggle n-1.
	if _stage >= 1:
		(_toggles[_stage - 1]["run"] as Callable).call()
	return false
