class_name HeapWater
extends RefCounted
## The Verdant Dump v2's moving water (docs/art/verdant_dump_v2.md, Part B and D): the turquoise river in the ravine, the gorge stepping down the
## terraces, the sludge chasm and the compost pits as water strips at the layout's levels (`HeapLayout.water_level_at`), and the waterfalls between the
## tiers: one curved sheet of the scrolling-streak shader (the Gainlands' waterfall shader, recoloured turquoise and white) from a lip down to the water,
## a pale pool of foam where it lands and a few puffs of mist. Views only: nothing here blocks or is walked on.

const SHADER_PATH: String = "res://world/gainlands/gainlands_waterfall.gdshader"
const SHALLOW: Color = Color("62d6c0")
const DEEP: Color = Color("1f7a86")
const SLUDGE_SHALLOW: Color = Color("6a9a78")
const SLUDGE_DEEP: Color = Color("2a4a3a")

static var _fall_material: ShaderMaterial
static var _foam: StandardMaterial3D
static var _mist: StandardMaterial3D


static func fall_material() -> ShaderMaterial:
	if _fall_material == null:
		_fall_material = ShaderMaterial.new()
		_fall_material.shader = load(SHADER_PATH) as Shader
		_fall_material.set_shader_parameter("water_color", Color(0.62, 0.9, 0.9))
		_fall_material.set_shader_parameter("foam_color", Color(0.97, 1.0, 1.0))
		_fall_material.set_shader_parameter("speed", 1.3)
		_fall_material.set_shader_parameter("opacity", 0.86)
		if EnvKit.has_art("DUMP-PROP-WATERFALL-02"):
			# art import Oct 20: a painted falling-water sheet (DUMP-PROP-WATERFALL, 3x2 sheet) laid under the scrolling streaks
			_fall_material.set_shader_parameter("fall_tex", EnvKit.texture("DUMP-PROP-WATERFALL-02"))
			_fall_material.set_shader_parameter("use_tex", true)
			_fall_material.set_shader_parameter("tex_repeat", 1.0)
	return _fall_material


static func _never(node: Node3D) -> void:
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_range_cull", true)
	node.set_meta(StyleToon.META_NO_TOON, true)
	node.set_meta(PaintedClasses.META_NO_PAINT, true)


## A water surface built from a list of quads (each four world points, counter-clockwise seen from above): one mesh, the toon water shader.
static func surface(quads: Array, node_name: String, shallow: Color = SHALLOW, deep: Color = DEEP) -> MeshInstance3D:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_smooth_group(-1)
	for entry: Variant in quads:
		var q: Array = entry as Array
		for p: Vector3 in [q[0], q[1], q[2], q[0], q[2], q[3]]:
			tool.set_color(Color.WHITE)
			tool.set_uv(Vector2(p.x, p.z) * 0.25)
			tool.add_vertex(p)
	tool.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = tool.commit()
	instance.material_override = StyleWater.painted("DUMP-SURF-WATER", shallow, deep)  # the painted turquoise river under the toon water (art import Oct 20)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.name = node_name
	_never(instance)
	return instance


## A strip of water along a centre line `centre(s)` (a Callable s -> Vector2 xz) from s0 to s1, `half` wide, at `level(s)` (a Callable s -> float).
static func strip(centre: Callable, level: Callable, s0: float, s1: float, half: float, node_name: String, step: float = 1.5, shallow: Color = SHALLOW, deep: Color = DEEP) -> MeshInstance3D:
	var quads: Array = []
	var s: float = s0
	while s < s1 - 0.001:
		var n: float = minf(s + step, s1)
		var c0: Vector2 = centre.call(s) as Vector2
		var c1: Vector2 = centre.call(n) as Vector2
		var d: Vector2 = (c1 - c0).normalized()
		var side: Vector2 = Vector2(-d.y, d.x) * half
		var y0: float = float(level.call(s))
		var y1: float = float(level.call(n))
		quads.append([Vector3(c0.x - side.x, y0, c0.y - side.y), Vector3(c1.x - side.x, y1, c1.y - side.y), Vector3(c1.x + side.x, y1, c1.y + side.y), Vector3(c0.x + side.x, y0, c0.y + side.y)])
		s = n
	return surface(quads, node_name, shallow, deep)


## A round pool (a pit, the drain) of `radius` at `centre`, `level` high.
static func pool(centre: Vector2, radius: float, level: float, node_name: String, shallow: Color = SHALLOW, deep: Color = DEEP) -> MeshInstance3D:
	var quads: Array = []
	var segments: int = 20
	for index: int in range(segments):
		var a0: float = TAU * float(index) / float(segments)
		var a1: float = TAU * float(index + 1) / float(segments)
		var p0: Vector3 = Vector3(centre.x + cos(a0) * radius, level, centre.y + sin(a0) * radius)
		var p1: Vector3 = Vector3(centre.x + cos(a1) * radius, level, centre.y + sin(a1) * radius)
		var mid: Vector3 = Vector3(centre.x, level, centre.y)
		quads.append([mid, p1, p0, mid])
	return surface(quads, node_name, shallow, deep)


