extends Node
## Regression test for the "NPC/vendor interaction does nothing" bug (A2): walks the hero to
## each NPC/vendor/station with injected input and checks the correct UI opens, using all three
## supported interact inputs (E, Space, and left-clicking the NPC in range) across the different
## spots, plus checking the "[E] ..." prompt is shown while in range.
## Run windowed (not headless - injected mouse input needs a real viewport):
##   Godot --path . res://tools/town_interact_smoke.tscn
## Exit code 0 = every spot opened the right UI with every input method tried; 1 = a check failed.

const STALL_LIMIT: int = 400

var driver: UiDriver
var scene: TownScene
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	Session.new_game()
	# Town is only reached after the starting area + tutorial dungeon + deck choice; bypass all
	# of that here (covered by tools/e2e_demo.gd) so this test stays focused on NPC/vendor/
	# station interaction.
	Session.ensure_game()
	var packed: PackedScene = load("res://scenes/town.tscn") as PackedScene
	scene = packed.instantiate() as TownScene
	get_tree().root.add_child(scene)
	driver = UiDriver.new(get_tree())
	await driver.frames(20)

	await _check_prompt_and_talk("elder", "Elder Maren", KEY_E)
	await _check_prompt_and_talk("guard", "Gatekeeper Brannoch", KEY_SPACE)
	await _check_vendor_by_click()
	await _check_deck_station()

	_finish(_failures.is_empty(), "checked elder (E), guard (Space), vendor (click), deck station (E)")


# ---- Helpers ----------------------------------------------------------------------------


func _spot(id: String) -> TownScene.Spot:
	for spot: TownScene.Spot in scene.spots:
		if spot.id == id:
			return spot
	_fail("no such spot: %s" % id)
	return null


## Walks to `id` with injected WASD, the same crude "no pathfinding" mover the existing e2e
## driver uses. `must_walk` strictly requires arriving on foot (used once, to prove the keyboard
## moves the hero at all); other spots may be behind a mountain this simple mover can't route
## around in time, so - exactly like tools/e2e_demo.gd's `_walk_to` - it silently teleports the
## last short distance instead of failing: this test is about interaction, not pathfinding.
func _walk_to(id: String, must_walk: bool = false) -> TownScene.Spot:
	var spot: TownScene.Spot = _spot(id)
	var elapsed: float = 0.0
	while elapsed < 9.0:
		var offset: Vector3 = spot.position - scene.player.position
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
	var reached: bool = Vector2(scene.player.position.x - spot.position.x, scene.player.position.z - spot.position.z).length() < spot.radius
	if must_walk:
		_check(reached, "the hero can walk to the %s spot with the keyboard" % id)
	if not reached:
		scene.player.position = spot.position + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)
	return spot


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


## Regression check for a real bug: DialogueBox's panel could be active/visible=true while its
## rect sat far outside the 1920x1080 canvas (a stale anchor preset fighting a manual position),
## so it never actually appeared on screen even though the state was otherwise correct.
func _check_dialogue_on_screen(context: String) -> void:
	var rect: Rect2 = scene.dialogue._panel.get_global_rect()
	var canvas: Rect2 = Rect2(0, 0, 1920, 1080)
	_check(canvas.intersects(rect), "%s: the dialogue panel is actually on screen (got %s)" % [context, rect])


func _dismiss_dialogue() -> void:
	var guard: int = 0
	while scene.dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)
	_check(not scene.dialogue.active, "the dialogue box closes after being advanced through")


func _check_prompt_and_talk(id: String, speaker_name: String, key: Key) -> void:
	await _walk_to(id, id == "elder")
	await driver.frames(3)
	_check(scene.hud._prompt_panel.visible and scene.hud._prompt_label.text.begins_with("[E]"), "an [E] prompt shows near %s" % id)
	_check(scene.hud._prompt_label.text.contains("Talk"), "the prompt for %s reads Talk" % id)
	await driver.tap_key(key)
	await driver.seconds(0.3)
	_check(scene.dialogue.active, "interacting with %s (key %d) opens dialogue" % [id, key])
	_check(scene.dialogue._speaker.text == speaker_name, "the dialogue speaker for %s is %s" % [id, speaker_name])
	_check_dialogue_on_screen(id)
	await _dismiss_dialogue()


func _check_vendor_by_click() -> void:
	var spot: TownScene.Spot = await _walk_to("vendor")
	await driver.frames(3)
	var pos: Vector2 = scene._screen_pos_of(spot)
	await driver.click(pos)
	await driver.seconds(0.3)
	_check(scene.dialogue.active, "left-clicking the vendor in range opens dialogue")
	_check(scene.dialogue._speaker.text == "Sable the Trader", "the vendor dialogue is from Sable the Trader")
	_check_dialogue_on_screen("vendor")
	await _dismiss_dialogue()
	await driver.seconds(0.3)
	_check(scene._overlay is VendorScreen, "the vendor dialogue leads into the Vendor screen")
	if scene._overlay is VendorScreen:
		await driver.click_button("Leave")
		await driver.seconds(0.3)
	_check(scene._overlay == null, "closing the Vendor screen returns to the town")


func _check_deck_station() -> void:
	await _walk_to("deck")
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.3)
	_check(scene._overlay is DeckbuilderScreen, "interacting with the Deck Station opens the deckbuilder")
	if scene._overlay is DeckbuilderScreen:
		await driver.click_button("Close")
		await driver.seconds(0.3)
	_check(scene._overlay == null, "closing the Deck Station returns to the town")


func _check(condition: bool, message: String) -> void:
	if condition:
		print("town_interact_smoke: ok    ", message)
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("town_interact_smoke: FAIL  ", message)
	push_error("town_interact_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("town_interact_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
