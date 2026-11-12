extends GutTest
## Fable Nov 12 (Part 2.5): the prop-ground check's rules (`PropGroundCheck`): a prop floats when its underside is more than FLOAT_GAP over
## the ground, is sunk when most of it lies under the ground; hanging things, things standing on another prop, pebbles and buildings pass.


func _box(parent: Node3D, node_name: String, size: Vector3, centre: Vector3) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	parent.add_child(instance)
	instance.position = centre
	return instance


func _scene() -> Node3D:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	return root


func _kinds(found: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for entry: Dictionary in found:
		result[str(entry["path"])] = str(entry["kind"])
	return result


func test_a_prop_on_the_ground_passes_and_a_floating_one_fails() -> void:
	var root: Node3D = _scene()
	_box(root, "Crate", Vector3(0.8, 0.8, 0.8), Vector3(0, 0.4, 0))
	_box(root, "Barrel", Vector3(0.8, 1.0, 0.8), Vector3(5, 1.2, 0))
	var kinds: Dictionary = _kinds(PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 0.0))
	assert_false(kinds.has("Crate"), "a crate standing on the ground is fine")
	assert_eq(str(kinds.get("Barrel", "")), "floats", "a barrel 0.7 m over the ground floats")


func test_a_sunk_prop_fails_and_a_bedded_one_passes() -> void:
	var root: Node3D = _scene()
	_box(root, "Rock", Vector3(1.0, 1.0, 1.0), Vector3(0, -0.3, 0))
	_box(root, "Stump", Vector3(1.0, 1.0, 1.0), Vector3(5, 0.3, 0))
	var kinds: Dictionary = _kinds(PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 0.0))
	assert_eq(str(kinds.get("Rock", "")), "sunk", "a rock 80 % under the ground is sunk")
	assert_false(kinds.has("Stump"), "a stump bedded 20 cm into the ground is fine")


func test_the_ground_height_is_the_maps() -> void:
	var root: Node3D = _scene()
	_box(root, "Crate", Vector3(0.8, 0.8, 0.8), Vector3(0, 4.4, 0))
	assert_true(PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 4.0).is_empty(), "on a 4 m plateau the same crate stands on the ground")
	assert_eq(PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 0.0).size(), 1)


func test_hanging_things_stacked_things_pebbles_and_buildings_pass() -> void:
	var root: Node3D = _scene()
	_box(root, "RulerBanner", Vector3(1.0, 2.0, 0.1), Vector3(0, 4.0, 0))
	var flagged: MeshInstance3D = _box(root, "Chandelier", Vector3(1.0, 1.0, 1.0), Vector3(3, 4.0, 0))
	flagged.set_meta(PropGroundCheck.META_OFF_GROUND, true)
	_box(root, "Counter", Vector3(2.0, 1.0, 1.0), Vector3(6, 0.5, 0))
	_box(root, "Jar", Vector3(0.4, 0.4, 0.4), Vector3(6, 1.2, 0))
	_box(root, "Pebble", Vector3(0.1, 0.1, 0.1), Vector3(9, 2.0, 0))
	_box(root, "Tower", Vector3(8.0, 20.0, 8.0), Vector3(20, 14.0, 0))
	var holder: Node3D = Node3D.new()
	holder.name = "Bunting"
	root.add_child(holder)
	_box(holder, "Piece", Vector3(0.5, 0.5, 0.05), Vector3(12, 3.5, 0))
	var found: Array[Dictionary] = PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 0.0)
	assert_true(found.is_empty(), "nothing here is an offender: %s" % str(_kinds(found)))


func test_a_jar_beside_the_counter_still_floats() -> void:
	var root: Node3D = _scene()
	_box(root, "Counter", Vector3(2.0, 1.0, 1.0), Vector3(0, 0.5, 0))
	_box(root, "Jar", Vector3(0.4, 0.4, 0.4), Vector3(3, 1.2, 0))
	assert_eq(str(_kinds(PropGroundCheck.scan(root, func(_p: Vector3) -> float: return 0.0)).get("Jar", "")), "floats")
