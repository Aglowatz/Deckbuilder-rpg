extends GutTest
## Fable Nov 16b (Part 2): the rules of the four zone card minigames - "Reps" (the Gainlands), "Order Up" (the Endless Buffet), "Sort It
## Out" (the Verdant Dump) and "File in Order" (the D.N.A.) - their win and lose conditions, and that a newcomer wins a first try.

const ZONES: Array[String] = ["beefcake", "gourmand", "refusemancer", "necrocrat"]


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _content() -> ContentSet:
	return Session.content


# ---- the pool ---------------------------------------------------------------------------------

func test_every_zone_deals_real_cards_of_its_path_and_colourless() -> void:
	for zone_id: String in ZONES:
		var path: Affinity.Type = ZoneEffects.path_of(zone_id)
		var cards: Array[CardData] = CardGamePool.cards(_content(), zone_id)
		assert_gt(cards.size(), 20, "%s has cards to deal" % zone_id)
		var own: int = 0
		var colourless: int = 0
		for card: CardData in cards:
			assert_false(card.is_token or card.is_infrastructure(), card.id)
			assert_false(CardAvailability.is_enemy_only(card), "%s is not an enemy-only card" % card.id)
			var paths: Array[Affinity.Type] = card.paths()
			assert_true(paths.is_empty() or (paths.size() == 1 and paths[0] == path), "%s is %s or colourless" % [card.id, zone_id])
			if paths.is_empty():
				colourless += 1
			else:
				own += 1
		assert_gt(own, 5, "%s: cards of its own Path" % zone_id)
		assert_gt(colourless, 5, "%s: colourless cards too" % zone_id)
		assert_gt(CardGamePool.units(_content(), zone_id).size(), 8)
		assert_false(CardGamePool.infrastructure(_content(), zone_id).is_empty(), "%s has an Infrastructure card for the bins" % zone_id)


func test_stars_follow_the_slips() -> void:
	assert_eq(CardGamePool.stars_for(false, 0), 0)
	assert_eq(CardGamePool.stars_for(true, 0), 3)
	assert_eq(CardGamePool.stars_for(true, 2), 2)
	assert_eq(CardGamePool.stars_for(true, 3), 1)


# ---- Reps -------------------------------------------------------------------------------------

func test_reps_eight_right_in_a_row_wins() -> void:
	var game: RepsCardGame = RepsCardGame.deal(CardGamePool.units(_content(), "beefcake"), _rng(7))
	assert_eq(game.deck.size(), RepsCardGame.DECK_SIZE)
	for _guess: int in range(RepsCardGame.STREAK_TO_WIN):
		assert_false(game.is_over())
		var higher: bool = game.upcoming().attack >= game.current().attack
		assert_true(game.guess(higher))
	assert_true(game.is_won())
	assert_eq(game.stars(), 3, "no miss: three stars")
	assert_false(game.guess(true), "nothing more is guessed after the set")


func test_reps_a_tie_counts_as_right_either_way() -> void:
	var units: Array[CardData] = CardGamePool.units(_content(), "beefcake")
	var same: Array[CardData] = []
	for card: CardData in units:
		if card.attack == units[0].attack:
			same.append(card)
	assert_gt(same.size(), 1, "two units of the same power exist")
	var game: RepsCardGame = RepsCardGame.new()
	game.deck = [same[0], same[1], same[0], same[1]] as Array[CardData]
	assert_true(game.would_be_right(true))
	assert_true(game.would_be_right(false))
	assert_true(game.guess(false))
	assert_true(game.guess(true))
	assert_eq(game.streak, 2)


