class_name Essence
extends RefCounted
## Brief 9, Part F: extra copies of a card (beyond the 4 a player may own - `DeckValidator.MAX_COPIES`) are not
## kept: they convert into **Path essence** of the card's Path, more for higher rarity. Extra copies of a
## NEUTRAL card have no Path, so they convert into gold instead. A multi-Path card's essence is split
## between its two Paths (half each, rounded up). Infrastructure is unlimited and never converts.
## Essence is spent at the Alchemist (`Alchemy`).

## Essence per extra copy by rarity (Common, Uncommon, Epic, Legendary).
const VALUE_BY_RARITY: Array[int] = [1, 2, 4, 8]
## Gold per extra neutral copy by rarity.
const GOLD_BY_RARITY: Array[int] = [15, 30, 60, 120]


static func value_for(rarity: CardEnums.Rarity) -> int:
	return VALUE_BY_RARITY[int(rarity)]


static func gold_for(rarity: CardEnums.Rarity) -> int:
	return GOLD_BY_RARITY[int(rarity)]


## What one extra copy of `card` converts into: {"essence": {Affinity.Type: amount}, "gold": int}.
static func conversion(card: CardData) -> Dictionary:
	var result: Dictionary = {"essence": {}, "gold": 0}
	var paths: Array[Affinity.Type] = card.paths()
	if paths.is_empty():
		result["gold"] = gold_for(card.rarity)
		return result
	var total: int = value_for(card.rarity)
	if paths.size() == 1:
		(result["essence"] as Dictionary)[paths[0]] = total
		return result
	var first: int = (total + 1) / 2
	(result["essence"] as Dictionary)[paths[0]] = first
	(result["essence"] as Dictionary)[paths[1]] = maxi(1, total - first)
	return result


## The player-facing notification for a conversion ("Extra copy of Firebolt converted into 2 Beefcake essence.").
static func message(card: CardData, conversion_result: Dictionary) -> String:
	var gold: int = int(conversion_result.get("gold", 0))
	if gold > 0:
		return "Extra copy of %s converted into %d gold." % [card.display_name, gold]
	var parts: PackedStringArray = []
	var essence: Dictionary = conversion_result.get("essence", {}) as Dictionary
	for path: Variant in essence.keys():
		parts.append("%d %s essence" % [int(essence[path]), Affinity.display_name(int(path) as Affinity.Type)])
	return "Extra copy of %s converted into %s." % [card.display_name, " and ".join(parts)]
