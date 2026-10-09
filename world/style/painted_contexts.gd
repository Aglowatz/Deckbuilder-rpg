class_name PaintedContexts
extends RefCounted
## Per-zone runtime data for `PaintedWorld.apply`: the named masks (Callable(Vector2 x/z) -> 0..1) the preset's layers and decals refer to, the terrain meshes to swap, and the flat-look
## overlays to hide while painted. The look itself (which textures, tint, decals) stays in data/art/texture_presets.json; only "where" comes from the zone's own layout data here.


## Soft edge ramp: 0.5 on the boundary, 1 `width / 2` inside, 0 `width / 2` outside (the shader roughens the 0.5 threshold with noise).
static func ramp(inside_distance: float, width: float = 1.6) -> float:
	return clampf(0.5 + inside_distance / width, 0.0, 1.0)


## Town: the plaza disc (stone), soil in a ring round the buildings, sand along the shore, plus helper masks for decals.
static func town(scene: TownScene) -> Dictionary:
	var shops: Array[TownLayout.Shop] = TownLayout.shops()
	var town: TownBuilder = scene.town
	var plaza: Vector2 = Vector2(TownLayout.PLAZA.x, TownLayout.PLAZA.z)
	var plaza_mask: Callable = func(p: Vector2) -> float:
		return PaintedContexts.ramp(TownLayout.PLAZA_RADIUS - p.distance_to(plaza))
	var paved: Callable = func(p: Vector2) -> float:
		return 1.0 if TownLayout.is_paved(Vector3(p.x, 0.0, p.y), 0.2) else 0.0
	var soil_mask: Callable = func(p: Vector2) -> float:
		if TownLayout.is_paved(Vector3(p.x, 0.0, p.y), 0.8):
			return 0.0
		var nearest: float = 1.0e9
		for shop: TownLayout.Shop in shops:
			nearest = minf(nearest, p.distance_to(Vector2(shop.center.x, shop.center.z)) - shop.radius * 1.2)
		return PaintedContexts.ramp(1.0 - nearest, 1.6) if nearest < 1.4 else 0.0
	var sand_mask: Callable = func(p: Vector2) -> float:
		var here: Vector3 = Vector3(p.x, 0.0, p.y)
		if not town.is_floor_at(here):
			return 0.0
		for radius: float in [0.8, 1.6, 2.4]:
			for index: int in range(6):
				var angle: float = TAU * float(index) / 6.0
				if not town.is_floor_at(here + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)):
					return PaintedContexts.ramp(2.0 - radius, 1.6)
		return 0.0
	var grass_mask: Callable = func(p: Vector2) -> float:
		return 0.0 if TownLayout.is_paved(Vector3(p.x, 0.0, p.y), 0.6) else 1.0
	var rect: Rect2 = town.map_bounds().grow(1.0)
	return {
		"bounds": rect,
		"masks": {"plaza": plaza_mask, "soil": soil_mask, "sand": sand_mask, "paved": paved, "grass": grass_mask},
		"flat_hidden": flat_overlays(scene, [scene.square.root, scene.square.streets.root, scene.get_node_or_null("ZoneDressing")]),
		"lift": GroundDecals.LIFT + 0.0006,
	}


