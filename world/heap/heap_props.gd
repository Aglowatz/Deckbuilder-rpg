class_name HeapProps
extends RefCounted
## Procedural props of the Verdant Heap, built from primitives in the shared palette (`HeapMaterials`) and dressed with
## Kenney Nature / Survival / Car Kit models: the scrap barn and windmills, the harvest table, the swap shed, the
## compost bin and heaps, the druid shrine, stables with their animals, crop plots, the county-fair stage, rusted
## wrecks overgrown with moss, junk piles, the landfill hatch, vine bridges, beanstalks and trash chutes. Every
## function returns a Node3D standing at the origin, facing +z (towards the camera). Text on props comes from the
## zone's story file (the `story` argument) so it can be rewritten without touching code.

const H = preload("res://world/heap/heap_materials.gd")
const B = preload("res://world/buffet/buffet_props.gd")


# ---- Dressing helpers ----------------------------------------------------------------------------


static func moss_patches(parent: Node3D, count: int, radius: float, height: float, seed_value: int = 0) -> void:
	for index: int in range(count):
		var angle: float = float(index * 7 + seed_value) * 1.9
		var spread: float = radius * (0.35 + 0.65 * float((index * 5 + seed_value) % 7) / 7.0)
		B.ball(parent, 0.22 + 0.06 * float(index % 3), H.flat(H.MOSS if index % 2 == 0 else H.MOSS.lightened(0.15)), Vector3(cos(angle) * spread, height * (0.3 + 0.7 * float((index * 3 + seed_value) % 5) / 5.0), sin(angle) * spread), Vector3(1.3, 0.55, 1.3))


static func flowers_on(parent: Node3D, count: int, radius: float, height: float) -> void:
	var colors: Array[Color] = [Color(1.0, 0.45, 0.65), Color(1.0, 0.85, 0.3), Color(0.7, 0.55, 1.0), Color(1.0, 1.0, 1.0)]
	for index: int in range(count):
		var angle: float = float(index) * 2.4
		var spread: float = radius * (0.2 + 0.8 * float((index * 3) % 5) / 5.0)
		B.cylinder(parent, 0.02, 0.02, 0.18, H.flat(H.VINE), Vector3(cos(angle) * spread, height + 0.09, sin(angle) * spread), 4)
		B.ball(parent, 0.08, H.flat(colors[index % colors.size()]), Vector3(cos(angle) * spread, height + 0.2, sin(angle) * spread))


static func tinted(node: Node3D, color: Color) -> Node3D:
	ModelKit.tint(node, color)
	return node


# ---- The Compost Grange --------------------------------------------------------------------------


static func barn(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(7.0, 3.2, 4.4), H.flat(H.RUST), Vector3(0, 1.6, -0.2))
	for index: int in range(7):
		B.box(root, Vector3(0.06, 3.1, 4.5), H.flat(H.RUST_DARK), Vector3(-3.0 + float(index), 1.6, -0.2))
	B.box(root, Vector3(7.6, 0.18, 2.9), H.flat(H.METAL), Vector3(0, 3.9, -1.55), Vector3(36, 0, 0))
	B.box(root, Vector3(7.6, 0.18, 2.9), H.flat(H.METAL_DARK), Vector3(0, 3.9, 1.15), Vector3(-36, 0, 0))
	B.box(root, Vector3(2.4, 2.4, 0.2), H.flat(H.WOOD_DARK), Vector3(0, 1.2, 2.05))
	B.box(root, Vector3(0.1, 2.4, 0.22), H.flat(H.STRAW), Vector3(0, 1.2, 2.12), Vector3(0, 0, 0))
	B.box(root, Vector3(2.5, 0.12, 0.26), H.flat(H.STRAW), Vector3(0, 1.2, 2.14), Vector3(0, 0, 40))
	B.box(root, Vector3(2.5, 0.12, 0.26), H.flat(H.STRAW), Vector3(0, 1.2, 2.14), Vector3(0, 0, -40))
	moss_patches(root, 10, 3.2, 3.8, 1)
	flowers_on(root, 8, 3.0, 3.6)
	B.label(root, story.text("prop.barn"), Vector3(0, 3.0, 2.2), 0.006, Color(1.0, 0.95, 0.8), 4.0, 6)
	for index: int in range(3):
		HeapModels.put(root, HeapModels.survival("barrel"), Vector3(-3.6 + float(index) * 0.5, 0.0, 2.6), float(index) * 40.0, 3.0)
	return root


