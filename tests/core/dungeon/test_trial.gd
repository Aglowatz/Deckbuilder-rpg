extends GutTest

var content: ContentSet


func before_each() -> void:
	content = ContentLibrary.load_all()


func test_map_shape_and_order() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var kinds: Array[DungeonMap.Kind] = []
	for node: DungeonMap.MapNode in map.nodes:
		kinds.append(node.kind)
	assert_eq(kinds.count(DungeonMap.Kind.BATTLE), 2)
	assert_eq(kinds.count(DungeonMap.Kind.CHALLENGE), 1)
	assert_eq(kinds.count(DungeonMap.Kind.SHRINE), 1)
	assert_eq(kinds.count(DungeonMap.Kind.BOSS), 1)
	assert_true(map.node(1).tutorial, "first battle is the tutorial")


func test_tutorial_encounters_have_low_life() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			assert_lt(node.enemy_life, PlayerProfile.START_MAX_LIFE, "%s should have low life" % node.title)


## Part D: non-boss opponents attack (an eager "aggressive but dumb" AI, not the old "Passive"
## that never attacked and made traps untestable); the boss uses a real (smarter) AI and can be a
## bit stronger, but still forgiving overall (see the simulation win-rate check below).
func test_non_boss_opponents_use_the_aggressive_dumb_ai_the_boss_does_not() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE:
			assert_eq(node.ai_name, "Aggressive (tutorial)", "%s should attack readily" % node.title)
		elif node.kind == DungeonMap.Kind.BOSS:
			assert_ne(node.ai_name, "Aggressive (tutorial)", "the boss should play smarter than the tutorial mooks")


## Part D: the two non-boss decks are vanilla-only - no removal, no card-draw/advantage - and
## include 1-cost creatures, same idea as the player's own starter.
func test_non_boss_decks_are_weak_and_vanilla_with_1_cost_creatures() -> void:
	var removal_or_draw_ops: Array[CardEnums.EffectOp] = [
		CardEnums.EffectOp.DESTROY, CardEnums.EffectOp.DRAW, CardEnums.EffectOp.DISCARD,
		CardEnums.EffectOp.RETURN_TO_HAND, CardEnums.EffectOp.MILL,
	]
	for enemy_name: String in ["Cave Scavenger", "Hollow Stalker"]:
		var deck: Deck = TrialOfTheHollow.enemy_deck(content, enemy_name)
		var one_cost_creatures: int = 0
		var seen: Dictionary = {}
		for card: CardData in deck.cards:
			if card.is_infrastructure() or seen.has(card.id):
				continue
			seen[card.id] = true
			for effect: EffectData in card.effects:
				assert_false(removal_or_draw_ops.has(effect.op), "%s: %s has removal/card-draw (%s)" % [enemy_name, card.id, effect.op])
			if card.is_creature():
				assert_lt(card.power + card.toughness, 8, "%s: %s should be a low-stat creature" % [enemy_name, card.id])
				if card.energy_value() == 1:
					one_cost_creatures += 1
		assert_gt(one_cost_creatures, 0, "%s should include 1-cost creatures" % enemy_name)


func test_shrine_before_the_boss_is_a_full_heal() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var shrine: DungeonMap.MapNode = null
	var boss: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.SHRINE:
			shrine = node
		elif node.kind == DungeonMap.Kind.BOSS:
			boss = node
	assert_true(shrine.next.has(boss.id), "the shrine leads straight into the boss")
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), Deck.new(), [] as Array[ModifierSource])
	run.lose_life(run.max_life() - 1)
	run.heal(shrine.heal_amount)
	assert_eq(run.life, run.max_life(), "the shrine heals all the way to max life")


func test_only_connected_nodes_are_available() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	assert_eq(map.available().size(), 1)
	assert_false(map.complete(3), "cannot skip ahead")
	assert_true(map.complete(1))
	assert_eq(map.current, 1)
	assert_false(map.complete(1), "cannot repeat a cleared node")
	assert_true(map.is_available(2))


func test_walking_the_whole_map_completes_it() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	assert_false(map.is_complete())
	while not map.available().is_empty():
		map.complete(map.available()[0].id)
	assert_true(map.is_complete())


func test_enemy_decks_resolve_all_cards() -> void:
	for enemy: String in ["Cave Scavenger", "Hollow Stalker", "Hollow Warden"]:
		var deck: Deck = TrialOfTheHollow.enemy_deck(content, enemy)
		var recipe_total: int = 0
		for count: Variant in TrialOfTheHollow.enemy_recipe(enemy).values():
			recipe_total += int(count)
		assert_eq(deck.size(), recipe_total, "%s has every recipe card" % enemy)
		assert_true(deck.infrastructure_count() >= 12, "%s has infrastructure" % enemy)


func test_deck_size_waiver_matches_the_starter_deck() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add_source(TrialOfTheHollow.deck_size_waiver())
	assert_eq(DeckValidator.min_deck_size(mods), TrialOfTheHollow.STARTER_DECK_SIZE)
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.B)
	assert_eq(deck.size(), TrialOfTheHollow.STARTER_DECK_SIZE)
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new(), mods))


func test_no_dungeon_wide_blessing_run_uses_plain_base_life() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(content, Affinity.Type.A)
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.A)
	var run: DungeonRun = DungeonRun.enter(profile, deck, [] as Array[ModifierSource])
	assert_eq(run.life, PlayerProfile.START_MAX_LIFE)
	assert_eq(run.max_life(), PlayerProfile.START_MAX_LIFE)


func test_enemy_setup_uses_node_life() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var setup: PlayerSetup = TrialOfTheHollow.enemy_setup(content, map.node(1))
	assert_eq(setup.starting_life, map.node(1).enemy_life)
	assert_lt(setup.starting_life, PlayerProfile.START_MAX_LIFE, "the tutorial's first enemy should be easier than the player")


## New brief (third), Part D: the secret tunnel skip grants exactly what the tutorial's own 2
## battles + boss would have paid (the challenge/shrine nodes pay neither).
func test_total_tutorial_rewards_sums_only_battle_and_boss_nodes() -> void:
	var totals: Dictionary = TrialOfTheHollow.total_tutorial_rewards()
	assert_eq(int(totals["xp"]), EncounterRewards.xp_for(DungeonMap.Difficulty.TUTORIAL) * 2 + EncounterRewards.xp_for(DungeonMap.Difficulty.BOSS))
	assert_eq(int(totals["gold"]), EncounterRewards.gold_for(DungeonMap.Difficulty.TUTORIAL) * 2 + EncounterRewards.gold_for(DungeonMap.Difficulty.BOSS))


func test_save_round_trip() -> void:
	var path: String = "user://test_save.json"
	assert_true(SaveSystem.write({"gold": 42, "owned": ["a", "b"]}, path))
	var data: Dictionary = SaveSystem.read(path)
	assert_eq(int(data["gold"]), 42)
	assert_eq((data["owned"] as Array).size(), 2)
	SaveSystem.delete(path)
	assert_true(SaveSystem.read(path).is_empty())
