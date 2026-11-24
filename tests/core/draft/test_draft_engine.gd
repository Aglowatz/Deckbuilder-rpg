extends GutTest
## Draft mode, Phase 1 (Part 1): the draft engine's rules (docs/design/draft_mode.md) - the schedule, the offers, the high-rarity
## picks, the Path and multi-Path rules, equipment and item picks, the reroll, the 35-card deck, saving, the rivals and the run.

const B: int = Affinity.Type.BEEFCAKE
const G: int = Affinity.Type.GOURMAND


func _content() -> ContentSet:
	return Session.content


func _start(paths: Array[int] = [B], seed_value: int = 11, two: bool = false, multi: bool = false) -> DraftState:
	return DraftEngine.start(_content(), "zone:beefcake", paths, 12, seed_value, two, multi)


func _finish_picks(state: DraftState, option: int = 0) -> void:
	var guard: int = 0
	while state.phase == DraftState.PHASE_PICK and guard < 100:
		assert_true(DraftEngine.pick(_content(), state, option % (state.offer["options"] as Array).size()))
		guard += 1


func test_the_schedule_is_25_cards_5_equipment_picks_and_2_item_picks_in_their_places() -> void:
	var steps: Array[Dictionary] = DraftEngine.schedule()
	var kinds: Dictionary = {"card": 0, "equipment": 0, "item": 0}
	var cards_before: Dictionary = {"equipment": [], "item": []}
	for step: Dictionary in steps:
		kinds[step["kind"]] = int(kinds[step["kind"]]) + 1
		if step["kind"] != "card":
			(cards_before[step["kind"]] as Array).append(int(kinds["card"]))
	assert_eq(kinds, {"card": 25, "equipment": 5, "item": 2})
	assert_eq(cards_before["equipment"], [4, 9, 14, 19, 23], "an equipment pick after card picks 4, 9, 14, 19 and 23")
	assert_eq(cards_before["item"], [7, 17], "an item pick after card picks 7 and 17")


func test_every_card_offer_is_three_different_cards_of_the_draft_s_paths_or_pathless() -> void:
	var state: DraftState = _start()
	var seen_pathless: bool = false
	var guard: int = 0
	while state.phase == DraftState.PHASE_PICK and guard < 100:
		guard += 1
		var options: Array = state.offer["options"] as Array
		assert_eq(options.size(), 3, "three options at step %d" % state.step)
		var unique: Dictionary = {}
		for id: Variant in options:
			unique[id] = true
		assert_eq(unique.size(), 3, "three different options")
		if state.offer["kind"] == "card":
			for id: Variant in options:
				var card: CardData = _content().card(str(id))
				var own: Array[Affinity.Type] = card.paths()
				seen_pathless = seen_pathless or own.is_empty()
				assert_true(own.is_empty() or (own.size() == 1 and int(own[0]) == B), "%s is Beefcake or Pathless" % card.id)
				assert_false(CardAvailability.is_enemy_only(card), "no foe's own card is offered")
				assert_false(card.is_unlimited(), "basic Infrastructure is never a pick")
		DraftEngine.pick(_content(), state, 0)
	assert_true(seen_pathless, "Pathless cards are always in the pool")
	assert_eq(state.cards.size(), 25)
	assert_eq(state.equipment.size(), 5)
	assert_eq(state.items.size(), 2)
	assert_eq(state.phase, DraftState.PHASE_DECK)


func test_every_fifth_pick_offers_the_top_two_rarities() -> void:
	for seed_value: int in [3, 4, 5]:
		var state: DraftState = _start([B], seed_value)
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			guard += 1
			if state.offer["kind"] == "card":
				var high: bool = int(state.offer["pick"]) % 5 == 0
				assert_eq(bool(state.offer["high"]), high)
				for id: Variant in state.offer["options"] as Array:
					var card: CardData = _content().card(str(id))
					if high:
						assert_true(int(card.rarity) >= int(CardEnums.Rarity.EPIC), "pick %d offers Epic or Legendary (%s)" % [int(state.offer["pick"]), card.id])
					else:
						assert_true(int(card.rarity) < int(CardEnums.Rarity.LEGENDARY), "a Legendary comes from a high-rarity pick only (%s)" % card.id)
			DraftEngine.pick(_content(), state, 1)


