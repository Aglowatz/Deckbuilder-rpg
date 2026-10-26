class_name GroundLight
extends Node
## Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): the "baked" ambient occlusion of a zone without LightmapGI (which has no script bake in 4.7.2, and the
## kit geometry is generated at run time without UV2). When the scene has finished loading, every static occluder (a mesh that stands on the ground and is at
## least a metre tall: buildings, walls, trees, big props; MultiMesh tree fields too) paints a soft dark pool into one small top-down texture of the zone
## (half-metre texels). The texture goes to the shader globals of `style_ground_light.gdshaderinc`, which every ground, wall, prop and character shader
## multiplies in, so corners, the foot of walls, the ground under trees and the people standing there all sit in the same soft shade. Costs one texture
## fetch per pixel and a few hundred milliseconds once at load; nothing per frame. Off on Low (`GraphicsQuality.cloud_shadows` gates it with the cloud
## shadows: Low never gets heavier).
## Graphics Tier 2 (docs/art/graphics_tier2.md): the map's G and B channels carry a bounce colour. Each rect occluder (a building, a wall) contributes the chroma
## of its materials (the albedo colour times the average of its texture) to the band of ground round its footprint, so a warm plaster wall tints the ground
## beside it the way bounced light would. Grey walls contribute nothing (the amount follows the colour's saturation); tree discs contribute nothing (their
## shade is the violet ambient already). `style_ground_bounce` (zone style `light.bounce`) scales it at run time.
## Install: `GroundLight.install(scene, bounds, style_rig)`; `rebake()` after dressing changes (the Capital changing state).

const TEXEL: float = 0.5
const MAX_SIZE: int = 512
const MIN_HEIGHT: float = 1.0
const MAX_FOOTPRINT: float = 60.0
## The map covers the walkable bounds plus this margin (metres).
const MARGIN: float = 6.0
## Tier 2: the bounce colour's strength at the foot of a fully saturated wall (a chroma delta multiplier).
const BOUNCE_AMOUNT: float = 1.2
## How much farther than the shade band the bounce colour reaches (a multiple of the occluder's shade margin).
const BOUNCE_REACH: float = 2.2
## Surfaces read per occluder for its colour.
const BOUNCE_SURFACES: int = 6

static var _white: ImageTexture
## Tier 2: the average colour of a texture, by its RID (decoding a kit texture once per session).
static var _texture_colors: Dictionary = {}

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


## A 1x1 "open, untinted" texture: the globals must always hold a valid texture (an unset sampler global samples as black).
static func white_texture() -> ImageTexture:
	if _white == null:
		var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
		image.fill(Color(1.0, 0.5, 0.5, 1.0))
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
	# Tier 2: the bounce deltas (red, blue) and their weight, accumulated per texel.
	var bounce_r: PackedFloat32Array = PackedFloat32Array()
	var bounce_b: PackedFloat32Array = PackedFloat32Array()
	var bounce_w: PackedFloat32Array = PackedFloat32Array()
	bounce_r.resize(width * height)
	bounce_b.resize(width * height)
	bounce_w.resize(width * height)
	occluder_count = 0
	var coloured: int = 0
	for occluder: Dictionary in collect_occluders(scene):
		var color: Color = occluder.get("color", Color(0.0, 0.0, 0.0, 0.0)) as Color
		_paint(open, bounce_r, bounce_b, bounce_w, width, height, rect.position, texel, occluder["rect"] as Rect2, float(occluder["height"]), bool(occluder.get("disc", false)), color)
		occluder_count += 1
		if color.a > 0.0:
			coloured += 1
	var blurred: PackedFloat32Array = _blur(open, width, height)
	bounce_r = _blur(bounce_r, width, height)
	bounce_b = _blur(bounce_b, width, height)
	bounce_w = _blur(bounce_w, width, height)
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y: int in range(height):
		for x: int in range(width):
			var index: int = y * width + x
			var v: float = blurred[index]
			var w: float = maxf(bounce_w[index], 1.0)
			var dr: float = clampf(bounce_r[index] / w, -1.0, 1.0)
			var db: float = clampf(bounce_b[index] / w, -1.0, 1.0)
			image.set_pixel(x, y, Color(v, 0.5 + 0.5 * dr, 0.5 + 0.5 * db, 1.0))
	texture = ImageTexture.create_from_image(image)
	RenderingServer.global_shader_parameter_set("style_ground_light", texture)
	RenderingServer.global_shader_parameter_set("style_ground_light_rect", Vector4(rect.position.x, rect.position.y, 1.0 / rect.size.x, 1.0 / rect.size.y))
	_apply_amount()
	bake_ms = Time.get_ticks_msec() - started
	if OS.get_environment("STYLE_DEBUG") != "":
		var peak: float = 0.0
		var filled: int = 0
		for index: int in range(width * height):
			if bounce_w[index] > 0.001:
				filled += 1
				peak = maxf(peak, maxf(absf(bounce_r[index]), absf(bounce_b[index])) / maxf(bounce_w[index], 1.0))
		print("ground_light: %d occluders (%d with a bounce colour) into %dx%d in %d ms; bounce texels %d, peak delta %.3f, textures read %d" % [occluder_count, coloured, width, height, bake_ms, filled, peak, _texture_colors.size()])
		for occluder: Dictionary in collect_occluders(scene).slice(0, 6):
			print("  occluder %s colour %s" % [str(occluder["rect"]), str(occluder.get("color"))])