## Overnight Nov 18 (owner, inbox Nov 17 #8): a miss keeps the reps already done.
func test_reps_a_miss_keeps_the_reps_and_the_fourth_miss_loses() -> void:
	var game: RepsCardGame = RepsCardGame.deal(CardGamePool.units(_content(), "beefcake"), _rng(11))
	var right_first: int = 0
	while right_first < 3:
		if game.upcoming().attack == game.current().attack:
			game.guess(true)
		else:
			game.guess(game.upcoming().attack > game.current().attack)
		right_first += 1
	assert_eq(game.streak, 3)
	var missed: int = 0
	while missed < RepsCardGame.MISSES_ALLOWED:
		if game.upcoming().attack == game.current().attack:
			game.guess(true)  # a tie cannot be missed
			continue
		assert_false(game.guess(game.upcoming().attack < game.current().attack))
		missed += 1
		assert_eq(game.streak, 3, "a miss keeps the reps already done")
		assert_false(game.is_lost(), "%d misses are allowed" % RepsCardGame.MISSES_ALLOWED)
	while game.upcoming().attack == game.current().attack:
		game.guess(true)
	game.guess(game.upcoming().attack < game.current().attack)
	assert_true(game.is_lost(), "the fourth miss ends the set")
	assert_eq(game.stars(), 0)


func test_reps_a_newcomer_wins_most_first_sets() -> void:
	var units: Array[CardData] = CardGamePool.units(_content(), "beefcake")
	var low: int = 99
	var high: int = 0
	for card: CardData in units:
		low = mini(low, card.attack)
		high = maxi(high, card.attack)
	var wins: int = 0
	var coin_wins: int = 0
	var coin: RandomNumberGenerator = _rng(99)
	for seed_value: int in range(300):
		var game: RepsCardGame = RepsCardGame.deal(units, _rng(seed_value + 1))
		while not game.is_over():
			game.guess(game.natural_guess(low, high))
		if game.is_won():
			wins += 1
		var blind: RepsCardGame = RepsCardGame.deal(units, _rng(seed_value + 1))
		while not blind.is_over():
			blind.guess(coin.randf() < 0.5)
		if blind.is_won():
			coin_wins += 1
	gut.p("Reps: 'guess away from the edge' wins %d of 300 first sets; a coin flip wins %d" % [wins, coin_wins])
	assert_gt(wins, 210, "a newcomer guessing away from the nearer edge wins at least 70 % of first sets")
	assert_lt(coin_wins, wins / 3, "and it is still a game: a coin flip does far worse")


# ---- Order Up ---------------------------------------------------------------------------------

func test_order_up_every_row_holds_an_answer_and_three_tickets_win() -> void:
	for seed_value: int in range(40):
		var game: OrderCardGame = OrderCardGame.deal(CardGamePool.cards(_content(), "gourmand"), _rng(seed_value + 1))
		for _ticket: int in range(OrderCardGame.TICKETS):
			assert_eq(game.row.size(), OrderCardGame.ROW_SIZE)
			assert_gt(game.target, 0)
			var answer: Array[int] = game.solution()
			assert_false(answer.is_empty(), "seed %d ticket %d: the row can make %d" % [seed_value, game.ticket, game.target])
			for index: int in answer:
				game.toggle(index)
			assert_eq(game.total(), game.target)
			assert_true(game.serve())
		assert_true(game.is_won())
		assert_eq(game.stars(), 3)


func test_order_up_a_wrong_total_is_sent_back_and_the_third_loses() -> void:
	var game: OrderCardGame = OrderCardGame.deal(CardGamePool.cards(_content(), "gourmand"), _rng(5))
	assert_false(game.serve(), "an empty plate cannot be rung up")
	assert_eq(game.sent_back, 0)
	for strike: int in range(OrderCardGame.SENT_BACK_LIMIT):
		assert_false(game.is_lost())
		# Everything on the plate is always too much (six cards of cost 1 or more against a two- or three-card answer).
		for index: int in range(game.row.size()):
			game.toggle(index)
		assert_ne(game.total(), game.target)
		assert_false(game.serve())
		assert_eq(game.sent_back, strike + 1)
		assert_true(game.picked.is_empty(), "the plate is cleared")
	assert_true(game.is_lost())
	assert_eq(game.stars(), 0)


