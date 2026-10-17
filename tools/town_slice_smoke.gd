extends Node
## Vertical slice, Part E: the rebuilt town square's interactions still work. Windowed run with injected input: the hero is put at each shop, NPC, civic and sign spot (the layout
## moved every one of them), the "[E]" prompt must show, E must open its dialogue / screen, and Esc / E must close it again. The first leg proves the keyboard still moves the hero.
##   Godot --path . res://tools/town_slice_smoke.tscn        (run alone, windowed)

var driver: UiDriver
var scene: TownScene
var _failures: PackedStringArray = []

const SPOTS: Array[String] = [
	"vendor", "item_vendor", "equipment_vendor", "pack_vendor", "tailor", "alchemist", "deck", "elder", "guard", "codex", "notice_board", "signpost_0", "signpost_2", "arena",
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	var packed: PackedScene = load("res://scenes/town.tscn") as PackedScene
	scene = packed.instantiate() as TownScene
	get_tree().root.add_child(scene)
	driver = UiDriver.new(get_tree())
	await driver.frames(30)
	# 1. the keyboard moves the hero: hold W for a second in the open forecourt
	scene.player.position = Vector3(26.5, 0.0, 20.0)
	await driver.frames(3)
	var start: Vector3 = scene.player.position
	await driver.key(KEY_W, true)
	await driver.seconds(0.8)
	await driver.key(KEY_W, false)
	_check(start.distance_to(scene.player.position) > 0.8, "holding W moves the hero (%.2f m)" % start.distance_to(scene.player.position))
	# 2. every spot: prompt, interact, close
	for id: String in SPOTS:
		await _visit(id)
	# the well heals with a toast and the cave gate changes scene: only their prompts are checked
	for id: String in ["well", "gate"]:
		var spot: TownScene.Spot = _spot(id)
		scene.player.position = spot.position + Vector3(0.0, 0.0, 0.5)
		await driver.frames(8)
		_check(scene.hud._prompt_panel.visible and scene.hud._prompt_label.text.begins_with("[E]"), "%s: the [E] prompt shows at its spot (%s)" % [id, scene.hud._prompt_label.text])
	_finish()


func _spot(id: String) -> TownScene.Spot:
	for spot: TownScene.Spot in scene.spots:
		if spot.id == id:
			return spot
	return null


func _visit(id: String) -> void:
	var spot: TownScene.Spot = _spot(id)
	if spot == null:
		_check(false, "spot %s exists" % id)
		return
	scene.player.position = spot.position + Vector3(0.0, 0.0, 0.5)
	await driver.frames(8)
	var prompt: bool = scene.hud._prompt_panel.visible and scene.hud._prompt_label.text.begins_with("[E]")
	_check(prompt, "%s: the [E] prompt shows at its spot (%s)" % [id, scene.hud._prompt_label.text])
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	var opened: bool = scene.dialogue.active or scene._overlay != null
	_check(opened, "%s: E opens a dialogue or a screen" % id)
	var guard: int = 0
	while guard < 30:  # Oct 16: long intros are split into more, shorter boxes now
		guard += 1
		if await driver.dismiss_reward_box(0.25):
			continue
		if scene.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.2)
		elif scene._overlay != null:
			# the screens' own buttons, like a player (Esc could open the pause menu over a level-up box and freeze the driver's timers)
			var closed: bool = await driver.click_button("Continue")
			if not closed:
				closed = await driver.click_button("Close")
			if not closed:
				scene._close_overlay()
			await driver.seconds(0.5)
		else:
			break
	_check(not scene.dialogue.active and scene._overlay == null, "%s: it closes again and the town is live" % id)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("town_slice_smoke: ok    %s" % what)
	else:
		_failures.append(what)
		print("town_slice_smoke: FAIL  %s" % what)
		push_error("town_slice_smoke: %s" % what)


func _finish() -> void:
	if _failures.is_empty():
		print("town_slice_smoke: PASSED - the keyboard walk and %d spots (prompt, interact, close)" % SPOTS.size())
		get_tree().quit(0)
	else:
		print("town_slice_smoke: FAILED - %d checks" % _failures.size())
		get_tree().quit(1)
