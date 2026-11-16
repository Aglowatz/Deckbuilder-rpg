class_name FourSealVault
extends RefCounted
## The Four Seals in Crosspath (Brief 16, Group G; rebuilt Fable Nov 16b, Part 4). It was a tall purple box with four coloured lights in
## the middle of a field. It is a cellar door now: a low grassy bank with a fieldstone face, a timber frame and a pair of plank doors
## bound in iron, half behind a hedge, at the end of a few stepping stones - the town's own painted materials (fieldstone, planks,
## beams, hedge, grass, cobbles), no purple and no flat colour.
##
## On the doors sit four round iron seals. A seal shows a padlock while its zone's hidden lever is not pulled. Once the lever is
## pulled, the next time the hero comes near the vault the seal turns over and shows that Path's icon (a small warm glow, a clunk):
## `reveal`. No coloured lights. With all four turned the doors stand ajar and warm light falls out of the gap; once the Warden is
## beaten they stand wide open on the dark stair.
##
## Fable Nov 16c (the owner's answer to inbox 19): the four seals sit in the fixed Path order, clockwise from the top - arm (Beefcake),
## chef's hat (Gourmand), leaf (Refusemancer), skull (Necrocrat) - and a locked seal shows a faint outline of its Path's icon behind
## the padlock (`Ghost`), so the player can tell which zone's lever is still missing. `tooltip` is what the hover / prompt says
## ("Gourmand seal: locked"); `SealTooltips` shows it.

const SEAL_PREFIX: String = "Seal_"
const LEAF_LEFT: String = "LeafLeft"
const LEAF_RIGHT: String = "LeafRight"
const GLOW_NODE: String = "CellarGlow"
## How far each door leaf swings: shut, ajar (all four seals turned, the Warden waiting), wide open (the Warden beaten).
const SHUT_DEGREES: float = 0.0
const AJAR_DEGREES: float = 24.0
const OPEN_DEGREES: float = 104.0
const DOOR_WIDTH: float = 1.9
const DOOR_HEIGHT: float = 1.75
const SEAL_RADIUS: float = 0.19
const PADLOCK_ICON: String = "ICON-PADLOCK"
## Where each seal sits on the shut doors, from the foot of the doors (x across, y up), in `VaultGuardian.ZONE_IDS` order: clockwise from the top.
const SEAL_SPOTS: Array[Vector2] = [Vector2(0.0, 1.45), Vector2(0.45, 1.02), Vector2(0.0, 0.59), Vector2(-0.45, 1.02)]
## The faint outline of the Path's icon on a locked seal: how wide it is drawn (in seal radii) and how small the padlock sits on it.
const GHOST_WIDTH: float = 1.72
const PADLOCK_WIDTH: float = 0.95
const ICON_WIDTH: float = 1.5
const GHOST_SHADER: String = "res://world/vault/seal_ghost.gdshader"
## The hero comes this close (metres) and the seals whose levers were pulled since the last visit turn over.
const REVEAL_RANGE: float = 9.0
const TURN_SECONDS: float = 0.9
## What is solid, from the foot of the doors (x, z, radius): the stone face, the bank behind it, the hedges beside it.
const SOLID: Array[Vector3] = [
	Vector3(-1.3, -0.1, 0.75), Vector3(0.0, -0.1, 0.8), Vector3(1.3, -0.1, 0.75), Vector3(0.0, -3.3, 2.9), Vector3(-2.9, -1.6, 1.3), Vector3(3.0, -1.8, 1.2),
	Vector3(-2.5, 1.5, 0.6), Vector3(-3.3, 1.0, 0.6), Vector3(2.9, 0.9, 0.6),
]
## An apple tree stands half in front of the cellar, west of the stepping stones (from the foot of the doors).
const APPLE_TREE: Vector3 = Vector3(-4.3, 0.0, 2.7)


## The flag that says the hero has seen zone `zone_id`'s seal turn.
static func seen_flag(zone_id: String) -> StringName:
	return StringName("vault_seal_seen_%s" % zone_id)


## A seal shows its Path's icon once its lever is pulled AND the hero has watched it turn.
static func seal_open(zone_id: String) -> bool:
	return Session.vault_lever_pulled(zone_id) and Session.flag(seen_flag(zone_id))


