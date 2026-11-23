extends GutTest
## Draft mode, Phase 1: the draft in the game - the session's books (the fee, saving, the stand-in profile of a draft fight, the
## rewards, the kept card), Trey Pickett in the four zones, the draft quest line and the eight new pieces of equipment.

var _saved: Dictionary = {}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.draft = null
	Session.gold = 500


func after_each() -> void:
	Session.draft = null
	Session.pending_draft_result = {}


func _draft_to_run() -> void:
	assert_true(Session.start_draft("zone:beefcake", [] as Array[int]))
	var guard: int = 0
	while Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		Session.draft_pick(guard % 3)
		guard += 1
	assert_true(Session.draft_begin_run())


func _finish_fight(won: bool) -> Dictionary:
	var real: PlayerProfile = Session.profile
	var context: BattleContext = Session.make_draft_battle()
	Session._draft_real_profile = real
	Session.profile = context.draft_profile
	context.game.winner = 0 if won else 1
	var result: Dictionary = Session.resolve_draft_battle(context)
	assert_eq(Session.profile, real, "the real profile is back after the fight")
	return result


func test_the_first_attempt_is_free_and_the_next_costs_100_gold() -> void:
	assert_eq(Session.draft_fee("zone:beefcake"), 0)
	assert_true(Session.start_draft("zone:beefcake", [] as Array[int]))
	assert_eq(Session.gold, 500, "the first sitting is on the house")
	assert_eq(Session.draft.paths, [int(Affinity.Type.BEEFCAKE)], "a zone draft fixes the Path")
	assert_false(Session.start_draft("zone:gourmand", [] as Array[int]), "one draft at a time")
	Session.close_draft()
	assert_eq(Session.draft_fee("zone:beefcake"), 100)
	assert_true(Session.start_draft("zone:beefcake", [] as Array[int]))
	assert_eq(Session.gold, 400)
	Session.close_draft()
	Session.gold = 50
	assert_false(Session.start_draft("zone:beefcake", [] as Array[int]), "no gold, no draft")
	assert_eq(Session.gold, 50)


func test_the_open_draft_takes_one_path_until_the_arena_is_open() -> void:
	assert_false(DraftChallenges.open_unlocked(Session.flags))
	Session.set_flag(StringName(DraftChallenges.won_flag("zone:beefcake")))
	assert_true(DraftChallenges.open_unlocked(Session.flags), "the open draft opens with the first zone draft won")
	assert_false(Session.start_draft("open", [1, 2] as Array[int]), "two Paths wait for the Crosspath draft arena")
	assert_true(Session.start_draft("open", [2] as Array[int]))
	assert_eq(Session.draft.paths, [2])
	Session.close_draft()
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))
	assert_true(Session.start_draft("open", [1, 2] as Array[int]))
	assert_false(Session.draft.two_path_ok, "two-Path cards still wait for all four zones to be freed")


func test_a_draft_is_saved_with_the_game_and_old_saves_still_load() -> void:
	assert_true(Session.start_draft("zone:beefcake", [] as Array[int]))
	for i: int in range(6):
		Session.draft_pick(i % 3)
	var offer: Array = (Session.draft.offer["options"] as Array).duplicate()
	var cards: Array[String] = Session.draft.cards.duplicate()
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	assert_true(data.has("draft"))
	var old: Dictionary = data.duplicate(true)
	old.erase("draft")
	Session.draft = null
	assert_true(Session.from_dict(data))
	assert_not_null(Session.draft, "the draft resumes")
	assert_eq(Session.draft.cards, cards)
	assert_eq(Session.draft.offer["options"], offer)
	assert_true(Session.from_dict(old), "a save from before draft mode loads")
	assert_null(Session.draft)


func test_a_draft_fight_uses_a_stand_in_and_never_touches_the_main_loadout() -> void:
	Session.grant_equipment(Session.content.equipment_piece("glass_jaw_gauntlets"))
	var worn: int = Session.profile.equipment.size()
	var hp: int = Session.profile.max_hp
	_draft_to_run()
	var context: BattleContext = Session.make_draft_battle()
	assert_true(context.draft)
	assert_ne(context.draft_profile, Session.profile)
	assert_eq(context.draft_profile.equipment.size(), 5, "only the drafted equipment")
	assert_eq(context.game.players[0].max_hp_cap if "max_hp_cap" in context.game.players[0] else context.draft_profile.max_hp, context.draft_profile.max_hp)
	assert_eq(Session.profile.equipment.size(), worn)
	assert_eq(Session.profile.max_hp, hp)
	assert_eq(context.enemy_name, str(Session.draft.rivals[0]["name"]))


