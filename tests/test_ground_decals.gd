extends GutTest
## The GroundDecals authoring API: kinds, the per-quality budget and the report.


func test_add_patch_counts_by_kind_and_spends_budget() -> void:
	GroundDecals.begin(0)
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var before: int = GroundDecals.budget_left()
	assert_not_null(GroundDecals.add_patch(parent, Vector3.ZERO, 1.0, GroundDecals.Kind.PUDDLE))
	assert_not_null(GroundDecals.add_patch(parent, Vector3(3, 0, 0), 1.0, GroundDecals.Kind.STAIN))
	assert_eq(GroundDecals.budget_left(), before - 2)
	var report: Dictionary = GroundDecals.report()
	assert_eq(int(report.get("PUDDLE", 0)), 1)
	assert_eq(int(report.get("STAIN", 0)), 1)


func test_add_path_needs_two_points() -> void:
	GroundDecals.begin(1)
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var one: Array[Vector3] = [Vector3.ZERO]
	assert_null(GroundDecals.add_path(parent, one, GroundDecals.Kind.CHALK))
	var two: Array[Vector3] = [Vector3.ZERO, Vector3(4, 0, 0)]
	assert_not_null(GroundDecals.add_path(parent, two, GroundDecals.Kind.CHALK, 0.4))


func test_budget_runs_out() -> void:
	GroundDecals.begin(0)
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	for i: int in range(GroundDecals.budget_left()):
		GroundDecals.add_patch(parent, Vector3(float(i), 0, 0), 0.5, GroundDecals.Kind.CRACKS)
	assert_eq(GroundDecals.budget_left(), 0)
	assert_null(GroundDecals.add_patch(parent, Vector3.ZERO, 0.5, GroundDecals.Kind.CRACKS))
	GroundDecals.begin(1)
