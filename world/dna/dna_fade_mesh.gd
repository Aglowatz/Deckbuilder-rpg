class_name DnaFadeMesh
extends RefCounted
## A merged mesh of many small solid pieces (the D.N.A.'s filing cabinets and cubicle partitions) that fade out one by one when they stand between the camera and the
## hero (`world/dna/dna_fade.gdshader`). One SurfaceTool per material slot; every vertex carries its piece's centre, half width and top in CUSTOM0 so the shader can
## test each piece on its own. UVs are planar in metres (the kit surfaces tile by their `tile` size), vertex colours carry a tint and baked ambient occlusion.
## Build with `box(slot, piece, center, size)` calls (`piece` = the piece's footprint centre x, z, half width and top y, shared by all the boxes of one cabinet), then
## `instance()`.

var _tools: Dictionary = {}
var _materials: Dictionary = {}
var _triangles: int = 0

static var _shader: Shader


## A slot drawn with a kit surface (`texture_id`, tiled in metres) or a flat colour (empty id), multiplied by `tint`. Oct 19: `alpha` under 1 makes frosted glass,
## `emission` lights the slot (the fluorescent tubes), `near_reach` widens the cut-away for pieces near the lens (full-height walls).
func set_slot(slot: String, texture_id: String, tint: Color = Color.WHITE, alpha: float = 1.0, emission: float = 0.0, near_reach: float = 0.0, tile: float = 0.0) -> void:
	if _shader == null:
		_shader = load("res://world/dna/dna_fade.gdshader") as Shader
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = _shader
	var texture: Texture2D = EnvKit.texture(texture_id) if texture_id != "" and EnvKit.has(texture_id) else null
	material.set_shader_parameter("use_texture", texture != null)
	if texture != null:
		material.set_shader_parameter("albedo_tex", texture)
		material.set_shader_parameter("tile", tile if tile > 0.0 else maxf(EnvKit.tile_size(texture_id), 0.5))
	material.set_shader_parameter("albedo", tint)
	material.set_shader_parameter("base_alpha", alpha)
	material.set_shader_parameter("emission_strength", emission)
	material.set_shader_parameter("near_reach", near_reach)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	_materials[slot] = material
	DnaMaterials.register_fade_material(material)


func has_slot(slot: String) -> bool:
	return _materials.has(slot)


func triangle_count() -> int:
	return _triangles


func _tool(slot: String) -> SurfaceTool:
	if not _tools.has(slot):
		var tool: SurfaceTool = SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		tool.set_custom_format(0, SurfaceTool.CUSTOM_RGBA_FLOAT)
		tool.set_custom_format(1, SurfaceTool.CUSTOM_RGBA_FLOAT)
		_tools[slot] = tool
	return _tools[slot] as SurfaceTool


## A box of `size` round `center` belonging to `piece` (Vector4: centre x, centre z, half width, top y). `ao` darkens the bottom (1 = off); `tint` multiplies the slot colour.
## `bottom` (Oct 19) is the piece's underside: 0 for anything standing on the floor, the height of a ceiling beam's underside for hanging pieces (the fade test
## checks whether the piece's span covers the sight line).
func box(slot: String, piece: Vector4, center: Vector3, size: Vector3, tint: Color = Color.WHITE, ao: float = 1.0, bottom: float = 0.0) -> void:
	var tool: SurfaceTool = _tool(slot)
	var half: Vector3 = size * 0.5
	for axis: int in range(3):
		for sign_value: int in [-1, 1]:
			var normal: Vector3 = Vector3.ZERO
			normal[axis] = float(sign_value)
			var u_axis: int = (axis + 1) % 3
			var v_axis: int = (axis + 2) % 3
			var pts: Array[Vector3] = []
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				var local: Vector3 = Vector3.ZERO
				local[axis] = half[axis] * float(sign_value)
				local[u_axis] = half[u_axis] * corner.x
				local[v_axis] = half[v_axis] * corner.y
				pts.append(center + local)
			# the quad's outward side must be the front: order the corners so the winding faces `normal`
			var d: Vector3 = (pts[1] - pts[0]).cross(pts[2] - pts[0])
			if d.dot(normal) < 0.0:
				pts = [pts[0], pts[3], pts[2], pts[1]]
			for tri: Array in [[0, 1, 2], [0, 2, 3]]:
				# Godot wants clockwise front faces: emit reversed
				for k: int in [2, 1, 0]:
					var p: Vector3 = pts[tri[k]]
					var t: float = clampf((p.y - (center.y - half.y)) / maxf(size.y, 0.001), 0.0, 1.0)
					var shade: float = lerpf(ao, 1.0, minf(t * 2.5, 1.0))
					tool.set_normal(normal)
					tool.set_uv(KitMesh.planar_uv(p, normal))
					tool.set_color(Color(tint.r * shade, tint.g * shade, tint.b * shade, 1.0))
					tool.set_custom(0, Color(piece.x, piece.y, piece.z, piece.w))
					tool.set_custom(1, Color(bottom, 0.0, 0.0, 0.0))
					tool.add_vertex(p)
			_triangles += 2


func build() -> ArrayMesh:
	var mesh: ArrayMesh = ArrayMesh.new()
	for slot: String in _tools.keys():
		var tool: SurfaceTool = _tools[slot] as SurfaceTool
		var part: ArrayMesh = tool.commit()
		if part.get_surface_count() == 0:
			continue
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, part.surface_get_arrays(0), [], {}, part.surface_get_format(0))
		mesh.surface_set_material(mesh.get_surface_count() - 1, _materials.get(slot) as Material)
	return mesh


func instance(node_name: String = "FadeMesh") -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = build()
	mesh_instance.name = node_name
	mesh_instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	mesh_instance.set_meta(StyleToon.META_NO_TOON, true)
	mesh_instance.set_meta(&"no_occlusion_fade", true)  # each piece fades itself in the shader
	return mesh_instance
