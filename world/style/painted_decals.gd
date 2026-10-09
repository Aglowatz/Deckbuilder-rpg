class_name PaintedDecals
extends RefCounted
## Decal scatter tool (docs/art/style_guide.md, "Painted textures"): places the DEC- decals naturally on ground, roads and walls with random rotation, scale, tint and density
## per zone. One merged mesh per decal id (one draw call each), each quad tilted to the ground under it, lifted just above the surface, faded at the edges by the texture's own alpha.
## Entries come from the zone preset: {"id": "moss", "count": 14, "min": 0.8, "max": 1.6, "opacity": 0.7, "mask": "grass", "mask_min": 0.5, "avoid_mask": "road", "tint": "#ffffff",
## "tint_jitter": 0.1, "surface": "ground" | "wall"}. Pure placement is `place` (unit-testable, no scene).

const SHADER_PATH: String = "res://assets/shaders/style_painted_decal.gdshader"
const LIFT: float = 0.045

static var _shader: Shader


## One placed decal.
class Placement:
	var id: String = ""
	var position: Vector3 = Vector3.ZERO
	var normal: Vector3 = Vector3.UP
	var yaw: float = 0.0
	var radius: float = 1.0
	var color: Color = Color.WHITE


## Deterministic placements for `entries`. `context`: {"area": WalkableArea, "bounds": Rect2, "masks": {name: Callable(Vector2) -> float}, "avoid": Array[Vector3] (x, z, radius),
## "walls": Array[Dictionary] {"pos": Vector3, "normal": Vector3, "length": float, "height": float}, "height": Callable(Vector3) -> float (overrides area.height_at), "floor": Callable(Vector3) -> bool}.
static func place(entries: Array, context: Dictionary, seed_value: int, quality: int) -> Array[Placement]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var result: Array[Placement] = []
	var scale_by_quality: float = [0.4, 0.75, 1.0][clampi(quality, 0, 2)]
	var bounds: Rect2 = context.get("bounds", Rect2(-20, -20, 40, 40)) as Rect2
	var masks: Dictionary = context.get("masks", {}) as Dictionary
	var avoid: Array = context.get("avoid", []) as Array
	var area: WalkableArea = context.get("area") as WalkableArea
	var height_call: Callable = context.get("height", Callable()) as Callable
	var floor_call: Callable = context.get("floor", Callable()) as Callable
	var walls: Array = context.get("walls", []) as Array
	for entry_variant: Variant in entries:
		var entry: Dictionary = entry_variant as Dictionary
		var count: int = int(round(float(entry.get("count", 8)) * scale_by_quality))
		var surface: String = str(entry.get("surface", "ground"))
		var made: int = 0
		var tries: int = 0
		var radius_min: float = float(entry.get("min", 0.6))
		var radius_max: float = float(entry.get("max", 1.4))
		var base_color: Color = PaintedLibrary.color_of(entry.get("tint", "#ffffff"))
		var opacity: float = float(entry.get("opacity", 0.85))
		var jitter: float = float(entry.get("tint_jitter", 0.08))
		while made < count and tries < count * 20 + 20:
			tries += 1
			var placement: Placement = Placement.new()
			placement.id = str(entry["id"])
			placement.radius = rng.randf_range(radius_min, radius_max)
			if surface == "wall":
				if walls.is_empty():
					break
				var wall: Dictionary = walls[rng.randi() % walls.size()] as Dictionary
				var along: Vector3 = (wall["normal"] as Vector3).cross(Vector3.UP).normalized()
				var span: float = maxf(float(wall.get("length", 2.0)) * 0.5 - placement.radius * 0.5, 0.0)
				placement.position = (wall["pos"] as Vector3) + along * rng.randf_range(-span, span) + Vector3.UP * rng.randf_range(0.4, maxf(float(wall.get("height", 2.0)) - 0.4, 0.5)) + (wall["normal"] as Vector3) * 0.03
				placement.normal = wall["normal"] as Vector3
			else:
				var flat: Vector2 = Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
				var pos: Vector3 = Vector3(flat.x, 0.0, flat.y)
				if floor_call.is_valid():
					if not bool(floor_call.call(pos)):
						continue
				elif area != null and not area.is_floor_at(pos):
					continue
				if entry.has("mask") and masks.has(str(entry["mask"])) and float((masks[str(entry["mask"])] as Callable).call(flat)) < float(entry.get("mask_min", 0.5)):
					continue
				if entry.has("avoid_mask") and masks.has(str(entry["avoid_mask"])) and float((masks[str(entry["avoid_mask"])] as Callable).call(flat)) > 0.3:
					continue
				if _avoided(flat, placement.radius, avoid):
					continue
				pos.y = _height(pos, height_call, area)
				placement.position = pos + Vector3.UP * LIFT
				placement.normal = _ground_normal(pos, placement.radius, height_call, area)
				placement.position.y += float(made % 7) * 0.0012
			placement.yaw = rng.randf() * TAU
			var shade: float = 1.0 + rng.randf_range(-jitter, jitter)
			placement.color = Color(clampf(base_color.r * shade, 0.0, 2.0), clampf(base_color.g * shade, 0.0, 2.0), clampf(base_color.b * shade, 0.0, 2.0), opacity * rng.randf_range(0.8, 1.0))
			result.append(placement)
			made += 1
	return result


