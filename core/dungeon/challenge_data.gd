class_name ChallengeData
extends Resource
## A deck-based challenge, defined as data (stored as .tres in data/encounters/challenges/).

enum Kind {
	## Reveal cards until the first creature; success if its power >= threshold.
	FIRST_CREATURE_POWER,
	## Reveal the top `reveal_count` cards; success if they hold >= threshold lands.
	TOP_N_LAND_COUNT,
	## Reveal the top `reveal_count` cards; success if >= threshold are of `card_type`.
	TOP_N_TYPE_COUNT,
	## Reveal the top `reveal_count` cards; success if their total mana value >= threshold.
	TOP_N_TOTAL_COST,
	## Sacrifice a card of your choice; success if the deck has a card to give.
	SACRIFICE_CARD,
	## Pay `threshold` life to accept; success if accepted and affordable.
	PAY_LIFE,
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var kind: Kind = Kind.FIRST_CREATURE_POWER
@export var reveal_count: int = 0
@export var threshold: int = 0
@export var card_type: CardEnums.CardType = CardEnums.CardType.SPELL
@export var on_success: Array[ChallengeOutcome] = []
@export var on_failure: Array[ChallengeOutcome] = []
