class_name CliffSkirt
extends RefCounted
## Fix pass Nov 4 (B), Part 2.5: the Gainlands' natural cliff edge (GainlandsTerrain.rock / _walls) as a reusable strip for any zone. A ragged, layered
## rock face hangs from an open polyline (the lip) down to `bottom`: a lip, an upper face, a ledge, a lower face and a talus (the Gainlands' profile,
## scaled to the depth), each course jittered along the edge, coloured in strata bands that darken towards the bottom. The face points to the
## `side` of the line (+1 = left of the walking direction, -1 = right). Built with the shared StyleTerrain material, so the zone's painted preset
## puts its own "cliff" texture on it (PaintedContexts.terrain_meshes) and its palette comes from the `light` / `dark` strata colours.

## Course depths as fractions of the full drop, and how far each course leans out (metres) - the Gainlands' WALL_DROPS / WALL_PUSH shape.
const DROPS: Array[float] = [0.0, 0.11, 0.26, 0.32, 0.56, 1.0]
const PUSHES: Array[float] = [0.0, 0.3, 0.12, 0.8, 0.6, 1.3]
const PIECE: float = 1.8


static func wall(line: PackedVector2Array, top: float, bottom: float, side: float, node_name: String, light: Color, dark: Color, push_scale: float = 1.0) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var depth: float = maxf(top - bottom, 0.5)
	for i: int in range(line.size() - 1):
		var a: Vector2 = line[i]
		var b: Vector2 = line[i + 1]
		var length: float = a.distance_to(b)
		if length < 0.01:
			continue
		var dir: Vector2 = (b - a) / length
		var outward: Vector2 = Vector2(-dir.y, dir.x) * side
		var pieces: int = maxi(1, int(ceilf(length / PIECE)))
		for k: int in range(pieces):
			var columns: Array = []
			for end: int in range(2):
				var p: Vector2 = a.lerp(b, float(k + end) / float(pieces))
				var column: Array[Vector3] = []
				for layer: int in range(DROPS.size()):
					var jitter: float = (GainlandsTerrain._noise(p.x * 0.5 + float(layer) * 2.3, p.y * 0.5) - 0.5) * 0.9 if layer > 0 else 0.0
					var push: float = (PUSHES[layer] + jitter) * push_scale
					var drop: float = DROPS[layer] * depth + ((GainlandsTerrain._noise(p.y * 0.4, p.x * 0.4 + float(layer)) - 0.5) * 0.5 if layer > 0 and layer < DROPS.size() - 1 else 0.0)
					column.append(Vector3(p.x + outward.x * push, top - drop, p.y + outward.y * push))
				columns.append(column)
			var left: Array[Vector3] = columns[0] as Array[Vector3]
			var right: Array[Vector3] = columns[1] as Array[Vector3]
			for layer: int in range(DROPS.size() - 1):
				_face(surface, left[layer], right[layer], right[layer + 1], outward, top, depth, light, dark)
				_face(surface, left[layer], right[layer + 1], left[layer + 1], outward, top, depth, light, dark)
	surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = GainlandsMaterials.terrain()
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	instance.name = node_name
	instance.set_meta(&"no_range_cull", true)  # Fixes Nov 8: land and cliffs are never range-culled (Low-end's shorter range left black triangle holes in the faces)
	return instance


## Strata bands like the Gainlands' cliffs, fading into shadow towards the bottom of the drop.
static func strata(y: float, x: float, z: float, top: float, depth: float, light: Color, dark: Color) -> Color:
	var band: float = sin((y + GainlandsTerrain._noise(floorf(x * 0.3), floorf(z * 0.3)) * 0.6) * 3.4) * 0.5 + 0.5
	var color: Color = dark.lerp(light, band)
	var down: float = clampf((top - y) / depth, 0.0, 1.0)
	return color.lerp(Color(0.06, 0.06, 0.09), smoothstep(0.35, 1.0, down) * 0.8)


static func _face(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, outward: Vector2, top: float, depth: float, light: Color, dark: Color) -> void:
	var tri: Array[Vector3] = [a, b, c]
	var normal: Vector3 = (b - a).cross(c - a)
	if normal.x * outward.x + normal.z * outward.y < 0.0:
		tri = [a, c, b]
	for p: Vector3 in tri:
		surface.set_color(strata(p.y, p.x, p.z, top, depth, light, dark))
		surface.add_vertex(p)
