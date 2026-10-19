class_name HeapCritters
extends Node3D
## The Verdant Dump v2's small life (docs/art/verdant_dump_v2.md, Part D): a few critters (raccoons, rats, a possum, a fox) that trot back and forth
## between two spots on their terrace (the Cube Pets animals, tinted), pausing to nose about at each end, kept to the junk clusters at the edges so
## they never cross a route or stand on an anchor. Decoration only: nothing here blocks, and they keep clear of the hero's spots.

const PAUSE: float = 2.4
const SPEED: float = 1.6


class Critter:
	extends RefCounted
	var node: Node3D
	var a: Vector3
	var b: Vector3
	var t: float = 0.0
	var forward: bool = true
	var wait: float = 0.0
	var player: AnimationPlayer


var critters: Array[Critter] = []
var _height: Callable


## `runs`: a list of [kind, Vector2 a (xz), Vector2 b (xz)]; `height` gives the ground height at (x, z).
static func spawn(parent: Node3D, runs: Array, height: Callable, seed_value: int = 21) -> HeapCritters:
	var life: HeapCritters = HeapCritters.new()
	life.name = "HeapCritters"
	life._height = height
	parent.add_child(life)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for entry: Variant in runs:
		var run: Array = entry as Array
		life._add(str(run[0]), run[1] as Vector2, run[2] as Vector2, rng)
	return life


func _add(kind: String, a: Vector2, b: Vector2, rng: RandomNumberGenerator) -> void:
	var model: String = "animal-cat"
	var tint: Color = Color.WHITE
	var scale_value: float = 0.7
	match kind:
		"raccoon":
			model = "animal-cat"
			tint = Color(0.6, 0.6, 0.66)
			scale_value = 0.75
		"rat":
			model = "animal-bunny"
			tint = Color(0.55, 0.5, 0.48)
			scale_value = 0.45
		"possum":
			model = "animal-fox"
			tint = Color(0.78, 0.74, 0.7)
			scale_value = 0.6
		"fox":
			model = "animal-fox"
			scale_value = 0.7
		"chick":
			model = "animal-chick"
			scale_value = 0.5
	var node: Node3D = HeapModels.pet(model)
	if tint != Color.WHITE:
		ModelKit.tint(node, tint)
	add_child(node)
	node.scale = Vector3.ONE * scale_value
	node.set_meta(&"no_occlusion_fade", true)
	var critter: Critter = Critter.new()
	critter.node = node
	critter.a = Vector3(a.x, float(_height.call(a.x, a.y)), a.y)
	critter.b = Vector3(b.x, float(_height.call(b.x, b.y)), b.y)
	critter.t = rng.randf()
	critter.wait = rng.randf_range(0.0, PAUSE)
	critter.player = ModelKit.animation_player(node)
	critters.append(critter)
	_place(critter)


func _place(critter: Critter) -> void:
	var from: Vector3 = critter.a if critter.forward else critter.b
	var to: Vector3 = critter.b if critter.forward else critter.a
	var pos: Vector3 = from.lerp(to, critter.t)
	pos.y = float(_height.call(pos.x, pos.z))
	critter.node.position = pos
	var heading: Vector3 = to - from
	if heading.length_squared() > 0.001:
		critter.node.rotation.y = atan2(heading.x, heading.z)


func _process(delta: float) -> void:
	for critter: Critter in critters:
		var moving: bool = critter.wait <= 0.0
		if moving:
			var length: float = maxf(critter.a.distance_to(critter.b), 0.1)
			critter.t += delta * SPEED / length
			if critter.t >= 1.0:
				critter.t = 0.0
				critter.forward = not critter.forward
				critter.wait = PAUSE
			_place(critter)
		else:
			critter.wait -= delta
		if critter.player != null:
			var wanted: String = "walk" if moving else ("eat" if critter.player.has_animation("eat") else "idle")
			if critter.player.has_animation(wanted) and critter.player.current_animation != wanted:
				critter.player.play(wanted, 0.2)
