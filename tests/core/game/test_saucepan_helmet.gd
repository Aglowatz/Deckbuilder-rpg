extends CardTestBase
## Overnight Nov 3-4, Part A3: the Saucepan Helmet - "Max HP +1, and heal 1 HP at the start of every duel." Both effects work: max HP
## +1 while equipped, and a 1 HP heal when a duel starts that never goes above max HP (it matters with carried HP).


func _helmet() -> EquipmentData:
	return ProgressionContent.zone_equipment()["saucepan_helmet"] as EquipmentData


func _duel(gear: Array[ModifierSource], starting_hp: int = -1) -> GameState:
	CardSet.load_all()
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), PlayerProfile.new(), gear, "Player")
	setup.starting_hp = starting_hp
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	game.options.free_mulligan = false
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	return game


func test_description() -> void:
	assert_eq(_helmet().description, "Max HP +1, and heal 1 HP at the start of every duel.")


func test_max_hp_plus_one_while_equipped() -> void:
	var bare: GameState = _duel([] as Array[ModifierSource])
	var worn: GameState = _duel([_helmet()] as Array[ModifierSource])
	assert_eq(worn.players[0].max_hp, bare.players[0].max_hp + 1)
	assert_eq(worn.players[0].hp, worn.players[0].max_hp, "a fresh duel starts at full, never above max")


func test_heals_one_at_the_start_of_a_duel_with_carried_hp() -> void:
	var bare: GameState = _duel([] as Array[ModifierSource])
	var max_hp: int = bare.players[0].max_hp + 1
	var worn: GameState = _duel([_helmet()] as Array[ModifierSource], max_hp - 4)
	assert_eq(worn.players[0].hp, max_hp - 3, "carried HP + 1")


func test_the_heal_stops_at_max_hp() -> void:
	var bare: GameState = _duel([] as Array[ModifierSource])
	var max_hp: int = bare.players[0].max_hp + 1
	var worn: GameState = _duel([_helmet()] as Array[ModifierSource], max_hp)
	assert_eq(worn.players[0].hp, max_hp)


func test_no_starting_hp_bonus_left() -> void:
	for modifier: Modifier in _helmet().modifiers:
		assert_ne(modifier.kind, Modifier.Kind.STARTING_HP, "the old over-max starting HP is gone")
