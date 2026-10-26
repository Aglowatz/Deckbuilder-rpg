extends SceneTree
## Fixes Oct 26, Part 1: how far the game camera sees in an area, so the sun's shadow can reach the top of the screen (docs/perf/report.md).
## Run windowed (it reads the depth buffer): Godot --path . -s res://tools/shadow_reach_probe.gd -- --scene=res://scenes/dna_zone.tscn [--spots=10]
##   [--zoom=2.0] [--angles=0,1,2] [--margin=8]
## For each hero spot (spread over the walkable area, the spawn first) and each angle preset at the zoom, a full-screen quad writes the linear
## view depth of every pixel; the probe reads the frame back and reconstructs each pixel's world point. A pixel counts as "in the area" when its
## world point lies inside the area's map bounds grown by `--margin` m (the rim dressing); the far backdrops beyond (mountains, sky cards) do not.
## Prints "shadow_reach: <scene> angle=<a> zoom=<z> spot=<x,z> in_max=<m> in_p99=<m> all_max=<m>" per sample and a summary line
## "shadow_reach_summary: <scene> in_max=<m> in_p99=<m> all_max=<m> spots=<n>".

const DEPTH_SHADER: String = """
shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, depth_test_disabled, cull_disabled, shadows_disabled;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest, repeat_disable;
vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}
void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}
void fragment() {
	float d = texture(depth_tex, SCREEN_UV).x;
	vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d, 1.0);
	float lin = -view.z / view.w;
	float q = clamp(lin / 4.0, 0.0, 254.99);
	vec3 enc = vec3(floor(q) / 255.0, fract(q), d < 0.0000001 ? 1.0 : 0.0);
	ALBEDO = to_linear(enc);
	ALPHA = 1.0;
}
"""

var _args: Dictionary = {}
var _scene: Node
var _step: int = 0
var _wait: int = 0
var _look: Node
var _hero: Node3D
var _area: Object
var _spots: Array[Vector3] = []
var _jobs: Array[Vector2] = []  # (spot index, angle)
var _quad: MeshInstance3D
var _summary_in: Array[float] = []
var _summary_p99: Array[float] = []
var _summary_all: Array[float] = []


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))


func _process(_delta: float) -> bool:
	match _step:
		0:
			var settings: Node = root.get_node("Settings")
			root.get_node("Session").set("save_enabled", false)
			settings.set("graphics_quality", int(_args.get("quality", 1)))
			settings.set("depth_of_field", false)
			settings.set("upscaling_mode", 1)
			settings.set("render_scale_pct", 100)
			settings.set("camera_zoom", float(_args.get("zoom", 2.0)))
			_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
			if _scene.has_method("screenshot_prepare"):
				_scene.call("screenshot_prepare", _args)
			root.add_child(_scene)
			_step = 1
			_wait = 240
		1:
			_wait -= 1
			if _wait > 0:
				return false
			var found: Array[Node] = _scene.find_children("WorldLookRig", "", true, false)
			if found.is_empty():
				push_error("shadow_reach: no WorldLookRig in %s" % str(_args.get("scene")))
				quit(1)
				return true
			_look = found[0]
			_hero = _look.get("follow") as Node3D
			_area = _look.get("area") as Object
			if _args.has("casters"):
				_caster_census(float(_args.get("casters")))
				quit(0)
				return true
			_pick_spots()
			_prepare_frame()
			for spot_index: int in _spots.size():
				for angle: String in str(_args.get("angles", "0,1,2")).split(",", false):
					_jobs.append(Vector2(spot_index, int(angle)))
			_step = 2
			_wait = 0
		2:
			if _jobs.is_empty():
				_print_summary()
				quit(0)
				return true
			var job: Vector2 = _jobs[0]
			if _wait == 0:
				root.get_node("Settings").set("camera_angle", int(job.y))
				_hero.global_position = _spots[int(job.x)]
				_wait = 45
				return false
			_wait -= 1
			if _wait > 1:
				return false
			_wait = 0
			_jobs.pop_front()
			_measure(_spots[int(job.x)], int(job.y))
	return false


## `--casters=<near m>`: the shadow casters (visible, cast_shadow on) beyond the near cascade, grouped by their parent's name, with their size class.
func _caster_census(near: float) -> void:
	var cam: Camera3D = root.get_viewport().get_camera_3d()
	var groups: Dictionary = {}
	var total: int = 0
	for node: Node in _scene.find_children("*", "GeometryInstance3D", true, false):
		var geo: GeometryInstance3D = node as GeometryInstance3D
		if not geo.is_visible_in_tree() or geo.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			continue
		var box: AABB = geo.global_transform * geo.get_aabb()
		var depth: float = (box.get_center() - cam.global_position).dot(-cam.global_transform.basis.z)
		if depth < near:
			continue
		var size: float = box.size.length()
		var rel: String = str(_scene.get_path_to(geo))
		if _args.has("frustum") and not cam.is_position_in_frustum(box.get_center()):
			continue
		var top: String = "/".join(rel.split("/").slice(0, int(_args.get("top", "2")))) if _args.has("top") else str(geo.get_parent().name).left(28)
		var key: String = "%s/%s %s" % [top.left(48), geo.get_class(), "small" if size < 2.5 else ("mid" if size < 8.0 else "big")]
		groups[key] = int(groups.get(key, 0)) + 1
		total += 1
	var keys: Array = groups.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(groups[a]) > int(groups[b]))
	print("shadow_casters: %s beyond %.0f m: %d" % [str(_args.get("scene")), near, total])
	for key: Variant in keys.slice(0, 30):
		print("shadow_casters:   %4d  %s" % [int(groups[key]), str(key)])


