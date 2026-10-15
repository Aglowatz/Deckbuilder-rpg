class_name ZoneShrine
extends RefCounted
## A shrine in a zone (SR-7, the one reward kind kept from the removed sub-areas): one offering per campaign, paid from the zone's own chest table
## (`ZoneDef.chest_rewards`) so the economy does not move (docs/design/progression.md): a card entry when the table has one, otherwise a little gold.
## Equipment, cosmetics and packs are never drawn (those are one-of-a-kind finds of the hidden chests). Deterministic per shrine key. Pure data: no scene tree.

const FALLBACK_GOLD: int = 40


## The flag set once the shrine has been used.
static func flag(zone_id: String, spot_id: String) -> StringName:
	return StringName("shrine_%s_%s" % [zone_id, spot_id])


## The offering: {"card": id} drawn from the card entries of `chest_rewards` (sorted by chest id, picked by the hash of `key`), or {"gold": FALLBACK_GOLD}.
static func reward(chest_rewards: Dictionary, key: String) -> Dictionary:
	var cards: Array[String] = card_pool(chest_rewards)
	if cards.is_empty():
		return {"gold": FALLBACK_GOLD}
	return {"card": cards[absi(hash(key)) % cards.size()]}


## The card ids a shrine may give: every table entry with a card and nothing one-of-a-kind, in chest-id order.
static func card_pool(chest_rewards: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var ids: Array = chest_rewards.keys()
	ids.sort()
	for id: Variant in ids:
		var entry: Dictionary = chest_rewards[id] as Dictionary
		if str(entry.get("card", "")) == "":
			continue
		if entry.has("equipment") or entry.has("cosmetic") or entry.has("pack"):
			continue
		result.append(str(entry["card"]))
	return result
