class_name IconArt
extends RefCounted
## The icon set (docs/art/art_pipeline.md, "import icons"): `assets/art/icons/<ICON ID>.webp` (256 px master) plus crisp pre-downscaled `<ID>_24/_32/_48/_64/_96/_128.webp`.
## Every screen asks for an icon by ID and size and keeps its old look when the image is missing (`texture` returns null), so any icon can arrive late.
## The importer copies from the read-only Drive folder in `art_config.cfg` (`icons_dir`), keeps transparency (or removes a plain flat background), trims the empty
## margin, centres the sprite on a square canvas and writes lossless WebP. Nothing in the Drive folder is moved, renamed or deleted.

const OUT_DIR: String = "res://assets/art/icons"
const MANIFEST_PATH: String = "res://data/source/icons_import_manifest.csv"
const CONFIG_PATH: String = "res://data/source/art_config.cfg"
const CSV_PATH: String = "res://data/source/icons.csv"
const STATUS_MARKER: String = "## Icons"
const INPUT_EXTENSIONS: Array[String] = ["png", "webp", "jpg", "jpeg"]
## Placeholder rows of the CSV that are not icons yet.
const PLACEHOLDER_IDS: Array[String] = ["ICON-GEAR-OTHERS", "ICON-ITEM-OTHERS", "ICON-HAT-OTHERS"]
const MASTER_SIDE: int = 256
const SIZES: Array[int] = [24, 32, 48, 64, 96, 128]
## Fraction of the canvas left empty on each side so glow and outline do not touch the edge.
const CANVAS_MARGIN: float = 0.03

static var _textures: Dictionary = {}


class Result extends RefCounted:
	var added: Array[String] = []
	var replaced: Array[String] = []
	var unchanged: int = 0
	var background_removed: Array[String] = []
	var unknown: Array[String] = []
	## Files whose name was matched forgivingly ("<file> -> <ICON ID>", see `file_icon_id`); the copy is saved under the ID.
	var renamed: Array[String] = []
	var errors: Array[String] = []
	var have: Array[String] = []
	var missing: Array[String] = []


# ---- Loading --------------------------------------------------------------------------------


static func path_for(id: String, size: int = 0) -> String:
	return OUT_DIR.path_join(("%s.webp" % id) if size <= 0 else ("%s_%d.webp" % [id, size]))


## Overnight Oct 17 (Phase 2, performance): the answer is remembered per ID - a card's rules text asks about 14 icons and each
## `ResourceLoader.exists` is a file check, about 1.7 ms of every card view built.
static var _has_cache: Dictionary = {}


static func has(id: String) -> bool:
	var known: Variant = _has_cache.get(id)
	if known == null:
		known = ResourceLoader.exists(path_for(id))
		_has_cache[id] = known
	return bool(known)


## The sharpest stored size for drawing about `px` pixels wide: the smallest variant that is at least `px` (so it is only ever shrunk a little), else the master (0).
static func best_size(px: float) -> int:
	for size: int in SIZES:
		if float(size) >= px - 0.5:
			return size
	return 0


## The texture of an icon ID for drawing at about `px` pixels; null when there is no image (the caller keeps its fallback look).
static func texture(id: String, px: float = 0.0) -> Texture2D:
	var size: int = best_size(px) if px > 0.0 else 0
	var key: String = "%s|%d" % [id, size]
	if _textures.has(key):
		return _textures[key] as Texture2D
	var path: String = path_for(id, size)
	var loaded: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	if loaded == null and size > 0:
		loaded = texture(id)
	_textures[key] = loaded
	return loaded


static func reset() -> void:
	_textures = {}
	_has_cache = {}


## A TextureRect of the icon at `px` x `px`; null when the icon is missing. With `tooltip` text it shows it on hover, otherwise it ignores the mouse.
static func rect(id: String, px: float, tooltip: String = "") -> TextureRect:
	var tex: Texture2D = texture(id, px)
	if tex == null:
		return null
	var view: TextureRect = TextureRect.new()
	view.texture = tex
	view.custom_minimum_size = Vector2(px, px)
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE if tooltip.is_empty() else Control.MOUSE_FILTER_PASS
	view.tooltip_text = tooltip
	return view


