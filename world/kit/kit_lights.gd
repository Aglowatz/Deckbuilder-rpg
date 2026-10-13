class_name KitLights
extends RefCounted
## Turns the "lights" metadata of kit buildings and props (lanterns, stall lamps) into real warm OmniLight3Ds, registers them with the style rig light budget (only the nearest
## few stay on, GraphicsQuality.light_budget) and lays a soft additive glow pool under each lantern so the ones the budget switches off still read.

const WARM: Color = Color("ffb45a")


## Walks `root` (which must be in the tree) and creates the lights under `parent`. Returns them so the caller can count them.
static func attach(root: Node3D, parent: Node3D, rig: StyleRig = null, glow_pools: bool = true) -> Array[OmniLight3D]:
	var created: Array[OmniLight3D] = []
	var carriers: Array[Node] = root.find_children("*", "Node3D", true, false)
	carriers.append(root)
	for node: Node in carriers:
		if not node.has_meta("lights"):
			continue
		var carrier: Node3D = node as Node3D
		if not carrier.is_inside_tree():
			continue
		var list: Array = carrier.get_meta("lights") as Array
		for item: Variant in list:
			var data: Dictionary = item as Dictionary
			var light: OmniLight3D = OmniLight3D.new()
			light.light_color = data.get("color", WARM) as Color
			light.light_energy = float(data.get("energy", 1.6))
			light.omni_range = float(data.get("range", 6.0))
			light.omni_attenuation = 1.3
			light.shadow_enabled = false
			parent.add_child(light)
			var world: Vector3 = carrier.global_transform * (data["pos"] as Vector3)
			light.global_position = world
			created.append(light)
			if glow_pools and str(data.get("kind", "")) == "lantern":
				GroundDecals.glow(parent, Vector3(world.x, 0.0, world.z), 2.4, light.light_color, 0.16)
	if rig != null and not created.is_empty():
		rig.register_lights(created)
	return created
