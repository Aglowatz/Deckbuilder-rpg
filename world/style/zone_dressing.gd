class_name ZoneDressing
extends RefCounted
## Generic set dressing for every walkable area (docs/art/style_guide.md, section 8: density rules): wind-swaying foliage and small themed clutter scattered
## as chunked MultiMeshes on the walkable ground, plus soft ground patches. Recipes are per style preset. Everything is decorative (never blocks the hero),
## deterministic (seeded by the preset id) and scaled by the graphics quality.

const NATURE: String = ModelKit.KENNEY_NATURE
const SURVIVAL: String = ModelKit.KENNEY_SURVIVAL
const FOOD: String = ModelKit.KENNEY_FOOD
const FURNITURE: String = "res://assets/kenney-furniture-kit/models/"
const CHUNK: float = 16.0

## The instance budget over the whole area per quality level.
const BUDGET: Array[int] = [250, 1100, 2400]
## Grass clumps are cheap blades: this many per old Kenney tuft.
const GRASS_DENSITY: float = 2.0


## Recipes: items are [kit folder, model, instances per 100 square metres, min scale, max scale].
static func recipe(preset_id: StringName) -> Dictionary:
	match preset_id:
		StylePresets.TOWN:
			return {
				"items": [
					[NATURE, "grass_leafs", 22.0, 1.4, 2.3], [NATURE, "plant_flatShort", 4.0, 1.3, 2.0], [NATURE, "flower_redA", 0.8, 1.2, 1.8],
					[NATURE, "flower_yellowA", 0.8, 1.2, 1.8], [NATURE, "flower_purpleA", 0.6, 1.2, 1.8], [NATURE, "mushroom_redGroup", 0.8, 1.4, 2.0],
					[NATURE, "stone_smallA", 1.2, 1.5, 2.4], [NATURE, "stump_round", 0.5, 1.5, 2.2],
				],
				"patches": [Color("6fae62"), Color("86c066"), Color("5a9a5a")], "patch_pattern": GroundDecals.Pattern.MOSS,
			}
		StylePresets.START:
			return {
				"items": [
					[NATURE, "grass_leafs", 28.0, 1.4, 2.3], [NATURE, "mushroom_tanGroup", 3.0, 1.6, 2.4], [NATURE, "mushroom_redGroup", 1.5, 1.4, 2.0],
					[NATURE, "flower_purpleB", 7.0, 1.3, 2.0], [NATURE, "flower_purpleC", 4.0, 1.3, 2.0], [NATURE, "stone_smallFlatA", 2.0, 1.4, 2.4], [NATURE, "plant_bush", 1.5, 1.6, 2.4],
				],
				"patches": [Color("4f8a6a"), Color("3f7a78"), Color("5a8a6a")], "patch_pattern": GroundDecals.Pattern.MOSS,
			}
		StylePresets.DNA:
			return {
				"items": [
					[FURNITURE, "books", 0.5, 1.4, 1.8], [FURNITURE, "cardboardBoxOpen", 0.35, 1.6, 2.2], [FURNITURE, "plantSmall1", 0.3, 1.8, 2.4],
					[FURNITURE, "cardboardBoxClosed", 0.35, 1.6, 2.2], [FURNITURE, "plantSmall2", 0.25, 1.8, 2.4], [FURNITURE, "lampRoundFloor", 0.12, 1.4, 1.6],
				],
				"patches": [Color("20262b"), Color("2b3238"), Color("171b1f")], "patch_pattern": GroundDecals.Pattern.DIRT,
			}
		StylePresets.GAINLANDS:
			return {
				"items": [
					[NATURE, "grass_leafs", 30.0, 1.4, 2.3], [NATURE, "flower_redB", 6.0, 1.3, 2.0], [NATURE, "flower_yellowB", 6.0, 1.3, 2.0], [NATURE, "flower_purpleA", 4.0, 1.3, 2.0],
					[NATURE, "plant_flatTall", 4.0, 1.3, 2.0], [NATURE, "stone_smallB", 1.0, 1.6, 2.6],
				],
				"patches": [Color("78c25a"), Color("5fb064"), Color("9bd070")], "patch_pattern": GroundDecals.Pattern.MOSS,
			}
		StylePresets.BUFFET:
			return {
				"items": [
					[FOOD, "cupcake", 0.5, 1.4, 1.9], [FOOD, "donut", 0.5, 1.4, 1.9], [FOOD, "muffin", 0.45, 1.4, 1.9], [FOOD, "cookie", 0.6, 1.4, 1.9],
					[FOOD, "loaf", 0.35, 1.4, 1.9], [FOOD, "pie", 0.25, 1.2, 1.6], [FOOD, "cheese", 0.3, 1.2, 1.6],
				],
				"patches": [Color("e8a85a"), Color("d98a4a"), Color("f0c070")], "patch_pattern": GroundDecals.Pattern.DIRT,
			}
		StylePresets.HEAP:
			return {
				"items": [
					[NATURE, "grass_leafs", 26.0, 1.4, 2.3], [NATURE, "plant_flatShort", 6.0, 1.3, 2.0], [NATURE, "mushroom_tanGroup", 2.0, 1.4, 2.2],
					[SURVIVAL, "box", 0.8, 1.2, 1.8], [SURVIVAL, "barrel", 0.5, 1.2, 1.6], [SURVIVAL, "bottle", 0.8, 1.6, 2.4], [SURVIVAL, "tree-log-small", 0.5, 1.3, 1.8],
					[NATURE, "stump_square", 0.6, 1.4, 2.0],
				],
				"patches": [Color("8a7a3a"), Color("9a6a3a"), Color("6a8a3a")], "patch_pattern": GroundDecals.Pattern.DIRT,
			}
		StylePresets.CAPITAL_FACADE, StylePresets.CAPITAL_FREED:
			return {
				"items": [
					[NATURE, "plant_bushLarge", 3.0, 1.6, 2.4], [NATURE, "flower_redC", 14.0, 1.3, 1.9], [NATURE, "flower_purpleC", 14.0, 1.3, 1.9], [NATURE, "flower_yellowC", 14.0, 1.3, 1.9], [NATURE, "flower_redA", 8.0, 1.3, 1.9],
					[NATURE, "grass_leafs", 18.0, 1.4, 2.0],
				],
				"patches": [Color("b8e8c8"), Color("d8c8f0"), Color("f0d0e0")], "patch_pattern": GroundDecals.Pattern.MOSS,
			}
		StylePresets.CAPITAL_OUTSKIRTS, StylePresets.CAPITAL_DARK:
			return {
				"items": [
					[NATURE, "stone_smallC", 2.2, 1.4, 2.6], [NATURE, "stone_smallFlatB", 1.8, 1.4, 2.4], [NATURE, "rock_smallA", 1.0, 1.5, 2.6],
					[NATURE, "grass_leafs", 12.0, 1.3, 2.0], [NATURE, "mushroom_tanGroup", 1.0, 1.4, 2.0], [SURVIVAL, "box", 0.4, 1.2, 1.8],
				],
				"patches": [Color("4a4258"), Color("5a4a60"), Color("3a3446")], "patch_pattern": GroundDecals.Pattern.DIRT,
			}
	return {"items": [], "patches": []}


