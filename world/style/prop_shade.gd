class_name PropShade
extends RefCounted
## Fable Nov 12c (Part C, item 1): a little ambient darkening at the base of every prop that stands on the ground - the cheapest "sits in
## the world" fix, standing in for SSAO (which costs too much on Medium). One MultiMesh of soft violet blobs per scene (one draw call),
## laid by a scan of the scene's prop-sized meshes: each blob lies under its prop, sized to the prop's footprint, a hand over the ground.
## Characters are left to `ContactShadow`; things that hang, fly or lie flat are skipped (the same rules as `PropGroundCheck`).
##
## Medium and High darken more than Low (which has no sun shadows to compete with). The scan runs a little after the scene has loaded and
## once more later (staged builds), from `StyleRig`.

const NAME: String = "PropShade"
const MAX_BLOBS: int = 700
## Prop-sized: bigger than a pebble, smaller than a building; at least knee high (a flat thing casts nothing).
const MIN_SIZE: float = 0.45
const MAX_SIZE: float = 6.0
const MIN_HEIGHT: float = 0.3
## How far a prop's underside may be from the ground and still count as standing on it.
const GROUND_GAP: float = 0.4
const LIFT: float = 0.045
const ALPHA: Array[float] = [0.24, 0.34, 0.34]

static var _texture: GradientTexture2D


## The footprints to shade under `root`: [{"pos": Vector3 (on the ground), "size": Vector2 (metres across x and z)}]. `height_at`
## (Vector3 -> float) is the scene's ground; without it a prop's own underside is taken as the ground when it is near y 0.
static func footprints(root: Node, height_at: Callable = Callable()) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	if root == null:
		return found
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null or not mesh.is_visible_in_tree() or mesh.name == NAME or mesh.name == ContactShadow.NAME:
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		var across: float = maxf(box.size.x, box.size.z)
		if across < MIN_SIZE or maxf(across, box.size.y) > MAX_SIZE or box.size.y < MIN_HEIGHT:
			continue
		if PropGroundCheck.skipped(mesh, root) or _has_own_shadow(mesh, root):
			continue
		var centre: Vector3 = box.get_center()
		var ground: float = float(height_at.call(centre)) if height_at.is_valid() else (box.position.y if absf(box.position.y) < GROUND_GAP else INF)
		if ground == INF or absf(box.position.y - ground) > GROUND_GAP:
			continue
		found.append({"pos": Vector3(centre.x, ground, centre.z), "size": Vector2(maxf(0.5, box.size.x * 0.8 + 0.25), maxf(0.5, box.size.z * 0.8 + 0.25))})
		if found.size() >= MAX_BLOBS:
			break
	return found


## A character (or anything that already carries a `ContactShadow`) keeps its own blob.
static func _has_own_shadow(mesh: Node, root: Node) -> bool:
	var node: Node = mesh
	var depth: int = 0
	while node != null and node != root and depth < 4:
		if node.has_node(ContactShadow.NAME) or node is WorldSprite:
			return true
		node = node.get_parent()
		depth += 1
	return false


## Lays (or relays) the blobs under `parent` for the props under `root`. Returns the MultiMesh node, null when nothing qualifies.
static func install(parent: Node, root: Node, height_at: Callable = Callable(), quality: int = 1) -> MultiMeshInstance3D:
	if parent == null:
		return null
	var old: Node = parent.get_node_or_null(NAME)
	if old != null:
		parent.remove_child(old)
		old.queue_free()
	var spots: Array[Dictionary] = footprints(root, height_at)
	if spots.is_empty():
		return null
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(1.0, 1.0)
	quad.orientation = PlaneMesh.FACE_Y
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = _blob_texture()
	material.albedo_color = Color(ContactShadow.COLOR.r, ContactShadow.COLOR.g, ContactShadow.COLOR.b, ALPHA[clampi(quality, 0, 2)])
	material.disable_receive_shadows = true
	material.render_priority = -1
	material.set_meta(StyleToon.META_NO_TOON, true)
	quad.material = material
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = quad
	multi.instance_count = spots.size()
	for index: int in range(spots.size()):
		var spot: Dictionary = spots[index]
		var size: Vector2 = spot["size"] as Vector2
		var at: Vector3 = (spot["pos"] as Vector3) + Vector3(0.0, LIFT + 0.0004 * float(index % 16), 0.0)
		multi.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3(size.x, 1.0, size.y)), at))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = NAME
	instance.multimesh = multi
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	parent.add_child(instance)
	return instance


static func _blob_texture() -> GradientTexture2D:
	if _texture == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.add_point(0.5, Color(1, 1, 1, 0.6))
		gradient.set_color(gradient.get_point_count() - 1, Color(1, 1, 1, 0))
		_texture = GradientTexture2D.new()
		_texture.gradient = gradient
		_texture.fill = GradientTexture2D.FILL_RADIAL
		_texture.fill_from = Vector2(0.5, 0.5)
		_texture.fill_to = Vector2(1.0, 0.5)
		_texture.width = 64
		_texture.height = 64
	return _texture


## The scene's ground function, when it has one: a zone's `builder.height_at`, the town's `town.height_at`.
static func ground_of(scene: Node) -> Callable:
	if scene == null:
		return Callable()
	for key: String in ["builder", "town", "area"]:
		if key in scene:
			var map: Variant = scene.get(key)
			if map is Object and (map as Object).has_method(&"height_at"):
				return func(p: Vector3) -> float: return float((map as Object).call(&"height_at", p))
	return Callable()
