class_name CopyCaps
extends RefCounted
## Overnight Oct 17, Part 1: how many copies of a card the player may own and put in a deck. Never more than
## `ABSOLUTE_MAX` (3); rarer cards start lower (Common 3, Uncommon 2, Epic 1, Legendary 1) and level-ups raise their caps
## toward 3 (`data/progression/level_track.json`, section "copy_caps"). Infrastructure is unlimited and tokens never go in a
## deck. The same cap rules the shop, packs and rewards (an extra copy converts, `Essence`), the deck builder and saved decks.

const ABSOLUTE_MAX: int = 3
## What `for_card` returns for infrastructure (no cap).
const UNLIMITED: int = 9999
const _FALLBACK_START: Array[int] = [3, 2, 1, 1]


static func absolute_max() -> int:
	return mini(ABSOLUTE_MAX, int(LevelTrack.section("copy_caps").get("absolute_max", ABSOLUTE_MAX)))


static func start_cap(rarity: CardEnums.Rarity) -> int:
	var start: Dictionary = LevelTrack.section("copy_caps").get("start", {}) as Dictionary
	var key: String = LevelTrack.rarity_key(rarity)
	return mini(absolute_max(), int(start.get(key, _FALLBACK_START[int(rarity)])))


## The raises in level order: [{level, rarity (int), cap}].
static func raises() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in LevelTrack.section("copy_caps").get("raises", []) as Array:
		var row: Dictionary = entry as Dictionary
		var rarity: int = LevelTrack.rarity_from_key(str(row.get("rarity", "")))
		if rarity < 0:
			continue
		result.append({"level": int(row.get("level", 1)), "rarity": rarity, "cap": mini(absolute_max(), int(row.get("cap", 1)))})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["level"]) < int(b["level"]))
	return result


## The copy cap of a rarity at a player level.
static func cap_for(rarity: CardEnums.Rarity, level: int) -> int:
	var cap: int = start_cap(rarity)
	for row: Dictionary in raises():
		if int(row["rarity"]) == int(rarity) and level >= int(row["level"]):
			cap = maxi(cap, int(row["cap"]))
	return cap


## The copy cap of a card at a player level (infrastructure: UNLIMITED, tokens: 0).
static func for_card(card: CardData, level: int) -> int:
	if card == null or card.is_token:
		return 0
	if card.is_unlimited():
		return UNLIMITED
	return cap_for(card.rarity, level)


## The next level that raises a rarity's cap: {level, cap}, or {} when it is already at its highest.
static func next_raise(rarity: CardEnums.Rarity, level: int) -> Dictionary:
	var current: int = cap_for(rarity, level)
	for row: Dictionary in raises():
		if int(row["rarity"]) == int(rarity) and int(row["level"]) > level and int(row["cap"]) > current:
			return {"level": int(row["level"]), "cap": int(row["cap"])}
	return {}


## The raises gained exactly at `level` (the level-up screen lists them): [{rarity, cap}].
static func raises_at(level: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Dictionary in raises():
		if int(row["level"]) == level:
			result.append({"rarity": int(row["rarity"]), "cap": int(row["cap"])})
	return result


static func rarity_name(rarity: CardEnums.Rarity) -> String:
	return LevelTrack.rarity_key(rarity).capitalize()


## The copies in `cards` beyond each card's cap at `level` (the later copies; infrastructure never). Used by the save
## migration: an old collection could hold 4 of a card.
static func excess(cards: Array[CardData], level: int) -> Array[CardData]:
	var seen: Dictionary = {}
	var result: Array[CardData] = []
	for card: CardData in cards:
		if card == null or card.is_unlimited():
			continue
		var have: int = int(seen.get(card.id, 0)) + 1
		seen[card.id] = have
		if have > for_card(card, level):
			result.append(card)
	return result


## A saved deck's card ids with every copy beyond its cap dropped (the first copies stay, order kept). Unknown ids stay.
static func trim_ids(ids: Array[String], lookup: Callable, level: int) -> Array[String]:
	var seen: Dictionary = {}
	var result: Array[String] = []
	for id: String in ids:
		var card: CardData = lookup.call(id) as CardData
		if card != null and not card.is_unlimited():
			var have: int = int(seen.get(id, 0)) + 1
			seen[id] = have
			if have > for_card(card, level):
				continue
		result.append(id)
	return result


## "x/cap" for a card (an empty string for infrastructure).
static func ratio_text(have: int, card: CardData, level: int) -> String:
	if card == null or card.is_unlimited():
		return ""
	return "%d/%d" % [have, for_card(card, level)]


## Why no further copy of `card` is allowed at `level`: "Epic cards: 1 copy each for now (2 at level 12)." /
## "3 copies is the most of any card."
static func reason(card: CardData, level: int) -> String:
	var cap: int = for_card(card, level)
	if cap >= absolute_max():
		return "%d copies is the most any deck or collection can hold of one card." % absolute_max()
	var text: String = "%s cards: %d %s each for now" % [rarity_name(card.rarity), cap, "copy" if cap == 1 else "copies"]
	var next: Dictionary = next_raise(card.rarity, level)
	if not next.is_empty():
		text += " (%d at level %d)" % [int(next["cap"]), int(next["level"])]
	return text + "."