static func open_count() -> int:
	var count: int = 0
	for zone_id: String in VaultGuardian.ZONE_IDS:
		if seal_open(zone_id):
			count += 1
	return count


## The seals that will turn the next time the hero comes near (levers pulled since the last visit).
static func pending() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in VaultGuardian.ZONE_IDS:
		if Session.vault_lever_pulled(zone_id) and not Session.flag(seen_flag(zone_id)):
			result.append(zone_id)
	return result


## The Path's icon of a seal (what its ghost outlines and what it shows once turned).
static func path_icon(zone_id: String) -> String:
	return IconArt.energy_id(ZoneEffects.path_of(zone_id))


## What a hover or the prompt says about a seal: "Gourmand seal: locked" / "Gourmand seal: turned".
static func tooltip(zone_id: String) -> String:
	return "%s seal: %s" % [Affinity.display_name(ZoneEffects.path_of(zone_id)), "turned" if seal_open(zone_id) else "locked"]


## The icon a seal's face shows.
static func face_icon(zone_id: String, open: bool) -> String:
	return IconArt.energy_id(ZoneEffects.path_of(zone_id)) if open else PADLOCK_ICON


## How far the doors stand open right now (degrees).
static func door_degrees() -> float:
	if Session.vault_defeated():
		return OPEN_DEGREES
	return AJAR_DEGREES if open_count() == VaultGuardian.ZONE_IDS.size() else SHUT_DEGREES


