class_name DeckRack
extends Control
## Playtest v0.4.0, Part F: the ten saved-deck slots of the Deck Station, drawn into the empty slot racks painted at the top and the
## bottom of the station's own background (UI-BG-DECKBUILDER: a five-slot rack along the top, a seven-slot rack along the bottom - the
## middle five are used). A saved deck's tile is its cover card's painting with the name on a banner, its Path icons and an In use chip; an empty open slot shows "+";
## a locked slot a padlock and the level that opens it. Click a slot to open that deck (or start a new one there); in `save_mode`
## a click means "save here". The same ten slots as `DeckBox` / `DeckSlots` (4 open at the start, +2 at levels 7, 14 and 21).

signal slot_pressed(slot: int)

## The painted background's size and its racks, measured on the image (pixels of the 1536x1024 picture): the top rack's five cells
## and the bottom rack's seven cells, as x ranges plus one y range each.
const ART_SIZE: Vector2 = Vector2(1536, 1024)
const TOP_Y: Vector2 = Vector2(42, 186)
const TOP_X: Array[Vector2] = [Vector2(400, 548), Vector2(552, 700), Vector2(704, 852), Vector2(856, 1004), Vector2(1008, 1148)]
const BOTTOM_Y: Vector2 = Vector2(768, 936)
const BOTTOM_X: Array[Vector2] = [Vector2(412, 548), Vector2(556, 692), Vector2(700, 836), Vector2(844, 980), Vector2(988, 1124)]
const INSET: Vector2 = Vector2(6, 6)
## UI + economy fixes Oct 22, Part 2: the even margin between a slot's edge and its cover painting.
const ART_MARGIN: float = 5.0

var highlight: int = -1
var save_mode: bool = false
var tiles: Array[FancyButton] = []
## The canvas the rack lays itself out on (the station's full-screen size); `rebuild` reads it.
var canvas: Vector2 = Vector2(1920, 1080)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rebuild()


## Where slot `slot` sits on a canvas of `view` pixels: the painted rack cell, mapped through the background's "keep aspect, covered" fit.
static func cell_rect(slot: int, view: Vector2) -> Rect2:
	var scale_factor: float = maxf(view.x / ART_SIZE.x, view.y / ART_SIZE.y)
	var offset: Vector2 = (view - ART_SIZE * scale_factor) * 0.5
	var xs: Vector2 = TOP_X[slot] if slot < 5 else BOTTOM_X[slot - 5]
	var ys: Vector2 = TOP_Y if slot < 5 else BOTTOM_Y
	var rect: Rect2 = Rect2(Vector2(xs.x, ys.x) * scale_factor + offset, Vector2(xs.y - xs.x, ys.y - ys.x) * scale_factor)
	# The covered fit crops a strip top and bottom at 16:9: keep the tile on screen with a small margin.
	rect.position.y = clampf(rect.position.y, 8.0, view.y - rect.size.y - 8.0)
	return rect.grow_individual(-INSET.x, -INSET.y, -INSET.x, -INSET.y)


func rebuild() -> void:
	for tile: FancyButton in tiles:
		tile.queue_free()
	tiles.clear()
	for slot: int in range(DeckSlots.SLOT_COUNT):
		var tile: FancyButton = _tile(slot, cell_rect(slot, canvas))
		add_child(tile)
		tile.focus_mode = Control.FOCUS_ALL
		tiles.append(tile)


func focus_slot(slot: int) -> void:
	if slot >= 0 and slot < tiles.size() and tiles[slot].is_inside_tree():
		tiles[slot].focus_mode = Control.FOCUS_ALL
		tiles[slot].grab_focus()


