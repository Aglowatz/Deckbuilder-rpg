class_name DeckPicker
extends Control
## Brief 16, Group E: "which deck do you take in?" - shown before entering a dungeon or an arena encounter when the player has more than one saved deck. Each deck shows
## its name, size, Paths and whether it is legal (or why not, or which cards you no longer own). Choosing a deck makes it the active one (`Session.use_deck`) and carries on.
## With a single saved deck nothing is shown and the action simply goes ahead.

signal chosen(index: int)
signal cancelled


## Runs `proceed` straight away when there is only one deck, otherwise asks first. `on_cancel` runs when the player backs out.
static func guard(layer: Control, proceed: Callable, on_cancel: Callable = Callable()) -> DeckPicker:
	if Session.deck_box.size() < 2:
		proceed.call()
		return null
	var picker: DeckPicker = DeckPicker.new()
	layer.add_child(picker)
	picker.chosen.connect(func(_index: int) -> void:
		picker.queue_free()
		proceed.call())
	picker.cancelled.connect(func() -> void:
		picker.queue_free()
		if on_cancel.is_valid():
			on_cancel.call())
	return picker


func _ready() -> void:
	name = "DeckPicker"
	UIKit.full_rect(self)
	z_index = 210
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.8)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(980, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose your deck", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.label("The deck you pick is the one you fight with.", &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var list: VBoxContainer = UIKit.vbox(6)
	column.add_child(list)
	for index: int in range(Session.deck_box.size()):
		list.add_child(_row(index))
	var back: FancyButton = FancyButton.make("Cancel", &"", Vector2(220, 52))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.name = "CancelButton"
	back.pressed.connect(func() -> void: cancelled.emit())
	column.add_child(back)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open", -4.0)


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		cancelled.emit()


func _row(index: int) -> Control:
	var saved: DeckBox.SavedDeck = Session.deck_box.decks[index]
	var deck: Deck = Session.deck_box.build(index, Session.deck_lookup())
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, Session.profile, null, true)
	var warnings: Array[String] = Session.deck_warnings(index)
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "Deck%d" % index
	var row: HBoxContainer = UIKit.hbox(14)
	panel.add_child(row)
	var text: VBoxContainer = UIKit.vbox(2)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	var title: String = "%d. %s%s" % [index + 1, saved.name, "   (in use)" if index == Session.deck_box.active else ""]
	var heading: Label = UIKit.label(title, &"", 28, UIStyle.GOLD)
	heading.add_theme_font_override("font", UIStyle.font_bold())
	text.add_child(heading)
	var paths: Array[String] = []
	for path: Affinity.Type in deck.colors():
		paths.append(UIStyle.affinity_name(path))
	text.add_child(UIKit.label("%d cards  |  %s" % [deck.size(), ", ".join(paths) if not paths.is_empty() else "no Paths yet"], &"", 21, UIStyle.PARCHMENT))
	var ready: bool = issues.is_empty()
	if not ready:
		text.add_child(UIKit.label("Not ready: %s" % issues[0].message, &"", 19, Color("ff9d98")))
	elif not warnings.is_empty():
		text.add_child(UIKit.label("Warning: %s" % " ".join(warnings), &"", 19, Color("ffb066")))
	else:
		text.add_child(UIKit.label("Ready", &"", 19, UIStyle.GOOD))
	var use: FancyButton = FancyButton.make("Use this deck", &"PrimaryButton", Vector2(200, 52))
	use.name = "UseButton%d" % index
	use.disabled = not ready
	use.tooltip_text = "" if ready else "This deck is not legal yet. Fix it in the Deck Station (B)."
	use.pressed.connect(func() -> void:
		if Session.use_deck(index):
			chosen.emit(index))
	row.add_child(use)
	return panel
