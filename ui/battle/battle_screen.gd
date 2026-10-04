class_name BattleScreen
extends Control
## The duel screen. Owns the GameState, turns the player's clicks into GameActions, lets the AI
## take the opponent's turns, and plays every resulting event through the board and HUD.
## All rules live in core/; this class only decides what to show and which action to submit.

signal finished(won: bool)

enum Mode { WAITING, MAIN, TARGETING, ATTACK, BLOCK, DISCARD, MULLIGAN, OVER }

const DRAG_START_DISTANCE: float = 16.0
const PLAY_LINE_Y: float = 720.0
## Modes where the primary button is "the end-step button for the current phase" - Space
## triggers it in exactly these (targeting/discard/mulligan are different decisions, not a
## phase/step advance).
const _SPACE_ADVANCE_MODES: Array[Mode] = [Mode.MAIN, Mode.ATTACK, Mode.BLOCK]

var context: BattleContext
var game: GameState
var ai: AIPlayer
var board: BattleBoard
var fx: BattleFX
var hud: BattleHud
var mode: Mode = Mode.WAITING
var busy: bool = false
## When set, this AI plays the human seat (screenshots, end-to-end tests).
var human_bot: AIPlayer
var bot_until_turn: int = 0
var tutorial: TutorialLayer

var _board_root: Control
var _event_cursor: int = 0
var _fast_end_turn: bool = false
var _screenshot_args: Dictionary = {}
var _overlay_layer: Control
var _mulligan_panel: Control
var _result_panel: Control
var _press_uid: int = 0
var _press_pos: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _target_source: int = 0
var _target_options: Array[int] = []
var _target_action: GameAction.Type = GameAction.Type.CAST
var _target_ability: int = 0
## New brief, Part F: set instead of _target_action/_target_ability while targeting an equipped
## item's effect (items are not cards - no GameAction involved).
var _pending_item: ItemData = null
var item_bar: ItemBar
var _selected_attackers: Array[int] = []
var _block_assign: Dictionary = {}
var _block_pick: int = 0
var _discard_selection: Array[int] = []
var _hovered_view: CardView
var _toast_label: Label


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


func _ready() -> void:
	SceneManager.pause_allowed = true
	Audio.play_music(&"battle")
	context = Session.pending_battle
	if context == null:
		context = Session.make_practice_battle(str(_screenshot_args.get("enemy", "Cave Scavenger")))
		context.zone_id = str(_screenshot_args.get("zone", ""))
	Session.pending_battle = null
	game = context.game
	ai = context.ai
	_build_scene()
	game.event_emitted.connect(_on_game_event)
	var bot_turns: int = int(_screenshot_args.get("bot", 0))
	if bot_turns > 0:
		human_bot = AIPlayer.new(AIPersonality.balanced())
		bot_until_turn = bot_turns
	if _flag("fast"):
		board.speed = 8.0
	if _flag("force_tutorial"):
		context.tutorial = true
	if context.tutorial and not _flag("no_tutorial") and (not Session.flag(&"tutorial_done") or _flag("force_tutorial")):
		tutorial = TutorialLayer.new()
		add_child(tutorial)
		tutorial.setup(self)
	_drive.call_deferred()


## "The Gainlands" etc. for the zone-effects panel (the zone's own display name).
func _zone_title(zone_id: String) -> String:
	if zone_id.is_empty() or not ZoneDefs.has_def(zone_id):
		return ""
	return ZoneDefs.get_def(zone_id).display_name

