class_name GroundLight
extends Node
## Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): the "baked" ambient occlusion of a zone without LightmapGI (which has no script bake in 4.7.2, and the
## kit geometry is generated at run time without UV2). When the scene has finished loading, every static occluder (a mesh that stands on the ground and is at
## least a metre tall: buildings, walls, trees, big props; MultiMesh tree fields too) paints a soft dark pool into one small top-down texture of the zone
## (half-metre texels). The texture goes to the shader globals of `style_ground_light.gdshaderinc`, which every ground, wall, prop and character shader
## multiplies in, so corners, the foot of walls, the ground under trees and the people standing there all sit in the same soft shade. Costs one texture
## fetch per pixel and a few hundred milliseconds once at load; nothing per frame. Off on Low (`GraphicsQuality.cloud_shadows` gates it with the cloud
## shadows: Low never gets heavier).
## Install: `GroundLight.install(scene, bounds, style_rig)`; `rebake()` after dressing changes (the Capital changing state).

const TEXEL: float = 0.5
const MAX_SIZE: int = 512
const MIN_HEIGHT: float = 1.0
const MAX_FOOTPRINT: float = 60.0
## The map covers the walkable bounds plus this margin (metres).
const MARGIN: float = 6.0

static var _white: ImageTexture

var scene: Node
var bounds: Rect2
var style_rig: StyleRig
var texture: ImageTexture
var occluder_count: int = 0
var bake_ms: int = 0
var _baked: bool = false
var _frames: int = 0


static func install(owner_scene: Node, area_bounds: Rect2, rig: StyleRig) -> GroundLight:
	var light: GroundLight = GroundLight.new()
	light.name = "GroundLight"
	light.scene = owner_scene
	light.bounds = area_bounds
	light.style_rig = rig
	owner_scene.add_child(light)
	return light


## A 1x1 white texture: the globals must always hold a valid texture (an unset sampler global samples as black).
static func white_texture() -> ImageTexture:
	if _white == null:
		var image: Image = Image.create(1, 1, false, Image.FORMAT_R8)
		image.fill(Color.WHITE)
		_white = ImageTexture.create_from_image(image)
	return _white


## Every scene starts open: no map, no darkening (the globals outlive the scene that set them).
static func clear_globals() -> void:
	RenderingServer.global_shader_parameter_set("style_ground_light_amount", 0.0)
	RenderingServer.global_shader_parameter_set("style_ground_light", white_texture())
	RenderingServer.global_shader_parameter_set("style_ground_light_rect", Vector4(0.0, 0.0, 1.0, 1.0))


func _ready() -> void:
	clear_globals()
	Settings.graphics_changed.connect(_apply_amount)


func _exit_tree() -> void:
	if Settings.graphics_changed.is_connected(_apply_amount):
		Settings.graphics_changed.disconnect(_apply_amount)
	clear_globals()


func _process(_delta: float) -> void:
	if _baked:
		return
	_frames += 1
	var finished: bool = _frames > 2
	if scene.has_method("is_load_finished"):
		finished = bool(scene.call("is_load_finished")) and _frames > 2
	if finished:
		bake()


func rebake() -> void:
	_baked = false
	_frames = 0


func enabled() -> bool:
	var level: int = style_rig.quality() if style_rig != null else Settings.graphics_quality
	return GraphicsQuality.cloud_shadows(level) and OS.get_environment("NO_GROUND_LIGHT") == ""


func _apply_amount() -> void:
	if texture == null:
		return
	RenderingServer.global_shader_parameter_set("style_ground_light_amount", 1.0 if enabled() else 0.0)


## Paints the map and pushes it to the shader globals.
func bake() -> void:
	_baked = true
	var started: int = Time.get_ticks_msec()
	var rect: Rect2 = bounds.grow(MARGIN)
	var width: int = clampi(int(ceil(rect.size.x / TEXEL)), 8, MAX_SIZE)
	var height: int = clampi(int(ceil(rect.size.y / TEXEL)), 8, MAX_SIZE)
	var texel: Vector2 = Vector2(rect.size.x / float(width), rect.size.y / float(height))
	var open: PackedFloat32Array = PackedFloat32Array()
	open.resize(width * height)
	open.fill(1.0)
	occluder_count = 0
	for occluder: Dictionary in collect_occluders(scene):
		_paint(open, width, height, rect.position, texel, occluder["rect"] as Rect2, float(occluder["height"]), bool(occluder.get("disc", false)))
		occluder_count += 1
	var blurred: PackedFloat32Array = _blur(open, width, height)
	var image: Image = Image.create(width, height, false, Image.FORMAT_R8)
	for y: int in range(height):
		for x: int in range(width):
			var v: float = blurred[y * width + x]
			image.set_pixel(x, y, Color(v, v, v))
	texture = ImageTexture.create_from_image(image)
	RenderingServer.global_shader_parameter_set("style_ground_light", texture)
	RenderingServer.global_shader_parameter_set("style_ground_light_rect", Vector4(rect.position.x, rect.position.y, 1.0 / rect.size.x, 1.0 / rect.size.y))
	_apply_amount()
	bake_ms = Time.get_ticks_msec() - started
	if OS.get_environment("STYLE_DEBUG") != "":
		print("ground_light: %d occluders into %dx%d in %d ms" % [occluder_count, width, height, bake_ms])


