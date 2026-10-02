class_name BuffetProps
extends RefCounted
## Procedural props of the Endless Buffet, built from primitives in the shared palette (`BuffetMaterials`) and
## dressed with Kenney Food Kit / KayKit Restaurant Bits models: layer-cake buildings, the jelly bounce pads,
## crouton rafts, the lazy susan, the soup fountain, the grand oven, the walk-in freezer, stalls, signs and
## more. Every function returns a Node3D standing at the origin, facing +z (towards the camera). Text on props
## comes from the zone's story file (the `story` argument) so it can be rewritten without touching code.

const M = preload("res://world/buffet/buffet_materials.gd")


# ---- Primitive helpers ---------------------------------------------------------------------------


static func mesh_at(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3, scl: Vector3 = Vector3.ONE, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scl
	instance.rotation_degrees = rot_deg
	parent.add_child(instance)
	return instance


static func cylinder(parent: Node3D, radius_top: float, radius_bottom: float, height: float, material: Material, pos: Vector3, segments: int = 14) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius_top
	mesh.bottom_radius = radius_bottom
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	return mesh_at(parent, mesh, material, pos)


static func box(parent: Node3D, size: Vector3, material: Material, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return mesh_at(parent, mesh, material, pos, Vector3.ONE, rot_deg)


static func ball(parent: Node3D, radius: float, material: Material, pos: Vector3, scl: Vector3 = Vector3.ONE, hemisphere: bool = false) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * (1.0 if hemisphere else 2.0)
	mesh.is_hemisphere = hemisphere
	mesh.radial_segments = 14
	mesh.rings = 7
	return mesh_at(parent, mesh, material, pos, scl)


static func label(parent: Node3D, text: String, pos: Vector3, pixel_size: float, color: Color, width_m: float = 0.0, outline: int = 8) -> Label3D:
	var node: Label3D = Label3D.new()
	node.text = text
	node.font = UIStyle.font_title()
	node.font_size = 48
	node.pixel_size = pixel_size
	node.modulate = color
	node.outline_size = outline
	node.outline_modulate = Color(0.12, 0.05, 0.03, 0.9)
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.double_sided = false
	if width_m > 0.0:
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.width = width_m / pixel_size
	node.position = pos
	parent.add_child(node)
	return node


static func steam(parent: Node3D, pos: Vector3, amount: int = 10, spread_width: float = 0.5, rise: float = 1.4) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = amount
	particles.lifetime = 2.2
	particles.preprocess = 2.2
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = spread_width
	particles.direction = Vector3.UP
	particles.spread = 12.0
	particles.initial_velocity_min = rise * 0.7
	particles.initial_velocity_max = rise
	particles.gravity = Vector3.ZERO
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.1
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.28
	puff.height = 0.56
	puff.radial_segments = 6
	puff.rings = 3
	particles.mesh = puff
	particles.material_override = M.translucent(Color(1.0, 0.97, 0.92), 0.38, 0.35)
	particles.position = pos
	parent.add_child(particles)
	return particles


# ---- Traversal -----------------------------------------------------------------------------------


## A jelly bounce pad: a glossy translucent dome on a plate, wobbling (the "dome" meta node).
static func jelly_pad(color: Color, radius: float = 1.25) -> Node3D:
	var root: Node3D = Node3D.new()
	var plate_ring: MeshInstance3D = cylinder(root, radius * 1.18, radius * 1.3, 0.12, M.flat(M.VANILLA), Vector3(0, 0.06, 0), 20)
	plate_ring.name = "Plate"
	var dome: Node3D = Node3D.new()
	dome.name = "Dome"
	root.add_child(dome)
	ball(dome, radius, M.translucent(color, 0.82, 0.55, 0.05), Vector3(0, 0.1, 0), Vector3(1.0, 0.7, 1.0), true)
	ball(dome, radius * 0.55, M.translucent(color.lightened(0.45), 0.55, 0.9, 0.05), Vector3(0, 0.12, 0), Vector3(1.0, 0.8, 1.0), true)
	# A cherry on top and a highlight.
	ball(dome, 0.18, M.glow(Color(0.95, 0.1, 0.2), 0.6), Vector3(0, radius * 0.7 + 0.06, 0))
	ball(dome, 0.1, M.glow(Color(1, 1, 1), 1.4), Vector3(-radius * 0.35, radius * 0.5, radius * 0.25))
	root.set_meta("dome", dome)
	return root


## A crouton raft: a cluster of toasted bread cubes with a sprig of parsley.
static func raft() -> Node3D:
	var root: Node3D = Node3D.new()
	var slab: MeshInstance3D = cylinder(root, 1.55, 1.6, 0.34, M.flat(M.TOAST_DARK), Vector3(0, -0.05, 0), 12)
	slab.name = "Slab"
	var positions: Array[Vector3] = [Vector3(0, 0, 0), Vector3(0.95, 0, 0.2), Vector3(-0.95, 0, -0.1), Vector3(0.2, 0, 0.98), Vector3(-0.25, 0, -0.98), Vector3(0.78, 0, -0.75), Vector3(-0.8, 0, 0.78)]
	var index: int = 0
	for offset: Vector3 in positions:
		var size: float = 1.1 if index == 0 else 0.88
		var crouton: MeshInstance3D = box(root, Vector3(size, 0.42, size), M.flat(M.TOAST if index % 2 == 0 else M.TOAST.lightened(0.1)), offset + Vector3(0, 0.12, 0), Vector3(0, float(index) * 31.0, 0))
		crouton.name = "Crouton%d" % index
		box(root, Vector3(size * 0.82, 0.05, size * 0.82), M.flat(M.TOAST_DARK.darkened(0.1)), offset + Vector3(0, 0.36, 0), Vector3(0, float(index) * 31.0, 0))
		index += 1
	ball(root, 0.16, M.flat(M.LETTUCE), Vector3(0.3, 0.46, 0.2), Vector3(1.4, 0.6, 1.0))
	ball(root, 0.13, M.flat(M.LETTUCE.darkened(0.15)), Vector3(0.45, 0.44, 0.0), Vector3(1.2, 0.6, 1.0))
	return root


## The lazy susan: a big ceramic serving platter that turns slowly (the whole node is rotated by the builder).
static func susan(radius: float) -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, radius, radius * 0.96, 0.28, M.shiny(Color(0.97, 0.95, 0.9), 0.3), Vector3(0, -0.12, 0), 36)
	cylinder(root, radius * 0.97, radius * 0.97, 0.05, M.shiny(Color(0.3, 0.52, 0.9), 0.3), Vector3(0, 0.03, 0), 36)
	cylinder(root, radius * 0.9, radius * 0.9, 0.06, M.shiny(Color(0.99, 0.97, 0.93), 0.3), Vector3(0, 0.06, 0), 36)
	cylinder(root, radius * 0.5, radius * 0.5, 0.07, M.shiny(Color(1.0, 0.82, 0.3), 0.3), Vector3(0, 0.08, 0), 36)
	cylinder(root, radius * 0.45, radius * 0.45, 0.075, M.shiny(Color(0.99, 0.97, 0.93), 0.3), Vector3(0, 0.085, 0), 36)
	# Painted spokes so the rotation is easy to read.
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		var spoke: MeshInstance3D = box(root, Vector3(radius * 0.8, 0.02, 0.16), M.flat(Color(0.3, 0.52, 0.9)), Vector3(cos(angle) * radius * 0.45, 0.12, sin(angle) * radius * 0.45))
		spoke.rotation.y = -angle
	for index: int in range(12):
		var angle: float = TAU * float(index) / 12.0 + 0.2
		ball(root, 0.2, M.flat(Color(0.95, 0.4, 0.5) if index % 2 == 0 else Color(1.0, 0.82, 0.3)), Vector3(cos(angle) * radius * 0.82, 0.14, sin(angle) * radius * 0.82), Vector3(1, 0.5, 1))
	return root


## The susan's central pillar: a giant pepper mill with a crank on top.
static func mill_pillar() -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, 0.75, 1.05, 2.6, M.flat(M.WOOD_DARK), Vector3(0, 1.3, 0), 12)
	cylinder(root, 0.9, 0.9, 0.2, M.shiny(M.STEEL), Vector3(0, 2.7, 0), 12)
	cylinder(root, 0.55, 0.55, 0.9, M.flat(M.WOOD), Vector3(0, 3.2, 0), 12)
	ball(root, 0.45, M.flat(M.WOOD), Vector3(0, 3.7, 0))
	box(root, Vector3(1.4, 0.12, 0.14), M.shiny(M.STEEL), Vector3(0.5, 4.1, 0))
	ball(root, 0.2, M.flat(M.CLOTH_RED), Vector3(1.2, 4.1, 0))
	return root