func _build_scene() -> void:
	add_child(ArenaBackdrop.new())
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.07, 0.6)
	UIKit.full_rect(dim)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	add_child(UIKit.vignette(0.8))
	_board_root = Control.new()
	UIKit.full_rect(_board_root)
	_board_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board_root)
	fx = BattleFX.new()
	board = BattleBoard.new()
	hud = BattleHud.new()
	_board_root.add_child(hud)
	_board_root.add_child(board)
	add_child(fx)
	fx.shake_target = _board_root
	board.setup(game, fx)
	hud.setup(game, context.enemy_name, context.enemy_icon)
	hud.set_zone_effects(ZoneEffects.for_zone(context.zone_id), _zone_title(context.zone_id))
	board.portrait_anchor = [hud.portrait_center(0), hud.portrait_center(1)]
	board.card_hovered.connect(_on_card_hovered)
	board.card_unhovered.connect(_on_card_unhovered)
	board.card_input.connect(_on_card_input)
	hud.primary_pressed.connect(_on_primary)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.attack_all_pressed.connect(_on_attack_all)
	# New brief, Part F: the equipped-items row, next to the player's own portrait.
	if Session.profile != null and Session.profile.item_slots > 0:
		item_bar = ItemBar.new()
		item_bar.position = Vector2(24, 700)
		_board_root.add_child(item_bar)
		item_bar.setup(game, Session.profile)
		item_bar.item_pressed.connect(_on_item_pressed)
	_overlay_layer = Control.new()
	UIKit.full_rect(_overlay_layer)
	_overlay_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay_layer)
	_toast_label = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast_label.add_theme_font_override("font", UIStyle.font_bold())
	_toast_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast_label.add_theme_constant_override("outline_size", 8)
	_toast_label.position = Vector2(585, 676)
	_toast_label.size = Vector2(800, 40)
	_toast_label.modulate.a = 0.0
	_toast_label.z_index = 500
	add_child(_toast_label)


const _SEEN_EVENT_TYPES: Array[GameEvent.Type] = [
	GameEvent.Type.CARD_CAST, GameEvent.Type.PERMANENT_ENTERED, GameEvent.Type.TRAP_SET,
]


func _on_game_event(event: GameEvent) -> void:
	board.register_uid(event.card)
	if event.other > 0:
		board.register_uid(event.other)
	if event.type == GameEvent.Type.TURN_STARTED:
		# "End Turn" fast-forwards through the rest of THAT turn only (skipping the attack
		# step with no attackers declared). It must never leak into a later turn, or the
		# human's next turn gets auto-passed with no chance to act.
		_fast_end_turn = false
	# Codex: any card either side actually plays face-up is "seen" from here on. A trap is only
	# recorded for its own controller while it is still face-down (TRAP_SET) - the opponent
	# should not learn a hidden trap's identity from the Codex before it actually springs.
	if event.card > 0 and event.type in _SEEN_EVENT_TYPES:
		if event.type != GameEvent.Type.TRAP_SET or event.player == 0:
			var card: CardInstance = game.find_card(event.card)
			if card != null:
				Session.record_seen(card.data.id)


# ---- Main loop --------------------------------------------------------------------------


func _drive() -> void:
	if busy:
		return
	busy = true
	while true:
		await _play_new_events()
		board.sync_state()
		hud.refresh_all()
		if item_bar != null:
			item_bar.refresh()
		if game.is_over():
			busy = false
			await _show_result()
			return
		var who: int = game.awaiting_player()
		if who == 1:
			mode = Mode.WAITING
			_refresh_ui()
			await _ai_step()
			continue
		if human_bot != null and _bot_active():
			mode = Mode.WAITING
			_refresh_ui()
			await _bot_step()
			continue
		if _auto_pass_if_pointless():
			continue
		busy = false
		_enter_human_mode()
		return


func _bot_active() -> bool:
	return game.turn < bot_until_turn or game.stage == GameState.Stage.MULLIGAN and bot_until_turn > 0


func _play_new_events() -> void:
	while _event_cursor < game.events.size():
		var event: GameEvent = game.events[_event_cursor]
		_event_cursor += 1
		hud.on_event(event)
		await board.present(event)
		if tutorial != null:
			tutorial.on_battle_event(event)
	await board.flush_center()


func _ai_step() -> void:
	await get_tree().create_timer(0.35 / board.speed, false).timeout
	var action: GameAction = ai.choose_action(game)
	if not game.apply_action(action):
		if not game.apply_action(GameAction.pass_phase(1)):
			push_error("BattleScreen: AI produced no legal action")
			game.advance_phase()


