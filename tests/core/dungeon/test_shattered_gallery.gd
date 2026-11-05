extends GutTest
## Overnight Nov 4-5, Part 5: The Shattered Gallery (S-GALLERY) - unlocked by Wren's postgame quest at the castle mirror, a 13-node graph in three
## wings, each Echo's twisted rule, the stacking wing rules, The Perfect Copy playing the run's own deck, and the first-clear rewards.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)


func test_the_quest_is_postgame_and_the_mirror_opens_the_gallery() -> void:
	var quest: QuestData = QuestCatalog.find(ShatteredGallery.QUEST_ID)
	assert_not_null(quest)
	assert_eq(quest.giver_npc, CapitalZone.NPC_WREN)
	assert_false(Condition.met(quest.prerequisite, Session.unlock_state()), "not before Primm falls")
	assert_false(Session.side_unlocked(ShatteredGallery.DUNGEON_ID))
	Session.unlock_postgame()
	assert_true(Condition.met(quest.prerequisite, Session.unlock_state()))
	Session.start_quest(ShatteredGallery.QUEST_ID, false)
	Session.set_flag(StringName(ShatteredGallery.FLAG_MIRROR_SEEN))
	Session.refresh_quests()
	assert_true(Session.quest_log.is_completed(ShatteredGallery.QUEST_ID), "looking into the mirror finishes it (no hand-in)")
	assert_true(Session.side_unlocked(ShatteredGallery.DUNGEON_ID), "and opens the glass")


func test_the_node_graph_has_three_wings_and_the_mirror_room() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(ShatteredGallery.DUNGEON_ID)
	assert_not_null(plan)
	assert_true(plan.is_postgame())
	var map: DungeonMap = MainDungeons.build_map(ShatteredGallery.DUNGEON_ID)
	assert_eq(map.problems(), [] as Array[String], "a sound node map")
	assert_between(map.nodes.size(), 12, 14, "about 12-14 nodes")
	var kinds: Dictionary = {}
	for node: DungeonMap.MapNode in map.nodes:
		kinds[node.kind] = int(kinds.get(node.kind, 0)) + 1
		assert_ne(node.kind, DungeonMap.Kind.SHRINE, "no free rest node (the only rest is the costly Quiet Frame event)")
	assert_eq(int(kinds.get(DungeonMap.Kind.BOSS, 0)), 1)
	assert_eq(map.boss().enemy_name, ShatteredGallery.BOSS_NAME)
	assert_gte(int(kinds.get(DungeonMap.Kind.EVENT, 0)), 3, "harsh choices along the way")


func test_every_echo_has_a_twisted_rule_and_its_original_picture() -> void:
	var map: DungeonMap = MainDungeons.build_map(ShatteredGallery.DUNGEON_ID)
	var echoes: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if not node.enemy_name.begins_with(ShatteredGallery.ECHO_PREFIX):
			continue
		echoes += 1
		assert_true(ShatteredGallery.is_mirror_foe(node.enemy_name))
		assert_gt(EncounterModifiers.rules(node.enemy_name).size(), 0, "%s has its own rule" % node.enemy_name)
		assert_ne(ShatteredGallery.original_of(node.enemy_name), node.enemy_name, "the picture is its original's")
	assert_eq(echoes, 7)
	assert_eq(EncounterModifiers.problems(), [] as Array[String], "every rule parses")


func test_the_mirror_rules_stack_wing_by_wing() -> void:
	var names: Callable = func(node_number: int) -> Array[String]:
		var found: Array[String] = []
		for badge: RuleBadges.Badge in RuleBadges.for_dungeon(ShatteredGallery.DUNGEON_ID, node_number):
			found.append(badge.name)
		return found
	assert_eq(names.call(2), ["Silvered"] as Array[String], "the Iron wing")
	assert_eq(names.call(5), ["Silvered", "Reflected Order"] as Array[String], "the Order wing adds one")
	assert_eq(names.call(11), ["Silvered", "Reflected Order", "Perfect Form"] as Array[String], "all three in the Appetite wing")
	assert_eq(names.call(13), ["Silvered", "Reflected Order"] as Array[String], "the mirror room keeps two (the Copy has its own extra draw)")


