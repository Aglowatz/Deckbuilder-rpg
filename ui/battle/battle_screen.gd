class_name BattleScreen
extends Control
## The duel screen. Owns the GameState, turns the player's clicks into GameActions, lets the AI
## take the opponent's turns, and plays every resulting event through the board and HUD.
## All rules live in core/; this class only decides what to show and which action to submit.

signal finished(won: bool)

enum Mode { WAITING, MAIN, TARGETING, ATTACK, BLOCK, TOSS, MULLIGAN, OVER }

const DRAG_START_DISTANCE: float = 16.0
const PLAY_LINE_Y: float = 720.0
## Modes where the primary button is "the end-step button for the current phase" - Space
## triggers it in exactly these (targeting/discard/mulligan are different decisions, not a
## phase/step advance).
const _SPACE_ADVANCE_MODES: Array[Mode] = [Mode.MAIN, Mode.ATTACK, Mode.BLOCK]

var context: BattleContext
## The `Audio.push_music` token of the battle's song (0 once handed back).
var _music_token: int = 0
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
## How many turns the auto-end-turn option ended (smokes read it).
var auto_ended_turns: int = 0

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
var _target_action: GameAction.Type = GameAction.Type.PLAY
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
## Brief 14: the decision chain for playing a card or activating an ability (targets, cost picks, X), one step at a time.
var _chain_steps: Array[Dictionary] = []
var _chain_pos: int = 0
var _chain_active: bool = false
var _chain_source: int = 0
var _chain_done: Callable = Callable()
var _toast_label: Label
var refuse_widgets: Array[RefusePileWidget] = []
var refuse_viewer: RefusePileViewer
var battle_log: BattleLog


func screenshot_prepare(args: Dictionary) -> void:
	_screenshot_args = args


## Screenshot/dev helper: `--keep=true` keeps the opening hand; `--hover=hand:2` (also field:N, efield:N, token:N, etoken:N, resource:N,
## eresource:N) hovers that card after the board settles, as the mouse would (the preview opens, a hand card lifts).
func _screenshot_hover(spec: String) -> void:
	await get_tree().create_timer(1.5).timeout
	if _flag("keep") and _mulligan_panel != null:
		_mulligan_choice(true)
		await get_tree().create_timer(2.0).timeout
	if spec.is_empty():
		return
	var parts: PackedStringArray = spec.split(":")
	var zone_names: Dictionary = {"hand": BattleBoard.Zone.HAND, "field": BattleBoard.Zone.FIELD, "token": BattleBoard.Zone.TOKENS, "resource": BattleBoard.Zone.RESOURCES, "trap": BattleBoard.Zone.TRAPS}
	var word: String = parts[0]
	var enemy: bool = word.begins_with("e")
	if enemy:
		word = word.substr(1)
	if not zone_names.has(word):
		return
	var owner_index: int = 1 if enemy else 0
	var uids: Array[int] = board._cards_in(owner_index, int(zone_names[word]) as BattleBoard.Zone)
	var at: int = int(parts[1]) if parts.size() > 1 else 0
	if at >= uids.size():
		print("hover: no %s card %d (have %d)" % [parts[0], at, uids.size()])
		return
	var view: CardView = board.view_for(uids[at])
	board._on_hover(view)


## Screenshot/dev helper: `--give=iron:2,redtape:2,ingredient:3,garbage:2,contract:2` puts that many of each on the human's table.
## Screenshot helper (Oct 19): `--result=win|lose` ends the duel after the board settles and shows the result panel.
func _screenshot_result(spec: String) -> void:
	if spec.is_empty():
		return
	await get_tree().create_timer(3.0).timeout
	if _mulligan_panel != null:
		_mulligan_choice(true)
		await get_tree().create_timer(1.0).timeout
	game._end_game(0 if spec == "win" else 1, false)
	busy = false
	await _show_result()


## Oct 20 Dev Menu: ends the duel now (`won` = the hero wins); the normal result panel and completion follow through `_drive`.
func dev_end(won: bool) -> void:
	if game == null or game.is_over():
		return
	if _mulligan_panel != null:
		_mulligan_choice(true)
	game._end_game(0 if won else 1, false)
	if not busy:
		_drive()


## Oct 20 Dev Menu: redraws the board, hand, piles and HUD after the menu changed the game state (cards drawn, energy, resources...).
func dev_refresh() -> void:
	if game == null:
		return
	board.register_all()
	board.sync_state(false)
	board.layout(false)
	hud.refresh_all()
	_refresh_piles()
	_refresh_ui()


func _screenshot_give(spec: String) -> void:
	if spec.is_empty():
		return
	for part: String in spec.split(","):
		var pieces: PackedStringArray = part.split(":")
		var kind: int = ResourceKind.from_word(pieces[0])
		if kind != ResourceKind.NONE:
			ResourceRules.create(game, 0, kind as ResourceKind.Kind, int(pieces[1]) if pieces.size() > 1 else 1)
	board.sync_state(false)
	board.layout(false)


## Screenshot/dev helper: `--bury=0:N-07,N-07;1:C-25` fills Refuse Piles, `--hand=N-17,N-28` adds cards to your hand, `--energy=1` gives
## you every basic infrastructure, `--play=N-17` plays that hand card as the mouse would (opening the targeting viewer),
## `--pick=0` then chooses the Nth legal pile card, `--viewer=0|1` opens the browse viewer on that pile. Runs once the board has settled.
## Screenshot helper (Oct 23): `--script_key=<encounter key>` shows that encounter's rule row and its first scripted event's banner (and the
## warning line) a moment after the board settles.
func _screenshot_script_banner() -> void:
	var key: String = str(_screenshot_args.get("script_key", ""))
	if key.is_empty():
		return
	if hud.rule_row == null:
		hud.set_rule_badges(RuleBadges.for_encounter(EncounterModifiers.rules(key)))
	await get_tree().create_timer(2.0).timeout
	var triggers: Array[EncounterScripts.Trigger] = EncounterScripts.triggers(key)
	if triggers.is_empty():
		return
	var index: int = clampi(int(_screenshot_args.get("script_index", 0)), 0, triggers.size() - 1)
	if hud.rule_row != null:
		hud.rule_row.mark_fired(triggers[0].name, 3)
	for each: EncounterScripts.Trigger in triggers:
		if not each.warn.is_empty():
			script_banner.warn(each.warn)
			break
	script_banner.show_event(triggers[index], context.enemy_name, 0.05)


