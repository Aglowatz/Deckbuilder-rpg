extends GutTest
## Rebalance Part B: the balance simulator - the catalog covers every fight, the expected player is built from the progression model,
## consumables are spent sensibly, and a quick run produces sane numbers.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func test_the_catalog_covers_every_kind_of_fight() -> void:
	var specs: Array[EncounterSpec] = EncounterCatalog.all(content)
	var ids: Dictionary = {}
	var groups: Dictionary = {}
	for spec: EncounterSpec in specs:
		assert_false(ids.has(spec.id), "unique id %s" % spec.id)
		ids[spec.id] = true
		groups[spec.group] = int(groups.get(spec.group, 0)) + 1
		assert_gt(spec.expected_level, 0, "%s has an expected level" % spec.id)
		assert_true(spec.enemy_builder.is_valid() or spec.mirror_player_deck or not spec.enemy_recipe.is_empty(), "%s has an enemy deck" % spec.id)
	assert_eq(int(groups.get("tutorial", 0)), 3, "the three tutorial fights")
	assert_eq(int(groups.get("town", 0)), 7, "4 corrupted NPCs + Graveyard + Shiro + the Vault")
	assert_gt(int(groups.get("zone:beefcake", 0)), 1)
	assert_gt(int(groups.get("zone:final", 0)), 2)
	assert_gt(int(groups.get("dungeon:D-HOG", 0)), 4, "every battle node of the House of Gains")
	assert_eq(int(groups.get("side:S-BEEF", 0)), 3, "a side dungeon's three fights")
	assert_gt(int(groups.get("postgame:D-LAB", 0)), 3)
	assert_gt(int(groups.get("arena", 0)), 2)
	var primm: int = 0
	for spec: EncounterSpec in specs:
		if spec.id.contains("phase"):
			primm += 1
	assert_eq(primm, 3, "Primm's three phases")


func test_every_catalog_enemy_builds_a_legal_seat() -> void:
	var player_deck: Deck = ProgressionModel.reference_deck(content, Affinity.Type.BEEFCAKE, 1)
	for spec: EncounterSpec in EncounterCatalog.all(content):
		var seat: PlayerSetup = spec.build_enemy(content, player_deck)
		assert_not_null(seat, spec.id)
		assert_gt(seat.deck.size(), 10, "%s has a real deck (%d cards)" % [spec.id, seat.deck.size()])
		assert_gt(seat.starting_hp, 0, "%s has HP" % spec.id)


func test_the_expected_player_grows_with_the_level() -> void:
	var low: Deck = ProgressionModel.reference_deck(content, Affinity.Type.REFUSEMANCER, 1)
	var mid: Deck = ProgressionModel.reference_deck(content, Affinity.Type.REFUSEMANCER, 10)
	var high: Deck = ProgressionModel.reference_deck(content, Affinity.Type.REFUSEMANCER, 22)
	assert_true(low.size() >= 42, "a starter-sized deck at level 1")
	assert_true(mid.size() >= DeckValidator.MIN_DECK_SIZE and mid.size() <= ProgressionModel.REFERENCE_DECK_SIZE + 3, "upgrades replace filler (%d cards)" % mid.size())
	assert_eq(high.count_of("R-33"), 1, "the Signature legendary by level 22")
	assert_gt(high.count_of("R-22") + high.count_of("R-28"), low.count_of("R-22") + low.count_of("R-28"))
	for path: Affinity.Type in Affinity.colored_types():
		for level: int in [1, 5, 10, 18, 26]:
			var deck: Deck = ProgressionModel.reference_deck(content, path, level)
			var copies: Dictionary = deck.copy_counts()
			for id: Variant in copies.keys():
				var card: CardData = content.card(str(id))
				if not card.is_infrastructure():
					assert_true(int(copies[id]) <= CopyCaps.ABSOLUTE_MAX, "%s x%d in %s L%d" % [str(id), int(copies[id]), Affinity.display_name(path), level])
	assert_eq(ProgressionModel.equipment_for(1).size(), 0, "no gear before the armory")
	assert_true(ProgressionModel.equipment_for(10).size() >= 4)
	assert_true(ProgressionModel.items_for(1).is_empty())
	assert_false(ProgressionModel.items_for(12).is_empty())
	var spec: EncounterSpec = EncounterCatalog.find(content, "zone:necrocrat:manager")
	var player: PlayerSpec = ProgressionModel.player_for(content, spec, Affinity.Type.GOURMAND)
	assert_eq(player.level, ProgressionModel.level_for("zone:necrocrat"))
	var profile: PlayerProfile = player.profile(content)
	assert_eq(profile.max_hp, ProgressionTable.row(player.level).max_hp)
	assert_eq(profile.equipment.size(), ProgressionModel.equipment_for(player.level).size(), "every gear id resolves to a piece")


