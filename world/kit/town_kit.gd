class_name TownKit
extends RefCounted
## Puts the kit (vertical slice, Part E) into the town: a `TownLayout.Shop` with a `preset` becomes a `BuildingKit` building at its place, with its circle obstacles, a soft AO
## skirt, worn earth at the doorstep and its lights / chimney smoke registered for the scene. Pure placement: positions, anchors and gameplay data stay in `TownLayout`.


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
	KitAO.footprint(parent, shop.center, Vector2(float(spec.get("width", 6.0)), float(spec.get("depth", 5.0))), shop.yaw)
	return building


## World position of a building's smoke points (chimney tops).
static func smoke_points(building: Node3D) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if not building.has_meta("smoke"):
		return result
	for point: Variant in building.get_meta("smoke") as Array:
		result.append(building.global_transform * (point as Vector3))
	return result
