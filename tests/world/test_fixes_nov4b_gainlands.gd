extends GutTest
## Fix pass Nov 4 (B): the Gainlands. Part 1.4: the tan "cones" near Greta were the dry grass clumps of the zone dressing (gone). Part 2.1: nothing is
## scattered on the blue workout mats of the lifting yards (no shrub, grass, rock, tree or loose prop), and the exclusion is built in, so it stays that way.

var builder: GainlandsBuilder
var layout: GainlandsLayout
var host: Node3D


func before_all() -> void:
	host = Node3D.new()
	add_child(host)
	builder = GainlandsBuilder.new()
	builder.build(host)
	layout = builder.layout


func after_all() -> void:
	host.queue_free()


func test_the_gainlands_dressing_has_no_grass_clumps() -> void:
	for item: Variant in ZoneDressing.recipe(StylePresets.GAINLANDS)["items"] as Array:
		assert_false(StyleGrass.replaces(str((item as Array)[1])), "no grass clumps (the tan cones) in the Gainlands")


func test_the_mats_are_not_floor_for_dressing() -> void:
	assert_gt(layout.yard_rects().size(), 0)
	for rect: Rect2 in layout.yard_rects():
		var centre: Vector2 = rect.get_center()
		assert_false(builder.is_floor_at(Vector3(centre.x, 0.0, centre.y)), "the mat at %s is not dressing floor" % str(centre))
		assert_false(builder.is_floor_at(Vector3(rect.position.x + 0.2, 0.0, rect.position.y + 0.2)), "nor its corner")


func test_no_scatter_lands_on_a_mat() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind.begins_with("gym:"):
			continue  # the yard's own kit stands on its mat
		assert_false(layout.on_mat(prop.pos.x, prop.pos.z), "%s at %s is off the mats" % [prop.kind, str(prop.pos)])
	var dressing: Node3D = ZoneDressing.build(host, builder, StylePresets.GAINLANDS, 2)
	var checked: int = 0
	for node: Node in dressing.find_children("*", "MultiMeshInstance3D", true, false):
		for pos: Vector3 in node.get_meta(&"positions", PackedVector3Array()) as PackedVector3Array:
			checked += 1
			assert_false(layout.on_mat(pos.x, pos.z), "no dressing on a mat (%s)" % str(pos))
	assert_gt(checked, 0, "the dressing placed something to check")
	var kit: GainlandsDressing = GainlandsDressing.build(host, builder, 2)
	for child: Node in kit.root.get_children():
		var at: Vector3 = (child as Node3D).position
		assert_false(layout.on_mat(at.x, at.z), "no loose kit on a mat (%s at %s)" % [child.name, str(at)])
