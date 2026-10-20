extends GutTest
## Playtest v0.4.0 Part D: the armory quest asks for "one fight (any fight)" - every kind of victory bumps the `duels_won` counter:
## Crosspath outskirts roamers, zone roamers, the four gatekeepers (which never counted before), the town bosses, dungeon battles and
## the arena. The Form 7-B / witnessed-duel wording is gone.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _won(context: BattleContext) -> BattleContext:
	context.won = true
	return context


func test_a_gatekeeper_win_counts() -> void:
	for id: String in CorruptedNpcs.IDS:
		var before: int = Session.counter("duels_won")
		Session.record_victory(_won(Session.make_npc_challenge_battle(id)))
		assert_eq(Session.counter("duels_won"), before + 1, "beating %s is a won fight" % id)


func test_the_town_bosses_and_the_arena_count() -> void:
	Session.record_victory(_won(Session.make_graveyard_battle()))
	assert_eq(Session.counter("duels_won"), 1, "the Restless Cairn")
	Session.record_victory(_won(Session.make_ninja_battle()))
	assert_eq(Session.counter("duels_won"), 2, "Shiro Swindle")
	Session.record_victory(_won(Session.make_vault_battle()))
	assert_eq(Session.counter("duels_won"), 3, "the Vault Guardian")
	var arena: ArenaEncounter = ArenaDefs.all()[0]
	Session.record_victory(_won(Session.make_arena_battle(arena.id)))
	assert_eq(Session.counter("duels_won"), 4, "the arena")


func test_a_loss_never_counts() -> void:
	var context: BattleContext = Session.make_npc_challenge_battle(CorruptedNpcs.IDS[0])
	context.won = false
	if context.won:
		Session.record_victory(context)
	assert_eq(Session.counter("duels_won"), 0)


func test_an_outskirts_roamer_and_a_zone_roamer_count() -> void:
	Session.resolve_town_battle(_won(Session.make_town_battle(TownEnemies.RACCOON, "town_raccoon")))
	assert_eq(Session.counter("duels_won"), 1, "a Crosspath outskirts roamer")
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	Session.resolve_zone_battle(_won(Session.make_zone_battle(GainlandsEnemies.BRUTE, "brute_0")))
	assert_eq(Session.counter("duels_won"), 2, "a zone roamer")


func test_a_dungeon_battle_counts_through_its_rewards() -> void:
	var offer: RewardOffer = RewardOffer.new()
	offer.gold = 5
	Session.pending_reward = offer
	Session.apply_rewards()
	assert_eq(Session.counter("duels_won"), 1, "a dungeon battle's reward step counts the win")


func test_the_quest_completes_on_any_single_win() -> void:
	Session.add_xp(ProgressionTable.xp_to_reach(5) - Session.profile.xp)
	Session.quest_log.completed.append(QuestDefinitions.GHOSTS)  # Oct 20: Maren sends the hero after the store room
	assert_true(Session.start_quest(QuestDefinitions.ARMORY))
	assert_true(Session.quest_log.is_active(QuestDefinitions.ARMORY))
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.ARMORY)
	for objective: QuestObjective in quest.objectives:
		assert_false(objective.text.contains("7-B"), "no Form 7-B: %s" % objective.text)
		assert_false(objective.text.to_lower().contains("witness"))
	assert_eq(quest.objectives[1].text, "Win one fight (any fight)")
	assert_eq(Session.armory_talk(), 1, "report first")
	Session.record_victory(_won(Session.make_npc_challenge_battle(CorruptedNpcs.IDS[1])))
	Session.refresh_quests()
	assert_eq(Session.armory_stage(), 3, "one gatekeeper win is enough")
	for key: String in ["quest.armory.start", "quest.armory.waiting", "quest.armory.done"]:
		for line: String in StoryText.shared().get_lines(key):
			assert_false(line.contains("7-B") or line.to_lower().contains("witness"), "%s: %s" % [key, line])


## Oct 20, Part 4: level 5 no longer points at Bertram (Maren sends the hero to him after the store room).
func test_the_level_five_notice_no_longer_points_at_bertram() -> void:
	var row: LevelData = ProgressionTable.row(5)
	var lines: Array[String] = ProgressionTable.reward_lines(row, ProgressionTable.row(4), Affinity.Type.BEEFCAKE)
	for line: String in lines:
		assert_false(line.to_lower().contains("equipment slot"), "the level-5 notice never mentions equipment slots: %s" % line)
		assert_false(line.contains("Bertram Beetsworth"), "nor Bertram: %s" % line)