## A waterfall whose lip is centred at `top` (on a cliff edge), `width` wide, falling along `outward` (xz) to the water at `landing_y`.
static func waterfall(top: Vector3, width: float, outward: Vector2, landing_y: float, node_name: String = "Waterfall") -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var out: Vector3 = Vector3(outward.x, 0.0, outward.y).normalized()
	var across: Vector3 = Vector3(-out.z, 0.0, out.x)
	var drop: float = maxf(top.y - landing_y, 0.5)
	# the curve of the sheet: it leaves the lip almost level and bends down, ending a body length out from the cliff's foot
	var profile: Array[Vector2] = [Vector2(-0.3, 0.05), Vector2(0.35, -0.12), Vector2(0.8, -0.4), Vector2(1.15, -0.75), Vector2(1.45, -1.0)]
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rows: Array = []
	for index: int in range(profile.size()):
		var step: Vector2 = profile[index]
		var centre: Vector3 = top + out * step.x * minf(drop * 0.35, 2.4) + Vector3(0.0, step.y * drop, 0.0)
		var spread: float = width * (1.0 + 0.25 * float(index) / float(profile.size() - 1))
		rows.append([centre - across * spread * 0.5, centre + across * spread * 0.5, float(index) / float(profile.size() - 1)])
	for index: int in range(rows.size() - 1):
		var a: Array = rows[index] as Array
		var b: Array = rows[index + 1] as Array
		var verts: Array[Vector3] = [a[0] as Vector3, a[1] as Vector3, b[1] as Vector3, a[0] as Vector3, b[1] as Vector3, b[0] as Vector3]
		var uvs: Array[Vector2] = [Vector2(0, float(a[2])), Vector2(1, float(a[2])), Vector2(1, float(b[2])), Vector2(0, float(a[2])), Vector2(1, float(b[2])), Vector2(0, float(b[2]))]
		for k: int in range(6):
			tool.set_uv(uvs[k])
			tool.add_vertex(verts[k])
	var sheet: MeshInstance3D = MeshInstance3D.new()
	sheet.name = "Sheet"
	sheet.mesh = tool.commit()
	sheet.material_override = fall_material()
	sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_never(sheet)
	root.add_child(sheet)
	# the foam pool where it lands
	var landing: Vector3 = (rows[rows.size() - 1][0] as Vector3).lerp(rows[rows.size() - 1][1] as Vector3, 0.5)
	var foam: MeshInstance3D = MeshInstance3D.new()
	foam.name = "Foam"
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = width * 0.8
	disc.bottom_radius = width * 0.8
	disc.height = 0.04
	disc.radial_segments = 12
	foam.mesh = disc
	if _foam == null:
		_foam = StandardMaterial3D.new()
		_foam.albedo_color = Color(0.95, 1.0, 1.0, 0.65)
		_foam.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_foam.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	foam.material_override = _foam
	foam.position = Vector3(landing.x, landing_y + 0.08, landing.z)
	foam.scale = Vector3(1.0, 1.0, 0.7)
	foam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_never(foam)
	root.add_child(foam)
	root.add_child(mist(Vector3(landing.x, landing_y + 0.2, landing.z), width * 0.45, 8))
	return root


## Puffs of mist drifting up from `pos` (a waterfall's foot, the ravine's bends).
static func mist(pos: Vector3, spread: float, amount: int) -> CPUParticles3D:
	var puffs: CPUParticles3D = CPUParticles3D.new()
	puffs.name = "Mist"
	puffs.amount = amount
	puffs.lifetime = 2.2
	puffs.preprocess = 2.2
	puffs.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	puffs.emission_box_extents = Vector3(spread, 0.1, spread * 0.6)
	puffs.direction = Vector3.UP
	puffs.spread = 30.0
	puffs.initial_velocity_min = 0.5
	puffs.initial_velocity_max = 1.1
	puffs.gravity = Vector3(0, -0.15, 0)
	puffs.scale_amount_min = 0.8
	puffs.scale_amount_max = 1.7
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.45
	puff.height = 0.9
	puff.radial_segments = 6
	puff.rings = 3
	puffs.mesh = puff
	if _mist == null:
		_mist = HeapMaterials.translucent(Color(0.9, 0.98, 1.0), 0.32, 0.2)
	puffs.material_override = _mist
	puffs.position = pos
	_never(puffs)
	return puffs