# ---- Fences, dividers and food-kit dressing ------------------------------------------------------


## An upright giant fork (or spatula) for the picket fence.
static func fence_fork(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var names: Array[String] = ["cooking-fork", "utensil-fork", "cooking-spatula"]
	var piece: Node3D = BuffetModels.food(names[variant % names.size()])
	root.add_child(piece)
	piece.rotation_degrees = Vector3(0, 0, 90)
	piece.scale = Vector3.ONE * 8.5
	piece.position = Vector3(0, 0.0, 0)
	piece.rotation_degrees.y = 90.0
	return root


## A divider post between districts: an upright baguette, carrot or celery stick.
static func divider_post(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	match variant % 3:
		0:
			var bread: Node3D = BuffetModels.food("loaf-baguette")
			root.add_child(bread)
			bread.rotation_degrees = Vector3(0, 0, 90)
			bread.scale = Vector3.ONE * 5.5
		1:
			var carrot: Node3D = BuffetModels.food("carrot")
			root.add_child(carrot)
			carrot.scale = Vector3.ONE * 4.2
		_:
			var celery: Node3D = BuffetModels.food("celery-stick")
			root.add_child(celery)
			celery.rotation_degrees = Vector3(0, 0, 90)
			celery.scale = Vector3.ONE * 8.0
	return root


static func lollipop(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var colors: Array[Color] = [Color(1.0, 0.4, 0.65), Color(0.5, 0.9, 1.0), Color(1.0, 0.85, 0.25), Color(0.7, 0.55, 1.0)]
	var color: Color = colors[variant % colors.size()]
	cylinder(root, 0.07, 0.07, 2.4, M.flat(M.VANILLA), Vector3(0, 1.2, 0), 6)
	var candy: MeshInstance3D = cylinder(root, 0.8, 0.8, 0.16, M.flat(color), Vector3(0, 2.7, 0), 14)
	candy.rotation_degrees.x = 90.0
	var swirl: MeshInstance3D = cylinder(root, 0.55, 0.55, 0.18, M.flat(Color(1, 1, 1)), Vector3(0, 2.7, 0.01), 14)
	swirl.rotation_degrees.x = 90.0
	var core: MeshInstance3D = cylinder(root, 0.3, 0.3, 0.2, M.flat(color), Vector3(0, 2.7, 0.02), 14)
	core.rotation_degrees.x = 90.0
	return root


## A layer-cake building: tiers of sponge and frosting, a cherry on top and a doorway.
static func layer_cake(variant: int, tiers: int = 3) -> Node3D:
	var root: Node3D = Node3D.new()
	var frostings: Array[Color] = [M.PINK, M.MINT, M.VANILLA, Color(1.0, 0.82, 0.45)]
	var sponge: Array[Color] = [M.CHOCOLATE, Color(0.98, 0.84, 0.5), Color(0.82, 0.4, 0.42), M.CHOCOLATE]
	var frost: Color = frostings[variant % frostings.size()]
	var cake: Color = sponge[variant % sponge.size()]
	var radius: float = 2.2
	var height: float = 0.0
	for tier: int in range(tiers):
		var tier_height: float = 1.3 - float(tier) * 0.1
		cylinder(root, radius, radius, tier_height, M.flat(cake), Vector3(0, height + tier_height * 0.5, 0), 20)
		# Frosting band and drips.
		cylinder(root, radius * 1.03, radius * 1.03, 0.2, M.flat(frost), Vector3(0, height + tier_height, 0), 20)
		for drip: int in range(10):
			var angle: float = TAU * float(drip) / 10.0 + float(tier) * 0.4
			var drip_height: float = 0.25 + 0.2 * float((drip * 7 + tier * 3) % 4)
			ball(root, 0.14, M.flat(frost), Vector3(cos(angle) * radius * 1.02, height + tier_height - drip_height * 0.5, sin(angle) * radius * 1.02), Vector3(1, drip_height * 3.0, 1))
		height += tier_height + 0.1
		radius *= 0.74
	ball(root, 0.3, M.glow(Color(0.9, 0.1, 0.2), 0.5), Vector3(0, height + 0.25, 0))
	# A doorway on the front of the bottom tier and little windows above.
	box(root, Vector3(0.9, 1.1, 0.12), M.flat(M.WOOD_DARK), Vector3(0, 0.55, 2.2))
	box(root, Vector3(1.0, 0.1, 0.2), M.flat(frost.lightened(0.1)), Vector3(0, 1.15, 2.2))
	for window: int in range(3):
		var wa: float = (-0.5 + float(window) * 0.5) * 1.2
		box(root, Vector3(0.3, 0.4, 0.1), M.glow(Color(1.0, 0.9, 0.55), 0.9), Vector3(sin(wa) * 1.6, 1.55, cos(wa) * 1.6), Vector3(0, rad_to_deg(wa), 0))
	return root


# ---- The hub ----------------------------------------------------------------------------------


static func kitchen_row(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var models: Array[String] = ["kitchencounter_straight_A_backsplash", "stove_multi_decorated", "kitchencounter_sink", "fridge_A_decorated", "kitchencounter_straight_A_decorated"]
	var node: Node3D = BuffetModels.restaurant(models[variant % models.size()])
	root.add_child(node)
	node.scale = Vector3.ONE * 2.1
	if variant % 5 == 1 or variant % 5 == 0:
		steam(root, Vector3(0.0, 2.8, 0.2), 6, 0.3, 1.0)
	return root


static func soup_fountain() -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, 1.9, 2.0, 0.55, M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 0.27, 0), 24)
	cylinder(root, 1.75, 1.75, 0.08, M.soup(), Vector3(0, 0.56, 0), 24)
	cylinder(root, 0.35, 0.5, 1.7, M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 1.0, 0), 12)
	cylinder(root, 1.15, 1.0, 0.35, M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 1.75, 0), 20)
	cylinder(root, 1.0, 1.0, 0.06, M.soup(M.GRAVY.lightened(0.1)), Vector3(0, 1.93, 0), 20)
	cylinder(root, 0.22, 0.3, 1.0, M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 2.3, 0), 10)
	cylinder(root, 0.6, 0.5, 0.25, M.flat(Color(0.97, 0.94, 0.88)), Vector3(0, 2.9, 0), 16)
	cylinder(root, 0.5, 0.5, 0.05, M.soup(M.GRAVY.lightened(0.2)), Vector3(0, 3.03, 0), 16)
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		ball(root, 0.14, M.flat(M.CHEESE if index % 2 == 0 else Color(0.5, 0.78, 0.3)), Vector3(cos(angle) * 0.9, 1.99, sin(angle) * 0.9), Vector3(1, 0.6, 1))
	steam(root, Vector3(0, 3.2, 0), 12, 0.35, 1.2)
	var drip: MeshInstance3D = cylinder(root, 0.05, 0.05, 1.0, M.soup(M.GRAVY.lightened(0.2)), Vector3(0.0, 2.45, 0.0), 6)
	drip.name = "Stream"
	return root


