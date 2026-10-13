class_name TownKit
extends RefCounted
## Puts the kit (vertical slice, Part E) into the town: a `TownLayout.Shop` with a `preset` becomes a `BuildingKit` building at its place, with its circle obstacles, a soft AO
## skirt and warm light pools under its lit windows. Pure placement: positions, anchors and gameplay data stay in `TownLayout`.


## Builds the shop's building under `parent`, registers its obstacles on `town` and returns the building node.
static func place_building(parent: Node3D, town: TownBuilder, shop: TownLayout.Shop) -> Node3D:
	var building: Node3D = BuildingPresets.build(shop.preset, shop.overrides, shop.tint)
	building.name = "Building_%s" % (shop.key if shop.key != "" else shop.label.replace(" ", "_"))
	parent.add_child(building)
	building.position = shop.center
	building.rotation_degrees.y = shop.yaw
	var spec: Dictionary = BuildingPresets.spec(shop.preset, shop.overrides)
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(shop.yaw))
	for circle: Vector3 in BuildingKit.obstacle_circles(spec, 0.05):
		var world: Vector3 = shop.center + basis * Vector3(circle.x, 0.0, circle.y)
		town.obstacles.append(Vector3(world.x, world.z, circle.z))
	dress(parent, building, spec)
	return building


## The ground treatment of a placed building: the AO skirt and warm pools of light in front of its lit ground-floor windows.
static func dress(parent: Node3D, building: Node3D, spec: Dictionary) -> void:
	var yaw: float = building.rotation_degrees.y
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	KitAO.footprint(parent, building.position, Vector2(float(spec.get("width", 6.0)), float(spec.get("depth", 5.0))), yaw)
	if building.has_meta("glows"):
		for spot: Variant in building.get_meta("glows") as Array:
			var world_point: Vector3 = building.position + basis * (spot as Vector3)
			GroundDecals.glow(parent, Vector3(world_point.x, 0.0, world_point.z), 2.1, Color("ffb45a"), 0.1)


## World position of a building's smoke points (chimney tops).
static func smoke_points(building: Node3D) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if not building.has_meta("smoke"):
		return result
	for point: Variant in building.get_meta("smoke") as Array:
		result.append(building.global_transform * (point as Vector3))
	return result