## The static occluders under `root`: {"rect": Rect2 (world x/z), "height": float}. A mesh counts when it stands on the ground, is at least MIN_HEIGHT tall and no
## wider than MAX_FOOTPRINT (ground planes, water and the sky dome are not occluders); world-look pieces (`no_range_cull`), characters (WorldSprite cards) and
## invisible or faded meshes are skipped. MultiMesh fields (tree cards) contribute every instance.
static func collect_occluders(root: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if not _counts(mesh_instance) or mesh_instance.mesh == null:
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
		_add_box(result, box)
	for node: Node in root.find_children("*", "MultiMeshInstance3D", true, false):
		var field: MultiMeshInstance3D = node as MultiMeshInstance3D
		if not field.is_visible_in_tree() or field.multimesh == null or field.multimesh.mesh == null or field.has_meta(&"no_range_cull"):
			continue
		var local: AABB = field.multimesh.mesh.get_aabb()
		var count: int = mini(field.multimesh.visible_instance_count if field.multimesh.visible_instance_count >= 0 else field.multimesh.instance_count, 4096)
		for index: int in range(count):
			var box: AABB = field.global_transform * (field.multimesh.get_instance_transform(index) * local)
			_add_box(result, box)
	return result


static func _counts(mesh_instance: MeshInstance3D) -> bool:
	if not mesh_instance.is_visible_in_tree() or mesh_instance.transparency > 0.01:
		return false
	if mesh_instance.has_meta(&"no_range_cull") or mesh_instance.has_meta(&"no_ground_light"):
		return false
	var parent: Node = mesh_instance.get_parent()
	if parent is WorldSprite or parent is Camera3D:
		return false
	return true


## A box becomes a "rect" occluder (a building, a wall, a big prop: a ring of shade round its footprint line, nothing under its middle, which is hidden anyway
## and would show as a dark rectangle when the OcclusionFader cuts the building away) or, when it is thin and tall (a tree card, a post), a "disc" of canopy
## shade round its foot.
static func _add_box(result: Array[Dictionary], box: AABB) -> void:
	if box.size.y < MIN_HEIGHT or box.size.x > MAX_FOOTPRINT or box.size.z > MAX_FOOTPRINT or box.position.y > 1.5 or box.end.y < 1.0:
		return
	var thin: bool = minf(box.size.x, box.size.z) < 0.6
	if thin:
		if box.size.y < 2.5:
			return  # a fence, a low sign: no shade worth painting
		var centre: Vector2 = Vector2(box.get_center().x, box.get_center().z)
		result.append({"rect": Rect2(centre - Vector2.ONE * 0.5, Vector2.ONE), "height": box.size.y, "disc": true})
		return
	if box.size.x * box.size.z < 0.3:
		return
	result.append({"rect": Rect2(box.position.x, box.position.z, box.size.x, box.size.z), "height": box.size.y, "disc": false})


## Darkens the texels round one occluder. Rect: full at the footprint line, fading outward over a margin that grows with the height and inward over
## INNER_FADE metres. Disc: full at the foot, fading out over the canopy radius.
const INNER_FADE: float = 1.0


static func _paint(open: PackedFloat32Array, width: int, height: int, origin: Vector2, texel: Vector2, footprint: Rect2, tall: float, disc: bool = false) -> void:
	# A wall's foot takes a light band (the kit's own AO skirt is under it too); a canopy disc is the real shade.
	var strength: float = clampf(0.16 + 0.07 * tall, 0.2, 0.48) if disc else clampf(0.1 + 0.04 * tall, 0.14, 0.28)
	var margin: float = clampf(0.3 * tall, 0.8, 2.8) if not disc else clampf(0.28 * tall, 1.2, 3.2)
	var half: Vector2 = footprint.size * 0.5
	var center: Vector2 = footprint.get_center()
	var x0: int = maxi(int(floor((footprint.position.x - margin - origin.x) / texel.x)), 0)
	var x1: int = mini(int(ceil((footprint.end.x + margin - origin.x) / texel.x)), width - 1)
	var y0: int = maxi(int(floor((footprint.position.y - margin - origin.y) / texel.y)), 0)
	var y1: int = mini(int(ceil((footprint.end.y + margin - origin.y) / texel.y)), height - 1)
	for y: int in range(y0, y1 + 1):
		var wz: float = origin.y + (float(y) + 0.5) * texel.y
		for x: int in range(x0, x1 + 1):
			var wx: float = origin.x + (float(x) + 0.5) * texel.x
			var band: float
			if disc:
				var t: float = clampf((Vector2(wx, wz) - center).length() / margin, 0.0, 1.0)
				band = 1.0 - t * t * (3.0 - 2.0 * t)
			else:
				var q: Vector2 = (Vector2(wx, wz) - center).abs() - half
				var outside: float = Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length()
				var inside: float = -maxf(q.x, q.y) if q.x <= 0.0 and q.y <= 0.0 else 0.0
				var t: float = clampf(outside / margin, 0.0, 1.0)
				band = (1.0 - t * t * (3.0 - 2.0 * t)) * (1.0 - clampf(inside / INNER_FADE, 0.0, 1.0))
			var index: int = y * width + x
			open[index] = open[index] * (1.0 - strength * band)


static func _blur(values: PackedFloat32Array, width: int, height: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	out.resize(values.size())
	for y: int in range(height):
		var y0: int = maxi(y - 1, 0)
		var y1: int = mini(y + 1, height - 1)
		for x: int in range(width):
			var x0: int = maxi(x - 1, 0)
			var x1: int = mini(x + 1, width - 1)
			var sum: float = 0.0
			var n: float = 0.0
			for yy: int in range(y0, y1 + 1):
				var row: int = yy * width
				for xx: int in range(x0, x1 + 1):
					sum += values[row + xx]
					n += 1.0
			out[y * width + x] = sum / n
	return out
