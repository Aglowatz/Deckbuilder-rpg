class_name AmbientBirds
extends Node3D
## A small flock of low-poly birds circling over an area (two flapping wings and a body, built from primitives): HP in the sky without a model pack.

class Bird:
	extends RefCounted
	var node: Node3D
	var left: MeshInstance3D
	var right: MeshInstance3D
	var radius: float
	var speed: float
	var phase: float
	var height: float


var center: Vector3 = Vector3.ZERO
var birds: Array[Bird] = []
var _time: float = 0.0


static func spawn(parent: Node3D, area_center: Vector3, count: int, body_color: Color, seed_value: int = 5) -> AmbientBirds:
	var flock: AmbientBirds = AmbientBirds.new()
	flock.name = "AmbientBirds"
	flock.center = area_center
	parent.add_child(flock)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i: int in range(count):
		flock._add_bird(rng, body_color)
	return flock


func _add_bird(rng: RandomNumberGenerator, body_color: Color) -> void:
	var bird: Bird = Bird.new()
	bird.radius = rng.randf_range(5.0, 11.0)
	bird.speed = rng.randf_range(0.18, 0.32) * (1.0 if rng.randf() > 0.5 else -1.0)
	bird.phase = rng.randf() * TAU
	bird.height = rng.randf_range(5.5, 8.0)
	bird.node = Node3D.new()
	bird.node.set_meta(StyleToon.META_NO_TOON, true)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = body_color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var body: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.09
	capsule.height = 0.4
	body.mesh = capsule
	body.rotation_degrees.x = 90.0
	body.material_override = material
	bird.node.add_child(body)
	bird.left = _wing(material, -1.0)
	bird.right = _wing(material, 1.0)
	bird.node.add_child(bird.left)
	bird.node.add_child(bird.right)
	add_child(bird.node)
	birds.append(bird)


func _wing(material: Material, side: float) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array([Vector3(0, 0, 0.12), Vector3(side * 0.45, 0, -0.02), Vector3(0, 0, -0.14)])
	var normals: PackedVector3Array = PackedVector3Array([Vector3.UP, Vector3.UP, Vector3.UP])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var wing: MeshInstance3D = MeshInstance3D.new()
	wing.mesh = mesh
	wing.material_override = material
	return wing


func _process(delta: float) -> void:
	_time += delta
	for bird: Bird in birds:
		var angle: float = bird.phase + _time * bird.speed
		var pos: Vector3 = center + Vector3(cos(angle) * bird.radius, bird.height + sin(_time * 0.7 + bird.phase) * 0.5, sin(angle) * bird.radius * 0.8)
		bird.node.position = pos
		var tangent: Vector3 = Vector3(-sin(angle), 0.0, cos(angle) * 0.8) * signf(bird.speed)
		bird.node.rotation.y = atan2(tangent.x, tangent.z)
		var flap: float = sin(_time * 9.0 + bird.phase) * 0.7
		bird.left.rotation.z = -flap
		bird.right.rotation.z = flap