func _tile(slot: int, rect: Rect2) -> FancyButton:
	var box: DeckBox = Session.deck_box
	var index: int = box.index_in_slot(slot)
	var open: bool = Session.slot_open(slot)
	var tile: FancyButton = FancyButton.make("", &"GhostButton", rect.size)
	tile.name = "Slot%d" % (slot + 1)
	tile.position = rect.position
	tile.size = rect.size
	var rim: Color = UIStyle.GOLD if slot == highlight else Color(1, 1, 1, 0.12)
	tile.add_theme_stylebox_override("normal", UIStyle.box(Color(0.06, 0.04, 0.1, 0.55 if open else 0.7), rim, 3 if slot == highlight else 1, 8))
	tile.add_theme_stylebox_override("hover", UIStyle.box(Color(0.12, 0.08, 0.18, 0.85), UIStyle.GOLD, 2, 8))
	tile.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), Color("ffe08a"), 3, 8))
	tile.focus_mode = Control.FOCUS_ALL
	tile.pressed.connect(func() -> void:
		if not open:
			Audio.sfx(&"ui_error", -4.0)
		slot_pressed.emit(slot))
	var column: VBoxContainer = UIKit.vbox(2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.position = Vector2(6, 4)
	column.size = rect.size - Vector2(12, 8)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(column)
	if not open:
		tile.tooltip_text = "Opens at level %d." % DeckSlots.level_for_slot(slot)
		var lock: TextureRect = IconArt.rect("ICON-PADLOCK", 40.0)
		if lock != null:
			lock.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			column.add_child(lock)
		column.add_child(_label("Level %d" % DeckSlots.level_for_slot(slot), 15, UIStyle.MUTED))
		tile.modulate = Color(0.8, 0.8, 0.85, 1.0)
		return tile
	if index < 0:
		column.add_child(_label("+" if not save_mode else "Save here", 30 if not save_mode else 17, UIStyle.PARCHMENT))
		column.add_child(_label("Empty slot %d" % (slot + 1), 13, UIStyle.MUTED))
		tile.tooltip_text = "An empty slot: start a new deck here." if not save_mode else "Save the deck into slot %d." % (slot + 1)
		return tile
	var saved: DeckBox.SavedDeck = box.decks[index]
	var cover: CardData = Session.card_by_id(DeckSlots.cover_id(saved.card_ids, Session.deck_lookup(), saved.cover_id))
	var paths: Array[Affinity.Type] = DeckSlots.paths_of(saved.card_ids, Session.deck_lookup())
	var face: Control = cover_tile(cover, rect.size, saved.name, paths, index == box.active)
	tile.add_child(face)
	# Hover shows the deck's size over the art.
	var count: Label = _chip("%d cards" % saved.card_count(), 13, UIStyle.PARCHMENT)
	count.name = "CardCount"
	count.position = Vector2((rect.size.x - 76.0) * 0.5, rect.size.y * 0.42)
	count.size = Vector2(76, 22)
	count.visible = false
	tile.add_child(count)
	tile.mouse_entered.connect(func() -> void: count.visible = true)
	tile.mouse_exited.connect(func() -> void: count.visible = false)
	tile.focus_entered.connect(func() -> void: count.visible = true)
	tile.focus_exited.connect(func() -> void: count.visible = false)
	tile.tooltip_text = "%s (%d cards)%s" % [saved.name, saved.card_count(), "\nSaving here overwrites it." if save_mode else "\nClick to open it."]
	return tile


## UI + economy fixes Oct 22, Part 2: a saved deck's slot face - the cover card's painting filling the slot almost edge to edge (a small
## even margin, cut by `CardArt.cropped` so the head shows), the deck's name on a banner along the bottom, its Path icons in the top-left
## corner and a small "In use" chip in the top-right for the active deck. Also used by tools/card_crop_sheet.gd.
static func cover_tile(cover: CardData, tile_size: Vector2, deck_name: String, paths: Array[Affinity.Type], in_use: bool) -> Control:
	var face: Control = Control.new()
	face.name = "CoverFace"
	face.size = tile_size
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var window: Rect2 = Rect2(Vector2(ART_MARGIN, ART_MARGIN), tile_size - Vector2(ART_MARGIN, ART_MARGIN) * 2.0)
	var art: Texture2D = CardArt.cropped(cover.id, window.size, 1.0, true) if cover != null else null
	if art != null:
		var picture: TextureRect = TextureRect.new()
		picture.name = "CoverArt"
		picture.texture = art
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.position = window.position
		picture.size = window.size
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face.add_child(picture)
	else:
		var plain: ColorRect = ColorRect.new()
		plain.color = UIStyle.affinity_color(cover.color).darkened(0.55) if cover != null else Color(0.1, 0.08, 0.14)
		plain.position = window.position
		plain.size = window.size
		plain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face.add_child(plain)
	# The banner: a dark band across the bottom with the deck's name (shrunk to fit one line, then cut with an ellipsis).
	var banner_height: float = clampf(tile_size.y * 0.2, 24.0, 34.0)
	var banner: Panel = Panel.new()
	banner.name = "NameBanner"
	banner.position = Vector2(window.position.x, window.end.y - banner_height)
	banner.size = Vector2(window.size.x, banner_height)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_theme_stylebox_override("panel", UIStyle.box(Color(0.05, 0.03, 0.09, 0.86), UIStyle.GOLD_DIM, 1, 4))
	face.add_child(banner)
	var name_label: Label = UIKit.label(deck_name, &"", 15, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "DeckName"
	name_label.add_theme_font_override("font", UIStyle.font_bold())
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.position = Vector2(4, 0)
	name_label.size = Vector2(banner.size.x - 8.0, banner_height)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font: Font = UIStyle.font_bold()
	var font_size: int = 15
	while font_size > 11 and font.get_string_size(deck_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > name_label.size.x:
		font_size -= 1
	name_label.add_theme_font_size_override("font_size", font_size)
	banner.add_child(name_label)
	# The Path icons, top-left, on a small dark backing so they read on any painting.
	if not paths.is_empty():
		var icons: HBoxContainer = UIKit.hbox(2)
		icons.name = "PathIcons"
		icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var backing: PanelContainer = PanelContainer.new()
		backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var backing_box: StyleBoxFlat = UIStyle.box(Color(0.05, 0.03, 0.09, 0.78), Color(0, 0, 0, 0), 0, 10)
		backing_box.content_margin_left = 3
		backing_box.content_margin_right = 3
		backing_box.content_margin_top = 2
		backing_box.content_margin_bottom = 2
		backing.add_theme_stylebox_override("panel", backing_box)
		backing.position = window.position + Vector2(3, 3)
		backing.add_child(icons)
		for path: Affinity.Type in paths:
			var icon: TextureRect = IconArt.rect(IconArt.energy_id(path), 20.0, "%s Path" % UIStyle.affinity_name(path))
			if icon != null:
				icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
				icons.add_child(icon)
		face.add_child(backing)
	if in_use:
		var chip: Label = _chip("In use", 12, UIStyle.GOOD)
		chip.name = "InUse"
		chip.size = Vector2(52, 20)
		chip.position = Vector2(window.end.x - chip.size.x - 3.0, window.position.y + 3.0)
		face.add_child(chip)
	return face


## A small rounded label on a dark backing.
static func _chip(text: String, font_size: int, color: Color) -> Label:
	var chip: Label = UIKit.label(text, &"", font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	chip.add_theme_font_override("font", UIStyle.font_bold())
	chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip.add_theme_stylebox_override("normal", UIStyle.box(Color(0.04, 0.03, 0.07, 0.88), color.darkened(0.2), 1, 9))
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return chip


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = UIKit.label(text, &"", font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