func test_a_quick_run_produces_sane_numbers_and_card_impact() -> void:
	var spec: EncounterSpec = EncounterCatalog.find(content, "tutorial:2")
	var player: PlayerSpec = ProgressionModel.player_for(content, spec, Affinity.Type.BEEFCAKE)
	var result: BalanceSim.Result = BalanceSim.run(content, player, spec, 8, 123)
	assert_eq(result.games, 8)
	assert_eq(result.wins + result.draws + (result.games - result.wins - result.draws), 8)
	assert_eq(result.illegal_actions, 0)
	assert_gt(result.avg_player_turns(), 1.0)
	assert_true(result.win_rate() >= 0.0 and result.win_rate() <= 1.0)
	assert_gt(result.cards.size(), 0, "cards played were recorded")
	var same: BalanceSim.Result = BalanceSim.run(content, player, spec, 8, 123)
	assert_eq(same.wins, result.wins, "deterministic for a seed")
	var table: String = BalanceSim.table([{"all": result, "paths": {Affinity.Type.BEEFCAKE: result}}])
	assert_true(table.contains(spec.title), "the table names the encounter")


func test_consumables_are_spent_when_they_help() -> void:
	var game: GameState = GameFactory.blank_game(5)
	GameFactory.add_infrastructure_cards(game, 0, 3)
	var items: Dictionary = {"healing_salve": 1, "firebrand_charm": 1}
	var used: Dictionary = {}
	game.players[0].hp = 10
	assert_false(SimItemPolicy.act(game, 0, items, content, used), "no heal at full HP, no damage target")
	game.players[0].hp = 3
	assert_true(SimItemPolicy.act(game, 0, items, content, used), "heals when low")
	assert_eq(game.players[0].hp, 7)
	assert_eq(int(items["healing_salve"]), 0)
	var foe_unit: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(3, 2))
	assert_true(SimItemPolicy.act(game, 0, items, content, used), "burns a unit it can kill")
	assert_false(game.field_contains(foe_unit))
	assert_eq(int(items["firebrand_charm"]), 0)
	assert_false(SimItemPolicy.act(game, 0, items, content, used), "nothing left")


func test_a_sequence_carries_hp_between_fights() -> void:
	var specs: Array[EncounterSpec] = EncounterCatalog.tutorial()
	var player: PlayerSpec = PlayerSpec.make(ProgressionModel.reference_deck(content, Affinity.Type.NECROCRAT, 1), 1)
	var result: BalanceSim.SequenceResult = BalanceSim.run_sequence(content, player, specs, 3, 500, {2: true})
	assert_eq(result.runs, 3)
	assert_true(result.cleared >= 0 and result.cleared <= 3)
	var lost: int = 0
	for index: Variant in result.lost_at.keys():
		lost += int(result.lost_at[index])
	assert_eq(result.cleared + lost, 3, "every run either cleared or was lost at some fight")


func test_the_ai_can_be_told_not_to_use_resources() -> void:
	var game: GameState = GameFactory.blank_game(2)
	game.active = 0
	GameFactory.add_infrastructure_cards(game, 0, 2)
	GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 3))
	ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 2)
	var muted: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	muted.use_resources = false
	assert_ne(muted.choose_action(game).type, GameAction.Type.USE_RESOURCE)
	var normal: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	assert_eq(normal.choose_action(game).type, GameAction.Type.USE_RESOURCE)
