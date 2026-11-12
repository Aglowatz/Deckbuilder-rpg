extends GutTest
## Fable Nov 12c (A2): a boss's closing words show the speaker's picture, like every other speaker. The Cave Warden's were plain text in
## the "Through the Forgotten Cave" panel; the gatekeepers' post-fight lines were started by title only.

## Bosses whose closing beat has no portrait because no portrait art exists for them (no new art in this pass; logged in the inbox).
const NO_PORTRAIT_ART: Array[String] = ["S-IRON"]


func _dungeon_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.append_array(MainDungeons.ids())
	ids.append_array(MainDungeons.side_ids())
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not ids.has(plan.id) and MainDungeons.has_def(plan.id):
			ids.append(plan.id)
	return ids


func test_the_cave_wardens_closing_words_are_his_with_his_picture() -> void:
	var spoken: Array[String] = RewardsScreen.warden_spoken()
	assert_eq(spoken.size(), 1)
	assert_string_contains(spoken[0], "The door knows your hand")
	for line: String in RewardsScreen.warden_narration():
		assert_string_contains(line, "the Warden's eyes", "what is left describes him: narration, no portrait")
	var entry: NpcRegistry.Entry = NpcRegistry.find(RewardsScreen.WARDEN_NPC_ID)
	assert_not_null(entry, "NPC-WARDEN is in the list")
	assert_true(Portraits.has_portrait(entry.portrait_id), "and has its portrait art")
	var box: DialogueBox = DialogueBox.new()
	add_child_autofree(box)
	box.start("", spoken, RewardsScreen.WARDEN_NPC_ID)
	assert_eq(box.npc_id, RewardsScreen.WARDEN_NPC_ID, "the box shows his portrait")
	box.close_now()


func test_the_trial_complete_panel_no_longer_prints_his_words() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/dungeon/rewards_screen.gd")
	assert_false(source.contains(".join(StoryText.shared().get_lines(\"tutorial.warden.after\"))"), "not pasted into the panel's body text")
	assert_true(source.contains("closing.start(\"\", warden_spoken(), WARDEN_NPC_ID)"))


func test_every_dungeon_boss_with_closing_lines_has_a_speaker_with_a_portrait() -> void:
	var checked: int = 0
	for id: String in _dungeon_ids():
		var map: DungeonMap = MainDungeons.build_map(id)
		var boss: DungeonMap.MapNode = map.boss() if map != null else null
		if boss == null or boss.story_after.is_empty() or NO_PORTRAIT_ART.has(id):
			continue
		checked += 1
		var speaker: String = NpcRegistry.story_speaker(boss.story_after)
		var entry: NpcRegistry.Entry = NpcRegistry.find(speaker)
		assert_not_null(entry, "%s: %s has a speaker in npc_game_map.json's story_keys" % [id, boss.story_after])
		if entry != null:
			assert_true(Portraits.has_portrait(entry.portrait_id), "%s: %s has portrait art" % [id, speaker])
	assert_gt(checked, 9, "the five final dungeons and the side dungeons")


func test_the_gatekeepers_post_fight_lines_name_their_npc() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd").replace("\r\n", "\n")
	assert_false(source.contains("dialogue.start(Gatekeepers.full_title(id), lines)\n"), "no gatekeeper line is started by title alone")
	for id: String in Gatekeepers.IDS:
		var npc: String = str(TownScene.NPC_IDS.get("npc_%s" % id, ""))
		var entry: NpcRegistry.Entry = NpcRegistry.find(npc)
		assert_not_null(entry, "gatekeeper %s has an NPC" % id)
		if entry != null:
			assert_true(Portraits.has_portrait(entry.portrait_id), "%s has portrait art" % npc)
