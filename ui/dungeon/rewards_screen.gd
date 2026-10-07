class_name RewardsScreen
extends Control
## After a victory: gold and a choice of one card (Part C: on the trial's first clear, the choice
## is restricted to the player's own element - see Session.complete_battle). After the boss,
## Session.complete_trial() runs and this shows the "Trial Complete" step.

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
	if _offer.xp > 0:
		_column.add_child(UIKit.label("+%d XP" % _offer.xp, &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
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
	if not _offer.levels_gained.is_empty():
		var screen: LevelUpScreen = LevelUpScreen.new()
		screen.setup(_offer.levels_gained)
		add_child(screen)
		screen.finished.connect(func() -> void:
			screen.queue_free()
			_after_rewards(continues, was_boss, first_clear))
		return
	_after_rewards(continues, was_boss, first_clear)


func _after_rewards(continues: bool, was_boss: bool, first_clear: bool) -> void:
	if Session.main_dungeon_active and was_boss and not continues:
		_main_boss_epilogue()
		return
	if Session.mini_active and was_boss and not continues:
		Session.finish_mini_dungeon(true)
		return
	if continues or not was_boss:
		SceneManager.change_scene("res://scenes/dungeon_map.tscn")
		return
	Session.complete_trial()
	_show_trial_complete(first_clear)


## Part E: after a zone dungeon's boss falls: the boss node's closing story lines, then its cutscene (the
## Archdruid cut free from the Rotheart...), then the zone is freed (`Session.finish_main_dungeon`).
func _main_boss_epilogue() -> void:
	var boss: DungeonMap.MapNode = Session.dungeon_map.boss()
	var story: ZoneStoryText = ZoneStoryText.for_zone(Session.zone_def().id)
	var finish: Callable = func() -> void: Session.finish_main_dungeon(true)
	var after_scene: Callable = func() -> void:
		if boss != null and not boss.after_scene.is_empty() and CutsceneDefs.has_scene(boss.after_scene):
			var scene: CutsceneScreen = CutsceneScreen.make(boss.after_scene)
			add_child(scene)
			scene.finished.connect(finish, CONNECT_ONE_SHOT)
		else:
			finish.call()
	if boss != null and not boss.story_after.is_empty():
		_panel.visible = false
		var dialogue: DialogueBox = DialogueBox.new()
		add_child(dialogue)
		dialogue.start("", story.get_lines(boss.story_after), NpcRegistry.story_speaker(boss.story_after))
		dialogue.finished.connect(after_scene, CONNECT_ONE_SHOT)
	else:
		after_scene.call()

## Part C: the boss reward is what actually completes the trial now - there is no separate
## deck-choice step (the starter deck already grew to 45 cards via the 3 on-element reward
## picks). First clear unlocks the town; a replay is just a recap.
func _show_trial_complete(first_clear: bool) -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	Audio.sfx(&"victory")
	_column.add_child(UIKit.label("Trial Complete", &"TitleLabel", 64, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var body_text: String = "The Hollow is quiet again. You gather what it offered and head back to town."
	if first_clear:
		body_text = "The Hollow is cleared, and your deck is whole. Somewhere beyond it, the road to town is finally open."
		Session.town_notice = "The %s deck is yours. The road to town is open." % UIStyle.affinity_name(Session.profile.primary_affinity)
	var text: Label = UIKit.label(body_text, &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1100, 0)
	_column.add_child(text)
	var home: FancyButton = FancyButton.make("Enter town", &"PrimaryButton", Vector2(300, 62))
	home.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	home.pressed.connect(func() -> void:
		SceneManager.go_to_town())
	_column.add_child(home)
	UIKit.pop_in(_panel)