static func windmill(blade_spinner: bool = true) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.35, 0.7, 4.0, H.flat(H.WOOD), Vector3(0, 2.0, 0), 8)
	for index: int in range(4):
		B.box(root, Vector3(0.9, 0.08, 0.05), H.flat(H.METAL_DARK), Vector3(0, 0.5 + float(index) * 0.9, 0.5), Vector3(0, 0, 20.0 * float(index)))
	var hub: Node3D = Node3D.new()
	hub.name = "Hub"
	hub.position = Vector3(0, 4.1, 0.55)
	root.add_child(hub)
	B.ball(hub, 0.3, H.flat(H.RUST), Vector3.ZERO)
	for index: int in range(4):
		var blade: Node3D = Node3D.new()
		blade.rotation.z = TAU * float(index) / 4.0
		hub.add_child(blade)
		B.box(blade, Vector3(0.7, 2.0, 0.05), H.flat(H.METAL if index % 2 == 0 else H.RUST), Vector3(0.0, 1.3, 0.0))
		B.box(blade, Vector3(0.05, 2.2, 0.08), H.flat(H.WOOD_DARK), Vector3(-0.35, 1.3, 0.0))
	if blade_spinner:
		root.set_meta("spinner", hub)
	moss_patches(root, 5, 0.8, 1.2, 4)
	return root


static func harvest_table() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(4.0, 0.2, 2.2), H.flat(H.WOOD), Vector3(0, 1.3, 0))
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			B.box(root, Vector3(0.2, 1.3, 0.2), H.flat(H.WOOD_DARK), Vector3(sx * 1.8, 0.65, sz * 0.9))
	B.box(root, Vector3(4.1, 0.05, 0.8), H.flat(Color(0.95, 0.3, 0.3)), Vector3(0, 1.42, 0))
	BuffetModels.put_food(root, "bowl-soup", Vector3(-1.4, 1.45, 0.4), 0.0, 2.2)
	BuffetModels.put_food(root, "bread", Vector3(1.3, 1.45, 0.5), 15.0, 2.4)
	BuffetModels.put_food(root, "cheese", Vector3(0.1, 1.45, 0.6), 0.0, 1.6)
	BuffetModels.put_food(root, "honey", Vector3(-0.5, 1.45, -0.5), 0.0, 2.2)
	HeapModels.put(root, HeapModels.nature("crop_pumpkin"), Vector3(1.4, 1.42, -0.5), 20.0, 2.2)
	HeapModels.put(root, HeapModels.nature("crop_carrot"), Vector3(0.6, 1.42, -0.6), 70.0, 2.4)
	HeapModels.put(root, HeapModels.nature("crop_melon"), Vector3(-1.5, 1.42, -0.5), 0.0, 2.0)
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(3.6, 0.1, 0.45), H.flat(H.WOOD_DARK), Vector3(0, 0.7, side * 1.7))
	B.steam(root, Vector3(0, 2.1, 0), 8, 0.9, 0.8)
	return root


static func swap_shed(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var bench: Node3D = HeapModels.survival("workbench")
	root.add_child(bench)
	bench.scale = Vector3.ONE * 4.2
	for index: int in range(4):
		B.box(root, Vector3(0.9, 0.06, 1.8), H.flat(H.METAL if index % 2 == 0 else H.RUST), Vector3(-1.35 + float(index) * 0.9, 2.6, -0.2), Vector3(-14, 0, 0))
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.06, 0.06, 2.6, H.flat(H.WOOD_DARK), Vector3(side * 1.7, 1.3, 0.7), 6)
	HeapModels.put(root, HeapModels.survival("bucket"), Vector3(-1.1, 1.0, 0.4), 0.0, 4.0)
	HeapModels.put(root, HeapModels.survival("box-large"), Vector3(1.2, 0.5, 0.0), 30.0, 3.0)
	B.box(root, Vector3(1.2, 0.8, 0.06), H.flat(Color(0.95, 0.92, 0.8)), Vector3(0.2, 2.0, -0.3), Vector3(-10, 0, 0))
	B.label(root, story.text("prop.swap_shed"), Vector3(0.2, 2.0, -0.24), 0.0034, Color(0.25, 0.12, 0.05), 1.1, 0)
	return root


static func compost_bin() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.6, 1.2, 2.0), H.flat(H.WOOD), Vector3(0, 0.6, 0))
	B.box(root, Vector3(2.3, 0.1, 1.7), H.flat(H.DIRT_DARK), Vector3(0, 1.22, 0))
	B.ball(root, 1.0, H.flat(H.DIRT), Vector3(0, 1.2, 0), Vector3(1.1, 0.5, 0.8), true)
	for index: int in range(6):
		B.box(root, Vector3(2.7, 0.06, 0.12), H.flat(H.WOOD_DARK), Vector3(0, 0.15 + float(index) * 0.2, 1.02))
	flowers_on(root, 6, 1.0, 1.4)
	B.steam(root, Vector3(0, 1.6, 0), 8, 0.7, 0.9)
	for index: int in range(5):
		B.ball(root, 0.05, H.glow(Color(0.1, 0.1, 0.1), 0.2), Vector3(-0.6 + float(index) * 0.3, 2.0 + 0.1 * float(index % 2), 0.2))
	return root


