class_name DeckBoxGrid
extends GridContainer
## Overnight Oct 17, Part 4: the Deck Station's ten slots, five across the top and five across the bottom (`DeckSlots`). A
## filled slot shows its cover card, name, card count and the icons of the Paths in it; an empty open slot shows "Empty";
## a locked slot a padlock and the level that opens it. Every tile is a focusable button (mouse, keyboard and pad).

signal slot_pressed(slot: int)

const COVER_SCALE: float = 0.4
const TILE_SIZE: Vector2 = Vector2(150, 262)

## The slot drawn with a gold rim (the deck being edited, or the save target).
var highlight: int = -1
## Save mode: empty open slots read "Save here" and filled ones "Overwrite".
var save_mode: bool = false
var tiles: Array[FancyButton] = []


func _ready() -> void:
	columns = DeckSlots.COLUMNS
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("h_separation", 12)
	add_theme_constant_override("v_separation", 12)
	rebuild()


func rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	tiles.clear()
	for slot: int in range(DeckSlots.SLOT_COUNT):
		var tile: FancyButton = _tile(slot)
		add_child(tile)
		tile.focus_mode = Control.FOCUS_ALL  # after FancyButton._ready, which turns focus off
		tiles.append(tile)


func focus_slot(slot: int) -> void:
	if slot >= 0 and slot < tiles.size():
		tiles[slot].call_deferred(&"grab_focus")


func _tile(slot: int) -> FancyButton:
	var box: DeckBox = Session.deck_box
	var index: int = box.index_in_slot(slot)
	var open: bool = Session.slot_open(slot)
	var tile: FancyButton = FancyButton.make("", &"GhostButton", TILE_SIZE)
	tile.name = "Slot%d" % (slot + 1)
	var rim: Color = UIStyle.GOLD if slot == highlight else Color(1, 1, 1, 0.14)
	tile.add_theme_stylebox_override("normal", UIStyle.box(Color(0.06, 0.04, 0.1, 0.82), rim, 3 if slot == highlight else 2, 12))
	tile.add_theme_stylebox_override("hover", UIStyle.box(Color(0.12, 0.08, 0.18, 0.92), UIStyle.GOLD, 2, 12))
	tile.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), Color("ffe08a"), 3, 12))
	var column: VBoxContainer = UIKit.vbox(4)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.position = Vector2(8, 6)
	column.size = TILE_SIZE - Vector2(16, 12)
	tile.add_child(column)
	if not open:
		tile.tooltip_text = "Opens at level %d." % DeckSlots.level_for_slot(slot)
		tile.pressed.connect(func() -> void:
			Audio.sfx(&"ui_error", -4.0)
			slot_pressed.emit(slot))
		column.add_child(_spacer(46))
		var lock: TextureRect = IconArt.rect("ICON-PADLOCK", 72.0)
		if lock != null:
			lock.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			column.add_child(lock)
		column.add_child(_label("Level %d" % DeckSlots.level_for_slot(slot), 22, UIStyle.MUTED))
		tile.modulate = Color(0.75, 0.75, 0.8, 1.0)
		return tile
	tile.pressed.connect(func() -> void: slot_pressed.emit(slot))
	if index < 0:
		column.add_child(_spacer(70))
		column.add_child(_label("+" if not save_mode else "Save here", 40 if not save_mode else 22, UIStyle.PARCHMENT))
		column.add_child(_label("Empty slot %d" % (slot + 1), 17, UIStyle.MUTED))
		tile.tooltip_text = "An empty slot: start a new deck here." if not save_mode else "Save the deck into slot %d." % (slot + 1)
		return tile
	var saved: DeckBox.SavedDeck = box.decks[index]
	var cover: CardData = Session.card_by_id(DeckSlots.cover_id(saved.card_ids, Session.deck_lookup(), saved.cover_id))
	var holder: Control = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.custom_minimum_size = CardView.SIZE * COVER_SCALE
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(holder)
	if cover != null:
		var view: CardView = CardView.create(cover, CardView.Mode.FULL)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(view)
		CardView.fit(view, COVER_SCALE)
		_ignore_mouse(view)
	column.add_child(_label(saved.name, 17, UIStyle.PARCHMENT))
	var line: HBoxContainer = UIKit.hbox(4)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(line)
	line.add_child(_label("%d" % saved.card_count(), 16, UIStyle.MUTED))
	for path: Affinity.Type in DeckSlots.paths_of(saved.card_ids, Session.deck_lookup()):
		var icon: TextureRect = IconArt.rect(IconArt.energy_id(path), 22.0, "%s Path" % UIStyle.affinity_name(path))
		if icon != null:
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			line.add_child(icon)
	if index == box.active:
		var badge: Label = _label("In use", 15, UIStyle.GOOD)
		badge.position = Vector2(TILE_SIZE.x - 62, 4)
		badge.size = Vector2(56, 20)
		tile.add_child(badge)
	tile.tooltip_text = "%s (%d cards)%s" % [saved.name, saved.card_count(), "\nSaving here overwrites it." if save_mode else ""]
	return tile


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = UIKit.label(text, &"", font_size, color, HORIZONTAL_ALIGNMENT_CENTER)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label


func _spacer(height: float) -> Control:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _ignore_mouse(node: Node) -> void:
	for child: Node in node.find_children("*", "Control", true, false):
		(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
