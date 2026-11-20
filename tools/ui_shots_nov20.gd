extends SceneTree
## Fable Nov 20 (Part 9): screenshots of two screens straight from their classes (no walk through the town needed): Auntie Alembic's
## brew (two essences chosen, the brewed card, a second brew at once) and the equipment page with the longest descriptions at Large
## text.   Godot --path . --resolution 1600x900 -s res://tools/ui_shots_nov20.gd -- --out=res://docs/overnight_shots/nov19c
## Windowed (it reads the viewport). Never saves a game.

var _out: String = "res://docs/overnight_shots/nov19c"


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	image.save_jpg("%s/%s.jpg" % [_out, name], 0.88)
	print("ui_shots: %s" % name)


func _press(holder: Node, node_name: String) -> bool:
	var button: BaseButton = holder.find_child(node_name, true, false) as BaseButton
	if button == null or button.disabled:
		print("ui_shots: no button %s" % node_name)
		return false
	button.pressed.emit()
	return true


func _run() -> void:
	var session: Node = root.get_node("Session")
	var settings: Node = root.get_node("Settings")
	session.set("save_enabled", false)
	session.call("new_game")
	session.call("ensure_game", 1)
	session.set("gold", 3000)
	var profile: Object = session.get("profile") as Object
	profile.call("set_essence", 1, 18)
	profile.call("set_essence", 4, 18)
	# ---- Auntie Alembic ----
	var alchemist: Control = (load("res://ui/town/alchemist_screen.gd") as GDScript).new() as Control
	root.add_child(alchemist)
	await _wait(1.0)
	_press(alchemist, "EssenceRow1")
	_press(alchemist, "EssenceRow4")
	await _wait(0.6)
	await _shot("p9_alembic_1_two_chosen")
	_press(alchemist, "CraftButton")
	await _wait(3.2)
	await _shot("p9_alembic_2_brewed_card")
	var card: Control = alchemist.find_child("CraftedCard", true, false) as Control
	if card != null:
		# the hover magnifier, as the mouse would raise it
		card.mouse_entered.emit()
		await _wait(0.9)
		await _shot("p9_alembic_3_hover")
		card.mouse_exited.emit()
		await _wait(0.3)
	_press(alchemist, "CraftButton")
	await _wait(3.2)
	await _shot("p9_alembic_4_second_brew_at_once")
	alchemist.queue_free()
	await _wait(0.4)
	# ---- the equipment page ----
	session.call("set_flag", &"armory_unlocked")
	var content: Object = session.get("content") as Object
	for slot: int in range(5):
		profile.call("unlock_equipment_slot", slot)
	for id: String in ["thorned_loincloth", "big_brain_beret", "xray_goggles"]:
		var piece: Object = content.call("equipment_piece", id) as Object
		if piece != null:
			session.call("grant_equipment", piece)
	for text_level: int in [0, 1]:
		settings.call("set_text_master", text_level)
		for id: String in ["thorned_loincloth", "big_brain_beret"]:
			var piece: Object = content.call("equipment_piece", id) as Object
			if piece == null:
				continue
			var screen: Control = (load("res://ui/town/character_screen.gd") as GDScript).new() as Control
			root.add_child(screen)
			await _wait(0.8)
			screen.call("open_equipment_page", int(piece.get("slot")))
			await _wait(0.5)
			_press(screen, "Gear_%s" % id)
			await _wait(0.6)
			await _shot("p9_equipment_%s_%s_text" % [id, "large" if text_level == 1 else "normal"])
			screen.queue_free()
			await _wait(0.3)
	settings.call("set_text_master", 0)
	quit(0)
