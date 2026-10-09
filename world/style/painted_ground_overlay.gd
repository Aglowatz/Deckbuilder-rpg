class_name PaintedGroundOverlay
extends RefCounted
## A painted ground laid just above the hex tiles of the walkable-area zones (Town, Starting Area): a grid of 1 m squares over the walkable ground (a square is kept only when all
## four corners and its centre are on the island, so it never hangs over water), drawn before the road decals so they stay on top. Used by `PaintedWorld`.

const CELL: float = 1.0


## `bounds` is the x/z rectangle to cover, `lift` the height above y = 0.
static func build(area: WalkableArea, bounds: Rect2, lift: float, material: Material, cover: Callable = Callable()) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	var x_start: int = int(floor(bounds.position.x))
	var z_start: int = int(floor(bounds.position.y))
	var x_end: int = int(ceil(bounds.end.x))
	var z_end: int = int(ceil(bounds.end.y))
	for iz: int in range(z_start, z_end):
		for ix: int in range(x_start, x_end):
			var x0: float = float(ix)
			var z0: float = float(iz)
			var inside: bool = true
			for point: Vector2 in [Vector2(0.5, 0.5), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
				var corner: Vector3 = Vector3(x0 + point.x * CELL, 0.0, z0 + point.y * CELL)
				if not (bool(cover.call(corner)) if cover.is_valid() else area.is_floor_at(corner)):
					inside = false
					break
			if not inside:
				continue
			var base: int = vertices.size()
			vertices.append(Vector3(x0, 0.0, z0))
			vertices.append(Vector3(x0 + CELL, 0.0, z0))
			vertices.append(Vector3(x0 + CELL, 0.0, z0 + CELL))
			vertices.append(Vector3(x0, 0.0, z0 + CELL))
			for i: int in range(4):
				normals.append(Vector3.UP)
				colors.append(Color.WHITE)
			indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	if vertices.is_empty():
		return null
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "PaintedGround"
	instance.mesh = mesh
	instance.material_override = material
	instance.position = Vector3(0.0, lift, 0.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	return instance
