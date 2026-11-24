class_name DraftKit
extends RefCounted
## Fable big pass Nov 23: the pieces the draft screens share (the pick screen, the deck builder, the next-opponent reveal, Trey's
## menu and the Shuffle House's): text and panes in the stained-glass look, the cost curve, the Path chips, a gear card in the one
## display order (`GearText`), full-screen backdrops and the carnival plaques of the mock-ups. Presentation only.

const PATH_ORDER: Array[int] = [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]
## The carnival-casino palette of the Shuffle House art (Batch 20): velvet, marquee gold, baize.
const VELVET: Color = Color("5a1226")
const VELVET_DEEP: Color = Color("2a0a16")
const MARQUEE: Color = Color("f6c65a")
const CREAM: Color = Color("fbe9c2")
const BAIZE: Color = Color("14432c")
const NIGHT: Color = Color("15122c")


static func text(words: String, size: int = 30, colour: Color = GlassTheme.TEXT, wrap: bool = true) -> Label:
	var label: Label = UIKit.label(words, &"", size, colour)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


static func pane(lit: bool = false, glass: Color = GlassTheme.SLATE) -> PanelContainer:
	var made: PanelContainer = PanelContainer.new()
	if GlassTheme.available():
		made.add_theme_stylebox_override("panel", GlassTheme.pane(glass, lit))
	return made


## A dark plaque with a gold rim (the side panels of the mock-ups), `alpha` see-through over a backdrop.
static func plaque(alpha: float = 0.9, fill: Color = NIGHT, rim: Color = GlassTheme.GOLD_LINE, radius: int = 18, margin: float = 16.0) -> PanelContainer:
	var made: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = UIStyle.box(Color(fill, alpha), rim, 3, radius)
	box.set_content_margin_all(margin)
	made.add_theme_stylebox_override("panel", box)
	return made


## A small heading chip ("Cost Curve", "Equipment"): the dark rounded labels of the pick screen's side panel.
static func chip(words: String, size: int = 24) -> PanelContainer:
	var made: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = UIStyle.box(Color(0.06, 0.05, 0.14, 0.85), Color(0, 0, 0, 0), 0, 12)
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 3.0
	box.content_margin_bottom = 4.0
	made.add_theme_stylebox_override("panel", box)
	made.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var label: Label = UIKit.label(words, &"", size, CREAM)
	label.add_theme_font_override("font", UIStyle.font_bold())
	made.add_child(label)
	return made


static func button(words: String, node_name: String, action: Callable, size: Vector2 = Vector2(300, 66), variation: StringName = &"") -> FancyButton:
	var made: FancyButton = FancyButton.make(words, variation, size)
	made.name = node_name
	made.pressed.connect(action)
	return made


## A picture that covers the whole screen (or its parent), cropped to fit.
static func backdrop(texture: Texture2D, shade: float = 0.0) -> Control:
	var holder: Control = Control.new()
	holder.name = "Backdrop"
	UIKit.full_rect(holder)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var picture: TextureRect = TextureRect.new()
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(picture)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(picture)
	if shade > 0.0:
		var dim: ColorRect = ColorRect.new()
		dim.color = Color(0.03, 0.01, 0.05, shade)
		UIKit.full_rect(dim)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(dim)
	return holder


