class_name LevelUpScreen
extends Control
## Part E: shown after a battle grants enough XP to level up. New brief, Part A: one celebratory
## popup PER level gained, shown in sequence (not one combined recap) - the new level number and
## every bonus gained at that level, each with an icon, an animated entrance, a particle burst and
## a sound. Reused as-is for level-ups from any source (the dev shrine, New Part E) - callers only
## ever call `setup()` then add this as a child, so nothing about the source leaks in here.
## Once every level's popup has been shown, walks through any pending equipment-slot choices and
## "choose 1 of 3 cards" level rewards before finishing - same as before.

signal finished

## One bonus row on a level's popup: an icon name (CardIcons.ui()) and its text.
class Bonus:
	extends RefCounted
	var icon: String = ""
	var text: String = ""


static func _bonus(icon_name: String, text_value: String) -> Bonus:
	var bonus: Bonus = Bonus.new()
	bonus.icon = icon_name
	bonus.text = text_value
	return bonus


var levels_gained: Array[LevelData] = []
var _index: int = 0
var _frame: PopupFrame
var _child_screen: Control


func setup(gained: Array[LevelData]) -> void:
	levels_gained = gained


func _ready() -> void:
	UIKit.full_rect(self)
	# Polish round: the same frame as the chest and quest-complete boxes (`PopupFrame`).
	_frame = PopupFrame.make("LEVEL UP!", "level_badge", UIStyle.GOLD)
	add_child(_frame)
	_frame.confirmed.connect(_next_level)
	_index = 0
	_show_level_popup()


## One level's popup: badge + "Level N", every bonus gained at this level (with icons), a
## particle burst and a sound. `_advance()` moves to the next level, or on to equipment/card
## choices once every level has had its popup.
func _show_level_popup() -> void:
	_frame.clear_body()
	var row: LevelData = levels_gained[_index]
	_frame.set_heading("You are now level %d." % row.level, "(%d of %d levels gained)" % [_index + 1, levels_gained.size()] if levels_gained.size() > 1 else "")
	var bonus_list: VBoxContainer = UIKit.vbox(8)
	_frame.body.add_child(bonus_list)
	for bonus: Bonus in _bonuses_for(row):
		var bonus_row: HBoxContainer = UIKit.hbox(12)
		bonus_row.add_child(CardIcons.glyph(CardIcons.ui(bonus.icon), UIStyle.PARCHMENT, Vector2(32, 32)))
		var label: Label = UIKit.label(bonus.text, &"", 20, UIStyle.PARCHMENT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(640, 0)
		bonus_row.add_child(label)
		bonus_list.add_child(bonus_row)
	_frame.animate_in()
	Audio.sfx(&"level_up")


## Bonuses gained at `row`, compared to the previous level's row (mirrors
## `ProgressionTable._fill_summaries_and_fallback_rewards`'s diffing, but as icon rows instead of
## one text string). Level 1 (no previous row) is never shown by this screen in practice - nobody
## "levels up" into level 1 - but is handled the same as any other level for safety.
func _bonuses_for(row: LevelData) -> Array[Bonus]:
	var bonuses: Array[Bonus] = []
	var previous: LevelData = ProgressionTable.row(row.level - 1)
	if previous == null:
		bonuses.append(_bonus("level_badge", "Starting stats."))
		return bonuses
	if row.max_hp > previous.max_hp:
		bonuses.append(_bonus("hp", "+1 starting HP (now %d)." % row.max_hp))
	if row.opening_hand_size > previous.opening_hand_size:
		bonuses.append(_bonus("hand", "Opening hand size +1 (now %d)." % row.opening_hand_size))
	if row.item_slots > previous.item_slots:
		bonuses.append(_bonus("item_slot", "+1 item slot (now %d)." % row.item_slots))
	if row.max_hand_size > previous.max_hand_size:
		bonuses.append(_bonus("hand", "Max hand size +1 (now %d)." % row.max_hand_size))
	if row.equipment_choice:
		bonuses.append(_bonus("equipment_unlock", "Choose an equipment slot to unlock."))
	if row.reward_equipment_vendor_unlock:
		bonuses.append(_bonus("equipment_unlock", "Unlocks the advanced equipment at the equipment vendor."))
	if row.reward_item_vendor_advanced_unlock:
		bonuses.append(_bonus("vendor", "Unlocks the second half of the item vendor's stock."))
	if row.reward_deck_expansion:
		bonuses.append(_bonus("card_choice", "Deck box expansion: %d to %d deck slots." % [ProgressionTable.BASE_DECK_SLOTS, ProgressionTable.EXPANDED_DECK_SLOTS]))
	if row.reward_vendor_discount_percent > 0:
		bonuses.append(_bonus("vendor", "Permanent vendor discount +%d%%." % row.reward_vendor_discount_percent))
	if not row.reward_vendor_unlock.is_empty():
		bonuses.append(_bonus("vendor", "Unlocks %s at the vendor." % row.reward_vendor_unlock))
	if bonuses.is_empty():
		bonuses.append(_bonus("level_badge", row.summary))
	return bonuses


func _next_level() -> void:
	_index += 1
	if _index < levels_gained.size():
		_show_level_popup()
	else:
		_advance()


## Resolves pending equipment choices one at a time; finishes once there are none left. New
## brief, Part D: this used to also walk through pending "choose 1 of 3 cards" level rewards,
## removed along with that whole mechanic.
func _advance() -> void:
	if _child_screen != null:
		_child_screen.queue_free()
		_child_screen = null
	if Session.pending_equipment_choices > 0:
		_show_equipment_choice()
		return
	finished.emit()


func _show_equipment_choice() -> void:
	_frame.visible = false
	var choice: EquipmentSlotChoiceScreen = EquipmentSlotChoiceScreen.new()
	choice.chosen.connect(func(slot: EquipmentData.Slot) -> void:
		Session.choose_equipment_slot(slot)
		Audio.sfx(&"ui_confirm")
		_advance())
	_child_screen = choice
	add_child(choice)


