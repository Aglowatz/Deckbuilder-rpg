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
var _where_label: Label
var _to_deck: bool = false
var _screenshot_args: Dictionary = {}
var _card_row: HBoxContainer
var _reroll_button: FancyButton
var _boss_talk_done: bool = false
## Fresh eyes Oct 30: the hovered (else the chosen) card's keywords, explained under the row - a reward cannot be judged on "Hustle." alone.
var _keyword_help: VBoxContainer


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	SceneManager.pause_allowed = false
	Audio.play_music(StringName(MusicDirector.dungeon_exploration(MusicDirector.session_dungeon_id())))
	if Session.pending_reward == null:
		# Launched directly (screenshots): fake a boss reward.
		Session.ensure_game()
		var offer: RewardOffer = RewardOffer.new()
		offer.gold = 120
		offer.enemy_name = "Hollow Warden"
		offer.is_boss = str(_screenshot_args.get("boss", "true")) == "true"
		offer.cards = RewardGenerator.card_choices(Session.content, Session.profile, Session.rng, 3, offer.is_boss)
		offer.reroll_price = Economy.reroll_price(Session.profile.level)
		offer.reroll = func() -> Array[CardData]: return RewardGenerator.card_choices(Session.content, Session.profile, Session.rng, 3, offer.is_boss)
		Session.pending_reward = offer
		if _screenshot_args.has("board"):
			offer.board_key = str(_screenshot_args["board"])
		Session.trial_finished = offer.is_boss
	_offer = Session.pending_reward
	# Oct 19: the place of the fight just won (its battleboard, blurred) - it used to be the arena for every dungeon.
	add_child(PostBattleBackdrop.for_board(_offer.board_key if not _offer.board_key.is_empty() else PostBattleBackdrop.dungeon_board_key()))
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	_panel = UIKit.panel()
	center.add_child(_panel)
	_column = UIKit.vbox(14)
	_panel.add_child(_column)
	_build_rewards()
	# The battle's own result already rang STG-VICTORY a moment ago; a second fanfare would stack on it.


