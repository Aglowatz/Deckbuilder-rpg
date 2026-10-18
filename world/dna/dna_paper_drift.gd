class_name DnaPaperDrift
extends RefCounted
## Overnight Oct 17 (Phase 2 cycle 18): the D.N.A. stands on a bare grey apron, and every view was a third empty ground. Loose sheets of paperwork
## now drift and tumble over it round the offices - never over a floor cell or within MARGIN cells of one, so they stay out of rooms and walls (one
## MultiMesh, a vertex shader does the motion, no shadows), fading into the zone's fog with distance.

const COUNT: int = 380
const AREA_MIN: Vector2 = Vector2(-24.0, -22.0)
const AREA_MAX: Vector2 = Vector2(120.0, 92.0)
## Height above the apron (it lies at y = 0).
const DEPTH: Vector2 = Vector2(0.3, 3.5)
const MARGIN: int = 3
const SHADER_PATH: String = "res://world/dna/dna_paper_drift.gdshader"


static func build(parent: Node3D, layout: DnaLayout, count: int = COUNT) -> MultiMeshInstance3D:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7341
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.42, 0.56)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHADER_PATH) as Shader
	quad.material = material
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = quad
	var spots: Array[Vector3] = positions(layout, count, rng)
	multimesh.instance_count = spots.size()
	for index: int in range(spots.size()):
		var pos: Vector3 = spots[index]
		var basis: Basis = Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.8, 1.35))
		multimesh.set_instance_transform(index, Transform3D(basis, pos))
		multimesh.set_instance_custom_data(index, Color(rng.randf(), rng.randf_range(0.15, 0.55), rng.randf() * TAU, rng.randf_range(0.15, 0.6)))
	var field: MultiMeshInstance3D = MultiMeshInstance3D.new()
	field.name = "PaperDrift"
	field.multimesh = multimesh
	field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	field.set_meta(&"no_range_cull", true)
	field.set_meta(&"no_occlusion_fade", true)
	field.set_meta(PaintedClasses.META_NO_PAINT, true)
	# the whole field's box: the sheets move inside it, never cull it by its centre
	field.custom_aabb = AABB(Vector3(AREA_MIN.x, DEPTH.x - 1.0, AREA_MIN.y), Vector3(AREA_MAX.x - AREA_MIN.x, DEPTH.y - DEPTH.x + 2.0, AREA_MAX.y - AREA_MIN.y))
	parent.add_child(field)
	return field


## Where the sheets float: random spots over the apron, none near a floor or the causeway.
static func positions(layout: DnaLayout, count: int, rng: RandomNumberGenerator) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var guard: int = 0
	while result.size() < count and guard < count * 20:
		guard += 1
		var candidate: Vector3 = Vector3(rng.randf_range(AREA_MIN.x, AREA_MAX.x), rng.randf_range(DEPTH.x, DEPTH.y), rng.randf_range(AREA_MIN.y, AREA_MAX.y))
		if layout != null and near_floor(layout, candidate):
			continue
		result.append(candidate)
	return result


## True when a floor cell lies within MARGIN cells of `pos`, or the approach causeway within 4 m.
static func near_floor(layout: DnaLayout, pos: Vector3) -> bool:
	# the approach causeway is walked but is not a floor cell: keep its sides clear too
	for side: float in [-4.0, 0.0, 4.0]:
		for ahead: float in [-4.0, 0.0, 4.0]:
			if DnaLayout.on_approach(pos.x + side, pos.z + ahead):
				return true
	var cell: Vector2i = DnaLayout.world_to_cell(pos)
	for dz: int in range(-MARGIN, MARGIN + 1):
		for dx: int in range(-MARGIN, MARGIN + 1):
			if layout.in_bounds(cell.x + dx, cell.y + dz) and layout.is_floor(cell.x + dx, cell.y + dz):
				return true
	return false