func _bot_step() -> void:
	await get_tree().create_timer(0.12 / board.speed, false).timeout
	var action: GameAction = human_bot.choose_action(game)
	if not game.apply_action(action):
		game.apply_action(GameAction.pass_phase(0))


## Skips decisions that have no choices (no possible attackers, no possible blockers).
func _auto_pass_if_pointless() -> bool:
	if game.stage != GameState.Stage.PLAYING or game.pending_discard > 0:
		return false
	if game.phase != GameState.Phase.COMBAT:
		if _fast_end_turn and game.active == 0 and game.phase != GameState.Phase.END:
			game.apply_action(GameAction.pass_phase(0))
			return true
		return false
	if game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and game.active == 0:
		if game.possible_attackers(0).is_empty() or _fast_end_turn:
			game.apply_action(GameAction.pass_phase(0))
			return true
	if game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS and game.awaiting_player() == 0:
		if not _any_block_possible():
			game.apply_action(GameAction.pass_phase(0))
			return true
	return false


func _any_block_possible() -> bool:
	for attacker_uid: int in game.attackers:
		var attacker: CardInstance = game.find_permanent(attacker_uid)
		for blocker: CardInstance in game.possible_blockers(0):
			if attacker != null and CombatResolver.can_block(attacker, blocker):
				return true
	return false


func _submit(action: GameAction) -> void:
	if busy:
		return
	if not game.apply_action(action):
		Audio.sfx(&"ui_error")
		_toast("That is not allowed right now")
		return
	_clear_selection_state()
	_drive()


func _clear_selection_state() -> void:
	_selected_attackers.clear()
	_block_assign.clear()
	_block_pick = 0
	_discard_selection.clear()
	_target_source = 0
	_target_options.clear()
	board.attacking.clear()
	board.blockers.clear()
	board.drag_uid = 0
	_dragging = false
	fx.clear_arrows()
	hud.set_portrait_targets(false, false)


# ---- Human decision modes ---------------------------------------------------------------


func _enter_human_mode() -> void:
	if game.active != 0 or game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		# Blocking on the opponent's turn is a real decision; don't fast-forward past it.
		_fast_end_turn = false
	if game.stage == GameState.Stage.MULLIGAN:
		mode = Mode.MULLIGAN
		_show_mulligan()
	elif game.pending_discard > 0:
		mode = Mode.DISCARD
		_fast_end_turn = false
	elif game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS:
		mode = Mode.ATTACK
	elif game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		mode = Mode.BLOCK
	else:
		mode = Mode.MAIN
	_refresh_ui()
	if tutorial != null:
		tutorial.on_mode_changed(mode)
	if _flag("shot_mode"):
		pass