static func _avoided(flat: Vector2, radius: float, avoid: Array) -> bool:
	for item: Variant in avoid:
		var circle: Vector3 = item as Vector3
		if flat.distance_to(Vector2(circle.x, circle.y)) < circle.z + radius * 0.5:
			return true
	return false


static func _ground_normal(pos: Vector3, radius: float, height_call: Callable, area: WalkableArea) -> Vector3:
	var step: float = maxf(radius * 0.6, 0.4)
	var hx0: float = _height(pos + Vector3(-step, 0, 0), height_call, area)
	var hx1: float = _height(pos + Vector3(step, 0, 0), height_call, area)
	var hz0: float = _height(pos + Vector3(0, 0, -step), height_call, area)
	var hz1: float = _height(pos + Vector3(0, 0, step), height_call, area)
	return Vector3(hx0 - hx1, 2.0 * step, hz0 - hz1).normalized()


static func _height(pos: Vector3, height_call: Callable, area: WalkableArea) -> float:
	if height_call.is_valid():
		return float(height_call.call(pos))
	return area.height_at(pos) if area != null else 0.0


## Builds the merged meshes under `parent` (one MeshInstance3D per decal id) and returns them.
static func build(parent: Node3D, placements: Array[Placement], priority: int = 5) -> Array[MeshInstance3D]:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var by_id: Dictionary = {}
	for placement: Placement in placements:
		if not by_id.has(placement.id):
			by_id[placement.id] = [] as Array[Placement]
		(by_id[placement.id] as Array[Placement]).append(placement)
	var meshes: Array[MeshInstance3D] = []
	for id: String in by_id.keys():
		var texture: Texture2D = PaintedLibrary.decal(id)
		if texture == null:
			continue
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for placement: Placement in by_id[id] as Array[Placement]:
			var up: Vector3 = placement.normal
			var side: Vector3 = up.cross(Vector3.FORWARD if absf(up.dot(Vector3.FORWARD)) < 0.95 else Vector3.RIGHT).normalized()
			var front: Vector3 = side.cross(up).normalized()
			var spin: Basis = Basis(up, placement.yaw)
			side = spin * side
			front = spin * front
			var r: float = placement.radius
			var corners: Array[Vector3] = [
				placement.position + (-side - front) * r, placement.position + (side - front) * r,
				placement.position + (side + front) * r, placement.position + (-side + front) * r,
			]
			var uvs: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
			for index: int in [0, 1, 2, 0, 2, 3]:
				surface.set_color(placement.color)
				surface.set_normal(up)
				surface.set_uv(uvs[index])
				surface.add_vertex(corners[index])
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = _shader
		material.set_shader_parameter("decal_tex", texture)
		material.render_priority = priority
		if id in ["ectoplasm", "rift"]:
			material.set_shader_parameter("glow", 0.35)
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = "Decals_%s" % id
		instance.mesh = surface.commit()
		instance.material_override = material
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta(StyleToon.META_NO_TOON, true)
		instance.set_meta(&"painted_decal", true)
		parent.add_child(instance)
		meshes.append(instance)
	return meshes
