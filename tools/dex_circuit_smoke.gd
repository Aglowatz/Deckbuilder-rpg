class_name DexCircuitSmoke
extends Node
## Overnight Nov 9, Part 3: plays the whole Cardsharp's Circuit through the real game - Dex's talk spot in each of the four Path zones (his
## lines, the quest offer, the table opening), each table played with a perfect memory through the table's own flip calls (one deliberate
## miss on the first table, so the miss flourish and the moves meter run), then the final table, the turn-in and Dex's Matching Pair.
##   Godot --path . --resolution 1600x900 res://tools/dex_circuit_smoke.tscn      Exit code 0 = every step passed. Shots: docs/overnight_shots/nov9b/
const TAG: String = "dex_smoke"
const SHOT_DIR: String = "res://docs/overnight_shots/nov9b/"

var driver: UiDriver
var _steps: Array[Array] = []


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	Session.new_game()
	Session.ensure_game()
	await driver.frames(5)
	for zone_id: String in CardMatchCircuit.ZONES:
		await _table(zone_id, zone_id, zone_id == CardMatchCircuit.ZONES[0])
	_step(CardMatchCircuit.final_open(Session.flags), "all four zone tables beaten: the final table opens")
	await _table(CardMatchCircuit.ZONES[3], CardMatchCircuit.FINAL, false)
	var quest_done: bool = Session.quest_log.is_completed(CardMatchCircuit.QUEST_ID)
	if not quest_done:
		quest_done = Session.turn_in_quest(CardMatchCircuit.QUEST_ID) or Session.quest_log.is_completed(CardMatchCircuit.QUEST_ID)
	_step(quest_done, "the Circuit can be turned in after the final table")
	var prize: bool = Session.owned_equipment_ids().has(CardMatchCircuit.PRIZE_ID)
	_step(prize, "Dex's Matching Pair is in the armory")
	var piece: EquipmentData = Session.content.equipment_piece(CardMatchCircuit.PRIZE_ID)
	if piece != null:
		Session.profile.unlock_equipment_slot(piece.slot)
		_step(Session.equip_item(piece) and Session.profile.equipped_in(piece.slot) == piece, "the Matching Pair can be worn (boots)")
	_finish()


## Travels to `zone_id`, talks to Dex, reads his lines and plays the table he opens (expected: `table`).
func _table(zone_id: String, table: String, with_miss: bool) -> void:
	DevActions.travel_zone(zone_id)
	var zone: ZoneScene = await _wait_for(ZoneScene) as ZoneScene
	_step(zone != null and zone.def.id == zone_id, "%s: the zone loads" % zone_id)
	if zone == null:
		return
	await driver.seconds(1.5)
	await _read(zone)
	var spot: ZoneSpot = null
	for candidate: ZoneSpot in zone.spots:
		if candidate.id == "cardsharp":
			spot = candidate
	_step(spot != null and zone._npcs.has("cardsharp"), "%s: Dex stands at his table" % zone_id)
	if spot == null:
		return
	zone._interact(spot)
	await driver.seconds(0.4)
	await _read(zone)
	if table == CardMatchCircuit.ZONES[0]:
		_step(Session.quest_log.is_active(CardMatchCircuit.QUEST_ID), "Dex's first talk gives The Cardsharp's Circuit")
	var screen: CardMatchScreen = null
	for _i: int in range(30):
		for node: Node in zone.find_children("*", "CardMatchScreen", true, false):
			screen = node as CardMatchScreen
		if screen != null:
			break
		await driver.seconds(0.2)
	_step(screen != null and screen.table == table, "%s: Dex opens the %s table" % [zone_id, table])
	if screen == null:
		return
	await driver.seconds(0.6)
	_step(screen._status.text.contains("one move") and screen._status.text.contains(str(CardMatchCircuit.target_for(table))), "%s: the rules line says what a move is and Dex's score" % table)
	_step(screen.find_child("DexPortrait", true, false) != null and screen.find_child("Felt", true, false) != null, "%s: Dex sits at a felt table" % table)
	await _shot("dex_%s_1_table" % table)
	if with_miss:
		var a: int = 0
		var b: int = 1
		while screen.game.cards[b] == screen.game.cards[a]:
			b += 1
		await _flip(screen, a)
		await _flip(screen, b)
		await driver.seconds(0.2)
		_step(screen._status.text.begins_with("Not a pair") and screen._dex_line.text != "", "%s: a miss says so, and Dex has a line for it" % table)
	# a perfect memory: every pair, left to right
	var done: Dictionary = {}
	for i: int in range(screen.game.slot_count()):
		if done.has(i) or screen.game.matched[i]:
			continue
		for j: int in range(i + 1, screen.game.slot_count()):
			if screen.game.cards[j] == screen.game.cards[i]:
				done[i] = true
				done[j] = true
				await _flip(screen, i)
				await _flip(screen, j)
				break
	await driver.seconds(0.8)
	var target: int = CardMatchCircuit.target_for(table)
	_step(screen.game.is_won() and screen.game.moves <= target, "%s: all eight pairs in %d moves (Dex: %d)" % [table, screen.game.moves, target])
	_step(Session.flag(StringName(CardMatchCircuit.flag_name(table))), "%s: beating Dex sets the table's flag" % table)
	_step(screen.find_child("Stars", true, false) != null, "%s: the result's stars pop in" % table)
	await _shot("dex_%s_2_won" % table)
	screen.request_close()
	await driver.seconds(0.6)


func _flip(screen: CardMatchScreen, index: int) -> void:
	for _i: int in range(40):
		if not screen._busy:
			break
		await driver.seconds(0.1)
	screen._flip(index)
	await driver.seconds(0.15)
	for _i: int in range(40):
		if not screen._busy:
			break
		await driver.seconds(0.1)


func _read(zone: ZoneScene) -> void:
	await driver.frames(5)
	var guard: int = 0
	while zone.dialogue != null and zone.dialogue.active and guard < 60:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)
	for node: Node in get_tree().root.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and button.text.strip_edges() == "Got it":
			await driver.click(driver.button_center(button))


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _shot(shot_name: String) -> void:
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var texture: Texture2D = get_tree().root.get_texture()
	if texture != null:
		texture.get_image().save_jpg(ProjectSettings.globalize_path("%s%s.jpg" % [SHOT_DIR, shot_name]))


func _step(ok: bool, message: String) -> void:
	_steps.append([ok, message])
	print("%s: %s  %s" % [TAG, "PASS" if ok else "FAIL", message])


func _finish() -> void:
	var failed: int = 0
	for step: Array in _steps:
		if not bool(step[0]):
			failed += 1
	print("%s: ---- %d steps, %d passed, %d failed ----" % [TAG, _steps.size(), _steps.size() - failed, failed])
	get_tree().quit(0 if failed == 0 else 1)