## BBCode `[img]` tag of an icon for RichTextLabel text; "" when the icon is missing.
static func bbcode(id: String, px: int) -> String:
	if not has(id):
		return ""
	return "[img=%dx%d]%s[/img]" % [px, px, path_for(id, best_size(float(px)))]


# ---- Which icon where --------------------------------------------------------------------------


const ENERGY_IDS: Dictionary = {
	Affinity.Type.BEEFCAKE: "ICON-ENERGY-B",
	Affinity.Type.NECROCRAT: "ICON-ENERGY-N",
	Affinity.Type.GOURMAND: "ICON-ENERGY-G",
	Affinity.Type.REFUSEMANCER: "ICON-ENERGY-R",
	Affinity.Type.NEUTRAL: "ICON-ENERGY-GENERIC",
}
const ESSENCE_IDS: Dictionary = {
	Affinity.Type.BEEFCAKE: "ICON-ESSENCE-B",
	Affinity.Type.NECROCRAT: "ICON-ESSENCE-N",
	Affinity.Type.GOURMAND: "ICON-ESSENCE-G",
	Affinity.Type.REFUSEMANCER: "ICON-ESSENCE-R",
}
## Resources and the Contract token (ResourceKind.Kind).
const RESOURCE_IDS: Dictionary = {
	ResourceKind.Kind.IRON: "ICON-RES-IRON",
	ResourceKind.Kind.RED_TAPE: "ICON-RES-REDTAPE",
	ResourceKind.Kind.CONTRACT: "ICON-TOKEN-CONTRACT",
	ResourceKind.Kind.INGREDIENT: "ICON-RES-INGREDIENT",
	ResourceKind.Kind.GARBAGE: "ICON-RES-GARBAGE",
}
const KEYWORD_IDS: Dictionary = {
	CardEnums.Keyword.FLYING: "ICON-KW-FLYING",
	CardEnums.Keyword.SWAT: "ICON-KW-SWAT",
	CardEnums.Keyword.HUSTLE: "ICON-KW-HUSTLE",
	CardEnums.Keyword.WALLFLOWER: "ICON-KW-WALLFLOWER",
	CardEnums.Keyword.BULLDOZE: "ICON-KW-BULLDOZE",
	CardEnums.Keyword.SUCKER_PUNCH: "ICON-KW-SUCKERPUNCH",
	CardEnums.Keyword.NOURISH: "ICON-KW-NOURISH",
	CardEnums.Keyword.OVERTIME: "ICON-KW-OVERTIME",
	CardEnums.Keyword.ONE_TWO_PUNCH: "ICON-KW-ONETWO",
	CardEnums.Keyword.TOXIC: "ICON-KW-TOXIC",
	CardEnums.Keyword.ELUSIVE: "ICON-KW-ELUSIVE",
	CardEnums.Keyword.UNTOUCHABLE: "ICON-KW-UNTOUCHABLE",
	CardEnums.Keyword.UNBREAKABLE: "ICON-KW-UNBREAKABLE",
}
const TYPE_IDS: Dictionary = {
	CardEnums.CardType.UNIT: "ICON-TYPE-UNIT",
	CardEnums.CardType.SPELL: "ICON-TYPE-SPELL",
	CardEnums.CardType.TRAP: "ICON-TYPE-TRAP",
	CardEnums.CardType.TOOL: "ICON-TYPE-TOOL",
	CardEnums.CardType.WONDER: "ICON-TYPE-WONDER",
	CardEnums.CardType.INFRASTRUCTURE: "ICON-TYPE-INFRA",
	CardEnums.CardType.TOKEN: "ICON-TYPE-TOKEN",
}
## Mechanic and token words in rules text and glossary entries -> icon.
const WORD_IDS: Dictionary = {
	"Exhaust": "ICON-MECH-EXHAUST", "Shred": "ICON-MECH-SHRED", "Reinstate": "ICON-MECH-REINSTATE", "Brawl": "ICON-MECH-BRAWL", "Plate": "ICON-MECH-PLATE",
	"Peek": "ICON-MECH-PEEK", "Bury": "ICON-MECH-BURY", "Processing": "ICON-MECH-PROCESSING", "Buff": "ICON-MECH-BUFF", "Overexert": "ICON-MECH-OVEREXERT",
	"Eat Garbage": "ICON-MECH-EATGARBAGE", "Send back": "ICON-MECH-SENDBACK",
}
## Words of card rules text that get a small icon in front of them: resource and token names (singular and plural).
const RULES_WORD_IDS: Dictionary = {
	"Iron": "ICON-RES-IRON", "Irons": "ICON-RES-IRON", "Red Tape": "ICON-RES-REDTAPE", "Ingredient": "ICON-RES-INGREDIENT", "Ingredients": "ICON-RES-INGREDIENT",
	"Garbage": "ICON-RES-GARBAGE", "Contract": "ICON-TOKEN-CONTRACT", "Contracts": "ICON-TOKEN-CONTRACT", "Clause": "ICON-TOKEN-CLAUSE", "Clauses": "ICON-TOKEN-CLAUSE",
}