func _screenshot_scenario() -> void:
	_screenshot_script_banner()
	var keys: Array[String] = ["bury", "hand", "energy", "play", "pick", "viewer", "field", "mark", "efield", "combat", "endturn", "traps", "tape", "etape"]
	var wanted: bool = false
	for key: String in keys:
		wanted = wanted or _screenshot_args.has(key)
	if not wanted:
		return
	await get_tree().create_timer(2.5).timeout
	if _mulligan_panel != null:
		_mulligan_choice(true)
		await get_tree().create_timer(2.5).timeout
	for part: String in str(_screenshot_args.get("bury", "")).split(";", false):
		var halves: PackedStringArray = part.split(":")
		for id: String in halves[1].split(",", false):
			var card: CardData = load("res://data/cards/%s.tres" % id) as CardData
			game.players[int(halves[0])].refuse_pile.append(game.create_instance(card, int(halves[0])))
	## `--traps=0:R-14,R-14;1:R-14` sets traps face down for you (0) and the enemy (1).
	for part: String in str(_screenshot_args.get("traps", "")).split(";", false):
		var sides: PackedStringArray = part.split(":")
		for id: String in sides[1].split(",", false):
			var trap: CardData = load("res://data/cards/%s.tres" % id) as CardData
			game.players[int(sides[0])].traps.append(game.create_instance(trap, int(sides[0])))
	for id: String in str(_screenshot_args.get("hand", "")).split(",", false):
		var card: CardData = load("res://data/cards/%s.tres" % id) as CardData
		game.players[0].hand.append(game.create_instance(card, 0))
	# Oct 22: a T- id is a token (data/tokens), so token art can be photographed on the field too.
	for id: String in str(_screenshot_args.get("field", "")).split(",", false):
		var unit: CardData = load("res://data/%s/%s.tres" % ["tokens" if id.begins_with("T-") else "cards", id]) as CardData
		game.players[0].field.append(game.create_instance(unit, 0))
	for id: String in str(_screenshot_args.get("efield", "")).split(",", false):
		var enemy_unit: CardData = load("res://data/%s/%s.tres" % ["tokens" if id.begins_with("T-") else "cards", id]) as CardData
		game.players[1].field.append(game.create_instance(enemy_unit, 1))
	## `--mark=exhaust:0,buff:1:3` exhausts your field unit 0 and gives field unit 1 three buffs (screenshots of the exhausted and buff badges).
	for part: String in str(_screenshot_args.get("mark", "")).split(",", false):
		var bits: PackedStringArray = part.split(":")
		var target_index: int = int(bits[1]) if bits.size() > 1 else 0
		if target_index < game.players[0].field.size():
			if bits[0] == "exhaust":
				game.players[0].field[target_index].exhausted = true
			elif bits[0] == "buff":
				game.players[0].field[target_index].buffs = int(bits[2]) if bits.size() > 2 else 1
	## Oct 19: `--tape=0` = your Red Tape on enemy field unit 0 (ends at the start of YOUR next turn); `--etape=1` = the enemy's Red Tape
	## on your field unit 1 (ends at the start of the enemy's next turn). Both show the debuff badge with its turns left.
	for index_text: String in str(_screenshot_args.get("tape", "")).split(",", false):
		if int(index_text) < game.players[1].field.size():
			game.change_stats_until_turn_of(game.players[1].field[int(index_text)], -ResourceRules.red_tape_amount(game, 0), 0, 0)
	for index_text: String in str(_screenshot_args.get("etape", "")).split(",", false):
		if int(index_text) < game.players[0].field.size():
			game.change_stats_until_turn_of(game.players[0].field[int(index_text)], -ResourceRules.red_tape_amount(game, 1), 0, 1)
	if _screenshot_args.has("energy"):
		for number: int in range(1, 12):
			var infra: CardData = load("res://data/cards/INF-%02d.tres" % number) as CardData
			if infra != null:
				game.players[0].infrastructure.append(game.create_instance(infra, 0))
	board.register_all()
	board.sync_state(false)
	board.layout(false)
	hud.refresh_all()
	_refresh_piles()
	_refresh_ui()
	await get_tree().create_timer(0.6).timeout
	if _screenshot_args.has("play"):
		for card: CardInstance in game.players[0].hand:
			if card.data.id == str(_screenshot_args["play"]):
				_try_play(card.uid)
				break
		await get_tree().create_timer(0.6).timeout
	if _screenshot_args.has("pick") and refuse_viewer.targeting:
		var nth: int = int(_screenshot_args["pick"])
		if nth >= 0 and nth < _target_options.size():
			_finish_targeting(_target_options[nth])
		await get_tree().create_timer(1.5).timeout
	if _screenshot_args.has("endturn"):
		_on_end_turn()
	## `--combat=all` goes to combat and selects every attacker (the combat preview); `--combat=1` selects only the first.
	if _screenshot_args.has("combat") and mode == Mode.MAIN:
		_on_primary()
		await get_tree().create_timer(1.2).timeout
		if mode == Mode.ATTACK:
			if str(_screenshot_args["combat"]) == "all":
				_on_attack_all()
			elif not game.possible_attackers(0).is_empty():
				_toggle_attacker(game.possible_attackers(0)[0].uid)
	if _screenshot_args.has("viewer"):
		var piles: Array[int] = [int(_screenshot_args["viewer"])]
		refuse_viewer.open_browse(piles)