static func shrine(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 1.5, 1.7, 0.3, H.flat(H.STONE), Vector3(0, 0.15, 0), 14)
	B.cylinder(root, 0.5, 0.6, 0.9, H.flat(H.MOSS.darkened(0.2)), Vector3(0, 0.75, 0), 8)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		var stone: Node3D = HeapModels.nature("stone_tallA" if index % 2 == 0 else "rock_tallB")
		root.add_child(stone)
		stone.scale = Vector3.ONE * 2.6
		stone.position = Vector3(cos(angle) * 1.6, 0.0, sin(angle) * 1.6)
		stone.rotation_degrees.y = rad_to_deg(-angle)
	var bloom: MeshInstance3D = B.ball(root, 0.28, H.glow(H.BLOOM, 1.8), Vector3(0, 1.5, 0))
	bloom.name = "Bloom"
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0
		B.ball(root, 0.14, H.glow(H.BLOOM.lightened(0.3), 1.4), Vector3(cos(angle) * 0.34, 1.5, sin(angle) * 0.34), Vector3(1.0, 0.5, 1.0))
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.7, 0.9)
	light.light_energy = 0.9
	light.omni_range = 5.0
	light.position = Vector3(0, 1.8, 0)
	root.add_child(light)
	B.label(root, story.text("prop.shrine"), Vector3(0, 2.3, 0.2), 0.005, Color(1.0, 0.85, 0.95), 2.4, 6)
	return root


static func trough() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 0.5, 0.9), H.flat(H.WOOD), Vector3(0, 0.45, 0))
	B.box(root, Vector3(2.1, 0.1, 0.6), H.flat(H.DIRT_DARK), Vector3(0, 0.72, 0))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.12, 0.5, 0.9), H.flat(H.WOOD_DARK), Vector3(side * 1.1, 0.25, 0))
	HeapModels.put(root, HeapModels.survival("bucket"), Vector3(-0.6, 0.8, 0.0), 0.0, 3.0)
	HeapModels.put(root, HeapModels.survival("box-open"), Vector3(0.8, 0.8, 0.0), 40.0, 2.2)
	return root


static func stable(kind: String) -> Node3D:
	var root: Node3D = Node3D.new()
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			B.cylinder(root, 0.1, 0.12, 2.6, H.flat(H.WOOD_DARK), Vector3(sx * 1.7, 1.3, sz * 1.3), 6)
	B.box(root, Vector3(4.2, 0.14, 3.2), H.flat(H.METAL), Vector3(0, 2.7, 0), Vector3(0, 0, 4))
	B.box(root, Vector3(3.4, 0.9, 0.12), H.flat(H.WOOD), Vector3(0, 0.45, -1.3))
	B.box(root, Vector3(3.4, 0.14, 0.12), H.flat(H.WOOD), Vector3(0, 1.0, 1.3))
	B.cylinder(root, 1.4, 1.5, 0.12, H.flat(H.STRAW), Vector3(0, 0.06, 0), 12)
	var animal: Node3D = HeapModels.pet("animal-hog" if kind == "boar" else "animal-deer")
	animal.name = "StableAnimal"
	root.add_child(animal)
	animal.scale = Vector3.ONE * 1.5
	animal.position = Vector3(0, 0.1, 0.1)
	if kind == "goat":
		ModelKit.tint(animal, Color(1.2, 1.15, 1.0))
	var player: AnimationPlayer = ModelKit.animation_player(animal)
	if player != null and player.has_animation("idle"):
		player.play("idle")
	root.set_meta("animal", animal)
	moss_patches(root, 4, 1.8, 2.5, 7)
	return root


static func exit_arch(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		for index: int in range(4):
			var tire: MeshInstance3D = B.cylinder(root, 0.8, 0.8, 0.5, H.flat(H.TIRE), Vector3(side * 2.9, 0.25 + float(index) * 0.5, 0), 14)
			tire.rotation_degrees.x = 0.0
			B.cylinder(root, 0.35, 0.35, 0.52, H.flat(H.METAL_DARK), Vector3(side * 2.9, 0.25 + float(index) * 0.5, 0), 10)
		B.box(root, Vector3(0.5, 1.4, 0.5), H.flat(H.METAL), Vector3(side * 2.9, 2.7, 0))
	B.box(root, Vector3(6.8, 0.8, 0.5), H.flat(H.RUST), Vector3(0, 3.6, 0))
	B.box(root, Vector3(6.4, 0.1, 0.52), H.flat(H.RUST_DARK), Vector3(0, 3.2, 0))
	B.label(root, story.text("prop.arch"), Vector3(0, 3.6, 0.28), 0.0068, Color(1.0, 0.97, 0.85), 6.2)
	moss_patches(root, 12, 3.4, 3.8, 2)
	flowers_on(root, 10, 3.2, 3.9)
	return root


static func crop_plot(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(4.2, 0.16, 2.6), H.flat(H.DIRT_DARK), Vector3(0, 0.08, 0))
	for row: int in range(3):
		B.box(root, Vector3(3.9, 0.14, 0.45), H.flat(H.DIRT.lightened(0.05)), Vector3(0, 0.2, -0.8 + float(row) * 0.8))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(4.4, 0.22, 0.12), H.flat(H.WOOD), Vector3(0, 0.12, side * 1.3))
	var sprout: Node3D = Node3D.new()
	sprout.name = "Sprout"
	root.add_child(sprout)
	for index: int in range(4):
		HeapModels.put(sprout, HeapModels.nature("crops_leafsStageA"), Vector3(-1.4 + float(index) * 0.9, 0.2, -0.8 + float(index % 3) * 0.8), float(index) * 50.0, 2.6)
	var ripe: Node3D = Node3D.new()
	ripe.name = "Ripe"
	root.add_child(ripe)
	for index: int in range(4):
		HeapModels.put(ripe, HeapModels.nature("crop_pumpkin" if index % 2 == 0 else "crop_melon"), Vector3(-1.4 + float(index) * 0.9, 0.2, -0.8 + float(index % 3) * 0.8), float(index) * 50.0, 3.0)
	sprout.visible = false
	ripe.visible = false
	root.set_meta("sprout", sprout)
	root.set_meta("ripe", ripe)
	B.label(root, story.text("prop.crop_plot"), Vector3(0, 1.0, 1.2), 0.0034, Color(1.0, 0.95, 0.7), 1.4, 6)
	return root


