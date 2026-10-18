class_name DeckRack
extends Control
## Playtest v0.4.0, Part F: the ten saved-deck slots of the Deck Station, drawn into the empty slot racks painted at the top and the
## bottom of the station's own background (UI-BG-DECKBUILDER: a five-slot rack along the top, a seven-slot rack along the bottom - the
## middle five are used). Each tile shows the deck's cover card, its name, its size and its Path icons; an empty open slot shows "+";
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
const COVER_SCALE: float = 0.22
const INSET: Vector2 = Vector2(6, 6)

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
	var strip: HBoxContainer = UIKit.hbox(6)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(strip)
	var holder: Control = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.custom_minimum_size = CardView.SIZE * COVER_SCALE
	strip.add_child(holder)
	if cover != null:
		var view: CardView = CardView.create(cover, CardView.Mode.FULL, true)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(view)
		CardView.fit(view, COVER_SCALE)
		for child: Node in view.find_children("*", "Control", true, false):
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var text_box: VBoxContainer = UIKit.vbox(0)
	text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	strip.add_child(text_box)
	var name_label: Label = _label(saved.name, 14, UIStyle.PARCHMENT)
	name_label.custom_minimum_size = Vector2(rect.size.x - CardView.SIZE.x * COVER_SCALE - 30.0, 0)
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_box.add_child(name_label)
	var line: HBoxContainer = UIKit.hbox(3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.add_child(line)
	var count: Label = _label("%d" % saved.card_count(), 13, UIStyle.MUTED)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	line.add_child(count)
	for path: Affinity.Type in DeckSlots.paths_of(saved.card_ids, Session.deck_lookup()):
		var icon: TextureRect = IconArt.rect(IconArt.energy_id(path), 18.0, "%s Path" % UIStyle.affinity_name(path))
		if icon != null:
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			line.add_child(icon)
	if index == box.active:
		var badge: Label = _label("In use", 12, UIStyle.GOOD)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		text_box.add_child(badge)
	tile.tooltip_text = "%s (%d cards)%s" % [saved.name, saved.card_count(), "\nSaving here overwrites it." if save_mode else "\nClick to open it."]
	return tile


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = UIKit.label(text, &"", font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