func _ready() -> void:
	SceneManager.pause_allowed = true
	context = Session.pending_battle
	if context == null:
		if str(_screenshot_args.get("ninja", "false")) == "true":
			context = Session.make_ninja_battle()
		elif str(_screenshot_args.get("vault", "false")) == "true":
			context = Session.make_vault_battle()
		else:
			context = Session.make_practice_battle(str(_screenshot_args.get("enemy", "Cave Scavenger")))
			context.zone_id = str(_screenshot_args.get("zone", ""))
			# Oct 23 (screenshots): `--as=<name>` shows the practice foe under another name (a boss's entrance, its banner lines).
			if _screenshot_args.has("as"):
				context.enemy_name = str(_screenshot_args["as"])
	Session.pending_battle = null
	_music_token = Audio.push_music(StringName(MusicDirector.for_battle(context, Session.flags)), 0.6, false)
	# Sound pass: the place's ambience gives way to the table, and the cards are riffled as the battle begins.
	Audio.set_ambience("none", 0.6)
	Audio.sfx(&"battle_start")
	game = context.game
	ai = context.ai
	_build_scene()
	_screenshot_give(str(_screenshot_args.get("give", "")))
	_screenshot_hover(str(_screenshot_args.get("hover", "")))
	_screenshot_scenario()
	_screenshot_result(str(_screenshot_args.get("result", "")))
	if _screenshot_args.has("lights"):
		_screenshot_lights()
	game.event_emitted.connect(_on_game_event)
	var bot_turns: int = int(_screenshot_args.get("bot", 0))
	if bot_turns > 0:
		human_bot = AIPlayer.new(AIPersonality.balanced())
		bot_until_turn = bot_turns
	board.speed = Settings.battle_speed_scale()
	if _screenshot_args.has("speed"):
		Settings.battle_speed = clampi(int(_screenshot_args["speed"]), 0, Settings.BATTLE_SPEEDS.size() - 1)
		board.speed = Settings.battle_speed_scale()
		hud.set_speed_label()
	if _flag("fast"):
		board.speed = 8.0
	if _flag("force_tutorial"):
		context.tutorial = true
	# Battle feel, Part D: tips show in a new player's battles until each has been seen once (or they are skipped), so the
	# later topics (traps, Tools, the Refuse Pile) appear in whichever early battle first has them. Dev practice duels only when forced.
	if not _flag("no_tutorial") and (_flag("force_tutorial") or (not context.practice and TutorialLayer.wanted())):
		tutorial = TutorialLayer.new()
		add_child(tutorial)
		tutorial.setup(self)
	# Overnight Oct 23, Part 3: a boss's, lieutenant's or gatekeeper's entrance first (skippable), then the battle.
	if BossIntro.wanted(context.enemy_name) and not _flag("no_intro") and not _flag("fast") and (not context.practice or _screenshot_args.has("intro")):
		boss_intro = BossIntro.new()
		add_child(boss_intro)
		boss_intro.play(context.enemy_name, Bestiary.art(context.enemy_name), context.enemy_icon)
		if str(_screenshot_args.get("intro", "")) == "hold":
			boss_intro.hold.call_deferred()
			return
		boss_intro.finished.connect(_drive, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
		return
	_drive.call_deferred()


## "The Gainlands" etc. for the zone-effects panel (the zone's own display name).
func _zone_title(zone_id: String) -> String:
	if zone_id.is_empty() or not ZoneDefs.has_def(zone_id):
		return ""
	return ZoneDefs.get_def(zone_id).display_name

## Graphics Tier 1, Part 3: the effect lights of this duel (BattleLights).
var lights: BattleLights


## Screenshot helper (Tier 1): `--lights=true` holds three effect lights on the table after the board settles (a hit on each portrait, a spell in the middle).
func _screenshot_lights() -> void:
	await get_tree().create_timer(2.5).timeout
	if lights == null:
		return
	lights.pulse(BattleBoard.CENTER_POINT, Color("ff9c4a"), 320.0, 1.1, 60.0)
	lights.pulse(hud.portrait_center(0), Color("7be08a"), 260.0, 0.9, 60.0)
	lights.pulse(hud.portrait_center(1), Color("ff5a5a"), 260.0, 1.0, 60.0)


func _build_scene() -> void:
	# Screenshot/dev helpers: --ctx=<context key> (e.g. zone:beefcake, capital:in) or --board=<Battleboard ID> picks the board without playing to it.
	if _screenshot_args.has("ctx"):
		context.board_key = str(_screenshot_args["ctx"])
	var backdrop: TextureRect = TextureRect.new()
	backdrop.name = "Battleboard"
	backdrop.texture = Battleboards.texture_for(str(_screenshot_args.get("board", context.board_key)))
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(backdrop)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Graphics Tier 1, Part 3: the board's own grade per area and the effect lights (the board and the cards are lit, the HUD is not).
	backdrop.material = BattleGrade.material_for(context.zone_id)
	BattleLights.mark_lit(backdrop)
	add_child(backdrop)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.07, 0.2)
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
	lights = BattleLights.new()
	lights.name = "BattleLights"
	lights.setup(Settings.graphics_quality)
	_board_root.add_child(lights)
	fx.lights = lights
	board.setup(game, fx)
	hud.setup(game, context.enemy_name, context.enemy_icon)
	# Playtest v0.4.0 Part F: one icon row for every rule of the fight (the old text panels are gone); Primm's phase rule keeps its own panel.
	hud.set_rule_badges(context.rule_badges)
	if context.zone_id == CapitalZone.ID and not context.rules_text.is_empty():
		hud.set_capital_panels({}, context.rules_text)
	if not context.arena_id.is_empty():
		hud.set_arena_banner(context.arena_id)
	board.portrait_anchor = [hud.portrait_center(0), hud.portrait_center(1)]
	var deck_spots: Array[Vector2] = [hud.deck_center(0), hud.deck_center(1)]
	board.deck_anchor = deck_spots
	board.card_hovered.connect(_on_card_hovered)
	board.card_unhovered.connect(_on_card_unhovered)
	board.card_input.connect(_on_card_input)
	hud.primary_pressed.connect(_on_primary)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.attack_all_pressed.connect(_on_attack_all)
	hud.speed_pressed.connect(_on_speed_pressed)
	# New brief, Part F: the equipped-items row, next to the player's own portrait.
	if Session.profile != null and Session.profile.item_slots > 0:
		item_bar = ItemBar.new()
		item_bar.position = Vector2(24, 700)
		_board_root.add_child(item_bar)
		item_bar.setup(game, Session.profile)
		item_bar.item_pressed.connect(_on_item_pressed)
	_build_refuse_piles()
	battle_log = BattleLog.new()
	_board_root.add_child(battle_log)
	battle_log.setup(game, context.enemy_name, board.card_data)
	battle_log.position = Vector2(24, 646)
	battle_log.z_index = 50
	if _flag("log"):
		battle_log.toggle()
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
	# Overnight Oct 23, Part 1: scripted boss/elite events and the warning the turn before a timed one.
	script_banner = ScriptEventBanner.new()
	script_banner.z_index = 480
	add_child(script_banner)


