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


## Fable Nov 12c (A1): why a RANDOM_SACRIFICE offer (the Hollow Well) cannot be taken right now. NONE = it can.
enum Block { NONE, USED, FULL_HP, MIN_DECK }


static func offer_block(challenge: ChallengeData, run: DungeonRun) -> Block:
	if challenge == null or run == null or challenge.kind != ChallengeData.Kind.RANDOM_SACRIFICE:
		return Block.NONE
	if run.used_challenges.has(challenge.id):
		return Block.USED
	if run.current_deck().size() <= run.min_deck_size():
		return Block.MIN_DECK
	if run.hp >= run.max_hp() and heals_on_success(challenge):
		return Block.FULL_HP
	return Block.NONE


## The button's words and the line under it for a blocked offer ("" when it is open).
static func block_button_text(block: Block) -> String:
	match block:
		Block.USED:
			return "Already given"
		Block.FULL_HP:
			return "You're at full HP"
		Block.MIN_DECK:
			return "Your deck is too small"
	return ""


static func block_reason(block: Block, run: DungeonRun) -> String:
	match block:
		Block.USED:
			return "The well takes one card in each run of this dungeon, and it has had yours."
		Block.FULL_HP:
			return "You have nothing to mend, so the well asks for nothing."
		Block.MIN_DECK:
			return "A dungeon deck needs at least %d cards and yours has exactly that many, so the well can't take one." % (run.min_deck_size() if run != null else DeckValidator.MIN_DECK_SIZE)
	return ""


## The HP a taken offer would give back right now (the heal, capped at max HP).
static func heal_preview(challenge: ChallengeData, run: DungeonRun) -> int:
	var total: int = 0
	for outcome: ChallengeOutcome in challenge.on_success:
		if outcome.kind == ChallengeOutcome.Kind.HEAL:
			total += outcome.amount
	return clampi(total, 0, maxi(0, run.max_hp() - run.hp)) if run != null else total


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
		ChallengeData.Kind.RANDOM_SACRIFICE:
			if not picked.accept or offer_block(challenge, run) != Block.NONE:
				result.declined = true
				return result
			sacrificed = RngUtil.pick(deck_cards, rng) as CardData
			result.success = sacrificed != null
			if result.success:
				run.used_challenges.append(challenge.id)
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


## Overnight Oct 31 - Nov 1 (mid-game critic #9: "it never says what is tested"): the test in numbers, shown before the reveal.
static func rule_text(challenge: ChallengeData) -> String:
	match challenge.kind:
		ChallengeData.Kind.FIRST_UNIT_ATTACK:
			return "The test: the first unit drawn from your deck needs %d+ attack." % challenge.threshold
		ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT:
			return "The test: draw %d cards from your deck - %d+ must be Infrastructure." % [challenge.reveal_count, challenge.threshold]
		ChallengeData.Kind.TOP_N_TYPE_COUNT:
			return "The test: draw %d cards from your deck - %d+ must be %s cards." % [challenge.reveal_count, challenge.threshold, str(CardEnums.CardType.keys()[challenge.card_type]).capitalize()]
		ChallengeData.Kind.TOP_N_TOTAL_COST:
			return "The test: draw %d cards from your deck - together they must cost %d+ energy." % [challenge.reveal_count, challenge.threshold]
	return ""


## Whether `revealed` (in draw order) passes the challenge's test - the same rule `resolve` applies.
static func passes(challenge: ChallengeData, revealed: Array[CardData]) -> bool:
	match challenge.kind:
		ChallengeData.Kind.FIRST_UNIT_ATTACK:
			for card: CardData in revealed:
				if card.is_unit():
					return card.attack >= challenge.threshold
			return false
		ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT:
			return _count(revealed, func(c: CardData) -> bool: return c.is_infrastructure()) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TYPE_COUNT:
			var wanted: CardEnums.CardType = challenge.card_type
			return _count(revealed, func(c: CardData) -> bool: return c.type == wanted) >= challenge.threshold
		ChallengeData.Kind.TOP_N_TOTAL_COST:
			var total: int = 0
			for card: CardData in revealed:
				total += card.energy_value()
			return total >= challenge.threshold
	return false


## The chance (0..1) that `deck` passes, from `trials` shuffles (a fixed seed: the same deck always shows the same odds).
static func odds(challenge: ChallengeData, deck: Array[CardData], trials: int = 600) -> float:
	if deck.is_empty():
		return 0.0
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var wins: int = 0
	var count: int = deck.size() if challenge.kind == ChallengeData.Kind.FIRST_UNIT_ATTACK else mini(challenge.reveal_count, deck.size())
	for _trial: int in range(trials):
		var shuffled: Array[CardData] = deck.duplicate()
		RngUtil.shuffle(shuffled, rng)
		if passes(challenge, shuffled.slice(0, count)):
			wins += 1
	return float(wins) / float(trials)
