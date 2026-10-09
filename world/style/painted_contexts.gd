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
