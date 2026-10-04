class_name ChallengeScreen
extends Control
## A deck challenge (the Hollow Well): reveal cards from your deck, see whether you passed and
## what it cost or gave. All resolution is done by core (ChallengeResolver).

signal finished

var challenge: ChallengeData
var _column: VBoxContainer
var _cards_row: HBoxContainer
var _result_box: VBoxContainer
var _reveal_button: FancyButton
var _resolved: bool = false


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.82)
	UIKit.full_rect(shade)
	add_child(shade)
	challenge = _pick_challenge()
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(1100, 0)
	center.add_child(panel)
	_column = UIKit.vbox(14)
	panel.add_child(_column)
	_column.add_child(UIKit.label(challenge.display_name, &"TitleLabel", 54, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var text: Label = UIKit.label(challenge.description, &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1000, 0)
	_column.add_child(text)
	_column.add_child(UIKit.label(_stakes_text(), &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_cards_row = UIKit.hbox(14)
	_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_row.custom_minimum_size = Vector2(0, 250)
	_column.add_child(_cards_row)
	_result_box = UIKit.vbox(6)
	_column.add_child(_result_box)
	_reveal_button = FancyButton.make("Reveal", &"PrimaryButton", Vector2(260, 60))
	_reveal_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_reveal_button.pressed.connect(_on_reveal)
	_column.add_child(_reveal_button)
	UIKit.pop_in(panel)
	Audio.sfx(&"ui_open")


func _pick_challenge() -> ChallengeData:
	if Session.main_dungeon_active:
		var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", 0)))
		var themed: ChallengeData = MainDungeons.def(Session.zone_def().id).challenge(node.challenge_id)
		if themed != null:
			return themed
	for candidate: ChallengeData in Session.content.challenges:
		if candidate.id == TrialOfTheHollow.CHALLENGE_ID:
			return candidate
	return Session.content.challenges[0]


func _stakes_text() -> String:
	var win: PackedStringArray = []
	for outcome: ChallengeOutcome in challenge.on_success:
		win.append(outcome.description)
	var lose: PackedStringArray = []
	for outcome: ChallengeOutcome in challenge.on_failure:
		lose.append(outcome.description)
	return "Pass: %s      Fail: %s" % [", ".join(win), ", ".join(lose)]


func _on_reveal() -> void:
	if _resolved:
		finished.emit()
		return
	_resolved = true
	_reveal_button.disabled = true
	var result: ChallengeResult = ChallengeResolver.resolve(challenge, Session.run, Session.rng)
	for card: CardData in result.revealed:
		var holder: Control = CardView.wrapped(card, 0.5)
		_cards_row.add_child(holder)
		holder.modulate.a = 0.0
		Audio.sfx(&"card_draw")
		create_tween().tween_property(holder, "modulate:a", 1.0, 0.25)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.3).timeout
	_show_outcome(result)


func _show_outcome(result: ChallengeResult) -> void:
	var passed: bool = result.success
	Audio.sfx(&"victory" if passed else &"defeat", -6.0)
	var headline: Label = UIKit.label("The well answers." if passed else "The well stays silent.", &"HeadingLabel", 36, UIStyle.GOOD if passed else Color("e06a5a"), HORIZONTAL_ALIGNMENT_CENTER)
	_result_box.add_child(headline)
	var lines: PackedStringArray = []
	if result.life_healed > 0:
		lines.append("You recover %d life." % result.life_healed)
	if result.life_lost > 0:
		lines.append("You lose %d life." % result.life_lost)
	for card: CardData in result.lost_cards:
		lines.append("%s is lost for this dungeon." % card.display_name)
	for card: CardData in result.gained_cards:
		lines.append("%s joins your deck for this dungeon." % card.display_name)
	for boon: ModifierSource in result.boons:
		lines.append("Boon: %s." % boon.source_name)
	if lines.is_empty():
		lines.append("Nothing changes.")
	for line: String in lines:
		_result_box.add_child(UIKit.label(line, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	_reveal_button.text = "Continue"
	_reveal_button.disabled = false
