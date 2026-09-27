class_name RewardOffer
extends RefCounted
## What a victory offers: gold plus a choice of one card (or none).

var gold: int = 0
var cards: Array[CardData] = []
var is_boss: bool = false
var enemy_name: String = ""
var taken: CardData = null
