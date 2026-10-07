class_name TownConnectors
extends RefCounted
## Brief 16, Group D: what lies beyond each zone passageway in the main town. A bridge or causeway runs from the passage's mouth over the water to a
## distant landmass themed to the zone: a sunny gym-and-mill island (the Gainlands), a gloomy office tower (the Department of Necrotic Affairs), a
## landscape of giant food (the Endless Buffet), a junk-and-farm hill (the Verdant Dump) and white-and-gold walls (the Capital). Purely visual: nothing
## here is walkable and the hero never needs to cross it. `plan` (island cells and bridge corridor) is computed first so `TownBuilder` can leave
## water tiles out under the land and clear the far scenery from the way.

## From the passage mouth to the island's centre (metres).
const ISLAND_DISTANCE: float = 21.0
const BRIDGE_START: float = 3.4
## Island radius in unscaled hex units (4.05 gives the 19-cell island: a centre and two rings).
const ISLAND_REACH: float = 4.05
## Radius in cells of the water kept (or added) around an island.
const WATER_RADIUS: int = 5
const BRIDGE_HALF_WIDTH: float = 1.2

const THEMES: Dictionary = {
	"beefcake": {"tile": Color(0.5, 0.74, 0.3), "tile_b": Color(0.46, 0.7, 0.28), "wood": Color(0.62, 0.42, 0.24), "rail": Color(0.85, 0.3, 0.25)},
	"necrocrat": {"tile": Color(0.3, 0.33, 0.4), "tile_b": Color(0.26, 0.29, 0.36), "wood": Color(0.2, 0.22, 0.28), "rail": Color(0.8, 0.2, 0.2)},
	"gourmand": {"tile": Color(0.95, 0.62, 0.3), "tile_b": Color(0.98, 0.84, 0.66), "wood": Color(0.85, 0.6, 0.32), "rail": Color(0.9, 0.3, 0.3)},
	"refusemancer": {"tile": Color(0.5, 0.5, 0.24), "tile_b": Color(0.44, 0.44, 0.2), "wood": Color(0.5, 0.36, 0.22), "rail": Color(0.4, 0.55, 0.3)},
	"final": {"tile": Color(0.95, 0.92, 0.82), "tile_b": Color(0.9, 0.86, 0.74), "wood": Color(0.94, 0.92, 0.88), "rail": Color(0.95, 0.76, 0.24)},
}


## {"center": Vector3 (the island's centre, world), "cells": Array of Vector2i (the island), "corridor": Array of Vector2i (cells under the bridge)}.
static func plan(mouth: Vector3, out: Vector3) -> Dictionary:
	var raw: Vector3 = mouth + out * ISLAND_DISTANCE
	var center_cell: Vector2i = HexGrid.world_to_cell(raw / TownBuilder.SCALE)
	var center: Vector3 = HexGrid.cell_to_world(center_cell.x, center_cell.y) * TownBuilder.SCALE
	var cells: Array[Vector2i] = []
	var base: Vector3 = HexGrid.cell_to_world(center_cell.x, center_cell.y)
	for row: int in range(center_cell.y - 5, center_cell.y + 6):
		for col: int in range(center_cell.x - 6, center_cell.x + 7):
			var pos: Vector3 = HexGrid.cell_to_world(col, row)
			if Vector2(pos.x - base.x, pos.z - base.z).length() <= ISLAND_REACH:
				cells.append(Vector2i(col, row))
	var corridor: Array[Vector2i] = []
	var length: float = center.distance_to(mouth)
	var step: float = 0.8
	var at: float = 0.0
	while at <= length:
		var point: Vector3 = mouth + out * at
		var cell: Vector2i = HexGrid.world_to_cell(point / TownBuilder.SCALE)
		if not corridor.has(cell):
			corridor.append(cell)
		at += step
	return {"center": center, "center_cell": center_cell, "cells": cells, "corridor": corridor}


