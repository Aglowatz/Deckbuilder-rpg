extends GutTest
## Fable Nov 21 (Part 4): no full heals in the four main-zone dungeons. Each heal room is a choice room: heal 5 HP for a cost (gold, a
## random card out of the deck for the run, or a drawback in the next fight) or do nothing. The new drawbacks, one test each: the first
## unit you play has -2 attack, you skip your first card draw, the first card you play each turn costs 1 more, your first
## Infrastructure enters exhausted, the enemy starts with one more card, the enemy's first unit gets +1/+1. Also the "lose:1" cost,
## which two choices had written but which was never read.

const MAIN: Dictionary = {"beefcake": ["D-HOG", "10"], "gourmand": ["D-TTK", "9"], "necrocrat": ["D-HFA", "10"], "refusemancer": ["D-ROT", "9"]}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	CardSet.load_all()


func _room(zone: String) -> DungeonEvent:
	var ids: Array = MAIN[zone] as Array
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(str(ids[0]))
	return MainDungeons.def(zone).event(DungeonBuilder.event_id_of(plan, int(ids[1])))


func _game_with(spec: String, first_player: int = 0) -> GameState:
	var source: ModifierSource = DungeonBuilder.boon_from(spec)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 11
	options.first_player = first_player
	options.free_mulligan = false
	var game: GameState = GameState.new(options)
	var mine: Array[ModifierSource] = []
	var theirs: Array[ModifierSource] = []
	if source.for_enemy:
		theirs.append(source)
	else:
		mine.append(source)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, mine, "You"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, theirs, "Foe"))
	game.start()
	return game


# ---- 4.1 and 4.2: the heal rooms ------------------------------------------------------------------------------------------------------


func test_no_main_zone_dungeon_has_a_full_heal_room() -> void:
	for zone: Variant in MAIN.keys():
		var map: DungeonMap = MainDungeons.build_map(str(zone))
		var events: int = 0
		for node: DungeonMap.MapNode in map.nodes:
			assert_ne(node.kind, DungeonMap.Kind.SHRINE, "%s: %s is no longer a heal room" % [zone, node.title])
			assert_lt(node.heal_amount, 100, "%s: %s heals in full" % [zone, node.title])
			if node.kind == DungeonMap.Kind.EVENT:
				events += 1
		assert_gte(events, 2, "%s: its choice rooms" % zone)


func test_each_heal_room_offers_heal_5_for_a_cost_or_nothing() -> void:
	for zone: Variant in MAIN.keys():
		var event: DungeonEvent = _room(str(zone))
		assert_not_null(event, str(zone))
		if event == null:
			continue
		var heals: int = 0
		var nothings: int = 0
		for choice: DungeonEvent.Choice in event.choices:
			var heal: int = 0
			var cost: bool = false
			for outcome: DungeonEvent.Outcome in choice.outcomes:
				match outcome.kind:
					DungeonEvent.OutcomeKind.HEAL:
						heal += outcome.amount
					DungeonEvent.OutcomeKind.PAY_GOLD, DungeonEvent.OutcomeKind.LOSE_CARD, DungeonEvent.OutcomeKind.DAMAGE:
						cost = true
					DungeonEvent.OutcomeKind.BOON:
						assert_true(BoonText.is_curse(outcome.boon), "%s: '%s' is a drawback" % [zone, outcome.boon.source_name])
						assert_eq(outcome.boon.fights_left, 1, "%s: '%s' lasts the next fight" % [zone, outcome.boon.source_name])
						cost = true
			if heal > 0:
				heals += 1
				assert_eq(heal, 5, "%s: a heal of exactly 5" % zone)
				assert_true(cost, "%s: every heal has a cost (no purely good option)" % zone)
			else:
				nothings += 1
				assert_false(cost, "%s: doing nothing costs nothing" % zone)
		assert_gte(heals, 1, "%s: at least one 'heal 5 for a cost'" % zone)
		assert_eq(nothings, 1, "%s: one 'do nothing'" % zone)