func _refresh_ui() -> void:
	var glows: Dictionary = {}
	var primary: String = ""
	var primary_enabled: bool = true
	var end_visible: bool = false
	var prompt: String = ""
	match mode:
		Mode.WAITING:
			primary = "Enemy turn" if game.active == 1 else "..."
			primary_enabled = false
			prompt = "[color=#a89bb5]The opponent is thinking...[/color]" if game.active == 1 else ""
		Mode.MAIN:
			var hand: Array[CardInstance] = game.players[0].hand
			for card: CardInstance in hand:
				if _is_playable(card):
					glows[card.uid] = CardView.Glow.PLAYABLE
			for card: CardInstance in game.players[0].battlefield:
				if _usable_ability(card) >= 0:
					glows[card.uid] = CardView.Glow.PLAYABLE
			primary = "To Combat" if game.phase == GameState.Phase.MAIN1 else "End Turn"
			end_visible = game.phase == GameState.Phase.MAIN1
			prompt = "[b]Your main phase[/b]\nPlay an infrastructure and cast spells. Click a card, or drag it onto the table."
			if game.phase == GameState.Phase.MAIN2:
				prompt = "[b]Second main phase[/b]\nPlay anything you held back, then end your turn."
		Mode.ATTACK:
			for card: CardInstance in game.possible_attackers(0):
				glows[card.uid] = CardView.Glow.PLAYABLE
			for uid: int in _selected_attackers:
				glows[uid] = CardView.Glow.SELECTED
			var count: int = _selected_attackers.size()
			primary = "Attack with %d" % count if count > 0 else "No Attack"
			end_visible = true
			prompt = "[b]Choose attackers[/b]\nClick your creatures to send them into battle."
			if not CombatResolver.guard_creatures(game, 1).is_empty():
				prompt += "\n[color=#e8b04a]Guard:[/color] attackers must attack the enemy Guard creature first."
		Mode.BLOCK:
			for attacker_uid: int in game.attackers:
				glows[attacker_uid] = CardView.Glow.ATTACK
			for blocker: CardInstance in game.possible_blockers(0):
				glows[blocker.uid] = CardView.Glow.PLAYABLE
			for blocker_uid: Variant in _block_assign.values():
				glows[int(blocker_uid)] = CardView.Glow.BLOCK
			if _block_pick != 0:
				glows[_block_pick] = CardView.Glow.SELECTED
			var blocks: int = _block_assign.size()
			primary = "Confirm Blocks (%d)" % blocks if blocks > 0 else "No Blocks"
			prompt = "[b]Block![/b]\nClick one of your creatures, then the attacker it should block."
		Mode.DISCARD:
			for card: CardInstance in game.players[0].hand:
				glows[card.uid] = CardView.Glow.TARGET if _discard_selection.has(card.uid) else CardView.Glow.PLAYABLE
			primary = "Discard (%d/%d)" % [_discard_selection.size(), game.pending_discard]
			primary_enabled = _discard_selection.size() == game.pending_discard
			prompt = "[b]Too many cards[/b]\nChoose %d card%s to discard." % [game.pending_discard, "" if game.pending_discard == 1 else "s"]
		Mode.TARGETING:
			for uid: int in _target_options:
				if uid > 0:
					glows[uid] = CardView.Glow.TARGET
			glows[_target_source] = CardView.Glow.SELECTED
			primary = "Cancel"
			prompt = "[b]Choose a target[/b]\nClick a highlighted target. Right-click to cancel."
		Mode.MULLIGAN:
			primary = "..."
			primary_enabled = false
			prompt = "[b]Opening hand[/b]\nKeep it, or take your free mulligan."
		Mode.OVER:
			primary = "..."
			primary_enabled = false
	board.set_glows(glows)
	if primary_enabled and _SPACE_ADVANCE_MODES.has(mode):
		primary += "  [Space]"
	hud.primary_button.text = primary
	hud.primary_button.disabled = not primary_enabled
	hud.end_turn_button.visible = end_visible
	hud.attack_all_button.visible = mode == Mode.ATTACK
	hud.set_prompt(prompt)
	_update_arrows()


func _is_playable(card: CardInstance) -> bool:
	if card.data.is_infrastructure():
		return game.can_play_infrastructure(0, card.uid)
	return game.can_cast(0, card.uid)


## Index of the first activated ability the player can use on this permanent, or -1.
func _usable_ability(card: CardInstance) -> int:
	for index: int in range(card.data.effects.size()):
		if card.data.effects[index].trigger == CardEnums.Trigger.ACTIVATED and game.can_activate(0, card.uid, index):
			return index
	return -1


func _update_arrows() -> void:
	var arrows: Array[Dictionary] = []
	if mode == Mode.ATTACK:
		var guards: Array[CardInstance] = CombatResolver.guard_creatures(game, 1)
		for uid: int in _selected_attackers:
			var to: Vector2 = board.center_of(guards[0].uid) if not guards.is_empty() else hud.portrait_center(1)
			arrows.append({"from": board.center_of(uid), "to": to, "color": Color("ff9c4a")})
	elif mode == Mode.BLOCK:
		for attacker_uid: Variant in _block_assign.keys():
			arrows.append({"from": board.center_of(int(_block_assign[attacker_uid])), "to": board.center_of(int(attacker_uid)), "color": Color("6ab8ff")})
	fx.set_arrows(arrows)