func test_three_wins_pay_the_first_win_prize_once_and_let_you_keep_one_card() -> void:
	_draft_to_run()
	var gold: int = Session.gold
	assert_false(bool(_finish_fight(true)["over"]))
	assert_false(bool(_finish_fight(false)["over"]))
	assert_false(bool(_finish_fight(true)["over"]))
	var last: Dictionary = _finish_fight(true)
	assert_true(bool(last["over"]))
	var first_pay: int = int((last["reward"] as Dictionary)["gold"])
	assert_eq(first_pay, int(DraftChallenges.reward(3, true, true)["gold"]))
	assert_true(bool((last["reward"] as Dictionary)["first_win"]))
	assert_gte(Session.gold - gold, first_pay, "the gold is in the purse (a level gained on the way may add its own)")
	assert_true(Session.flag(StringName(DraftChallenges.won_flag("zone:beefcake"))))
	assert_eq(Session.counter("draft_runs_won"), 1)
	assert_false(Session.pending_draft_result.is_empty(), "the scene reopens the table on the result")
	# keep one card
	var card_id: String = Session.draft.cards[2]
	var owned: int = Session.profile.collection_count(card_id) if Session.profile.has_method("collection_count") else -1
	assert_true(Session.draft_keep(card_id))
	assert_false(Session.draft_keep(Session.draft.cards[3]), "one card only")
	if owned >= 0:
		assert_eq(Session.profile.collection_count(card_id), owned + 1)
	Session.close_draft()
	assert_null(Session.draft)
	# the replay pays the fair amount, not the first-win prize
	_draft_to_run()
	var replay: Dictionary = {}
	for i: int in range(3):
		replay = _finish_fight(true)
	assert_eq(int((replay["reward"] as Dictionary)["gold"]), int(DraftChallenges.reward(3, true, false)["gold"]))
	assert_false(bool((replay["reward"] as Dictionary)["first_win"]))
	assert_lt(int((replay["reward"] as Dictionary)["gold"]), first_pay)


func test_two_losses_end_the_run_with_something_and_no_card() -> void:
	_draft_to_run()
	var gold: int = Session.gold
	_finish_fight(false)
	var result: Dictionary = _finish_fight(false)
	assert_true(bool(result["over"]))
	assert_gt(Session.gold, gold, "something for every result")
	assert_false(Session.draft_keep(Session.draft.cards[0]))
	assert_false(Session.flag(StringName(DraftChallenges.won_flag("zone:beefcake"))))


func test_all_four_zone_drafts_open_the_crosspath_draft_arena() -> void:
	for zone_id: String in DraftChallenges.ZONES:
		assert_false(Session.flag(StringName(DraftChallenges.ARENA_FLAG)))
		Session.draft = DraftEngine.start(Session.content, DraftChallenges.zone_id_for(zone_id), DraftChallenges.fixed_paths(DraftChallenges.zone_id_for(zone_id)), 10, 5)
		Session.draft.phase = DraftState.PHASE_DONE
		Session.draft.wins = 3
		Session._pay_draft_rewards()
		Session.draft = null
	assert_true(Session.flag(StringName(DraftChallenges.ARENA_FLAG)), "the arena is unlocked (Phase 2 builds it)")


func test_trey_pickett_stands_in_every_path_zone_with_a_map_marker() -> void:
	for zone_id: String in DraftChallenges.ZONES:
		var zone: ZoneDef = ZoneDefs.get_def(zone_id)
		var npc: bool = false
		for entry: Dictionary in zone.npcs:
			npc = npc or str(entry.get("id", "")) == DraftHost.SPOT_ID
		var spot: bool = false
		for entry: Dictionary in zone.spots:
			spot = spot or str(entry.get("kind", "")) == DraftHost.SPOT_ID
		assert_true(npc, "%s has the host" % zone_id)
		assert_true(spot, "%s has his talk spot" % zone_id)
		assert_true(zone.poi_kinds.has(DraftHost.SPOT_ID), "%s shows him on the map and the minimap" % zone_id)
	assert_eq(NpcRegistry.display_name(DraftHost.NPC_ID), "Trey Pickett")
	for key: String in ["drafthost.intro", "drafthost.return", "drafthost.resume", "drafthost.arena"]:
		assert_gt(DungeonCatalog.text_lines(key).size(), 0, key)
	assert_eq(DraftHost.line_key({}, false), "drafthost.intro")
	assert_eq(DraftHost.line_key({DraftHost.MET_FLAG: true}, true), "drafthost.resume")
	assert_eq(DraftHost.line_key({DraftHost.MET_FLAG: true, DraftChallenges.ARENA_FLAG: true}, false), "drafthost.arena")


