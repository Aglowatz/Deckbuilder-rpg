class_name WorldScenery
extends Node3D
## Water, far shore and distant scenery of the World Look Test (docs/art/world_look_test.md):
##  - the town hex water tiles get the painted TEX-TOWN-WATER material, a huge plane of the same water runs to the horizon (no water edge anywhere), and DEC-SHOREFOAM cards
##    lap along every shoreline (hex tiles and the far shore);
##  - a far shore of grass, then painted rings: BD-NEAR-TREELINE, BD-MID-HILLS, BD-FAR-MOUNTAINS at growing distances, each hazier and cooler than the one in front;
##  - the five BD-LANDMARK cards stand between the hills and the mountains in the real directions of their zone passageways;
##  - the hex wall of rocky mountains behind the town and the old 3D clouds are hidden here (the painted layers replace them).

const WATER_SHADER: String = "res://world/look/world_water.gdshader"
const BACKDROP_SHADER: String = "res://world/look/world_backdrop.gdshader"
const FOAM_SHADER: String = "res://world/look/world_shorefoam.gdshader"
const FOAM_RING_SHADER: String = "res://world/look/world_shorering.gdshader"
const LAND_SHADER: String = "res://world/look/world_land.gdshader"
const ART: String = "res://assets/art/world_test/"
const WATER_Y: float = -0.36
## The middle of the whole town including its zone islands (metres); every ring is centred here.
const SHORE_INNER: float = 128.0
const SHORE_OUTER: float = 165.0
## Ring layers, nearest first: file, radius, height (m), base y, haze, cool, render priority.
const RINGS: Array[Dictionary] = [
	{"file": "near_treeline", "radius": 146.0, "height": 9.5, "base": 0.0, "haze": 0.1, "cool": 0.05, "base_haze": 0.0, "priority": -6},
	{"file": "mid_hills", "radius": 215.0, "height": 17.0, "base": -0.4, "haze": 0.38, "cool": 0.28, "base_haze": 0.4, "priority": -7},
	{"file": "far_mountains", "radius": 375.0, "height": 36.0, "base": -0.4, "haze": 0.58, "cool": 0.5, "base_haze": 0.45, "priority": -9},
]
const LANDMARK_RADIUS: float = 275.0
## Landmark file, zone id whose passageway it lies beyond, angular width in degrees.
const LANDMARKS: Array[Dictionary] = [
	{"file": "gainlands", "zone": "beefcake", "width": 21.0},
	{"file": "dna", "zone": "necrocrat", "width": 19.0},
	{"file": "buffet", "zone": "gourmand", "width": 17.0},
	{"file": "dump", "zone": "refusemancer", "width": 17.0},
	{"file": "capital", "zone": "final", "width": 19.0},
]
const HEX_STEP: float = 3.6

## The middle every ring is centred on (the town: the whole town including its zone islands; a zone: the middle of its map).
var center: Vector3 = Vector3(25.2, 0.0, 26.0)
var camera: Camera3D
var water_material: ShaderMaterial
var _town: TownBuilder
var _backdrops: Array[ShaderMaterial] = []
## One entry per backdrop material: {"material", "haze", "cool", "base_haze"} (the design values; a mood scales them).
var _backdrop_entries: Array[Dictionary] = []
var _scale: float = 1.0
var _mood: Dictionary = {}
## The Capital island's ring of white wall prisms and castle block looked bare from behind in the test and were hidden; the game keeps them (docs/art/world_rollout.md).
var hide_capital_blocks: bool = false
var _haze: Color = Color("f2cfa4")
var _foam_cards: int = 0
var _water_tiles: int = 0


func setup(_scene: TownScene, town: TownBuilder, cam: Camera3D) -> void:
	camera = cam
	_town = town
	_build_water_material()
	_replace_tile_water()
	_hide_old_scenery()
	_build_water_plane()
	_build_far_shore()
	for ring: Dictionary in RINGS:
		_build_ring(ring)
	_build_landmarks()
	print("world_look: scenery built (%d water tiles, %d shore foam cards)" % [_water_tiles, _foam_cards])


# ---- Water -------------------------------------------------------------------------------------------------------------------------


func _build_water_material() -> void:
	water_material = ShaderMaterial.new()
	water_material.shader = load(WATER_SHADER) as Shader
	water_material.set_shader_parameter("water_tex", load(ART + "tex/town_water.png"))


