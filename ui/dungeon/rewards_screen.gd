class_name RewardsScreen
extends Control
## After a victory: gold, a choice of one card, and (after the boss) the Wellspring's attunement.

var _offer: RewardOffer
var _panel: PanelContainer
var _column: VBoxContainer
var _cards: Array[CardView] = []
var _selected: int = -1
var _take_button: FancyButton
var _screenshot_args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = false
	Audio.play_music(&"map")
	if Session.pending_reward == null:
		# Launched directly (screenshots): fake a boss reward.
		Session.ensure_game()
		var offer: RewardOffer = RewardOffer.new()
		offer.gold = 120
		offer.enemy_name = "Hollow Warden"
		offer.is_boss = str(_screenshot_args.get("boss", "true")) == "true"
		offer.cards = RewardGenerator.card_choices(Session.content, Session.profile, Session.rng, 3, offer.is_boss)
		Session.pending_reward = offer
		Session.trial_finished = offer.is_boss
	_offer = Session.pending_reward
	add_child(ArenaBackdrop.new())
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.07, 0.6)
	UIKit.full_rect(dim)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	add_child(UIKit.vignette(0.85))
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_build_rewards()
	Audio.sfx(&"victory")


func _build_rewards() -> void:
	_column.add_child(UIKit.label("Victory!", &"TitleLabel", 72, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_column.add_child(UIKit.label("%s is defeated." % _offer.enemy_name, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	var gold_row: HBoxContainer = UIKit.hbox(12)
	gold_row.alignment = BoxContainer.ALIGNMENT_CENTER
	gold_row.add_child(CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(44, 44)))
	var gold_label: Label = UIKit.label("+0 gold", &"", 40, UIStyle.GOLD)
	gold_label.add_theme_font_override("font", UIStyle.font_title())
	gold_row.add_child(gold_label)
	_column.add_child(gold_row)
	var count: Tween = create_tween()
	count.tween_interval(0.4)
	count.tween_method(func(value: float) -> void: gold_label.text = "+%d gold" % roundi(value), 0.0, float(_offer.gold), 0.8)
	count.tween_callback(func() -> void: Audio.sfx(&"coins"))
	if _offer.cards.is_empty():
		_add_buttons()
		return
	_column.add_child(UIKit.label("Choose a card to add to your collection", &"HeadingLabel", 28, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(22)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(row)
	for index: int in range(_offer.cards.size()):
		var holder: Control = Control.new()
		holder.custom_minimum_size = CardView.SIZE * 0.8
		var view: CardView = CardView.create(_offer.cards[index], CardView.Mode.FULL)
		holder.add_child(view)
		CardView.fit(view, 0.8)
		view.gui_event.connect(func(_v: CardView, event: InputEvent) -> void:
			var click: InputEventMouseButton = event as InputEventMouseButton
			if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
				_select(index))
		view.hovered.connect(func(_v: CardView) -> void:
			Audio.sfx(&"card_hover", -12.0)
			if _selected != index:
				create_tween().tween_property(view, "position:y", view.position.y - 14.0, 0.1))
		view.unhovered.connect(func(_v: CardView) -> void:
			if _selected != index:
				create_tween().tween_property(view, "position:y", -CardView.SIZE.y * 0.1, 0.1))
		row.add_child(holder)
		_cards.append(view)
	_add_buttons()


func _add_buttons() -> void:
	var buttons: HBoxContainer = UIKit.hbox(16)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(buttons)
	_take_button = FancyButton.make("Take card" if not _offer.cards.is_empty() else "Continue", &"PrimaryButton", Vector2(240, 60))
	_take_button.disabled = not _offer.cards.is_empty()
	_take_button.pressed.connect(_confirm)
	buttons.add_child(_take_button)
	if not _offer.cards.is_empty():
		var skip: FancyButton = FancyButton.make("Skip card", &"", Vector2(200, 60))
		skip.pressed.connect(func() -> void:
			_selected = -1
			_confirm())
		buttons.add_child(skip)


func _select(index: int) -> void:
	_selected = index
	Audio.sfx(&"ui_select")
	for i: int in range(_cards.size()):
		_cards[i].set_glow(CardView.Glow.SELECTED if i == index else CardView.Glow.NONE)
		_cards[i].modulate = Color.WHITE if i == index else Color(0.7, 0.7, 0.78)
	_take_button.disabled = false
	_take_button.text = "Take %s" % _offer.cards[index].display_name


func _confirm() -> void:
	if _selected >= 0:
		_offer.taken = _offer.cards[_selected]
	var was_boss: bool = _offer.is_boss
	var first_clear: bool = not Session.flag(&"trial_cleared")
	var continues: bool = Session.apply_rewards()
	if continues or not was_boss:
		SceneManager.change_scene("res://scenes/dungeon_map.tscn")
		return
	Session.complete_trial()
	if first_clear:
		_show_starting_deck_choice()
	else:
		_show_trial_complete()


## First clear only: the Hollow is done, but there is no deck or town yet - pick one now.
func _show_starting_deck_choice() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	Audio.sfx(&"victory")
	_column.add_child(UIKit.label("Trial Complete", &"TitleLabel", 64, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label("The Hollow is cleared. Somewhere beyond it, a road leads to a town - but first, choose the deck you will carry there.", &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1100, 0)
	_column.add_child(text)
	var next: FancyButton = FancyButton.make("Choose your deck", &"PrimaryButton", Vector2(300, 62))
	next.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	next.pressed.connect(_open_deck_choice)
	_column.add_child(next)
	UIKit.pop_in(_panel)


func _open_deck_choice() -> void:
	# The overlay covers the screen visually, but its own "Choose <deck>" confirm button also
	# reads "Choose" - hide this button/panel so nothing underneath is left clickable (or found
	# by a text search) while the choice is open.
	_panel.visible = false
	var choice: StartingDeckChoiceScreen = StartingDeckChoiceScreen.new()
	add_child(choice)
	choice.chosen.connect(func(color: Affinity.Type) -> void:
		Session.choose_starting_deck(color)
		Audio.sfx(&"heal")
		Audio.sfx(&"ui_confirm")
		Session.town_notice = "The %s deck is yours. The road to town is open." % UIStyle.affinity_name(color)
		SceneManager.go_to_town())


## A replay of the trial (already cleared once): a short recap, then back to town.
func _show_trial_complete() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	Audio.sfx(&"victory")
	_column.add_child(UIKit.label("Trial Complete", &"TitleLabel", 64, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label("The Hollow is quiet again. You gather what it offered and head back to town.", &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1100, 0)
	_column.add_child(text)
	var home: FancyButton = FancyButton.make("Return to town", &"PrimaryButton", Vector2(300, 62))
	home.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	home.pressed.connect(func() -> void:
		Session.town_notice = ""
		SceneManager.go_to_town())
	_column.add_child(home)
	UIKit.pop_in(_panel)
