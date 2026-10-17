class_name UndercroftHouse
extends Node3D
## Overnight Oct 16, Block 3f: the Arena moved underground. The colosseum is gone; at the end of Champions' Road stands an old abandoned cottage -
## boarded windows, ivy and weeds, a sagging roof - with a cellar hatch beside it. Once the first zone is free (the Arena's old unlock) a faint
## warm glow leaks round the hatch and a muffled crowd roars down there now and then when the hero is close: the way into The Undercroft, Grand
## Bellows' underground fighting ring (a battle screen and its booth UI, not a walkable place). Before that the hatch is chained and silent.

const CHEER_RADIUS: float = 11.0

var unlocked: bool = false
## Where the hero stands to open the hatch (the scene's "arena" spot).
var hatch_spot: Vector3 = Vector3.ZERO
var _hatch: Vector3 = Vector3.ZERO
var _glow: OmniLight3D
var _cheer_timer: float = 3.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Builds the house round `center` (the colosseum's old middle), facing north onto Champions' Road. Adds its solid footprint to `town`.
static func build(parent: Node3D, town: TownBuilder, center: Vector3, is_unlocked: bool) -> UndercroftHouse:
	var house: UndercroftHouse = UndercroftHouse.new()
	house.name = "UndercroftHouse"
	house.unlocked = is_unlocked
	house._rng.seed = 13
	parent.add_child(house)
	house._build(town, center)
	return house


func _build(town: TownBuilder, center: Vector3) -> void:
	var spec: Dictionary = BuildingPresets.spec("cottage", {})
	var building: Node3D = BuildingPresets.build("cottage", {}, Color(0.55, 0.5, 0.47))
	building.name = "AbandonedCottage"
	add_child(building)
	building.position = center
	building.rotation_degrees.y = 0.0  # front (+z of the kit frame) faces south, toward the camera, so the hero at the hatch is never hidden behind it
	building.rotation_degrees.z = 1.6  # it has started to lean
	var basis: Basis = Basis.IDENTITY
	for circle: Vector3 in BuildingKit.obstacle_circles(spec, 0.05):
		var world: Vector3 = center + basis * Vector3(circle.x, 0.0, circle.y)
		town.obstacles.append(Vector3(world.x, world.z, circle.z))
	var width: float = float(spec.get("width", 6.0))
	var depth: float = float(spec.get("depth", 5.0))
	var front_z: float = center.z + depth * 0.5 + 0.06
	# Boards nailed across the windows and the door, in rough crosses.
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_texture = load("res://assets/art/textures/mat_woodplanks_albedo.webp") as Texture2D
	wood.albedo_color = Color(0.7, 0.58, 0.46)
	wood.uv1_triplanar = true
	for spot: Vector2 in [Vector2(-width * 0.3, 1.25), Vector2(width * 0.3, 1.25), Vector2(-width * 0.25, 2.75), Vector2(width * 0.25, 2.75), Vector2(0.0, 0.95)]:
		for tilt: float in [24.0, -21.0]:
			var board: MeshInstance3D = MeshInstance3D.new()
			var box: BoxMesh = BoxMesh.new()
			box.size = Vector3(1.35 if spot.y > 1.0 else 1.6, 0.16, 0.05)
			board.mesh = box
			board.material_override = wood
			board.position = Vector3(center.x + spot.x, spot.y, front_z + 0.03)
			board.rotation_degrees.z = tilt + _rng.randf_range(-4.0, 4.0)
			add_child(board)
	# Overgrowth: ivy climbing the corners, tall weeds along the front, a scraggly tree leaning over the roof.
	for side: float in [-1.0, 1.0]:
		var ivy: Node3D = TreeCards.make("dump_reed", 1.4, false)
		if ivy != null:
			ivy.position = Vector3(center.x + side * (width * 0.5 - 0.2), 0.0, front_z + 0.25)
			add_child(ivy)
	for i: int in range(7):
		var weed: Node3D = TreeCards.make("dump_wild" if i % 2 == 0 else "buff_herb", 1.0 + _rng.randf() * 0.4, false)
		if weed != null:
			weed.position = Vector3(center.x + lerpf(-width * 0.5, width * 0.5, float(i) / 6.0), 0.0, front_z + 0.5 + _rng.randf() * 0.4)
			add_child(weed)
	var lean: Node3D = TreeCards.make("dump_twisted", 0.9, true)
	if lean != null:
		lean.position = Vector3(center.x + width * 0.5 + 0.7, 0.0, center.z - 0.6)
		add_child(lean)
	# The cellar hatch: two slanted wooden doors at the front-left corner.
	_hatch = Vector3(center.x - width * 0.5 + 0.2, 0.0, front_z + 1.4)
	hatch_spot = _hatch + Vector3(0.0, 0.0, 1.25)
	town.obstacles.append(Vector3(_hatch.x, _hatch.z, 0.7))
	for side: float in [-1.0, 1.0]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var slab: BoxMesh = BoxMesh.new()
		slab.size = Vector3(0.68, 0.08, 1.3)
		door.mesh = slab
		door.material_override = wood
		door.position = _hatch + Vector3(side * 0.36, 0.28, 0.0)
		door.rotation_degrees.z = -18.0 * side
		add_child(door)
	var frame: MeshInstance3D = MeshInstance3D.new()
	var frame_box: BoxMesh = BoxMesh.new()
	frame_box.size = Vector3(1.6, 0.3, 1.5)
	frame.mesh = frame_box
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_texture = load("res://assets/art/textures/mat_stonewall_albedo.webp") as Texture2D
	stone.uv1_triplanar = true
	frame.material_override = stone
	frame.position = _hatch + Vector3(0.0, 0.1, 0.0)
	add_child(frame)
	if unlocked:
		# A warm glow leaks out of the crack between the doors.
		var slit: MeshInstance3D = MeshInstance3D.new()
		var slit_box: BoxMesh = BoxMesh.new()
		slit_box.size = Vector3(0.06, 0.05, 1.25)
		slit.mesh = slit_box
		var glow_material: StandardMaterial3D = StandardMaterial3D.new()
		glow_material.albedo_color = Color("ffb35c")
		glow_material.emission_enabled = true
		glow_material.emission = Color("ffb35c")
		glow_material.emission_energy_multiplier = 3.0
		glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		slit.material_override = glow_material
		slit.position = _hatch + Vector3(0.0, 0.36, 0.0)
		add_child(slit)
		_glow = OmniLight3D.new()
		_glow.light_color = Color("ffb35c")
		_glow.light_energy = 0.7
		_glow.omni_range = 3.2
		_glow.position = _hatch + Vector3(0.0, 0.6, 0.0)
		add_child(_glow)
	else:
		# Chained shut: a heavy chain across both doors.
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chain_box: BoxMesh = BoxMesh.new()
		chain_box.size = Vector3(1.5, 0.07, 0.07)
		chain.mesh = chain_box
		var iron: StandardMaterial3D = StandardMaterial3D.new()
		iron.albedo_color = Color(0.3, 0.3, 0.32)
		iron.metallic = 0.6
		chain.material_override = iron
		chain.position = _hatch + Vector3(0.0, 0.42, 0.0)
		add_child(chain)


## The glow flickers, and now and then a muffled roar comes up through the floor when the hero is near (only once the ring is open).
func update(hero: Vector3, delta: float) -> void:
	if not unlocked:
		return
	if _glow != null:
		_glow.light_energy = 0.6 + 0.15 * sin(Time.get_ticks_msec() * 0.007) + 0.08 * sin(Time.get_ticks_msec() * 0.019)
	_cheer_timer -= delta
	if _cheer_timer <= 0.0:
		_cheer_timer = 4.0 + _rng.randf() * 5.0
		var distance: float = Vector2(hero.x - _hatch.x, hero.z - _hatch.z).length()
		if distance < CHEER_RADIUS:
			Audio.sfx_at(&"arena_cheer", _hatch + Vector3(0.0, -2.0, 0.0), -14.0 + (1.0 - distance / CHEER_RADIUS) * 4.0)