func test_the_costs_get_harsher_from_dungeon_to_dungeon() -> void:
	# the designed order of the zones: the Gainlands, the Buffet, the D.N.A., the Dump
	var gold: Array[int] = []
	for zone: String in ["beefcake", "gourmand", "refusemancer"]:
		gold.append(_room(zone).choices[0].gold_cost())
	assert_eq(gold, [30, 40, 50] as Array[int], "the gold price of a heal rises")
	var filed: DungeonEvent.Choice = _room("necrocrat").choices[0]
	assert_eq(filed.outcomes[1].kind, DungeonEvent.OutcomeKind.LOSE_CARD, "the Hall of Final Approvals takes a card instead of gold")


func test_a_paid_heal_heals_five_and_takes_the_gold() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.hp = 4
	var event: DungeonEvent = _room("beefcake")
	var poor: EventResolver.Result = EventResolver.resolve(event, 0, run, Session.content, 10, false)
	assert_false(poor.ok, "30 gold is needed")
	assert_eq(run.hp, 4)
	var paid: EventResolver.Result = EventResolver.resolve(event, 0, run, Session.content, 100, false)
	assert_true(paid.ok)
	assert_eq(run.hp, 9, "5 HP, not a full heal")
	assert_eq(paid.gold_delta, -30)
	var none: EventResolver.Result = EventResolver.resolve(event, 2, run, Session.content, 100, false)
	assert_true(none.ok)
	assert_eq([none.hp_delta, none.gold_delta, none.boons.size()], [0, 0, 0], "walking on changes nothing")


func test_the_heal_that_costs_a_card_takes_one_card_for_the_run() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.hp = 3
	var before: int = run.current_deck().cards.size()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	var result: EventResolver.Result = EventResolver.resolve(_room("necrocrat"), 0, run, Session.content, 0, false, rng)
	assert_true(result.ok)
	assert_eq(run.hp, 8)
	assert_eq(result.lost_cards.size(), 1, "one card is filed away")
	assert_false(result.lost_cards[0].is_basic, "never basic Infrastructure")
	assert_eq(run.current_deck().cards.size(), before - 1, "it is out of the deck for the rest of the run")
	assert_eq(Session.deck.cards.size(), before, "the real deck is untouched")


func test_the_lose_token_is_read_now() -> void:
	var outcome: DungeonEvent.Outcome = DungeonBuilder.event_outcome("lose:1", null)
	assert_not_null(outcome, "it was an unknown token: the ladle's and the pool's 'lose a card' cost nothing")
	if outcome != null:
		assert_eq(outcome.kind, DungeonEvent.OutcomeKind.LOSE_CARD)
	for spot: Array in [["gourmand", "D-TTK", 7, 2], ["refusemancer", "D-ROT", 7, 2]]:
		var event: DungeonEvent = MainDungeons.def(str(spot[0])).event(DungeonBuilder.event_id_of(DungeonCatalog.find(str(spot[1])), int(spot[2])))
		var kinds: Array[int] = []
		for part: DungeonEvent.Outcome in event.choices[int(spot[3])].outcomes:
			kinds.append(int(part.kind))
		assert_has(kinds, int(DungeonEvent.OutcomeKind.LOSE_CARD), "%s node %d: the written cost is real" % [spot[1], spot[2]])


func test_the_full_heals_that_stay_are_the_cave_the_castle_and_the_lab() -> void:
	var left: Array[String] = []
	for room: Array in DungeonBuilder.full_heal_rooms():
		left.append(str(room[0]))
	left.sort()
	assert_eq(left, ["D-LAB", "D-PC", "D-TUT"] as Array[String], "reported, not changed: the tutorial cave, Primm's Castle, the Path-ology Lab")


# ---- 4.3: the new drawbacks, one by one -------------------------------------------------------------------------------------------------