## Builds the dressing under `parent` for walkable area `area`; `avoid` lists circles (Vector3(x, z, radius)) to leave empty (a hand-dressed square, say); `region` (pos -> bool) limits where items and patches go.
static func build(parent: Node3D, area: WalkableArea, preset_id: StringName, quality: int, avoid: Array[Vector3] = [], region: Callable = Callable(), region_share: float = 1.0) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ZoneDressing"
	parent.add_child(root)
	var bounds: Rect2 = area.map_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return root
	var data: Dictionary = recipe(preset_id)
	var items: Array = data.get("items", []) as Array
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(String(preset_id)) + (7 if region.is_valid() else 0)
	var chunks: Dictionary = {}
	var scatter: ScatterTool = ScatterTool.new()
	scatter.seed_value = hash(String(preset_id)) & 0xFFFF
	scatter.bounds = bounds
	scatter.keep_out_circles = avoid
	scatter.is_floor = func(pos: Vector3) -> bool: return area.is_floor_at(pos) and area.is_walkable(pos, 0.12) and (not region.is_valid() or bool(region.call(pos)))
	scatter.height_at = func(pos: Vector3) -> float: return area.height_at(pos)
	var budget: int = BUDGET[clampi(quality, 0, 2)]
	var placed: int = 0
	var density_scale: float = GraphicsQuality.foliage_density(quality)
	var area_m2: float = bounds.size.x * bounds.size.y * region_share
	for item: Array in items:
		var wanted: int = int(area_m2 / 100.0 * float(item[2]) * density_scale * 0.35 * (GRASS_DENSITY if StyleGrass.replaces(str(item[1])) else 1.0))
		wanted = mini(wanted, budget - placed)
		if wanted <= 0:
			continue
		var mesh: Mesh = ModelKit.kit_mesh(str(item[0]), str(item[1]))
		if mesh == null:
			continue
		var count: int = 0
		if StyleGrass.replaces(str(item[1])):
			# Grass is a uniform carpet of clumps: plain random placement.
			var tries: int = 0
			while count < wanted and tries < wanted * 10:
				tries += 1
				var pos: Vector3 = Vector3(rng.randf_range(bounds.position.x, bounds.end.x), 0.0, rng.randf_range(bounds.position.y, bounds.end.y))
				if not area.is_floor_at(pos) or not area.is_walkable(pos, 0.12) or _avoided(pos, avoid) or (region.is_valid() and not bool(region.call(pos))):
					continue
				pos.y = area.height_at(pos)
				var s: float = rng.randf_range(float(item[3]), float(item[4]))
				_add_to_chunk(chunks, mesh, str(item[1]), Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * s), pos), data)
				count += 1
			placed += count / 3
		else:
			# Everything else goes through the ScatterTool: clusters of three (big, medium, small), keep-outs respected.
			var entry: ScatterTool.Entry = ScatterTool.Entry.make(str(item[0]), str(item[1]), 1.0, float(item[3]), float(item[4]))
			for placement: ScatterTool.Placement in scatter.scatter(str(item[1]), [entry] as Array[ScatterTool.Entry], wanted, 3, 1.1):
				_add_to_chunk(chunks, mesh, str(item[1]), placement.transform(), data)
				count += 1
			placed += count
	for key: String in chunks:
		_make_multimesh(root, chunks[key] as Dictionary)
	_patches(root, area, bounds, data, rng, quality, region)
	_decals(root, area, bounds, preset_id, rng, quality, region, avoid)
	if OS.get_environment("STYLE_DEBUG") != "":
		print("zone_dressing decals ", preset_id, " ", GroundDecals.report(), " budget left ", GroundDecals.budget_left())
	return root


