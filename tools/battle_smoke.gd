extends Node
## Plays a whole battle through real mouse events (clicks and drags) with a simple policy and
## reports how it ended. Run windowed (not headless):
##   Godot --path . res://tools/battle_smoke.tscn -- [--enemy="Hollow Warden"] [--shots]
## Exit code 0 = the battle reached a result screen; 1 = it got stuck or errored.

var driver: UiDriver
var screen: BattleScreen
var _steps: int = 0
var _dragged_once: bool = false
var _take_shots: bool = false
var _log: PackedStringArray = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_take_shots = args.has("shots")
	Session.save_enabled = false
	Session.ensure_game()
	var packed: PackedScene = load("res://scenes/battle.tscn") as PackedScene
	screen = packed.instantiate() as BattleScreen
	screen.screenshot_prepare({"enemy": str(args.get("enemy", "Cave Scavenger")), "no_tutorial": "true"})
	get_tree().root.add_child(screen)
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	screen.board.speed = 10.0
	var last_progress: int = 0
	while _steps < 4000:
		_steps += 1
		if screen.mode == BattleScreen.Mode.OVER and screen._result_panel != null:
			await driver.seconds(1.0)
			_finish(true)
			return
		if screen.busy or screen.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
			continue
		var before: int = screen.game.events.size()
		await _act()
		await driver.frames(3)
		if screen.game.events.size() != before:
			last_progress = _steps
		if _steps - last_progress > 60:
			_finish(false, "no progress at mode %d turn %d phase %d" % [screen.mode, screen.game.turn, screen.game.phase])
			return
	_finish(false, "step limit")


func _finish(ok: bool, reason: String = "") -> void:
	var game: GameState = screen.game
	print("battle_smoke: %s turns=%d winner=%d steps=%d %s" % ["OK" if ok else "FAILED", game.turn, game.winner, _steps, reason])
	if _take_shots:
		get_tree().root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://_screenshots/smoke_result.png"))
	get_tree().quit(0 if ok else 1)


func _view_center(uid: int) -> Vector2:
	var view: CardView = screen.board.view_for(uid)
	return driver.center_of_control(view)


func _act() -> void:
	var game: GameState = screen.game
	match screen.mode:
		BattleScreen.Mode.MULLIGAN:
			await driver.click_button("Keep Hand")
		BattleScreen.Mode.MAIN:
			await _act_main(game)
		BattleScreen.Mode.ATTACK:
			for card: CardInstance in game.possible_attackers(0):
				if game.get_power(card) > 0:
					await driver.click(_view_center(card.uid))
			await driver.click(driver.button_center(driver.find_button("Attack with")) if driver.find_button("Attack with") != null else driver.button_center(driver.find_button("No Attack")))
		BattleScreen.Mode.BLOCK:
			var used: Array[int] = []
			for attacker_uid: int in game.attackers:
				var attacker: CardInstance = game.find_permanent(attacker_uid)
				for blocker: CardInstance in game.possible_blockers(0):
					if used.has(blocker.uid) or attacker == null or not CombatResolver.can_block(attacker, blocker):
						continue
					if game.get_toughness(blocker) > game.get_power(attacker) or game.players[0].life <= game.get_power(attacker):
						used.append(blocker.uid)
						await driver.click(_view_center(blocker.uid))
						await driver.click(_view_center(attacker_uid))
						break
			var confirm: Button = driver.find_button("Confirm Blocks")
			if confirm == null:
				confirm = driver.find_button("No Blocks")
			await driver.click(driver.button_center(confirm))
		BattleScreen.Mode.DISCARD:
			for card: CardInstance in game.players[0].hand.slice(0, game.pending_discard):
				await driver.click(_view_center(card.uid))
			await driver.click_button("Discard")
		BattleScreen.Mode.TARGETING:
			var target: int = screen._target_options[0]
			if target > 0:
				await driver.click(_view_center(target))
			else:
				await driver.click(screen.hud.portrait_rect(Targets.player_index(target)).get_center())


func _act_main(game: GameState) -> void:
	var player: PlayerState = game.players[0]
	# Land first, then the most expensive castable card; drag the first spell once.
	for card: CardInstance in player.hand:
		if card.data.is_land() and game.can_play_land(0, card.uid):
			await driver.click(_view_center(card.uid))
			return
	var best: CardInstance = null
	for card: CardInstance in player.hand:
		if not card.data.is_land() and game.can_cast(0, card.uid):
			if best == null or card.data.mana_value() > best.data.mana_value():
				best = card
	if best != null:
		if not _dragged_once and best.data.effects.is_empty():
			_dragged_once = true
			await driver.drag(_view_center(best.uid), Vector2(985, 480))
		else:
			await driver.click(_view_center(best.uid))
		return
	await driver.click(driver.button_center(driver.find_button("To Combat") if driver.find_button("To Combat") != null else driver.find_button("End Turn")))