func test_no_offer_is_three_duds() -> void:
	for seed_value: int in range(20, 30):
		var state: DraftState = _start([B], seed_value)
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			guard += 1
			if state.offer["kind"] == "card":
				var playable: bool = false
				for id: Variant in state.offer["options"] as Array:
					var card: CardData = _content().card(str(id))
					playable = playable or card.is_unit() or card.energy_value() <= 3
				assert_true(playable, "seed %d pick %d has a unit or a cheap card" % [seed_value, int(state.offer["pick"])])
			DraftEngine.pick(_content(), state, 2)


func test_the_multi_path_lock_holds_in_drafts() -> void:
	var two_path: CardData = null
	var three_path: CardData = null
	for card: CardData in _content().multipath_cards.values():
		if CardAvailability.is_enemy_only(card):
			continue
		if card.paths().size() == 2 and two_path == null:
			two_path = card
		if card.paths().size() >= 3 and three_path == null:
			three_path = card
	assert_not_null(two_path)
	assert_not_null(three_path)
	var all: Array[int] = [1, 2, 3, 4]
	assert_false(DraftEngine.card_allowed(two_path, all, false, false), "two-Path cards wait for all four zones")
	assert_true(DraftEngine.card_allowed(two_path, all, true, false))
	assert_false(DraftEngine.card_allowed(three_path, all, true, false), "three- and four-Path cards wait for Primm")
	assert_true(DraftEngine.card_allowed(three_path, all, true, true))
	var one: Array[int] = [int(two_path.paths()[0])]
	assert_false(DraftEngine.card_allowed(two_path, one, true, true), "a multi-Path card needs every one of its Paths chosen")


func test_the_five_equipment_picks_are_five_different_slots() -> void:
	var state: DraftState = _start()
	_finish_picks(state)
	var slots: Dictionary = {}
	for id: String in state.equipment:
		var piece: EquipmentData = _content().equipment_piece(id)
		assert_not_null(piece, id)
		slots[int(piece.slot)] = true
	assert_eq(slots.size(), 5, "one piece for each slot")


## Fable big pass Nov 23: the owner's removals are the equipment ban list (Gotta-Go Galoshes, the pieces that hurt enemy units,
## the pieces that only work outside battle); no item and no card is banned.
func test_the_whole_pool_is_offered_but_the_owners_removals() -> void:
	var banned: Dictionary = DraftRules.banned("banned_equipment")
	assert_eq(DraftEngine.equipment_pool(_content()).size(), GearCatalog.all_pieces(_content()).size() - banned.size(), "every piece of equipment but the removals is in the pool")
	assert_true(banned.has("gotta_go_galoshes"))
	assert_true(banned.has("flamethrower"))
	assert_true(banned.has("hall_pass_slippers"))
	for piece: EquipmentData in DraftEngine.equipment_pool(_content()):
		assert_false(banned.has(piece.id), "%s is banned" % piece.id)
	assert_eq(DraftEngine.item_pool(_content()).size(), _content().items.size(), "every item is in the pool")
	for key: String in ["banned_equipment", "banned_items", "banned_cards"]:
		assert_true(DraftRules.data().has(key), "%s is in the data file" % key)
	for key: String in ["banned_items", "banned_cards"]:
		assert_eq(DraftRules.banned(key).size(), 0)


func test_a_banned_piece_is_never_offered() -> void:
	var first: EquipmentData = DraftEngine.equipment_pool(_content())[0]
	DraftRules.data()["banned_equipment"] = [first.id]
	var ids: Array[String] = []
	for piece: EquipmentData in DraftEngine.equipment_pool(_content()):
		ids.append(piece.id)
	DraftRules.reload()
	assert_false(ids.has(first.id))