const _SEEN_EVENT_TYPES: Array[GameEvent.Type] = [
	GameEvent.Type.CARD_PLAYED, GameEvent.Type.PERMANENT_ENTERED, GameEvent.Type.TRAP_SET,
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
		_refresh_piles()
		if item_bar != null:
			item_bar.refresh()
		_refresh_resource_tokens()
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
		battle_log.add_event(event)
		_refresh_piles()
		if event.type == GameEvent.Type.SCRIPT_TRIGGERED:
			await _show_script_event(event)
		elif event.type == GameEvent.Type.SCRIPT_WARNING and script_banner != null:
			script_banner.warn(event.detail)
		await board.present(event)
		if tutorial != null:
			tutorial.on_battle_event(event)
	await board.flush_center()


func _ai_step() -> void:
	await get_tree().create_timer(0.35 / board.speed, false).timeout
	# Battle AI upgrade, Part 4: a decision that takes a while (a boss planning a full board) is named before the search runs, so
	# the screen never just stalls; the search itself is time-boxed (AIPersonality.time_budget_ms).
	if ai.last_think_ms > 150.0 and game.in_main_phase():
		hud.announce("%s is thinking..." % context.enemy_name, 0.6 / board.speed)
		await get_tree().process_frame
	var action: GameAction = ai.choose_action(game)
	var line: String = _describe_ai_action(action)
	if not line.is_empty():
		# Battle feel, Part B: the opponent's move is named for a moment before it resolves, at every speed. Part 4: combat
		# declarations hold a little longer, so the attackers and blocks can be read before damage lands.
		var hold: float = 0.8 if action.type == GameAction.Type.DECLARE_ATTACKERS or action.type == GameAction.Type.DECLARE_BLOCKERS else 0.5
		hud.announce(line, (hold + 0.2) / board.speed)
		await get_tree().create_timer(hold / board.speed, false).timeout
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
	if game.stage != GameState.Stage.PLAYING or game.pending_toss > 0:
		return false
	if game.phase != GameState.Phase.COMBAT:
		if _fast_end_turn and game.active == 0 and game.phase != GameState.Phase.END:
			game.apply_action(GameAction.pass_phase(0))
			return true
		if should_auto_end_turn():
			_fast_end_turn = true
			auto_ended_turns += 1
			Audio.sfx(&"turn_end")
			_toast("Nothing left to play: turn ended")
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


## Overnight Oct 18, Part 7 (Settings > Battle > Auto-end turn, off by default): in your main phase with no card, ability or attack left,
## the turn ends by itself. Items never hold it open (an item is always "usable"). Never during the guided first battles or for bots.
func should_auto_end_turn() -> bool:
	if not Settings.auto_end_turn or human_bot != null or game.active != 0 or game.awaiting_player() != 0 or not game.in_main_phase():
		return false
	if tutorial != null and tutorial.blocks_turn_end():
		return false
	if game.phase == GameState.Phase.MAIN1 and not game.possible_attackers(0).is_empty():
		return false
	var moves: Vector2i = _moves_left(true)
	return moves.x + moves.y == 0


func _any_block_possible() -> bool:
	for attacker_uid: int in game.attackers:
		var attacker: CardInstance = game.find_permanent(attacker_uid)
		for blocker: CardInstance in game.possible_blockers(0):
			if attacker != null and CombatResolver.can_block(game, attacker, blocker):
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
	_sync_pile_viewer()


# ---- Human decision modes ---------------------------------------------------------------


func _enter_human_mode() -> void:
	if game.active != 0 or game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
		# Blocking on the opponent's turn is a real decision; don't fast-forward past it.
		_fast_end_turn = false
	if game.stage == GameState.Stage.MULLIGAN:
		mode = Mode.MULLIGAN
		_show_mulligan()
	elif game.pending_toss > 0:
		mode = Mode.TOSS
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
			for card: CardInstance in game.players[0].field + game.players[0].infrastructure:
				if _usable_ability(card) >= 0 or not _usable_abilities(card).is_empty():
					glows[card.uid] = CardView.Glow.PLAYABLE
			primary = "To Combat" if game.phase == GameState.Phase.MAIN1 else "End Turn"
			end_visible = game.phase == GameState.Phase.MAIN1
			prompt = "[b]Your main phase[/b]\nPlay an infrastructure and play spells. Click a card, or drag it onto the table."
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
			prompt = "[b]Choose attackers[/b]\nClick your units to send them into battle."
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
			prompt = "[b]Block![/b]\nClick one of your units, then the attacker it should block."
		Mode.TOSS:
			for card: CardInstance in game.players[0].hand:
				glows[card.uid] = CardView.Glow.TARGET if _discard_selection.has(card.uid) else CardView.Glow.PLAYABLE
			primary = "Toss (%d/%d)" % [_discard_selection.size(), game.pending_toss]
			primary_enabled = _discard_selection.size() == game.pending_toss
			prompt = "[b]Too many cards[/b]\nChoose %d card%s to toss." % [game.pending_toss, "" if game.pending_toss == 1 else "s"]
		Mode.TARGETING:
			for uid: int in _target_options:
				if uid > 0:
					glows[uid] = CardView.Glow.TARGET
			glows[_target_source] = CardView.Glow.SELECTED
			primary = "Cancel"
			prompt = "[b]Choose a target[/b]\nClick a highlighted target. Right-click to cancel."
			if _chain_active and _chain_pos < _chain_steps.size():
				var step: Dictionary = _chain_steps[_chain_pos]
				prompt = str(step["prompt"])
				for picked_uid: int in step["picked"] as Array[int]:
					glows[picked_uid] = CardView.Glow.SELECTED
				if str(step["kind"]) == "multi":
					primary = "Done (%d/%d)" % [(step["picked"] as Array[int]).size(), int(step["max"])]
		Mode.MULLIGAN:
			primary = "..."
			primary_enabled = false
			prompt = "[b]Opening hand[/b]\nKeep it, or take your free mulligan."
		Mode.OVER:
			primary = "..."
			primary_enabled = false
	board.set_glows(glows)
	board.set_dims(_dims())
	_refresh_combat_preview()
	if primary_enabled and _SPACE_ADVANCE_MODES.has(mode):
		primary += "  [%s]" % Keybinds.first_key(&"battle_advance")
	hud.primary_button.text = primary
	hud.primary_button.disabled = not primary_enabled
	hud.end_turn_button.visible = end_visible
	hud.attack_all_button.visible = mode == Mode.ATTACK
	hud.set_prompt(prompt)
	UiSkin.set_targeting(mode == Mode.TARGETING)
	_sync_pile_viewer()
	_update_arrows()


func _is_playable(card: CardInstance) -> bool:
	if card.data.is_infrastructure():
		return game.can_play_infrastructure(0, card.uid)
	return game.can_play_card(0, card.uid)


## Battle feel, Part A: which cards are shown dimmed. Your hand cards you can't play right now (in every mode but the
## mulligan and the toss), and while choosing a target every card that is not a legal target.
func _dims() -> Dictionary:
	var dims: Dictionary = {}
	if mode == Mode.TARGETING:
		for uid: int in board.views.keys():
			if not _target_options.has(uid) and uid != _target_source:
				dims[uid] = true
		return dims
	if mode in [Mode.MAIN, Mode.ATTACK, Mode.BLOCK, Mode.WAITING]:
		for card: CardInstance in game.players[0].hand:
			if mode != Mode.MAIN or not _is_playable(card):
				dims[card.uid] = true
	return dims


## Battle feel, Part A: the live combat preview while you choose attackers (assuming no blocks) or blockers.
func _refresh_combat_preview() -> void:
	if mode == Mode.ATTACK and not _selected_attackers.is_empty():
		board.show_combat_preview(CombatPreview.predict(game, 0, _selected_attackers, {}), "if unblocked")
	elif mode == Mode.BLOCK:
		board.show_combat_preview(CombatPreview.predict(game, 0, [] as Array[int], _block_assign))
	else:
		board.clear_combat_preview()


## The short line on the hover preview of your hand card that can't be played now ("" when it can, or is not yours).
func _hover_note(view: CardView) -> String:
	if bool(view.get_meta("trap_peek", false)):
		return "Set face down - only you can read it."
	var card: CardInstance = game.players[0].find_hand(view.instance_uid)
	if card == null or mode == Mode.MULLIGAN or mode == Mode.TOSS or mode == Mode.OVER:
		return ""
	if game.active != 0:
		return "Not your turn"
	if not game.in_main_phase():
		return "Wrong phase: play cards in a main phase"
	if _is_playable(card):
		return ""
	if card.data.is_infrastructure():
		return "One infrastructure per turn"
	var pips: Array[Affinity.Type] = game.pips_for(0, card.data, card)
	if not game.can_pay_energy(0, game.generic_cost_for(0, card.data, card), pips):
		return "Not enough energy"
	return "No legal target (or its extra cost can't be paid)"


## Index of the first activated ability the player can use on this permanent, or -1.
func _usable_ability(card: CardInstance) -> int:
	for index: int in range(card.data.effects.size()):
		if card.data.effects[index].trigger == CardEnums.Trigger.ACTIVATED and game.can_activate(0, card.uid, index):
			return index
	return -1


func _update_arrows() -> void:
	var arrows: Array[Dictionary] = []
	if mode == Mode.ATTACK:
		for uid: int in _selected_attackers:
			var to: Vector2 = hud.portrait_center(1)
			arrows.append({"from": board.center_of(uid), "to": to, "color": Color("ff9c4a")})
	elif mode == Mode.BLOCK:
		for attacker_uid: Variant in _block_assign.keys():
			arrows.append({"from": board.center_of(int(_block_assign[attacker_uid])), "to": board.center_of(int(attacker_uid)), "color": Color("6ab8ff")})
	fx.set_arrows(arrows)


func _process(_delta: float) -> void:
	if mode == Mode.TARGETING:
		# The line runs from the card (or your plate, for items and resources) and snaps onto a legal target under the mouse.
		var aim: Vector2 = get_global_mouse_position()
		var on_target: bool = false
		if _hovered_view != null and _target_options.has(_hovered_view.instance_uid):
			aim = board.center_of(_hovered_view.instance_uid)
			on_target = true
		for index: int in range(2):
			if hud.portrait_rect(index).has_point(aim) and _target_options.has(Targets.player(index)):
				aim = hud.portrait_center(index)
				on_target = true
		var from: Vector2 = board.center_of(_target_source) if _target_source != 0 else hud.portrait_center(0)
		var arrows: Array[Dictionary] = [{"from": from, "to": aim, "color": Color("ff3a3a") if on_target else Color("ff8a7a")}]
		fx.set_arrows(arrows)
	if _dragging and board.drag_uid != 0:
		board.drag_center = get_global_mouse_position()
		board.layout(false)


# ---- Button handlers --------------------------------------------------------------------


func _on_primary() -> void:
	if busy or _confirm_open:
		return
	match mode:
		Mode.MAIN:
			if _tutorial_holds_turn():
				return
			if game.phase == GameState.Phase.MAIN2:
				_confirm_end_turn(func() -> void: _submit(GameAction.pass_phase(0)))
			else:
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
		Mode.TOSS:
			var action: GameAction = GameAction.make(GameAction.Type.TOSS, 0)
			for uid: int in _discard_selection:
				action.uids.append(uid)
			_submit(action)
		Mode.TARGETING:
			if _chain_active and _chain_pos < _chain_steps.size() and str(_chain_steps[_chain_pos]["kind"]) == "multi":
				_chain_advance()
			else:
				_cancel_targeting()


func _on_end_turn() -> void:
	if busy or not (mode == Mode.MAIN or mode == Mode.ATTACK) or _confirm_open:
		return
	if _tutorial_holds_turn():
		return
	_confirm_end_turn(func() -> void:
		Audio.sfx(&"turn_end")
		_fast_end_turn = true
		_clear_selection_state()
		_submit(GameAction.pass_phase(0))
	)


var _confirm_open: bool = false


## Overnight Oct 17, Part 9: the first-battle guide asks the player to spend their Resource before moving on (only while it can be).
func _tutorial_holds_turn() -> bool:
	if tutorial == null or not tutorial.blocks_turn_end():
		return false
	_reject("Spend your Resource first: the guide is waiting for it.")
	return true


## Battle feel, Part B: ending the turn while cards could still be played (in this main phase, or the second one when you end
## it from combat) or abilities used asks first, with "don't ask again" (Settings.confirm_end_turn). Bots never ask.
func _confirm_end_turn(end: Callable) -> void:
	var moves: Vector2i = _moves_left()
	var left: int = moves.x + moves.y
	if not Settings.confirm_end_turn or human_bot != null or left == 0:
		end.call()
		return
	_confirm_open = true
	var parts: PackedStringArray = []
	if moves.x > 0:
		parts.append("play %d card%s" % [moves.x, "" if moves.x == 1 else "s"])
	if moves.y > 0:
		parts.append("use %d abilit%s" % [moves.y, "y" if moves.y == 1 else "ies"])
	var energy: int = game.players[0].ready_infrastructure().size()
	var message: String = ("You have %d energy left and can still %s this turn." % [energy, " and ".join(parts)]) if energy > 0 else "You can still %s this turn." % " and ".join(parts)
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, "End your turn?", message, "End Turn", "Keep playing", false, "Don't ask again")
	dialog.name = "EndTurnConfirm"
	var remember: Callable = func() -> void:
		_confirm_open = false
		if dialog.check != null and dialog.check.button_pressed:
			Settings.confirm_end_turn = false
			Settings.save_settings()
	dialog.confirmed.connect(func() -> void:
		remember.call()
		end.call()
	)
	dialog.cancelled.connect(remember)