func _build_rewards() -> void:
	_column.add_child(UIKit.label("Victory!", &"TitleLabel", 72, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_column.add_child(UIKit.label("%s is defeated." % _offer.enemy_name, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	var gold_row: HBoxContainer = UIKit.hbox(12)
	gold_row.alignment = BoxContainer.ALIGNMENT_CENTER
	gold_row.add_child(IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 44.0))
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
	# Cards Oct 27, Part 3: in the tutorial cave the pick joins the deck; everywhere else it goes to the collection, for the Deck Station.
	_to_deck = Session.rewards_go_to_deck()
	_column.add_child(UIKit.label("Choose a card for your deck" if _to_deck else "Choose a card for your collection", &"HeadingLabel", 28, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_card_row = UIKit.hbox(22)
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(_card_row)
	_fill_cards()
	_where_label = UIKit.label("", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_where_label.name = "WhereLabel"
	_where_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_where_label.custom_minimum_size = Vector2(760, 0)
	_column.add_child(_where_label)
	_keyword_help = UIKit.vbox(2)
	_keyword_help.name = "KeywordHelp"
	_keyword_help.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(_keyword_help)
	if not _to_deck and Session.take_collection_tip():
		var tip: Label = UIKit.label("New: cards you win go to your collection, not straight into your deck. Build them in at the Deck Station in Crosspath.", &"", 20, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		tip.name = "CollectionTip"
		tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tip.custom_minimum_size = Vector2(760, 0)
		_column.add_child(tip)
	_add_buttons()
	# Fresh eyes Oct 30: the middle card starts chosen, so "Take" is the live gold button from the first frame (with nothing chosen the
	# plain "Skip card" read as the primary button and the critic skipped the first reward).
	if _cards.size() > 1:
		_select(1, true)
	elif not _cards.is_empty():
		_select(0, true)


## The card views of the offer's current cards, in the card row (built once, and again after a reroll).
func _fill_cards() -> void:
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
		PadClick.enable(view)  # controller support (Oct 26): A picks the card
		view.hovered.connect(func(_v: CardView) -> void:
			Audio.sfx(&"card_hover", -12.0)
			_show_keywords(_offer.cards[index])
			if _selected != index:
				create_tween().tween_property(view, "position:y", view.position.y - 14.0, 0.1))
		view.unhovered.connect(func(_v: CardView) -> void:
			_show_keywords(_offer.cards[_selected] if _selected >= 0 and _selected < _offer.cards.size() else null)
			if _selected != index:
				create_tween().tween_property(view, "position:y", -CardView.SIZE.y * 0.1, 0.1))
		_card_row.add_child(holder)
		_cards.append(view)


## Oct 29, Phase 2: pays the reroll and shows three fresh cards in the same row; the button goes once used.
func _reroll() -> void:
	if not Session.reroll_dungeon_pick(_offer):
		Audio.sfx(&"ui_error", -4.0)
		return
	Audio.sfx(&"card_shuffle")
	for holder: Node in _card_row.get_children():
		holder.queue_free()
	_cards.clear()
	_selected = -1
	_fill_cards()
	_take_button.disabled = true
	_take_button.text = "Take card"
	if _where_label != null:
		_where_label.text = ""
	if _cards.size() > 1:
		_select(1, true)
	if _reroll_button != null:
		_reroll_button.queue_free()
		_reroll_button = null
	if InputDevice.using_pad() and not _cards.is_empty():
		_cards[0].grab_focus.call_deferred()


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
		# Oct 29, Phase 2: one reroll for gold (the late sink, inside dungeons too); greyed out when the purse is short.
		if _offer.can_reroll():
			_reroll_button = FancyButton.make("Reroll (%d gold)" % _offer.reroll_price, &"", Vector2(200, 60))
			_reroll_button.name = "RerollButton"
			_reroll_button.disabled = Session.gold < _offer.reroll_price
			_reroll_button.tooltip_text = "Not enough gold (you have %d)." % Session.gold if _reroll_button.disabled else "Pay %d gold for three different cards. Once per pick." % _offer.reroll_price
			_reroll_button.pressed.connect(_reroll)
			buttons.add_child(_reroll_button)


func _select(index: int, quiet: bool = false) -> void:
	_selected = index
	if not quiet:
		Audio.sfx(&"ui_select")
	for i: int in range(_cards.size()):
		_cards[i].set_glow(CardView.Glow.SELECTED if i == index else CardView.Glow.NONE)
		_cards[i].modulate = Color.WHITE if i == index else Color(0.7, 0.7, 0.78)
	_take_button.disabled = false
	_take_button.text = "Take %s" % _offer.cards[index].display_name
	if _where_label != null:
		_where_label.text = ("%s joins your deck." if _to_deck else "Added to your collection: %s (find it at the Deck Station).") % _offer.cards[index].display_name
	_show_keywords(_offer.cards[index])


## Fresh eyes Oct 30: the card's keywords and the resources its text names, each with its one-line meaning (KeywordInfo, as the Deck
## Station's hover preview shows them); nothing for a card without any.
func _show_keywords(card: CardData) -> void:
	if _keyword_help == null:
		return
	for child: Node in _keyword_help.get_children():
		child.queue_free()
	if card == null:
		return
	for entry: Array in KeywordInfo.entries_for(card):
		var line: Label = UIKit.label("%s: %s" % [str(entry[0]), str(entry[1])], &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		line.name = "Keyword_%s" % str(entry[0]).replace(" ", "_")
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(900, 0)
		_keyword_help.add_child(line)
	if InputDevice.using_pad() and _take_button.is_visible_in_tree():
		_take_button.grab_focus.call_deferred()  # Fixes Oct 27: the next A takes it


## Fixes Oct 27, Part 1: the pad starts on the first card of the pick (else the first button).
func pad_first_focus() -> Control:
	if not _cards.is_empty() and _cards[0].focus_mode != Control.FOCUS_NONE:
		return _cards[0]
	return _take_button


## Fixes Oct 27, Part 1: the keyboard chooses too - Left / Right step the chosen card, 1-3 choose one, Enter / Space / E takes it.
func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if _cards.is_empty() or key == null or not key.pressed or key.echo or InputDevice.using_pad() or PadFocus.top_root(get_tree()) != self:
		return
	var index: int = -1
	if key.keycode >= KEY_1 and key.keycode <= KEY_9:
		index = int(key.keycode - KEY_1)
	elif key.keycode == KEY_LEFT or key.keycode == KEY_A:
		index = maxi(0, _selected - 1) if _selected >= 0 else 0
	elif key.keycode == KEY_RIGHT or key.keycode == KEY_D:
		index = mini(_cards.size() - 1, _selected + 1)
	elif UiInput.is_confirm(event) and _selected >= 0 and not _take_button.disabled and _take_button.is_visible_in_tree():
		get_viewport().set_input_as_handled()
		_take_button.pressed.emit()
		return
	if index < 0 or index >= _cards.size():
		return
	_select(index)
	get_viewport().set_input_as_handled()


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
	# Oct 21: a boss's closing story scene (Crumb in the Paste Works, Siphon and his daughter) before the dungeon wraps up.
	var boss: DungeonMap.MapNode = Session.dungeon_map.boss() if Session.dungeon_map != null else null
	if was_boss and not continues and boss != null and not _boss_talk_done:
		var talk: String = BossTalks.after_boss(boss, Session.dungeon_key, Session.run)
		if StoryScenes.should_play(talk, Session.flags):
			_boss_talk_done = true
			_panel.visible = false
			var dialogue: DialogueBox = DialogueBox.new()
			add_child(dialogue)
			StoryScenePlayer.play(dialogue, talk, _after_rewards.bind(continues, was_boss, first_clear))
			return
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
	var story: ZoneStoryText = ZoneStoryText.for_zone(MainDungeons.def(Session.dungeon_key).zone_id)
	var finish: Callable = func() -> void: Session.finish_main_dungeon(true)
	var after_scene: Callable = func() -> void:
		if boss != null and not boss.after_scene.is_empty() and CutsceneDefs.has_scene(boss.after_scene):
			var scene: CutsceneScreen = CutsceneScreen.make(boss.after_scene)
			add_child(scene)
			scene.finished.connect(finish, CONNECT_ONE_SHOT)
		else:
			finish.call()
	# The story still of the boss's fall (the stamp shatters, the Rotheart splits, Primm kneels) comes between his closing words and the aftermath scene.
	var after_still: Callable = func() -> void:
		var still: String = StoryStills.after_boss(Session.dungeon_key)
		if still.is_empty():
			after_scene.call()
		else:
			_panel.visible = false
			StoryStillScreen.play(self, still, after_scene)
	if boss != null and not boss.story_after.is_empty():
		_panel.visible = false
		var dialogue: DialogueBox = DialogueBox.new()
		add_child(dialogue)
		dialogue.start("", story.get_lines(HouseOfGainsDungeon.boss_story_key(boss.story_after, Session.run)), NpcRegistry.story_speaker(boss.story_after))
		dialogue.finished.connect(after_still, CONNECT_ONE_SHOT)
	else:
		after_still.call()

## Part C: the boss reward is what actually completes the trial now - there is no separate
## deck-choice step (the starter deck already grew to 45 cards via the 3 on-element reward
## picks). First clear unlocks the town; a replay is just a recap.
func _show_trial_complete(first_clear: bool) -> void:
	for child: Node in _column.get_children():
		child.queue_free()
	Audio.sting(&"STG-DUNGEON")
	_column.add_child(UIKit.label("Through the Forgotten Cave", &"TitleLabel", 64, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var body_text: String = "The Forgotten Cave is quiet again. You gather what it offered and head back to town."
	if first_clear:
		body_text = "%s\n\nDaylight at last. Your deck is whole, and the way out is open." % "\n".join(StoryText.shared().get_lines("tutorial.warden.after"))
		Session.town_notice = "The %s deck is yours. The road to town is open." % UIStyle.affinity_name(Session.profile.primary_affinity)
	var text: Label = UIKit.label(body_text, &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(1100, 0)
	_column.add_child(text)
	var home: FancyButton = FancyButton.make("Step outside" if first_clear else "Enter town", &"PrimaryButton", Vector2(300, 62))
	home.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	home.pressed.connect(func() -> void:
		if first_clear:
			# Playtest v0.4.0 Part C: straight into Crosspath, beside Elder Maren, with her welcome opening as the town appears.
			# v0.4.2 hotfix: with the loading screen again - the town's first build takes seconds, and a black screen there looked frozen.
			Session.cave_exit_pending = true
		SceneManager.go_to_town())
	_column.add_child(home)
	UIKit.pop_in(_panel)