## The flat ground's own overlays (moss patches, the plaza's paving discs, ZoneDressing's procedural decals): 28-segment fans (29 vertices) with a GroundDecals material.
## They are hidden while the painted ground shows. Road ribbons, the royal crest and other decals stay in both modes.
static func flat_overlays(_scene: Node, roots: Array) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for parent_variant: Variant in roots:
		var parent: Node = parent_variant as Node
		if parent == null:
			continue
		for child: Node in parent.get_children():
			var instance: MeshInstance3D = child as MeshInstance3D
			if instance == null or not instance.material_override is ShaderMaterial or not instance.mesh is ArrayMesh:
				continue
			var arrays: Array = (instance.mesh as ArrayMesh).surface_get_arrays(0)
			if (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() != 29:
				continue
			var pattern: int = int((instance.material_override as ShaderMaterial).get_shader_parameter("pattern"))
			var in_dressing: bool = parent.name == &"ZoneDressing"
			var at_plaza: bool = Vector2(instance.position.x - TownLayout.PLAZA.x, instance.position.z - TownLayout.PLAZA.z).length() < 0.5
			if in_dressing or pattern == int(GroundDecals.Pattern.MOSS) or at_plaza:
				found.append(instance)
	return found


## Starting Area: the dirt path from the spawn to the cave gate (the same wobbling line the old worn-path decal followed), the forest floor everywhere else. The overlay covers every
## cell of the 5x5 clearing (treeline cells too), the huge forest floor plane is painted with the same material, and the old flat blotches/worn path are hidden while painted.
static func start(scene: StartingAreaScene) -> Dictionary:
	var area: StartingAreaBuilder = scene.area
	var spawn: Vector3 = area.anchors.get("spawn", Vector3.ZERO) as Vector3
	var gate: Vector3 = (area.anchors.get("gate", Vector3.ZERO) as Vector3) + Vector3(0.0, 0.0, 0.6)
	var line: PackedVector2Array = PackedVector2Array()
	for i: int in range(7):
		var t: float = float(i) / 6.0
		var p: Vector3 = spawn.lerp(gate, t) + Vector3(sin(t * 6.0) * 0.25, 0.0, 0.0)
		line.append(Vector2(p.x, p.z))
	var path_mask: Callable = func(p: Vector2) -> float:
		var best: float = 1.0e9
		for index: int in range(line.size() - 1):
			best = minf(best, p.distance_to(Geometry2D.get_closest_point_to_segment(p, line[index], line[index + 1])))
		return PaintedContexts.ramp(0.85 - best, 1.4)
	var off_path: Callable = func(p: Vector2) -> float:
		return 1.0 - float(path_mask.call(p))
	var cover: Callable = func(pos: Vector3) -> bool:
		var cell: Vector2i = HexGrid.world_to_cell(pos)
		return cell.x >= -1 and cell.y >= -1 and cell.x <= StartingAreaBuilder.MAP[0].length() and cell.y <= StartingAreaBuilder.MAP.size()
	var terrain: Array = []
	var hidden: Array[Node3D] = []
	if scene.forest != null:
		var floor_node: Node3D = scene.forest.get_node_or_null("ForestFloor") as Node3D
		if floor_node != null:
			terrain.append(floor_node)
		hidden.append_array(flat_overlays(scene, [scene.forest, scene.get_node_or_null("ZoneDressing")]))
	if scene._worn_path_node != null:
		hidden.append(scene._worn_path_node)
	var rect: Rect2 = HexGrid.bounds_of(_all_cells()).grow(3.0)
	return {"bounds": rect, "masks": {"path": path_mask, "grass": off_path}, "terrain": terrain, "flat_hidden": hidden, "cover": cover, "floor": cover}


static func _all_cells() -> Array:
	var cells: Array = []
	for row: int in range(StartingAreaBuilder.MAP.size()):
		for col: int in range(StartingAreaBuilder.MAP[row].length()):
			cells.append(Vector2i(col, row))
	return cells


## Every vertex-coloured terrain mesh of a zone (the zone builders' `StyleTerrain` meshes): the painted terrain material replaces them, the vertex colours are the painted masks.
static func terrain_meshes(scene: Node) -> Array:
	var found: Array = []
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var instance: MeshInstance3D = node as MeshInstance3D
		var shader_material: ShaderMaterial = instance.material_override as ShaderMaterial
		if shader_material != null and shader_material.shader != null and shader_material.shader.resource_path.ends_with("style_terrain.gdshader"):
			found.append(instance)
	return found


## Zone scenes (`ZoneScene`): dispatch by style preset id.
static func zone(scene: ZoneScene, preset_id: StringName) -> Dictionary:
	var context: Dictionary = {"terrain": terrain_meshes(scene)}
	match preset_id:
		StylePresets.GAINLANDS:
			context.merge(gainlands(scene), true)
		StylePresets.BUFFET:
			context.merge(buffet(scene), true)
		StylePresets.DNA:
			context.merge(dna(scene), true)
	return context


## Soft disc mask value 0..1 around `center` (x/z) with `radius`.
static func disc_mask(p: Vector2, center: Vector2, radius: float) -> float:
	return ramp(radius - p.distance_to(center), 1.6)


## The Gainlands: gym mat under the gym equipment and the Swole Station, hay round the mills and hamster wheels, grass elsewhere on land (the dirt paths come from the vertex colours).
static func gainlands(scene: ZoneScene) -> Dictionary:
	var builder: GainlandsBuilder = scene.builder as GainlandsBuilder
	var layout: GainlandsLayout = builder.layout
	var gym_spots: Array[Vector3] = []
	var hay_spots: Array[Vector3] = []
	for prop: GainlandsLayout.Prop in layout.props:
		match prop.kind:
			"bench_press", "dumbbell_rack", "log_rack":
				gym_spots.append(Vector3(prop.pos.x, prop.pos.z, 2.4))
			"mill":
				hay_spots.append(Vector3(prop.pos.x, prop.pos.z, 4.6 * prop.model_scale / 3.0 + 1.6))
			"wheel":
				hay_spots.append(Vector3(prop.pos.x, prop.pos.z, 3.2 * prop.model_scale))
	gym_spots.append(Vector3(72.0, 68.0, 6.5))
	var gym_mask: Callable = func(p: Vector2) -> float:
		var best: float = 0.0
		for spot: Vector3 in gym_spots:
			best = maxf(best, PaintedContexts.disc_mask(p, Vector2(spot.x, spot.y), spot.z))
		return best
	var hay_mask: Callable = func(p: Vector2) -> float:
		var best: float = 0.0
		for spot: Vector3 in hay_spots:
			best = maxf(best, PaintedContexts.disc_mask(p, Vector2(spot.x, spot.y), spot.z))
		return best
	var path_mask: Callable = func(p: Vector2) -> float:
		return layout.path_weight(p.x, p.y)
	var grass_mask: Callable = func(p: Vector2) -> float:
		return 0.0 if layout.path_weight(p.x, p.y) > 0.2 or float(gym_mask.call(p)) > 0.2 else 1.0
	return {
		"bounds": Rect2(-30, -30, 180, 150),
		"masks": {"gym": gym_mask, "hay": hay_mask, "path": path_mask, "grass": grass_mask},
		"floor": func(pos: Vector3) -> bool: return builder.is_floor_at(pos),
	}


## Soft mask of an axis-aligned rectangle (x, z, width, depth): 1 well inside, 0 outside, 0.5 on the edge.
static func rect_mask(p: Vector2, rect: Rect2) -> float:
	var inside: float = minf(minf(p.x - rect.position.x, rect.end.x - p.x), minf(p.y - rect.position.y, rect.end.y - p.y))
	return ramp(inside, 1.2)


## The D.N.A.: every floor chunk's surfaces get the painted floor of their kind (carpet in the cubicle farms, marble in the lobby/mail/elevator bank, linoleum in the breakroom and the
## filing maze, a checker inlay in the lobby and the records basement), the walls get dark paneling under drab wallpaper, partitions get wallpaper. Papers lie on the office floors.
static func dna(scene: ZoneScene) -> Dictionary:
	var builder: DnaBuilder = scene.builder as DnaBuilder
	var kind_names: Dictionary = {
		int(DnaLayout.Floor.CARPET): "carpet", int(DnaLayout.Floor.TILE): "tile", int(DnaLayout.Floor.CONCRETE): "concrete",
		int(DnaLayout.Floor.EXEC): "exec", int(DnaLayout.Floor.LINO): "lino",
	}
	var swaps: Array = []
	var walls: Material = PaintedTriplanar.wall_material("dna_paneling", "dna_wallpaper", 2.4, 0.55, Color("1c2b28"), Color("1f2a28"), 1.0)
	var partitions: Material = PaintedTriplanar.material("dna_wallpaper", 2.2, Color(0.42, 0.56, 0.5), 0.1)
	for chunk: Node in builder.chunks.values():
		for child: Node in chunk.get_children():
			if child.name == &"Floor" and child is MeshInstance3D:
				var instance: MeshInstance3D = child as MeshInstance3D
				for surface: int in range(instance.mesh.get_surface_count()):
					for kind: int in kind_names.keys():
						if instance.mesh.surface_get_material(surface) == DnaMaterials.floor_material(kind as DnaLayout.Floor):
							swaps.append({"node": instance, "surface": surface, "variant": kind_names[kind]})
			elif child.name == &"Walls" and walls != null:
				swaps.append({"node": child, "material": walls})
			elif child.name == &"Partitions" and partitions != null:
				swaps.append({"node": child, "material": partitions})
	var records: Rect2 = Rect2(56, 4, 32, 20)
	var lobby_inlay: Rect2 = Rect2(41, 50, 10, 6)
	var farms: Array[Rect2] = [Rect2(2, 26, 32, 18), Rect2(56, 26, 32, 18)]
	var records_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.rect_mask(p, records)
	var inlay_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.rect_mask(p, lobby_inlay)
	var office_mask: Callable = func(p: Vector2) -> float:
		return maxf(PaintedContexts.rect_mask(p, farms[0]), PaintedContexts.rect_mask(p, farms[1]))
	var lino_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.rect_mask(p, Rect2(18, 48, 17, 12))
	var marble_mask: Callable = func(p: Vector2) -> float:
		return maxf(PaintedContexts.rect_mask(p, Rect2(36, 46, 20, 14)), PaintedContexts.rect_mask(p, Rect2(36, 2, 18, 12)))
	return {
		"bounds": Rect2(0, 0, float(DnaLayout.W), float(DnaLayout.H)),
		"masks": {"records": records_mask, "inlay": inlay_mask, "office": office_mask, "lino": lino_mask, "marble": marble_mask},
		"swaps": swaps,
	}


## How much of `p` lies inside the named layout areas (soft edge), for the zones whose layout is a list of circular areas (Buffet, Dump).
static func area_cover(areas: Array, ids: Array, p: Vector2) -> float:
	var best: float = 0.0
	for area: Variant in areas:
		if str(area.id) in ids:
			best = maxf(best, ramp(float(area.radius) - p.distance_to(area.center), 3.0))
	return best


## The Endless Buffet: biscuit on the paths and the Grand Pantry floor, crumb soil in the Broccoli Forest, frosting in the Candy Field and Layer-Cake Town, cheese on the cheddar
## cliffs; the gravy river and ponds become the painted, gently flowing gravy.
static func buffet(scene: ZoneScene) -> Dictionary:
	var builder: BuffetBuilder = scene.builder as BuffetBuilder
	var layout: BuffetLayout = builder.layout
	var areas: Array = layout.areas
	var path_mask: Callable = func(p: Vector2) -> float:
		return maxf(layout.path_weight(p.x, p.y), PaintedContexts.area_cover(areas, ["hub"], p))
	var forest_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["forest"], p)
	var sweet_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["candy", "cake"], p)
	var cheese_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["cheddar", "cheddar_top"], p)
	var food_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["hub", "cake", "candy", "bank"], p)
	var swaps: Array = []
	var gravy: Material = PaintedFlow.material("buff_gravy", Vector2(1.0, 0.25), 0.2, 5.0, Color(0.82, 0.74, 0.64), 0.95)
	if gravy != null:
		for node: Node in builder.root.get_children():
			if node.name == &"GravyRiver" or node.name == &"GravyPond":
				swaps.append({"node": node, "material": gravy})
	return {
		"bounds": Rect2(0, 0, 100, 82),
		"masks": {"path": path_mask, "forest": forest_mask, "sweet": sweet_mask, "cheese": cheese_mask, "food": food_mask},
		"swaps": swaps,
		"floor": func(pos: Vector3) -> bool: return builder.is_floor_at(pos),
	}
