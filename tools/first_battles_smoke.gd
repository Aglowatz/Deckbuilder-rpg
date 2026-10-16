extends Node
## Battle feel, Parts D and E: plays the intro dungeon's three battles (Cave Scavenger, Hollow Stalker, Hollow Warden) as a
## brand-new player, with the tips on, using only mouse clicks: one battle at each speed (Normal, Fast, Very Fast). It
## records every tip shown, checks that each appears once, that a bubble never covers what it talks about, how long each
## battle takes, the HP left, and the lowest fps seen while the board animates. Run windowed: tools/run_first_battles_smoke.sh.

const STEP_LIMIT: int = 9000
const BATTLE_NODES: Array[int] = [1, 3, 5]
const SPEEDS: Array[int] = [0, 1, 2]

var driver: UiDriver
var screen: BattleScreen
var _failures: PackedStringArray = []
var _tips: Array[String] = []
var _tip_battle: Dictionary = {}
var _last_tip: String = ""
var _report: PackedStringArray = []
var _worst_fps: float = 1000.0
var _fps_timer: float = 0.0
var _fps_samples: int = 0
var _cover_frames: int = 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	Session.ensure_game()
	Settings.confirm_end_turn = true
	driver = UiDriver.new(get_tree())
	var map: DungeonMap = TrialOfTheHollow.build_map()
	for index: int in range(BATTLE_NODES.size()):
		Settings.battle_speed = SPEEDS[index]
		var node: DungeonMap.MapNode = map.node(BATTLE_NODES[index])
		_start_battle(node)
		await driver.frames(10)
		var started: int = Time.get_ticks_msec()
		var result: String = await _play_battle(index + 1)
		var seconds: float = float(Time.get_ticks_msec() - started) / 1000.0
		_report.append("battle %d (%s, speed %s): %s in %d turns, %.0f s, you %d HP, enemy %d HP" % [index + 1, node.enemy_name, Settings.BATTLE_SPEED_NAMES[SPEEDS[index]], result, screen.game.turn, seconds, screen.game.players[0].hp, screen.game.players[1].hp])
		if index == 0:
			for line: String in screen.battle_log.lines:
				print("battle1 log: ", line)
		if index == 0 and result != "won":
			_fail("the first battle was not won (%s)" % result)
		if index == 0 and screen.game.turn > 16:
			_fail("the first battle took %d turns (should be quick)" % screen.game.turn)
		screen.queue_free()
		await driver.frames(10)
	for tip: String in ["intro", "infrastructure", "energy", "unit", "attack"]:
		if not _tips.has(tip):
			_fail("the %s tip never appeared" % tip)
	var order: PackedStringArray = []
	for tip: String in _tips:
		order.append("%s(b%d)" % [tip, int(_tip_battle[tip])])
	_report.append("tips in order: " + ", ".join(order))
	_report.append("lowest fps while animating: %.0f over %d samples" % [_worst_fps, _fps_samples])
	_finish(_failures.is_empty())


func _start_battle(node: DungeonMap.MapNode) -> void:
	var options: GameOptions = GameOptions.new()
	options.first_player = 0
	options.rng_seed = 777 + node.id
	options.turn_limit = 60
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(Session.deck, Session.profile, [] as Array[ModifierSource], "You"))
	game.add_player(TrialOfTheHollow.enemy_setup(Session.content, node))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(TrialOfTheHollow.personality(Session.content, node.ai_name))
	context.enemy_name = node.enemy_name
	context.tutorial = node.tutorial
	Session.pending_battle = context
	var packed: PackedScene = load("res://scenes/battle.tscn") as PackedScene
	screen = packed.instantiate() as BattleScreen
	get_tree().root.add_child(screen)


func _play_battle(number: int) -> String:
	var steps: int = 0
	var last_progress: int = 0
	while steps < STEP_LIMIT:
		steps += 1
		_watch(number)
		if screen.mode == BattleScreen.Mode.OVER:
			await driver.seconds(1.0)
			return "won" if screen.game.winner == 0 else ("draw" if screen.game.is_draw else "lost")
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING:
			await driver.frames(2)
			continue
		var before: int = screen.game.events.size()
		await _act()
		await driver.frames(3)
		if screen.game.events.size() != before:
			last_progress = steps
		if steps - last_progress > 300:
			_fail("battle %d: no progress (mode %d, turn %d)" % [number, screen.mode, screen.game.turn])
			return "stuck"
	return "step limit"