## The ten named equipment pieces that have their own icon (equipment id -> icon). Every other piece keeps its game-icons fallback (docs/backlog.md).
const EQUIPMENT_IDS: Dictionary = {
	"wicked_dagger": "ICON-GEAR-WICKEDDAGGER",
	"flamethrower": "ICON-GEAR-FLAMETHROWER",
	"extra_pocket": "ICON-GEAR-EXTRAPOCKET",
	"cheaters_dice": "ICON-GEAR-CHEATERSDICE",
	"travelers_boots": "ICON-GEAR-TRAVELERSBOOTS",
	"hover_boots": "ICON-GEAR-HOVERBOOTS",
	"solid_plate": "ICON-GEAR-SOLIDPLATE",
	"thorned_loincloth": "ICON-GEAR-THORNEDLOINCLOTH",
	"xray_goggles": "ICON-GEAR-XRAYGOGGLES",
	"big_brain_beret": "ICON-GEAR-BIGBRAINBERET",
}
## The empty-slot placeholders of the character screen (EquipmentData.Slot).
const SLOT_IDS: Dictionary = {
	EquipmentData.Slot.HELM: "ICON-EQUIP-HELM",
	EquipmentData.Slot.WEAPON: "ICON-EQUIP-WEAPON",
	EquipmentData.Slot.ARMOR: "ICON-EQUIP-ARMOR",
	EquipmentData.Slot.BOOTS: "ICON-EQUIP-BOOTS",
	EquipmentData.Slot.RELIC: "ICON-EQUIP-RELIC",
}


## Oct 16: the 25 new pieces use their own `ICON-GEAR-<NAME>` art once it is imported (docs/art/zone_kits/equipment_icons.md); until then the
## closest existing gear icon stands in (`PLACEHOLDER_GEAR`).
static func equipment_id(piece: EquipmentData) -> String:
	if EQUIPMENT_IDS.has(piece.id):
		return str(EQUIPMENT_IDS[piece.id])
	var own: String = gear_icon_id(piece.id)
	if has(own):
		return own
	return str(PLACEHOLDER_GEAR.get(piece.id, ""))


# ---- Own-icon ID conventions (Oct 19 night, Part 3: drop-in gear / item / cosmetic icons) ------------------------------------------------


const GEAR_PREFIX: String = "ICON-GEAR-"
const ITEM_PREFIX: String = "ICON-ITEM-"
const COSMETIC_PREFIX: String = "ICON-COS-"


## "lucky_sock" -> "LUCKYSOCK": upper case, no underscores, dashes or spaces (the icon ID body of a game id).
static func id_slug(game_id: String) -> String:
	return game_id.strip_edges().to_upper().replace("_", "").replace("-", "").replace(" ", "")


## The own icon of an equipment piece: ICON-GEAR-<id upper, no underscores> ("lucky_sock" -> ICON-GEAR-LUCKYSOCK). The ten named
## pieces of `EQUIPMENT_IDS` follow the same rule.
static func gear_icon_id(equipment_id_text: String) -> String:
	if EQUIPMENT_IDS.has(equipment_id_text):
		return str(EQUIPMENT_IDS[equipment_id_text])
	return GEAR_PREFIX + id_slug(equipment_id_text)


