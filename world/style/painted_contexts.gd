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
		if town.hub_land:
			return 0.0  # Oct 16: the town sits in one country, not on an island: no beach round its edge
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
	# Oct 16: in the one-country hub the painted ground reaches a little past the walkable edge, so no bare corner of an edge hex tile shows.
	var cover: Callable = func(p: Vector3) -> bool:
		if town.is_floor_at(p):
			return true
		if not town.hub_land or town.map_char_at(p) == ".":
			return false
		for offset: Vector3 in [Vector3(1.0, 0, 0), Vector3(-1.0, 0, 0), Vector3(0, 0, 1.0), Vector3(0, 0, -1.0)]:
			if town.is_floor_at(p + offset):
				return true
		return false
	var rect: Rect2 = town.map_bounds().grow(1.0)
	return {
		"bounds": rect,
		"cover": cover,
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


## Opening Forest (docs/art/opening_forest.md): the dirt of the worn path (`OpeningForestLayout.PATH`) and the camp, the mossy forest floor everywhere else. The overlay covers
## the floor and a few metres of the treeline round it, the huge forest floor plane is painted with the same material, and the flat worn-path decal is hidden while painted.
static func start(scene: StartingAreaScene) -> Dictionary:
	var layout: OpeningForestLayout = scene.area.layout
	var camp: Vector2 = Vector2(OpeningForestLayout.SPAWN.x, OpeningForestLayout.SPAWN.z)
	var path_mask: Callable = func(p: Vector2) -> float:
		var on_path: float = PaintedContexts.ramp(OpeningForestLayout.PATH_HALF * 0.78 - layout.path_distance(p), 1.2)
		var at_camp: float = PaintedContexts.ramp(2.6 - p.distance_to(camp + Vector2(-0.8, 0.2)), 1.4)
		return maxf(on_path, at_camp * 0.85)
	var off_path: Callable = func(p: Vector2) -> float:
		return 1.0 - float(path_mask.call(p))
	var cover: Callable = func(pos: Vector3) -> bool:
		return layout.floor_sdf(Vector2(pos.x, pos.z)) < 3.5
	var terrain: Array = []
	var hidden: Array[Node3D] = []
	if scene.forest != null:
		var floor_node: Node3D = scene.forest.get_node_or_null("ForestFloor") as Node3D
		if floor_node != null:
			terrain.append(floor_node)
		hidden.append_array(flat_overlays(scene, [scene.forest, scene.get_node_or_null("ZoneDressing")]))
	if scene._worn_path_node != null:
		hidden.append(scene._worn_path_node)
	return {"bounds": layout.bounds().grow(4.0), "masks": {"path": path_mask, "grass": off_path}, "terrain": terrain, "flat_hidden": hidden, "cover": cover, "floor": cover}


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
		StylePresets.CAPITAL_FACADE, StylePresets.CAPITAL_OUTSKIRTS, StylePresets.CAPITAL_DARK, StylePresets.CAPITAL_FREED, StylePresets.CAPITAL_INSIDE, StylePresets.CAPITAL_INSIDE_DARK:
			context.merge(capital(scene), true)
		StylePresets.HEAP:
			context.merge(heap(scene), true)
		StylePresets.BUFFET:
			context.merge(buffet(scene), true)
		StylePresets.DNA:
			context.merge(dna(scene), true)
	return context


## Soft disc mask value 0..1 around `center` (x/z) with `radius`.
static func disc_mask(p: Vector2, center: Vector2, radius: float) -> float:
	return ramp(radius - p.distance_to(center), 1.6)


## The Gainlands (v2, docs/art/gainlands_v2.md): sandy chalk ground, stone paving on every route, the plaza, the forecourt and the mesa top, patches of dry
## scrub (thicker towards the rims, never on the paving), gym mat under the lifting yards. The cliffs take the triplanar sandstone of the preset.
static func gainlands(scene: ZoneScene) -> Dictionary:
	var builder: GainlandsBuilder = scene.builder as GainlandsBuilder
	var layout: GainlandsLayout = builder.layout
	var bounds: Rect2 = Rect2(GainlandsLayout.GRID_ORIGIN, Vector2(GainlandsLayout.GRID_W, GainlandsLayout.GRID_H) * GainlandsLayout.GRID_CELL)
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var gym_rects: Array[Rect2] = layout.yard_rects()
	# the road weight once per splat pixel (the three masks share it)
	var roads: Dictionary = {}
	var road_at: Callable = func(p: Vector2) -> float:
		var key: Vector2i = Vector2i(roundi(p.x * 4.0), roundi(p.y * 4.0))
		if roads.has(key):
			return float(roads[key])
		var value: float = layout.path_weight(p.x, p.y)
		value = maxf(value, PaintedContexts.disc_mask(p, Vector2(hub.x, hub.z), 12.5))
		value = maxf(value, PaintedContexts.rect_mask(p, Rect2(42.5, 14.5, 27.0, 7.0)))
		if GainlandsLayout.level_at(p.x, p.y) == 2:
			value = maxf(value, PaintedContexts.rect_mask(p, Rect2(44.0, -6.0, 24.0, 15.0)))
		roads[key] = value
		return value
	var gym_mask: Callable = func(p: Vector2) -> float:
		var best: float = 0.0
		for rect: Rect2 in gym_rects:
			best = maxf(best, PaintedContexts.rect_mask(p, rect))
		return best
	var mills: Array[Vector2] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == "mill":
			mills.append(Vector2(prop.pos.x, prop.pos.z))
	var hay_mask: Callable = func(p: Vector2) -> float:
		var best: float = 0.0
		for mill: Vector2 in mills:
			best = maxf(best, PaintedContexts.disc_mask(p, mill, 5.5))
		return best * (1.0 - float(road_at.call(p)))
	var scrub_mask: Callable = func(p: Vector2) -> float:
		var road: float = float(road_at.call(p))
		if road > 0.3 or float(gym_mask.call(p)) > 0.3 or float(hay_mask.call(p)) > 0.3:
			return 0.0
		var patches: float = sin(p.x * 0.21 + 1.3) * cos(p.y * 0.17 + 0.4) + 0.6 * sin(p.x * 0.47 - p.y * 0.39)
		var rim: float = 1.0 - clampf(GainlandsLayout.main_edge_distance(p.x, p.y) / 9.0, 0.0, 1.0)
		return clampf(smoothstep(0.35, 0.9, patches * 0.6 + rim * 0.7) * (1.0 - road * 2.0), 0.0, 1.0)
	# the floating islands keep green tops (the preset's "islands" variant); the plateau and its rocks take the sandstone preset
	var land: Array = []
	var swaps: Array = []
	for mesh: Variant in terrain_meshes(scene):
		if str((mesh as Node).name).begins_with("Island_"):
			swaps.append({"node": mesh, "variant": "islands"})
		else:
			land.append(mesh)
	return {
		"terrain": land,
		"swaps": swaps,
		"bounds": bounds,
		"masks": {"road": road_at, "gym": gym_mask, "scrub": scrub_mask, "hay": hay_mask},
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
			elif child.name == &"Walls" and walls != null:  # the pre-slice wall mesh (the Oct 19 interior is "Interior" and paints itself)
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
	# the paint-overs (docs/art/buffet_slice.md, Part D): biscuit cobbles on the routes, the Dining Hall plaza, the cake square and the show kitchen; crumb soil on the
	# forest floor; mashed potato everywhere else; frosting nowhere on the ground (it is the Cathedral's)
	var path_mask: Callable = func(p: Vector2) -> float:
		return maxf(layout.path_weight(p.x, p.y), PaintedContexts.area_cover(areas, ["hub", "cake", "candy"], p))
	var forest_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["forest"], p)
	var sweet_mask: Callable = func(p: Vector2) -> float: return 0.0 * p.x
	var cheese_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["cheddar", "cheddar_top"], p)
	var food_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["hub", "cake", "candy", "bank"], p)
	var swaps: Array = []
	var gravy: Material = PaintedFlow.material("buff_gravy", Vector2(1.0, 0.25), 0.2, 5.0, Color(0.82, 0.74, 0.64), 0.95)
	if gravy != null:
		for node: Node in builder.root.get_children():
			if node.name == &"GravyRiver" or node.name == &"GravyPond":
				swaps.append({"node": node, "material": gravy})
	# the table itself takes the painted ground (the rim layers keep their cake colours)
	var terrain: Array = []
	var table: Node = builder.root.find_child("Table", false, false)
	if table != null:
		terrain.append(table)
	return {
		"bounds": Rect2(0, 0, 100, 82),
		"masks": {"path": path_mask, "forest": forest_mask, "sweet": sweet_mask, "cheese": cheese_mask, "food": food_mask},
		"terrain": terrain,
		"swaps": swaps,
		"floor": func(pos: Vector3) -> bool: return builder.is_floor_at(pos),
	}