func _pick_spots() -> void:
	_spots.append(_hero.global_position)
	var bounds: Rect2 = (_area.call("map_bounds") as Rect2)
	var count: int = int(_args.get("spots", 10))
	var candidates: Array[Vector3] = []
	var cells: int = 14
	for ix: int in cells:
		for iz: int in cells:
			var p: Vector3 = Vector3(bounds.position.x + bounds.size.x * (ix + 0.5) / cells, 0.0, bounds.position.y + bounds.size.y * (iz + 0.5) / cells)
			if bool(_area.call("is_walkable", p)):
				p.y = float(_area.call("height_at", p))
				candidates.append(p)
	# Farthest-point sampling (the south edge always ends up in: the camera looks north over the whole area from there).
	candidates.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.z > b.z)
	if not candidates.is_empty():
		_spots.append(candidates[0])
	while _spots.size() < count and not candidates.is_empty():
		var best: int = -1
		var best_gap: float = -1.0
		for i: int in candidates.size():
			var gap: float = INF
			for s: Vector3 in _spots:
				gap = minf(gap, Vector2(s.x - candidates[i].x, s.z - candidates[i].z).length())
			if gap > best_gap:
				best_gap = gap
				best = i
		_spots.append(candidates[best])
		candidates.remove_at(best)


func _prepare_frame() -> void:
	var cam: Camera3D = root.get_viewport().get_camera_3d()
	_quad = MeshInstance3D.new()
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(2.0, 2.0)
	_quad.mesh = mesh
	_quad.extra_cull_margin = 16384.0
	_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_quad.set_meta(&"no_toon", true)
	var shader: Shader = Shader.new()
	shader.code = DEPTH_SHADER
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.render_priority = 127
	_quad.material_override = material
	cam.add_child(_quad)
	root.get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	root.get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	for layer: Node in root.find_children("*", "CanvasLayer", true, false):
		(layer as CanvasLayer).visible = false
	for env_node: Node in root.find_children("*", "WorldEnvironment", true, false):
		var env: Environment = (env_node as WorldEnvironment).environment
		if env != null:
			env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
			env.tonemap_exposure = 1.0
			env.glow_enabled = false
			env.adjustment_enabled = false
			env.fog_enabled = false
			env.volumetric_fog_enabled = false
	root.get_viewport().use_debanding = false


func _measure(spot: Vector3, angle: int) -> void:
	var cam: Camera3D = root.get_viewport().get_camera_3d()
	# Re-assert the probe's environment (a zone look blending its mood may have re-applied its tonemap).
	for env_node: Node in root.find_children("*", "WorldEnvironment", true, false):
		var env: Environment = (env_node as WorldEnvironment).environment
		if env != null:
			env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
			env.tonemap_exposure = 1.0
			env.glow_enabled = false
			env.adjustment_enabled = false
			env.fog_enabled = false
	var image: Image = root.get_viewport().get_texture().get_image()
	var size: Vector2i = image.get_size()
	var bounds: Rect2 = (_area.call("map_bounds") as Rect2).grow(float(_args.get("margin", 8.0)))
	var inside: Array[float] = []
	var all_max: float = 0.0
	var top_in: float = 0.0
	for y: int in range(0, size.y, 6):
		for x: int in range(0, size.x, 6):
			var c: Color = image.get_pixel(x, y)
			if c.b > 0.5:
				continue
			var depth: float = (roundf(c.r * 255.0) + c.g) * 4.0
			if depth < 0.3:
				continue
			# The outline / post quads draw in front at the near plane: skip the hero-near noise.
			var ray: Vector3 = cam.project_ray_normal(Vector2(x, y) * Vector2(root.get_viewport().get_visible_rect().size) / Vector2(size))
			var forward: Vector3 = -cam.global_transform.basis.z
			var along: float = depth / maxf(ray.dot(forward), 0.01)
			var world: Vector3 = cam.global_position + ray * along
			all_max = maxf(all_max, depth)
			if bounds.has_point(Vector2(world.x, world.z)) and world.y < float(_args.get("max_y", 30.0)) and world.y > -12.0:
				inside.append(depth)
				if y < size.y / 8:
					top_in = maxf(top_in, depth)
	inside.sort()
	var in_max: float = inside[inside.size() - 1] if not inside.is_empty() else 0.0
	var in_p99: float = inside[int(float(inside.size() - 1) * 0.99)] if not inside.is_empty() else 0.0
	_summary_in.append(in_max)
	_summary_p99.append(in_p99)
	_summary_all.append(all_max)
	print("shadow_reach: %s angle=%d zoom=%.2f spot=%.1f,%.1f cam=%.1f,%.1f,%.1f in_max=%.1f in_p99=%.1f top_in=%.1f all_max=%.1f" % [
		str(_args.get("scene")), angle, float(_args.get("zoom", 2.0)), spot.x, spot.z, cam.global_position.x, cam.global_position.y,
		cam.global_position.z, in_max, in_p99, top_in, all_max])
	if _args.has("save"):
		image.save_png("res://_screenshots/shadow_reach_%d.png" % _summary_in.size())


func _print_summary() -> void:
	var in_max: float = 0.0
	var p99_max: float = 0.0
	var all_max: float = 0.0
	for value: float in _summary_in:
		in_max = maxf(in_max, value)
	for value: float in _summary_p99:
		p99_max = maxf(p99_max, value)
	for value: float in _summary_all:
		all_max = maxf(all_max, value)
	print("shadow_reach_summary: %s in_max=%.1f in_p99=%.1f all_max=%.1f spots=%d" % [str(_args.get("scene")), in_max, p99_max, all_max, _spots.size()])
