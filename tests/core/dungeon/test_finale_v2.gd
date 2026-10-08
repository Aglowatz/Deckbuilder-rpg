extends GutTest
## Story v2 Part G: the Capital's hunt posters, the castle's gallery and ward, the Primm reveal, the new ending beats and Primm's fate.


func _story() -> ZoneStoryText:
	return ZoneStoryText.for_zone(CapitalZone.ID)


func test_the_reveal_scene_tells_the_wanderer_who_he_is() -> void:
	var text: String = ""
	for beat: Dictionary in CutsceneDefs.beats("primm_reveal"):
		text += "\n".join(_story().get_lines(str(beat["key"]))) + "\n"
	assert_true(text.contains("You don't even know, do you?") or text.contains("You do not even know, do you?"))
	assert_true(text.contains("I kept your face"))
	assert_true(text.contains(RoyalFamily.data().prince_full_name), "the prince's full name comes from the token")


func test_the_fight_scenes_carry_the_reflection_line_and_the_zone_lessons() -> void:
	var story: ZoneStoryText = _story()
	assert_true("\n".join(story.get_lines("cutscene.primm_p1.4")).contains("ten years of practice"), "the Reflection phase line")
	assert_true("\n".join(story.get_lines("cutscene.primm_p1.2")).contains("strength is not control"))
	assert_true("\n".join(story.get_lines("cutscene.primm_p2.2")).contains("treating people with respect"))
	assert_true("\n".join(story.get_lines("cutscene.primm_end.3")).contains("nothing grows"))
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		assert_false(PrimmBoss.leader_boon(zone_id) == null, zone_id)
	assert_eq(PrimmBoss.LEADERS["gourmand"], "The Grand Chef")
	assert_eq(PrimmBoss.LEADERS["necrocrat"], "Agnes Overdue")


func test_the_ending_has_the_throne_primm_the_stamp_and_marens_welcome() -> void:
	var by_n: Dictionary = {}
	for beat: Dictionary in EndingDefs.BEATS:
		by_n[int(beat["n"])] = "\n".join(_story().get_lines(EndingDefs.beat_key(int(beat["n"]))))
	assert_eq(EndingDefs.BEATS.size(), 10)
	assert_true(str(by_n[8]).contains("Pathwork Throne"))
	assert_true(str(by_n[8]).contains(RoyalFamily.data().prince_full_name), "his name and power return on the throne")
	assert_true(str(by_n[9]).contains("how much he broke"), "Primm realizes the damage")
	assert_true(str(by_n[10]).contains("HEIR: ALIVE. FILE COMPLETE."))
	assert_true(str(by_n[10]).contains("'Tessar,' she says"), "Maren calls him by name")
	assert_true(str(by_n[2]).contains("PATHORDIA"), "the Capital is renamed")


func test_primm_works_under_guard_after_the_ending() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var ids: Array[String] = []
	for entry: Dictionary in def.freed_npcs:
		ids.append(str(entry["id"]))
	assert_true(ids.has("primm") and ids.has("primm_guard"))
	var primm: String = "\n".join(_story().get_lines("freed_npc.primm"))
	assert_true(primm.contains("water main") and primm.contains("not permitted"), "infrastructure only, no Path workings")
	assert_true("\n".join(_story().get_lines("ending.postgame.line.3")).contains("Primm works under guard"))


func test_the_capital_and_the_player_are_renamed_by_tokens() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	assert_eq(RoyalFamily.fill("{capital}"), "Primm's Perfection")
	assert_eq(RoyalFamily.fill("{pathordia}"), "Pathordia")
	Session.set_flag(&"primm_defeated")
	assert_eq(RoyalFamily.fill("{capital}"), "Pathordia", "the Capital is Pathordia once Primm has fallen")
	Session.new_game()
	assert_eq(RoyalFamily.fill("{capital}"), "Primm's Perfection", "and a new game starts renamed back")


func test_lost_property_posters_can_be_defaced_like_the_portraits() -> void:
	for id: String in ["poster_f1", "poster_f2", "poster_a1"]:
		assert_true(CapitalZone.DEFACE_SPOTS.has(id), id)
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	for id: String in ["poster_f1", "poster_f2", "poster_a1"]:
		assert_true(layout.anchors.has(id), id)
	var posters: int = 0
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind == "portrait" and prop.variant == 2:
			posters += 1
	assert_eq(posters, 3)
	var story: ZoneStoryText = _story()
	assert_true("\n".join(story.get_lines("prop.lost_poster")).contains("IMPROVEMENT OPPORTUNITY"))
	assert_true("\n".join(story.get_lines("prop.lost_poster.known")).contains("Face: yours"), "chilling once the prince is known")
	assert_true(story.lines.has("fx.deface_poster"))


func test_the_castle_gallery_ward_and_wren_and_the_rifts() -> void:
	var story: ZoneStoryText = _story()
	var gallery: String = "\n".join(story.get_lines("dungeon.pc_gallery.before"))
	assert_true(gallery.contains("painted over in white") and gallery.contains("KEPT FOR REFERENCE"))
	var ward: String = "\n".join(story.get_lines("dungeon.pc_ward.before"))
	assert_true(ward.contains("SUBJECT") and ward.contains("M."), "the records include Maren's early notes")
	assert_true("\n".join(story.get_lines("npc.wren.intro")).contains("Maren"), "Wren names Maren as the contact in Crosspath")
	assert_true("\n".join(story.get_lines("sign.out_rift")).contains("failing"), "the rift sign explains Primm's failing hold")
	var map: DungeonMap = MainDungeons.build_map(CapitalZone.ID)
	var keys: Array[String] = []
	for node: DungeonMap.MapNode in map.nodes:
		keys.append(node.story_before)
	assert_true(keys.has("dungeon.pc_gallery.before") and keys.has("dungeon.pc_ward.before"))
