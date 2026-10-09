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
