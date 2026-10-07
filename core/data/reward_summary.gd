class_name RewardSummary
extends RefCounted
## Everything one event handed the player (a chest, a finished quest), as plain data the reward popup draws: gold, XP, cards (with their art),
## items, equipment, unopened packs, cosmetics, and for quests what the completion unlocked or opened up. Built by `Session` when the reward is
## granted; the UI only reads it.

enum Kind { CHEST, QUEST }

var kind: Kind = Kind.CHEST
## The quest's name, or the chest's label ("Hidden chest").
var title: String = ""
## A line under the header ("You found a hidden chest!").
var subtitle: String = ""
var gold: int = 0
var xp: int = 0
var cards: Array[CardData] = []
var items: Array[ItemData] = []
var equipment: Array[EquipmentData] = []
## One entry per pack kind: {"id": String, "name": String, "count": int}.
var packs: Array[Dictionary] = []
## Display names of the cosmetics (hats, cloaks) granted.
var cosmetics: Array[String] = []
## "The Gainlands entrance is now open", "New stock at the Equipment Vendor", ...
var unlocks: Array[String] = []
## The player reached these levels from this reward (the level-up popup follows the quest box).
var levels_reached: Array[int] = []


func add_pack(pack_id: String, pack_name: String, count: int = 1) -> void:
	for entry: Dictionary in packs:
		if str(entry["id"]) == pack_id:
			entry["count"] = int(entry["count"]) + count
			return
	packs.append({"id": pack_id, "name": pack_name, "count": count})


## True when nothing at all was handed over (a quest with no reward still has a popup, so the popup copes with this).
func is_empty() -> bool:
	return gold <= 0 and xp <= 0 and cards.is_empty() and items.is_empty() and equipment.is_empty() and packs.is_empty() and cosmetics.is_empty()


## One short line per reward, in the order the popup shows them (also what the tests and the toast fallback read).
func lines() -> Array[String]:
	var result: Array[String] = []
	if gold > 0:
		result.append("%d gold" % gold)
	if xp > 0:
		result.append("%d XP" % xp)
	for card: CardData in cards:
		result.append(card.display_name)
	for item: ItemData in items:
		result.append(item.display_name)
	for piece: EquipmentData in equipment:
		result.append(piece.source_name)
	for entry: Dictionary in packs:
		var count: int = int(entry["count"])
		result.append(str(entry["name"]) if count == 1 else "%dx %s" % [count, str(entry["name"])])
	for cosmetic: String in cosmetics:
		result.append(cosmetic)
	return result