## Builds the vault at `position` (the foot of the doors, facing +z) under `parent` and shows the save's state.
static func build(parent: Node3D, position: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "FourSealVault"
	root.position = position
	parent.add_child(root)
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("grass", EnvKit.material("ENV-GROUND-GRASS-CALM"))
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	mesh.set_material("cap", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.84, 0.86, 0.78)))
	mesh.set_material("dark", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.07, 0.06, 0.08)))
	mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	mesh.set_material("leaf", EnvKit.material("ENV-HEDGE", false, Color(0.62, 0.72, 0.5)))
	mesh.set_material("moss", EnvKit.material("ENV-HEDGE", false, Color(0.5, 0.62, 0.36)))
	mesh.set_material("cobble", EnvKit.material("ENV-GROUND-COBBLE"))
	# The bank: a grassy mound the cellar is dug into, the door's stone face on its south side.
	# (a blob is round on the ground: its x radius is its z radius too)
	mesh.blob("grass", Vector3(0.0, 0.3, -3.3), Vector3(3.1, 2.0, 3.1), 6, 12, 0.9)
	mesh.blob("grass", Vector3(-2.9, 0.2, -1.6), Vector3(1.5, 1.05, 1.5), 5, 10, 0.9)
	mesh.blob("grass", Vector3(3.0, 0.2, -1.8), Vector3(1.4, 1.0, 1.4), 5, 10, 0.9)
	mesh.box("stone", Vector3(0.0, 1.05, -0.12), Vector3(3.3, 2.1, 0.7), Basis.IDENTITY, 0.08, 0.85)
	for side: float in [-1.0, 1.0]:
		mesh.box("stone", Vector3(side * 1.42, 0.95, 0.22), Vector3(0.62, 1.9, 0.62), Basis.IDENTITY, 0.07, 0.8)
		mesh.box("cap", Vector3(side * 1.42, 1.96, 0.22), Vector3(0.74, 0.16, 0.74), Basis.IDENTITY, 0.04)
	mesh.box("cap", Vector3(0.0, 2.2, -0.02), Vector3(3.5, 0.22, 0.86), Basis.IDENTITY, 0.05)
	# The dark of the stair behind the doors.
	mesh.box("dark", Vector3(0.0, 0.93, 0.02), Vector3(DOOR_WIDTH + 0.06, DOOR_HEIGHT + 0.1, 0.5))  # (its front stands just proud of the stone face)
	# The timber frame.
	for side: float in [-1.0, 1.0]:
		mesh.box("beam", Vector3(side * (DOOR_WIDTH * 0.5 + 0.09), 0.93, 0.3), Vector3(0.18, 1.86, 0.24), Basis.IDENTITY, 0.02)
	mesh.box("beam", Vector3(0.0, DOOR_HEIGHT + 0.14, 0.3), Vector3(DOOR_WIDTH + 0.5, 0.22, 0.28), Basis.IDENTITY, 0.02)
	# Moss on the stone, a hedge half across the front, and the stepping stones of the side path.
	mesh.blob("moss", Vector3(-1.1, 2.3, -0.1), Vector3(0.7, 0.2, 0.45), 4, 8, 0.8)
	mesh.blob("moss", Vector3(1.3, 2.28, -0.2), Vector3(0.5, 0.18, 0.4), 4, 8, 0.8)
	mesh.blob("moss", Vector3(1.55, 0.25, 0.5), Vector3(0.4, 0.3, 0.3), 4, 8, 0.8)
	for hedge: Vector3 in [Vector3(-2.5, 0.55, 1.5), Vector3(-3.3, 0.6, 1.0), Vector3(2.9, 0.5, 0.9)]:
		mesh.blob("leaf", hedge, Vector3(0.85, 0.78, 0.7), 5, 9, 0.7)
	for stone: Vector3 in [Vector3(0.15, 0.03, 1.2), Vector3(0.5, 0.03, 2.0), Vector3(0.95, 0.03, 2.8), Vector3(1.6, 0.03, 3.5)]:
		mesh.box("cobble", stone, Vector3(0.62, 0.07, 0.5), Basis(Vector3.UP, stone.x * 0.7), 0.03)
	var body: MeshInstance3D = mesh.instance("Cellar")
	body.set_meta(&"no_wind", true)
	body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	var apple: Node3D = TreeCards.make("fruit", 0.85, true)
	if apple != null:
		apple.name = "AppleTree"
		apple.position = APPLE_TREE
		root.add_child(apple)
	# The two leaves, each on its own hinge, two seals on each.
	for side: float in [-1.0, 1.0]:
		var leaf: Node3D = Node3D.new()
		leaf.name = LEAF_LEFT if side < 0.0 else LEAF_RIGHT
		leaf.position = Vector3(side * DOOR_WIDTH * 0.5, 0.04, 0.3)
		leaf.set_meta(&"side", side)
		root.add_child(leaf)
		var planks: MeshInstance3D = _leaf_mesh(side).instance("Planks")
		planks.set_meta(&"no_wind", true)
		planks.set_meta(&"no_occlusion_fade", true)
		leaf.add_child(planks)
	for index: int in range(VaultGuardian.ZONE_IDS.size()):
		var zone_id: String = VaultGuardian.ZONE_IDS[index]
		# Fable Nov 16c: a diamond in the fixed Path order, clockwise from the top (arm, chef's hat, leaf, skull). The top and the left
		# seal ride the left leaf, the right and the bottom one the right leaf; each swings with its leaf.
		var spot: Vector2 = SEAL_SPOTS[index]
		var on_left: bool = index == 0 or index == 3
		var leaf_node: Node3D = root.get_node(LEAF_LEFT if on_left else LEAF_RIGHT) as Node3D
		var hinge_x: float = (-1.0 if on_left else 1.0) * DOOR_WIDTH * 0.5
		var seal: Node3D = _seal(zone_id)
		seal.position = Vector3(spot.x - hinge_x, spot.y - 0.04, 0.1)
		leaf_node.add_child(seal)
	# Warm light out of the gap while the doors stand ajar (no colour: lamplight on the stair).
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = GLOW_NODE
	glow.position = Vector3(0.0, 0.9, 0.55)
	glow.light_color = Color(1.0, 0.82, 0.52)
	glow.omni_range = 3.2
	glow.light_energy = 0.0
	root.add_child(glow)
	refresh(root)
	return root


## One door leaf, hinged at its outer edge (x = 0) and reaching toward the middle: planks, three iron straps, a ring.
static func _leaf_mesh(side: float) -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("plank", EnvKit.material("ENV-WALL-PLANK", false, Color(0.86, 0.78, 0.66)))
	mesh.set_material("iron", iron_material())
	var half: float = DOOR_WIDTH * 0.25
	mesh.box("plank", Vector3(-side * half, DOOR_HEIGHT * 0.5, 0.0), Vector3(DOOR_WIDTH * 0.5 - 0.03, DOOR_HEIGHT, 0.1), Basis.IDENTITY, 0.015)
	for strap_y: float in [0.28, 0.82, 1.5]:
		mesh.box("iron", Vector3(-side * half, strap_y, 0.06), Vector3(DOOR_WIDTH * 0.5 - 0.02, 0.1, 0.03))
	mesh.box("iron", Vector3(-side * (DOOR_WIDTH * 0.5 - 0.16), 0.62, 0.08), Vector3(0.1, 0.2, 0.05), Basis.IDENTITY, 0.02)
	return mesh