## How many hand cards could still be played this turn (on a clone that skips ahead to the second main phase when you are in
## combat) and the abilities you could use now, as (cards, abilities). One infrastructure counts at most once.
func _moves_left(any_mode: bool = false) -> Vector2i:
	if game.active != 0 or game.stage != GameState.Stage.PLAYING:
		return Vector2i.ZERO
	var trial: GameState = game.clone(false, 1)
	var guard: int = 0
	while not trial.in_main_phase() and trial.active == 0 and guard < 3 and not trial.is_over():
		trial.apply_action(GameAction.pass_phase(0))
		guard += 1
	if not trial.in_main_phase() or trial.active != 0:
		return Vector2i.ZERO
	var count: int = 0
	var infrastructure: int = 0
	var abilities: int = 0
	for card: CardInstance in trial.players[0].hand:
		if card.data.is_infrastructure():
			infrastructure = 1 if trial.can_play_infrastructure(0, card.uid) else infrastructure
		elif trial.can_play_card(0, card.uid):
			count += 1
	if mode == Mode.MAIN or any_mode:
		for card: CardInstance in game.players[0].field + game.players[0].infrastructure:
			if _usable_ability(card) >= 0 or not _usable_abilities(card).is_empty():
				abilities += 1
	return Vector2i(count + infrastructure, abilities)


func _on_speed_pressed() -> void:
	Settings.battle_speed = (Settings.battle_speed + 1) % Settings.BATTLE_SPEEDS.size()
	Settings.save_settings()
	if not _flag("fast"):
		board.speed = Settings.battle_speed_scale()
	hud.set_speed_label()
	Audio.sfx(&"ui_tick")


## The line the opponent's move is announced with ("" for passes and other bookkeeping).
func _describe_ai_action(action: GameAction) -> String:
	var who: String = context.enemy_name
	match action.type:
		GameAction.Type.PLAY:
			var card: CardInstance = game.find_card(action.card_uid)
			if card == null:
				return ""
			if card.data.type == CardEnums.CardType.TRAP:
				return "%s sets a trap" % who
			var target: String = ""
			if action.target != 0:
				target = " on %s" % _ref_name(action.target)
			return "%s plays %s%s" % [who, card.data.display_name, target]
		GameAction.Type.PLAY_INFRASTRUCTURE:
			var infra: CardInstance = game.find_card(action.card_uid)
			return "%s plays %s" % [who, infra.data.display_name] if infra != null else ""
		GameAction.Type.ACTIVATE, GameAction.Type.ACTIVATE_ABILITY:
			var source: CardInstance = game.find_card(action.card_uid)
			return "%s uses %s" % [who, source.data.display_name] if source != null else ""
		GameAction.Type.USE_RESOURCE:
			return "%s uses a %s on %s" % [who, ResourceKind.display_name(action.effect_index as ResourceKind.Kind), _ref_name(action.target)]
		GameAction.Type.DECLARE_ATTACKERS:
			if action.uids.is_empty():
				return ""
			var first: CardInstance = game.find_card(action.uids[0])
			var lead: String = first.data.display_name if first != null else "a unit"
			return "%s attacks with %s%s" % [who, lead, "" if action.uids.size() == 1 else " and %d more" % (action.uids.size() - 1)]
		GameAction.Type.DECLARE_BLOCKERS:
			if action.blocks.is_empty():
				return ""
			return "%s blocks with %d unit%s" % [who, action.blocks.size(), "" if action.blocks.size() == 1 else "s"]
	return ""


func _ref_name(ref: int) -> String:
	if Targets.is_player(ref):
		return "you" if Targets.player_index(ref) == 0 else "itself"
	var card: CardInstance = game.find_card(ref)
	return card.data.display_name if card != null else "a card"


# ---- Card interaction -------------------------------------------------------------------


func _on_card_hovered(view: CardView) -> void:
	_hovered_view = view
	hud.show_preview(view, _hover_note(view))
	if view.get_meta("owner", 0) == 0 and board.zones.get(view.instance_uid) == BattleBoard.Zone.HAND:
		Audio.sfx(&"card_hover", -3.0)


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
	# Oct 19: a click on a set trap reads it (yours) or names it (the enemy's "Face-down Trap"), like a hover.
	if zone == BattleBoard.Zone.TRAPS and button_event.pressed and mode != Mode.TARGETING:
		_hovered_view = view
		hud.show_preview(view, _hover_note(view))
		return
	match mode:
		Mode.MAIN:
			if zone == BattleBoard.Zone.HAND and mine and button_event.pressed:
				_press_uid = uid
				_press_pos = get_global_mouse_position()
			elif (zone == BattleBoard.Zone.FIELD or zone == BattleBoard.Zone.INFRASTRUCTURE) and mine and button_event.pressed:
				_try_activate(uid)
			elif (zone == BattleBoard.Zone.RESOURCES or zone == BattleBoard.Zone.TOKENS) and mine and button_event.pressed and view.data != null:
				_on_resource_pressed(view.data.resource_kind as ResourceKind.Kind)
		Mode.ATTACK:
			if button_event.pressed and zone == BattleBoard.Zone.FIELD and mine:
				_toggle_attacker(uid)
		Mode.BLOCK:
			if button_event.pressed and zone == BattleBoard.Zone.FIELD:
				_block_click(uid, mine)
		Mode.TOSS:
			if button_event.pressed and zone == BattleBoard.Zone.HAND and mine:
				_toggle_discard(uid)
		Mode.TARGETING:
			if button_event.pressed and _target_options.has(uid):
				_finish_targeting(uid)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"battle_advance"):
		if not busy and _SPACE_ADVANCE_MODES.has(mode) and not hud.primary_button.disabled:
			_on_primary()
		return
	if event.is_action_pressed(&"battle_end_turn"):
		_on_end_turn()
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _press_uid != 0 and mode == Mode.MAIN and not _dragging:
		if (get_global_mouse_position() - _press_pos).length() > DRAG_START_DISTANCE:
			_dragging = true
			Audio.sfx(&"card_pickup")
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
	if not game.can_play_card(0, uid):
		_reject(_why_not_castable(card))
		return
	var steps: Array[Dictionary] = _play_steps(card)
	if steps.is_empty():
		var effect: EffectData = _target_effect(card.data)
		if effect != null:
			var options: Array[int] = game.legal_targets(0, effect, uid)
			if not options.is_empty():
				_begin_targeting(uid, options, GameAction.Type.PLAY, 0)
				return
		_submit(GameAction.play_card(0, uid))
		return
	_start_chain(uid, steps, func(result: Dictionary) -> void:
		var chosen: Array[int] = result["targets"] as Array[int]
		var action: GameAction = GameAction.play_card(0, uid, chosen[0] if not chosen.is_empty() else 0)
		action.targets = chosen
		action.picks = result["picks"] as Array[int]
		_submit(action)
	)