## The own icon of a consumable item: ICON-ITEM-<id upper, no underscores> ("healing_draught" -> ICON-ITEM-HEALINGDRAUGHT).
static func item_icon_id(item_id: String) -> String:
	return ITEM_PREFIX + id_slug(item_id)


## The shop / wardrobe icon of a hat or cloak: ICON-COS-<art name> ("WIDEBRIM" -> ICON-COS-WIDEBRIM, "REDCAPE" -> ICON-COS-REDCAPE).
static func cosmetic_icon_id(art_name: String) -> String:
	return COSMETIC_PREFIX + id_slug(art_name)


## True when the consumable has its own icon (ICON-ITEM-*), not the game-icons fallback.
static func has_item_icon(item: ItemData) -> bool:
	return item != null and has(item_icon_id(item.id))


## The picture of a consumable for about `px` pixels: its own full-colour icon once imported, else the old game-icons silhouette.
static func item_texture(item: ItemData, px: float) -> Texture2D:
	if has_item_icon(item):
		return texture(item_icon_id(item.id), px)
	return CardIcons.for_item(item)


## A TextureRect of the consumable: its icon untinted, or the fallback silhouette tinted `tint` (the old look).
static func item_glyph(item: ItemData, tint: Color, px: float) -> TextureRect:
	if has_item_icon(item):
		return rect(item_icon_id(item.id), px)
	return CardIcons.glyph(CardIcons.for_item(item), tint, Vector2(px, px))


## The shop icon of a hat or cloak (ICON-COS-<art name>) for about `px` pixels; null when it is not imported (the caller keeps its old picture).
static func cosmetic_texture(item: CosmeticData, px: float) -> Texture2D:
	if item == null or item.art_name.is_empty():
		return null
	var id: String = cosmetic_icon_id(item.art_name)
	return texture(id, px) if has(id) else null


const PLACEHOLDER_GEAR: Dictionary = {
	"lucky_sock": "ICON-GEAR-EXTRAPOCKET", "cardboard_cuirass": "ICON-GEAR-SOLIDPLATE", "pointy_stick": "ICON-GEAR-WICKEDDAGGER",
	"saucepan_helmet": "ICON-GEAR-BIGBRAINBERET", "flip_flops": "ICON-GEAR-TRAVELERSBOOTS", "kettlebell_locket": "ICON-GEAR-CHEATERSDICE",
	"red_tape_dispenser": "ICON-GEAR-EXTRAPOCKET", "doggy_bag": "ICON-GEAR-EXTRAPOCKET", "dumpster_gloves": "ICON-GEAR-THORNEDLOINCLOTH",
	"glass_jaw_gauntlets": "ICON-GEAR-WICKEDDAGGER", "overdue_library_book": "ICON-GEAR-BIGBRAINBERET", "elastic_waistband": "ICON-GEAR-THORNEDLOINCLOTH",
	"hubris_crown": "ICON-GEAR-BIGBRAINBERET", "protein_bandolier": "ICON-GEAR-SOLIDPLATE", "notary_seal": "ICON-GEAR-CHEATERSDICE",
	"rolling_pin": "ICON-GEAR-WICKEDDAGGER", "raccoon_crown": "ICON-GEAR-BIGBRAINBERET", "hustle_headband": "ICON-GEAR-XRAYGOGGLES",
	"paper_plane_cape": "ICON-GEAR-SOLIDPLATE", "mystery_stain_bib": "ICON-GEAR-THORNEDLOINCLOTH", "velvet_rope": "ICON-GEAR-CHEATERSDICE",
	"sucker_punch_mitts": "ICON-GEAR-WICKEDDAGGER", "dog_eared_bookmark": "ICON-GEAR-EXTRAPOCKET", "participation_trophy": "ICON-GEAR-CHEATERSDICE",
	"gotta_go_galoshes": "ICON-GEAR-HOVERBOOTS",
}


static func slot_id(slot: EquipmentData.Slot) -> String:
	return str(SLOT_IDS.get(slot, ""))


