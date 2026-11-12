class_name ChallengeData
extends Resource
## A deck-based challenge, defined as data (stored as .tres in data/encounters/challenges/).

enum Kind {
	## Reveal cards until the first unit; success if its attack >= threshold.
	FIRST_UNIT_ATTACK,
	## Reveal the top `reveal_count` cards; success if they hold >= threshold infrastructure.
	TOP_N_INFRASTRUCTURE_COUNT,
	## Reveal the top `reveal_count` cards; success if >= threshold are of `card_type`.
	TOP_N_TYPE_COUNT,
	## Reveal the top `reveal_count` cards; success if their total energy value >= threshold.
	TOP_N_TOTAL_COST,
	## Sacrifice a card of your choice; success if the deck has a card to give.
	SACRIFICE_CARD,
	## Pay `threshold` HP to accept; success if accepted and affordable.
	PAY_HP,
	## Fable Nov 12c (A1, the Hollow Well): an offer the player may decline - a RANDOM card of the deck is given up for the rest of
	## this dungeon run (it returns when the run ends) for the `on_success` outcomes (a heal). Once per run; not offered at full HP or
	## with the deck at the minimum dungeon deck size (`ChallengeResolver.offer_block`).
	RANDOM_SACRIFICE,
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var kind: Kind = Kind.FIRST_UNIT_ATTACK
@export var reveal_count: int = 0
@export var threshold: int = 0
@export var card_type: CardEnums.CardType = CardEnums.CardType.SPELL
@export var on_success: Array[ChallengeOutcome] = []
@export var on_failure: Array[ChallengeOutcome] = []
