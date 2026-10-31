class_name ChallengeResolver
extends RefCounted
## Resolves a ChallengeData against a DungeonRun: reveals cards from the (shuffled) current deck,
## decides success, then applies the outcomes to the run.


## Fresh eyes round 2 (Oct 31): "1 of the 5 cards was Infrastructure; 2 were needed." - the verb agrees with its number.
static func _were(count: int) -> String:
	return "was" if count == 1 else "were"


## Fresh eyes Oct 30: the outcome in numbers, so the player learns the rule ("3 of the 5 were Infrastructure; 3 were needed."). "" for
## the challenge kinds whose outcome is the player's own choice.
static func explain(challenge: ChallengeData, result: ChallengeResult) -> String:
	var shown: int = result.revealed.size()
	match challenge.kind:
		ChallengeData.Kind.FIRST_UNIT_ATTACK:
			for card: CardData in result.revealed:
				if card.is_unit():
					return "The first unit to come up was %s, with %d attack; %d was needed." % [card.display_name, card.attack, challenge.threshold]
			return "No unit came up; one with %d attack was needed." % challenge.threshold
		ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT:
			var count: int = _count(result.revealed, func(c: CardData) -> bool: return c.is_infrastructure())
			return "%d of the %d cards %s Infrastructure; %d %s needed." % [count, shown, _were(count), challenge.threshold, _were(challenge.threshold)]
		ChallengeData.Kind.TOP_N_TYPE_COUNT:
			var wanted: CardEnums.CardType = challenge.card_type
			var count: int = _count(result.revealed, func(c: CardData) -> bool: return c.type == wanted)
			return "%d of the %d cards %s %s cards; %d %s needed." % [count, shown, _were(count), str(CardEnums.CardType.keys()[wanted]).capitalize(), challenge.threshold, _were(challenge.threshold)]
		ChallengeData.Kind.TOP_N_TOTAL_COST:
			var total: int = 0
			for card: CardData in result.revealed:
				total += card.energy_value()
			return "The %d cards cost %d energy together; %d was needed." % [shown, total, challenge.threshold]
	return ""


## True when a passed challenge's reward list holds a heal (so "nothing changes" at full HP can say why).
static func heals_on_success(challenge: ChallengeData) -> bool:
	for outcome: ChallengeOutcome in challenge.on_success:
		if outcome.kind == ChallengeOutcome.Kind.HEAL:
			return true
	return false


## Cards Oct 27, Part 3: `to_deck` = a won card also joins the run's deck (the tutorial cave); otherwise it is only reported in
## `gained_cards` for the caller to add to the collection.
static func resolve(
	challenge: ChallengeData,
	run: DungeonRun,
	rng: RandomNumberGenerator,
	choice: ChallengeChoice = null,
	to_deck: bool = true,
) -> ChallengeResult:
	var picked: ChallengeChoice = choice if choice != null else ChallengeChoice.new()
	var result: ChallengeResult = ChallengeResult.new()
	result.challenge_id = challenge.id
	var deck_cards: Array[CardData] = run.current_deck().cards
	var sacrificed: CardData = null
	match challenge.kind:
		ChallengeData.Kind.FIRST_UNIT_ATTACK:
			var shuffled: Array[CardData] = deck_cards.duplicate()
			RngUtil.shuffle(shuffled, rng)
			for card: CardData in shuffled:
				result.revealed.append(card)
				if card.is_unit():
					result.success = card.attack >= challenge.threshold
					break
		ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			result.success = _count(result.revealed, func(c: CardData) -> bool: return c.is_infrastructure()) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TYPE_COUNT:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			var wanted: CardEnums.CardType = challenge.card_type
			result.success = _count(result.revealed, func(c: CardData) -> bool: return c.type == wanted) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TOTAL_COST:
			result.revealed = _reveal(deck_cards, challenge.reveal_count, rng)
			var total: int = 0
			for card: CardData in result.revealed:
				total += card.energy_value()
			result.success = total >= challenge.threshold
		ChallengeData.Kind.SACRIFICE_CARD:
			sacrificed = picked.sacrifice_card
			if sacrificed != null and not deck_cards.has(sacrificed):
				sacrificed = null
			if sacrificed == null:
				sacrificed = _cheapest_non_basic(deck_cards)
			result.success = sacrificed != null
		ChallengeData.Kind.PAY_HP:
			if not picked.accept or run.hp <= challenge.threshold:
				result.declined = true
				return result
			result.success = true
	var outcomes: Array[ChallengeOutcome] = challenge.on_success if result.success else challenge.on_failure
	for outcome: ChallengeOutcome in outcomes:
		_apply(outcome, run, rng, result, sacrificed, to_deck)
	return result


static func _apply(
	outcome: ChallengeOutcome,
	run: DungeonRun,
	rng: RandomNumberGenerator,
	result: ChallengeResult,
	sacrificed: CardData,
	to_deck: bool = true,
) -> void:
	result.outcomes.append(outcome)
	match outcome.kind:
		ChallengeOutcome.Kind.LOSE_HP:
			var before: int = run.hp
			run.lose_hp(outcome.amount)
			result.hp_lost += before - run.hp
		ChallengeOutcome.Kind.HEAL:
			var before: int = run.hp
			run.heal(outcome.amount)
			result.hp_healed += run.hp - before
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
				if to_deck:
					run.gain_card(card)
				result.gained_cards.append(card)


static func _card_to_lose(run: DungeonRun, rng: RandomNumberGenerator, result: ChallengeResult, sacrificed: CardData) -> CardData:
	if sacrificed != null:
		return sacrificed
	var best: CardData = null
	for card: CardData in result.revealed:
		if card.is_basic or not run.current_deck().cards.has(card):
			continue
		if best == null or card.energy_value() > best.energy_value():
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
		if best == null or card.energy_value() < best.energy_value():
			best = card
	return best
