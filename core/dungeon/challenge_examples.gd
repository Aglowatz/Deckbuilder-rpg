class_name ChallengeExamples
extends RefCounted
## Six example challenges covering every ChallengeData.Kind. The content generator saves these
## as .tres files in data/encounters/challenges/; tests build them directly.


static func all(reward_pool: Array[CardData]) -> Array[ChallengeData]:
	var result: Array[ChallengeData] = []
	result.append(test_of_might())
	result.append(hollow_well())
	result.append(scholars_riddle(reward_pool))
	result.append(weighing_scale())
	result.append(altar_of_sacrifice())
	result.append(toll_keeper(reward_pool))
	return result


static func _boon(name: String, kind: Modifier.Kind, value: int) -> ModifierSource:
	return CardBuilder.modifier_source(name, ModifierSource.SourceKind.BOON, [CardBuilder.modifier(kind, value)] as Array[Modifier])


static func _outcome(kind: ChallengeOutcome.Kind, amount: int = 0, text: String = "") -> ChallengeOutcome:
	var outcome: ChallengeOutcome = ChallengeOutcome.make(kind, amount)
	outcome.description = text
	return outcome


static func _challenge(id: String, title: String, text: String, kind: ChallengeData.Kind, count: int, threshold: int) -> ChallengeData:
	var challenge: ChallengeData = ChallengeData.new()
	challenge.id = id
	challenge.display_name = title
	challenge.description = text
	challenge.kind = kind
	challenge.reveal_count = count
	challenge.threshold = threshold
	return challenge


## Reveal the first unit in your deck: attack 3+ wins a boon, otherwise lose 3 HP.
static func test_of_might() -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"test_of_might", "Test of Might",
		"The statue demands proof of strength. Its gaze finds your first unit: is it mighty enough?",
		ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3,
	)
	var boon: ChallengeOutcome = _outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +2 max HP for the dungeon.")
	boon.boon = _boon("Blessing of Might", Modifier.Kind.MAX_HP, 2)
	challenge.on_success = [boon] as Array[ChallengeOutcome]
	challenge.on_failure = [_outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	return challenge


## Reveal the top 5 cards: 2+ infrastructure heals 4 HP, otherwise the well takes a card.
static func hollow_well() -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"hollow_well", "The Hollow Well",
		"Five cards fall into the well. If enough of them are infrastructure, it answers with water.",
		ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT, 5, 2,
	)
	challenge.on_success = [_outcome(ChallengeOutcome.Kind.HEAL, 4, "Heal 4 HP.")] as Array[ChallengeOutcome]
	challenge.on_failure = [_outcome(ChallengeOutcome.Kind.LOSE_CARD, 0, "Lose a card for the dungeon.")] as Array[ChallengeOutcome]
	return challenge


## Reveal the top 4: at least one spell wins a card from the pool; otherwise lose 2 HP.
static func scholars_riddle(reward_pool: Array[CardData]) -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"scholars_riddle", "Scholar's Riddle",
		"The scholar will reward anyone who shows a spell among four drawn cards.",
		ChallengeData.Kind.TOP_N_TYPE_COUNT, 4, 1,
	)
	challenge.card_type = CardEnums.CardType.SPELL
	var reward: ChallengeOutcome = _outcome(ChallengeOutcome.Kind.GAIN_CARD, 0, "Gain a card for the dungeon.")
	reward.card_pool = reward_pool.duplicate()
	challenge.on_success = [reward] as Array[ChallengeOutcome]
	challenge.on_failure = [_outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP.")] as Array[ChallengeOutcome]
	return challenge


## Reveal the top 3: total energy value 7+ tips the scale in your favour (+1 hand size).
static func weighing_scale() -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"weighing_scale", "The Weighing Scale",
		"Three cards are placed on the scale. It rewards a heavy total.",
		ChallengeData.Kind.TOP_N_TOTAL_COST, 3, 7,
	)
	var boon: ChallengeOutcome = _outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +1 max hand size for the dungeon.")
	boon.boon = _boon("Heavy Purse", Modifier.Kind.MAX_HAND_SIZE, 1)
	challenge.on_success = [boon] as Array[ChallengeOutcome]
	challenge.on_failure = [_outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP.")] as Array[ChallengeOutcome]
	return challenge


## Sacrifice a card of your choice for +3 max HP (and a matching heal).
static func altar_of_sacrifice() -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"altar_of_sacrifice", "Altar of Sacrifice",
		"Give up one card from your deck and the altar will strengthen you.",
		ChallengeData.Kind.SACRIFICE_CARD, 0, 0,
	)
	var boon: ChallengeOutcome = _outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +3 max HP for the dungeon.")
	boon.boon = _boon("Altar's Favor", Modifier.Kind.MAX_HP, 3)
	challenge.on_success = [_outcome(ChallengeOutcome.Kind.LOSE_CARD, 0, "The sacrificed card is lost."), boon] as Array[ChallengeOutcome]
	return challenge


## Pay 4 HP (if you can spare it) to gain a card from the pool.
static func toll_keeper(reward_pool: Array[CardData]) -> ChallengeData:
	var challenge: ChallengeData = _challenge(
		"toll_keeper", "The Toll Keeper",
		"Pay in blood and pass with a prize; refuse and walk on with nothing.",
		ChallengeData.Kind.PAY_HP, 0, 4,
	)
	var reward: ChallengeOutcome = _outcome(ChallengeOutcome.Kind.GAIN_CARD, 0, "Gain a card for the dungeon.")
	reward.card_pool = reward_pool.duplicate()
	challenge.on_success = [_outcome(ChallengeOutcome.Kind.LOSE_HP, 4, "Lose 4 HP."), reward] as Array[ChallengeOutcome]
	return challenge
