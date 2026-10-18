extends GutTest
## Overnight Oct 17, Part 12: boss-victory stings cut from the boss tracks (data/audio/audio_extras.json, merged into the registry), the
## loop fixes (docs/audio/loop_fixes.md) and the audit and brief documents.


func before_each() -> void:
	AudioRegistry.reload()


func test_every_boss_track_has_its_victory_sting() -> void:
	var bosses: int = 0
	for id: String in AudioRegistry.ids():
		if id.begins_with("MUS-") and id.ends_with("-BOSS"):
			bosses += 1
			var sting: String = "STG-WIN-%s" % id.trim_prefix("MUS-")
			assert_true(AudioRegistry.has_id(sting), "%s has %s" % [id, sting])
			assert_true(ResourceLoader.exists(AudioRegistry.entry(sting).file), sting)
			assert_lte(AudioRegistry.entry(sting).duration, 4.0, "short")
	assert_gt(bosses, 10)


func test_the_generated_registry_still_wins_for_its_own_ids() -> void:
	assert_true(AudioRegistry.has_id("STG-VICTORY"))
	assert_true(AudioRegistry.has_id("MUS-CROSSPATH") or AudioRegistry.has_id("MUS-TOWN"), "area tracks still load")


func test_fixed_loops_have_no_silence_at_the_wrap() -> void:
	var text: String = FileAccess.get_file_as_string("res://docs/audio/loop_fixes.md")
	var rows: int = 0
	for line: String in text.split("\n"):
		if not line.begins_with("| MUS-"):
			continue
		rows += 1
		var after: String = line.split("|")[5].strip_edges()
		assert_true(after.begins_with("0.00"), "no gap after the fix: %s" % line)
	assert_gt(rows, 20)


func test_the_audit_and_the_brief_exist() -> void:
	assert_true(FileAccess.get_file_as_string("res://docs/audio/music_audit.md").contains("| Track | Name | Zone | Use | Score | Notes |"))
	var brief: String = FileAccess.get_file_as_string("res://docs/audio/music_brief.md")
	for heading: String in ["starting forest", "Crosspath", "Gainlands", "D.N.A.", "Buffet", "Dump", "Capital", "Battle", "Boss", "Dungeons", "Shops", "title", "Level-up"]:
		assert_true(brief.contains(heading), heading)
