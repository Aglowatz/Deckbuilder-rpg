class_name GearText
extends RefCounted
## Fable big pass Nov 23 (Part 6.5): ONE display order for equipment and items, on every screen (the armory, the shops, the
## Character page, the draft picks, the reward screens and the tooltips):
##   1. the name;  2. the slot and the rarity ("Relic - Uncommon");  3. what it does;  4. the flavour text.
## The name is never repeated in the body, and what a piece does never runs together with its flavour. Screens ask this class for
## the four parts (or for the tooltip built from them) instead of gluing a piece's fields together themselves.

const KIND_DIVIDER: String = "  -  "


static func name_of(piece: EquipmentData) -> String:
	return piece.source_name if piece != null else ""


## "Relic  -  Uncommon".
static func kind_line(piece: EquipmentData) -> String:
	if piece == null:
		return ""
	return "%s%s%s" % [EquipmentData.slot_name(piece.slot), KIND_DIVIDER, EquipmentRarity.display_name(int(piece.rarity))]


## What the piece does: its rules text only.
static func effect(piece: EquipmentData) -> String:
	return piece.description.strip_edges() if piece != null else ""


static func flavour(piece: EquipmentData) -> String:
	return piece.flavor_text.strip_edges() if piece != null else ""


## The body under a name that is shown elsewhere (a card's title, a row's heading): kind, effect, flavour.
static func body(piece: EquipmentData) -> String:
	var lines: PackedStringArray = []
	for line: String in [kind_line(piece), effect(piece), flavour(piece)]:
		if not line.is_empty():
			lines.append(line)
	return "\n".join(lines)


## The whole tooltip: name, kind, effect, flavour, one line each.
static func tooltip(piece: EquipmentData) -> String:
	if piece == null:
		return ""
	return "%s\n%s" % [name_of(piece), body(piece)]


## "Item  -  single use" (the kind line of a consumable).
static func item_kind_line(item: ItemData) -> String:
	if item == null:
		return ""
	return "Item%s%s" % [KIND_DIVIDER, "single use" if item.uses <= 1 else "%d uses" % item.uses]


## What the item does, with its targeting note.
static func item_effect(item: ItemData) -> String:
	if item == null:
		return ""
	var text: String = item.description.strip_edges()
	if item.effect != null and not item.effect.target_requirement_text().is_empty():
		text += "\n%s" % item.effect.target_requirement_text()
	return text


static func item_tooltip(item: ItemData) -> String:
	if item == null:
		return ""
	return "%s\n%s\n%s" % [item.display_name, item_kind_line(item), item_effect(item)]
