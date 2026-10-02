class_name ZoneEntrancesSmoke
extends Node
## New brief, Part C: a human-input e2e regression test for the 5 map-edge zone entrances -
## walks to each one with injected input and checks that a locked element entrance shows its
## barrier (Sealed prompt + toast, no scene change), the always-open Final entrance actually
## changes the scene to ZonePlaceholderScene, coming back returns the player to that same
## entrance (not the default spawn), and that defeating a corrupted NPC (simulated here by
## setting its unlock flag directly, since Part E owns setting it for real) actually opens that
## entrance on the next town load.
## Run through the real scene tree, not a manually instantiated scene, because this test needs
## the real town <-> zone SceneManager transition:
##   Godot --path . res://tools/zone_entrances_launcher.tscn
## Exit code 0 = every check passed; 1 = a check failed.

const LOCKED_IDS: Array[String] = ["beefcake", "tide", "root", "necrocrat"]
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
	await _check_all_locked_except_final(town)
	await _check_final_entrance_round_trip(town)
	await _check_unlocking_root()

	_finish(_failures.is_empty(), "checked lock/unlock and the scene change for all 5 entrances")


# ---- Phases -------------------------------------------------------------------------------


func _check_all_locked_except_final(town: TownScene) -> void:
	for zone_id: String in LOCKED_IDS:
		await _walk_to(town, "portal_%s" % zone_id, zone_id == LOCKED_IDS[0])
		await driver.frames(3)
		_check(town.hud._prompt_label.text.contains("Sealed"), "%s entrance shows a Sealed prompt while locked" % zone_id)
		await driver.tap_key(KEY_E)
		await driver.seconds(0.3)
		_check(get_tree().current_scene == town, "interacting with a locked %s entrance does not change the scene" % zone_id)
		_check(town.hud._toast.text.contains("sealed"), "a locked %s entrance shows a barrier toast" % zone_id)
	await _walk_to(town, "portal_final")
	await driver.frames(3)
	_check(town.hud._prompt_label.text.contains("Enter") and not town.hud._prompt_label.text.contains("Sealed"), "the Final entrance is open from the start")


func _check_final_entrance_round_trip(town: TownScene) -> void:
	await driver.tap_key(KEY_E)
	var zone: ZonePlaceholderScene = await _wait_for_zone()
	_check(zone != null, "entering the Final entrance actually changes the scene")
	if zone == null:
		return
	_check(zone.info.id == "final", "the zone placeholder shows the Final zone's info")
	var portal_pos: Vector3 = zone.area.anchors.get("portal", Vector3.ZERO) as Vector3
	zone.player.position = portal_pos
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	var back: TownScene = await _wait_for_town()
	_check(back != null, "returning from the Final zone comes back to town")
	if back == null:
		return
	var final_anchor: Vector3 = back.town.anchors.get("portal_final", Vector3.ZERO) as Vector3
	var distance: float = Vector2(back.player.position.x - final_anchor.x, back.player.position.z - final_anchor.z).length()
	_check(distance < 2.0, "coming back from a zone returns the player to that same entrance (got %.2f away)" % distance)


func _check_unlocking_root() -> void:
	# Simulate Part E's "defeat the corrupted NPC" outcome directly, then reload town like a real
	# return from battle would - the barrier is a load-time snapshot (see town_scene.gd
	# _build_portal_barriers), so this is the real path an unlock actually takes.
	Session.set_flag(&"root_zone_unlocked")
	get_tree().change_scene_to_file("res://scenes/town.tscn")
	var town: TownScene = await _wait_for_town()
	await _walk_to(town, "portal_root")
	await driver.frames(3)
	_check(town.hud._prompt_label.text.contains("Enter") and not town.hud._prompt_label.text.contains("Sealed"), "the Root entrance opens once its unlock flag is set")
	await _walk_to(town, "portal_beefcake")
	await driver.frames(3)
	_check(town.hud._prompt_label.text.contains("Sealed"), "other entrances stay locked after unlocking just one")
	await _walk_to(town, "portal_root")
	await driver.frames(3)
	await driver.tap_key(KEY_E)
	var zone: ZonePlaceholderScene = await _wait_for_zone()
	_check(zone != null and zone.info.id == "root", "the now-unlocked Root entrance actually changes the scene to the Root zone")


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


func _wait_for_zone() -> ZonePlaceholderScene:
	var elapsed: float = 0.0
	while elapsed < STALL_LIMIT:
		var scene: Node = get_tree().current_scene
		if scene is ZonePlaceholderScene and not SceneManager.busy:
			await driver.frames(5)
			return scene as ZonePlaceholderScene
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	return null


## The same crude "no pathfinding, teleport the last bit if stuck" mover the existing town smoke
## test uses (tools/town_interact_smoke.gd) - correctness here is about lock/unlock and scene
## transitions, not pathfinding.
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
		_check(reached, "the hero can actually walk to %s through the expanded town" % spot_id)
	if not reached:
		town.player.position = spot.position + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held_keys.get(key, false)) != down:
		_held_keys[key] = down
		await driver.key(key, down)


func _check(condition: bool, message: String) -> void:
	if condition:
		print("zone_entrances_smoke: ok    ", message)
	else:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	print("zone_entrances_smoke: FAIL  ", message)
	push_error("zone_entrances_smoke: " + message)


func _finish(ok: bool, reason: String) -> void:
	print("zone_entrances_smoke: %s - %s" % ["OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)
