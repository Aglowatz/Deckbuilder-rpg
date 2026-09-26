class_name ChallengeChoice
extends RefCounted
## The player's decisions for challenges that ask for one.

## SACRIFICE_CARD: the card to give up (null = the engine offers the cheapest non-basic card).
var sacrifice_card: CardData = null
## PAY_LIFE: whether the player accepts the offer.
var accept: bool = true
