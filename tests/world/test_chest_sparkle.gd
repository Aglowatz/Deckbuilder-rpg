extends GutTest
## Overnight Oct 17, Part 3: unopened chests glint when the hero is near (fade in within 3 m, out when they leave); opened
## chests have no glint.

var _root: Node3D
var _hero: Node3D


func before_each() -> void:
	_root = Node3D.new()
	add_child_autofree(_root)
	_hero = Node3D.new()
	_hero.add_to_group(&"audio_hero")
	_root.add_child(_hero)


func after_each() -> void:
	if is_instance_valid(_hero):
		_hero.remove_from_group(&"audio_hero")


func _chest(at: Vector3) -> Node3D:
	var chest: Node3D = Node3D.new()
	chest.position = at
	var body: MeshInstance3D = MeshInstance3D.new()
	body.name = ChestKit.BODY_NODE
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(1.0, 0.8, 0.7)
	body.mesh = box
	chest.add_child(body)
	var lid: Node3D = Node3D.new()
	lid.name = ChestKit.LID_NODE
	chest.add_child(lid)
	_root.add_child(chest)
	return chest


func test_fades_in_near_and_out_far() -> void:
	var chest: Node3D = _chest(Vector3(10, 0, 0))
	_hero.position = Vector3(0, 0, 0)
	var sparkle: ChestSparkle = ChestSparkle.attach(chest)
	await wait_process_frames(5)
	assert_almost_eq(sparkle.fade, 0.0, 0.001, "far away: no glint")
	assert_false(sparkle.visible, "a faded-out glint is not drawn")
	_hero.position = Vector3(8.5, 0, 0)
	await wait_seconds(ChestSparkle.FADE_SECONDS + 0.3)
	assert_almost_eq(sparkle.fade, 1.0, 0.001, "within 3 m: full glint")
	assert_true(sparkle.visible)
	_hero.position = Vector3(0, 0, 0)
	await wait_seconds(ChestSparkle.FADE_SECONDS + 0.3)
	assert_almost_eq(sparkle.fade, 0.0, 0.001, "walking off fades it out")


func test_saved_chests_get_a_glint_only_while_unopened() -> void:
	Session.save_enabled = false
	Session.new_game()
	var shut: Node3D = _chest(Vector3(0, 0, 0))
	var found: Node3D = _chest(Vector3(4, 0, 0))
	Session.discover_secret("chest_test_found")
	ChestKit.apply_saved({"shut": shut, "found": found}, func(id: String) -> String: return "chest_test_%s" % id)
	assert_not_null(ChestSparkle.of(shut), "an unopened chest glints")
	assert_null(ChestSparkle.of(found), "an opened chest does not")
	ChestKit.open_animated(shut)
	assert_null(ChestSparkle.of(shut), "opening it removes the glint")


func test_the_glint_sits_over_the_chest() -> void:
	var chest: Node3D = _chest(Vector3(2, 0, 3))
	var sparkle: ChestSparkle = ChestSparkle.attach(chest)
	await wait_process_frames(1)
	var bounds: AABB = (sparkle.mesh as ArrayMesh).custom_aabb
	assert_true(bounds.has_point(Vector3(2, 0.6, 3)), str(bounds))
	assert_eq(sparkle.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
