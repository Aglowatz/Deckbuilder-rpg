class_name GainlandsWater
extends RefCounted
## Gainlands v2, Part B: waterfalls pouring over the sandstone rims into the canyons and the sea (docs/art/gainlands_v2.md). A fall is one curved strip of the
## scrolling-water shader from the lip down to the water, a pale pool of foam where it lands and a few puffs of mist. Views only: nothing here blocks.

const SHADER_PATH: String = "res://world/gainlands/gainlands_waterfall.gdshader"
const WATER_Y: float = -0.3

static var _material: ShaderMaterial
static var _foam: StandardMaterial3D


static func _fall_material() -> ShaderMaterial:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = load(SHADER_PATH) as Shader
	return _material


## A waterfall whose lip is centred at `top` (on a cliff edge), `width` wide, falling away from the land along `outward` (xz) to the water.
static func waterfall(top: Vector3, width: float, outward: Vector2, node_name: String = "Waterfall") -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var out: Vector3 = Vector3(outward.x, 0.0, outward.y).normalized()
	var across: Vector3 = Vector3(-out.z, 0.0, out.x)
	var drop: float = top.y - WATER_Y
	# the curve of the sheet: it leaves the lip almost level and bends down, ending a body length out from the cliff's foot
	var profile: Array[Vector2] = [Vector2(-0.3, 0.05), Vector2(0.35, -0.12), Vector2(0.8, -0.4), Vector2(1.15, -0.75), Vector2(1.45, -1.0)]
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
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
			surface.set_uv(uvs[k])
			surface.add_vertex(verts[k])
	var sheet: MeshInstance3D = MeshInstance3D.new()
	sheet.name = "Sheet"
	sheet.mesh = surface.commit()
	sheet.material_override = _fall_material()
	sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sheet.set_meta(&"no_occlusion_fade", true)
	sheet.set_meta(&"no_range_cull", true)
	sheet.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(sheet)
	# the foam pool where it lands
	var landing: Vector3 = (rows[rows.size() - 1][0] as Vector3).lerp(rows[rows.size() - 1][1] as Vector3, 0.5)
	var pool: MeshInstance3D = MeshInstance3D.new()
	pool.name = "Foam"
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = width * 0.9
	disc.bottom_radius = width * 0.9
	disc.height = 0.04
	disc.radial_segments = 12
	pool.mesh = disc
	if _foam == null:
		_foam = StandardMaterial3D.new()
		_foam.albedo_color = Color(0.95, 0.98, 1.0, 0.7)
		_foam.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_foam.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pool.material_override = _foam
	pool.position = Vector3(landing.x, WATER_Y + 0.08, landing.z)
	pool.scale = Vector3(1.0, 1.0, 0.7)
	pool.set_meta(&"no_occlusion_fade", true)
	pool.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(pool)
	var mist: CPUParticles3D = CPUParticles3D.new()
	mist.name = "Mist"
	mist.amount = 8
	mist.lifetime = 1.8
	mist.preprocess = 1.8
	mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	mist.emission_box_extents = Vector3(width * 0.4, 0.1, 0.4)
	mist.direction = Vector3.UP
	mist.spread = 30.0
	mist.initial_velocity_min = 0.6
	mist.initial_velocity_max = 1.2
	mist.gravity = Vector3(0, -0.2, 0)
	mist.scale_amount_min = 0.8
	mist.scale_amount_max = 1.6
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.45
	puff.height = 0.9
	puff.radial_segments = 6
	puff.rings = 3
	mist.mesh = puff
	mist.material_override = GainlandsMaterials.translucent(Color(0.92, 0.97, 1.0), 0.35, 0.2)
	mist.position = Vector3(landing.x, WATER_Y + 0.2, landing.z)
	mist.set_meta(&"no_occlusion_fade", true)
	root.add_child(mist)
	return root