func test_order_up_two_swaps_each_with_an_answer() -> void:
	var game: OrderCardGame = OrderCardGame.deal(CardGamePool.cards(_content(), "gourmand"), _rng(21))
	var target: int = game.target
	for swap: int in range(OrderCardGame.SWAPS):
		assert_true(game.swap_row())
		assert_eq(game.target, target, "a swap keeps the ticket")
		assert_eq(game.row.size(), OrderCardGame.ROW_SIZE)
		assert_false(game.solution().is_empty(), "the new row can make the ticket too")
	assert_false(game.swap_row(), "only two swaps")
	for index: int in game.solution():
		game.toggle(index)
	assert_true(game.serve())
	game.toggle(0)
	game.toggle(0)
	assert_eq(game.total(), 0, "a card can be taken off the plate again")


# ---- Sort It Out ------------------------------------------------------------------------------

func _belt(seed_value: int) -> SortCardGame:
	return SortCardGame.deal(CardGamePool.cards(_content(), "refusemancer"), CardGamePool.infrastructure(_content(), "refusemancer"), _rng(seed_value))


func test_sort_it_out_deals_twenty_cards_for_all_four_bins() -> void:
	var game: SortCardGame = _belt(3)
	assert_eq(game.cards.size(), SortCardGame.CARDS)
	var per_bin: Array[int] = [0, 0, 0, 0]
	for index: int in range(game.cards.size()):
		per_bin[game.bin_of(index)] += 1
	for bin: int in range(SortCardGame.BIN_COUNT):
		assert_gt(per_bin[bin], 1, "bin %s gets cards" % CardGamePool.KIND_NAMES[bin])
	assert_eq(CardGamePool.kind_of(_content().infrastructure[int(Affinity.Type.REFUSEMANCER)] as CardData), CardGamePool.Kind.INFRASTRUCTURE)


func test_sort_it_out_sixteen_right_wins_and_the_belt_speeds_up_gently() -> void:
	var game: SortCardGame = _belt(4)
	for card: int in range(SortCardGame.CARDS):
		var time: float = SortCardGame.spawn_time(card) + 1.0
		game.advance(time)
		# Four on purpose in the wrong bin.
		var bin: int = game.bin_of(card) if card >= 4 else (game.bin_of(card) + 1) % SortCardGame.BIN_COUNT
		assert_eq(game.press(bin, time), SortCardGame.Result.CORRECT if card >= 4 else SortCardGame.Result.WRONG)
	assert_true(game.is_finished())
	assert_eq(game.correct_count(), 16)
	assert_true(game.is_won(), "16 of 20 wins")
	assert_eq(game.stars(), 1)
	for card: int in range(1, SortCardGame.CARDS):
		assert_gt(SortCardGame.spawn_time(card), SortCardGame.spawn_time(card - 1), "cards come one after another")
		assert_lt(SortCardGame.end_time(card) - SortCardGame.spawn_time(card), SortCardGame.end_time(card - 1) - SortCardGame.spawn_time(card - 1) + 0.001, "never slower")
	assert_gt(SortCardGame.end_time(SortCardGame.CARDS - 1) - SortCardGame.spawn_time(SortCardGame.CARDS - 1), 5.0, "the last card still rides the belt for five seconds or more")
	assert_gt(SortCardGame.spawn_time(SortCardGame.CARDS - 1) - SortCardGame.spawn_time(SortCardGame.CARDS - 2), 1.5, "and the cards never come closer than a second and a half")


func test_sort_it_out_the_fifth_lost_card_stops_the_belt() -> void:
	var game: SortCardGame = _belt(5)
	assert_eq(game.press(0, 0.0), SortCardGame.Result.IGNORED, "nothing to sort before the first card appears")
	# Let the first two fall off the end, put the next two in the wrong bin.
	assert_eq(game.advance(SortCardGame.end_time(1) + 0.01), 2)
	for card: int in [2, 3]:
		var time: float = maxf(SortCardGame.spawn_time(card) + 0.5, SortCardGame.end_time(1) + 0.02)
		assert_eq(game.press((game.bin_of(card) + 2) % SortCardGame.BIN_COUNT, time), SortCardGame.Result.WRONG)
	assert_false(game.is_lost(), "four lost: sixteen can still be reached")
	assert_false(game.is_finished())
	game.press((game.bin_of(4) + 1) % SortCardGame.BIN_COUNT, SortCardGame.spawn_time(4) + 0.5)
	assert_true(game.is_lost(), "the fifth lost card ends the run")
	assert_true(game.is_finished())
	assert_false(game.is_won())
	assert_eq(game.stars(), 0)