## The choices the player makes when playing a card: its declared targets, then the units/tokens it destroys or uses as an
## additional cost.
func _play_steps(card: CardInstance) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	var ability: CardAbility = game.play_ability_of(card.data)
	if ability != null:
		for index: int in range(ability.targets.size()):
			var decl: CardAbility.TargetDecl = ability.targets[index]
			var options: Array[int] = game.legal_play_targets(0, card.uid, index)
			if options.is_empty():
				continue
			steps.append(_target_step(decl, options))
	var ctx: AbilityContext = game.play_context(0, card)
	for cost: CardAbility.Cost in game.play_costs_of(card.data):
		var pick_step: Dictionary = _cost_pick_step(ctx, cost)
		if not pick_step.is_empty():
			steps.append(pick_step)
	return steps


func _target_step(decl: CardAbility.TargetDecl, options: Array[int]) -> Dictionary:
	var many: bool = decl.max_count > 1
	var text: String = "Choose up to %d targets" % decl.max_count if many else "Choose a target"
	return {"role": "target", "kind": "multi" if many else "ref", "options": options, "max": decl.max_count, "prompt": "[b]%s[/b]\nClick a highlighted target. Right-click to cancel." % text, "picked": [] as Array[int]}


## A "destroy a unit you control" / "use a token" cost: the player chooses which.
func _cost_pick_step(ctx: AbilityContext, cost: CardAbility.Cost) -> Dictionary:
	var options: Array[int] = []
	if cost.kind == "destroy":
		for card: CardInstance in AbilityRunner.destroy_cost_options(ctx, cost):
			options.append(card.uid)
	elif cost.kind == "use_token":
		for card: CardInstance in AbilityRunner.token_cost_options(ctx):
			if not card.data.is_resource() and not card.data.is_table_token():
				options.append(card.uid)
	if options.is_empty() or (options.size() <= cost.count and cost.kind == "destroy"):
		return {}
	var wording: String = "Choose the unit to destroy" if cost.kind == "destroy" else "Choose the token to use"
	return {"role": "pick", "kind": "multi" if cost.count > 1 else "ref", "options": options, "max": cost.count, "prompt": "[b]%s[/b]\nThis is part of the cost. Right-click to cancel." % wording, "picked": [] as Array[int]}


func _why_not_castable(card: CardInstance) -> String:
	if not game.in_main_phase() or game.active != 0:
		return "You can only play cards in your main phase"
	var pips: Array[Affinity.Type] = game.pips_for(0, card.data, card)
	if not game.can_pay_energy(0, game.generic_cost_for(0, card.data, card), pips):
		return "Not enough energy"
	return "There is no legal target, or you can't pay its extra cost"


func _target_effect(data: CardData) -> EffectData:
	for effect: EffectData in data.effects:
		if effect.trigger == CardEnums.Trigger.ON_ENTER and effect.needs_chosen_target():
			return effect
	return null


# ---- Decision chains (Brief 14) --------------------------------------------------------------


## Walks the player through `steps` (targets, cost picks, X) and then calls `done` with {"targets", "picks", "x"}.
func _start_chain(source_uid: int, steps: Array[Dictionary], done: Callable) -> void:
	_chain_steps = steps
	_chain_pos = 0
	_chain_active = true
	_chain_source = source_uid
	_chain_done = done
	_chain_enter_step()


func _chain_enter_step() -> void:
	var step: Dictionary = _chain_steps[_chain_pos]
	if str(step["kind"]) == "x":
		_show_x_dialog(step)
		return
	_begin_targeting(_chain_source, step["options"] as Array[int], GameAction.Type.PLAY, 0)
	_chain_active = true


func _chain_pick(ref: int) -> void:
	var step: Dictionary = _chain_steps[_chain_pos]
	var picked: Array[int] = step["picked"] as Array[int]
	if str(step["kind"]) == "multi":
		if picked.has(ref):
			picked.erase(ref)
		elif picked.size() < int(step["max"]):
			picked.append(ref)
		if picked.size() >= int(step["max"]):
			_chain_advance()
		else:
			_refresh_ui()
		return
	picked.append(ref)
	_chain_advance()


func _chain_advance() -> void:
	_chain_pos += 1
	if _chain_pos < _chain_steps.size():
		_chain_enter_step()
		return
	var result: Dictionary = {"targets": [] as Array[int], "picks": [] as Array[int], "x": 0}
	for step: Dictionary in _chain_steps:
		match str(step["role"]):
			"target":
				(result["targets"] as Array[int]).append_array(step["picked"] as Array[int])
			"pick":
				(result["picks"] as Array[int]).append_array(step["picked"] as Array[int])
			"x":
				result["x"] = int(step["value"])
	var done: Callable = _chain_done
	_chain_reset()
	_clear_selection_state()
	mode = Mode.MAIN
	done.call(result)


func _chain_reset() -> void:
	_chain_steps = []
	_chain_pos = 0
	_chain_active = false
	_chain_done = Callable()


## "Use X Ingredients": the player picks X (1 to the most they can afford).
func _show_x_dialog(step: Dictionary) -> void:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "XDialog"
	panel.position = Vector2(760, 420)
	_overlay_layer.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose X", &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for value: int in range(1, int(step["max"]) + 1):
		var button: FancyButton = FancyButton.make(str(value), &"", Vector2(70, 56))
		var chosen: int = value
		button.pressed.connect(func() -> void:
			step["value"] = chosen
			panel.queue_free()
			_chain_advance()
		)
		row.add_child(button)
	var cancel: FancyButton = FancyButton.make("Cancel", &"GhostButton", Vector2(160, 46))
	cancel.pressed.connect(func() -> void:
		panel.queue_free()
		_cancel_targeting()
	)
	column.add_child(cancel)


## Resources and Contract tokens sit on the table (BattleBoard Zone.RESOURCES and TOKENS). Your Iron, Red Tape and Contract glow when you can use one now.
func _refresh_resource_tokens() -> void:
	for uid: int in board.views.keys():
		if not [BattleBoard.Zone.RESOURCES, BattleBoard.Zone.TOKENS].has(int(board.zones.get(uid, -1))):
			continue
		var view: CardView = board.view_for(uid)
		if view == null or view.data == null or int(view.get_meta("owner", 0)) != 0:
			continue
		var kind: ResourceKind.Kind = view.data.resource_kind as ResourceKind.Kind
		var usable: bool = mode == Mode.MAIN and not busy and ResourceKind.has_use_ability(kind) and game.in_main_phase() and game.active == 0 and game.can_pay_energy(0, 1, [] as Array[Affinity.Type]) and not ResourceRules.use_targets(game, 0, kind).is_empty()
		view.set_glow(CardView.Glow.PLAYABLE if usable else CardView.Glow.NONE)


