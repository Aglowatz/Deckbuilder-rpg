class_name ChallengeResolver
extends RefCounted
## Resolves a ChallengeData against a DungeonRun: reveals cards from the (shuffled) current deck,
## decides success, then applies the outcomes to the run.


static func resolve(
	challenge: ChallengeData,
	run: DungeonRun,
	rng: RandomNumberGenerator,
	choice: ChallengeChoice = null,
) -> ChallengeResult:
	var picked: ChallengeChoice = choice if choice != null else ChallengeChoice.new()
	var result: ChallengeResult = ChallengeResult.new()
	result.challenge_id = challenge.id
	var deck_cards: Array[CardData] = run.current_deck().cards
	var sacrificed: CardData = null
	match challenge.kind:
		ChallengeData.Kind.FIRST_CREATURE_POWER:
			var shuffled: Array[CardData] = deck_cards.duplicate()
			RngUtil.shuffle(shuffled, rng)
			for card: CardData in shuffled:
				result.revealed.append(card)
				if card.is_creature():
					result.success = card.power >= challenge.threshold
					break
		ChallengeData.Kind.TOP_N_LAND_COUNT:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			result.success = _count(result.revealed, func(c: CardData) -> bool: return c.is_land()) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TYPE_COUNT:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			var wanted: CardEnums.CardType = challenge.card_type
			result.success = _count(result.revealed, func(c: CardData) -> bool: return c.type == wanted) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TOTAL_COST:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			var total: int = 0
			for card: CardData in result.revealed:
				total += card.mana_value()
			result.success = total >= challenge.threshold
		ChallengeData.Kind.SACRIFICE_CARD:
			sacrificed = picked.sacrifice_card
			if sacrificed != null and not deck_cards.has(sacrificed):
				sacrificed = null
			if sacrificed == null:
				sacrificed = _cheapest_non_basic(deck_cards)
			result.success = sacrificed != null
		ChallengeData.Kind.PAY_LIFE:
			if not picked.accept or run.life <= challenge.threshold:
				result.declined = true
				return result
			result.success = true
	var outcomes: Array[ChallengeOutcome] = challenge.on_success if result.success else challenge.on_failure
	for outcome: ChallengeOutcome in outcomes:
		_apply(outcome, run, rng, result, sacrificed)
	return result


static func _apply(
	outcome: ChallengeOutcome,
	run: DungeonRun,
	rng: RandomNumberGenerator,
	result: ChallengeResult,
	sacrificed: CardData,
) -> void:
	result.outcomes.append(outcome)
	match outcome.kind:
		ChallengeOutcome.Kind.LOSE_LIFE:
			var before: int = run.life
			run.lose_life(outcome.amount)
			result.life_lost += before - run.life
		ChallengeOutcome.Kind.HEAL:
			var before: int = run.life
			run.heal(outcome.amount)
			result.life_healed += run.life - before
		ChallengeOutcome.Kind.LOSE_CARD:
			var victim: CardData = _card_to_lose(run, rng, result, sacrificed)
			if victim != null and run.lose_card(victim):
				result.lost_cards.append(victim)
		ChallengeOutcome.Kind.GAIN_BOON:
			if outcome.boon != null:
				run.add_dungeon_source(outcome.boon)
				result.boons.append(outcome.boon)
		ChallengeOutcome.Kind.GAIN_CARD:
			if not outcome.card_pool.is_empty():
				var card: CardData = RngUtil.pick(outcome.card_pool, rng) as CardData
				run.gain_card(card)
				result.gained_cards.append(card)


static func _card_to_lose(run: DungeonRun, rng: RandomNumberGenerator, result: ChallengeResult, sacrificed: CardData) -> CardData:
	if sacrificed != null:
		return sacrificed
	var best: CardData = null
	for card: CardData in result.revealed:
		if card.is_basic or not run.current_deck().cards.has(card):
			continue
		if best == null or card.mana_value() > best.mana_value():
			best = card
	if best != null:
		return best
	var candidates: Array[CardData] = []
	for card: CardData in run.current_deck().cards:
		if not card.is_basic:
			candidates.append(card)
	if candidates.is_empty():
		return null
	return RngUtil.pick(candidates, rng) as CardData


static func _reveal(cards: Array[CardData], count: int, rng: RandomNumberGenerator) -> Array[CardData]:
	var shuffled: Array[CardData] = cards.duplicate()
	RngUtil.shuffle(shuffled, rng)
	var revealed: Array[CardData] = []
	for i: int in range(mini(count, shuffled.size())):
		revealed.append(shuffled[i])
	return revealed


static func _count(cards: Array[CardData], predicate: Callable) -> int:
	var total: int = 0
	for card: CardData in cards:
		if bool(predicate.call(card)):
			total += 1
	return total


static func _cheapest_non_basic(cards: Array[CardData]) -> CardData:
	var best: CardData = null
	for card: CardData in cards:
		if card.is_basic:
			continue
		if best == null or card.mana_value() < best.mana_value():
			best = card
	return best
