class_name ChallengeOutcome
extends Resource
## One consequence of a challenge, applied to the DungeonRun.

enum Kind {
	NOTHING,
	## amount = HP lost.
	LOSE_HP,
	## amount = HP restored (capped at max HP).
	HEAL,
	## A card is lost for the dungeon: the sacrificed card, else the priciest revealed
	## non-basic card, else a random non-basic card from the deck.
	LOSE_CARD,
	## `boon` is added to the run's dungeon modifiers.
	GAIN_BOON,
	## A random card from `card_pool` is added to the deck for the dungeon.
	GAIN_CARD,
}

@export var kind: Kind = Kind.NOTHING
@export var amount: int = 0
@export var boon: ModifierSource
@export var card_pool: Array[CardData] = []
@export var description: String = ""


static func make(outcome_kind: Kind, outcome_amount: int = 0) -> ChallengeOutcome:
	var outcome: ChallengeOutcome = ChallengeOutcome.new()
	outcome.kind = outcome_kind
	outcome.amount = outcome_amount
	return outcome
