extends GutTest
## Overnight Oct 30-31 (mid-game critic #2): the zone HP bar explains its max HP - the level's base, each rule that changes it, the total.


func test_the_breakdown_adds_up() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var run: ZoneRun = Session.begin_zone_visit("beefcake")
	var lines: Array[String] = run.run.hp_breakdown()
	assert_gt(lines.size(), 1)
	assert_string_contains(lines[0], str(Session.profile.base_max_hp()))
	assert_string_contains(lines[lines.size() - 1], "= %d max HP" % run.run.max_hp())