func _process(_delta: float) -> void:
	if mode == Mode.TARGETING and _target_source != 0:
		var arrows: Array[Dictionary] = [{"from": board.center_of(_target_source), "to": get_global_mouse_position(), "color": Color("ff5a5a")}]
		fx.set_arrows(arrows)
	if _dragging and board.drag_uid != 0:
		board.drag_center = get_global_mouse_position()
		board.layout(false)


# ---- Button handlers --------------------------------------------------------------------


func _on_primary() -> void:
	if busy:
		return
	match mode:
		Mode.MAIN:
			_submit(GameAction.pass_phase(0))
		Mode.ATTACK:
			var action: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, 0)
			for uid: int in _selected_attackers:
				action.uids.append(uid)
			_submit(action)
		Mode.BLOCK:
			var action: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, 0)
			action.blocks = _block_assign.duplicate()
			_submit(action)
		Mode.DISCARD:
			var action: GameAction = GameAction.make(GameAction.Type.DISCARD, 0)
			for uid: int in _discard_selection:
				action.uids.append(uid)
			_submit(action)
		Mode.TARGETING:
			_cancel_targeting()


func _on_end_turn() -> void:
	if busy or not (mode == Mode.MAIN or mode == Mode.ATTACK):
		return
	_fast_end_turn = true
	_clear_selection_state()
	_submit(GameAction.pass_phase(0))


# ---- Card interaction -------------------------------------------------------------------


func _on_card_hovered(view: CardView) -> void:
	_hovered_view = view
	hud.show_preview(view)
	if view.get_meta("owner", 0) == 0 and board.zones.get(view.instance_uid) == BattleBoard.Zone.HAND:
		Audio.sfx(&"card_hover", -12.0)


func _on_card_unhovered(view: CardView) -> void:
	if _hovered_view == view:
		_hovered_view = null
		hud.hide_preview()


func _on_card_input(view: CardView, event: InputEvent) -> void:
	if busy:
		return
	var button_event: InputEventMouseButton = event as InputEventMouseButton
	if button_event == null:
		return
	var uid: int = view.instance_uid
	if button_event.button_index == MOUSE_BUTTON_RIGHT and button_event.pressed:
		if mode == Mode.TARGETING:
			_cancel_targeting()
		return
	if button_event.button_index != MOUSE_BUTTON_LEFT:
		return
	var zone: int = int(board.zones.get(uid, -1))
	var mine: bool = int(view.get_meta("owner", 0)) == 0
	match mode:
		Mode.MAIN:
			if zone == BattleBoard.Zone.HAND and mine and button_event.pressed:
				_press_uid = uid
				_press_pos = get_global_mouse_position()
			elif zone == BattleBoard.Zone.BATTLEFIELD and mine and button_event.pressed:
				_try_activate(uid)
		Mode.ATTACK:
			if button_event.pressed and zone == BattleBoard.Zone.BATTLEFIELD and mine:
				_toggle_attacker(uid)
		Mode.BLOCK:
			if button_event.pressed and zone == BattleBoard.Zone.BATTLEFIELD:
				_block_click(uid, mine)
		Mode.DISCARD:
			if button_event.pressed and zone == BattleBoard.Zone.HAND and mine:
				_toggle_discard(uid)
		Mode.TARGETING:
			if button_event.pressed and _target_options.has(uid):
				_finish_targeting(uid)


func _input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_SPACE:
		if not busy and _SPACE_ADVANCE_MODES.has(mode) and not hud.primary_button.disabled:
			_on_primary()
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _press_uid != 0 and mode == Mode.MAIN and not _dragging:
		if (get_global_mouse_position() - _press_pos).length() > DRAG_START_DISTANCE:
			_dragging = true
			board.drag_uid = _press_uid
			board.hover_uid = 0
			hud.hide_preview()
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button == null:
		return
	if button.button_index == MOUSE_BUTTON_LEFT and not button.pressed and _press_uid != 0:
		var uid: int = _press_uid
		var was_dragging: bool = _dragging
		var drop_y: float = get_global_mouse_position().y
		_press_uid = 0
		_dragging = false
		board.drag_uid = 0
		board.layout()
		if mode == Mode.MAIN and (not was_dragging or drop_y < PLAY_LINE_Y):
			_try_play(uid)
	elif button.button_index == MOUSE_BUTTON_LEFT and button.pressed and mode == Mode.TARGETING and not busy:
		_click_portrait_target(get_global_mouse_position())
	elif button.button_index == MOUSE_BUTTON_RIGHT and button.pressed and mode == Mode.TARGETING:
		_cancel_targeting()


