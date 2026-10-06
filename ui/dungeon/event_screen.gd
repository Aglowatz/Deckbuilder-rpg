class_name EventScreen
extends Control
## A story event of a zone dungeon (Part E): the event's title and text, one button per choice (with a small
## hint of what it does), then the result text. Choices that need gold are disabled while you are short.
## An outcome that chains into another event ("forms that require other forms") swaps the screen to
## that event. Mechanics: `DungeonEvent` / `EventResolver`; text: the zone story (`event.<id>.*`).

signal finished

var event: DungeonEvent
var zone_id: String = ""
var _story: ZoneStoryText
var _column: VBoxContainer
var _panel: PanelContainer
var _buttons: Array[FancyButton] = []
var _resolved: bool = false


static func make(first_event: DungeonEvent, zone: String) -> EventScreen:
	var screen: EventScreen = EventScreen.new()
	screen.name = "EventScreen"
	screen.event = first_event
	screen.zone_id = zone
	return screen


func _ready() -> void:
	UIKit.full_rect(self)
	_story = ZoneStoryText.for_zone(zone_id)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.84)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	_panel.custom_minimum_size = Vector2(1100, 0)
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_show_event()
	Audio.sfx(&"ui_open")


func _show_event() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	_buttons.clear()
	_resolved = false
	var title: Label = UIKit.label(_story.text(event.title_key()), &"TitleLabel", 50, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "EventTitle"
	_column.add_child(title)
	var body: Label = UIKit.label(_story.text(event.body_key()), &"", 25, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	body.name = "EventBody"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(1000, 0)
	_column.add_child(body)
	_column.add_child(UIKit.spacer(6))
	for index: int in range(event.choices.size()):
		var choice: DungeonEvent.Choice = event.choices[index]
		var hint: String = choice.hint()
		var label: String = _story.text(event.choice_key(index))
		var button: FancyButton = FancyButton.make("%s%s" % [label, ("   (%s)" % hint) if not hint.is_empty() else ""], &"", Vector2(1000, 62))
		button.name = "Choice%d" % index
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.disabled = choice.gold_cost() > Session.gold
		if button.disabled:
			button.tooltip_text = "You need %d gold." % choice.gold_cost()
		button.pressed.connect(_choose.bind(index))
		_column.add_child(button)
		_buttons.append(button)
	UIKit.pop_in(_panel)


func _choose(index: int) -> void:
	if _resolved:
		return
	var result: EventResolver.Result = Session.resolve_dungeon_event(event, index)
	if not result.ok:
		Audio.sfx(&"ui_error")
		return
	_resolved = true
	Audio.sfx(&"ui_confirm")
	for child: Node in _column.get_children():
		child.queue_free()
	_column.add_child(UIKit.label(_story.text(event.title_key()), &"TitleLabel", 50, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label(_story.text(event.result_key(index)), &"", 25, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.name = "EventResult"
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1000, 0)
	_column.add_child(text)
	for line: String in _summary_lines(result):
		var row: Label = UIKit.label(line, &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		_column.add_child(row)
	var go: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(260, 60))
	go.name = "EventContinue"
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.pressed.connect(_continue.bind(result))
	_column.add_child(go)
	UIKit.pop_in(_panel)


func _summary_lines(result: EventResolver.Result) -> Array[String]:
	var lines: Array[String] = []
	if result.hp_delta > 0:
		lines.append("+%d HP" % result.hp_delta)
	elif result.hp_delta < 0:
		lines.append("%d HP" % result.hp_delta)
	if result.gold_delta > 0:
		lines.append("+%d gold" % result.gold_delta)
	elif result.gold_delta < 0:
		lines.append("%d gold" % result.gold_delta)
	for boon: ModifierSource in result.boons:
		lines.append("Boon: %s" % boon.source_name)
	for card: CardData in result.cards:
		lines.append("Card: %s" % card.display_name)
	return lines


func _continue(result: EventResolver.Result) -> void:
	if not result.next_event.is_empty():
		var next_event: DungeonEvent = MainDungeons.def(zone_id).event(result.next_event)
		if next_event != null:
			event = next_event
			_show_event()
			return
	finished.emit()
