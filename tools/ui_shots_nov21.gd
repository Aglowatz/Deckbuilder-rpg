extends SceneTree
## Fable Nov 21: screenshots of menu screens straight from their classes (no walk through the town needed).
##   Godot --path . --resolution 1600x900 -s res://tools/ui_shots_nov21.gd -- --out=res://docs/overnight_shots/nov20 [--only=deck,filter,...]
## Sections: deck (the sealed-card pop-up and the Path pop-up), filter (the Path toggles and the search box), wardrobe, packs.
## Windowed (it reads the viewport). Never saves a game.

var _out: String = "res://docs/overnight_shots/nov20"
var _only: PackedStringArray = []
var _session: Node


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg.begins_with("--only="):
			_only = arg.trim_prefix("--only=").split(",")
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _wants(section: String) -> bool:
	return _only.is_empty() or _only.has(section)


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


func _fresh_game() -> void:
	_session.set("save_enabled", false)
	_session.call("new_game")
	_session.call("ensure_game", 1)
	_session.call("set_flag", &"tip_deck")
	_session.set("gold", 3000)


func _card(id: String) -> Resource:
	return (_session.get("content") as Object).call("card", id) as Resource


func _own(ids: Array) -> void:
	var owned: Array = (_session.get("profile") as Object).get("owned_cards") as Array
	for id: Variant in ids:
		owned.append(_card(str(id)))


func _open(script_path: String) -> Control:
	var screen: Control = (load(script_path) as GDScript).new() as Control
	root.add_child(screen)
	return screen


func _run() -> void:
	_session = root.get_node("Session")
	if _wants("deck"):
		await _deck_popups()
	if _wants("filter"):
		await _deck_filter()
	if _wants("wardrobe"):
		await _wardrobe()
	if _wants("packs"):
		await _packs()
	quit()


## Part 3: the sealed three-Path card's pop-up, and the wrong-Path pop-up.
func _deck_popups() -> void:
	_fresh_game()
	_session.call("set_flag", &"tip_multi_path_locked")
	_own(["GRN-01", "N-01"])
	var station: Control = _open("res://ui/town/deckbuilder_screen.gd")
	await _wait(2.5)
	station.call("_add", _card("GRN-01"))
	await _wait(0.8)
	await _shot("p3_sealed_card_popup")
	var notice: Node = station.find_child("NoticeDialog", true, false)
	if notice != null:
		notice.queue_free()
	await _wait(0.3)
	station.call("_add", _card("N-01"))
	await _wait(0.8)
	await _shot("p3_wrong_path_popup")
	station.queue_free()
	await _wait(0.3)
	# the first visit with a sealed card: the station explains the seal
	_fresh_game()
	_own(["GRN-01"])
	station = _open("res://ui/town/deckbuilder_screen.gd")
	await _wait(2.5)
	await _shot("p3_seal_explained_once")
	station.queue_free()
	await _wait(0.3)


func _deck_filter() -> void:
	pass


func _wardrobe() -> void:
	pass


func _packs() -> void:
	pass
