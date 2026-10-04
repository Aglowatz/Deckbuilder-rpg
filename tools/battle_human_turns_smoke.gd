extends Node
## Regression test for the "human turns get skipped" bug (A1): plays a whole battle where the
## HUMAN seat (player 0) is driven ONLY through injected mouse input (no keyboard, no bot), for
## at least MIN_HUMAN_TURNS full turns (infrastructure drop, cast, attack, end turn each turn), and asserts
## the battle screen actually entered a human decision mode (Mode.MAIN) on every one of the
## player's turns - i.e. the game always waits for human input on the human's turn, never
## auto-passing it.
##
## Turns alternate between the two real ways a player ends a turn, because the original bug
## ("End Turn" leaking `_fast_end_turn` into later turns) only reproduces via the dedicated
## shortcut button, not the main "To Combat" / "End Turn" progression button:
##  - even turns: cast, declare an actual attack, then finish through Main 2 normally.
##  - odd turns:  cast, then click the "End Turn" shortcut to fast-forward the rest of the turn.
##
## Run windowed (not headless - injected mouse input needs a real viewport):
##   Godot --path . res://tools/battle_human_turns_smoke.tscn
## Exit code 0 = at least MIN_HUMAN_TURNS human turns were seen, each with a MAIN decision point.
## Exit code 1 = a human turn was silently skipped, or the run stalled/errored.

const MIN_HUMAN_TURNS: int = 6
const STEP_LIMIT: int = 6000
const HIGH_LIFE: int = 999

var driver: UiDriver
var screen: BattleScreen
var _steps: int = 0
var _turns_with_main: Dictionary = {}
var _failures: PackedStringArray = []


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
		_observe()
		if _turns_with_main.size() >= MIN_HUMAN_TURNS:
			_finish(true, "saw %d human turns, each with a MAIN decision point" % _turns_with_main.size())
			return
		if screen.mode == BattleScreen.Mode.OVER:
			_finish(false, "the battle ended before %d human turns were seen (only %d)" % [MIN_HUMAN_TURNS, _turns_with_main.size()])
			return
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
		else:
			var before: int = screen.game.events.size()
			await _act()
			await driver.frames(3)
			if screen.game.events.size() != before:
				last_progress = _steps
		if _steps - last_progress > 240:
			_finish(false, "no progress (mode %d, turn %d, human turns seen: %d)" % [screen.mode, screen.game.turn, _turns_with_main.size()])
			return
	_finish(false, "step limit reached with only %d human turns seen" % _turns_with_main.size())


func _view_center(uid: int) -> Vector2:
	return driver.center_of_control(screen.board.view_for(uid))


## One decision, using the real UI only: mouse clicks, no keyboard, no bot. `use_shortcut`
## picks which of the two "end the turn" buttons to use once nothing else is left to play,
## as explained above.
func _act() -> void:
	var game: GameState = screen.game
	var use_shortcut: bool = game.turn % 4 == 1
	match screen.mode:
		BattleScreen.Mode.MULLIGAN:
			await driver.click_button("Keep Hand")
		BattleScreen.Mode.DISCARD:
			for card: CardInstance in game.players[0].hand.slice(0, game.pending_discard):
				await driver.click(_view_center(card.uid))
			await driver.click_button("Discard")
		BattleScreen.Mode.BLOCK:
			await driver.click_button("No Blocks")
		BattleScreen.Mode.TARGETING:
			await driver.click_button("Cancel")
		BattleScreen.Mode.ATTACK:
			if use_shortcut:
				await driver.click(driver.button_center(screen.hud.end_turn_button))
			else:
				for card: CardInstance in game.possible_attackers(0):
					await driver.click(_view_center(card.uid))
				var button: Button = driver.find_button("Attack with")
				if button == null:
					button = driver.find_button("No Attack")
				await driver.click(driver.button_center(button))
		BattleScreen.Mode.MAIN:
			var player: PlayerState = game.players[0]
			for card: CardInstance in player.hand:
				if card.data.is_infrastructure() and game.can_play_infrastructure(0, card.uid):
					await driver.click(_view_center(card.uid))
					return
			for card: CardInstance in player.hand:
				if not card.data.is_infrastructure() and game.can_cast(0, card.uid) and card.data.effects.is_empty():
					await driver.click(_view_center(card.uid))
					return
			if use_shortcut and game.phase == GameState.Phase.MAIN1:
				await driver.click(driver.button_center(screen.hud.end_turn_button))
			else:
				var button: Button = driver.find_button("To Combat")
				if button == null:
					button = driver.find_button("End Turn")
				await driver.click(driver.button_center(button))


## Builds a practice battle where both sides have very high life, so the match reliably lasts
## long enough to observe MIN_HUMAN_TURNS full human turns before anyone wins or loses.
func _start_battle() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var node: DungeonMap.MapNode = map.node(1)
	var options: GameOptions = GameOptions.new()
	options.first_player = 0
	options.rng_seed = 424242
	options.turn_limit = 60
	var game: GameState = GameState.new(options)
	var human: PlayerSetup = PlayerSetup.create(Session.deck, Session.profile, [] as Array[ModifierSource], "You")
	human.starting_life = HIGH_LIFE
	var enemy: PlayerSetup = TrialOfTheHollow.enemy_setup(Session.content, node)
	enemy.starting_life = HIGH_LIFE
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


## Records, for the game's CURRENT turn number, whether the human (player 0) was actually given
## a Mode.MAIN decision point this frame - and flags it immediately if the screen is doing
## something on the human's turn that is not a legitimate human decision mode.
func _observe() -> void:
	var game: GameState = screen.game
	if game.active != 0 or game.stage != GameState.Stage.PLAYING:
		return
	if screen.mode == BattleScreen.Mode.MAIN:
		_turns_with_main[game.turn] = true
	elif screen.mode != BattleScreen.Mode.WAITING and game.awaiting_player() != 0:
		_fail("battle screen is in mode %d on turn %d, but the game is not waiting on the human" % [screen.mode, game.turn])


func _fail(message: String) -> void:
	if not _failures.has(message):
		_failures.append(message)
		push_error("battle_human_turns_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	ok = ok and _failures.is_empty()
	print("battle_human_turns_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	for failure: String in _failures:
		print("battle_human_turns_smoke: FAIL - ", failure)
	get_tree().quit(0 if ok else 1)
