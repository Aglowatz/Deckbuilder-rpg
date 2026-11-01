extends GutTest
## Fable pass Nov 1, Part 7 (the yes-to-all list), the rules-side pieces: boss card picks offer at least 2 of 3 on-Path or Colorless, the
## Lab's -5 max life rides the run (the map HUD shows it) and is not added again per battle, arena first-clear prizes scale with the
## level, the Intake Corridor's foe has its own name.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_boss_pick_offers_two_of_three_on_path_or_colorless() -> void:
	var content: ContentSet = Session.content
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for path: Affinity.Type in Affinity.colored_types():
		for seed_value: int in range(40):
			rng.seed = 1000 + seed_value
			# The Test Kitchen's boss (Gourmand) seen by a hero of `path`: the encounter weight pulls toward Gourmand cards.
			var chosen: Array[CardData] = RewardPicks.choose(content, rng, [Affinity.Type.GOURMAND] as Array[Affinity.Type], path, 14, true, false)
			assert_eq(chosen.size(), 3)
			var fitting: int = 0
			for card: CardData in chosen:
				if RewardPicks.fits_own(card, path):
					fitting += 1
			assert_gte(fitting, 2, "%s seed %d: %s / %s / %s" % [Affinity.display_name(path), seed_value, chosen[0].id, chosen[1].id, chosen[2].id])
			assert_true(RewardPicks.fits_own(chosen[0], path) and RewardPicks.fits_own(chosen[1], path), "the first two slots fit (the third may be the chase card)")


func test_fits_own_means_on_path_or_colorless() -> void:
	var content: ContentSet = Session.content
	var beef: CardData = null
	var colorless: CardData = null
	var gourmand: CardData = null
	for id: Variant in content.cards.keys():
		var card: CardData = content.cards[id] as CardData
		if card == null or card.is_infrastructure():
			continue
		if beef == null and card.color == Affinity.Type.BEEFCAKE and not card.is_multipath():
			beef = card
		if colorless == null and card.color == Affinity.Type.NEUTRAL:
			colorless = card
		if gourmand == null and card.color == Affinity.Type.GOURMAND and not card.is_multipath():
			gourmand = card
	assert_true(RewardPicks.fits_own(beef, Affinity.Type.BEEFCAKE))
	assert_true(RewardPicks.fits_own(colorless, Affinity.Type.BEEFCAKE))
	assert_false(RewardPicks.fits_own(gourmand, Affinity.Type.BEEFCAKE))


func test_the_labs_specimen_conditions_ride_the_run_once() -> void:
	Session.unlock_postgame()
	var usual: int = Session.profile.max_hp
	Session.enter_lab()
	assert_not_null(Session.run)
	assert_eq(Session.run.max_hp(), usual - 5, "the map HUD's pool is 5 lower in the Lab")
	var battle_node: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE:
			battle_node = node
			break
	assert_not_null(battle_node)
	var context: BattleContext = Session.make_dungeon_battle(battle_node)
	assert_eq(context.game.players[0].max_hp, usual - 5, "a battle applies it once, not twice")
	assert_eq(context.game.players[0].modifiers.sum(Modifier.Kind.MAX_HP), -5)


func test_arena_first_clear_prizes_scale_with_the_level() -> void:
	var encounter: ArenaEncounter = ArenaDefs.in_tier(1)[0]
	var base: Dictionary = ArenaScenario.resolve_reward(encounter, Affinity.Type.BEEFCAKE)
	var same: Dictionary = ArenaScenario.resolve_reward(encounter, Affinity.Type.BEEFCAKE, ProgressionModel.level_for("arena:1"))
	assert_eq(int(same.get("gold", 0)), int(base.get("gold", 0)), "at the tier's level the printed prize")
	var late: Dictionary = ArenaScenario.resolve_reward(encounter, Affinity.Type.BEEFCAKE, 24)
	assert_gt(int(late.get("gold", 0)), int(base.get("gold", 0)) * 2, "a postgame player gets a postgame purse")
	assert_eq(int(late.get("gold", 0)) % 5, 0)
	assert_eq(ArenaScenario.prize_factor(1, 4), 1.0, "never below the printed prize")
	assert_eq(ArenaScenario.prize_factor(1, 0), 1.0)
	if base.has("xp"):
		assert_gt(int(late["xp"]), int(base["xp"]))


func test_the_intake_corridor_has_its_own_foe() -> void:
	var map: DungeonMap = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	var names: PackedStringArray = []
	for node: DungeonMap.MapNode in map.nodes:
		if node.title == "Intake Corridor":
			assert_eq(node.enemy_name, "Intake Orderly")
		names.append(node.enemy_name)
	assert_false(names.has("Decontamination Technician"), "the old name is gone")
	var bestiary: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/bestiary/bestiary.json")) as Dictionary
	var found: bool = false
	for entry: Variant in bestiary["entries"] as Array:
		if str((entry as Dictionary).get("name", "")) == "Intake Orderly":
			found = true
	assert_true(found, "the Bestiary follows")