static func hearty_table() -> Node3D:
	var root: Node3D = Node3D.new()
	var table: Node3D = BuffetModels.restaurant("kitchentable_A_large")
	root.add_child(table)
	table.scale = Vector3.ONE * 1.35
	var cloth: MeshInstance3D = box(root, Vector3(4.2, 0.06, 2.7), M.flat(Color(0.95, 0.3, 0.32)), Vector3(0, 1.4, 0))
	cloth.name = "Cloth"
	box(root, Vector3(4.2, 0.07, 0.5), M.flat(Color(1, 1, 1)), Vector3(0, 1.41, 0))
	BuffetModels.put_food(root, "turkey", Vector3(0, 1.44, 0), 0.0, 2.4)
	BuffetModels.put_food(root, "bowl-soup", Vector3(-1.4, 1.44, 0.6), 0.0, 2.2)
	BuffetModels.put_food(root, "salad", Vector3(1.4, 1.44, 0.5), 0.0, 2.2)
	BuffetModels.put_food(root, "bread", Vector3(1.2, 1.44, -0.7), 20.0, 2.4)
	BuffetModels.put_food(root, "cup", Vector3(-1.6, 1.44, -0.6), 0.0, 2.2)
	BuffetModels.put_food(root, "pie", Vector3(-0.2, 1.44, 0.8), 0.0, 1.4)
	steam(root, Vector3(0, 2.2, 0), 8, 0.9, 0.8)
	return root


