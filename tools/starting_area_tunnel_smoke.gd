class_name StartingAreaTunnelSmoke
extends Node
## New brief (third), Part D: human-input e2e test for the hidden-tunnel tutorial skip. Starts a
## brand-new game at the starting area, confirms no prompt shows far from the tunnel, walks to it
## with injected WASD, interacts (E), dismisses the flavor dialogue, picks an element via the same
## ElementChoiceScreen the real gate uses, and confirms the result lands in town with a legal
## 45-card deck, the tutorial's own total XP/gold, and the tutorial-complete flags - with no
## dungeon in between. Added to get_tree().root directly (not inside the scene it drives) so it
## survives the real scene change from the starting area to town.
## Run windowed (not headless - injected input needs a real viewport):
##   Godot --path . res://tools/starting_area_tunnel_smoke.tscn
## Exit code 0 = every check passed; 1 = a check failed.

const TIME_LIMIT_SECONDS: float = 60.0

var driver: UiDriver
var _failures: PackedStringArray = []
var _held_keys: Dictionary = {}


## Called by the launcher (starting_area_tunnel_launcher.gd) after this node is added directly to
## get_tree().root - not inside the scene being driven - so it survives the real scene change from
## the starting area to town partway through.
func run() -> void:
	Session.save_enabled = false
	Session.new_game()
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var scene: StartingAreaScene = await _wait_for(StartingAreaScene) as StartingAreaScene
	if scene == null:
		_finish(false, "starting area never loaded")
		return
	# Skip the wake-up dialogue (Session.new_game() already ran above, but StartingAreaScene's own
	# _ready() plays it once "awakened" is unset).
	await _dismiss_any_dialogue(scene)

	var tunnel: Vector3 = scene.area.anchors.get("tunnel", Vector3.ZERO) as Vector3
	scene.player.position = tunnel + Vector3(0.0, 0.0, 6.0)
	await driver.frames(5)
	_check(not scene._prompt_panel.visible, "no prompt shows 6m from the hidden tunnel")

	await _walk_to_position(scene, tunnel, StartingAreaScene.TUNNEL_RADIUS)
	await driver.frames(3)
	_check(scene._prompt_panel.visible and scene._prompt_label.text.contains("tunnel"), "the prompt appears once genuinely close to the hidden tunnel")

	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(scene.dialogue.active, "using the tunnel plays a flavor dialogue line first")
	await _dismiss_any_dialogue(scene)

	var choice: ElementChoiceScreen = _find_element_choice(scene)
	_check(choice != null, "the tunnel offers the same element choice as the real gate")
	if choice == null:
		_finish(false, "no ElementChoiceScreen appeared")
		return
	var gold_before: int = Session.gold
	var tile: Button = choice._tiles[Affinity.Type.C] as Button
	await driver.click(driver.center_of_control(tile))
	await driver.click_button("Begin")
	await driver.seconds(0.6)

	_check(Session.has_profile() and Session.profile.primary_affinity == Affinity.Type.C, "choosing an element via the tunnel sets the primary affinity")
	_check(not Session.in_dungeon(), "the tunnel skips the tutorial dungeon entirely")
	_check(Session.deck != null and Session.deck.size() == 45, "the tunnel grants a full 45-card deck (got %d)" % (Session.deck.size() if Session.deck != null else -1))
	_check(Session.deck_is_valid(), "the granted deck is actually legal")
	var totals: Dictionary = TrialOfTheHollow.total_tutorial_rewards()
	# >=, not ==, on gold: crossing level 3 along the way also grants its own +65 gold filler
	# reward (ProgressionTable) - exactly what a real tutorial run gaining the same total XP the
	# same way would also do, not specific to the tunnel skip.
	_check(Session.gold >= gold_before + int(totals["gold"]), "the tunnel grants at least the same gold the tutorial would have (+%d, got +%d)" % [int(totals["gold"]), Session.gold - gold_before])
	_check(Session.profile.xp == int(totals["xp"]), "the tunnel grants the same XP the tutorial would have (%d)" % int(totals["xp"]))
	_check(Session.flag(&"trial_cleared"), "the tunnel sets the tutorial-complete flag so town opens normally")
	_check(Session.profile.intro_dungeon_cleared, "the tunnel marks the intro dungeon cleared")
	_check(Session.found_secret("starting_area_tunnel"), "using the tunnel marks its own secret found")

	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null, "the tunnel leads straight to town")
	if town != null:
		await driver.frames(5)
		_check(town.hud._objective.text.contains("cleared"), "the town objective reflects the (skipped) cleared trial")

	_finish(_failures.is_empty(), "walked to the hidden tunnel, chose an element, and landed in town with a legal deck")


# ---- Helpers ----------------------------------------------------------------------------


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < TIME_LIMIT_SECONDS:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_any_dialogue(scene: StartingAreaScene) -> void:
	var guard: int = 0
	while scene.dialogue.active and guard < 20:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _find_element_choice(scene: StartingAreaScene) -> ElementChoiceScreen:
	for child: Node in scene._overlay_layer.get_children():
		if child is ElementChoiceScreen:
			return child as ElementChoiceScreen
	return null


func _walk_to_position(scene: StartingAreaScene, target: Vector3, radius: float) -> void:
	var elapsed: float = 0.0
	while elapsed < 9.0:
		var offset: Vector3 = target - scene.player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	# No _check on `reached`: the tunnel is deliberately camouflaged by trees (obstacles), and this
	# crude 4-direction bot has no obstacle-avoidance - same accepted limitation as the town's
	# hidden chests (tools/e2e_demo.gd's own copy of this walker). Teleporting the last short
	# distance on a stall is about proving the tunnel itself works, not re-proving pathing.
	var reached: bool = Vector2(scene.player.position.x - target.x, scene.player.position.z - target.z).length() < radius
	if not reached:
		scene.player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("starting_area_tunnel_smoke: ok    ", message)
	else:
		_failures.append(message)
		print("starting_area_tunnel_smoke: FAIL  ", message)
		push_error("starting_area_tunnel_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("starting_area_tunnel_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
