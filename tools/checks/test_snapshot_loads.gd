extends GutTest
## Overnight Nov 8-9, Part 1.3 (robustness): every snapshot on this PC (user://dev_saves/, the critic and bot saves of the last weeks)
## and every campaign save loads through `Session.from_dict` without failing, keeps its quest log, and has a sane state afterwards.
## Not in the main suite (it depends on this PC's user folder):  bash tools/run_tests.sh --only=tools/checks


func test_every_snapshot_on_this_pc_loads() -> void:
	var dir: DirAccess = DirAccess.open(DevActions.SNAPSHOT_DIR)
	if dir == null:
		pass_test("no snapshots on this PC")
		return
	var loaded: int = 0
	var failed: PackedStringArray = []
	for file: String in dir.get_files():
		if not file.ends_with(".json"):
			continue
		var data: Dictionary = SaveSystem.read(DevActions.SNAPSHOT_DIR + file)
		if data.is_empty():
			failed.append("%s: unreadable" % file)
			continue
		var ok: bool = Session.from_dict(data)
		if not ok:
			failed.append("%s: from_dict returned false" % file)
			continue
		if Session.profile == null or Session.deck == null:
			failed.append("%s: no profile/deck after load" % file)
			continue
		var round_trip: Dictionary = Session.to_dict()
		if not round_trip.has("quests") and not round_trip.has("quest_log"):
			failed.append("%s: no quest log in the re-save" % file)
			continue
		loaded += 1
	gut.p("snapshots loaded: %d, failed: %d" % [loaded, failed.size()])
	for line: String in failed:
		gut.p("  " + line)
	assert_gt(loaded, 0)
	assert_eq(failed.size(), 0, "\n".join(failed))