## Brief 14: clicking an Iron, Red Tape or Contract coin picks a target unit (the same targeting flow cards use).
func _on_resource_pressed(kind: ResourceKind.Kind) -> void:
	if busy or mode != Mode.MAIN:
		return
	var options: Array[int] = []
	for target_uid: int in ResourceRules.use_targets(game, 0, kind):
		if game.can_use_resource(0, kind, target_uid):
			options.append(target_uid)
	if options.is_empty():
		_reject("You need a %s, 1 energy and a unit to use it on" % ResourceKind.display_name(kind))
		return
	_begin_targeting(0, options, GameAction.Type.USE_RESOURCE, int(kind))


func _try_activate(uid: int) -> void:
	var card: CardInstance = game.players[0].find_field(uid)
	if card == null:
		card = game.players[0].find_infrastructure(uid)
	if card == null:
		return
	var usable: Array[int] = _usable_abilities(card)
	if not usable.is_empty():
		if usable.size() == 1:
			_begin_ability(card, usable[0])
		else:
			_show_ability_menu(card, usable)
		return
	var index: int = _usable_ability(card)
	if index < 0:
		for ability: CardAbility in card.data.abilities():
			if ability.is_activated():
				_reject("That ability can't be used right now")
				return
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


## Indices of the scripted activated abilities of a permanent that can be used right now.
func _usable_abilities(card: CardInstance) -> Array[int]:
	var result: Array[int] = []
	var abilities: Array[CardAbility] = card.data.abilities()
	for index: int in range(abilities.size()):
		if abilities[index].is_activated() and _ability_available(card, index):
			result.append(index)
	return result


## An ability is usable if it has legal targets and costs, for some choice of X.
func _ability_available(card: CardInstance, index: int) -> bool:
	var ability: CardAbility = card.data.abilities()[index]
	var uses_x: bool = false
	for cost: CardAbility.Cost in ability.costs:
		uses_x = uses_x or cost.x_count
	return game.can_activate_ability(0, card.uid, index, [] as Array[int], 1 if uses_x else 0)


func _begin_ability(card: CardInstance, index: int) -> void:
	var ability: CardAbility = card.data.abilities()[index]
	var ctx: AbilityContext = game.activation_context(0, card, ability)
	var steps: Array[Dictionary] = []
	for decl: CardAbility.TargetDecl in ability.targets:
		var options: Array[int] = TargetResolver.legal_targets(decl, ctx)
		if not options.is_empty():
			steps.append(_target_step(decl, options))
	for cost: CardAbility.Cost in ability.costs:
		if cost.x_count:
			var most: int = 1
			for kind: ResourceKind.Kind in cost.resource_kinds:
				most = maxi(most, game.players[0].count_resource(kind))
			if most > 1:
				steps.append({"role": "x", "kind": "x", "max": mini(most, 12), "value": 1, "picked": [] as Array[int]})
		else:
			var pick_step: Dictionary = _cost_pick_step(ctx, cost)
			if not pick_step.is_empty():
				steps.append(pick_step)
	var finish: Callable = func(result: Dictionary) -> void:
		var chosen: Array[int] = result["targets"] as Array[int]
		var x_value: int = int(result["x"]) if int(result["x"]) > 0 else _default_x(ability)
		var action: GameAction = GameAction.activate_ability(0, card.uid, index, chosen, x_value)
		action.picks = result["picks"] as Array[int]
		_submit(action)
	if steps.is_empty():
		finish.call({"targets": [] as Array[int], "picks": [] as Array[int], "x": 0})
		return
	_start_chain(card.uid, steps, finish)


func _default_x(ability: CardAbility) -> int:
	for cost: CardAbility.Cost in ability.costs:
		if cost.x_count:
			return 1
	return 0


