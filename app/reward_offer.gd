class_name RewardOffer
extends RefCounted
## What a victory offers: gold, XP (Part E) and a choice of one card (or none).

var gold: int = 0
var xp: int = 0
var cards: Array[CardData] = []
var is_boss: bool = false
var enemy_name: String = ""
var taken: CardData = null
## Levels gained from `xp` (Part E), in order, if applying it leveled the player up. Filled in by
## Session.complete_battle so the rewards screen can show a level-up recap alongside the card pick.
var levels_gained: Array[LevelData] = []
