class_name LevelUpScreen
extends Control
## Part E: shown after a battle grants enough XP to level up (once or several times at once).
## Recaps what every level gained, then walks through any pending equipment-slot choices and
## "choose 1 of 3 cards" level rewards before finishing - so nothing is left half-resolved.

signal finished

var levels_gained: Array[LevelData] = []
var _panel: PanelContainer
var _column: VBoxContainer
var _child_screen: Control


func setup(gained: Array[LevelData]) -> void:
	levels_gained = gained


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.92)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	_panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_show_recap()


func _show_recap() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	var title: String = "Level Up!" if levels_gained.size() == 1 else "Level Up x%d!" % levels_gained.size()
	_column.add_child(UIKit.label(title, &"TitleLabel", 56, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var final_level: int = levels_gained[-1].level if not levels_gained.is_empty() else Session.profile.level
	_column.add_child(UIKit.label("Now level %d." % final_level, &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_column.add_child(scroll)
	var list: VBoxContainer = UIKit.vbox(8)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for row: LevelData in levels_gained:
		var line: Label = UIKit.label("Level %d - %s" % [row.level, row.summary], &"", 20, UIStyle.PARCHMENT)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(820, 0)
		list.add_child(line)
	var button: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(240, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_advance)
	_column.add_child(button)
	UIKit.pop_in(_panel)


## Resolves pending equipment choices, then pending card offers, one at a time; finishes once
## both are empty.
func _advance() -> void:
	if _child_screen != null:
		_child_screen.queue_free()
		_child_screen = null
	if Session.pending_equipment_choices > 0:
		_show_equipment_choice()
		return
	if not Session.pending_level_card_offers.is_empty():
		_show_card_offer(Session.pending_level_card_offers[0])
		return
	finished.emit()


func _show_equipment_choice() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	var choice: EquipmentSlotChoiceScreen = EquipmentSlotChoiceScreen.new()
	choice.chosen.connect(func(slot: EquipmentData.Slot) -> void:
		Session.choose_equipment_slot(slot)
		Audio.sfx(&"ui_confirm")
		_advance())
	_child_screen = choice
	add_child(choice)


func _show_card_offer(offer: RewardOffer) -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	_column.add_child(UIKit.label("A level reward: choose a card", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(20)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(row)
	for index: int in range(offer.cards.size()):
		var holder: Control = Control.new()
		holder.custom_minimum_size = CardView.SIZE * 0.75
		var view: CardView = CardView.create(offer.cards[index], CardView.Mode.FULL)
		holder.add_child(view)
		CardView.fit(view, 0.75)
		view.gui_event.connect(func(_v: CardView, event: InputEvent) -> void:
			var click: InputEventMouseButton = event as InputEventMouseButton
			if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
				Audio.sfx(&"ui_select")
				Session.resolve_level_card_offer(index)
				Audio.sfx(&"card_draw")
				_advance())
		row.add_child(holder)
	var skip: FancyButton = FancyButton.make("Skip", &"", Vector2(180, 54))
	skip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skip.pressed.connect(func() -> void:
		Session.resolve_level_card_offer(-1)
		_advance())
	_column.add_child(skip)