## True when `piece` shows its own icon (not the game-icons fallback).
static func has_equipment_icon(piece: EquipmentData) -> bool:
	var id: String = equipment_id(piece)
	return id != "" and has(id)


## The picture of an equipment piece for about `px` pixels: its own full-colour icon, else the game-icons fallback silhouette.
static func equipment_texture(piece: EquipmentData, px: float) -> Texture2D:
	if has_equipment_icon(piece):
		return texture(equipment_id(piece), px)
	return CardIcons.for_equipment(piece)


## A TextureRect of the piece: its icon untinted, or the fallback silhouette tinted `tint`.
static func equipment_glyph(piece: EquipmentData, tint: Color, px: float) -> TextureRect:
	if has_equipment_icon(piece):
		return rect(equipment_id(piece), px)
	return CardIcons.glyph(CardIcons.for_equipment(piece), tint, Vector2(px, px))


static func energy_id(path: Affinity.Type) -> String:
	return str(ENERGY_IDS.get(path, "ICON-ENERGY-GENERIC"))


static func essence_id(path: Affinity.Type) -> String:
	return str(ESSENCE_IDS.get(path, ""))


static func resource_id(kind: int) -> String:
	return str(RESOURCE_IDS.get(kind, ""))


static func keyword_id(keyword: CardEnums.Keyword) -> String:
	return str(KEYWORD_IDS.get(keyword, ""))


static func type_id(type: CardEnums.CardType) -> String:
	return str(TYPE_IDS.get(type, ""))


## The icon `id` (full colour, never tinted) at `px`, or - when it is missing - `fallback` as the old tinted glyph.
static func glyph_or(id: String, fallback: Texture2D, tint: Color, px: float) -> TextureRect:
	var icon: TextureRect = rect(id, px)
	if icon != null:
		return icon
	return CardIcons.glyph(fallback, tint, Vector2(px, px))


## Puts the icon `id` (full colour) in front of a Button's text. Does nothing when the icon is missing.
static func button_icon(button: Button, id: String, px: float = 32.0) -> void:
	var tex: Texture2D = texture(id, px)
	if tex == null:
		return
	button.icon = tex
	button.add_theme_constant_override("icon_max_width", int(px))
	button.add_theme_constant_override("h_separation", 10)
	for icon_color: String in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color", "icon_disabled_color"]:
		button.add_theme_color_override(icon_color, Color.WHITE if icon_color != "icon_disabled_color" else Color(1, 1, 1, 0.45))


## A section heading with its icon in front (`UIKit.label` HeadingLabel); just the label when the icon is missing.
static func heading_row(text: String, icon_id: String, font_size: int = 28) -> Control:
	var label: Label = UIKit.label(text, &"HeadingLabel", font_size)
	var icon: TextureRect = rect(icon_id, float(font_size) + 12.0)
	if icon == null:
		return label
	var row: HBoxContainer = UIKit.hbox(10)
	row.add_child(icon)
	row.add_child(label)
	return row


## Old `CardIcons.ui` names that now have a real icon.
const UI_NAME_IDS: Dictionary = {
	"coins": "ICON-GOLD", "lock": "ICON-PADLOCK", "hp": "ICON-STAT-HP", "attack": "ICON-STAT-ATTACK", "level_badge": "ICON-LEVEL", "card_choice": "ICON-DECKBOX",
}


## The icon id behind `name`: an icon id itself ("ICON-CHECK"), or an old `CardIcons.ui` name with a mapped icon; "" when there is none.
static func id_for_name(name: String) -> String:
	if name.begins_with("ICON-"):
		return name
	return str(UI_NAME_IDS.get(name, ""))


## A glyph for `name` (an icon id or an old `CardIcons.ui` name): the icon untinted at `px`, else the old tinted silhouette.
static func glyph_for(name: String, tint: Color, px: float) -> TextureRect:
	var id: String = id_for_name(name)
	var fallback: Texture2D = CardIcons.ui(name) if not name.begins_with("ICON-") else CardIcons.ui("magic")
	return glyph_or(id, fallback, tint, px)