static func vendor_stall() -> Node3D:
	var root: Node3D = Node3D.new()
	var counter: Node3D = BuffetModels.restaurant("kitchencounter_straight_A_decorated")
	root.add_child(counter)
	counter.scale = Vector3.ONE * 1.5
	counter.position = Vector3(0, 0, 0)
	for index: int in range(6):
		var stripe_color: Color = M.PINK if index % 2 == 0 else Color(1, 1, 1)
		box(root, Vector3(0.62, 0.1, 2.0), M.flat(stripe_color), Vector3(-1.55 + float(index) * 0.62, 2.55, -0.3), Vector3(-14, 0, 0))
	for side: float in [-1.0, 1.0]:
		cylinder(root, 0.07, 0.07, 2.6, M.flat(M.WOOD_DARK), Vector3(side * 1.65, 1.3, 0.7), 6)
	BuffetModels.put_food(root, "cake-birthday", Vector3(-1.0, 1.52, 0.1), 0.0, 1.8)
	BuffetModels.put_food(root, "cupcake", Vector3(0.1, 1.52, 0.2), 0.0, 2.2)
	BuffetModels.put_food(root, "donut-sprinkles", Vector3(0.9, 1.52, 0.1), 0.0, 3.0)
	BuffetModels.put_food(root, "pudding", Vector3(1.4, 1.52, 0.3), 0.0, 2.6)
	# Playing cards on a little stand.
	var stand: MeshInstance3D = box(root, Vector3(0.7, 0.9, 0.06), M.flat(M.CLOTH_RED), Vector3(0.2, 1.95, -0.5), Vector3(-12, 0, 0))
	stand.name = "CardSign"
	box(root, Vector3(0.45, 0.62, 0.02), M.flat(Color(0.99, 0.97, 0.9)), Vector3(0.2, 1.97, -0.46), Vector3(-12, 0, 0))
	return root


static func grand_oven() -> Node3D:
	var root: Node3D = Node3D.new()
	var oven: Node3D = BuffetModels.restaurant("oven")
	root.add_child(oven)
	oven.scale = Vector3.ONE * 1.5
	oven.rotation_degrees.y = 0.0
	var glow_door: MeshInstance3D = box(root, Vector3(1.8, 1.0, 0.1), M.glow(Color(1.0, 0.55, 0.15), 1.6), Vector3(0, 1.6, 1.7))
	glow_door.name = "Glow"
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.25)
	light.light_energy = 1.4
	light.omni_range = 6.0
	light.position = Vector3(0, 1.6, 2.2)
	root.add_child(light)
	cylinder(root, 0.4, 0.4, 1.2, M.flat(M.STEEL), Vector3(0.8, 3.7, -0.8), 10)
	steam(root, Vector3(0.8, 4.6, -0.8), 10, 0.25, 1.2)
	return root