func test_perfect_form_copies_the_first_unit_each_turn_for_the_enemy() -> void:
	var rule: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Perfect Form", "text": "copied", "kind": "mirror_first_unit", "side": "player"})
	var game: GameState = GameFactory.new_game(3)
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "test"
	source.modifiers = rule.modifiers
	game.players[0].modifiers.add_source(source)
	GameFactory.add_infrastructure_cards(game, 0, 3)
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	var before: int = game.players[1].field.size()
	assert_true(game.play_card(0, first.uid))
	assert_eq(game.players[1].field.size(), before + 1, "the first unit is copied onto the enemy's field")
	assert_true(game.play_card(0, second.uid))
	assert_eq(game.players[1].field.size(), before + 1, "only the first one each turn")


func test_the_perfect_copy_plays_the_runs_own_deck() -> void:
	var deck: Deck = Deck.new()
	for card: CardData in Session.deck.cards.slice(0, 20):
		deck.cards.append(card)
	var setup: PlayerSetup = ShatteredGallery.perfect_copy_setup(deck, 30)
	assert_eq(setup.deck.cards.size(), 20, "an exact copy")
	assert_eq(setup.deck.cards[0], deck.cards[0])
	assert_eq(setup.starting_hp, 30 + ShatteredGallery.PERFECT_COPY_HP_BONUS, "more HP than you")
	assert_true(setup.modifiers.has(Modifier.Kind.EXTRA_DRAWS), "one extra card each turn")
	deck.cards.pop_back()
	assert_eq(setup.deck.cards.size(), 20, "a copy, not the same list")


func test_the_perfect_copy_seat_in_a_real_run_mirrors_lost_cards() -> void:
	Session.unlock_postgame()
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = ShatteredGallery.DUNGEON_ID
	Session.dungeon_map = MainDungeons.build_map(ShatteredGallery.DUNGEON_ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.mini_active = true
	var lost: CardData = Session.run.current_deck().cards[0]
	Session.run.lost_cards.append(lost)
	var context: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.boss())
	var enemy: PlayerState = context.game.players[1]
	assert_eq(enemy.deck.size() + enemy.hand.size(), Session.run.current_deck().size(), "the copy is the run's deck as it is now")
	assert_eq(enemy.hp, Session.run.max_hp() + ShatteredGallery.PERFECT_COPY_HP_BONUS, "it starts with more HP than your max")


func test_the_first_clear_pays_gold_essence_and_the_mirrored_finish() -> void:
	Session.unlock_postgame()
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = ShatteredGallery.DUNGEON_ID
	Session.dungeon_map = MainDungeons.build_map(ShatteredGallery.DUNGEON_ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.mini_active = true
	Session.gold = 0
	Session.profile.set_essence(Affinity.Type.BEEFCAKE, 0)
	var result: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(result.get("first_clear", false)))
	assert_gte(Session.gold, ShatteredGallery.FIRST_CLEAR_GOLD)
	assert_eq(Session.profile.essence_of(Affinity.Type.BEEFCAKE), ShatteredGallery.FIRST_CLEAR_ESSENCE)
	assert_true(Session.cosmetics.mirrored_unlocked, "the Mirrored finish")
	assert_not_null(FeatDefs.find(ShatteredGallery.FEAT_ID), "a feat for it")
	# a repeat clear pays the small repeat gold and a Prismatic Pack, not the first prize again
	Session.dungeon_key = ShatteredGallery.DUNGEON_ID
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.mini_active = true
	var again: Dictionary = Session.resolve_mini_dungeon(true)
	assert_false(bool(again.get("first_clear", false)))
	assert_true(again.has("packs"), "a Prismatic Pack")


func test_the_mirrored_finish_is_per_card_and_saved() -> void:
	var state: CosmeticState = CosmeticState.new()
	assert_false(state.set_mirrored("B-01", true), "locked until the Gallery is cleared")
	state.mirrored_unlocked = true
	assert_true(state.set_mirrored("B-01", true))
	assert_true(state.is_mirrored("B-01"))
	assert_false(state.is_mirrored("B-02"))
	var copy: CosmeticState = state.duplicate_state()
	assert_true(copy.is_mirrored("B-01"), "saved and loaded")
	state.set_mirrored("B-01", false)
	assert_false(state.is_mirrored("B-01"))


func test_the_gallery_has_a_stand_in_map_and_board_and_music() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(ShatteredGallery.DUNGEON_ID)
	assert_true(MapArt.STANDIN_MAPS.has(plan.map_id), "the castle map until MAP-S-GALLERY arrives")
	assert_true(Battleboards.STANDIN_BOARDS.has(plan.battleboard_id))
	assert_true(MusicDirector.DUNGEONS.has(ShatteredGallery.DUNGEON_ID))