static func _avoided(pos: Vector3, avoid: Array[Vector3]) -> bool:
	for circle: Vector3 in avoid:
		if Vector2(pos.x - circle.x, pos.z - circle.y).length() < circle.z:
			return true
	return false


static func _make_multimesh(root: Node3D, chunk: Dictionary) -> void:
	var transforms: Array[Transform3D] = chunk["transforms"] as Array[Transform3D]
	var mesh: Mesh = chunk["mesh"] as Mesh
	if StyleGrass.replaces(str(chunk["model"])):
		var grass: Array[Color] = chunk["grass"] as Array[Color]
		root.add_child(StyleGrass.multimesh_instance(transforms, grass[0], grass[1]))
		return
	var foliage: bool = _is_foliage(str(chunk["model"]))
	for surface: int in range(mesh.get_surface_count()):
		var toon: ShaderMaterial = StyleToon.toon_for(mesh.surface_get_material(surface), 1.0 if foliage else -1.0)
		if toon != null:
			mesh.surface_set_material(surface, toon)
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(instance)


static func _is_foliage(model: String) -> bool:
	for word: String in StyleToon.FOLIAGE_WORDS:
		if model.to_lower().contains(word):
			return true
	return false


static func _patches(root: Node3D, area: WalkableArea, bounds: Rect2, data: Dictionary, rng: RandomNumberGenerator, quality: int, region: Callable = Callable()) -> void:
	var colors: Array = data.get("patches", []) as Array
	if colors.is_empty():
		return
	var pattern: int = int(data.get("patch_pattern", GroundDecals.Pattern.MOSS))
	var count: int = clampi(int(bounds.size.x * bounds.size.y / 250.0), 4, [8, 26, 40][clampi(quality, 0, 2)])
	var made: int = 0
	var tries: int = 0
	while made < count and tries < count * 12:
		tries += 1
		var pos: Vector3 = Vector3(rng.randf_range(bounds.position.x, bounds.end.x), 0.0, rng.randf_range(bounds.position.y, bounds.end.y))
		if not area.is_floor_at(pos) or not area.is_floor_at(pos + Vector3(1.0, 0.0, 0.0)) or not area.is_floor_at(pos + Vector3(0.0, 0.0, 1.0)) or (region.is_valid() and not bool(region.call(pos))):
			continue
		pos.y = area.height_at(pos)
		var base: Color = colors[made % colors.size()] as Color
		var material: ShaderMaterial = GroundDecals.material(pattern as GroundDecals.Pattern, base, base.lerp(colors[(made + 1) % colors.size()] as Color, 0.6), base.darkened(0.4), GroundDecals.Shape.DISC, 1.0, 0.7, float(made))
		GroundDecals.disc(root, pos, rng.randf_range(1.0, 2.4), material, rng.randf_range(0.6, 1.0), rng.randf() * 180.0, 0.001 * float(made))
		made += 1