func test_the_first_unit_you_play_has_minus_two_attack() -> void:
	var game: GameState = _game_with("Slept on the Mats|first_unit_atk=-2,next=1")
	GameFactory.add_infrastructure_cards(game, 0, 6)
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(3, 3, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(3, 3, 1))
	assert_true(game.play_card(0, first.uid))
	assert_true(game.play_card(0, second.uid))
	assert_eq(game.get_attack(first), 1, "3 - 2")
	assert_eq(game.get_defense(first), 3, "its defense is untouched")
	assert_eq(game.get_attack(second), 3, "only the first")
	var source: ModifierSource = DungeonBuilder.boon_from("Slept on the Mats|first_unit_atk=-2,next=1")
	assert_eq(BoonText.short(source), "the first unit you play gets -2 attack in the next fight")
	assert_true(BoonText.is_curse(source))


func test_you_skip_your_first_card_draw_going_second() -> void:
	var plain: GameState = _game_with("Nothing|max_hp=0", 1)
	var cursed: GameState = _game_with("Overslept|first_draw=-1,next=1", 1)
	for game: GameState in [plain, cursed]:
		while game.active != 0 and not game.is_over():
			GameFactory.pass_turn(game)
	assert_eq(cursed.players[0].hand.size(), plain.players[0].hand.size() - 1, "the first turn's draw is skipped")
	GameFactory.pass_turn(plain)
	GameFactory.pass_turn(plain)
	GameFactory.pass_turn(cursed)
	GameFactory.pass_turn(cursed)
	assert_eq(cursed.players[0].hand.size(), plain.players[0].hand.size() - 1, "only once: the next draw is a normal one")


func test_you_skip_your_first_card_draw_going_first() -> void:
	var plain: GameState = _game_with("Nothing|max_hp=0", 0)
	var cursed: GameState = _game_with("Overslept|first_draw=-1,next=1", 0)
	assert_eq(cursed.players[0].hand.size(), plain.players[0].hand.size(), "the first player draws nothing on turn one anyway")
	for game: GameState in [plain, cursed]:
		GameFactory.pass_turn(game)
		while game.active != 0 and not game.is_over():
			GameFactory.pass_turn(game)
	assert_eq(cursed.players[0].hand.size(), plain.players[0].hand.size() - 1, "so the penalty waits for the first turn that draws")
	assert_eq(BoonText.short(DungeonBuilder.boon_from("Overslept|first_draw=-1,next=1")), "you skip your first card draw in the next fight")
	assert_true(BoonText.is_curse(DungeonBuilder.boon_from("Overslept|first_draw=-1,next=1")))


func test_the_first_card_each_turn_costs_one_more() -> void:
	var game: GameState = _game_with("Sticky Fingers|first_cost=1,next=1")
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	assert_eq(game.generic_cost_for(0, first.data, first), 3, "2 + 1")
	GameFactory.add_infrastructure_cards(game, 0, 6)
	assert_true(game.play_card(0, first.uid))
	assert_eq(game.generic_cost_for(0, second.data, second), 2, "the second card costs what it says")
	var source: ModifierSource = DungeonBuilder.boon_from("Sticky Fingers|first_cost=1,next=1")
	assert_eq(BoonText.short(source), "the first card you play each turn costs 1 more in the next fight")
	assert_true(BoonText.is_curse(source))


func test_your_first_infrastructure_enters_exhausted() -> void:
	var game: GameState = _game_with("Flash Burn|first_infra=1,next=1")
	var hand_infra: CardInstance = null
	for card: CardInstance in game.players[0].hand:
		if card.data.is_infrastructure():
			hand_infra = card
			break
	if hand_infra == null:
		hand_infra = GameFactory.add_to_hand(game, 0, GameFactory.infra())
	assert_true(game.play_infrastructure(0, hand_infra.uid))
	assert_true(hand_infra.exhausted, "no energy from it this turn")
	GameFactory.pass_turn(game)
	while game.active != 0 and not game.is_over():
		GameFactory.pass_turn(game)
	assert_false(hand_infra.exhausted, "it refreshes like any other on your next turn")
	var later: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.infra())
	assert_true(game.play_infrastructure(0, later.uid))
	assert_false(later.exhausted, "only the first")
	var source: ModifierSource = DungeonBuilder.boon_from("Flash Burn|first_infra=1,next=1")
	assert_eq(BoonText.short(source), "your first Infrastructure enters exhausted in the next fight")
	assert_true(BoonText.is_curse(source))