## Old iron: the beam painting, darkened and a little metallic (the kit has no iron of its own).
static func iron_material() -> StandardMaterial3D:
	var iron: StandardMaterial3D = EnvKit.material("ENV-BEAM", false, Color(0.2, 0.21, 0.25)).duplicate() as StandardMaterial3D
	iron.metallic = 0.45
	iron.roughness = 0.62
	return iron


## A round iron seal: a disc with a raised rim and a painted face (the padlock or the Path's icon).
static func _seal(zone_id: String) -> Node3D:
	var seal: Node3D = Node3D.new()
	seal.name = SEAL_PREFIX + zone_id
	var disc: MeshInstance3D = MeshInstance3D.new()
	disc.name = "Disc"
	var shape: CylinderMesh = CylinderMesh.new()
	shape.top_radius = SEAL_RADIUS
	shape.bottom_radius = SEAL_RADIUS + 0.015
	shape.height = 0.06
	shape.radial_segments = 20
	disc.mesh = shape
	disc.rotation_degrees.x = 90.0
	disc.material_override = iron_material()
	disc.set_meta(StyleToon.META_NO_TOON, true)
	seal.add_child(disc)
	var rim: MeshInstance3D = MeshInstance3D.new()
	rim.name = "Rim"
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = SEAL_RADIUS - 0.035
	ring.outer_radius = SEAL_RADIUS + 0.012
	ring.rings = 20
	ring.ring_segments = 6
	rim.mesh = ring
	rim.rotation_degrees.x = 90.0
	rim.position.z = 0.025
	rim.material_override = iron_material()
	rim.set_meta(StyleToon.META_NO_TOON, true)
	seal.add_child(rim)
	# The faint outline of the Path's icon behind the padlock (hidden once the seal has turned).
	var ghost: MeshInstance3D = MeshInstance3D.new()
	ghost.name = "Ghost"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE * SEAL_RADIUS * GHOST_WIDTH
	ghost.mesh = quad
	ghost.position.z = 0.033
	var ghost_material: ShaderMaterial = ShaderMaterial.new()
	ghost_material.shader = load(GHOST_SHADER) as Shader
	ghost_material.set_shader_parameter("icon", IconArt.texture(path_icon(zone_id), 128.0))
	ghost.material_override = ghost_material
	ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ghost.set_meta(StyleToon.META_NO_TOON, true)
	ghost.set_meta(&"icon", path_icon(zone_id))
	seal.add_child(ghost)
	var face: Sprite3D = Sprite3D.new()
	face.name = "Face"
	face.position.z = 0.036
	face.shaded = false
	face.double_sided = false
	face.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	face.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	face.set_meta(StyleToon.META_NO_TOON, true)
	seal.add_child(face)
	return seal


## Puts the padlock or the Path's icon on a seal's face.
static func set_seal(root: Node3D, zone_id: String, open: bool) -> void:
	var seal: Node3D = root.find_child(SEAL_PREFIX + zone_id, true, false) as Node3D
	if seal == null:
		return
	var face: Sprite3D = seal.get_node_or_null("Face") as Sprite3D
	if face == null:
		return
	var icon: String = face_icon(zone_id, open)
	var texture: Texture2D = IconArt.texture(icon, 128.0)
	face.texture = texture
	if texture != null:
		face.pixel_size = (SEAL_RADIUS * (ICON_WIDTH if open else PADLOCK_WIDTH)) / float(maxi(texture.get_width(), 1))
	# A padlock sits dimmed on the iron, small, over the faint outline of its Path's icon; a turned seal's icon is in full colour.
	face.modulate = Color.WHITE if open else Color(0.72, 0.7, 0.66)
	var ghost: Node3D = seal.get_node_or_null("Ghost") as Node3D
	if ghost != null:
		ghost.visible = not open
	seal.set_meta(&"icon", icon)
	seal.set_meta(&"open", open)


## Shows the save's state: the four faces, how far the doors stand open, the light on the stair.
static func refresh(root: Node3D) -> void:
	for zone_id: String in VaultGuardian.ZONE_IDS:
		set_seal(root, zone_id, seal_open(zone_id))
	_set_doors(root, door_degrees())