## Several abilities can be used: a small menu of them next to the card.
func _show_ability_menu(card: CardInstance, usable: Array[int]) -> void:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "AbilityMenu"
	panel.position = board.center_of(card.uid) + Vector2(-140, -40)
	_overlay_layer.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	column.add_child(UIKit.label(card.data.display_name, &"HeadingLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	for index: int in usable:
		var ability: CardAbility = card.data.abilities()[index]
		var button: FancyButton = FancyButton.make(AbilityDescriber.describe(ability), &"", Vector2(360, 50))
		var chosen: int = index
		button.pressed.connect(func() -> void:
			panel.queue_free()
			_begin_ability(card, chosen)
		)
		column.add_child(button)
	var close: FancyButton = FancyButton.make("Never mind", &"GhostButton", Vector2(160, 44))
	close.pressed.connect(func() -> void: panel.queue_free())
	column.add_child(close)


## New brief, Part F: using an equipped item from the item bar. Items are not cards - no energy, no
## hand/field involvement - but they reuse the exact same TARGETING flow when their effect
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
		_begin_targeting(0, options, GameAction.Type.PLAY, 0)
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
	if game.item_used(0, item):
		return "Each item works once per battle"
	return "There is no legal target"


## Overnight Oct 23, Part 1: the banner of a scripted event; its rule icon is marked as done.
var script_banner: ScriptEventBanner
## Overnight Oct 23, Part 3: the entrance before a boss battle (null once it has finished).
var boss_intro: BossIntro


func _show_script_event(event: GameEvent) -> void:
	var trigger: EncounterScripts.Trigger = EncounterScripts.trigger_for_event(event.detail)
	if trigger == null or script_banner == null:
		return
	if hud.rule_row != null:
		hud.rule_row.mark_fired(trigger.name, game.turn)
	if lights != null:
		lights.pulse(hud.portrait_center(event.player), ScriptEventBanner.AMBER, 300.0, 1.0, 60.0)
	await script_banner.show_event(trigger, context.enemy_name, board.speed)


func _reject(message: String) -> void:
	Audio.sfx(&"ui_error")
	_toast(message)


func _toast(message: String) -> void:
	_toast_label.text = message
	_toast_label.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)



# ---- Refuse Piles (viewer and pile targeting) ------------------------------------------------


func _build_refuse_piles() -> void:
	# Oct 19: each Refuse Pile stands right beside its owner's deck (above the player's, below the opponent's), in the deck's column.
	var spots: Array[Vector2] = [
		BattleHud.DECK_PILE_POSITIONS[0] + Vector2(-6, -RefusePileWidget.WIDGET_SIZE.y - 2),
		BattleHud.DECK_PILE_POSITIONS[1] + Vector2(-6, DeckPile.PILE_SIZE.y - 6),
	]
	for index: int in range(2):
		var widget: RefusePileWidget = RefusePileWidget.new()
		_board_root.add_child(widget)
		widget.setup(index)
		widget.position = spots[index]
		widget.pressed.connect(_on_pile_pressed)
		refuse_widgets.append(widget)
		board.grave_anchor[index] = spots[index] + RefusePileWidget.STACK_TOP + CardView.SIZE * RefusePileWidget.CARD_SCALE * 0.5
	refuse_viewer = RefusePileViewer.new()
	add_child(refuse_viewer)
	refuse_viewer.setup(game)
	refuse_viewer.card_chosen.connect(func(uid: int) -> void:
		if mode == Mode.TARGETING and not busy:
			_finish_targeting(uid)
	)
	refuse_viewer.done_pressed.connect(_on_primary)
	refuse_viewer.cancel_pressed.connect(_cancel_targeting)
	_refresh_piles()


func _refresh_piles() -> void:
	for index: int in range(refuse_widgets.size()):
		refuse_widgets[index].show_pile(game.players[index].refuse_pile)


func _on_pile_pressed(player_index: int) -> void:
	if mode == Mode.TARGETING and _options_in_refuse_piles():
		_sync_pile_viewer()
		return
	var piles: Array[int] = [player_index]
	refuse_viewer.open_browse(piles)


func _in_refuse_pile(uid: int) -> bool:
	for player: PlayerState in game.players:
		for card: CardInstance in player.refuse_pile:
			if card.uid == uid:
				return true
	return false


func _options_in_refuse_piles() -> bool:
	for uid: int in _target_options:
		if uid > 0 and _in_refuse_pile(uid):
			return true
	return false


## While an effect needs cards from a Refuse Pile the viewer shows it in targeting mode (legal cards glow); in every other
## state a targeting viewer closes.
func _sync_pile_viewer() -> void:
	if refuse_viewer == null:
		return
	var wants: bool = mode == Mode.TARGETING and _options_in_refuse_piles()
	for index: int in range(refuse_widgets.size()):
		var holds: bool = false
		if wants:
			for card: CardInstance in game.players[index].refuse_pile:
				if _target_options.has(card.uid):
					holds = true
		refuse_widgets[index].set_targetable(holds)
	if not wants:
		if refuse_viewer.targeting:
			refuse_viewer.targeting = false
			refuse_viewer.close()
		return
	var picked: Array[int] = [] as Array[int]
	var max_count: int = 1
	var prompt: String = "[b]Choose a card in the Refuse Pile[/b]  Click a highlighted card."
	if _chain_active and _chain_pos < _chain_steps.size():
		var step: Dictionary = _chain_steps[_chain_pos]
		picked = step["picked"] as Array[int]
		max_count = int(step["max"])
		if max_count > 1:
			prompt = "[b]Choose up to %d cards in the Refuse Pile[/b]  Click highlighted cards, then Done." % max_count
	refuse_viewer.open_targeting(_target_options, picked, max_count, prompt, true)


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
	_chain_reset()
	_clear_selection_state()
	mode = Mode.MAIN
	_refresh_ui()


func _click_portrait_target(pos: Vector2) -> void:
	for index: int in range(2):
		if hud.portrait_rect(index).has_point(pos) and _target_options.has(Targets.player(index)):
			_finish_targeting(Targets.player(index))
			return


func _finish_targeting(ref: int) -> void:
	if _chain_active:
		_chain_pick(ref)
		return
	if _pending_item != null:
		var item: ItemData = _pending_item
		_pending_item = null
		_use_item(item, ref)
		return
	var source: int = _target_source
	var action_type: GameAction.Type = _target_action
	var ability: int = _target_ability
	if action_type == GameAction.Type.USE_RESOURCE:
		_submit(GameAction.use_resource(0, ability as ResourceKind.Kind, ref))
		return
	if action_type == GameAction.Type.PLAY:
		_submit(GameAction.play_card(0, source, ref))
	else:
		_submit(GameAction.activate(0, source, ability, ref))


# ---- Combat selection -------------------------------------------------------------------


## Selects every unit able to attack (the player can still deselect before confirming).
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
		_reject("That unit cannot attack")
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
		var blocker: CardInstance = game.players[0].find_field(uid)
		if blocker == null or blocker.exhausted:
			_reject("That unit cannot block")
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
			_toast("Pick one of your units first")
			return
		var attacker: CardInstance = game.find_permanent(uid)
		var blocker: CardInstance = game.players[0].find_field(_block_pick)
		if attacker == null or blocker == null or not CombatResolver.can_block(game, attacker, blocker):
			_reject("That unit cannot block this attacker")
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
	elif _discard_selection.size() < game.pending_toss:
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


## The boss-victory sting of this battle's song ("STG-WIN-BEEF-BOSS" for MUS-BEEF-BOSS), "" when the song is not a boss track or has none.
func boss_victory_sting() -> String:
	var song: String = MusicDirector.for_battle(context, Session.flags)
	if not song.ends_with("-BOSS"):
		return ""
	var id: String = "STG-WIN-%s" % song.trim_prefix("MUS-")
	return id if AudioRegistry.has_id(id) else ""


func _show_result() -> void:
	mode = Mode.OVER
	_refresh_ui()
	var won: bool = game.winner == 0
	if not context.arena_id.is_empty():
		won = ArenaDefs.find(context.arena_id).player_won(game)
	context.won = won
	# The fight is over: the battle song gives way to the area's music, with the result sting over it.
	_release_battle_music(0.5)
	# Overnight Oct 17, Part 12: a boss falls to its own track's climax (a sting cut from it), every other win to the victory sting.
	var boss_sting: String = boss_victory_sting()
	if won and not boss_sting.is_empty() and Audio.music != null and Audio.music.sting(boss_sting):
		Audio.sfx(&"victory_layer")
	else:
		Audio.sfx(&"victory" if won else &"defeat")
	# Battle feel, Part C: a short end sequence before the result panel: the banner, the losing plate knocked out, and a
	# gold shower on a win. Fast and Very Fast shorten it.
	hud.show_banner("Victory!" if won else ("Draw" if game.is_draw else "Defeat"), UIStyle.GOLD if won else Color("e06a5a"))
	if not game.is_draw and game.winner >= 0:
		hud.knock_out(1 - game.winner)
		fx.burst(hud.portrait_center(1 - game.winner), Color("ff8a5a"), 30, 320.0)
		fx.shake(10.0, 0.3)
	if won:
		for i: int in range(3):
			fx.burst(Vector2(600 + i * 380, 380), UIStyle.GOLD, 22, 340.0)
	await get_tree().create_timer(1.2 / maxf(board.speed, 1.0), false).timeout
	if tutorial != null:
		tutorial.queue_free()
		tutorial = null
	await board.clear_board()
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_panel = center
	_overlay_layer.add_child(center)
	# Oct 19: the fight's own board fades in blurred behind the result panel (covering the HUD), the same backdrop the rewards use.
	_overlay_layer.z_index = 200  # above the board's trays (z 20-60) and the battle log (z 50)
	var backdrop: PostBattleBackdrop = PostBattleBackdrop.for_board(str(_screenshot_args.get("board", context.board_key)))
	_overlay_layer.add_child(backdrop)
	_overlay_layer.move_child(backdrop, 0)
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
	if not context.arena_id.is_empty():
		var arena_encounter: ArenaEncounter = ArenaDefs.find(context.arena_id)
		var arena_story: StoryText = StoryText.shared()
		if arena_encounter.is_puzzle():
			title_label.text = "Puzzle Solved!" if won else "Puzzle Failed"
			detail = arena_story.text("arena.puzzle.won" if won else "arena.puzzle.lost")
		else:
			detail = arena_story.text("arena.won.first" if won and not Session.is_arena_cleared(context.arena_id) else ("arena.won.replay" if won else "arena.lost"))
	column.add_child(UIKit.label(detail, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	if context.zone_battle:
		var zone_note: String = "Your HP stays as it is - there is no healing after a battle in the zone. Heal at the hub." if won else "Declared Deceased. You will wake at the hub (and owe a small paperwork fee)."
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


func _exit_tree() -> void:
	UiSkin.set_targeting(false)
	_release_battle_music(0.8)


## The battle's song is an override over the area track: handing it back resumes the area's music where it left off.
func _release_battle_music(fade: float) -> void:
	if _music_token != 0:
		Audio.pop_music(_music_token, fade)
		_music_token = 0