## Shows `id` in an existing TextureRect (full colour); false (the rect keeps its texture and tint) when the icon is missing.
static func apply(target: TextureRect, id: String, px: float) -> bool:
	var tex: Texture2D = texture(id, px)
	if tex == null:
		return false
	target.texture = tex
	target.material = null
	target.modulate = Color.WHITE
	return true


## Shows a price on a (centred) Label as the gold icon followed by the number; falls back to "<n> gold" when the icon is missing.
static func set_price(label: Label, value: int) -> void:
	var icon: TextureRect = _price_icon(label)
	if icon == null:
		label.text = "%d gold" % value
		return
	label.text = str(value)
	icon.visible = true
	_place_price_icon(label, icon)


## Plain text in a price Label ("???", "Max", "Owned"): the gold icon hides.
static func set_price_text(label: Label, text: String) -> void:
	label.text = text
	var icon: TextureRect = label.get_node_or_null("GoldIcon") as TextureRect
	if icon != null:
		icon.visible = false


static func _price_icon(label: Label) -> TextureRect:
	var existing: TextureRect = label.get_node_or_null("GoldIcon") as TextureRect
	if existing != null:
		return existing
	var px: float = clampf(float(label.get_theme_font_size("font_size")) + 4.0, 20.0, 40.0)
	var icon: TextureRect = rect("ICON-GOLD", px)
	if icon == null:
		return null
	icon.name = "GoldIcon"
	icon.size = Vector2(px, px)
	label.add_child(icon)
	label.resized.connect(func() -> void: _place_price_icon(label, icon))
	return icon


## The icon sits just left of the centred number, vertically centred in the label.
static func _place_price_icon(label: Label, icon: TextureRect) -> void:
	var font: Font = label.get_theme_font("font")
	var text_width: float = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x
	icon.position = Vector2(maxf(2.0, (label.size.x - text_width) * 0.5 - icon.size.x - 4.0), (label.size.y - icon.size.y) * 0.5)


# ---- Import ---------------------------------------------------------------------------------


static func source_dir() -> String:
	var dir: String = OS.get_environment("ICON_SOURCE_DIR")
	if dir.is_empty():
		var config: ConfigFile = ConfigFile.new()
		if config.load(CONFIG_PATH) == OK:
			dir = str(config.get_value("art", "icons_dir", ""))
	return dir.replace("\\", "/").rstrip("/")


## {ICON ID -> asset name} from the designer's CSV (rows whose first column starts with "ICON-", placeholders skipped).
static func known_ids() -> Dictionary:
	var known: Dictionary = {}
	if not FileAccess.file_exists(CSV_PATH):
		return known
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() >= 2 and row[0].begins_with("ICON-") and not PLACEHOLDER_IDS.has(row[0].strip_edges()):
			known[row[0].strip_edges()] = row[1].strip_edges()
	file.close()
	return known


## Oct 19 night (Part 3): what the importer accepts and reports on - the CSV's IDs plus the expected own icon of every gear piece, consumable
## and hat / cloak of the game (`game_ids`), so ICON-GEAR-* / ICON-ITEM-* / ICON-COS-* art drops in even when the CSV has no row for it.
static func import_ids() -> Dictionary:
	var known: Dictionary = known_ids()
	var from_game: Dictionary = game_ids()
	for id: Variant in from_game:
		if not known.has(id):
			known[id] = from_game[id]
	return known


const GAME_EQUIPMENT_DIRS: Array[String] = ["res://data/equipment/", "res://data/equipment/zone/"]
const GAME_ITEM_DIRS: Array[String] = ["res://data/items/"]


