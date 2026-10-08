extends GutTest
## Story v2 Part E: the memory fragments, Maren's stages, the quest and the name change after the reveal.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.new_game()


func test_pending_follows_the_number_of_zones_freed_not_which_zones() -> void:
	assert_eq(MemoryDefs.pending(0, 0), 0)
	assert_eq(MemoryDefs.pending(1, 0), 1)
	assert_eq(MemoryDefs.pending(1, 1), 0)
	assert_eq(MemoryDefs.pending(3, 1), 2)
	assert_eq(MemoryDefs.pending(4, 3), 4)
	assert_eq(MemoryDefs.pending(4, 4), 0)
	# Any order: freeing the last zone first still plays fragment 1 first.
	Session.set_flag(ZoneCompletion.flag_name("refusemancer"))
	assert_eq(Session.completed_zone_count(), 1)
	assert_eq(Session.pending_memory(), 1)


func test_every_text_key_exists() -> void:
	var story: StoryText = StoryText.shared()
	var missing: Array[String] = []
	for number: int in range(1, MemoryDefs.COUNT + 1):
		for part: String in ["title", "intro", "fragment", "after"]:
			if not story.texts.has(MemoryDefs.key(number, part)):
				missing.append(MemoryDefs.key(number, part))
	for key: String in ["memory.4.intro_known", "memory.4.after_known", "memory.4.reply", "memory.4.after2", "memory.1.announce_title", "memory.1.announce_body", "memory.title_format", "town.elder.known_early"]:
		if not story.texts.has(key):
			missing.append(key)
	for stage: int in range(0, MemoryDefs.COUNT + 1):
		if not story.texts.has("town.elder.stage.%d" % stage):
			missing.append("town.elder.stage.%d" % stage)
	assert_eq(missing, [] as Array[String])


func test_recovering_fragments_in_order_sets_flags_and_the_counter() -> void:
	Session.set_flag(ZoneCompletion.flag_name("beefcake"))
	Session.set_flag(ZoneCompletion.flag_name("gourmand"))
	Session.recover_memory(2)
	assert_eq(Session.memories_recovered(), 0, "fragment 2 cannot be skipped to")
	Session.recover_memory(1)
	assert_eq(Session.memories_recovered(), 1)
	assert_true(Session.flag(MemoryDefs.flag_name(1)))
	assert_eq(Session.pending_memory(), 2)
	Session.recover_memory(2)
	assert_eq(Session.pending_memory(), 0)
	assert_false(Session.flag(MemoryDefs.FLAG_REVEALED), "the name is not known yet")


func test_the_fourth_fragment_reveals_the_prince_and_renames_the_player() -> void:
	assert_eq(RoyalFamily.wanderer_name(), "Wanderer")
	assert_eq(NpcRegistry.find(NpcRegistry.PLAYER_ID).plate_name(), "The Wanderer")
	for zone_id: String in ZoneDefs.ids():
		Session.set_flag(ZoneCompletion.flag_name(zone_id))
	for number: int in range(1, 5):
		Session.recover_memory(number)
	assert_true(Session.flag(MemoryDefs.FLAG_REVEALED))
	assert_eq(RoyalFamily.wanderer_name(), RoyalFamily.data().prince_name)
	assert_eq(NpcRegistry.find(NpcRegistry.PLAYER_ID).plate_name(), RoyalFamily.data().prince_name)
	assert_eq(RoyalFamily.fill("Well met, {wanderer}!"), "Well met, %s!" % RoyalFamily.data().prince_name)


func test_an_early_reveal_by_primm_also_renames_the_player() -> void:
	Session.set_flag(MemoryDefs.FLAG_REVEALED)
	assert_eq(RoyalFamily.wanderer_name(), RoyalFamily.data().prince_name)


func test_the_fragments_quest_tracks_the_memories() -> void:
	var quest: QuestData = QuestCatalog.find(MemoryDefs.QUEST_ID)
	assert_not_null(quest)
	assert_eq(quest.objectives.size(), MemoryDefs.COUNT)
	assert_true(quest.auto_give)


func test_the_memory_state_survives_a_save_and_load() -> void:
	Session.set_flag(ZoneCompletion.flag_name("beefcake"))
	Session.recover_memory(1)
	var data: Dictionary = Session.to_dict()
	Session.new_game()
	assert_true(Session.from_dict(data))
	assert_eq(Session.memories_recovered(), 1)
	assert_true(Session.flag(MemoryDefs.flag_name(1)))
	assert_eq(Session.profile.zones_freed, 1)