func _try_play(uid: int) -> void:
	var card: CardInstance = game.players[0].find_hand(uid)
	if card == null:
		return
	if card.data.is_infrastructure():
		if game.can_play_infrastructure(0, uid):
			_submit(GameAction.play_infrastructure(0, uid))
		else:
			_reject("You can only play one infrastructure per turn")
		return
	if not game.can_cast(0, uid):
		_reject(_why_not_castable(card))
		return
	var effect: EffectData = _target_effect(card.data)
	if effect != null:
		var options: Array[int] = game.legal_targets(0, effect, uid)
		if not options.is_empty():
			_begin_targeting(uid, options, GameAction.Type.CAST, 0)
			return
	_submit(GameAction.cast(0, uid))


func _why_not_castable(card: CardInstance) -> String:
	if not game.in_main_phase() or game.active != 0:
		return "You can only cast cards in your main phase"
	if not PathEnergy.can_pay(game.players[0].ready_infrastructure(), game.generic_cost_for(0, card.data), card.data.colored_pips):
		return "Not enough Path energy"
	return "There is no legal target"


func _target_effect(data: CardData) -> EffectData:
	for effect: EffectData in data.effects:
		if effect.trigger == CardEnums.Trigger.ON_ENTER and effect.needs_chosen_target():
			return effect
	return null


func _try_activate(uid: int) -> void:
	var card: CardInstance = game.players[0].find_battlefield(uid)
	if card == null:
		return
	var index: int = _usable_ability(card)
	if index < 0:
		return
	var effect: EffectData = card.data.effects[index]
	if effect.needs_chosen_target():
		var options: Array[int] = game.legal_targets(0, effect, uid)
		if options.is_empty():
			_reject("There is no legal target")
			return
		_begin_targeting(uid, options, GameAction.Type.ACTIVATE, index)
		return
	_submit(GameAction.activate(0, uid, index))


## New brief, Part F: using an equipped item from the item bar. Items are not cards - no Path energy, no
## hand/battlefield involvement - but they reuse the exact same TARGETING flow when their effect
## needs a chosen target (_pending_item, checked first in _finish_targeting).
func _on_item_pressed(item: ItemData) -> void:
	if busy or mode == Mode.TARGETING:
		return
	if not game.can_use_item(0, item):
		_reject(_why_not_usable(item))
		return
	if item.effect.needs_chosen_target():
		var options: Array[int] = game.legal_targets(0, item.effect, 0)
		if options.is_empty():
			_reject("There is no legal target")
			return
		_pending_item = item
		_begin_targeting(0, options, GameAction.Type.CAST, 0)
		return
	_use_item(item, 0)


func _use_item(item: ItemData, target: int) -> void:
	if not Session.use_equipped_item(game, 0, item, target):
		_reject("Cannot use that right now")
		return
	Audio.sfx(&"ui_confirm")
	_clear_selection_state()
	_drive()


func _why_not_usable(item: ItemData) -> String:
	if not game.in_main_phase() or game.active != 0:
		return "You can only use items in your main phase"
	return "There is no legal target"


func _reject(message: String) -> void:
	Audio.sfx(&"ui_error")
	_toast(message)


func _toast(message: String) -> void:
	_toast_label.text = message
	_toast_label.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)


# ---- Targeting --------------------------------------------------------------------------


func _begin_targeting(source: int, options: Array[int], action_type: GameAction.Type, ability: int) -> void:
	mode = Mode.TARGETING
	_target_source = source
	_target_options = options
	_target_action = action_type
	_target_ability = ability
	var opponent_target: bool = options.has(Targets.player(1))
	var self_target: bool = options.has(Targets.player(0))
	hud.set_portrait_targets(self_target, opponent_target)
	_refresh_ui()


