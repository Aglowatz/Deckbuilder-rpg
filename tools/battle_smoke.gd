extends Node
## Plays a whole battle through real mouse events (clicks and drags) with BattlePilot and
## reports how it ended. Run windowed (not headless):
##   Godot --path . res://tools/battle_smoke.tscn -- [--enemy="Hollow Warden"] [--tutorial] [--shots]
## Exit code 0 = the battle reached a result screen; 1 = it got stuck or errored.

var driver: UiDriver
var screen: BattleScreen
var pilot: BattlePilot
var _steps: int = 0
var _take_shots: bool = false


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
	screen.screenshot_prepare({
		"enemy": str(args.get("enemy", "Cave Scavenger")),
		"no_tutorial": "false" if args.has("tutorial") else "true",
		"force_tutorial": "true" if args.has("tutorial") else "false",
	})
	get_tree().root.add_child(screen)
	driver = UiDriver.new(get_tree())
	pilot = BattlePilot.new(driver, screen)
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
		await pilot.act()
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
