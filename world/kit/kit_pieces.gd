class_name KitPieces
extends RefCounted
## Art import Oct 29 (art batches 5-9): the painted zone-kit pieces the zone builders place by hand - a standing cut-out (a hero prop, a giant
## tree, a sheet part: a camera-facing card whose base sits on the ground) and a flat decal (a poster on a wall, a hatch or a stain on the
## ground). Every call returns null and places nothing when the id is not imported, so a zone keeps its old look without the art.

## How far a wall decal stands off its wall, and a ground decal off the ground (no z-fighting at the far camera).
const WALL_GAP: float = 0.04
const GROUND_GAP: float = 0.045

static var _flat_materials: Dictionary = {}


## A standing painted piece `height` metres tall (its width from the art), base at `pos`. `shadow`: whether it casts one (big hero pieces
## standing against a cliff or wall usually should not). `brighten` above 1 lifts a landmark that must read in a dark mood (its own copy of the card material).
static func stand(parent: Node3D, id: String, pos: Vector3, height: float, shadow: bool = true, brighten: float = 1.0) -> Node3D:
	if not EnvKit.has(id) or not EnvKit.has_art(id):
		return null
	var piece: Node3D = ZoneClusters.card_prop(id, height, shadow)
	if piece == null:
		return null
	piece.name = "Kit_%s" % id
	if not is_equal_approx(brighten, 1.0):
		var body: MeshInstance3D = piece.get_node_or_null("Body") as MeshInstance3D
		if body != null and body.material_override is ShaderMaterial:
			var lifted: ShaderMaterial = (body.material_override as ShaderMaterial).duplicate() as ShaderMaterial
			var tint: Color = lifted.get_shader_parameter("mood_tint") as Color
			lifted.set_shader_parameter("mood_tint", Color(tint.r * brighten, tint.g * brighten, tint.b * brighten))
			lifted.set_shader_parameter("base_dark", 0.9)
			body.material_override = lifted
	parent.add_child(piece)
	piece.position = pos
	return piece


## A flat picture `width` metres wide on a wall: centred at `center`, facing `yaw_deg` (0 = facing +z, toward the default camera).
static func wall(parent: Node3D, id: String, center: Vector3, yaw_deg: float, width: float) -> MeshInstance3D:
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw_deg))
	return _flat(parent, id, center + basis * Vector3(0.0, 0.0, WALL_GAP), basis, width)


## A flat picture `width` metres across lying on the ground at `center` (its top edge toward -z turned by `yaw_deg`).
static func ground(parent: Node3D, id: String, center: Vector3, yaw_deg: float, width: float) -> MeshInstance3D:
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw_deg)) * Basis(Vector3.RIGHT, -PI * 0.5)
	return _flat(parent, id, center + Vector3(0.0, GROUND_GAP, 0.0), basis, width)


static func _flat(parent: Node3D, id: String, center: Vector3, basis: Basis, width: float) -> MeshInstance3D:
	if not EnvKit.has(id) or not EnvKit.has_art(id):
		return null
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(width, width / maxf(EnvKit.aspect(id), 0.01))
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Flat_%s" % id
	instance.mesh = quad
	instance.material_override = flat_material(id)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	parent.add_child(instance)
	instance.transform = Transform3D(basis, center)
	return instance


## The shared see-through material of a flat piece (one per id), drawn after the surface it lies on.
static func flat_material(id: String) -> StandardMaterial3D:
	if _flat_materials.has(id):
		return _flat_materials[id] as StandardMaterial3D
	var material: StandardMaterial3D = EnvKit.material(id, true).duplicate() as StandardMaterial3D
	material.render_priority = 4
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_flat_materials[id] = material
	return material
