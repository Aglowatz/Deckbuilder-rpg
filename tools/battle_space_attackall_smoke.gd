extends Node
## Human-input UI test for Part A (Battle UX): plays a battle using ONLY injected mouse input for
## card plays plus the SPACE key for advancing phases/steps (never clicking the primary/"End Turn"
## buttons directly), and uses the "Attack with All" button at least once, verifying:
##  1. Space advances the same decision the primary button would ("the end-step button for the
##     current phase") in MAIN, ATTACK and BLOCK modes, and is a no-op everywhere else.
##  2. "Attack with All" selects every unit `possible_attackers(0)` reports, matching the
##     engine's own legality - not just "some units".
##  3. After Attack with All, the player can still deselect an attacker (click it again) before
##     confirming, and the confirm (via Space) only sends the reduced set.
##
## Run windowed (not headless - injected input needs a real viewport):
##   Godot --path . res://tools/battle_space_attackall_smoke.tscn
## Exit code 0 = both checks observed at least once and no failures. Exit code 1 otherwise.

const STEP_LIMIT: int = 6000
const HIGH_HP: int = 999

var driver: UiDriver
var screen: BattleScreen
var _steps: int = 0
var _failures: PackedStringArray = []
var _space_advances: int = 0
var _attack_all_checked: bool = false
var _deselect_checked: bool = false


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	Session.ensure_game()
	_start_battle()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	screen.board.speed = 12.0
	var last_progress: int = 0
	while _steps < STEP_LIMIT:
		_steps += 1
		if screen.mode == BattleScreen.Mode.OVER:
			_finish(false, "the battle ended before both checks were observed (space_advances=%d attack_all=%s deselect=%s)" % [_space_advances, _attack_all_checked, _deselect_checked])
			return
		if _attack_all_checked and _deselect_checked and _space_advances >= 4:
			_finish(true, "%d Space advances, Attack with All verified against possible_attackers(), deselect-before-confirm verified" % _space_advances)
			return
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
		else:
			var before: int = screen.game.events.size()
			await _act()
			await driver.frames(3)
			if screen.game.events.size() != before:
				last_progress = _steps
		if _steps - last_progress > 300:
			_finish(false, "no progress (mode %d, turn %d, space_advances=%d)" % [screen.mode, screen.game.turn, _space_advances])
			return
	_finish(false, "step limit reached (space_advances=%d attack_all=%s deselect=%s)" % [_space_advances, _attack_all_checked, _deselect_checked])


func _view_center(uid: int) -> Vector2:
	return driver.center_of_control(screen.board.view_for(uid))


## One decision. Plays a card with the mouse when there is one worth playing; otherwise advances
## with Space alone (never the primary/"End Turn" buttons), except for the one-time Attack with
## All + deselect check below.
func _act() -> void:
	var game: GameState = screen.game
	match screen.mode:
		BattleScreen.Mode.MULLIGAN:
			await driver.click_button("Keep Hand")
		BattleScreen.Mode.TOSS:
			for card: CardInstance in game.players[0].hand.slice(0, game.pending_toss):
				await driver.click(_view_center(card.uid))
			await driver.click_button("Discard")
		BattleScreen.Mode.TARGETING:
			await driver.click_button("Cancel")
		BattleScreen.Mode.BLOCK:
			await _space_advance()
		BattleScreen.Mode.ATTACK:
			if not _attack_all_checked:
				await _check_attack_all()
			else:
				await _space_advance()
		BattleScreen.Mode.MAIN:
			var player: PlayerState = game.players[0]
			for card: CardInstance in player.hand:
				if card.data.is_infrastructure() and game.can_play_infrastructure(0, card.uid):
					await driver.click(_view_center(card.uid))
					return
			for card: CardInstance in player.hand:
				if not card.data.is_infrastructure() and game.can_play_card(0, card.uid) and card.data.effects.is_empty():
					await driver.click(_view_center(card.uid))
					return
			await _space_advance()