func test_one_reroll_changes_the_offer_keeps_the_kind_and_is_then_spent() -> void:
	var state: DraftState = _start()
	assert_eq(state.rerolls_left, 1, "one reroll per draft (the number is DraftRules')")
	var before: Array = (state.offer["options"] as Array).duplicate()
	assert_true(DraftEngine.reroll(_content(), state))
	assert_ne(state.offer["options"], before, "three new options")
	assert_eq(state.offer["kind"], "card")
	assert_eq(state.rerolls_left, 0)
	assert_false(DraftEngine.reroll(_content(), state), "the reroll is spent")
	# on an equipment offer the slot stays
	var other: DraftState = _start([B], 12)
	while other.offer["kind"] != "equipment":
		DraftEngine.pick(_content(), other, 0)
	var slot: int = int(other.offer["slot"])
	assert_true(DraftEngine.reroll(_content(), other))
	assert_eq(int(other.offer["slot"]), slot, "a reroll keeps the slot")
	assert_eq(other.offer["kind"], "equipment")


func test_the_same_seed_gives_the_same_offers() -> void:
	var a: DraftState = _start([B], 99)
	var b: DraftState = _start([B], 99)
	for i: int in range(10):
		assert_eq(a.offer, b.offer)
		DraftEngine.pick(_content(), a, i % 3)
		DraftEngine.pick(_content(), b, i % 3)
	assert_ne(_start([B], 100).offer["options"], _start([B], 99).offer["options"], "another seed, another offer")


func test_the_deck_is_20_of_the_25_plus_15_basics_split_across_the_paths() -> void:
	var state: DraftState = DraftEngine.start(_content(), "open", [B, G], 12, 5)
	_finish_picks(state, 1)
	assert_eq(state.bench.size(), 5, "five of the 25 sit out by default")
	assert_true(DraftEngine.deck_ready(state))
	var deck: Deck = DraftEngine.build_deck(_content(), state)
	assert_eq(deck.cards.size(), 35)
	var basics: int = 0
	for card: CardData in deck.cards:
		if card.is_unlimited():
			basics += 1
			assert_true([B, G].has(int(card.color)), "the basics are of the drafted Paths")
	assert_eq(basics, 15)
	assert_eq(int(state.basics[B]) + int(state.basics[G]), 15)
	# the player changes the split
	var before: int = int(state.basics[B])
	if before > 0:
		assert_true(DraftEngine.move_basic(state, B, G))
		assert_eq(int(state.basics[B]), before - 1)
	assert_true(DraftEngine.deck_ready(state))
	# and swaps a card: bench one, the deck is short, take one back
	var in_deck: int = 0
	while state.bench.has(in_deck):
		in_deck += 1
	assert_true(DraftEngine.toggle_bench(state, in_deck))
	assert_false(DraftEngine.deck_ready(state), "19 cards is not a deck")
	assert_true(DraftEngine.toggle_bench(state, state.bench[0]))
	assert_true(DraftEngine.deck_ready(state))
	# Fable big pass Nov 23 (the owner: build it like the main deck builder): all 25 picks may be played, 35 is only the minimum
	assert_true(DraftEngine.toggle_bench(state, state.bench[0]), "a 21st card fits: the deck may be bigger than the minimum")
	assert_true(DraftEngine.deck_ready(state))


func test_no_copy_limits_and_no_45_card_minimum() -> void:
	var state: DraftState = _start()
	var common: String = ""
	for card: CardData in DraftEngine.card_pool(_content(), state):
		if card.rarity == CardEnums.Rarity.COMMON and card.is_unit():
			common = card.id
			break
	for i: int in range(25):
		state.cards.append(common)
	state.phase = DraftState.PHASE_DECK
	DraftEngine.auto_deck(_content(), state)
	var deck: Deck = DraftEngine.build_deck(_content(), state)
	assert_eq(deck.count_of(common), 20, "twenty copies of one common is a legal draft deck")
	assert_eq(deck.cards.size(), 35)
	assert_lt(deck.cards.size(), DeckValidator.MIN_DECK_SIZE, "the main game's 45-card minimum is not the draft's")