## Seven bars, cost 0 to 6+, each with its count (the pick screen's and the deck builder's curve).
static func curve(counts: Array[int], height: float = 120.0, bar_colour: Color = GlassTheme.GOLD_LINE) -> Control:
	var row: HBoxContainer = UIKit.hbox(6)
	row.name = "CostCurve"
	row.custom_minimum_size = Vector2(0, height)
	var top: int = 1
	for count: int in counts:
		top = maxi(top, count)
	for bucket: int in range(counts.size()):
		var column: VBoxContainer = UIKit.vbox(2)
		column.alignment = BoxContainer.ALIGNMENT_END
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_child(UIKit.label(str(counts[bucket]), &"", 20, GlassTheme.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		var bar: ColorRect = ColorRect.new()
		bar.color = bar_colour if counts[bucket] > 0 else Color(1, 1, 1, 0.12)
		bar.custom_minimum_size = Vector2(28, 4.0 + (height - 62.0) * float(counts[bucket]) / float(top))
		column.add_child(bar)
		column.add_child(UIKit.label("%d%s" % [bucket, "+" if bucket == counts.size() - 1 else ""], &"", 20, GlassTheme.SECONDARY, HORIZONTAL_ALIGNMENT_CENTER))
		row.add_child(column)
	return row


## A Path's energy symbol in a round coloured badge (`px` across), lit or dimmed; with `count` >= 0 a number rides beside it.
static func path_badge(path: int, px: float = 54.0, lit: bool = true, count: int = -1) -> Control:
	var row: HBoxContainer = UIKit.hbox(6)
	row.name = "Path_%d" % path
	var disc: PanelContainer = PanelContainer.new()
	var colour: Color = UIStyle.affinity_color(path as Affinity.Type) if path != int(Affinity.Type.NEUTRAL) else Color("8d8aa6")
	var box: StyleBoxFlat = UIStyle.box(colour if lit else Color(colour.darkened(0.6), 0.8), MARQUEE if lit else Color(0.4, 0.4, 0.45), 2, int(px * 0.5))
	box.set_content_margin_all(px * 0.14)
	disc.add_theme_stylebox_override("panel", box)
	disc.custom_minimum_size = Vector2(px, px)
	var symbol: TextureRect = IconArt.rect(IconArt.energy_id(path as Affinity.Type), px * 0.72)
	if symbol != null:
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		symbol.modulate = Color.WHITE if lit else Color(1, 1, 1, 0.45)
		disc.add_child(symbol)
	disc.tooltip_text = Affinity.display_name(path as Affinity.Type)
	row.add_child(disc)
	if count >= 0:
		var number: Label = UIKit.label(str(count), &"", int(px * 0.5), GlassTheme.TEXT)
		number.add_theme_font_override("font", UIStyle.font_bold())
		row.add_child(number)
	return row


## A row of Path badges for `paths` (a draft's Paths, a rival's).
static func path_row(paths: Array, px: float = 54.0) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(8)
	row.name = "Paths"
	for path: Variant in paths:
		row.add_child(path_badge(int(path), px))
	return row


## A square slot holding an icon (a piece of equipment, an item), or an empty dashed one. Hovering it shows `tooltip`.
static func icon_slot(icon: Texture2D, tooltip: String, px: float = 74.0) -> PanelContainer:
	var slot: PanelContainer = PanelContainer.new()
	var filled: bool = icon != null
	var box: StyleBoxFlat = UIStyle.box(Color(0.05, 0.04, 0.1, 0.85) if filled else Color(0, 0, 0, 0.25), GlassTheme.GOLD_LINE if filled else Color(1, 1, 1, 0.22), 2, 12)
	box.set_content_margin_all(6.0)
	slot.add_theme_stylebox_override("panel", box)
	slot.custom_minimum_size = Vector2(px, px)
	slot.tooltip_text = tooltip
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	if filled:
		var picture: TextureRect = TextureRect.new()
		picture.texture = icon
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.custom_minimum_size = Vector2(px - 12.0, px - 12.0)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(picture)
	return slot


static func equipment_icon(piece: EquipmentData, px: float) -> Texture2D:
	if piece == null:
		return null
	return IconArt.equipment_texture(piece, px) if IconArt.has_equipment_icon(piece) else IconArt.texture(str(IconArt.SLOT_IDS.get(piece.slot, "")), px)


static func item_icon(item: ItemData, px: float) -> Texture2D:
	if item == null or not IconArt.has_item_icon(item):
		return null
	return IconArt.item_texture(item, px)


## A piece of equipment or an item as a card-sized pane, in the one display order (`GearText`): the icon, the name, the slot
## and rarity, what it does, then the flavour text in italics under a thin line.
static func gear_card(title: String, kind_line: String, effect: String, flavour: String, icon: Texture2D, size: Vector2, rarity_colour: Color = GlassTheme.TITLE) -> PanelContainer:
	var card: PanelContainer = plaque(0.94, Color("1c1838"), rarity_colour, 20, 18.0)
	card.name = "GearCard"
	card.custom_minimum_size = size
	var box: VBoxContainer = UIKit.vbox(8)
	card.add_child(box)
	if icon != null:
		var picture: TextureRect = TextureRect.new()
		picture.name = "Icon"
		picture.texture = icon
		picture.custom_minimum_size = Vector2(size.x * 0.44, size.x * 0.44)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(picture)
	var name_label: Label = text(title, 34, GlassTheme.TITLE)
	name_label.name = "Name"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_label)
	var kind_label: Label = text(kind_line, 24, rarity_colour.lerp(GlassTheme.SECONDARY, 0.35))
	kind_label.name = "Kind"
	kind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kind_label)
	var effect_label: Label = text(effect, 27, GlassTheme.TEXT)
	effect_label.name = "Effect"
	box.add_child(effect_label)
	if not flavour.is_empty():
		var line: ColorRect = ColorRect.new()
		line.color = Color(GlassTheme.GOLD_LINE, 0.45)
		line.custom_minimum_size = Vector2(0, 2)
		box.add_child(line)
		var flavour_label: Label = text(flavour, 23, GlassTheme.SECONDARY)
		flavour_label.name = "Flavour"
		flavour_label.add_theme_font_override("font", UIStyle.font_italic())
		box.add_child(flavour_label)
	return card


static func equipment_card(piece: EquipmentData, size: Vector2) -> PanelContainer:
	return gear_card(GearText.name_of(piece), GearText.kind_line(piece), GearText.effect(piece), GearText.flavour(piece), equipment_icon(piece, size.x * 0.44), size, CardView.RARITY_COLORS[clampi(int(piece.rarity), 0, 3)])


static func item_card(item: ItemData, size: Vector2) -> PanelContainer:
	return gear_card(item.display_name, GearText.item_kind_line(item), GearText.item_effect(item), "", item_icon(item, size.x * 0.44), size)


## The pack id as words for a reward line ("a Gilded Beefcake Pack").
static func pack_name(pack_id: String) -> String:
	var pack: PackData = PackCatalog.find(pack_id)
	return pack.display_name if pack != null else pack_id


## A reward as one sentence: "140 gold, 80 XP, a Beefcake Pack".
static func reward_words(pay: Dictionary) -> String:
	var parts: PackedStringArray = []
	if int(pay.get("gold", 0)) > 0:
		parts.append("%d gold" % int(pay["gold"]))
	if int(pay.get("xp", 0)) > 0:
		parts.append("%d XP" % int(pay["xp"]))
	for pack: Variant in pay.get("packs", []) as Array:
		parts.append(pack_name(str(pack)))
	if pay.has("equipment") and Session.content != null and Session.content.equipment_piece(str(pay["equipment"])) != null:
		parts.append(Session.content.equipment_piece(str(pay["equipment"])).source_name)
	return ", ".join(parts) if not parts.is_empty() else "nothing this time"