func _cancel_targeting() -> void:
	if mode != Mode.TARGETING:
		return
	_pending_item = null
	_clear_selection_state()
	mode = Mode.MAIN
	_refresh_ui()


func _click_portrait_target(pos: Vector2) -> void:
	for index: int in range(2):
		if hud.portrait_rect(index).has_point(pos) and _target_options.has(Targets.player(index)):
			_finish_targeting(Targets.player(index))
			return


func _finish_targeting(ref: int) -> void:
	if _pending_item != null:
		var item: ItemData = _pending_item
		_pending_item = null
		_use_item(item, ref)
		return
	var source: int = _target_source
	var action_type: GameAction.Type = _target_action
	var ability: int = _target_ability
	if action_type == GameAction.Type.CAST:
		_submit(GameAction.cast(0, source, ref))
	else:
		_submit(GameAction.activate(0, source, ability, ref))


# ---- Combat selection -------------------------------------------------------------------


## Selects every creature able to attack (the player can still deselect before confirming).
func _on_attack_all() -> void:
	if busy or mode != Mode.ATTACK:
		return
	for card: CardInstance in game.possible_attackers(0):
		if not _selected_attackers.has(card.uid):
			_selected_attackers.append(card.uid)
			board.attacking[card.uid] = true
	Audio.sfx(&"card_hover")
	board.layout()
	_refresh_ui()
	if tutorial != null:
		tutorial.on_attackers_changed(_selected_attackers.size())


func _toggle_attacker(uid: int) -> void:
	var available: Array[CardInstance] = game.possible_attackers(0)
	if PlayerState.find_in(available, uid) == null:
		_reject("That creature cannot attack")
		return
	if _selected_attackers.has(uid):
		_selected_attackers.erase(uid)
		board.attacking.erase(uid)
	else:
		_selected_attackers.append(uid)
		board.attacking[uid] = true
		Audio.sfx(&"card_hover")
	board.layout()
	_refresh_ui()
	if tutorial != null:
		tutorial.on_attackers_changed(_selected_attackers.size())


func _block_click(uid: int, mine: bool) -> void:
	if mine:
		var blocker: CardInstance = game.players[0].find_battlefield(uid)
		if blocker == null or blocker.exhausted:
			_reject("That creature cannot block")
			return
		# Clicking an assigned blocker removes its block.
		for attacker_uid: Variant in _block_assign.keys():
			if int(_block_assign[attacker_uid]) == uid:
				_block_assign.erase(attacker_uid)
				board.blockers.erase(uid)
				_block_pick = 0
				board.layout()
				_refresh_ui()
				return
		_block_pick = uid
		Audio.sfx(&"card_hover")
	else:
		if not game.attackers.has(uid):
			return
		if _block_pick == 0:
			_toast("Pick one of your creatures first")
			return
		var attacker: CardInstance = game.find_permanent(uid)
		var blocker: CardInstance = game.players[0].find_battlefield(_block_pick)
		if attacker == null or blocker == null or not CombatResolver.can_block(attacker, blocker):
			_reject("That creature cannot block this attacker")
			return
		_block_assign.erase(uid)
		_block_assign[uid] = _block_pick
		board.blockers[_block_pick] = uid
		_block_pick = 0
		Audio.sfx(&"card_play", -4.0)
		board.layout()
	_refresh_ui()


func _toggle_discard(uid: int) -> void:
	if _discard_selection.has(uid):
		_discard_selection.erase(uid)
	elif _discard_selection.size() < game.pending_discard:
		_discard_selection.append(uid)
	Audio.sfx(&"ui_tick")
	_refresh_ui()


# ---- Mulligan and result ----------------------------------------------------------------