# ---- Decals (cracks, puddles, stains, leaf piles, scorch ...) through the GroundDecals authoring API ----------------------------------


## Per preset: [GroundDecals.Kind, count at High, min radius, max radius, palette colours].
static func decal_recipe(preset_id: StringName) -> Array:
	match preset_id:
		StylePresets.TOWN:
			return [
				[GroundDecals.Kind.LEAF_PILE, 8, 0.8, 1.5, [Color("d9a03a"), Color("b8652a")]],
				[GroundDecals.Kind.PUDDLE, 5, 0.9, 1.6, [Color("8fd0e8"), Color("4f95c8")]],
				[GroundDecals.Kind.STAIN, 5, 0.7, 1.4, [Color("6a4a30"), Color("86623e")]],
			]
		StylePresets.START:
			return [
				[GroundDecals.Kind.MOSS_PATCH, 8, 0.9, 1.8, [Color("3f8a7a"), Color("5aa890")]],
				[GroundDecals.Kind.PUDDLE, 3, 0.5, 0.9, [Color("9ab8ff"), Color("4a5ab8")]],
			]
		StylePresets.DNA:
			return [
				[GroundDecals.Kind.STAIN, 8, 0.4, 0.9, [Color("3a2c22"), Color("52402f")]],
				[GroundDecals.Kind.CRACKS, 8, 1.2, 2.2, [Color("1b2024"), Color("1b2024"), Color("0b0e10")]],
			]
		StylePresets.HEAP:
			return [
				[GroundDecals.Kind.PUDDLE, 8, 1.0, 1.9, [Color("7aa890"), Color("3a6a5a")]],
				[GroundDecals.Kind.STAIN, 10, 0.8, 1.8, [Color("2e241a"), Color("4a3a24")]],
				[GroundDecals.Kind.SCORCH, 3, 1.0, 1.8, [Color("3a2c20"), Color("3a2c20"), Color("100c08")]],
				[GroundDecals.Kind.LEAF_PILE, 6, 0.8, 1.5, [Color("a8a03a"), Color("7a7a2a")]],
			]
		StylePresets.BUFFET:
			return [
				[GroundDecals.Kind.STAIN, 12, 0.6, 1.4, [Color("a8322a"), Color("c8643a")]],
				[GroundDecals.Kind.PUDDLE, 4, 0.5, 1.0, [Color("c8742a"), Color("8a4a1c")]],
			]
		StylePresets.GAINLANDS:
			return [
				[GroundDecals.Kind.DIRT_PATCH, 8, 1.0, 2.0, [Color("c8a870"), Color("a88850")]],
				[GroundDecals.Kind.CHALK, 0, 1.0, 1.0, []],
			]
		StylePresets.CAPITAL_OUTSKIRTS, StylePresets.CAPITAL_DARK:
			return [
				[GroundDecals.Kind.CRACKS, 16, 1.4, 2.8, [Color("2a2630"), Color("2a2630"), Color("0c0a10")]],
				[GroundDecals.Kind.SCORCH, 5, 1.0, 2.0, [Color("2e2a28"), Color("2e2a28"), Color("0e0c0c")]],
				[GroundDecals.Kind.STAIN, 8, 0.8, 1.6, [Color("3a3030"), Color("504444")]],
			]
	return []