static func exit_arch(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		var post: Node3D = BuffetModels.food("utensil-fork")
		root.add_child(post)
		post.rotation_degrees = Vector3(0, 90, 90)
		post.scale = Vector3.ONE * 8.0
		post.position = Vector3(side * 2.9, 0, 0)
	var top: MeshInstance3D = box(root, Vector3(6.6, 0.7, 0.5), M.flat(M.TOAST), Vector3(0, 3.7, 0))
	top.name = "Lintel"
	box(root, Vector3(6.2, 0.1, 0.52), M.flat(M.TOAST_DARK), Vector3(0, 3.38, 0))
	label(root, story.text("prop.arch"), Vector3(0, 3.7, 0.28), 0.007, Color(1.0, 0.97, 0.88), 6.0)
	return root


static func dispenser(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, 0.55, 0.7, 1.1, M.flat(M.CLOTH_RED), Vector3(0, 0.55, 0), 14)
	var globe: MeshInstance3D = ball(root, 0.8, M.translucent(Color(0.85, 0.95, 1.0), 0.35, 0.1, 0.05), Vector3(0, 1.75, 0))
	globe.name = "Globe"
	for index: int in range(9):
		var angle: float = TAU * float(index) / 9.0
		BuffetModels.put_food(root, "cookie", Vector3(cos(angle) * 0.4, 1.45 + 0.12 * float(index % 3), sin(angle) * 0.4), float(index) * 40.0, 1.3)
	ball(root, 0.2, M.flat(Color(1.0, 0.85, 0.3)), Vector3(0, 2.6, 0))
	box(root, Vector3(0.5, 0.3, 0.3), M.flat(M.STEEL), Vector3(0, 0.3, 0.6))
	label(root, story.text("prop.dispenser"), Vector3(0, 0.62, 0.72), 0.0035, Color(1, 1, 1), 1.0, 4)
	return root


## The broken golem: a slumped meatloaf with a detached arm, crossed-out eyes and a few sparks.
static func broken_golem(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var body: Node3D = BuffetModels.food("loaf")
	root.add_child(body)
	body.scale = Vector3.ONE * 3.2
	body.rotation_degrees = Vector3(0, 0, -8)
	ModelKit.tint(body, Color(1.0, 0.72, 0.58))
	for side: float in [-1.0, 1.0]:
		box(root, Vector3(0.34, 0.08, 0.12), M.flat(Color(0.12, 0.05, 0.05)), Vector3(side * 0.35, 1.0, 0.92), Vector3(0, 0, 45))
		box(root, Vector3(0.34, 0.08, 0.12), M.flat(Color(0.12, 0.05, 0.05)), Vector3(side * 0.35, 1.0, 0.92), Vector3(0, 0, -45))
	box(root, Vector3(0.7, 0.07, 0.1), M.flat(Color(0.12, 0.05, 0.05)), Vector3(0, 0.62, 0.95), Vector3(0, 0, -6))
	BuffetModels.put_food(root, "sausage", Vector3(1.8, 0.2, 0.9), 30.0, 3.0)
	BuffetModels.put_food(root, "sausage", Vector3(-1.6, 0.18, 1.2), -20.0, 2.6)
	BuffetModels.put_food(root, "egg", Vector3(0.6, 0.2, 1.7), 0.0, 3.0)
	label(root, story.text("prop.broken_golem"), Vector3(0, 2.2, 0.9), 0.0045, Color(1.0, 0.85, 0.5), 2.4, 6)
	var sparks: CPUParticles3D = CPUParticles3D.new()
	sparks.amount = 8
	sparks.lifetime = 0.9
	sparks.direction = Vector3.UP
	sparks.spread = 70.0
	sparks.initial_velocity_min = 1.0
	sparks.initial_velocity_max = 2.4
	sparks.gravity = Vector3(0, -3.0, 0)
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.06, 0.06, 0.06)
	sparks.mesh = spark_mesh
	sparks.material_override = M.glow(Color(1.0, 0.9, 0.3), 3.0)
	sparks.position = Vector3(0.0, 1.8, 0.4)
	root.add_child(sparks)
	return root


static func hub_pot() -> Node3D:
	var root: Node3D = Node3D.new()
	var pot: Node3D = BuffetModels.restaurant("pot_large")
	root.add_child(pot)
	pot.scale = Vector3.ONE * 1.8
	steam(root, Vector3(0, 1.4, 0), 8, 0.7, 1.0)
	return root


# ---- Forest, candy field, flats, butte -------------------------------------------------------


## "A hollowed-out loaf of bread": four baguette posts under a dome of crusty bread, with a cheese-slab floor.
static func bread_gazebo() -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, 2.3, 2.4, 0.2, M.flat(M.CHEESE), Vector3(0, 0.1, 0), 20)
	for index: int in range(4):
		var angle: float = TAU * (float(index) + 0.5) / 4.0
		cylinder(root, 0.22, 0.26, 2.0, M.flat(M.TOAST), Vector3(cos(angle) * 1.9, 1.1, sin(angle) * 1.9), 8)
	ball(root, 2.8, M.flat(M.TOAST), Vector3(0, 2.1, 0), Vector3(1.0, 0.75, 1.0), true)
	ball(root, 2.35, M.flat(M.CREAM), Vector3(0, 2.05, 0), Vector3(1.0, 0.7, 1.0), true)
	for index: int in range(5):
		var angle: float = float(index) * 1.3
		box(root, Vector3(1.6, 0.06, 0.12), M.flat(M.TOAST_DARK), Vector3(cos(angle) * 0.9, 3.58 - 0.4 * absf(sin(angle)), sin(angle) * 0.9), Vector3(0, -rad_to_deg(angle), 0))
	return root


