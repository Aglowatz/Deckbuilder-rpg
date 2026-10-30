class_name RewardOffer
extends RefCounted
## What a victory offers: gold, XP (Part E) and a choice of one card (or none).

var gold: int = 0
var xp: int = 0
var cards: Array[CardData] = []
var is_boss: bool = false
var enemy_name: String = ""
var taken: CardData = null
## Overnight Oct 29, Phase 2: the pick may be rerolled once for gold (`Session.reroll_dungeon_pick`); `reroll` draws a fresh set.
var reroll: Callable = Callable()
var reroll_price: int = 0
var rerolled: bool = false


func can_reroll() -> bool:
	return reroll.is_valid() and not rerolled and reroll_price > 0 and not cards.is_empty()
## Levels gained from `xp` (Part E), in order, if applying it leveled the player up. Filled in by
## Session.complete_battle so the rewards screen can show a level-up recap alongside the card pick.
var levels_gained: Array[LevelData] = []
## Oct 19 (post-battle backgrounds): the battleboard context of the fight just won (BattleContext.board_key), so the rewards screen shows
## that place behind the panel. Empty: the rewards screen works it out from the dungeon being run.
var board_key: String = ""