## {ICON ID -> "Gear: <name>" / "Item: <name>" / "Hat: <name>" / "Cloak: <name>"} for every equipment piece, consumable and cosmetic in the game data
## (data/equipment, data/equipment/zone, data/items, CosmeticCatalog), by the conventions above.
static func game_ids() -> Dictionary:
	var ids: Dictionary = {}
	for dir_path: String in GAME_EQUIPMENT_DIRS:
		for path: String in _tres_in(dir_path):
			var piece: EquipmentData = load(path) as EquipmentData
			if piece != null and not piece.id.is_empty():
				ids[gear_icon_id(piece.id)] = "Gear: %s" % (piece.source_name if not piece.source_name.is_empty() else piece.id)
	for dir_path: String in GAME_ITEM_DIRS:
		for path: String in _tres_in(dir_path):
			var item: ItemData = load(path) as ItemData
			if item != null and not item.id.is_empty():
				ids[item_icon_id(item.id)] = "Item: %s" % (item.display_name if not item.display_name.is_empty() else item.id)
	for cosmetic: CosmeticData in CosmeticCatalog.all():
		if not cosmetic.art_name.is_empty():
			ids[cosmetic_icon_id(cosmetic.art_name)] = "%s: %s" % [cosmetic.slot_name(), cosmetic.display_name]
	return ids


## The expected own-icon IDs with one prefix (GEAR_PREFIX, ITEM_PREFIX, COSMETIC_PREFIX), sorted.
static func game_ids_with_prefix(prefix: String) -> Array[String]:
	var result: Array[String] = []
	for id: Variant in game_ids():
		if str(id).begins_with(prefix):
			result.append(str(id))
	result.sort()
	return result


static func _tres_in(dir_path: String) -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return files
	for file_name: String in dir.get_files():
		var clean: String = file_name.trim_suffix(".remap")
		if clean.ends_with(".tres"):
			files.append(dir_path + clean)
	files.sort()
	return files


## The icon ID a source file name stands for, "" when it matches none. Exact IDs win; otherwise the name is matched forgivingly so a drop-in
## import never skips art over spelling: any case, "_" or " " for "-", and for ICON-GEAR- / ICON-ITEM- / ICON-COS- names the body without
## separators ("ICON-GEAR-LUCKY-SOCK" -> ICON-GEAR-LUCKYSOCK) and an optional HAT- / CLOAK- after ICON-COS- ("ICON-COS-HAT-WIDEBRIM" -> ICON-COS-WIDEBRIM).
static func file_icon_id(base_name: String, known: Dictionary) -> String:
	var id: String = base_name.strip_edges()
	if known.has(id):
		return id
	var upper: String = id.to_upper().replace("_", "-").replace(" ", "-")
	if known.has(upper):
		return upper
	for prefix: String in [GEAR_PREFIX, ITEM_PREFIX, COSMETIC_PREFIX]:
		if not upper.begins_with(prefix):
			continue
		var body: String = upper.substr(prefix.length())
		var candidate: String = prefix + id_slug(body)
		if known.has(candidate):
			return candidate
		if prefix == COSMETIC_PREFIX:
			for kind: String in ["HAT-", "CLOAK-"]:
				if body.begins_with(kind):
					candidate = prefix + id_slug(body.substr(kind.length()))
					if known.has(candidate):
						return candidate
	return ""


static func import_from_source(source: String, out_dir: String, manifest_path: String, known: Dictionary) -> Result:
	var result: Result = Result.new()
	DirAccess.make_dir_recursive_absolute(_real(out_dir))
	var manifest: Dictionary = ArtImporter.read_manifest(_real(manifest_path))
	var rows: Dictionary = {}
	var files: Array[String] = []
	for file_name: String in DirAccess.get_files_at(source):
		files.append(file_name)
	files.sort()
	for file_name: String in files:
		if not INPUT_EXTENSIONS.has(file_name.get_extension().to_lower()):
			continue
		var id: String = file_icon_id(file_name.get_basename(), known)
		if id.is_empty():
			result.unknown.append(file_name)
			continue
		if id != file_name.get_basename():
			result.renamed.append("%s -> %s" % [file_name, id])
		var full_path: String = source.path_join(file_name)
		var hash: String = FileAccess.get_md5(full_path)
		var target: String = _real(out_dir.path_join("%s.webp" % id))
		var had: bool = FileAccess.file_exists(target)
		rows[id] = PackedStringArray([id, file_name, str(_size(full_path)), hash])
		if had and str(manifest.get(id, "")) == hash and _variants_exist(out_dir, id):
			result.unchanged += 1
			continue
		var image: Image = Image.load_from_file(full_path)
		if image == null or image.is_empty():
			result.errors.append("%s: not a readable image" % file_name)
			rows.erase(id)
			continue
		image.convert(Image.FORMAT_RGBA8)
		if Portraits.remove_flat_background(image):
			result.background_removed.append(file_name)
		image = UiArt.trimmed(image)
		var failed: bool = squared(image, MASTER_SIDE).save_webp(target, false) != OK
		for size: int in SIZES:
			failed = failed or squared(image, size).save_webp(_real(out_dir.path_join("%s_%d.webp" % [id, size])), false) != OK
		if failed:
			result.errors.append("%s: could not write" % file_name)
			rows.erase(id)
			continue
		result.added.append(id)
		if had:
			result.replaced.append(id)
	_write_manifest(_real(manifest_path), rows)
	var ids: Array = known.keys()
	ids.sort()
	for id: Variant in ids:
		if FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id)))):
			result.have.append(str(id))
		else:
			result.missing.append(str(id))
	reset()
	return result