## The static occluders under `root`: {"rect": Rect2 (world x/z), "height": float, "disc": bool, "color": Color (the bounce delta, a = amount)}. A mesh counts when it
## stands on the ground, is at least MIN_HEIGHT tall and no wider than MAX_FOOTPRINT (ground planes, water and the sky dome are not occluders); world-look pieces
## (`no_range_cull`), characters (WorldSprite cards) and invisible or faded meshes are skipped. MultiMesh fields (tree cards) contribute every instance.
static func collect_occluders(root: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if not _counts(mesh_instance) or mesh_instance.mesh == null:
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
		_add_box(result, box, bounce_of(mesh_instance))
	for node: Node in root.find_children("*", "MultiMeshInstance3D", true, false):
		var field: MultiMeshInstance3D = node as MultiMeshInstance3D
		if not field.is_visible_in_tree() or field.multimesh == null or field.multimesh.mesh == null or field.has_meta(&"no_range_cull"):
			continue
		var local: AABB = field.multimesh.mesh.get_aabb()
		var count: int = mini(field.multimesh.visible_instance_count if field.multimesh.visible_instance_count >= 0 else field.multimesh.instance_count, 4096)
		for index: int in range(count):
			var box: AABB = field.global_transform * (field.multimesh.get_instance_transform(index) * local)
			_add_box(result, box, Color(0.0, 0.0, 0.0, 0.0))
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
static func _add_box(result: Array[Dictionary], box: AABB, color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if box.size.y < MIN_HEIGHT or box.size.x > MAX_FOOTPRINT or box.size.z > MAX_FOOTPRINT or box.position.y > 1.5 or box.end.y < 1.0:
		return
	var thin: bool = minf(box.size.x, box.size.z) < 0.6
	if thin:
		if box.size.y < 2.5:
			return  # a fence, a low sign: no shade worth painting
		var centre: Vector2 = Vector2(box.get_center().x, box.get_center().z)
		result.append({"rect": Rect2(centre - Vector2.ONE * 0.5, Vector2.ONE), "height": box.size.y, "disc": true, "color": Color(0.0, 0.0, 0.0, 0.0)})
		return
	if box.size.x * box.size.z < 0.3:
		return
	result.append({"rect": Rect2(box.position.x, box.position.z, box.size.x, box.size.z), "height": box.size.y, "disc": false, "color": color})


# ---- Tier 2: the bounce colour of an occluder ---------------------------------------------------------------------------------------------------------


## The bounce delta of a mesh: the average colour of its materials (up to BOUNCE_SURFACES surfaces) turned into a chroma delta (r, g, b = chroma - 1) with the
## amount in `a` (0 = nothing to bounce: grey, unknown or unshaded).
static func bounce_of(mesh_instance: MeshInstance3D) -> Color:
	var mesh: Mesh = mesh_instance.mesh
	if mesh == null:
		return Color(0.0, 0.0, 0.0, 0.0)
	var sum: Color = Color(0.0, 0.0, 0.0, 0.0)
	var found: int = 0
	for index: int in range(mini(mesh.get_surface_count(), BOUNCE_SURFACES)):
		var material: Material = mesh_instance.material_override
		if material == null:
			material = mesh_instance.get_surface_override_material(index)
		if material == null:
			material = mesh.surface_get_material(index)
		var color: Color = material_color(material)
		if color.a > 0.0:
			sum += color
			found += 1
	if found == 0:
		return Color(0.0, 0.0, 0.0, 0.0)
	return bounce_delta(sum / float(found))


## The average albedo of a material (a = 1 when known, 0 when not): a StandardMaterial3D's colour times its texture's average, or the toon shader's `albedo`
## and `albedo_tex` (the values StyleToon copied from the kit material).
static func material_color(material: Material) -> Color:
	if material is StandardMaterial3D:
		var standard: StandardMaterial3D = material as StandardMaterial3D
		if standard.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
			return Color(0.0, 0.0, 0.0, 0.0)
		var color: Color = standard.albedo_color
		if standard.albedo_texture != null:
			color = color * texture_average(standard.albedo_texture)
		return Color(color.r, color.g, color.b, 1.0)
	if material is ShaderMaterial:
		var shader_material: ShaderMaterial = material as ShaderMaterial
		var albedo: Variant = shader_material.get_shader_parameter("albedo")
		if not (albedo is Color):
			return Color(0.0, 0.0, 0.0, 0.0)
		var color: Color = albedo as Color
		var use_texture: Variant = shader_material.get_shader_parameter("use_texture")
		var albedo_texture: Variant = shader_material.get_shader_parameter("albedo_tex")
		if bool(use_texture) and albedo_texture is Texture2D:
			color = color * texture_average(albedo_texture as Texture2D)
		return Color(color.r, color.g, color.b, 1.0)
	return Color(0.0, 0.0, 0.0, 0.0)


## The average colour of a texture (alpha-weighted, from an 8x8 downscale), cached per texture for the session; white when it cannot be read.
static func texture_average(texture_value: Texture2D) -> Color:
	var key: RID = texture_value.get_rid()
	if _texture_colors.has(key):
		return _texture_colors[key] as Color
	var result: Color = Color.WHITE
	var image: Image = texture_value.get_image()
	if image != null and not image.is_empty():
		if image.is_compressed():
			if image.decompress() != OK:
				image = null
		if image != null:
			# An 8x8 grid of point samples (no full-image resize: the decode is the cost worth paying once, the resize is not).
			var w: int = image.get_width()
			var h: int = image.get_height()
			var sum: Color = Color(0.0, 0.0, 0.0, 0.0)
			var weight: float = 0.0
			for y: int in range(8):
				for x: int in range(8):
					var pixel: Color = image.get_pixel(mini((x * w) / 8 + w / 16, w - 1), mini((y * h) / 8 + h / 16, h - 1))
					sum += Color(pixel.r * pixel.a, pixel.g * pixel.a, pixel.b * pixel.a, 0.0)
					weight += pixel.a
			if weight > 0.01:
				result = Color(sum.r / weight, sum.g / weight, sum.b / weight, 1.0)
	_texture_colors[key] = result
	return result


## A colour's bounce delta: its chroma (colour / luminance) minus one, with the amount from its saturation (grey walls tint nothing) times BOUNCE_AMOUNT.
static func bounce_delta(color: Color) -> Color:
	var luma: float = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	if luma < 0.08:
		return Color(0.0, 0.0, 0.0, 0.0)
	var top: float = maxf(color.r, maxf(color.g, color.b))
	var bottom: float = minf(color.r, minf(color.g, color.b))
	var saturation: float = clampf((top - bottom) / maxf(top, 0.001), 0.0, 1.0)
	var amount: float = clampf(saturation * 2.0, 0.0, 1.0) * BOUNCE_AMOUNT
	return Color(color.r / luma - 1.0, color.g / luma - 1.0, color.b / luma - 1.0, amount)


## Darkens the texels round one occluder. Rect: full at the footprint line, fading outward over a margin that grows with the height and inward over
## INNER_FADE metres. Disc: full at the foot, fading out over the canopy radius. Rect occluders with a colour also add their bounce delta along the band.
const INNER_FADE: float = 1.0


static func _paint(open: PackedFloat32Array, bounce_r: PackedFloat32Array, bounce_b: PackedFloat32Array, bounce_w: PackedFloat32Array, width: int, height: int, origin: Vector2, texel: Vector2, footprint: Rect2, tall: float, disc: bool = false, color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	# A wall's foot takes a light band (the kit's own AO skirt is under it too); a canopy disc is the real shade.
	var strength: float = clampf(0.16 + 0.07 * tall, 0.2, 0.48) if disc else clampf(0.1 + 0.04 * tall, 0.14, 0.28)
	var margin: float = clampf(0.3 * tall, 0.8, 2.8) if not disc else clampf(0.28 * tall, 1.2, 3.2)
	var bounce: float = 0.0 if disc else color.a
	var half: Vector2 = footprint.size * 0.5
	var center: Vector2 = footprint.get_center()
	var reach: float = margin * (BOUNCE_REACH if bounce > 0.0 else 1.0)
	var x0: int = maxi(int(floor((footprint.position.x - reach - origin.x) / texel.x)), 0)
	var x1: int = mini(int(ceil((footprint.end.x + reach - origin.x) / texel.x)), width - 1)
	var y0: int = maxi(int(floor((footprint.position.y - reach - origin.y) / texel.y)), 0)
	var y1: int = mini(int(ceil((footprint.end.y + reach - origin.y) / texel.y)), height - 1)
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
			# The bounce reaches twice as far as the shade (bounced light spreads wider than contact shadow does).
			if bounce > 0.0 and not disc:
				var q2: Vector2 = (Vector2(wx, wz) - center).abs() - half
				var outside2: float = Vector2(maxf(q2.x, 0.0), maxf(q2.y, 0.0)).length()
				var t2: float = clampf(outside2 / (margin * BOUNCE_REACH), 0.0, 1.0)
				var band2: float = 1.0 - t2 * t2 * (3.0 - 2.0 * t2)
				if band2 > 0.0:
					var k: float = band2 * bounce
					bounce_r[index] += color.r * k
					bounce_b[index] += color.b * k
					bounce_w[index] += k


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