## The hex water tiles keep their geometry (the shorelines hug the land tiles) but get the painted water; their positions give the coastline for the foam cards.
func _replace_tile_water() -> void:
	var shared: ShaderMaterial = StyleWater.material()
	var centres: Dictionary = {}
	for node: Node in _town.root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.material_override != shared:
			continue
		# The tiles stay for their geometry but are not drawn: one plane of water runs everywhere (no tile seams or outlines).
		mesh_instance.visible = false
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		var c: Vector3 = box.get_center()
		centres[_key(c)] = Vector3(c.x, WATER_Y, c.z)
		_water_tiles += 1
	_build_shore_foam(centres)


func _key(p: Vector3) -> Vector2i:
	return Vector2i(roundi(p.x * 2.0), roundi(p.z * 2.0))


## True when hex position `p` is land: inside the town's water grid but not water, or on a zone island.
func _is_land(p: Vector3, water: Dictionary, islands: Array[Vector3]) -> bool:
	if water.has(_key(p)):
		return false
	var cell: Vector2i = HexGrid.world_to_cell(p / TownBuilder.SCALE)
	var rows: int = TownBuilder.MAP.size()
	var cols: int = TownBuilder.MAP[0].length()
	var inside: bool = cell.y >= -TownBuilder.ROW_OFFSET - TownBuilder.WATER_PAD and cell.y < rows - TownBuilder.ROW_OFFSET + TownBuilder.WATER_PAD and cell.x >= -TownBuilder.COL_OFFSET - TownBuilder.WATER_PAD and cell.x < cols - TownBuilder.COL_OFFSET + TownBuilder.WATER_PAD
	if inside:
		return true
	for island: Vector3 in islands:
		if Vector2(p.x - island.x, p.z - island.z).length() < TownConnectors.ISLAND_REACH * TownBuilder.SCALE + 1.2:
			return true
	return false


func _island_centres() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		var cell: Vector2i = TownBuilder.PORTAL_CELLS[zone_id] as Vector2i
		var plan: Dictionary = TownConnectors.plan(_town.cell_center(cell.x, cell.y), TownBuilder.PORTAL_OUT[zone_id] as Vector3)
		result.append(plan["center"] as Vector3)
	return result


func _build_shore_foam(water: Dictionary) -> void:
	var islands: Array[Vector3] = _island_centres()
	var transforms: Array[Transform3D] = []
	var phases: Array[float] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 21
	for key: Variant in water.keys():
		var w: Vector3 = water[key] as Vector3
		for i: int in range(6):
			var angle: float = deg_to_rad(float(i) * 60.0)
			var n: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
			var land: Vector3 = w + n * HEX_STEP
			if not _is_land(land, water, islands):
				continue
			var middle: Vector3 = w + n * (HEX_STEP * 0.5)
			var tangent: Vector3 = Vector3.UP.cross(n).normalized()
			var basis: Basis = Basis(tangent, Vector3.UP, n)
			var origin: Vector3 = middle - n * 0.32 + Vector3(0.0, 0.03, 0.0)
			transforms.append(Transform3D(basis, origin))
			phases.append(rng.randf())
	_add_foam_multimesh(transforms, phases, Vector2(3.5, 1.7))


func _add_foam_multimesh(transforms: Array[Transform3D], phases: Array[float], size: Vector2) -> void:
	if transforms.is_empty():
		return
	var quad: QuadMesh = QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	quad.size = size
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(FOAM_SHADER) as Shader
	material.set_shader_parameter("tex", load(ART + "dec/shorefoam.png"))
	material.render_priority = 1
	quad.material = material
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = quad
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
		multimesh.set_instance_custom_data(index, Color(phases[index], 0.0, 0.0, 0.0))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 20.0
	add_child(instance)
	_foam_cards += transforms.size()