static func _variants_exist(out_dir: String, id: String) -> bool:
	for size: int in SIZES:
		if not FileAccess.file_exists(_real(out_dir.path_join("%s_%d.webp" % [id, size]))):
			return false
	return true


## `image` fitted into a transparent `side` x `side` square (centred, never stretched, CANVAS_MARGIN free), downscaled with Lanczos from the full-size source so small
## sizes are crisp. Colours are bled into transparent pixels first so the resize leaves no dark fringe.
static func squared(image: Image, side: int) -> Image:
	var inner: int = maxi(1, int(round(float(side) * (1.0 - 2.0 * CANVAS_MARGIN))))
	var longest: int = maxi(image.get_width(), image.get_height())
	var factor: float = float(inner) / float(longest)
	var work: Image = image.duplicate() as Image
	work.fix_alpha_edges()
	work.resize(maxi(1, int(round(work.get_width() * factor))), maxi(1, int(round(work.get_height() * factor))), Image.INTERPOLATE_LANCZOS)
	var canvas: Image = Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	canvas.blit_rect(work, Rect2i(Vector2i.ZERO, work.get_size()), Vector2i((side - work.get_width()) / 2, (side - work.get_height()) / 2))
	return canvas


static func _size(path: String) -> int:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return 0 if file == null else file.get_length()


static func _write_manifest(path: String, rows: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_csv_line(PackedStringArray(["Icon ID", "file", "bytes", "md5"]))
	var keys: Array = rows.keys()
	keys.sort()
	for key: Variant in keys:
		file.store_csv_line(rows[key] as PackedStringArray)
	file.close()


static func _real(path: String) -> String:
	return ProjectSettings.globalize_path(path)


# ---- Status ---------------------------------------------------------------------------------


static func status_markdown(out_dir: String = OUT_DIR) -> String:
	var known: Dictionary = import_ids()
	var ids: Array = known.keys()
	ids.sort()
	var rows: Array[String] = []
	var have: int = 0
	for id: Variant in ids:
		var present: bool = FileAccess.file_exists(_real(out_dir.path_join("%s.webp" % str(id))))
		have += 1 if present else 0
		rows.append("| %s | %s | %s |" % [id, str(known[id]).replace("|", "/"), "yes" if present else "MISSING"])
	var lines: Array[String] = [
		STATUS_MARKER,
		"",
		"Generated by `tools/import_icons`. Icons load from `assets/art/icons/<ICON ID>.webp` (`IconArt.texture`); every screen keeps its old look when an icon is missing.",
		"",
		"**%d of %d** icons are in the game." % [have, ids.size()],
		"",
		"| Icon ID | Asset | Image |",
		"|---------|-------|-------|",
	]
	lines.append_array(rows)
	return "\n".join(lines) + "\n"


static func write_status(status_path: String) -> void:
	var text: String = FileAccess.get_file_as_string(status_path) if FileAccess.file_exists(status_path) else ""
	var file: FileAccess = FileAccess.open(status_path, FileAccess.WRITE)
	file.store_string(Portraits.replace_section(text, STATUS_MARKER, status_markdown()))
	file.close()