static func _decals(root: Node3D, area: WalkableArea, bounds: Rect2, preset_id: StringName, rng: RandomNumberGenerator, quality: int, region: Callable, avoid: Array[Vector3]) -> void:
	GroundDecals.begin(quality)
	var scale_by_quality: float = [0.35, 0.7, 1.0][clampi(quality, 0, 2)]
	var kind_index: int = 0
	for entry: Array in decal_recipe(preset_id):
		var count: int = int(round(float(entry[1]) * scale_by_quality))
		var palette: Array[Color] = []
		palette.assign(entry[4] as Array)
		var made: int = 0
		var tries: int = 0
		while made < count and tries < count * 14:
			tries += 1
			var pos: Vector3 = Vector3(rng.randf_range(bounds.position.x, bounds.end.x), 0.0, rng.randf_range(bounds.position.y, bounds.end.y))
			if not area.is_floor_at(pos) or not area.is_walkable(pos, 0.3) or _avoided(pos, avoid) or (region.is_valid() and not bool(region.call(pos))):
				continue
			pos.y = area.height_at(pos)
			pos.y = _decal_height(area, pos, float(entry[3]))
			var radius: float = rng.randf_range(float(entry[2]), float(entry[3]))
			if OS.get_environment("STYLE_DEBUG") != "" and made == 0:
				print("decal ", entry[0], " at ", pos, " r ", radius)
			if GroundDecals.add_patch(root, pos, radius, entry[0] as GroundDecals.Kind, palette, float(made + kind_index * 17), rng.randf_range(0.6, 1.0), rng.randf() * 180.0) == null:
				return
			made += 1
		kind_index += 1


## The highest ground under a decal of up to `radius` (centre and eight ring points), so a flat decal never sinks into a bump.
static func _decal_height(area: WalkableArea, pos: Vector3, radius: float) -> float:
	var top: float = area.height_at(pos)
	for i: int in range(8):
		var angle: float = TAU * float(i) / 8.0
		top = maxf(top, area.height_at(pos + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)))
	return top


static func _add_to_chunk(chunks: Dictionary, mesh: Mesh, model: String, xform: Transform3D, data: Dictionary) -> void:
	var pos: Vector3 = xform.origin
	var key: String = "%s|%d|%d" % [model, int(floor(pos.x / CHUNK)), int(floor(pos.z / CHUNK))]
	if not chunks.has(key):
		chunks[key] = {"mesh": mesh, "model": model, "transforms": [] as Array[Transform3D], "grass": StyleGrass.colors_for(data.get("patches", []) as Array)}
	(chunks[key]["transforms"] as Array[Transform3D]).append(xform)
