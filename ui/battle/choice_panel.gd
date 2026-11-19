class_name ChoicePanel
extends Control
## Overnight Nov 19 (Part 1.1): a choice the engine used to make for the player (GameState.choice_requests): the unit an opponent's
## edict destroys, a triggered ability's target, a card a pick(...) takes, a "choose one" or a "you may". Units on the table are also
## picked by clicking them on the board (the battle screen highlights them); this panel names the choice and gives a button per
## option for keyboard and controller. Cards off the table (a Refuse Pile) show as small cards with a button under each.
## Emits `chosen(answer)` - a uid, or the option index for choose/may.

signal chosen(answer: int)

const CARD_SCALE: float = 0.5

var prompt: String = ""
var options: Array[int] = []
var labels: Array[String] = []
## Option -> CardData for card options (empty for choose/may).
var cards: Dictionary = {}
## True when every option is a card on the table: the panel docks at the top and leaves the board clickable.
var on_board: bool = false


static func make(request_prompt: String, request_options: Array[int], request_labels: Array[String], option_cards: Dictionary, board: bool) -> ChoicePanel:
	var panel: ChoicePanel = ChoicePanel.new()
	panel.prompt = request_prompt
	panel.options = request_options.duplicate()
	panel.labels = request_labels.duplicate()
	panel.cards = option_cards
	panel.on_board = board
	return panel


func _ready() -> void:
	name = "ChoicePanel"
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE if on_board else Control.MOUSE_FILTER_STOP
	if not on_board:
		var dim: ColorRect = ColorRect.new()
		dim.color = Color(0.02, 0.01, 0.04, 0.55)
		dim.mouse_filter = Control.MOUSE_FILTER_STOP
		UIKit.full_rect(dim)
		add_child(dim)
	var frame: PanelContainer = UIKit.panel()
	frame.name = "ChoiceFrame"
	add_child(frame)
	var column: VBoxContainer = UIKit.vbox(10)
	frame.add_child(UIKit.margin(column, 14))
	column.add_child(UIKit.label("Your choice", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label(prompt, &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(520, 0)
	column.add_child(text)
	if on_board:
		column.add_child(UIKit.label("Click a highlighted unit on the table, or pick it here.", &"", 18, UIStyle.PARCHMENT.darkened(0.15), HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for i: int in range(options.size()):
		row.add_child(_option(i))
	frame.reset_size()
	var view: Vector2 = Vector2(1920, 1080)
	var size_now: Vector2 = frame.get_combined_minimum_size()
	# Docked under the opponent's hand when the board stays clickable; centred otherwise.
	frame.position = Vector2((view.x - size_now.x) * 0.5, 250.0 if on_board else (view.y - size_now.y) * 0.5)
	UIKit.pop_in(frame)
	PadFocus.register(self)


func _option(i: int) -> Control:
	var option: int = options[i]
	var text: String = labels[i] if i < labels.size() else ""
	var data: CardData = cards.get(option) as CardData
	if data != null and text.is_empty():
		text = data.display_name
		if data.is_unit():
			text += "  %d/%d" % [data.attack, data.defense]
	var column: VBoxContainer = UIKit.vbox(6)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	if data != null and not on_board:
		column.add_child(CardView.wrapped(data, CARD_SCALE))
	var button: FancyButton = FancyButton.make(text, &"PrimaryButton" if i == 0 else &"", Vector2(maxf(150.0, 13.0 * text.length()), 50))
	button.name = "Option%d" % i
	button.pressed.connect(func() -> void: chosen.emit(option))
	column.add_child(button)
	return column
