class_name CorruptedNpcSmoke
extends Node
## New brief, Part E: a human-input e2e regression test for one corrupted-NPC encounter - talks
## to Torvin (Beefcake), checks the pre-fight dialogue and that it actually starts a real battle
## with the right opponent (name, life, town_npc_id), plays the duel out for real with
## BattlePilot (a real, uncertain outcome - not scripted), then checks the town-side result
## (post-fight dialogue matches what actually happened, and only a win actually pays out/unlocks).
## Run through the real scene tree (needs the real town <-> battle SceneManager transition):
##   Godot --path . res://tools/corrupted_npc_launcher.tscn
## Exit code 0 = every check passed; 1 = a check failed.

const STALL_LIMIT: float = 20.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}


func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)

	var town: TownScene = await _wait_for_town()
	await _walk_to(town, "npc_beefcake", true)
	await driver.frames(3)
	_check(town.hud._prompt_label.text.contains("Talk"), "the prompt near a corrupted NPC reads Talk")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	_check(town.dialogue.active, "talking to a corrupted NPC opens dialogue")
	_check(town.dialogue._speaker.text == "Torvin the Over-Pumped", "the dialogue speaker is the corrupted NPC")
	var guard: int = 0
	while town.dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)

	var battle: BattleScreen = await _wait_for_battle()
	_check(battle != null, "the dialogue actually leads into a real battle")
	if battle == null:
		_finish(false, "no battle started")
		return
	_check(battle.context.town_npc_id == "beefcake", "the battle context is tagged as the beefcake challenge")
	_check(battle.context.enemy_name == "Torvin the Over-Pumped", "the battle opponent is the corrupted NPC")
	_check(battle.game.players[1].life == CorruptedNpcs.STARTING_LIFE, "the corrupted NPC starts at 15 life")

	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	battle.board.speed = 10.0
	var steps: int = 0
	var last_progress: int = 0
	while steps < 4000:
		steps += 1
		if battle.mode == BattleScreen.Mode.OVER and battle._result_panel != null:
			break
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			await driver.frames(4)
			continue
		var before: int = battle.game.events.size()
		await pilot.act()
		await driver.frames(3)
		if battle.game.events.size() != before:
			last_progress = steps
		if steps - last_progress > 60:
			break
	_check(battle.mode == BattleScreen.Mode.OVER, "the duel actually finishes (%d steps)" % steps)
	var won: bool = battle.context.won
	var gold_before: int = Session.gold
	await driver.click_button("Continue")

	var back: TownScene = await _wait_for_town()
	_check(back != null, "returning from the fight comes back to town")
	if back == null:
		_finish(false, "did not return to town")
		return
	await driver.frames(5)
	_check(back.dialogue.active, "a post-fight line plays on return")
	if won:
		_check(back.dialogue._speaker.text == "Torvin the Over-Pumped", "the win dialogue is from the NPC")
		_check(Session.flag(CorruptedNpcs.unlock_flag("beefcake")), "a win unlocks the Beefcake zone entrance")
		_check(Session.gold > gold_before, "a first win actually pays out gold")
	else:
		_check(not Session.flag(CorruptedNpcs.unlock_flag("beefcake")), "a loss does not unlock the zone entrance")
		_check(Session.gold == gold_before, "a loss pays out nothing")
	guard = 0
	while back.dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)
	await driver.frames(3)
	await _walk_to(back, "npc_beefcake")
	await driver.frames(3)
	_check(back.hud._prompt_label.text.contains("Talk"), "the corrupted NPC can always be talked to again, win or lose")

	_finish(_failures.is_empty(), "checked one full corrupted-NPC challenge (%s)" % ("won" if won else "lost"))


# ---- Helpers --------------------------------------------------------------------------------


func _wait_for_town() -> TownScene:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene is TownScene and not SceneManager.busy:
			await driver.frames(5)
			return scene as TownScene
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	return null


func _wait_for_battle() -> BattleScreen:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene is BattleScreen and not SceneManager.busy:
			await driver.frames(10)
			return scene as BattleScreen
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	return null


func _walk_to(town: TownScene, spot_id: String, must_walk: bool = false) -> void:
	var spot: TownScene.Spot = null
	for candidate: TownScene.Spot in town.spots:
		if candidate.id == spot_id:
			spot = candidate
			break
	if spot == null:
		_fail("no such spot: %s" % spot_id)
		return
	var elapsed: float = 0.0
	while elapsed < 20.0:
		var offset: Vector3 = spot.position - town.player.position
		offset.y = 0.0
		if offset.length() < spot.radius * 0.5:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	var reached: bool = Vector2(town.player.position.x - spot.position.x, town.player.position.z - spot.position.z).length() < spot.radius
	if must_walk:
		_check(reached, "the hero can walk to %s with the keyboard" % spot_id)
	if not reached:
		town.player.position = spot.position + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("corrupted_npc_smoke: ok    ", message)
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("corrupted_npc_smoke: FAIL  ", message)
	push_error("corrupted_npc_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("corrupted_npc_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