static func bread_hollow() -> Node3D:
	var root: Node3D = Node3D.new()
	ball(root, 2.1, M.flat(M.TOAST), Vector3(0, 0, 0), Vector3(1.15, 0.9, 1.0), true)
	for index: int in range(4):
		box(root, Vector3(1.3, 0.05, 0.1), M.flat(M.TOAST_DARK), Vector3(-0.8 + float(index) * 0.6, 1.78, -0.2), Vector3(0, 20, 0))
	var hole: MeshInstance3D = ball(root, 1.0, M.flat(Color(0.22, 0.1, 0.05)), Vector3(0, 0.0, 1.35), Vector3(1.0, 1.0, 0.45), true)
	hole.rotation_degrees.x = 90.0
	hole.position = Vector3(0, 0.55, 1.5)
	return root


static func candy_jar() -> Node3D:
	var root: Node3D = Node3D.new()
	cylinder(root, 1.1, 1.1, 2.3, M.translucent(Color(0.8, 0.95, 1.0), 0.3, 0.1, 0.05), Vector3(0, 1.15, 0), 18)
	cylinder(root, 0.8, 0.8, 0.4, M.flat(Color(0.95, 0.35, 0.5)), Vector3(0, 2.5, 0), 14)
	ball(root, 0.2, M.flat(Color(0.95, 0.35, 0.5)), Vector3(0, 2.8, 0))
	var colors: Array[Color] = [Color(1.0, 0.4, 0.65), Color(0.5, 0.9, 1.0), Color(1.0, 0.85, 0.25), Color(0.7, 0.55, 1.0), Color(0.5, 1.0, 0.5)]
	for index: int in range(22):
		var angle: float = float(index) * 2.4
		var radius: float = 0.18 + 0.6 * float((index * 5) % 7) / 7.0
		ball(root, 0.2, M.glow(colors[index % colors.size()], 0.3), Vector3(cos(angle) * radius, 0.25 + 0.38 * float(index % 5), sin(angle) * radius))
	return root


