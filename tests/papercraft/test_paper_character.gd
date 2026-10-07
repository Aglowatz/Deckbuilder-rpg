extends GutTest
## Papercraft test characters: facing from travel direction, the flip, BACK when walking away, feet on the ground.

const PaperCharacter: GDScript = preload("res://tests/papercraft/paper_character.gd")


func _rig() -> Array:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	camera.position = Vector3(0.0, 11.0, 8.2)
	camera.current = true
	camera.look_at(Vector3.ZERO, Vector3.UP)
	var body: Node3D = Node3D.new()
	root.add_child(body)
	var paper: Node3D = PaperCharacter.create("NPC-HURL", 1.0, body) as Node3D
	root.add_child(paper)
	return [paper, body]


func _walk(paper: Node3D, body: Node3D, direction: Vector3, seconds: float) -> void:
	var steps: int = int(seconds * 60.0)
	for i: int in range(steps):
		body.position += direction.normalized() * 3.0 / 60.0
		paper._process(1.0 / 60.0)


func test_feet_sit_on_the_ground_and_the_sprite_faces_the_camera() -> void:
	var rig: Array = _rig()
	var paper: Node3D = rig[0] as Node3D
	paper._process(0.016)
	var cutout: MeshInstance3D = paper.get_node("Pivot/Cutout") as MeshInstance3D
	var mesh: QuadMesh = cutout.mesh as QuadMesh
	var pixel: float = mesh.size.y / 816.0
	var soles: float = cutout.position.y - mesh.size.y * 0.5 + float(PaperCharacter.PAD_PX) * pixel
	assert_almost_eq(paper.global_position.y, 0.0, 0.0001, "root on the ground")
	assert_almost_eq(soles, 0.0, 0.0001, "the soles are exactly at y = 0, the margin hangs below")
	var to_camera: Vector3 = (paper.get_viewport().get_camera_3d().global_position - paper.global_position)
	assert_almost_eq(paper.rotation.y, atan2(to_camera.x, to_camera.z), 0.001)


func test_walking_sideways_faces_that_way_with_a_flip() -> void:
	var rig: Array = _rig()
	var paper: Node3D = rig[0] as Node3D
	var body: Node3D = rig[1] as Node3D
	_walk(paper, body, Vector3.LEFT, 0.5)
	assert_eq(int(paper.get("facing")), PaperCharacter.Facing.LEFT)
	_walk(paper, body, Vector3.RIGHT, 0.1)
	assert_eq(int(paper.get("facing")), PaperCharacter.Facing.RIGHT)
	assert_gte(float(paper.get("_flip_timer")), 0.0, "flipping")
	_walk(paper, body, Vector3.RIGHT, 0.4)
	assert_lt(float(paper.get("_flip_timer")), 0.0, "flip done after about 0.15 s")
	assert_lt((paper.get_node("Pivot") as Node3D).scale.x, 0.0, "right is the mirror of the left-facing art")


func test_walking_away_from_the_camera_shows_the_back() -> void:
	var rig: Array = _rig()
	var paper: Node3D = rig[0] as Node3D
	var body: Node3D = rig[1] as Node3D
	_walk(paper, body, Vector3(0.0, 0.0, -1.0), 0.6)
	assert_eq(int(paper.get("facing")), PaperCharacter.Facing.BACK)
	_walk(paper, body, Vector3(0.0, 0.0, 1.0), 0.6)
	assert_ne(int(paper.get("facing")), PaperCharacter.Facing.BACK, "walking towards the camera shows the front again")


func test_walk_bobs_and_idle_returns_to_the_ground() -> void:
	var rig: Array = _rig()
	var paper: Node3D = rig[0] as Node3D
	var body: Node3D = rig[1] as Node3D
	var highest: float = 0.0
	for i: int in range(60):
		body.position += Vector3.LEFT * 3.0 / 60.0
		paper._process(1.0 / 60.0)
		highest = maxf(highest, (paper.get_node("Pivot") as Node3D).position.y)
	assert_gt(highest, 0.02, "bounces while walking")
	for i: int in range(60):
		paper._process(1.0 / 60.0)
	assert_almost_eq((paper.get_node("Pivot") as Node3D).position.y, 0.0, 0.0001, "feet back on the ground when idle")