static func _set_doors(root: Node3D, degrees: float) -> void:
	for leaf_name: String in [LEAF_LEFT, LEAF_RIGHT]:
		var leaf: Node3D = root.get_node_or_null(leaf_name) as Node3D
		if leaf != null:
			leaf.rotation.y = deg_to_rad(degrees) * float(leaf.get_meta(&"side", 1.0))
	var glow: OmniLight3D = root.get_node_or_null(GLOW_NODE) as OmniLight3D
	if glow != null:
		glow.light_energy = 1.1 if is_equal_approx(degrees, AJAR_DEGREES) else 0.0


## True when the hero at `hero` is near enough to see a seal turn and one is waiting to.
static func should_reveal(root: Node3D, hero: Vector3) -> bool:
	return root != null and not root.has_meta(&"revealing") and not pending().is_empty() and Vector2(hero.x - root.global_position.x, hero.z - root.global_position.z).length() <= REVEAL_RANGE


## The seals whose levers were pulled since the last visit turn over, one after another (a clunk, a small warm glow), then the doors
## move if that was the last one. `instant`: no waits (tests). Each seal is remembered as seen as it turns.
static func reveal(root: Node3D, instant: bool = false) -> void:
	if root == null or root.has_meta(&"revealing"):
		return
	root.set_meta(&"revealing", true)
	var before: float = door_degrees()
	for zone_id: String in pending():
		var seal: Node3D = root.find_child(SEAL_PREFIX + zone_id, true, false) as Node3D
		Session.set_flag(seen_flag(zone_id))
		if seal == null or instant or not root.is_inside_tree():
			set_seal(root, zone_id, true)
			continue
		Audio.sfx_at(&"lever_clunk", seal.global_position, -6.0)
		var turn: Tween = seal.create_tween()
		turn.tween_property(seal, "rotation:y", PI * 0.5, TURN_SECONDS * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		turn.tween_callback(func() -> void:
			set_seal(root, zone_id, true)
			seal.rotation.y = -PI * 0.5)
		turn.tween_property(seal, "rotation:y", 0.0, TURN_SECONDS * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_glow(seal)
		await turn.finished
		if not is_instance_valid(root) or not root.is_inside_tree():
			return
		Audio.sfx_at(&"ding", seal.global_position, -10.0)
		await root.get_tree().create_timer(0.25).timeout
	if not is_instance_valid(root):
		return
	var after: float = door_degrees()
	if instant or not root.is_inside_tree() or is_equal_approx(before, after):
		_set_doors(root, after)
	else:
		Audio.sfx_at(&"vault_grind", root.global_position, -4.0)
		for leaf_name: String in [LEAF_LEFT, LEAF_RIGHT]:
			var leaf: Node3D = root.get_node_or_null(leaf_name) as Node3D
			if leaf != null:
				leaf.create_tween().tween_property(leaf, "rotation:y", deg_to_rad(after) * float(leaf.get_meta(&"side", 1.0)), 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var glow: OmniLight3D = root.get_node_or_null(GLOW_NODE) as OmniLight3D
		if glow != null:
			glow.create_tween().tween_property(glow, "light_energy", 1.1 if is_equal_approx(after, AJAR_DEGREES) else 0.0, 1.6)
	Session.save_game()
	root.remove_meta(&"revealing")


## A small warm glow over a seal as it turns: a soft disc that swells and fades (no colour of its Path).
static func _glow(seal: Node3D) -> void:
	var glow: Sprite3D = Sprite3D.new()
	glow.name = "TurnGlow"
	glow.texture = UIStyle.circle_texture(96, Color(1.0, 0.86, 0.55, 0.85), Color(1.0, 0.86, 0.55, 0.0), 30)
	glow.pixel_size = (SEAL_RADIUS * 3.4) / 96.0
	glow.position.z = 0.05
	glow.shaded = false
	glow.transparency = 1.0
	glow.set_meta(StyleToon.META_NO_TOON, true)
	seal.add_child(glow)
	var pulse: Tween = glow.create_tween()
	pulse.tween_property(glow, "transparency", 0.25, TURN_SECONDS * 0.5)
	pulse.tween_property(glow, "transparency", 1.0, TURN_SECONDS * 0.7)
	pulse.tween_callback(glow.queue_free)
