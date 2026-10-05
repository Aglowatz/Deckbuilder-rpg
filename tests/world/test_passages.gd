extends GutTest
## The zone passageways (brief 13): geometry orientation, the walk from entry to mouth, and the single tracked quest.


func test_yaw_points_the_passage_outwards() -> void:
	for out: Vector3 in [Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)]:
		var node: Node3D = Node3D.new()
		add_child_autofree(node)
		node.rotation_degrees.y = TownPassages.yaw_for(out)
		var local_out: Vector3 = node.global_transform.basis * Vector3(0, 0, -1)
		assert_lt(local_out.distance_to(out), 0.01, "local -Z faces %s" % str(out))


func test_every_zone_has_a_passage_with_its_name_and_a_clear_walk() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var town: TownBuilder = TownBuilder.new()
	town.build(host)
	for info: ZonePortals.Info in ZonePortals.all():
		var passage: Node3D = town.passage_nodes.get(info.id) as Node3D
		assert_not_null(passage, "%s has a passage" % info.id)
		var label: Label3D = passage.find_child("SignText", true, false) as Label3D
		assert_eq(label.text, info.display_name, "the carved sign names the zone")
		var entry: Vector3 = town.anchors["portal_%s" % info.id] as Vector3
		var mouth: Vector3 = town.anchors["portal_%s_mouth" % info.id] as Vector3
		for step: int in range(21):
			assert_true(town.is_walkable(entry.lerp(mouth, float(step) / 20.0)), "%s: the way in is clear" % info.id)
		assert_null(passage.find_child("Tower*", true, false), "no tower")


func test_quest_log_tracks_one_quest_defaulting_to_the_latest() -> void:
	var qlog: QuestLog = QuestLog.new()
	qlog.active = ["a", "b", "c"]
	assert_eq(qlog.tracked_id(), "c", "the most recent by default")
	assert_true(qlog.track("a"))
	assert_eq(qlog.tracked_id(), "a")
	assert_false(qlog.track("zzz"))
	qlog.active.erase("a")
	assert_eq(qlog.tracked_id(), "c", "a finished quest falls back to the latest")
	var copy: QuestLog = QuestLog.new()
	copy.from_dict(qlog.to_dict())
	assert_eq(copy.tracked, qlog.tracked)