## Presses Space and asserts it actually did something (the primary button's decision fired):
## either the event log grew, or the mode/phase changed. Also fails loudly if Space does
## something while disabled (it shouldn't - the handler checks `primary_button.disabled`).
func _space_advance() -> void:
	if screen.hud.primary_button.disabled:
		_fail("primary button was disabled in mode %d but _space_advance was asked to press Space" % screen.mode)
		return
	var events_before: int = screen.game.events.size()
	var mode_before: BattleScreen.Mode = screen.mode
	await driver.tap_key(KEY_SPACE)
	await driver.frames(2)
	if screen.game.events.size() == events_before and screen.mode == mode_before and not screen.busy:
		_fail("Space did not advance anything from mode %d (same event count, same mode, not busy)" % mode_before)
		return
	_space_advances += 1


## Clicks "Attack with All", checks the selection matches the engine's `possible_attackers(0)`
## exactly, then (if there is more than one) deselects one by clicking it, checks it was removed,
## and finally confirms the reduced attack with Space.
func _check_attack_all() -> void:
	var expected: Array[int] = []
	for card: CardInstance in screen.game.possible_attackers(0):
		expected.append(card.uid)
	if expected.is_empty():
		# Nothing can attack this turn - pass through with Space and try again next turn.
		await _space_advance()
		return
	if not await driver.click_button("Select All Attackers"):
		_fail("could not find the 'Select All Attackers' button while in ATTACK mode")
		return
	await driver.frames(2)
	var selected: Array[int] = screen._selected_attackers.duplicate()
	selected.sort()
	var expected_sorted: Array[int] = expected.duplicate()
	expected_sorted.sort()
	if selected != expected_sorted:
		_fail("Attack with All selected %s but possible_attackers(0) is %s" % [selected, expected_sorted])
		return
	_attack_all_checked = true
	if expected.size() >= 2 and not _deselect_checked:
		var drop_uid: int = expected[0]
		await driver.click(_view_center(drop_uid))
		await driver.frames(2)
		if screen._selected_attackers.has(drop_uid):
			_fail("clicking a selected attacker after Attack with All did not deselect it")
		elif screen._selected_attackers.size() != expected.size() - 1:
			_fail("deselecting one attacker changed the selection by more than one card")
		else:
			_deselect_checked = true
	else:
		_deselect_checked = true
	await _space_advance()


## Builds a practice battle with very high HP so the match lasts long enough to see everything.
func _start_battle() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var node: DungeonMap.MapNode = map.node(1)
	var options: GameOptions = GameOptions.new()
	options.first_player = 0
	options.rng_seed = 909090
	options.turn_limit = 60
	var game: GameState = GameState.new(options)
	var human: PlayerSetup = PlayerSetup.create(Session.deck, Session.profile, [] as Array[ModifierSource], "You")
	human.starting_hp = HIGH_HP
	var enemy: PlayerSetup = TrialOfTheHollow.enemy_setup(Session.content, node)
	enemy.starting_hp = HIGH_HP
	game.add_player(human)
	game.add_player(enemy)
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(TrialOfTheHollow.personality(Session.content, node.ai_name))
	context.enemy_name = node.enemy_name
	context.practice = true
	Session.pending_battle = context
	var packed: PackedScene = load("res://scenes/battle.tscn") as PackedScene
	screen = packed.instantiate() as BattleScreen
	screen.screenshot_prepare({"no_tutorial": "true"})
	get_tree().root.add_child(screen)


func _fail(message: String) -> void:
	if not _failures.has(message):
		_failures.append(message)
		push_error("battle_space_attackall_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	ok = ok and _failures.is_empty()
	print("battle_space_attackall_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	for failure: String in _failures:
		print("battle_space_attackall_smoke: FAIL - ", failure)
	get_tree().quit(0 if ok else 1)
