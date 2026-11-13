extends GutTest
## Fable Nov 12d: pickups bob (off on Low-end and under Reduce motion), a tall piece does not dissolve at the draw-distance edge (the
## Transit Yards "ghost building"), Corwin Bale's stroll stays in the open alley, and Maren's cave-mouth welcome counts as her greeting.

var _was_low_end: bool
var _was_reduce: bool


func before_each() -> void:
	_was_low_end = GraphicsQuality.low_end
	_was_reduce = Settings.reduce_motion
	GraphicsQuality.low_end = false
	Settings.reduce_motion = false


func after_each() -> void:
	GraphicsQuality.low_end = _was_low_end
	Settings.reduce_motion = _was_reduce


func _pickup() -> Node3D:
	var holder: Node3D = Node3D.new()
	var model: Node3D = Node3D.new()
	model.name = "Model"
	model.position.y = 0.3
	holder.add_child(model)
	var ring: Node3D = Node3D.new()
	ring.name = PickupLife.RING_NODE
	holder.add_child(ring)
	add_child_autofree(holder)
	return holder


func test_a_pickup_bobs_and_its_ring_breathes() -> void:
	var holder: Node3D = _pickup()
	var tween: Tween = PickupLife.attach(holder)
	assert_not_null(tween, "motion starts")
	var model: Node3D = holder.get_node("Model") as Node3D
	var ring: Node3D = holder.get_node(PickupLife.RING_NODE) as Node3D
	var highest: float = model.position.y
	var widest: float = ring.scale.x
	for _step: int in range(30):
		tween.custom_step(PickupLife.BOB_SECONDS / 30.0)
		highest = maxf(highest, model.position.y)
		widest = maxf(widest, ring.scale.x)
		assert_almost_eq(ring.position.y, 0.0, 0.001, "the ring stays on the ground")
	assert_almost_eq(highest, 0.3 + PickupLife.BOB_HEIGHT, 0.01, "the model rises by the bob height")
	assert_gt(widest, 1.1, "the ring grows")
	assert_gte(model.position.y, 0.3 - 0.001, "it never sinks under its resting height")


func test_no_pickup_motion_on_low_end_or_reduce_motion() -> void:
	GraphicsQuality.low_end = true
	assert_null(PickupLife.attach(_pickup()), "Low-end: still")
	GraphicsQuality.low_end = false
	Settings.reduce_motion = true
	assert_null(PickupLife.attach(_pickup()), "Reduce motion: still")


func test_a_tall_piece_does_not_dissolve_at_the_range_edge() -> void:
	var rig: StyleRig = StyleRig.new()
	rig.cull_distance = 48.0
	add_child_autofree(rig)
	var tall: MeshInstance3D = MeshInstance3D.new()
	var house: BoxMesh = BoxMesh.new()
	house.size = Vector3(4.0, 13.0, 11.0)
	tall.mesh = house
	add_child_autofree(tall)
	var small: MeshInstance3D = MeshInstance3D.new()
	var crate: BoxMesh = BoxMesh.new()
	crate.size = Vector3(1.0, 1.0, 1.0)
	small.mesh = crate
	add_child_autofree(small)
	rig._limit_range(tall)
	rig._limit_range(small)
	assert_eq(tall.visibility_range_fade_mode, GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED, "a house switches, it never stands half see-through")
	assert_gt(tall.visibility_range_end, small.visibility_range_end * 1.3, "and draws further than a crate")
	assert_eq(small.visibility_range_fade_mode, GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF, "small pieces still dissolve")


func test_corwin_bale_strolls_in_the_open_alley() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var spot: Vector3 = layout.anchors["citizen_8"] as Vector3
	assert_eq(CapitalZone.citizen_name(8), "Corwin Bale")
	assert_almost_eq(spot.x, 68.5, 0.01, "he stands west of the house at x 72..77 (he stood behind it at 73.5)")
	var entry: Dictionary = {}
	for npc: Dictionary in CapitalZone.build_def().npcs:
		if str(npc["id"]) == "citizen_8":
			entry = npc
	assert_almost_eq(float(entry.get("stroll_radius", 0.0)), 2.0, 0.01, "and strolls 2 m, so he never reaches it")
	assert_lt(spot.x + 2.0, 72.0)


func test_marens_cave_mouth_welcome_is_her_greeting() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	var start: int = source.find("func _finish_cave_arrival()")
	assert_gt(start, 0)
	var body: String = source.substr(start, source.find("\nfunc ", start + 10) - start)
	assert_true(body.contains("Session.set_flag(&\"maren_met\")") and body.contains("Session.set_flag(&\"elder_greeted\")"), "the welcome sets both flags, so the Path talk is due at the first report after the armory")
