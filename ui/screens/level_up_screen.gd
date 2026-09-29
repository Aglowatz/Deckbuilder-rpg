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
	_panel.custom_minimum_size = Vector2(760, 0)
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_index = 0
	_show_level_popup()


## One level's popup: badge + "Level N", every bonus gained at this level (with icons), a
## particle burst and a sound. `_advance()` moves to the next level, or on to equipment/card
## choices once every level has had its popup.
func _show_level_popup() -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	var row: LevelData = levels_gained[_index]
	var badge_row: HBoxContainer = UIKit.hbox(14)
	badge_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(badge_row)
	badge_row.add_child(CardIcons.glyph(CardIcons.ui("level_badge"), UIStyle.GOLD, Vector2(56, 56)))
	badge_row.add_child(UIKit.label("Level Up!", &"TitleLabel", 56, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_column.add_child(UIKit.label("You are now level %d." % row.level, &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	if levels_gained.size() > 1:
		_column.add_child(UIKit.label("(%d of %d levels gained)" % [_index + 1, levels_gained.size()], &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_column.add_child(UIKit.spacer(6))
	var bonus_list: VBoxContainer = UIKit.vbox(8)
	_column.add_child(bonus_list)
	for bonus: Bonus in _bonuses_for(row):
		var bonus_row: HBoxContainer = UIKit.hbox(12)
		bonus_row.add_child(CardIcons.glyph(CardIcons.ui(bonus.icon), UIStyle.PARCHMENT, Vector2(32, 32)))
		var label: Label = UIKit.label(bonus.text, &"", 20, UIStyle.PARCHMENT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(640, 0)
		bonus_row.add_child(label)
		bonus_list.add_child(bonus_row)
	var button: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(240, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_next_level)
	_column.add_child(UIKit.spacer(6))
	_column.add_child(button)
	_animate_in()
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
	if row.max_life > previous.max_life:
		bonuses.append(_bonus("life", "+1 starting life (now %d)." % row.max_life))
	if row.opening_hand_size > previous.opening_hand_size:
		bonuses.append(_bonus("hand", "Opening hand size +1 (now %d)." % row.opening_hand_size))
	if row.item_slots > previous.item_slots:
		bonuses.append(_bonus("item_slot", "+1 item slot (now %d)." % row.item_slots))
	for rarity: Variant in row.copy_limits.keys():
		if int(row.copy_limits[rarity]) > int(previous.copy_limits.get(rarity, 0)):
			bonuses.append(_bonus("copies", "%s deck copy limit +1 (now %d)." % [CardEnums.Rarity.keys()[int(rarity)].capitalize(), int(row.copy_limits[rarity])]))
	if row.equipment_choice:
		bonuses.append(_bonus("equipment_unlock", "Choose an equipment slot to unlock."))
	if row.reward_gold > 0:
		bonuses.append(_bonus("coins", "+%d gold." % row.reward_gold))
	if row.reward_card_choice:
		bonuses.append(_bonus("card_choice", "Choose 1 of 3 cards to add to your collection."))
	if not row.reward_vendor_unlock.is_empty():
		bonuses.append(_bonus("vendor", "Unlocks %s at the vendor." % row.reward_vendor_unlock))
	if bonuses.is_empty():
		bonuses.append(_bonus("level_badge", row.summary))
	return bonuses


## Fades + scales the popup in and bursts particles from behind the badge - the "animated
## entrance, particles and a sound" the brief asks for (the sound is played by the caller).
func _animate_in() -> void:
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.7, 0.7)
	_panel.modulate.a = 0.0
	var tween: Tween = _panel.create_tween().set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_burst_particles()


func _burst_particles() -> void:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.position = get_viewport_rect().size * 0.5
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 48
	particles.lifetime = 1.0
	particles.explosiveness = 1.0
	particles.spread = 180.0
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = 140.0
	particles.initial_velocity_max = 420.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 9.0
	particles.color = UIStyle.GOLD
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, UIStyle.GOLD)
	ramp.set_color(1, Color(UIStyle.GOLD.r, UIStyle.GOLD.g, UIStyle.GOLD.b, 0.0))
	particles.color_ramp = ramp
	particles.z_index = 250
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.4, false).timeout.connect(particles.queue_free)


func _next_level() -> void:
	Audio.sfx(&"ui_confirm")
	_index += 1
	if _index < levels_gained.size():
		_show_level_popup()
	else:
		_advance()


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