static func shaker(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var node: Node3D = BuffetModels.food("shaker-salt" if variant % 2 == 0 else "shaker-pepper")
	root.add_child(node)
	node.scale = Vector3.ONE * 13.0
	return root


static func butter_pat() -> Node3D:
	var root: Node3D = Node3D.new()
	box(root, Vector3(1.4, 0.7, 1.0), M.flat(M.BUTTER), Vector3(0, 0.35, 0), Vector3(0, 12, 0))
	box(root, Vector3(1.5, 0.06, 1.1), M.flat(M.BUTTER.lightened(0.25)), Vector3(0, 0.72, 0), Vector3(0, 12, 0))
	cylinder(root, 1.1, 1.3, 0.04, M.translucent(M.BUTTER, 0.8, 0.2), Vector3(0, 0.03, 0), 12)
	return root


static func taste_station() -> Node3D:
	var root: Node3D = Node3D.new()
	var table: Node3D = BuffetModels.restaurant("table_round_A_small")
	root.add_child(table)
	table.scale = Vector3.ONE * 1.0
	var cloche: MeshInstance3D = ball(root, 0.5, M.shiny(M.STEEL, 0.15), Vector3(-0.3, 1.0, 0.1), Vector3(1.0, 0.9, 1.0), true)
	cloche.name = "Cloche"
	ball(root, 0.08, M.shiny(M.STEEL), Vector3(-0.3, 1.5, 0.1))
	for index: int in range(3):
		BuffetModels.put_food(root, "cup-saucer", Vector3(0.35, 1.0, -0.4 + float(index) * 0.45), 0.0, 1.6)
	var board: MeshInstance3D = box(root, Vector3(1.1, 0.8, 0.07), M.flat(Color(0.2, 0.14, 0.1)), Vector3(0, 2.05, -0.55), Vector3(-10, 0, 0))
	board.name = "ScoreBoard"
	for star: int in range(5):
		ball(root, 0.09, M.glow(Color(1.0, 0.85, 0.25), 0.6), Vector3(-0.4 + float(star) * 0.2, 2.05, -0.5))
	return root


static func chef_stage(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var backdrop: Node3D = BuffetModels.restaurant("wall_orderwindow_decorated")
	root.add_child(backdrop)
	backdrop.scale = Vector3.ONE * 1.1
	backdrop.position = Vector3(0, 0, -0.5)
	for index: int in range(2):
		var counter: Node3D = BuffetModels.restaurant("kitchencounter_straight_A")
		root.add_child(counter)
		counter.scale = Vector3.ONE * 1.3
		counter.position = Vector3(-1.4 + float(index) * 2.8, 0, 1.3)
	var neon: MeshInstance3D = box(root, Vector3(5.2, 0.8, 0.12), M.glow(Color(1.0, 0.3, 0.6), 1.2), Vector3(0, 4.7, -0.3))
	neon.name = "Neon"
	label(root, story.text("prop.stage"), Vector3(0, 4.7, -0.22), 0.0075, Color(1.0, 0.97, 0.8), 5.0, 4)
	for index: int in range(7):
		ball(root, 0.12, M.glow([Color(1.0, 0.4, 0.5), Color(1.0, 0.9, 0.3), Color(0.4, 0.9, 1.0)][index % 3], 1.8), Vector3(-2.4 + float(index) * 0.8, 5.25, -0.3))
	BuffetModels.put_restaurant(root, "food_burger", Vector3(-1.4, 1.35, 1.3), 0.0, 1.0)
	BuffetModels.put_restaurant(root, "food_dinner", Vector3(1.4, 1.35, 1.3), 0.0, 1.0)
	return root


static func freezer(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	box(root, Vector3(6.0, 4.6, 2.6), M.shiny(Color(0.84, 0.9, 0.95), 0.35), Vector3(0, 2.3, -0.6))
	box(root, Vector3(2.8, 3.4, 0.25), M.shiny(Color(0.7, 0.8, 0.9), 0.3), Vector3(0, 1.8, 0.76))
	box(root, Vector3(0.18, 1.3, 0.28), M.shiny(M.STEEL, 0.2), Vector3(1.0, 1.7, 0.95))
	var window: MeshInstance3D = box(root, Vector3(1.0, 0.8, 0.1), M.glow(Color(0.65, 0.9, 1.0), 1.2), Vector3(0, 2.9, 0.9))
	window.name = "Window"
	for index: int in range(7):
		var cone: MeshInstance3D = cylinder(root, 0.0, 0.14, 0.7 - 0.06 * float(index % 3), M.translucent(Color(0.8, 0.95, 1.0), 0.8, 0.5), Vector3(-1.9 + float(index) * 0.65, 4.2, 0.9), 6)
		cone.rotation_degrees.x = 180.0
	label(root, story.text("prop.freezer"), Vector3(0, 4.05, 0.82), 0.0062, Color(0.1, 0.25, 0.5), 5.0, 0)
	var frost: CPUParticles3D = CPUParticles3D.new()
	frost.amount = 14
	frost.lifetime = 2.5
	frost.preprocess = 2.5
	frost.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	frost.emission_box_extents = Vector3(1.4, 0.1, 0.3)
	frost.direction = Vector3(0, -0.3, 1)
	frost.spread = 25.0
	frost.initial_velocity_min = 0.3
	frost.initial_velocity_max = 0.8
	frost.gravity = Vector3(0, -0.35, 0)
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.2
	puff.height = 0.4
	puff.radial_segments = 6
	puff.rings = 3
	frost.mesh = puff
	frost.material_override = M.translucent(Color(0.85, 0.96, 1.0), 0.35, 0.4)
	frost.position = Vector3(0, 0.3, 1.0)
	root.add_child(frost)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.6, 0.85, 1.0)
	light.light_energy = 1.0
	light.omni_range = 5.0
	light.position = Vector3(0, 2.2, 2.2)
	root.add_child(light)
	return root


static func closed_kitchen(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	box(root, Vector3(6.0, 4.6, 2.6), M.flat(Color(0.88, 0.8, 0.7)), Vector3(0, 2.3, -0.6))
	box(root, Vector3(2.8, 3.4, 0.25), M.flat(M.WOOD_DARK), Vector3(0, 1.8, 0.76))
	for index: int in range(3):
		box(root, Vector3(3.6, 0.28, 0.1), M.flat(M.WOOD), Vector3(0, 0.9 + float(index) * 1.0, 0.95), Vector3(0, 0, -8.0 + float(index) * 8.0))
	for index: int in range(2):
		box(root, Vector3(6.4, 0.2, 0.06), M.flat(Color(1.0, 0.85, 0.1)), Vector3(0, 1.3 + float(index) * 1.4, 1.0), Vector3(0, 0, 4.0 - float(index) * 8.0))
	var plaque: MeshInstance3D = box(root, Vector3(2.6, 0.9, 0.08), M.flat(Color(0.95, 0.2, 0.2)), Vector3(0, 4.05, 0.72))
	plaque.name = "Plaque"
	label(root, story.text("prop.kitchen"), Vector3(0, 4.05, 0.78), 0.0058, Color(1, 1, 1), 2.6, 0)
	return root


static func stew_pot(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var pot: Node3D = BuffetModels.food("pot-stew")
	root.add_child(pot)
	pot.scale = Vector3.ONE * 3.2
	cylinder(root, 0.95, 0.95, 0.06, M.soup(Color(0.45, 0.75, 0.25)), Vector3(0, 1.1, 0), 18)
	steam(root, Vector3(0, 1.4, 0), 14, 0.7, 1.3)
	label(root, story.text("prop.stew"), Vector3(0, 2.4, 0.9), 0.0045, Color(1.0, 0.95, 0.75), 2.6, 6)
	return root


static func cheese_wheel(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var wheel: Node3D = BuffetModels.food("cheese")
	root.add_child(wheel)
	wheel.scale = Vector3.ONE * 6.0
	wheel.rotation_degrees.y = float(variant) * 50.0
	return root


static func pancake_stack(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(3 + variant % 2):
		var pancake: Node3D = BuffetModels.food("pancakes")
		root.add_child(pancake)
		pancake.scale = Vector3.ONE * 6.0
		pancake.position = Vector3(0.0, 0.65 * float(index), 0.0)
		pancake.rotation_degrees.y = float(index) * 37.0
	var top: float = 0.65 * float(3 + variant % 2)
	box(root, Vector3(1.0, 0.45, 0.9), M.flat(M.BUTTER), Vector3(0, top + 0.1, 0), Vector3(0, 15, 0))
	cylinder(root, 1.7, 1.9, 0.08, M.translucent(M.SYRUP, 0.85, 0.2), Vector3(0, top - 0.1, 0), 14)
	return root


# ---- Signs -------------------------------------------------------------------------------------


## A wooden sign (post board), framed poster, little note or chalkboard menu; the text is a Label3D the
## builder adds on top. Width/height are in metres of the board.
static func sign_post(width: float, height: float, style: String) -> Node3D:
	var root: Node3D = Node3D.new()
	match style:
		"poster":
			box(root, Vector3(width + 0.2, height + 0.2, 0.08), M.flat(M.WOOD_DARK), Vector3(0, 1.4 + height * 0.5, 0))
			box(root, Vector3(width, height, 0.1), M.flat(Color(1.0, 0.95, 0.8)), Vector3(0, 1.4 + height * 0.5, 0.01))
			for side: float in [-1.0, 1.0]:
				cylinder(root, 0.06, 0.06, 1.4, M.flat(M.WOOD_DARK), Vector3(side * (width * 0.4), 0.7, 0), 6)
		"memo":
			box(root, Vector3(width, height, 0.05), M.flat(Color(1.0, 0.98, 0.7)), Vector3(0, 1.1 + height * 0.5, 0))
			cylinder(root, 0.05, 0.05, 1.1, M.flat(M.WOOD_DARK), Vector3(0, 0.55, -0.04), 6)
			ball(root, 0.07, M.flat(Color(0.9, 0.15, 0.2)), Vector3(0, 1.1 + height - 0.1, 0.05))
		"menu":
			box(root, Vector3(width + 0.25, height + 0.25, 0.12), M.flat(M.WOOD), Vector3(0, 1.3 + height * 0.5, 0))
			box(root, Vector3(width, height, 0.14), M.flat(Color(0.14, 0.17, 0.15)), Vector3(0, 1.3 + height * 0.5, 0.01))
			for side: float in [-1.0, 1.0]:
				cylinder(root, 0.07, 0.07, 1.3, M.flat(M.WOOD), Vector3(side * (width * 0.45), 0.65, -0.05), 6)
		_:
			box(root, Vector3(width, height, 0.1), M.flat(Color(0.98, 0.9, 0.7)), Vector3(0, 1.45 + height * 0.5, 0))
			box(root, Vector3(width + 0.16, 0.1, 0.14), M.flat(M.WOOD_DARK), Vector3(0, 1.45 + height + 0.05, 0))
			box(root, Vector3(width + 0.16, 0.1, 0.14), M.flat(M.WOOD_DARK), Vector3(0, 1.4, 0))
			cylinder(root, 0.08, 0.08, 1.6, M.flat(M.WOOD_DARK), Vector3(-width * 0.35, 0.8, -0.04), 6)
			cylinder(root, 0.08, 0.08, 1.6, M.flat(M.WOOD_DARK), Vector3(width * 0.35, 0.8, -0.04), 6)
	return root