func test_a_draft_in_progress_saves_and_resumes() -> void:
	var state: DraftState = _start([B], 31)
	for i: int in range(9):
		DraftEngine.pick(_content(), state, i % 3)
	DraftEngine.reroll(_content(), state)
	var text: String = JSON.stringify(state.to_dict())
	var back: DraftState = DraftState.from_dict(JSON.parse_string(text) as Dictionary)
	assert_not_null(back)
	assert_eq(back.cards, state.cards)
	assert_eq(back.equipment, state.equipment)
	assert_eq(back.items, state.items)
	assert_eq(back.step, state.step)
	assert_eq(back.rerolls_left, 0)
	assert_eq(back.offer["options"], state.offer["options"], "the same three options are on the table")
	DraftEngine.pick(_content(), state, 0)
	DraftEngine.pick(_content(), back, 0)
	assert_eq(back.offer["options"], state.offer["options"], "and the draft goes on the same way")
	assert_null(DraftState.from_dict({}), "an old save has no draft")


func test_the_draft_player_has_base_hp_and_only_the_drafted_gear() -> void:
	var state: DraftState = _start()
	_finish_picks(state)
	var real: PlayerProfile = PlayerProfile.new()
	real.apply_level(ProgressionTable.row(12))
	real.equipment.append(_content().equipment_piece("glass_jaw_gauntlets"))
	var made: PlayerProfile = DraftRun.player_profile(_content(), state, real)
	assert_eq(made.max_hp, ProgressionTable.row(12).max_hp, "the base HP of the level")
	assert_eq(made.opening_hand_size, ProgressionTable.row(12).opening_hand_size)
	assert_eq(made.equipment.size(), 5)
	for piece: ModifierSource in made.equipment:
		assert_true(state.equipment.has((piece as EquipmentData).id))
	assert_eq(made.equipped_item_ids, state.items, "only the drafted items")
	assert_eq(real.equipment.size(), 1, "the main loadout is untouched")


func test_rivals_draft_with_the_same_system_and_their_decks_are_fixed_up() -> void:
	var state: DraftState = _start([B], 41)
	_finish_picks(state)
	assert_true(DraftRun.begin(_content(), state))
	assert_eq(state.phase, DraftState.PHASE_RUN)
	assert_eq(state.rivals.size(), 3)
	var names: Dictionary = {}
	for rival: Dictionary in state.rivals:
		names[rival["name"]] = true
		assert_ne(DraftRivals.portrait_id(str(rival["name"])), "", "a rival is somebody with a portrait")
		var deck: Deck = ZoneDecks.from_recipe(_content(), str(rival["name"]), rival["recipe"] as Dictionary)
		assert_eq(deck.cards.size(), 35, "%s plays 35 cards" % rival["name"])
		# Fable big pass Nov 23: a rival drafts a random Path of its own (one Path in a one-Path draft)
		var rival_paths: Array[int] = []
		rival_paths.assign(rival["paths"] as Array)
		assert_eq(rival_paths.size(), 1)
		var units: int = 0
		var dear: int = 0
		var basics: int = 0
		for card: CardData in deck.cards:
			if card.is_unlimited():
				basics += 1
				continue
			units += 1 if card.is_unit() else 0
			dear += 1 if card.energy_value() >= 5 else 0
			assert_true(DraftEngine.card_allowed(card, rival_paths, false, false), "%s drafted from the pool of its own Path (%s)" % [rival["name"], card.id])
		assert_eq(basics, 15)
		assert_gte(units, 9, "%s has enough units" % rival["name"])
		assert_lte(dear, 5, "%s is not all dear cards" % rival["name"])
		assert_eq(int(rival["hp"]), ProgressionTable.row(12).max_hp + int(DraftRules.rivals().get("hp_bonus", 0)), "a rival has the player's base HP plus the rules' bonus")
		for id: Variant in rival["equipment"] as Array:
			assert_lte(int(_content().equipment_piece(str(id)).rarity), DraftRules.rival_equipment_cap(DraftArena.KIND_ZONE), "%s wears nothing above the cap" % rival["name"])
		var worn: Array = rival["equipment"] as Array
		assert_eq(worn.size(), 5, "%s drafted five pieces of equipment, like the player" % rival["name"])
		var slots: Dictionary = {}
		for id: Variant in worn:
			slots[int(_content().equipment_piece(str(id)).slot)] = true
		assert_eq(slots.size(), 5, "one piece per slot")
		assert_eq(DraftRivals.equipment_sources(_content(), rival).size(), 5)
	assert_eq(names.size(), 3, "three different rivals")


