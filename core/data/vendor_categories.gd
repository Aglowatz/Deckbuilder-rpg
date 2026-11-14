class_name VendorCategories
extends RefCounted
## Overnight Oct 17, Part 2: what a vendor sells, as categories. A vendor with more than one category opens on a category
## selection screen first (`VendorScreen`); a single-category vendor goes straight to its goods. Pure data: no scene tree.

## Fable Nov 14 (Part 2): ITEMS - Fig Sly sells his supplies from his own shop (the crate beside him is gone).
enum Kind { CARDS, PACKS, GEAR, COSMETICS, ITEMS }

const LABELS: Dictionary = {
	Kind.CARDS: "Cards",
	Kind.PACKS: "Card Packs",
	Kind.GEAR: "Gear",
	Kind.COSMETICS: "Cosmetics",
	Kind.ITEMS: "Items",
}
const BLURBS: Dictionary = {
	Kind.CARDS: "Single cards for your deck",
	Kind.PACKS: "Sealed packs of three",
	Kind.GEAR: "Equipment for your slots",
	Kind.COSMETICS: "Hats, cloaks and dyes",
	Kind.ITEMS: "Supplies to use in battle",
}
const ICONS: Dictionary = {
	Kind.CARDS: "ICON-UI-COLLECTION",
	Kind.PACKS: "ICON-UI-PACKS",
	Kind.GEAR: "ICON-UI-INVENTORY",
	Kind.COSMETICS: "ICON-UI-WARDROBE",
	Kind.ITEMS: "ICON-ITEM-HEALINGDRAUGHT",
}


## The categories a vendor offers, in display order.
static func list(sells_cards: bool, sells_packs: bool, sells_gear: bool, sells_cosmetics: bool = false, sells_items: bool = false) -> Array[Kind]:
	var result: Array[Kind] = []
	if sells_cards:
		result.append(Kind.CARDS)
	if sells_items:
		result.append(Kind.ITEMS)  # beside the cards
	if sells_packs:
		result.append(Kind.PACKS)
	if sells_gear:
		result.append(Kind.GEAR)
	if sells_cosmetics:
		result.append(Kind.COSMETICS)
	return result


## True when the vendor should open on the category selection screen.
static func needs_picker(categories: Array[Kind]) -> bool:
	return categories.size() > 1


static func label(kind: Kind) -> String:
	return str(LABELS.get(kind, "Goods"))


static func blurb(kind: Kind) -> String:
	return str(BLURBS.get(kind, ""))


static func icon(kind: Kind) -> String:
	return str(ICONS.get(kind, ""))