## Largest soft disc mask over the props of the given kinds (`radius` round each).
static func prop_cover(spots: Array[Vector3], p: Vector2) -> float:
	var best: float = 0.0
	for spot: Vector3 in spots:
		best = maxf(best, disc_mask(p, Vector2(spot.x, spot.y), spot.z))
	return best


## The Verdant Dump (the art pass, docs/art/heap_slice.md): clover everywhere (the kit's DUMP-GROUND-CLOVER), farm rows in the farm region, warm mossy dirt on the
## routes and the plaza, junk gravel round the junk clusters and in the peaks' and throne's yards, and the corrupted soil (DUMP-GROUND-CORRUPT) painted in by the
## corruption gradient (`HeapBuilder.twist_at`, scaled by `corruption.texture`; gone once the zone is freed); junk props get rusted metal (the preset's specials).
static func heap(scene: ZoneScene) -> Dictionary:
	var builder: HeapBuilder = scene.builder as HeapBuilder
	var layout: HeapLayout = builder.layout
	var areas: Array = layout.areas
	var junk_spots: Array[Vector3] = []
	var compost_spots: Array[Vector3] = []
	for prop: HeapLayout.Prop in layout.props:
		match prop.kind:
			"junk_pile", "car_husk", "appliance_pile", "tire_stack", "wall_tires", "fridge", "appliance_ring", "junk_dam":
				junk_spots.append(Vector3(prop.pos.x, prop.pos.z, 3.0 * maxf(prop.model_scale, 0.8)))
			"compost_heap", "compost_bin", "composting_door":
				compost_spots.append(Vector3(prop.pos.x, prop.pos.z, 3.6))
	var plaza: Vector2 = HeapLayout.PLAZA_CENTER
	var texture: float = float(layout.corruption.get("texture", 0.9))
	# the farm rows are the farm terrace's (T1); the compost terrace's "farm" circles take the compost and junk layers instead
	var fields_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.area_cover(areas, ["farm"], p) * (1.0 - layout.path_weight(p.x, p.y)) * smoothstep(62.0, 66.0, p.y)
	var path_mask: Callable = func(p: Vector2) -> float:
		return maxf(layout.path_weight(p.x, p.y), PaintedContexts.disc_mask(p, plaza, HeapLayout.PLAZA_RADIUS + 0.5))
	var junk_mask: Callable = func(p: Vector2) -> float:
		var yard: float = PaintedContexts.area_cover(areas, ["peaks", "throne"], p) * 0.55
		return maxf(PaintedContexts.prop_cover(junk_spots, p), yard) * (1.0 - float(path_mask.call(p)) * 0.8)
	var compost_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.prop_cover(compost_spots, p)
	# the soil turns late: the throne approach and the stream keep golden ground with the odd vein, the wetlands toward the roots go over
	var corrupt_mask: Callable = func(p: Vector2) -> float: return smoothstep(0.35, 0.95, builder.twist_at(p.x, p.y)) * texture
	var grass_mask: Callable = func(p: Vector2) -> float:
		if float(fields_mask.call(p)) > 0.3 or float(junk_mask.call(p)) > 0.3 or float(path_mask.call(p)) > 0.3:
			return 0.0
		return 1.0 - float(corrupt_mask.call(p))
	# freed, the land takes the "freed" variant: no corrupted soil, rich compost round the heaps instead
	var swaps: Array = []
	if builder.freed:
		var land: Node = builder.root.find_child("Land", false, false)
		if land != null:
			swaps.append({"node": land, "variant": "freed"})
	return {
		"bounds": Rect2(HeapLayout.MIN_CORNER.x - 4.0, HeapLayout.MIN_CORNER.y - 4.0, HeapLayout.MAX_CORNER.x - HeapLayout.MIN_CORNER.x + 8.0, HeapLayout.MAX_CORNER.y - HeapLayout.MIN_CORNER.y + 8.0),
		"masks": {"fields": fields_mask, "path": path_mask, "junk": junk_mask, "corrupt": corrupt_mask, "compost": compost_mask, "grass": grass_mask},
		"swaps": swaps,
		"floor": func(pos: Vector3) -> bool: return builder.is_floor_at(pos),
	}