func test_a_run_ends_at_three_wins_or_two_losses() -> void:
	var state: DraftState = _start()
	_finish_picks(state)
	DraftRun.begin(_content(), state)
	assert_false(DraftRun.record(state, true))
	assert_false(DraftRun.record(state, false))
	assert_false(DraftRun.record(state, true))
	assert_true(DraftRun.record(state, true), "three wins end it")
	assert_true(state.full_win())
	assert_eq(state.phase, DraftState.PHASE_DONE)
	var other: DraftState = _start([B], 8)
	_finish_picks(other)
	DraftRun.begin(_content(), other)
	DraftRun.record(other, false)
	assert_true(DraftRun.record(other, false), "two losses end it")
	assert_false(other.full_win())
	assert_false(DraftRun.keep(other, other.cards[0]), "no card is kept without a full win")
	assert_true(DraftRun.keep(state, state.cards[3]))
	assert_false(DraftRun.keep(state, state.cards[4]), "one card only")


func test_rewards_rise_with_wins_and_the_first_full_win_pays_much_more() -> void:
	var last: int = -1
	for wins: int in range(4):
		var pay: Dictionary = DraftChallenges.reward(wins, wins >= 3, false)
		assert_gt(int(pay["gold"]), last, "%d wins pay more than %d" % [wins, wins - 1])
		assert_gt(int(pay["gold"]), 0, "something for every result")
		last = int(pay["gold"])
	var replay: Dictionary = DraftChallenges.reward(3, true, false)
	var first: Dictionary = DraftChallenges.reward(3, true, true)
	assert_gte(int(first["gold"]), int(replay["gold"]) * 3, "the first win pays much more")
	assert_true(bool(first["keep_card"]))
	assert_false(bool(DraftChallenges.reward(2, false, true)["keep_card"]))


## Fable big pass Nov 23 (the owner): entry is free, every time.
func test_entry_is_free() -> void:
	assert_eq(DraftChallenges.fee("zone:beefcake", {}), 0)
	assert_eq(DraftChallenges.fee("zone:beefcake", {DraftChallenges.attempts_counter("zone:beefcake"): 5}), 0)
	assert_eq(DraftChallenges.fee(DraftArena.OPEN_ID, {}), 0)


func test_a_draft_fight_is_an_ordinary_duel_with_the_draft_deck() -> void:
	var state: DraftState = _start()
	_finish_picks(state)
	DraftRun.begin(_content(), state)
	var profile: PlayerProfile = DraftRun.player_profile(_content(), state)
	var game: GameState = DraftRun.build_game(_content(), state, profile, DraftRun.next_rival(state), 5)
	assert_eq(game.players.size(), 2)
	var rival_setup: PlayerSetup = DraftRun.enemy_setup(_content(), DraftRun.next_rival(state))
	assert_eq(rival_setup.profile.equipment.size(), 5, "the rival wears what it drafted in the fight")
	assert_gt(game.players[1].hp, 0)
	var total: int = game.players[0].deck.size() + game.players[0].hand.size()
	assert_eq(total, 35, "the player plays the 35-card draft deck")
