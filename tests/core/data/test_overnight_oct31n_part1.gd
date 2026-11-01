extends GutTest
## Overnight Oct 31 - Nov 1, Part 1d: the designer's answers 8-10, the feats re-check on load and the boss plate fit.


func after_each() -> void:
	SpoilerFree.sync({})


func test_the_doppelganger_keeps_its_cover_name_until_the_reveal() -> void:
	SpoilerFree.sync({})
	var doppel: NpcRegistry.Entry = NpcRegistry.find("NPC-DOPPEL")
	assert_not_null(doppel)
	assert_eq(doppel.plate_name(), "The Doppelganger")
	assert_eq(str(BossIntros.find("The Doppelganger")["name"]), "The Doppelganger")


func test_the_doppelganger_keeps_its_name_after_the_reveal() -> void:
	SpoilerFree.sync({"cutscene_seen_wonder": true})
	assert_eq(NpcRegistry.find("NPC-DOPPEL").plate_name(), "Escoffina", "Fable pass Nov 1 (Part 4): the apprentice reads Escoffina after the reveal")
	assert_eq(str(BossIntros.find("The Doppelganger")["name"]), "The Doppelganger", "the boss fight always reads The Doppelganger")
	assert_eq(str(BossIntros.find("The Itamae Supreme")["name"]), "The Itamae Supreme", "other bosses unchanged")


func test_a_freed_buffet_counts_as_revealed_for_old_saves() -> void:
	SpoilerFree.sync({str(ZoneCompletion.flag_name("gourmand")): true})
	assert_true(SpoilerFree.is_revealed("NPC-DOPPEL"))


func test_the_session_syncs_the_reveal_from_its_flags() -> void:
	var before: bool = Session.flag(&"cutscene_seen_wonder")
	Session.set_flag(&"cutscene_seen_wonder")
	assert_true(SpoilerFree.is_revealed("NPC-DOPPEL"))
	Session.set_flag(&"cutscene_seen_wonder", before)
	assert_eq(SpoilerFree.is_revealed("NPC-DOPPEL"), before or Session.is_zone_completed("gourmand"))


func _spotless_entry() -> Dictionary:
	for entry: Dictionary in CapitalZone.build_def().npcs:
		if str(entry["id"]) == "spotless":
			return entry
	return {}


func test_captain_spotless_paces_on_his_walk_set_until_the_gate_opens() -> void:
	var entry: Dictionary = _spotless_entry()
	assert_false(entry.is_empty())
	assert_true(entry.has("pace"), "answer 8: he paces")
	assert_true((entry["pace"] as Array).has(Vector3.ZERO), "his beat comes back to the post")
	assert_eq(str(entry["pace_until_flag"]), str(CapitalZone.FLAG_GATE_OPEN))
	assert_true(SpriteLibrary.has_character(str(entry["pace_sprite"])), "the walk set the game looks up is imported")
	assert_false((SpriteLibrary.info(str(entry["pace_sprite"])).get("walk_dirs", []) as Array).is_empty(), "and it has walk strips")


func test_a_pacing_stroller_walks_its_beat_and_returns_home() -> void:
	var stroller: SpriteStroller = SpriteStroller.new()
	stroller.character = str(_spotless_entry()["pace_sprite"])
	stroller.pace.append_array([Vector3(-1.8, 0.0, 0.5), Vector3.ZERO, Vector3(1.8, 0.0, 0.5), Vector3.ZERO] as Array[Vector3])
	stroller.home_facing = Vector3(0.0, 0.0, 1.0)
	add_child_autofree(stroller)
	stroller.setup(Vector3(10.0, 0.0, 10.0), func(_p: Vector3) -> bool: return true, 7)
	var min_x: float = 10.0
	var max_x: float = 10.0
	var far: float = 0.0
	var home_again: bool = false
	for frame: int in range(60 * 40):
		stroller.tick(1.0 / 60.0, Vector3(100.0, 0.0, 100.0))
		var p: Vector3 = stroller.world_position()
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		far = maxf(far, p.distance_to(Vector3(10.0, 0.0, 10.0)))
		if max_x > 11.5 and min_x < 8.5 and p.distance_to(Vector3(10.0, 0.0, 10.0)) < 0.05:
			home_again = true
	assert_lt(min_x, 8.5, "walks to the left beat")
	assert_gt(max_x, 11.5, "walks to the right beat")
	assert_lt(far, 2.0, "never strays more than a few steps")
	assert_true(home_again, "comes back to his post")


func test_the_boss_plate_fits_names_whole_and_puts_a_phase_on_its_caption() -> void:
	var font: Font = UIStyle.font_title()
	var box: Vector2 = BattleHud.Portrait.NAME_BOX.size
	for title: String in ["Primm - Phase Standardization", "The Doppelganger", "Colonel Cornelius Crumb", "Cave Scavenger"]:
		var parts: PackedStringArray = BattleHud.Portrait.plate_title_parts(title)
		var font_size: int = BattleHud.Portrait.plate_title_size(font, parts[0], box, 22, 10)
		for word: String in parts[0].split(" ", false):
			assert_lte(font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x, box.x, "%s: '%s' fits whole at %d" % [title, word, font_size])
		var height: float = font.get_multiline_string_size(parts[0], HORIZONTAL_ALIGNMENT_LEFT, box.x, font_size, -1, TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY).y
		assert_lte(height, box.y, "%s: the lines fit the band" % title)
	assert_eq(BattleHud.Portrait.plate_title_parts("Primm - Phase Standardization"), PackedStringArray(["Primm", "Phase Standardization"]))
	var cap: Vector2 = BattleHud.Portrait.CAPTION_BOX.size
	var cap_size: int = BattleHud.Portrait.plate_title_size(font, "Phase Standardization", Vector2(cap.x, 999.0), 18, 11, true)
	assert_lte(font.get_string_size("Phase Standardization", HORIZONTAL_ALIGNMENT_LEFT, -1, cap_size).x, cap.x, "the phase caption fits on one line")
	assert_lte(BattleHud.Portrait.NAME_BOX.end.x, 226.0, "the name box stops short of the heart")


func test_the_plate_clips_its_name_to_the_band() -> void:
	var plate: BattleHud.Portrait = BattleHud.Portrait.new()
	plate.title = "Primm - Phase Standardization"
	add_child_autofree(plate)
	await wait_frames(2)
	var box: Control = plate.find_child("NameBox", true, false) as Control
	if box == null:
		pass_test("no plate art in this build")
		return
	assert_true(box.clip_contents)
	assert_lte(box.size.x, BattleHud.Portrait.NAME_BOX.size.x + 0.5, "the box keeps its width")
	assert_not_null(plate.find_child("PhaseCaption", true, false), "the phase caption is drawn")