func _show_mulligan() -> void:
	if _mulligan_panel != null:
		_mulligan_panel.queue_free()
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.position = Vector2(0, -60)
	_mulligan_panel = center
	_overlay_layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(12)
	panel.add_child(column)
	column.add_child(UIKit.label("Opening hand", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var infrastructure: int = 0
	for card: CardInstance in game.players[0].hand:
		if card.data.is_infrastructure():
			infrastructure += 1
	var info: Label = UIKit.label("%d infrastructure, %d spells in your %d cards." % [infrastructure, game.players[0].hand.size() - infrastructure, game.players[0].hand.size()], &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(info)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var keep: FancyButton = FancyButton.make("Keep Hand", &"PrimaryButton", Vector2(200, 56))
	keep.pressed.connect(func() -> void: _mulligan_choice(true))
	row.add_child(keep)
	var redraw: FancyButton = FancyButton.make("Mulligan (free)", &"", Vector2(220, 56))
	redraw.disabled = game.players[0].mulligan_used or not game.options.free_mulligan
	redraw.pressed.connect(func() -> void: _mulligan_choice(false))
	row.add_child(redraw)
	UIKit.pop_in(panel)


func _mulligan_choice(keep: bool) -> void:
	if _mulligan_panel != null:
		_mulligan_panel.queue_free()
		_mulligan_panel = null
	if keep:
		_submit(GameAction.make(GameAction.Type.KEEP_HAND, 0))
	else:
		_submit(GameAction.make(GameAction.Type.MULLIGAN, 0))


func _show_result() -> void:
	mode = Mode.OVER
	_refresh_ui()
	var won: bool = game.winner == 0
	context.won = won
	Audio.sfx(&"victory" if won else &"defeat")
	await get_tree().create_timer(0.7, false).timeout
	if tutorial != null:
		tutorial.queue_free()
		tutorial = null
	await board.clear_board()
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_panel = center
	_overlay_layer.add_child(center)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.04, 0.6)
	UIKit.full_rect(shade)
	_overlay_layer.add_child(shade)
	_overlay_layer.move_child(shade, 0)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	var title: String = "Victory!" if won else ("Draw" if game.is_draw else "Defeat")
	var title_label: Label = UIKit.label(title, &"TitleLabel", 84, UIStyle.GOLD if won else Color("e06a5a"), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(title_label)
	var detail: String = "You defeated %s in %d turns." % [context.enemy_name, game.turn] if won else "%s wins after %d turns." % [context.enemy_name, game.turn]
	if game.is_draw:
		detail = "Neither side could finish the game."
	column.add_child(UIKit.label(detail, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	if context.zone_battle:
		var zone_note: String = "Your life stays as it is - there is no healing after a battle in the zone. Heal at the hub." if won else "Declared Deceased. You will wake at the hub (and owe a small paperwork fee)."
		column.add_child(UIKit.label(zone_note, &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	elif not won and not context.practice and context.town_npc_id.is_empty():
		column.add_child(UIKit.label("You are carried out of the dungeon. Your collection is safe.", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	elif not won and not context.town_npc_id.is_empty():
		column.add_child(UIKit.label("You can challenge them again anytime.", &"MutedLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var button: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(240, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_continue)
	column.add_child(button)
	UIKit.pop_in(panel)
	if won:
		for i: int in range(5):
			fx.burst(Vector2(400 + i * 280, 300), UIStyle.GOLD, 26, 380.0)


func _continue() -> void:
	finished.emit(context.won)
	if context.practice:
		SceneManager.go_to_town()
	else:
		Session.complete_battle(context)


func _flag(key: String) -> bool:
	return str(_screenshot_args.get(key, "false")) in ["true", "1"]


func screenshot_ready() -> bool:
	if _flag("wait_result"):
		return mode == Mode.OVER and _result_panel != null
	return true


## Lets an AI play the human seat (tests, screenshots) and wakes the loop if it is waiting.
func set_bot(bot: AIPlayer, until_turn: int = 100000) -> void:
	human_bot = bot
	bot_until_turn = until_turn
	if _mulligan_panel != null:
		_mulligan_panel.queue_free()
		_mulligan_panel = null
	if not busy and mode != Mode.OVER:
		_drive()
