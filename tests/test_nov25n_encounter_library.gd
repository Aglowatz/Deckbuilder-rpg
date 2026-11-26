extends CardTestBase
## Nov 25 night (Part G): the encounter library - curses that can be played around (banned card types, one card a turn, brittle troops),
## deck-building checks (a Path roll-call, the Specimen Trial), a boon NPC (the hedge-wizard's trap copy) and patrols that shred a card
## type for the run. Each says what it checks before the choice; run-only losses end with the run.


func _deck(units: int, path: Affinity.Type, others: int = 0) -> Deck:
	var deck: Deck = Deck.new()
	for index: int in range(units):
		deck.cards.append(GameFactory.vanilla(3 + (index % 3), 3, 2, path))
	for index: int in range(others):
		deck.cards.append(GameFactory.infra(path))
	return deck


func _run(deck: Deck) -> DungeonRun:
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), deck, [] as Array[ModifierSource])
	run.hp = 20
	return run


func _event(tokens: Array) -> DungeonEvent:
	var event: DungeonEvent = DungeonEvent.make("test")
	var outcomes: Array[DungeonEvent.Outcome] = []
	for token: Variant in tokens:
		outcomes.append(DungeonBuilder.event_outcome(str(token), null))
	return event.choice(outcomes)


func test_a_path_roll_call_rewards_enough_units_and_costs_hp_otherwise() -> void:
	var event: DungeonEvent = _event(["check_units:gourmand,6,5|Head Chef's Nod|atk=1"])
	assert_string_contains(event.choices[0].hint(), "6 or more Gourmand units")
	assert_string_contains(event.choices[0].hint(), "lose 5 HP")
	var cooks: DungeonRun = _run(_deck(7, Affinity.Type.GOURMAND))
	var passed: EventResolver.Result = EventResolver.resolve(event, 0, cooks, null, 0)
	assert_eq(passed.boons.size(), 1, "the chef nods")
	assert_eq(cooks.hp, 20)
	assert_false(passed.notes.is_empty(), "the panel says what it found")
	var lifters: DungeonRun = _run(_deck(7, Affinity.Type.BEEFCAKE))
	var failed: EventResolver.Result = EventResolver.resolve(event, 0, lifters, null, 0)
	assert_true(failed.boons.is_empty())
	assert_eq(lifters.hp, 15, "too few cooks: 5 HP")


func test_the_specimen_trial_reveals_a_unit_and_shreds_every_copy_of_a_weak_one_for_the_run() -> void:
	var event: DungeonEvent = _event(["reveal_unit:9|Passed the Trial|atk=1"])
	var deck: Deck = Deck.new()
	var weak: CardData = GameFactory.vanilla(2, 2)
	for index: int in range(3):
		deck.cards.append(weak)
	for index: int in range(20):
		deck.cards.append(GameFactory.infra(Affinity.Type.BEEFCAKE))
	var run: DungeonRun = _run(deck)
	var result: EventResolver.Result = EventResolver.resolve(event, 0, run, null, 0)
	assert_eq(result.lost_cards.size(), 3, "every copy of the revealed unit")
	assert_false(run.current_deck().cards.has(weak), "gone for this run")
	assert_eq(run.deck_after_run().cards.count(weak), 3, "and all back after the run (the save keeps the real deck)")
	var strong: DungeonRun = _run(_deck(4, Affinity.Type.BEEFCAKE))
	var passed: EventResolver.Result = EventResolver.resolve(_event(["reveal_unit:3|Passed|atk=1"]), 0, strong, null, 0)
	assert_eq(passed.boons.size(), 1, "attack 3 or more passes")


func test_a_patrol_shreds_a_card_type_for_the_run() -> void:
	var deck: Deck = _deck(4, Affinity.Type.NECROCRAT)
	var wonder: CardData = CardSet.card("R-10")
	deck.cards.append(wonder)
	deck.cards.append(wonder)
	var run: DungeonRun = _run(deck)
	var result: EventResolver.Result = EventResolver.resolve(_event(["shred_type:wonder"]), 0, run, null, 0)
	assert_eq(result.lost_cards.size(), 2)
	assert_eq(run.current_deck().cards.count(wonder), 0)
	assert_eq(run.deck_after_run().cards.count(wonder), 2, "back after the run")


func test_banned_types_and_the_wizards_trap_copy_in_a_fight() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.BANNED_CARD_TYPE, int(CardEnums.CardType.SPELL)))
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("B-39"))
	assert_false(game.can_play_card(0, spell.uid), "no spells under Silent Glass")
	var unit: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	assert_true(game.can_play_card(0, unit.uid), "units are fine")
	var wizard: GameState = _game()
	_energy(wizard)
	wizard.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.COPY_FIRST_TRAP, 1))
	_play(wizard, "B-19")
	assert_eq(wizard.players[0].traps.size(), 2, "the first Trap is set twice")
	_play(wizard, "R-14")
	assert_eq(wizard.players[0].traps.size(), 3, "only the first each turn")


func test_the_library_is_placed_postgame_first_then_in_the_zone_dungeons() -> void:
	var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json"))["dungeons"]
	var tokens: Array[String] = []
	var where: Dictionary = {}
	for key: String in content:
		if not content[key] is Dictionary:
			continue
		for room: Variant in ((content[key] as Dictionary).get("events", {}) as Dictionary):
			var event: Variant = (content[key]["events"] as Dictionary)[room]
			if not event is Dictionary:
				continue
			for choice: Variant in (event as Dictionary).get("choices", []) as Array:
				for token: Variant in (choice as Array).slice(2):
					tokens.append(str(token))
					where[str(token).get_slice(":", 0)] = int(where.get(str(token).get_slice(":", 0), 0)) + 1
	for kind: String in ["check_units", "reveal_unit", "shred_type"]:
		assert_gt(int(where.get(kind, 0)), 0, "%s is used" % kind)
	var joined: String = "\n".join(tokens)
	for needle: String in ["ban_spell=1", "ban_trap=1", "one_card=1", "def=-2", "trap_copy=1", "shred_type:wonder"]:
		assert_true(joined.contains(needle), "the library has %s" % needle)
	# every token parses into a real outcome
	for token: String in tokens:
		if token.begins_with("check_units") or token.begins_with("reveal_unit") or token.begins_with("shred_type"):
			assert_not_null(DungeonBuilder.event_outcome(token, null), token)


func test_curses_read_as_curses_and_say_what_they_do() -> void:
	var silent: ModifierSource = DungeonBuilder.boon_from("Silent Glass|ban_spell=1")
	assert_true(BoonText.is_curse(silent))
	assert_string_contains(BoonText.short(silent), "you may not play spells")
	var one: ModifierSource = DungeonBuilder.boon_from("One Thing at a Time|one_card=1,next=2")
	assert_true(BoonText.is_curse(one))
	assert_eq(one.fights_left, 2)
	var wizard: ModifierSource = DungeonBuilder.boon_from("The Wizard's Echo|trap_copy=1")
	assert_false(BoonText.is_curse(wizard))
	assert_string_contains(BoonText.short(wizard), "set twice")
