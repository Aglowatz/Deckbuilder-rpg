class_name GearText
extends RefCounted
## Fable big pass Nov 23 (Part 6.5): ONE display order for equipment and items, on every screen (the armory, the shops, the
## Character page, the draft picks, the reward screens and the tooltips):
##   1. the name;  2. the slot and the rarity ("Relic - Uncommon");  3. what it does;  4. the flavour text.
## The name is never repeated in the body, and what a piece does never runs together with its flavour. Screens ask this class for
## the four parts (or for the tooltip built from them) instead of gluing a piece's fields together themselves.

const KIND_DIVIDER: String = "  -  "


## The older pieces were written with a flavour sentence at the front of their rules text ("Alchemist's fire in a backpack tank.
## At the start of your turn..."), so the effect and the flavour ran together on every screen (the owner's screenshot of Siphon's
## Lens). `split_lead_in` moves that sentence to the flavour text, where the display order puts it last. Piece id -> the sentence.
const LEAD_INS: Dictionary = {
	"wicked_dagger": "A blade with a reputation it didn't earn honestly.",
	"earned_blade": "It finally did something to deserve the stories.",
	"flamethrower": "Alchemist's fire in a backpack tank.",
	"extra_pocket": "Sewn in where no one thinks to look.",
	"cheaters_dice": "They only ever land the way you need them to.",
	"travelers_boots": "Worn thin by roads longer than this one.",
	"hover_boots": "A finger's width of clearance, always.",
	"solid_plate": "Unglamorous, unyielding.",
	"thorned_loincloth": "Nobody enjoys being the one who has to remove this from a corpse.",
	"xray_goggles": "Everything looks the same underneath.",
	"big_brain_beret": "It itches, but it's undeniably working.",
	"courier_lanyard": "Everything is routed exactly where you need it.",
	"swole_belt": "Brace the core, brace the deck.",
	"head_chef_ladle": "Heavy, battered and trusted by a hundred golems.",
	"seed_satchel": "Every pocket holds something that wants to grow.",
	"siphons_lens": "A glass lens from the draining chamber, ground to see all four Paths at once.",
}


## Moves a piece's flavour lead-in out of its rules text (once: a piece already split is left alone).
static func split_lead_in(piece: EquipmentData) -> void:
	if piece == null or not LEAD_INS.has(piece.id):
		return
	var lead: String = str(LEAD_INS[piece.id])
	if not piece.description.begins_with(lead):
		return
	piece.description = piece.description.substr(lead.length()).strip_edges()
	if not piece.description.is_empty():
		piece.description = piece.description.substr(0, 1).to_upper() + piece.description.substr(1)
	if piece.flavor_text.is_empty():
		piece.flavor_text = lead
	elif not piece.flavor_text.contains(lead):
		piece.flavor_text = "%s %s" % [lead, piece.flavor_text]


static func split_all(pieces: Dictionary) -> void:
	for piece: Variant in pieces.values():
		split_lead_in(piece as EquipmentData)


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
