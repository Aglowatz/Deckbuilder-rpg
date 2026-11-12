class_name EventScreen
extends Control
## A story event of a zone dungeon (Part E): the event's title and text, one button per choice (with a small
## hint of what it does), then the result text. Choices that need gold are disabled while you are short.
## An outcome that chains into another event ("forms that require other forms") swaps the screen to
## that event. Mechanics: `DungeonEvent` / `EventResolver`; text: the zone story (`event.<id>.*`).
## Fable Nov 12c (Part B): built on `NodeCard` (an event, or a rescue when the room is one): the room's corner of the dungeon map as the
## banner, the choices as a column of buttons, what a choice changed as chips with icons.

signal finished

var event: DungeonEvent
var zone_id: String = ""
var card: NodeCard
var _story: ZoneStoryText
var _buttons: Array[FancyButton] = []
var _resolved: bool = false
var _music_token: int = 0


static func make(first_event: DungeonEvent, zone: String) -> EventScreen:
	var screen: EventScreen = EventScreen.new()
	screen.name = "EventScreen"
	screen.event = first_event
	screen.zone_id = zone
	return screen


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	UIKit.full_rect(self)
	var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
	_story = ZoneStoryText.for_zone(dungeon.zone_id if dungeon != null else zone_id)
	var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", -1))) if Session.dungeon_map != null and has_meta("node_id") else null
	var rescue: bool = node != null and node.kind == DungeonMap.Kind.RESCUE
	card = NodeCard.make(NodeCard.Kind.RESCUE if rescue else NodeCard.Kind.EVENT, _story.text(event.title_key()), 980.0)
	add_child(card)
	card.title_label.name = "EventTitle"
	card.set_banner_for_node(node)
	_show_event()
	Audio.sfx(&"ui_open")
	# The journals of the Archive, the prince's old cell: a few events carry a story cue over the dungeon's music.
	var cue: String = MusicDirector.story_node(event.id)
	if not cue.is_empty():
		_music_token = Audio.push_music(StringName(cue), 1.2, false)


func _exit_tree() -> void:
	if _music_token != 0:
		Audio.pop_music(_music_token, 1.5)
		_music_token = 0


func _show_event() -> void:
	card.clear_content()
	card.set_title(_story.text(event.title_key()))
	_buttons.clear()
	_resolved = false
	var body: Label = card.line(_story.text(event.body_key()), NodeCard.INK, 23)
	body.name = "EventBody"
	for index: int in range(event.choices.size()):
		var choice: DungeonEvent.Choice = event.choices[index]
		var hint: String = choice.hint()
		var label: String = _story.text(event.choice_key(index))
		var button: FancyButton = FancyButton.make("%s%s" % [label, ("   (%s)" % hint) if not hint.is_empty() else ""], &"PrimaryButton" if index == 0 and event.choices.size() == 1 else &"", Vector2(card.card_width - 130.0, 60))
		button.name = "Choice%d" % index
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.focus_mode = Control.FOCUS_ALL
		button.disabled = choice.gold_cost() > Session.gold
		if button.disabled:
			button.tooltip_text = "You need %d gold." % choice.gold_cost()
			button.text = "%s   (you need %d gold)" % [label, choice.gold_cost()]  # Fix pass Nov 4 (B): the reason on the button itself, not only a tooltip
		elif choice.gold_cost() > 0:
			IconArt.button_icon(button, "ICON-GOLD", 28.0)
		button.pressed.connect(_choose.bind(index))
		card.content.add_child(button)
		button.focus_mode = Control.FOCUS_ALL
		_buttons.append(button)
	for button: FancyButton in _buttons:
		if not button.disabled:
			button.call_deferred(&"grab_focus")
			break


func _choose(index: int) -> void:
	if _resolved:
		return
	var result: EventResolver.Result = Session.resolve_dungeon_event(event, index)
	if not result.ok:
		Audio.sfx(&"ui_error")
		return
	_resolved = true
	Audio.sfx(&"ui_confirm")
	card.clear_content()
	_buttons.clear()
	var result_text: String = _story.text(event.result_key(index))
	if not result.lost_cards.is_empty():
		result_text = result_text.replace("{card}", result.lost_cards[0].display_name)  # Fix pass Nov 4 (B): the result names the card that left
	var text: Label = card.line(result_text, NodeCard.INK, 23)
	text.name = "EventResult"
	for entry: Array in summary_chips(result):
		card.chip(str(entry[0]), str(entry[1]), entry[2] as Color)
	if result.hp_delta > 0:
		Audio.sfx(&"heal")
	var go: FancyButton = card.button("Continue", true, "", 260.0)
	go.name = "EventContinue"
	go.pressed.connect(_continue.bind(result))
	go.call_deferred(&"grab_focus")
	ConfirmKey.attach(card, go)  # Fresh eyes round 2 (Oct 31): E / Enter / Space / pad A continue


func _summary_lines(result: EventResolver.Result) -> Array[String]:
	var lines: Array[String] = []
	for entry: Array in summary_chips(result):
		lines.append(str(entry[1]))
	return lines


## What the choice changed, one chip each: [icon id, text, colour].
static func summary_chips(result: EventResolver.Result) -> Array[Array]:
	var chips: Array[Array] = []
	if result.hp_delta > 0:
		chips.append(["ICON-STAT-HP", "+%d HP" % result.hp_delta, NodeCard.GOOD_INK])
	elif result.hp_delta < 0:
		chips.append(["ICON-STAT-HP", "%d HP" % result.hp_delta, NodeCard.BAD_INK])
	if result.gold_delta > 0:
		chips.append(["ICON-GOLD", "+%d gold" % result.gold_delta, NodeCard.GOLD_INK])
	elif result.gold_delta < 0:
		chips.append(["ICON-GOLD", "%d gold" % result.gold_delta, NodeCard.BAD_INK])
	for boon: ModifierSource in result.boons:
		# Fixes Oct 27: what it does, not just its name
		chips.append(["ICON-MECH-BUFF", "%s: %s. %s" % [BoonText.kind_word(boon), boon.source_name, BoonText.describe(boon)], NodeCard.GOOD_INK if boon.source_kind == ModifierSource.SourceKind.BOON else NodeCard.BAD_INK])
	for gained: CardData in result.cards:
		chips.append(["ICON-UI-COLLECTION", "Card: %s" % gained.display_name, NodeCard.GOLD_INK])
	for lost: CardData in result.lost_cards:
		chips.append(["ICON-UI-DECK", "Lost for this run: %s (back after the run)" % lost.display_name, NodeCard.BAD_INK])
	return chips


func _continue(result: EventResolver.Result) -> void:
	if not result.next_event.is_empty():
		var next_event: DungeonEvent = MainDungeons.def(zone_id).event(result.next_event)
		if next_event != null:
			event = next_event
			_show_event()
			return
	Audio.sfx(&"ui_close")
	finished.emit()
