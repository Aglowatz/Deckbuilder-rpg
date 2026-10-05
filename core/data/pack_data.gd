class_name PackData
extends Resource
## A card pack, as data (`data/packs/<id>.tres`, written once by `PackDefinitions`; after that the .tres is the thing to
## tune). Pool rules, rarity weights, guarantees, price and where it is sold are all fields here - nothing about packs
## is hardcoded in the roller. Display text for vendors/hints lives in the story data (`pack.*` keys), not here.

enum Kind {
	## One Path's pack-eligible cards plus neutral cards.
	PATH,
	## A premium Path pack with a guaranteed Epic or Legendary.
	GILDED,
	## Postgame: any Path, multi-Path cards included (one is guaranteed).
	PRISMATIC,
	## Any Path, but only from the town card vendor's selection (two tiers).
	GENERAL,
}

## Vendors that can sell a pack (`sold_by`).
const VENDOR_PACK: String = "pack_vendor"
const VENDOR_CARD: String = "card_vendor"
const VENDOR_BLACK_MARKET: String = "black_market"

@export var id: String = ""
@export var display_name: String = ""
@export var kind: Kind = Kind.PATH
## The Path of a PATH / GILDED pack (NEUTRAL for the others).
@export var path: Affinity.Type = Affinity.Type.NEUTRAL
## GENERAL packs: 1 (initial selection) or 2 (expanded selection).
@export var general_tier: int = 0
## How many cards the pack holds.
@export var card_count: int = 3
## Relative odds per rarity, in `CardEnums.Rarity` order: Common, Uncommon, Epic, Legendary.
@export var rarity_weights: Array[int] = [60, 28, 10, 2]
## Guarantees (a replaced slot is re-rolled so the pack always satisfies them).
@export var guarantee_epic_or_legendary: bool = false
@export var guarantee_multipath: bool = false

# ---- Card pool rules ----
## Single-Path cards of these Paths are in the pool (empty = every Path).
@export var pool_paths: Array[Affinity.Type] = []
@export var include_neutral: bool = true
@export var include_multipath: bool = false
## Only cards of rarity min..max are in the pool.
@export var min_rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON
@export var max_rarity: CardEnums.Rarity = CardEnums.Rarity.LEGENDARY
## True = the pool is the town card vendor's selection (the base card set) instead of every pack-eligible card.
@export var vendor_selection_only: bool = false

# ---- Presentation ----
## Foil colour of the pack art / frame.
@export var art_color: Color = Color(0.5, 0.5, 0.5)
## "plain", "foil", "gilded" or "prismatic" (`PackArt`).
@export var frame_style: String = "plain"
## A CardIcons glyph name shown on the pack.
@export var art_icon: String = ""

# ---- Shop ----
@export var price: int = 100
## Who sells it (`VENDOR_*`; empty = never sold, found only).
@export var sold_by: String = ""
## When the vendor stocks it. Until then it is shown as a teaser (story key `pack.hint.<id>`). Null = always.
@export var unlock: Condition = null  # General tier 2 is gated by `PackShop.tier2_unlocked` (PackConfig) instead
## Sort position in a shop.
@export var order: int = 100


func rarity_weight(rarity: CardEnums.Rarity) -> int:
	var index: int = int(rarity)
	return maxi(0, rarity_weights[index]) if index < rarity_weights.size() else 0


func is_path_pack() -> bool:
	return kind == Kind.PATH or kind == Kind.GILDED