## Records the tip on screen and checks it covers nothing it talks about; samples fps while the board is animating.
func _watch(number: int) -> void:
	var delta: float = get_process_delta_time()
	_fps_timer += delta
	if _fps_timer >= 0.5 and screen.busy:
		_fps_timer = 0.0
		_fps_samples += 1
		_worst_fps = minf(_worst_fps, Engine.get_frames_per_second())
	if screen.tutorial == null:
		return
	var tip: String = screen.tutorial.current_step()
	if tip != "" and tip != _last_tip:
		if _tips.has(tip):
			_fail("the %s tip appeared twice" % tip)
		else:
			_tips.append(tip)
			_tip_battle[tip] = number
	_last_tip = tip
	if tip == "":
		return
	var bubble: Rect2 = screen.tutorial.bubble_rect()
	# The bubble glides into place; judge it once it has settled near its spot.
	for rect: Rect2 in screen.tutorial._avoid_rects(tip):
		if rect.size != Vector2.ZERO and bubble.size != Vector2.ZERO and bubble.intersects(rect.grow(-6.0)):
			var spot: Vector2 = screen.tutorial._best_spot(screen.tutorial._target_rect(tip), screen.tutorial._avoid_rects(tip), bubble.size)
			if bubble.position.distance_to(spot) < 4.0:
				_cover_frames += 1
				if _cover_frames > 45:
					_fail("the %s tip covers what it talks about (bubble %s, subject %s)" % [tip, str(bubble), str(rect)])
				return
	_cover_frames = 0


func _view_center(uid: int) -> Vector2:
	return driver.center_of_control(screen.board.view_for(uid))


## A new player's decisions, by mouse only: keep the hand, play an infrastructure, play what can be paid for (picking the
## first legal target), attack with everything, block the biggest attacker when they can, end the turn (confirming the prompt).
func _act() -> void:
	var game: GameState = screen.game
	var confirm: Node = screen.find_child("EndTurnConfirm", true, false)
	if confirm != null:
		var buttons: Array[Node] = confirm.find_children("*", "FancyButton", true, false)
		if not buttons.is_empty():
			await driver.click(driver.button_center(buttons[0] as Button))
		return
	match screen.mode:
		BattleScreen.Mode.MULLIGAN:
			# A new player reads the opening tip first.
			await driver.seconds(1.5)
			await driver.click_button("Keep Hand")
		BattleScreen.Mode.TOSS:
			for card: CardInstance in game.players[0].hand.slice(0, game.pending_toss):
				await driver.click(_view_center(card.uid))
			await driver.click(driver.button_center(screen.hud.primary_button))
		BattleScreen.Mode.BLOCK:
			var blocked: bool = false
			if screen._block_assign.is_empty():
				for blocker: CardInstance in game.possible_blockers(0):
					for attacker_uid: int in game.attackers:
						var attacker: CardInstance = game.find_permanent(attacker_uid)
						if attacker != null and CombatResolver.can_block(game, attacker, blocker) and game.get_defense(blocker) > game.get_attack(attacker):
							await driver.click(_view_center(blocker.uid))
							await driver.frames(2)
							await driver.click(_view_center(attacker_uid))
							blocked = true
							break
					if blocked:
						break
			await driver.frames(2)
			await driver.click(driver.button_center(screen.hud.primary_button))
		BattleScreen.Mode.TARGETING:
			_target_tries += 1
			if _target_tries > 3:
				_target_tries = 0
				await driver.click(driver.button_center(screen.hud.primary_button))
				return
			for uid: int in screen._target_options:
				if uid > 0 and screen.board.view_for(uid) != null:
					await driver.click(_view_center(uid))
					return
			for index: int in range(2):
				if screen._target_options.has(Targets.player(index)):
					await driver.click(screen.hud.portrait_center(index))
					return
			await driver.click(driver.button_center(screen.hud.primary_button))
		BattleScreen.Mode.ATTACK:
			if screen._selected_attackers.is_empty() and not game.possible_attackers(0).is_empty():
				for card: CardInstance in game.possible_attackers(0):
					await driver.click(_view_center(card.uid))
				await driver.frames(2)
			await driver.click(driver.button_center(screen.hud.primary_button))
		BattleScreen.Mode.MAIN:
			var player: PlayerState = game.players[0]
			for card: CardInstance in player.hand:
				if card.data.is_infrastructure() and game.can_play_infrastructure(0, card.uid):
					await driver.click(_view_center(card.uid))
					return
			for card: CardInstance in player.hand:
				if not card.data.is_infrastructure() and game.can_play_card(0, card.uid) and not _tried.has(card.uid):
					_tried[card.uid] = true
					await driver.click(_view_center(card.uid))
					return
			await driver.click(driver.button_center(screen.hud.primary_button))


## Hand cards already clicked once (a card whose play was refused is not clicked again).
var _tried: Dictionary = {}
var _target_tries: int = 0


func _fail(message: String) -> void:
	if not _failures.has(message):
		_failures.append(message)
		push_error("first_battles_smoke: " + message)


func _finish(ok: bool) -> void:
	for line: String in _report:
		print("first_battles_smoke: ", line)
	print("first_battles_smoke: %s" % ("OK" if ok else "FAILED"))
	for failure: String in _failures:
		print("first_battles_smoke: FAIL - ", failure)
	get_tree().quit(0 if ok else 1)