## The Capital: outside the walls ash gray ground, dead grass (dead/grass/soil cells) and cracked paving (roads, metal, tiles, hub); inside the walls pastel paving and a perfect striped
## lawn. The masks come from the layout's own floor kinds; the two huge planes beyond the map get their own plain variants so no mask streaks run off the edge.
static func capital(scene: ZoneScene) -> Dictionary:
	var builder: CapitalBuilder = scene.builder as CapitalBuilder
	var layout: CapitalLayout = builder.layout
	var wall_z: float = float(CapitalLayout.WALL_Z0)
	var kind_at: Callable = func(p: Vector2) -> int:
		return int(layout.floor_at(int(floorf(p.x)), int(floorf(p.y))))
	var inside: Callable = func(p: Vector2) -> bool: return p.y < wall_z and p.x > CapitalLayout.CITY_WEST_X
	var paved_mask: Callable = func(p: Vector2) -> float:
		if inside.call(p):
			return 0.0
		match int(kind_at.call(p)):
			CapitalLayout.Floor.ROAD, CapitalLayout.Floor.GRAY, CapitalLayout.Floor.METAL, CapitalLayout.Floor.TILE, CapitalLayout.Floor.HUB, CapitalLayout.Floor.PLAZA:
				return 1.0
		return 0.0
	var dead_mask: Callable = func(p: Vector2) -> float:
		if inside.call(p):
			return 0.0
		match int(kind_at.call(p)):
			CapitalLayout.Floor.DEAD, CapitalLayout.Floor.GRASS, CapitalLayout.Floor.SOIL:
				return 1.0
		return 0.0
	# the art pass (Part F): Grave Row is a lawn cemetery with paved lanes and the Reek a paved back lane (their paint-overs), whatever the cells' floor kinds
	var district_at: Callable = func(p: Vector2) -> String:
		var area: CapitalLayout.Area = layout.area_at(p.x, p.y)
		return area.id if area != null else ""
	var lawn_mask: Callable = func(p: Vector2) -> float:
		if not inside.call(p):
			return 0.0
		match str(district_at.call(p)):
			"grave":
				return 0.0 if layout.route_edge_distance(p.x, p.y) < 0.2 else 1.0
			"reek":
				return 0.0
		match int(kind_at.call(p)):
			CapitalLayout.Floor.LAWN, CapitalLayout.Floor.SOIL, CapitalLayout.Floor.GRASS:
				return 1.0
		return 0.0
	var pastel_mask: Callable = func(p: Vector2) -> float:
		if not inside.call(p) or int(layout.cell_at(int(floorf(p.x)), int(floorf(p.y)))) == int(CapitalLayout.Cell.VOID):
			return 0.0
		return 1.0 - float(lawn_mask.call(p))
	var rift_spots: Array[Vector3] = []
	for rift: CapitalLayout.Rift in layout.rifts:
		rift_spots.append(Vector3(rift.pos.x, rift.pos.y, rift.radius + 2.0))
	var rift_mask: Callable = func(p: Vector2) -> float: return PaintedContexts.prop_cover(rift_spots, p)
	var outside_mask: Callable = func(p: Vector2) -> float: return 0.0 if inside.call(p) else 1.0
	var terrain: Array = []
	var swaps: Array = []
	for node: Node in builder.root.get_children():
		if node.name == &"Ground" or node.name == &"CreaseGround":
			terrain.append(node)
		elif str(node.name).begins_with("Wasteland"):
			swaps.append({"node": node, "variant": "wasteland"})
		elif node.name == &"Rim":
			# the Capital pass: the land round the map takes the far plain's painted wasteland, so the walkable edge never shows a seam
			swaps.append({"node": node.get_node("RimGround"), "variant": "wasteland"})
		elif node.name == &"Meadow":
			swaps.append({"node": node, "variant": "meadow"})
	return {
		"bounds": Rect2(float(CapitalLayout.GRID_X0), 0, float(CapitalLayout.W), float(CapitalLayout.H)),
		"masks": {"paved": paved_mask, "dead": dead_mask, "lawn": lawn_mask, "pastel": pastel_mask, "rift": rift_mask, "outside": outside_mask},
		"terrain": terrain,
		"swaps": swaps,
		"floor": func(pos: Vector3) -> bool: return builder.is_floor_at(pos),
	}
