class_name IconSign
extends RefCounted
## G-03 (Art Bible): no readable text in the world. A sign board, poster or prop front carries one pictogram from the icon set; the old words are read by
## using the sign (the zone scenes add a hidden "sign" spot that shows them as a dialogue). Shared by every hub builder.

const NODE_NAME: String = "SignIcon"
const FALLBACK: String = "ICON-MAP-QUEST"


## An unshaded icon quad facing +z (no toon conversion, no shadow), named `SignIcon`.
static func picture(size: Vector2, icon_id: String, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = NODE_NAME
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	node.mesh = quad
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = IconArt.texture(resolve(icon_id), 128.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.set_meta(StyleToon.META_NO_TOON, true)
	node.material_override = material
	node.set_meta(StyleToon.META_NO_TOON, true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.position = pos
	return node


## Adds a pictogram to `parent` (helper for prop fronts that used to carry a Label3D).
static func attach(parent: Node3D, icon_id: String, pos: Vector3, size: float) -> MeshInstance3D:
	var node: MeshInstance3D = picture(Vector2(size, size), icon_id, pos)
	parent.add_child(node)
	return node


## The icon a sign key shows: the zone's own map first, then `FALLBACK`. Unknown icon ids fall back too.
static func icon_for(key: String, icons: Dictionary) -> String:
	return resolve(str(icons.get(key, FALLBACK)))


static func resolve(icon_id: String) -> String:
	return icon_id if IconArt.has(icon_id) else FALLBACK


## The board size the old sign styles get now that they hold one square picture instead of lines of text.
static func board_size(style: String, size: float) -> Vector2:
	match style:
		"memo":
			return Vector2(1.0, 1.0)
		"poster":
			return Vector2(1.7, 1.9)
		"menu":
			return Vector2(1.6, 1.6)
	return Vector2(1.5, 1.5) * size