static func appliance_ring() -> Node3D:
	var root: Node3D = Node3D.new()
	var colors: Array[Color] = [Color(0.92, 0.92, 0.9), Color(0.7, 0.82, 0.6), Color(0.95, 0.85, 0.6), Color(0.85, 0.88, 0.92)]
	for index: int in range(9):
		var angle: float = TAU * (float(index) + 0.5) / 10.0 + 0.5
		var pos: Vector3 = Vector3(cos(angle) * 3.4, 0.0, sin(angle) * 3.4)
		var unit: Node3D = Node3D.new()
		unit.position = pos
		unit.rotation.y = -angle + PI * 0.5
		root.add_child(unit)
		var tall: bool = index % 3 != 1
		B.box(unit, Vector3(1.1, 2.0 if tall else 1.1, 1.0), H.flat(colors[index % colors.size()]), Vector3(0, 1.0 if tall else 0.55, 0))
		B.box(unit, Vector3(0.9, 0.05, 0.05), H.flat(H.METAL_DARK), Vector3(0.0, 1.5 if tall else 0.8, 0.52))
		if not tall:
			B.cylinder(unit, 0.35, 0.35, 0.06, H.flat(H.METAL_DARK), Vector3(0, 0.6, 0.52), 10).rotation_degrees.x = 90.0
		moss_patches(unit, 3, 0.5, 1.8 if tall else 1.0, index)
	flowers_on(root, 14, 3.0, 0.0)
	return root


static func compost_heap() -> Node3D:
	var root: Node3D = Node3D.new()
	B.ball(root, 2.0, H.flat(H.DIRT_DARK), Vector3(0, 0, 0), Vector3(1.0, 0.6, 1.0), true)
	moss_patches(root, 9, 1.6, 1.0, 3)
	flowers_on(root, 10, 1.6, 0.9)
	B.steam(root, Vector3(0, 1.4, 0), 8, 1.0, 0.9)
	HeapModels.put(root, HeapModels.nature("crop_pumpkin"), Vector3(0.8, 0.9, 0.4), 30.0, 2.0)
	return root


static func scarecrow() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.07, 0.09, 2.6, H.flat(H.WOOD_DARK), Vector3(0, 1.3, 0), 6)
	B.box(root, Vector3(1.8, 0.1, 0.1), H.flat(H.WOOD_DARK), Vector3(0, 1.9, 0))
	B.box(root, Vector3(1.0, 1.0, 0.4), H.flat(Color(0.3, 0.4, 0.55)), Vector3(0, 1.5, 0))
	B.ball(root, 0.32, H.flat(H.STRAW), Vector3(0, 2.35, 0))
	B.cylinder(root, 0.55, 0.55, 0.05, H.flat(H.STRAW.darkened(0.2)), Vector3(0, 2.6, 0), 12)
	B.cylinder(root, 0.25, 0.3, 0.3, H.flat(H.STRAW.darkened(0.2)), Vector3(0, 2.75, 0), 12)
	return root


# ---- Fair, wrecks, junk ---------------------------------------------------------------------------


static func fair_stage(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(5.0, 0.3, 3.0), H.flat(H.WOOD), Vector3(0, 0.15, 0))
	for index: int in range(5):
		B.box(root, Vector3(1.0, 2.6, 0.08), H.flat(H.METAL if index % 2 == 0 else H.METAL_DARK), Vector3(-2.0 + float(index), 1.6, -1.3))
	var belt: MeshInstance3D = B.box(root, Vector3(4.2, 0.2, 0.7), H.flat(H.METAL_DARK), Vector3(0, 0.9, -0.2))
	belt.name = "Belt"
	for index: int in range(7):
		B.cylinder(root, 0.1, 0.1, 0.72, H.flat(H.METAL), Vector3(-1.9 + float(index) * 0.63, 1.02, -0.2), 8).rotation_degrees.x = 90.0
	var bin_colors: Array[Color] = [Color(0.45, 0.32, 0.18), Color(0.55, 0.6, 0.65), Color(0.4, 0.7, 0.5), Color(0.3, 0.5, 0.85)]
	for index: int in range(4):
		B.box(root, Vector3(0.8, 0.7, 0.7), H.flat(bin_colors[index]), Vector3(-1.5 + float(index) * 1.0, 0.65, 0.9))
	# Bunting and the blue-ribbon banner.
	for index: int in range(8):
		var flag: MeshInstance3D = B.box(root, Vector3(0.3, 0.3, 0.02), H.flat([Color(1.0, 0.4, 0.4), Color(1.0, 0.9, 0.3), Color(0.4, 0.8, 1.0), Color(0.6, 1.0, 0.5)][index % 4]), Vector3(-2.3 + float(index) * 0.66, 3.2 - 0.25 * sin(float(index) * 0.45), -1.2), Vector3(0, 0, 45))
		flag.name = "Flag%d" % index
	B.box(root, Vector3(5.2, 0.9, 0.1), H.flat(Color(0.2, 0.35, 0.8)), Vector3(0, 3.9, -1.25))
	B.label(root, story.text("prop.fair"), Vector3(0, 3.9, -1.18), 0.0064, Color(1.0, 0.97, 0.85), 5.0, 4)
	return root