static func build(parent: Node3D, zone_id: String, mouth: Vector3, out: Vector3, plan_data: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Connector_%s" % zone_id
	parent.add_child(root)
	var theme: Dictionary = THEMES.get(zone_id, THEMES["final"]) as Dictionary
	var center: Vector3 = plan_data["center"] as Vector3
	_island_tiles(root, zone_id, theme, plan_data["cells"] as Array)
	_bridge(root, zone_id, theme, mouth + out * BRIDGE_START, center - out * 8.6)
	var u: Vector3 = -out
	var v: Vector3 = Vector3(u.z, 0.0, -u.x)
	var frame: Transform3D = Transform3D(Basis(v, Vector3.UP, u), center)
	match zone_id:
		"beefcake":
			_gainlands(root, frame, u)
		"necrocrat":
			_office(root, frame, u)
		"gourmand":
			_buffet(root, frame)
		"refusemancer":
			_dump(root, frame)
		_:
			_capital(root, frame, u)
	return root


# ---- Ground and bridge ------------------------------------------------------------------------------------------------------------------


static func _island_tiles(root: Node3D, zone_id: String, theme: Dictionary, cells: Array) -> void:
	var tiles: Node3D = Node3D.new()
	tiles.name = "Land"
	root.add_child(tiles)
	for cell: Variant in cells:
		var c: Vector2i = cell as Vector2i
		var pos: Vector3 = HexGrid.cell_to_world(c.x, c.y) * TownBuilder.SCALE
		var tile: Node3D = ModelKit.tile("hex_grass")
		ModelKit.flatten(tile, (theme["tile"] as Color) if (c.x + c.y) % 2 == 0 else (theme["tile_b"] as Color))
		ModelKit.place(tiles, tile, pos, 0.0, TownBuilder.SCALE)


static func _bridge(root: Node3D, zone_id: String, theme: Dictionary, from: Vector3, to: Vector3) -> void:
	var span: Vector3 = to - from
	var length: float = span.length()
	if length < 1.0:
		return
	var direction: Vector3 = span / length
	var yaw: float = atan2(direction.x, direction.z)
	var mesh: ProcMesh = ProcMesh.new()
	var plank: Color = theme["wood"] as Color
	var rail: Color = theme["rail"] as Color
	var dark: Color = plank.darkened(0.3)
	var count: int = int(length / 0.46)
	for i: int in range(count):
		var z: float = 0.23 + float(i) * 0.46
		var shade: Color = plank.lerp(dark, 0.18 * float(i % 3))
		if zone_id == "refusemancer" and i % 4 == 1:
			shade = Color(0.55, 0.45, 0.3)
		mesh.box(Vector3(0.0, 0.16, z), Vector3(BRIDGE_HALF_WIDTH * 2.0, 0.12, 0.4), shade)
	for side: float in [-1.0, 1.0]:
		var x: float = side * (BRIDGE_HALF_WIDTH + 0.05)
		mesh.box(Vector3(x, 0.78, length * 0.5), Vector3(0.07, 0.07, length), rail)
		var z: float = 0.1
		while z <= length:
			mesh.box(Vector3(x, 0.45, z), Vector3(0.12, 0.9, 0.12), dark)
			z += 2.1
	var node: MeshInstance3D = mesh.build("Bridge")
	node.position = from
	node.rotation.y = yaw
	root.add_child(node)
	# pillars under the span so it reads as standing in the water
	var pillars: ProcMesh = ProcMesh.new()
	var at: float = 1.5
	while at < length:
		for side: float in [-1.0, 1.0]:
			pillars.box(Vector3(side * (BRIDGE_HALF_WIDTH - 0.2), -0.4, at), Vector3(0.28, 1.2, 0.28), dark.darkened(0.1))
		at += 3.0
	var legs: MeshInstance3D = pillars.build("Pillars")
	legs.position = from
	legs.rotation.y = yaw
	root.add_child(legs)


static func _place(root: Node3D, node: Node3D, frame: Transform3D, local: Vector3, yaw_degrees: float, model_scale: float) -> Node3D:
	root.add_child(node)
	node.position = frame * local
	node.rotation_degrees.y = rad_to_deg(frame.basis.get_euler().y) + yaw_degrees
	node.scale = Vector3.ONE * model_scale
	return node


static func _mesh_at(root: Node3D, mesh: ProcMesh, frame: Transform3D, local: Vector3, node_name: String) -> void:
	var node: MeshInstance3D = mesh.build(node_name)
	node.position = frame * local
	node.rotation.y = frame.basis.get_euler().y
	root.add_child(node)


# ---- The five landmasses --------------------------------------------------------------------------------------------------------------


## The Gainlands: a sunny island with two windmills, a gym hall, weight racks, flags and a giant dumbbell.
static func _gainlands(root: Node3D, frame: Transform3D, u: Vector3) -> void:
	_place(root, ModelKit.building("windmill"), frame, Vector3(-4.2, 0.0, -1.5), 0.0, 2.3)
	_place(root, ModelKit.building("windmill"), frame, Vector3(4.6, 0.0, -3.0), 25.0, 1.8)
	var gym: Node3D = _place(root, ModelKit.building("barracks"), frame, Vector3(0.6, 0.0, -2.2), 0.0, 2.2)
	ModelKit.tint(gym, Color(1.0, 0.7, 0.62))
	for index: int in range(3):
		_place(root, ModelKit.prop("weaponrack"), frame, Vector3(-2.6 + 2.0 * float(index), 0.0, 1.2), 10.0 * float(index), 1.8)
	for side: float in [-1.0, 1.0]:
		_place(root, ModelKit.prop("flag_blue"), frame, Vector3(side * 5.2, 0.0, 1.8), 0.0, 2.2)
	var bell: ProcMesh = ProcMesh.new()
	var steel: Color = Color("aeb4c4")
	var spin: Transform3D = Transform3D(Basis(Vector3(0, 0, 1), PI * 0.5), Vector3(0.0, 1.1, 0.0))
	for side: float in [-1.0, 1.0]:
		for i: int in range(4):
			var a: float = 1.15 + 0.18 * float(i)
			var y0: float = a if side > 0.0 else -a - 0.17
			var radius: float = 0.9 - 0.04 * float(i)
			bell.frustum(y0, y0 + 0.17, radius, radius, 12, [Color("e2493f"), Color("f6c23c")][i % 2], spin)
	bell.frustum(-1.9, 1.9, 0.14, 0.14, 8, steel, spin, true, true)
	_mesh_at(root, bell, frame, Vector3(0.5, 0.0, 3.2), "GiantDumbbell")
	for index: int in range(7):
		var angle: float = float(index) * 0.9 + 0.4
		_place(root, ModelKit.nature("tree_single_A" if index % 2 == 0 else "tree_single_B"), frame, Vector3(cos(angle) * 6.8, 0.0, sin(angle) * 6.4), float(index) * 55.0, 1.6)


## The Department of Necrotic Affairs: a gloomy office tower with lit windows, a low annex and dead trees on slate ground.
static func _office(root: Node3D, frame: Transform3D, u: Vector3) -> void:
	var mesh: ProcMesh = ProcMesh.new()
	var wall: Color = Color("2c3140")
	var wall_light: Color = Color("3d4456")
	mesh.box(Vector3(0.0, 6.5, -1.0), Vector3(4.4, 13.0, 4.4), wall)
	mesh.box(Vector3(0.0, 13.4, -1.0), Vector3(4.8, 0.8, 4.8), wall_light)
	mesh.box(Vector3(0.0, 1.8, 3.2), Vector3(9.0, 3.6, 4.0), wall_light)
	mesh.box(Vector3(0.0, 3.8, 3.2), Vector3(9.4, 0.4, 4.4), wall)
	var glow: Color = Color("ffd98a")
	var dim: Color = Color("5f7a8f")
	for row: int in range(9):
		for col: int in range(5):
			var lit: bool = (row * 7 + col * 3) % 5 == 0
			mesh.box(Vector3(-1.8 + float(col) * 0.9, 1.6 + float(row) * 1.3, 1.25), Vector3(0.55, 0.7, 0.08), glow if lit else dim)
	for col: int in range(7):
		mesh.box(Vector3(-3.6 + float(col) * 1.2, 2.0, 5.25), Vector3(0.7, 0.9, 0.08), glow if col % 3 == 0 else dim)
	mesh.box(Vector3(0.0, 14.6, -1.0), Vector3(0.12, 2.4, 0.12), Color("2a2d36"))
	mesh.box(Vector3(0.0, 15.7, -1.0), Vector3(0.5, 0.5, 0.5), Color("d0342c"))
	_mesh_at(root, mesh, frame, Vector3.ZERO, "OfficeTower")
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color("ffd98a")
	light.light_energy = 1.2
	light.omni_range = 9.0
	light.position = frame * Vector3(0.0, 3.0, 4.5)
	root.add_child(light)
	for index: int in range(6):
		var angle: float = float(index) * 1.05 + 0.2
		var tree: Node3D = _place(root, ModelKit.nature("tree_single_A_cut"), frame, Vector3(cos(angle) * 7.0, 0.0, sin(angle) * 6.6), float(index) * 60.0, 1.5)
		ModelKit.tint(tree, Color(0.45, 0.4, 0.4))
	for index: int in range(3):
		_place(root, ModelKit.nature("rock_single_%s" % ["A", "B", "C"][index]), frame, Vector3(-5.5 + 5.5 * float(index), 0.0, 6.2), float(index) * 80.0, 1.6)


## The Endless Buffet: giant food on a checkered tablecloth.
static func _buffet(root: Node3D, frame: Transform3D) -> void:
	var food: String = ModelKit.KENNEY_FOOD
	var items: Array = [
		["donut-sprinkles", Vector3(-3.6, 0.0, -2.4), 11.0],
		["cake-birthday", Vector3(3.6, 0.0, -3.0), 11.0],
		["pie", Vector3(0.0, 0.0, -5.2), 9.0],
		["cupcake", Vector3(-5.6, 0.0, 1.6), 8.0],
		["sundae", Vector3(5.2, 0.0, 1.4), 9.0],
		["pancakes", Vector3(-1.4, 0.0, 1.8), 8.0],
		["cheese", Vector3(1.8, 0.0, 4.4), 8.0],
		["loaf-baguette", Vector3(-4.4, 0.0, 4.6), 9.0],
		["muffin", Vector3(2.0, 0.0, -0.4), 7.0],
		["cookie", Vector3(-1.0, 0.0, 5.6), 7.0],
	]
	for index: int in range(items.size()):
		var entry: Array = items[index]
		_place(root, ModelKit.kit_model(food, str(entry[0])), frame, entry[1] as Vector3, float(index) * 47.0, float(entry[2]))


## The Verdant Dump: a farm hill with a barn, haystacks, a heap of junk and a few crooked fences.
static func _dump(root: Node3D, frame: Transform3D) -> void:
	for cell_offset: Vector3 in [Vector3(-3.4, 0.0, -1.5), Vector3(3.4, 0.0, -2.2), Vector3(0.0, 0.0, -4.6)]:
		var hill: Node3D = ModelKit.nature("hills_A_trees" if cell_offset.x <= 0.0 else "hills_B_trees")
		_place(root, hill, frame, cell_offset, 0.0, TownBuilder.SCALE * 1.1)
	var barn: Node3D = _place(root, ModelKit.building("home_B"), frame, Vector3(0.4, 0.0, -2.0), 0.0, 2.6)
	ModelKit.tint(barn, Color(1.0, 0.55, 0.45))
	var props: ProcMesh = ProcMesh.new()
	for index: int in range(3):
		props.frustum(0.0, 1.1, 1.1, 0.95, 10, Color("d9b84a"), Transform3D(Basis.IDENTITY, Vector3(-4.8 + 1.7 * float(index), 0.0, 2.2)))
		props.sphere(Vector3(-4.8 + 1.7 * float(index), 1.1, 2.2), 0.95, 4, 10, Color("e2c35c"), Transform3D.IDENTITY, 0.55)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 404
	for index: int in range(26):
		var size: Vector3 = Vector3(rng.randf_range(0.5, 1.4), rng.randf_range(0.4, 1.2), rng.randf_range(0.5, 1.4))
		var spot: Vector3 = Vector3(4.2 + rng.randf_range(-1.6, 1.6), size.y * 0.5 + rng.randf_range(0.0, 1.2) * (1.0 - float(index) / 26.0), 2.4 + rng.randf_range(-1.4, 1.4))
		var tone: Color = [Color("8a8f98"), Color("b5543c"), Color("5a7a4a"), Color("c9b46a"), Color("4a4f58")][index % 5]
		props.box(spot, size, tone, Transform3D(Basis(Vector3.UP, rng.randf_range(0.0, PI)), Vector3.ZERO))
	_mesh_at(root, props, frame, Vector3.ZERO, "HaystacksAndJunk")
	for index: int in range(4):
		_place(root, ModelKit.prop("crate_A_big" if index % 2 == 0 else "barrel"), frame, Vector3(-2.2 + 1.3 * float(index), 0.0, 3.4), float(index) * 70.0, 1.8)
	_place(root, ModelKit.prop("wheelbarrow"), frame, Vector3(-1.0, 0.0, 5.0), 40.0, 2.0)
	for index: int in range(4):
		_place(root, ModelKit.neutral("fence_wood_straight"), frame, Vector3(-6.2 + 2.0 * float(index), 0.0, 5.8), 6.0 * float(index), 2.0)


## The Capital: a ring of white walls capped in gold around a white-and-gold castle, towers at the corners.
static func _capital(root: Node3D, frame: Transform3D, u: Vector3) -> void:
	var white: Color = Color("f4efe4")
	var gold: Color = Color("e8b04a")
	var mesh: ProcMesh = ProcMesh.new()
	var radius: float = 7.4
	var segments: int = 12
	for index: int in range(segments):
		var a0: float = TAU * float(index) / float(segments)
		var a1: float = TAU * float(index + 1) / float(segments)
		var mid: float = (a0 + a1) * 0.5
		var facing_hero: bool = absf(angle_difference(mid, PI * 0.5)) < 0.4
		if facing_hero:
			continue
		var p: Vector3 = Vector3(cos(mid) * radius, 0.0, sin(mid) * radius)
		var length: float = 2.0 * radius * sin(PI / float(segments)) + 0.1
		var basis: Basis = Basis(Vector3.UP, -mid + PI * 0.5)
		mesh.box(p + Vector3(0, 1.6, 0), Vector3(length, 3.2, 0.9), white, Transform3D(basis, Vector3.ZERO))
		mesh.box(p + Vector3(0, 3.35, 0), Vector3(length + 0.1, 0.3, 1.1), gold, Transform3D(basis, Vector3.ZERO))
	for index: int in range(segments):
		var angle: float = TAU * float(index) / float(segments)
		if absf(angle_difference(angle, PI * 0.5)) < 0.3:
			continue
		var corner: Vector3 = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		mesh.frustum(0.0, 4.6, 0.75, 0.7, 10, white, Transform3D(Basis.IDENTITY, corner))
		mesh.frustum(4.6, 6.0, 0.95, 0.0, 10, gold, Transform3D(Basis.IDENTITY, corner))
	# the open gate facing the bridge: two gold-capped gate towers
	for side: float in [-1.0, 1.0]:
		var tower: Vector3 = Vector3(side * 1.9, 0.0, radius - 0.2)
		mesh.box(tower + Vector3(0, 2.4, 0), Vector3(1.4, 4.8, 1.4), white)
		mesh.box(tower + Vector3(0, 5.0, 0), Vector3(1.7, 0.4, 1.7), gold)
	mesh.box(Vector3(0.0, 4.4, radius - 0.2), Vector3(4.2, 0.5, 1.2), gold)
	_mesh_at(root, mesh, frame, Vector3.ZERO, "WhiteWalls")
	var castle: Node3D = _place(root, ModelKit.building("castle"), frame, Vector3(0.0, 0.0, -0.4), 0.0, 2.5)
	ModelKit.tint(castle, Color(1.0, 0.96, 0.82))
	for side: float in [-1.0, 1.0]:
		var tower: Node3D = _place(root, ModelKit.building("tower_A"), frame, Vector3(side * 3.4, 0.0, 2.6), 0.0, 1.6)
		ModelKit.tint(tower, Color(1.0, 0.95, 0.8))
		_place(root, ModelKit.prop("flag_blue"), frame, Vector3(side * 1.0, 0.0, radius - 1.4), 0.0, 2.6)
	var glow: OmniLight3D = OmniLight3D.new()
	glow.light_color = Color("ffe9a8")
	glow.light_energy = 1.0
	glow.omni_range = 12.0
	glow.position = frame * Vector3(0.0, 4.0, 1.0)
	root.add_child(glow)