func test_the_enemy_starts_with_one_more_card() -> void:
	var plain: GameState = _game_with("Nothing|max_hp=0")
	var cursed: GameState = _game_with("Flagged for Audit|foe_draw=1,next=1")
	assert_eq(cursed.players[1].hand.size(), plain.players[1].hand.size() + 1)
	assert_eq(cursed.players[0].hand.size(), plain.players[0].hand.size(), "your own hand is as usual")
	var source: ModifierSource = DungeonBuilder.boon_from("Flagged for Audit|foe_draw=1,next=1")
	assert_true(source.for_enemy, "the whole drawback sits on the enemy's side")
	assert_eq(BoonText.short(source), "the enemy starts with +1 card in hand in the next fight")


func test_the_enemys_first_unit_gets_plus_one_plus_one() -> void:
	var game: GameState = _game_with("Spotter Knows|foe_first_unit=1,next=1", 1)
	GameFactory.add_infrastructure_cards(game, 1, 6)
	var first: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(2, 2, 1))
	var second: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(2, 2, 1))
	assert_true(game.play_card(1, first.uid))
	assert_true(game.play_card(1, second.uid))
	assert_eq([game.get_attack(first), game.get_defense(first)], [3, 3])
	assert_eq([game.get_attack(second), game.get_defense(second)], [2, 2], "only its first")
	var source: ModifierSource = DungeonBuilder.boon_from("Spotter Knows|foe_first_unit=1,next=1")
	assert_eq(BoonText.short(source), "the enemy's first unit gets +1/+1 in the next fight")
	assert_true(BoonText.is_curse(source))


func test_the_two_drawbacks_the_brief_names_that_already_existed() -> void:
	var exhausted: ModifierSource = DungeonBuilder.boon_from("Waterlogged|exhausted=1,next=1")
	assert_eq(BoonText.short(exhausted), "your units enter exhausted in the next fight")
	var game: GameState = _game_with("Waterlogged|exhausted=1,next=1")
	GameFactory.add_infrastructure_cards(game, 0, 4)
	var unit: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.BEEFCAKE, [CardEnums.Keyword.HUSTLE] as Array[CardEnums.Keyword]))
	assert_true(game.play_card(0, unit.uid))
	assert_true(unit.exhausted, "even a Hustle unit enters exhausted")
	var plain: GameState = _game_with("Nothing|max_hp=0")
	var fed: GameState = _game_with("Samples Were Counted|foe_hp=2,next=1")
	assert_eq(fed.players[1].hp, plain.players[1].hp + 2, "the opponent starts with 2 extra HP")
	assert_eq(BoonText.short(DungeonBuilder.boon_from("Samples Were Counted|foe_hp=2,next=1")), "the enemy starts with +2 HP in the next fight")


func test_a_next_fight_drawback_is_gone_after_one_fight() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.add_dungeon_source(DungeonBuilder.boon_from("Overslept|first_draw=-1,next=1"))
	run.add_dungeon_source(DungeonBuilder.boon_from("Flagged for Audit|foe_draw=1,next=1"))
	assert_eq(run.dungeon_sources.size(), 2)
	assert_true(run.modifiers().has(Modifier.Kind.FIRST_DRAW_PENALTY), "your side has yours")
	assert_false(run.modifiers().has(Modifier.Kind.OPENING_HAND_SIZE), "the enemy's is not on your side")
	run.tick_timed_sources()
	assert_eq(run.dungeon_sources.size(), 0, "both are gone after the fight")


func test_the_new_drawbacks_are_used_in_several_rooms() -> void:
	var text: String = FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")
	for key: String in ["first_unit_atk=-2", "first_draw=-1", "first_cost=1", "first_infra=1", "foe_draw=1", "foe_first_unit=1", "foe_hp=2", "exhausted=1"]:
		assert_string_contains(text, key)
	assert_gte(text.count("first_draw=-1"), 2, "skipping the first draw is in two rooms")