static func fridge() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.4, 2.4, 1.2), H.flat(Color(0.82, 0.78, 0.68)), Vector3(0, 1.2, 0))
	B.box(root, Vector3(0.1, 2.3, 1.0), H.flat(Color(0.7, 0.4, 0.2)), Vector3(0.78, 1.2, 0.8), Vector3(0, -50, 0))
	moss_patches(root, 8, 0.7, 2.4, 5)
	flowers_on(root, 5, 0.6, 2.4)
	return root


static func haybale(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var bale: MeshInstance3D = B.cylinder(root, 0.8, 0.8, 1.1, H.flat(H.STRAW if variant % 2 == 0 else H.GOLD_FIELD), Vector3(0, 0.8, 0), 14)
	bale.rotation_degrees.z = 90.0
	for index: int in range(3):
		B.cylinder(root, 0.81, 0.81, 0.06, H.flat(H.STRAW.darkened(0.3)), Vector3(-0.3 + float(index) * 0.3, 0.8, 0), 14).rotation_degrees.z = 90.0
	return root


static func beanstalk_mound(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	B.ball(root, 0.9, H.flat(H.DIRT_DARK), Vector3(0, 0, 0), Vector3(1.0, 0.5, 1.0), true)
	B.ball(root, 0.4, H.flat(H.DIRT.darkened(0.3)), Vector3(0, 0.38, 0), Vector3(1.0, 0.4, 1.0), true)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		var stone: Node3D = HeapModels.nature("stone_smallA")
		root.add_child(stone)
		stone.scale = Vector3.ONE * 2.0
		stone.position = Vector3(cos(angle) * 1.1, 0.0, sin(angle) * 1.1)
	var bud: MeshInstance3D = B.ball(root, 0.14, H.glow(Color(0.7, 1.0, 0.4), 1.2), Vector3(0, 0.55, 0))
	bud.name = "Bud"
	return root


static func junk_dam() -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 17
	B.ball(root, 1.9, H.flat(H.RUST_DARK), Vector3(0, 0, 0), Vector3(1.1, 0.9, 0.9), true)
	for index: int in range(7):
		var piece: Node3D = HeapModels.car("debris-tire" if index % 3 == 0 else ("debris-door" if index % 3 == 1 else "debris-plate-a"))
		root.add_child(piece)
		piece.scale = Vector3.ONE * 3.4
		piece.position = Vector3(rng.randf_range(-1.4, 1.4), rng.randf_range(0.3, 1.5), rng.randf_range(-0.7, 0.7))
		piece.rotation_degrees = Vector3(rng.randf_range(0, 90), rng.randf_range(0, 360), rng.randf_range(0, 90))
	B.cylinder(root, 0.7, 0.7, 0.6, H.flat(H.TIRE), Vector3(-0.9, 0.3, 0.9), 14)
	B.cylinder(root, 0.7, 0.7, 0.6, H.flat(H.TIRE), Vector3(1.0, 0.3, 0.8), 14)
	moss_patches(root, 8, 1.6, 1.4, 2)
	return root


static func hollow_log() -> Node3D:
	var root: Node3D = Node3D.new()
	var log_node: Node3D = HeapModels.nature("log_large")
	root.add_child(log_node)
	log_node.scale = Vector3.ONE * 4.0
	log_node.position = Vector3(0, 0.2, 0)
	var hole: MeshInstance3D = B.ball(root, 0.5, H.flat(Color(0.12, 0.08, 0.05)), Vector3(-1.9, 0.75, 0.0), Vector3(0.5, 1.0, 1.0))
	hole.name = "Hole"
	moss_patches(root, 5, 1.4, 1.1, 8)
	flowers_on(root, 4, 1.3, 1.0)
	return root


## A rusting car wreck turned into a planter and an animal den: tinted rust, soil and flowers on the roof.
static func car_husk(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var models: Array[String] = ["sedan", "van", "suv", "truck"]
	var car: Node3D = HeapModels.car(models[variant % models.size()])
	root.add_child(car)
	car.scale = Vector3.ONE * 1.9
	ModelKit.tint(car, [Color(0.85, 0.5, 0.35), Color(0.6, 0.62, 0.55), Color(0.75, 0.6, 0.4), Color(0.55, 0.5, 0.45)][variant % 4])
	B.box(root, Vector3(1.8, 0.2, 2.2), H.flat(H.DIRT_DARK), Vector3(0, 2.55, 0))
	flowers_on(root, 9, 0.8, 2.65)
	moss_patches(root, 6, 1.1, 2.3, variant)
	for index: int in range(2):
		HeapModels.put(root, HeapModels.nature("plant_bushSmall"), Vector3(-0.4 + float(index) * 0.8, 2.65, 0.2), 0.0, 2.2)
	return root


static func junk_pile(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 40 + variant
	B.ball(root, 2.2, H.flat(H.RUST_DARK.lerp(H.STONE, 0.4)), Vector3(0, 0, 0), Vector3(1.0, 0.75, 1.0), true)
	var parts: Array[String] = ["debris-tire", "debris-door", "debris-plate-a", "debris-bumper", "debris-door-window", "debris-spoiler-a"]
	for index: int in range(10):
		var piece: Node3D = HeapModels.car(parts[(index + variant) % parts.size()])
		root.add_child(piece)
		piece.scale = Vector3.ONE * rng.randf_range(2.6, 3.8)
		piece.position = Vector3(rng.randf_range(-1.7, 1.7), rng.randf_range(0.2, 1.4), rng.randf_range(-1.7, 1.7))
		piece.rotation_degrees = Vector3(rng.randf_range(0, 80), rng.randf_range(0, 360), rng.randf_range(0, 80))
	for index: int in range(3):
		HeapModels.put(root, HeapModels.survival("barrel"), Vector3(rng.randf_range(-1.5, 1.5), 1.0 + rng.randf() * 0.5, rng.randf_range(-1.5, 1.5)), rng.randf() * 360.0, 3.2)
	moss_patches(root, 12, 2.0, 1.6, variant)
	flowers_on(root, 10, 1.9, 1.3)
	return root


static func tire_stack(height: int = 3) -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(height):
		var tire: MeshInstance3D = B.cylinder(root, 0.55, 0.55, 0.32, H.flat(H.TIRE), Vector3(0, 0.16 + 0.32 * float(index), 0), 14)
		tire.rotation_degrees.y = float(index) * 30.0
		B.cylinder(root, 0.26, 0.26, 0.34, H.flat(H.METAL_DARK), Vector3(0, 0.16 + 0.32 * float(index), 0), 10)
	return root


static func wall_tires(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(5):
		B.cylinder(root, 0.55, 0.55, 0.3, H.flat(H.TIRE), Vector3(0, 0.15 + 0.3 * float(index), 0), 12)
	B.cylinder(root, 0.12, 0.12, 2.4, H.flat(H.METAL if variant != 1 else H.RUST), Vector3(0, 1.2, 0), 6)
	if variant == 2:
		moss_patches(root, 3, 0.5, 1.5, 3)
	return root


static func divider_post(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.45, 0.5, 0.45, H.flat(H.TIRE), Vector3(0, 0.22, 0), 10)
	var panel: Node3D = HeapModels.survival("metal-panel")
	root.add_child(panel)
	panel.scale = Vector3.ONE * (5.0 + float(variant))
	panel.position = Vector3(0, 0.5, 0)
	panel.rotation_degrees.y = float(variant) * 60.0
	if variant == 0:
		moss_patches(root, 3, 0.5, 1.8, 6)
	return root


static func appliance_pile() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.3, 1.9, 1.1), H.flat(Color(0.88, 0.88, 0.85)), Vector3(0, 0.95, 0))
	B.box(root, Vector3(1.2, 1.1, 1.0), H.flat(Color(0.75, 0.82, 0.62)), Vector3(0.4, 2.45, 0.1), Vector3(0, 20, 8))
	B.cylinder(root, 0.4, 0.4, 0.06, H.flat(H.METAL_DARK), Vector3(0.4, 2.4, 0.62), 10).rotation_degrees.x = 90.0
	moss_patches(root, 6, 0.8, 2.4, 9)
	flowers_on(root, 5, 0.8, 3.0)
	return root


static func landfill_gate(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.ball(root, 3.4, H.flat(H.RUST_DARK.lerp(H.STONE, 0.4)), Vector3(0, 0, -0.8), Vector3(1.3, 0.9, 1.0), true)
	B.cylinder(root, 1.3, 1.4, 0.3, H.flat(H.METAL_DARK), Vector3(0, 1.4, 1.2), 16).rotation_degrees.x = 90.0
	B.cylinder(root, 1.0, 1.0, 0.34, H.flat(Color(0.05, 0.08, 0.04)), Vector3(0, 1.4, 1.28), 16).rotation_degrees.x = 90.0
	var glow: MeshInstance3D = B.ball(root, 0.5, H.glow(Color(0.5, 1.0, 0.4), 1.4), Vector3(0, 1.4, 1.4), Vector3(1.4, 1.4, 0.3))
	glow.name = "Glow"
	for index: int in range(5):
		B.box(root, Vector3(0.9, 0.08, 0.08), H.flat(H.RUST), Vector3(0, 0.7 + float(index) * 0.25, 1.5))
	moss_patches(root, 10, 2.8, 2.6, 4)
	flowers_on(root, 8, 2.8, 2.0)
	B.label(root, story.text("prop.landfill"), Vector3(0, 3.3, 1.0), 0.006, Color(0.95, 0.95, 0.7), 4.2, 6)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.5, 1.0, 0.4)
	light.light_energy = 1.0
	light.omni_range = 5.0
	light.position = Vector3(0, 1.4, 2.4)
	root.add_child(light)
	return root


static func composting_door(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(6.0, 4.4, 2.4), H.flat(Color(0.58, 0.5, 0.4)), Vector3(0, 2.2, -0.6))
	B.box(root, Vector3(2.8, 3.2, 0.25), H.flat(H.WOOD_DARK), Vector3(0, 1.6, 0.7))
	for index: int in range(3):
		B.box(root, Vector3(3.4, 0.28, 0.1), H.flat(H.WOOD), Vector3(0, 0.8 + float(index) * 0.9, 0.9), Vector3(0, 0, -8.0 + float(index) * 8.0))
	B.box(root, Vector3(2.6, 0.9, 0.08), H.flat(H.MOSS.darkened(0.3)), Vector3(0, 3.8, 0.74))
	B.label(root, story.text("prop.composting"), Vector3(0, 3.8, 0.8), 0.0058, Color(1, 0.95, 0.8), 2.6, 0)
	moss_patches(root, 10, 2.8, 3.4, 3)
	steam(root)
	return root


static func steam(root: Node3D) -> void:
	B.steam(root, Vector3(0, 4.6, 0.2), 8, 1.4, 0.8)


# ---- Things that grow, junk barricades and chutes -----------------------------------------------------


## A vine bridge across the stream, `length` metres long along -z (south end at the origin, north end at -length). Its
## planks and railings are children "Seg<n>" so the builder can grow them one after another.
static func vine_bridge(length: float) -> Node3D:
	var root: Node3D = Node3D.new()
	var count: int = int(ceilf(length / 0.9))
	for index: int in range(count):
		var segment: Node3D = Node3D.new()
		segment.name = "Seg%d" % index
		segment.position = Vector3(0.0, 0.0, -float(index) * 0.9)
		root.add_child(segment)
		B.box(segment, Vector3(2.5, 0.12, 0.78), H.flat(H.WOOD if index % 2 == 0 else H.WOOD_DARK), Vector3(0, 0.0, 0.0))
		for side: float in [-1.0, 1.0]:
			B.cylinder(segment, 0.07, 0.09, 0.9, H.flat(H.VINE), Vector3(side * 1.3, 0.45, 0.0), 6)
			var rail: MeshInstance3D = B.cylinder(segment, 0.05, 0.05, 1.0, H.flat(H.VINE.lightened(0.1)), Vector3(side * 1.3, 0.88, 0.0), 6)
			rail.rotation_degrees.x = 90.0
			if index % 3 == 0:
				B.ball(segment, 0.11, H.glow(H.BLOOM, 0.6), Vector3(side * 1.3, 0.98, 0.1))
		if index % 2 == 0:
			B.ball(segment, 0.2, H.flat(H.VINE), Vector3(0.9, -0.05, 0.0), Vector3(1.4, 0.5, 1.4))
	return root


## A beanstalk from the origin up to `height`: a twisting green stalk with big leaves and a few blossoms; the
## "Seg<n>" children are grown one after another.
static func beanstalk(height: float) -> Node3D:
	var root: Node3D = Node3D.new()
	var count: int = int(ceilf(height / 0.8))
	for index: int in range(count):
		var segment: Node3D = Node3D.new()
		segment.name = "Seg%d" % index
		segment.position = Vector3(sin(float(index) * 0.7) * 0.25, float(index) * 0.8, cos(float(index) * 0.7) * 0.25)
		root.add_child(segment)
		B.cylinder(segment, 0.2, 0.24, 0.85, H.flat(H.VINE), Vector3.ZERO, 8)
		for leaf: int in range(2):
			var angle: float = float(index) * 1.4 + float(leaf) * PI
			var piece: MeshInstance3D = B.ball(segment, 0.45, H.flat(H.MOSS.lightened(0.1 * float(leaf))), Vector3(cos(angle) * 0.6, 0.2, sin(angle) * 0.6), Vector3(1.2, 0.18, 0.7))
			piece.rotation.y = -angle
		if index % 3 == 1:
			B.ball(segment, 0.16, H.glow(H.BLOOM, 0.8), Vector3(0.35, 0.3, 0.0))
	return root


static func barricade(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	B.box(root, Vector3(4.2, 1.2, 1.4), H.flat(H.RUST_DARK), Vector3(0, 0.6, 0))
	for index: int in range(9):
		var piece: Node3D = HeapModels.car("debris-tire" if index % 3 == 0 else ("debris-door" if index % 3 == 1 else "debris-plate-b"))
		root.add_child(piece)
		piece.scale = Vector3.ONE * 3.6
		piece.position = Vector3(rng.randf_range(-1.9, 1.9), rng.randf_range(0.5, 2.0), rng.randf_range(-0.6, 0.6))
		piece.rotation_degrees = Vector3(rng.randf_range(0, 80), rng.randf_range(0, 360), rng.randf_range(0, 80))
	for index: int in range(4):
		B.cylinder(root, 0.65, 0.65, 0.5, H.flat(H.TIRE), Vector3(-1.5 + float(index) * 1.0, 0.25, 0.9), 14)
	B.box(root, Vector3(2.0, 0.7, 0.08), H.flat(Color(0.95, 0.85, 0.2)), Vector3(0, 2.7, 0.9), Vector3(0, 0, 4))
	B.label(root, story.text("prop.barricade"), Vector3(0, 2.7, 0.96), 0.0048, Color(0.15, 0.1, 0.05), 2.0, 0)
	moss_patches(root, 8, 1.8, 1.8, 5)
	return root


## A trash chute: a tilted metal trough following `points` (world positions, already at the right heights), with rails.
static func chute(points: Array[Vector3]) -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(points.size() - 1):
		var a: Vector3 = points[index]
		var b: Vector3 = points[index + 1]
		var mid: Vector3 = (a + b) * 0.5
		var length: float = a.distance_to(b)
		var piece: Node3D = Node3D.new()
		piece.transform = Transform3D(Basis.looking_at(b - a, Vector3.UP), mid)
		root.add_child(piece)
		B.box(piece, Vector3(1.6, 0.1, length + 0.3), H.flat(H.METAL if index % 2 == 0 else H.METAL.darkened(0.12)), Vector3(0, 0.05, 0))
		for side: float in [-1.0, 1.0]:
			B.box(piece, Vector3(0.1, 0.4, length + 0.3), H.flat(H.RUST), Vector3(side * 0.8, 0.28, 0))
		if index % 2 == 0:
			B.box(piece, Vector3(0.12, 0.7, 0.12), H.flat(H.WOOD_DARK), Vector3(0.8, -0.3, 0))
	return root


# ---- Signs -------------------------------------------------------------------------------------


## A scrap sign (planks on posts), framed poster, little note or chalkboard menu; the text is a Label3D the builder
## adds on top. Width/height are in metres of the board.
static func sign_post(width: float, height: float, style: String) -> Node3D:
	var root: Node3D = Node3D.new()
	match style:
		"poster":
			B.box(root, Vector3(width + 0.2, height + 0.2, 0.08), H.flat(H.RUST_DARK), Vector3(0, 1.4 + height * 0.5, 0))
			B.box(root, Vector3(width, height, 0.1), H.flat(Color(0.96, 0.93, 0.8)), Vector3(0, 1.4 + height * 0.5, 0.01))
			for side: float in [-1.0, 1.0]:
				B.cylinder(root, 0.06, 0.06, 1.4, H.flat(H.WOOD_DARK), Vector3(side * (width * 0.4), 0.7, 0), 6)
		"memo":
			B.box(root, Vector3(width, height, 0.05), H.flat(Color(0.98, 0.96, 0.78)), Vector3(0, 1.1 + height * 0.5, 0))
			B.cylinder(root, 0.05, 0.05, 1.1, H.flat(H.WOOD_DARK), Vector3(0, 0.55, -0.04), 6)
			B.ball(root, 0.07, H.flat(Color(0.2, 0.55, 0.25)), Vector3(0, 1.1 + height - 0.1, 0.05))
		"menu":
			B.box(root, Vector3(width + 0.25, height + 0.25, 0.12), H.flat(H.WOOD), Vector3(0, 1.3 + height * 0.5, 0))
			B.box(root, Vector3(width, height, 0.14), H.flat(Color(0.16, 0.2, 0.15)), Vector3(0, 1.3 + height * 0.5, 0.01))
			for side: float in [-1.0, 1.0]:
				B.cylinder(root, 0.07, 0.07, 1.3, H.flat(H.WOOD), Vector3(side * (width * 0.45), 0.65, -0.05), 6)
		_:
			B.box(root, Vector3(width, height, 0.1), H.flat(Color(0.94, 0.9, 0.74)), Vector3(0, 1.45 + height * 0.5, 0))
			B.box(root, Vector3(width + 0.16, 0.1, 0.14), H.flat(H.RUST_DARK), Vector3(0, 1.45 + height + 0.05, 0))
			B.box(root, Vector3(width + 0.16, 0.1, 0.14), H.flat(H.RUST_DARK), Vector3(0, 1.4, 0))
			B.cylinder(root, 0.08, 0.08, 1.6, H.flat(H.WOOD_DARK), Vector3(-width * 0.35, 0.8, -0.04), 6)
			B.cylinder(root, 0.08, 0.08, 1.6, H.flat(H.WOOD_DARK), Vector3(width * 0.35, 0.8, -0.04), 6)
	return root
