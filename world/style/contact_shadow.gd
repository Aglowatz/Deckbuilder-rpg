class_name ContactShadow
extends RefCounted
## A soft dark blob under a character or prop (docs/art/graphics_loop.md, G-02/G-12): grounds them on uneven or shadowless surfaces and keeps small figures
## readable from the high camera. One cached material, one quad per character, tinted violet (never pure black).

const NAME: String = "ContactShadow"
const COLOR: Color = Color(0.1, 0.05, 0.18, 0.42)

static var _material: StandardMaterial3D
static var _mesh: QuadMesh


static func _shared_material() -> StandardMaterial3D:
	if _material == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.add_point(0.55, Color(1, 1, 1, 0.55))
		gradient.set_color(gradient.get_point_count() - 1, Color(1, 1, 1, 0))
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 64
		texture.height = 64
		_material = StandardMaterial3D.new()
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.albedo_texture = texture
		_material.albedo_color = COLOR
		_material.disable_receive_shadows = true
		_material.set_meta(StyleToon.META_NO_TOON, true)
	return _material


## Adds the blob under `character` (radius in metres, in the character's local units); returns it. Safe to call twice.
static func attach(character: Node3D, radius: float = 0.55) -> MeshInstance3D:
	var existing: Node = character.get_node_or_null(NAME)
	if existing != null:
		return existing as MeshInstance3D
	if _mesh == null:
		_mesh = QuadMesh.new()
		_mesh.size = Vector2(2.0, 2.0)
		_mesh.orientation = PlaneMesh.FACE_Y
		_mesh.material = _shared_material()
	var blob: MeshInstance3D = MeshInstance3D.new()
	blob.name = NAME
	blob.mesh = _mesh
	blob.scale = Vector3(radius, 1.0, radius)
	blob.position = Vector3(0.0, 0.035, 0.0)
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	blob.set_meta(StyleToon.META_NO_TOON, true)
	character.add_child(blob)
	return blob
