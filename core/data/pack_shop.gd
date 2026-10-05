class_name PackShop
extends RefCounted
## What each vendor's pack stock looks like at a given point of progress. Pure `core/` logic over `UnlockState`.

## Vendors that sell packs, with the pack vendors' shared stock rules in one place.
const VENDORS: Array[String] = [PackData.VENDOR_PACK, PackData.VENDOR_CARD, PackData.VENDOR_BLACK_MARKET]


## General Pack tier 2 (and the card vendor's expanded selection): the set level OR enough freed zones, whichever comes first.
static func tier2_unlocked(state: UnlockState) -> bool:
	var config: PackConfig = PackCatalog.config()
	return state.player_level >= config.tier2_level or state.zones_completed >= config.tier2_zones


## The same rule as a `Condition` (for the vendor's stock entries).
static func tier2_condition() -> Condition:
	var config: PackConfig = PackCatalog.config()
	return Condition.any_of([Condition.player_level(config.tier2_level), Condition.zones_completed(config.tier2_zones)] as Array[Condition])


## Whether the vendor currently stocks `pack` (false = shown only as a teaser).
static func is_unlocked(pack: PackData, state: UnlockState) -> bool:
	if pack.kind == PackData.Kind.GENERAL and pack.general_tier >= 2 and not tier2_unlocked(state):
		return false
	return Condition.met(pack.unlock, state)


## Every pack a vendor lists (stocked ones and teasers), in shop order.
static func listing(vendor: String) -> Array[PackData]:
	return PackCatalog.sold_by(vendor)


## Packs the vendor stocks right now.
static func stocked(vendor: String, state: UnlockState) -> Array[PackData]:
	var result: Array[PackData] = []
	for pack: PackData in listing(vendor):
		if is_unlocked(pack, state):
			result.append(pack)
	return result


## Whether a locked pack should be listed at all. The Pack Vendor's Prismatic Pack stays hidden until the postgame; everything else
## is a teaser until it unlocks.
static func is_visible(pack: PackData, state: UnlockState) -> bool:
	if pack.kind == PackData.Kind.PRISMATIC:
		return is_unlocked(pack, state)
	return true


## What a pack costs after the player's vendor discount.
static func price_for(pack: PackData, profile: PlayerProfile) -> int:
	return profile.discounted_price(pack.price) if profile != null else pack.price


## A one-line player-facing summary of what a pack holds (built from its data, so it follows any tuning).
static func describe(pack: PackData) -> String:
	var parts: PackedStringArray = []
	match pack.kind:
		PackData.Kind.PATH:
			parts.append("%d cards: %s cards and neutral cards." % [pack.card_count, Affinity.display_name(pack.path)])
		PackData.Kind.GILDED:
			parts.append("%d cards: %s cards and neutral cards. An Epic or Legendary is guaranteed." % [pack.card_count, Affinity.display_name(pack.path)])
		PackData.Kind.PRISMATIC:
			parts.append("%d cards from any Path, multi-Path cards included. One multi-Path card is guaranteed." % pack.card_count)
		PackData.Kind.GENERAL:
			if pack.max_rarity < CardEnums.Rarity.EPIC:
				parts.append("%d cards from the stall's selection: Commons and Uncommons." % pack.card_count)
			else:
				parts.append("%d cards from the stall's whole selection, up to Legendary." % pack.card_count)
	return " ".join(parts)
