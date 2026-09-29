extends GutTest
## Fourth brief, Part F: the Graveyard boss's data - deck legality, life, the escalation modifier,
## AI and reward plumbing. Presentation (town placement/dialogue/battle flow) is not under GUT per
## CLAUDE.md - verified instead with a real-input smoke test, same as CorruptedNpcs
## (test_corrupted_npcs.gd).

var content: ContentSet


func before_each() -> void:
	content = ContentLibrary.load_all()


func test_deck_is_real_and_strictly_dark_colored() -> void:
	var setup: PlayerSetup = GraveyardBoss.enemy_setup(content)
	assert_false(setup.deck.cards.is_empty(), "should have a real deck")
	for card: CardData in setup.deck.cards:
		assert_eq(card.color, Affinity.Type.D, "the boss's deck should be strictly dark-colored (found %s)" % card.id)


func test_enemy_setup_starts_at_its_own_life_total() -> void:
	var setup: PlayerSetup = GraveyardBoss.enemy_setup(content)
	assert_eq(setup.starting_life, GraveyardBoss.STARTING_LIFE)
	assert_eq(setup.profile.max_life, GraveyardBoss.STARTING_LIFE)


func test_has_a_resolvable_ai_personality() -> void:
	assert_not_null(GraveyardBoss.personality(content))


func test_reward_equipment_resolves_to_a_real_advanced_piece() -> void:
	var piece: EquipmentData = GraveyardBoss.reward_equipment(content)
	assert_not_null(piece, "the reward equipment should resolve")
	assert_true(piece.advanced, "the notable reward should be an advanced piece, not a basic one")


func test_enemy_setup_carries_the_escalation_modifier_with_six_stages() -> void:
	var setup: PlayerSetup = GraveyardBoss.enemy_setup(content)
	var found: bool = false
	for modifier: Modifier in setup.modifiers.modifiers:
		if modifier.kind == Modifier.Kind.SCRIPTED_ESCALATING_SUMMON:
			found = true
			assert_eq(modifier.tokens.size(), 6, "should have exactly the 6 authored stages")
			assert_eq(int(modifier.tokens[0].power), 1)
			var last: CardData = modifier.tokens[5]
			var first: CardData = modifier.tokens[0]
			assert_true(int(last.power) + int(last.toughness) > int(first.power) + int(first.toughness), "the last stage should be the strongest (the cap)")
	assert_true(found, "the boss's setup should carry a SCRIPTED_ESCALATING_SUMMON modifier")


## The mechanic actually fires in a real duel: the boss's own turns summon escalating threats,
## proving GraveyardBoss.enemy_setup() and the generic engine hook (test_scripted_encounters.gd)
## actually connect end to end, not just in isolation.
func test_escalation_actually_fires_in_a_real_duel_against_the_boss() -> void:
	var game: GameState = GameState.new()
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Player"))
	game.add_player(GraveyardBoss.enemy_setup(content))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	if game.active == 0:
		GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_eq(game.players[1].battlefield.size(), 1, "the boss's first turn should summon Restless Bone")
	assert_eq(game.players[1].battlefield[0].data.display_name, "Restless Bone")