# ---- File in Order ----------------------------------------------------------------------------

func _file(seed_value: int) -> FileCardGame:
	return FileCardGame.deal(CardGamePool.cards(_content(), "necrocrat"), _rng(seed_value))


func test_file_in_order_deals_seven_scattered_cards_that_nine_swaps_can_always_file() -> void:
	for seed_value: int in range(60):
		var game: FileCardGame = _file(seed_value + 1)
		assert_eq(game.cards.size(), FileCardGame.CARDS)
		var keys: Dictionary = {}
		for card: CardData in game.cards:
			keys[FileCardGame.key_of(card)] = true
		assert_eq(keys.size(), FileCardGame.CARDS, "seed %d: no two cards share a cost and a power" % seed_value)
		assert_gte(game.out_of_place().size(), 4, "seed %d: scattered" % seed_value)
		assert_lte(game.swaps_needed(), 6, "seven cards never need more than six swaps")
		assert_lt(game.swaps_needed(), FileCardGame.MAX_SWAPS)


func test_file_in_order_ascending_cost_then_power() -> void:
	var game: FileCardGame = _file(9)
	var wanted: Array[CardData] = game.sorted_cards()
	for index: int in range(1, wanted.size()):
		var before: CardData = wanted[index - 1]
		var after: CardData = wanted[index]
		assert_true(before.energy_value() < after.energy_value() or (before.energy_value() == after.energy_value() and CardGamePool.power_of(before) < CardGamePool.power_of(after)))


## Files the cards with the fewest swaps: each swap puts one card in its place.
func _solve(game: FileCardGame) -> void:
	var wanted: Array[CardData] = game.sorted_cards()
	for index: int in range(game.cards.size()):
		if game.cards[index] != wanted[index]:
			assert_true(game.swap(index, game.cards.find(wanted[index])))


func test_file_in_order_the_right_order_is_approved() -> void:
	var game: FileCardGame = _file(12)
	_solve(game)
	assert_true(game.in_order())
	assert_lte(game.swaps, 6)
	assert_true(game.stamp().is_empty())
	assert_true(game.approved)
	assert_eq(game.stars(), 3)
	assert_false(game.swap(0, 1), "a closed file is not touched again")


func test_file_in_order_one_free_check_then_rejected() -> void:
	var game: FileCardGame = _file(13)
	var wrong: Array[int] = game.stamp()
	assert_false(wrong.is_empty(), "the first check shows the cards out of place")
	assert_eq(wrong, game.out_of_place())
	assert_false(game.is_over(), "and is free")
	assert_eq(game.free_checks_left(), 0)
	assert_false(game.stamp().is_empty())
	assert_true(game.rejected, "a second wrong check is rejected")
	assert_eq(game.stars(), 0)
	# After the free check the file can still be put right and approved.
	var second: FileCardGame = _file(13)
	second.stamp()
	_solve(second)
	assert_true(second.stamp().is_empty())
	assert_true(second.approved)
	assert_eq(second.stars(), 2, "one check used: two stars")


func test_file_in_order_at_most_nine_swaps() -> void:
	var game: FileCardGame = _file(14)
	for swap: int in range(FileCardGame.MAX_SWAPS):
		assert_true(game.swap(0, 1))
	assert_eq(game.swaps_left(), 0)
	assert_false(game.swap(0, 1), "no tenth swap")
	assert_false(game.swap(2, 2), "a card is not swapped with itself")
	# Nine swaps of the same pair leave them swapped once: the order is wrong, and with no swap left the stamp rejects it.
	if not game.in_order():
		game.stamp()
		assert_true(game.rejected)