func _build_water_plane() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(1600.0, 1600.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "WaterPlane"
	instance.set_meta(&"look_role", &"water")
	instance.mesh = plane
	instance.material_override = water_material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.position = Vector3(center.x, WATER_Y, center.z)
	instance.extra_cull_margin = 400.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	add_child(instance)


# ---- Far shore and rings -----------------------------------------------------------------------------------------------------------


func _hide_old_scenery() -> void:
	for cloud: Node3D in _town.clouds:
		cloud.visible = false
	var west_edge: int = -TownBuilder.COL_OFFSET
	var east_edge: int = TownBuilder.MAP[0].length() - TownBuilder.COL_OFFSET
	var far_row: int = -TownBuilder.ROW_OFFSET - 2
	var spots: Array[Vector3] = []
	for col: int in range(west_edge - 2, east_edge + 3):
		spots.append(_town.cell_center(col, far_row))
	for cell: Vector2i in [Vector2i(west_edge - 2, 1), Vector2i(west_edge - 2, 6), Vector2i(west_edge - 2, 11), Vector2i(east_edge + 2, 2), Vector2i(east_edge + 2, 7), Vector2i(east_edge + 2, 0)]:
		spots.append(_town.cell_center(cell.x, cell.y))
	var hidden: int = 0
	for child: Node in _town.root.get_children():
		var node: Node3D = child as Node3D
		if node == null:
			continue
		for spot: Vector3 in spots:
			if Vector2(node.position.x - spot.x, node.position.z - spot.z).length() < 0.4:
				node.visible = false
				hidden += 1
				break
	print("world_look: hid %d pieces of the old hex wall / hills" % hidden)
	# The Capital island: the ring of bare white wall prisms and the plain castle block looked unfinished from the north and from behind. The gate towers, flags,
	# bridge and island stay; the painted Capital card stands far beyond (see _build_landmarks).
	var capital: Node3D = _town.root.get_node_or_null("Connector_final") as Node3D
	if capital != null and hide_capital_blocks:
		for child: Node in capital.get_children():
			if child.name.begins_with("WhiteWalls") or child.name.begins_with("building_castle"):
				(child as Node3D).visible = false


func _build_far_shore() -> void:
	var land_mesh: ArrayMesh = _annulus(SHORE_INNER * _scale, SHORE_OUTER * _scale, 0.0, 160, 1.0)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(LAND_SHADER) as Shader
	material.set_shader_parameter("grass_tex", load("res://assets/art/textures/town_grass_albedo.webp"))
	material.set_shader_parameter("sand_tex", load("res://assets/art/textures/town_sand_albedo.webp"))
	var land: MeshInstance3D = MeshInstance3D.new()
	land.name = "FarShore"
	land.set_meta(&"look_role", &"shore")
	land.mesh = land_mesh
	land.material_override = material
	land.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	land.extra_cull_margin = 400.0
	land.set_meta(StyleToon.META_NO_TOON, true)
	add_child(land)
	# Foam ring along the water side of the shore.
	var foam_mesh: ArrayMesh = _annulus(SHORE_INNER * _scale - 3.4, SHORE_INNER * _scale + 1.0, WATER_Y + 0.04, 160, 90.0)
	var foam_material: ShaderMaterial = ShaderMaterial.new()
	foam_material.shader = load(FOAM_RING_SHADER) as Shader
	foam_material.set_shader_parameter("tex", load(ART + "dec/shorefoam.png"))
	foam_material.render_priority = 1
	var foam: MeshInstance3D = MeshInstance3D.new()
	foam.name = "FarShoreFoam"
	foam.set_meta(&"look_role", &"shore")
	foam.mesh = foam_mesh
	foam.material_override = foam_material
	foam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	foam.extra_cull_margin = 400.0
	foam.set_meta(StyleToon.META_NO_TOON, true)
	add_child(foam)


## A flat ring from `inner` to `outer` at height `y`; UV x runs round the ring `repeats` times, UV y from the inner edge (0) to the outer (1).
func _annulus(inner: float, outer: float, y: float, segments: int, repeats: float) -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for i: int in range(segments):
		var a0: float = float(i) / float(segments) * TAU
		var a1: float = float(i + 1) / float(segments) * TAU
		var u0: float = float(i) / float(segments) * repeats
		var u1: float = float(i + 1) / float(segments) * repeats
		var p00: Vector3 = center + Vector3(sin(a0) * inner, y, -cos(a0) * inner)
		var p01: Vector3 = center + Vector3(sin(a0) * outer, y, -cos(a0) * outer)
		var p10: Vector3 = center + Vector3(sin(a1) * inner, y, -cos(a1) * inner)
		var p11: Vector3 = center + Vector3(sin(a1) * outer, y, -cos(a1) * outer)
		for corner: Array in [[p00, Vector2(u0, 0.0)], [p01, Vector2(u0, 1.0)], [p10, Vector2(u1, 0.0)], [p10, Vector2(u1, 0.0)], [p01, Vector2(u0, 1.0)], [p11, Vector2(u1, 1.0)]]:
			surface.set_uv(corner[1] as Vector2)
			surface.add_vertex(corner[0] as Vector3)
	return surface.commit()


## An upright band (a cylinder wall seen from inside) of `height` metres from `base` y, the image repeated `repeats` times round it. UV y: 0 at the top, 1 at the base.
func _wall(radius: float, base: float, height: float, segments: int, repeats: float) -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for i: int in range(segments):
		var a0: float = float(i) / float(segments) * TAU
		var a1: float = float(i + 1) / float(segments) * TAU
		var u0: float = float(i) / float(segments) * repeats
		var u1: float = float(i + 1) / float(segments) * repeats
		var x0: float = sin(a0) * radius
		var z0: float = -cos(a0) * radius
		var x1: float = sin(a1) * radius
		var z1: float = -cos(a1) * radius
		var top: float = base + height
		for corner: Array in [[Vector3(x0, top, z0), Vector2(u0, 0.0)], [Vector3(x0, base, z0), Vector2(u0, 1.0)], [Vector3(x1, top, z1), Vector2(u1, 0.0)], [Vector3(x1, top, z1), Vector2(u1, 0.0)], [Vector3(x0, base, z0), Vector2(u0, 1.0)], [Vector3(x1, base, z1), Vector2(u1, 1.0)]]:
			surface.set_uv(corner[1] as Vector2)
			surface.add_vertex(center + (corner[0] as Vector3))
	return surface.commit()


func _backdrop_material(texture: Texture2D, ring: Dictionary) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(BACKDROP_SHADER) as Shader
	material.set_shader_parameter("tex", texture)
	material.set_shader_parameter("haze_amount", float(ring["haze"]))
	material.set_shader_parameter("cool_amount", float(ring["cool"]))
	material.set_shader_parameter("base_haze", float(ring["base_haze"]))
	material.set_shader_parameter("haze", _haze)
	material.render_priority = int(ring["priority"])
	_backdrops.append(material)
	_backdrop_entries.append({"material": material, "haze": float(ring["haze"]), "cool": float(ring["cool"]), "base_haze": float(ring["base_haze"])})
	return material


func _build_ring(ring: Dictionary) -> void:
	var texture: Texture2D = load("%sbackdrop/%s.png" % [ART, str(ring["file"])]) as Texture2D
	var radius: float = float(ring["radius"]) * _scale
	var height: float = float(ring["height"]) * _scale
	var tile_width: float = height * float(texture.get_width()) / float(texture.get_height())
	var repeats: float = roundf(TAU * radius / tile_width)
	var mesh: ArrayMesh = _wall(radius, float(ring["base"]), height, int(repeats) * 6, repeats)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Ring_%s" % str(ring["file"])
	instance.set_meta(&"look_role", &"rings")
	instance.mesh = mesh
	instance.material_override = _backdrop_material(texture, ring)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 1000.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	add_child(instance)


## Each landmark card faces the town and stands where the zone passageway points: the direction from the town middle to the island at the end of its bridge.
func _build_landmarks() -> void:
	var ring: Dictionary = {"haze": 0.22, "cool": 0.12, "base_haze": 0.35, "priority": -8}
	for entry: Dictionary in LANDMARKS:
		var zone_id: String = str(entry["zone"])
		var cell: Vector2i = TownBuilder.PORTAL_CELLS[zone_id] as Vector2i
		# The direction from the middle of the town to the island at the end of the bridge (the two western zones, the Dump and the D.N.A., stay 18 degrees apart this way;
		# a ray straight out of each mouth would put them 4 degrees apart and the two cards on top of each other).
		var plan: Dictionary = TownConnectors.plan(_town.cell_center(cell.x, cell.y), TownBuilder.PORTAL_OUT[zone_id] as Vector3)
		var toward: Vector3 = (plan["center"] as Vector3) - center
		toward.y = 0.0
		toward = toward.normalized()
		var spot: Vector3 = center + toward * LANDMARK_RADIUS
		var texture: Texture2D = load("%sbackdrop/landmark_%s.png" % [ART, str(entry["file"])]) as Texture2D
		var width: float = 2.0 * LANDMARK_RADIUS * tan(deg_to_rad(float(entry["width"]) * 0.5))
		var height: float = width * float(texture.get_height()) / float(texture.get_width())
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(width, height)
		quad.center_offset = Vector3(0.0, height * 0.5, 0.0)
		var card: MeshInstance3D = MeshInstance3D.new()
		card.name = "Landmark_%s" % str(entry["file"])
		card.set_meta(&"look_role", &"landmarks")
		card.mesh = quad
		card.material_override = _backdrop_material(texture, ring)
		card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		card.extra_cull_margin = 400.0
		card.set_meta(StyleToon.META_NO_TOON, true)
		add_child(card)
		card.position = Vector3(spot.x, 3.0, spot.z)
		# The card front (+z) faces the town centre.
		card.look_at(Vector3(center.x, card.position.y, center.z), Vector3.UP, true)
		print("world_look: landmark %s toward %s (%.0f deg from north), card %.0f x %.0f m" % [str(entry["file"]), str(toward), rad_to_deg(atan2(toward.x, -toward.z)), width, height])


func set_haze_color(color: Color) -> void:
	_haze = color
	for material: ShaderMaterial in _backdrops:
		material.set_shader_parameter("haze", color)


# ---- Any other area (the zones, the starting area) and zone moods -----------------------------------------------------------------


## The same sea, far shore and painted rings round a zone map: centred on the map's middle and pushed out so every ring clears the farthest corner of the map.
## `spec` (the mood's scenery block): `water` (false: no sea, the ground meets the haze), `shore`, `rings`, `landmark_cards` (array of {file, angle in degrees from north, width}), `landmarks` (false hides them).
func setup_generic(middle: Vector3, bounds: Rect2, cam: Camera3D, spec: Dictionary) -> void:
	center = middle
	camera = cam
	var reach: float = Vector2(bounds.size.x, bounds.size.y).length() * 0.5
	_scale = maxf(1.0, (reach + 85.0) / float(RINGS[0]["radius"]))
	_build_water_material()
	if bool(spec.get("water", true)):
		_build_water_plane()
	if bool(spec.get("shore", true)):
		_build_far_shore()
	if bool(spec.get("rings", true)):
		for ring: Dictionary in RINGS:
			_build_ring(ring)
	for entry: Variant in spec.get("landmark_cards", []) as Array:
		_build_landmark_at(entry as Dictionary)
	for entry: Variant in spec.get("kit_cards", []) as Array:
		_build_kit_card(entry as Dictionary)
	if spec.get("apron") is Dictionary:
		_build_apron(spec["apron"] as Dictionary)
	print("world_look: generic scenery at %s, scale %.2f" % [str(middle), _scale])


## A backdrop card from a zone kit (GAIN-BD-MOUNT ...) standing in the rings: {id, angle (degrees from north), width (degrees), ring (0 near, 1 hills, 2 mountains; the card stands
## just inside that ring), lift (m)}. Painted with the ring's haze and cool so it sits in the same air as the hills.
func _build_kit_card(entry: Dictionary) -> void:
	var id: String = str(entry.get("id", ""))
	var texture: Texture2D = EnvKit.texture(id) if EnvKit.has(id) else null
	if texture == null:
		return
	var ring_index: int = clampi(int(entry.get("ring", 1)), 0, RINGS.size() - 1)
	var ring: Dictionary = RINGS[ring_index]
	var angle: float = deg_to_rad(float(entry.get("angle", 0.0)))
	var toward: Vector3 = Vector3(sin(angle), 0.0, -cos(angle))
	var radius: float = float(ring["radius"]) * _scale * float(entry.get("distance", 0.93))
	var width: float = 2.0 * radius * tan(deg_to_rad(float(entry.get("width", 40.0)) * 0.5))
	var height: float = width * float(texture.get_height()) / float(texture.get_width())
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(width, height)
	quad.center_offset = Vector3(0.0, height * 0.5, 0.0)
	var card: MeshInstance3D = MeshInstance3D.new()
	card.name = "KitCard_%s" % id
	card.set_meta(&"look_role", &"rings")
	card.mesh = quad
	card.material_override = _backdrop_material(texture, {"haze": float(ring["haze"]) * 0.9, "cool": float(ring["cool"]) * 0.9, "base_haze": float(ring["base_haze"]) * 0.9, "priority": int(ring["priority"]) + 1})
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = 600.0
	card.set_meta(StyleToon.META_NO_TOON, true)
	add_child(card)
	card.position = center + toward * radius + Vector3(0.0, float(ring["base"]) + float(entry.get("lift", 0.0)), 0.0)
	card.look_at(Vector3(center.x, card.position.y, center.z), Vector3.UP, true)


## A landmark card at a compass angle (degrees from north) from the middle.
func _build_landmark_at(entry: Dictionary) -> void:
	var angle: float = deg_to_rad(float(entry.get("angle", 0.0)))
	var toward: Vector3 = Vector3(sin(angle), 0.0, -cos(angle))
	var radius: float = LANDMARK_RADIUS * _scale
	var texture: Texture2D = load("%sbackdrop/landmark_%s.png" % [ART, str(entry["file"])]) as Texture2D
	if texture == null:
		return
	var width: float = 2.0 * radius * tan(deg_to_rad(float(entry.get("width", 19.0)) * 0.5))
	var height: float = width * float(texture.get_height()) / float(texture.get_width())
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(width, height)
	quad.center_offset = Vector3(0.0, height * 0.5, 0.0)
	var card: MeshInstance3D = MeshInstance3D.new()
	card.name = "Landmark_%s" % str(entry["file"])
	card.set_meta(&"look_role", &"landmarks")
	card.mesh = quad
	card.material_override = _backdrop_material(texture, {"haze": 0.22, "cool": 0.12, "base_haze": 0.35, "priority": -8})
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = 400.0
	card.set_meta(StyleToon.META_NO_TOON, true)
	add_child(card)
	card.position = center + toward * radius + Vector3(0.0, 3.0, 0.0)
	card.look_at(Vector3(center.x, card.position.y, center.z), Vector3.UP, true)


## A zone's scenery mood: `tint` (hex) multiplies the rings, `cool` (hex) is the colour the distance is pulled towards, `haze_scale` / `cool_amount_scale` thicken or thin the
## atmospheric perspective, `brightness`, and `water_tint` (hex) tints the sea. Layers a mood has no use for are hidden: `water`, `shore`, `rings`, `landmarks` (false).
func set_mood(spec: Dictionary) -> void:
	_mood = spec
	var tint: Color = Color.html(str(spec.get("tint", "ffffff")))
	var cool: Color = Color.html(str(spec.get("cool", "9aa8e0")))
	var haze_scale: float = float(spec.get("haze_scale", 1.0))
	var cool_scale: float = float(spec.get("cool_scale", 1.0))
	var brightness: float = float(spec.get("brightness", 1.0))
	for entry: Dictionary in _backdrop_entries:
		var material: ShaderMaterial = entry["material"] as ShaderMaterial
		material.set_shader_parameter("tint", tint)
		material.set_shader_parameter("cool", cool)
		material.set_shader_parameter("brightness", brightness)
		material.set_shader_parameter("haze_amount", clampf(float(entry["haze"]) * haze_scale, 0.0, 1.0))
		material.set_shader_parameter("cool_amount", clampf(float(entry["cool"]) * cool_scale, 0.0, 1.0))
		material.set_shader_parameter("base_haze", clampf(float(entry["base_haze"]) * haze_scale, 0.0, 1.0))
	if water_material != null and spec.has("water_tint"):
		var water_tint: Color = Color.html(str(spec["water_tint"]))
		water_material.set_shader_parameter("shallow_tint", water_tint.lerp(Color.WHITE, 0.55))
		water_material.set_shader_parameter("deep_tint", water_tint)
	for child: Node in get_children():
		var role: StringName = child.get_meta(&"look_role", &"") as StringName
		if role != &"" and child is Node3D:
			var wanted: Variant = spec.get(str(role), true)
			(child as Node3D).visible = wanted is Dictionary or bool(wanted)


## A flat unlit ground that carries on from the map in every direction (the D.N.A.'s office floor, the wasteland outside the Capital): the scene fog dissolves it into the
## background, so there is no edge of the world. `spec`: `color` (hex), `y` (height, default just under the floor top), `size` (metres, default 900).
func _build_apron(spec: Dictionary) -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	var size: float = float(spec.get("size", 900.0))
	plane.size = Vector2(size, size)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.html(str(spec.get("color", "2a3440")))
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Apron"
	instance.set_meta(&"look_role", &"apron")
	instance.mesh = plane
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 400.0
	instance.position = Vector3(center.x, float(spec.get("y", -0.03)), center.z)
	instance.set_meta(StyleToon.META_NO_TOON, true)
	add_child(instance)