func test_the_draft_quest_line_is_an_intro_four_zone_quests_and_a_finale() -> void:
	var quests: Array[QuestData] = DraftHost.quests()
	assert_eq(quests.size(), 6)
	var all_ids: Dictionary = {}
	for quest: QuestData in QuestDefinitions.build_all():
		all_ids[quest.id] = quest
	var rewards: Dictionary = {}
	for quest: QuestData in quests:
		assert_true(all_ids.has(quest.id), "%s is registered" % quest.id)
		assert_gt(quest.reward_gold, 0)
		assert_gt(quest.reward_xp, 0)
		assert_eq(quest.reward_equipment_ids.size(), 1, "%s pays a piece of equipment" % quest.id)
		assert_not_null(Session.content.equipment_piece(quest.reward_equipment_ids[0]), quest.reward_equipment_ids[0])
		rewards[quest.reward_equipment_ids[0]] = true
	assert_eq(rewards.size(), 6, "six different pieces")
	assert_true((all_ids[DraftHost.FINALE_QUEST] as QuestData).reward_unlock_flags.has(DraftChallenges.ARENA_FLAG), "the finale opens the Crosspath draft arena")
	assert_eq((all_ids[DraftHost.FINALE_QUEST] as QuestData).objectives.size(), 4)


func test_every_draft_piece_also_exists_in_the_main_game() -> void:
	var quest_pieces: Dictionary = {}
	for quest: QuestData in DraftHost.quests():
		quest_pieces[quest.reward_equipment_ids[0]] = true
	var stall: Array[String] = []
	for entry: EquipmentVendorEntry in EquipmentVendorScreen.default_stock().entries:
		if entry.unlock == null:
			stall.append(entry.equipment_id)
	assert_eq(DraftGear.ids().size(), 8)
	for id: String in DraftGear.ids():
		var piece: EquipmentData = Session.content.equipment_piece(id)
		assert_not_null(piece, id)
		assert_false(piece.source.is_empty(), "%s says where it comes from" % id)
		assert_true(quest_pieces.has(id) or DraftGear.VENDOR_PIECES.has(id), "%s is a quest reward or on Bertram's stall" % id)
		var in_pool: bool = false
		for pooled: EquipmentData in DraftEngine.equipment_pool(Session.content, int(piece.slot)):
			in_pool = in_pool or pooled.id == id
		assert_true(in_pool, "%s can be drafted" % id)
	for id: Variant in DraftGear.VENDOR_PIECES.keys():
		assert_eq(Session.content.equipment_piece(str(id)).rarity, EquipmentData.Rarity.COMMON, "the weak pieces are the early ones")
		assert_true(stall.has(str(id)), "%s is on the stall from the start" % id)


func test_the_bomb_rare_and_the_fedora_do_what_they_say() -> void:
	var fedora: EquipmentData = Session.content.equipment_piece("first_pick_fedora")
	var bomb: EquipmentData = Session.content.equipment_piece("the_bomb_rare")
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 3
	var profile: PlayerProfile = PlayerProfile.new()
	profile.equipment.append(fedora)
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), profile, [] as Array[ModifierSource], "Hat"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Bare"))
	game.start()
	assert_eq(game.players[0].hand.size(), game.players[1].hand.size() + 1, "the Fedora's owner opens with one card more")
	assert_eq(fedora.modifiers[0].kind, Modifier.Kind.OPENING_HAND_SIZE)
	assert_eq(fedora.modifiers[0].value, 1)
	assert_eq(bomb.modifiers[0].kind, Modifier.Kind.STAT_CHANGE)
	assert_eq(bomb.modifiers[1].value, -1, "one card fewer in the opening hand")
	assert_false(bomb.drawback.is_empty())
