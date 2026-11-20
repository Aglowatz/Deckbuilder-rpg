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
	_fresh_game()
	(_session.get("profile") as Object).set("zones_freed", 1)
	_own(["N-01", "N-02", "NB-04", "NB-03", "NB-02", "C-01", "C-02", "B-25", "B-34", "GB-13", "G-27"])
	var station: Control = _open("res://ui/town/deckbuilder_screen.gd")
	await _wait(3.0)
	var bar: Object = station.get("_filter") as Object
	bar.call("toggle_path", 1)
	bar.call("toggle_path", 4)
	await _wait(0.6)
	await _shot("p5_deck_filter_two_paths")
	bar.call("toggle_path", 2)
	await _wait(0.8)
	await _shot("p5_deck_filter_too_many_paths")
	var notice: Node = station.find_child("NoticeDialog", true, false)
	if notice != null:
		notice.queue_free()
	bar.call("toggle_path", -1)
	(bar.get("search_box") as LineEdit).text = "hustle"
	bar.call("set_search", "hustle")
	await _wait(0.8)
	await _shot("p5_deck_search_keyword")
	station.queue_free()
	await _wait(0.3)


func _wardrobe() -> void:
	_fresh_game()
	for id: String in ["hat_tricorn", "hat_wizard", "hat_chef", "cloak_red_cape", "cloak_patchwork"]:
		_session.call("grant_cosmetic", id)
	(_session.get("cosmetics") as Object).call("grant_dye", 0)
	var wardrobe: Control = _open("res://ui/town/wardrobe_screen.gd")
	await _wait(1.5)
	wardrobe.call("show_item", "hat|hat_tricorn")
	await _wait(0.4)
	await _shot("p5_wardrobe_item_hat")
	wardrobe.call("show_item", "cloak|cloak_patchwork")
	await _wait(0.4)
	await _shot("p5_wardrobe_item_cloak")
	wardrobe.call("_dye", 0)
	await _wait(0.4)
	await _shot("p5_wardrobe_plain_cloak_dyed")
	wardrobe.queue_free()
	await _wait(0.3)


func _packs() -> void:
	_fresh_game()
	_session.call("add_pack", "general_2", 2)
	var gilded: String = ""
	for pack: Variant in (load("res://core/data/pack_catalog.gd") as GDScript).call("all") as Array:
		if bool((pack as Object).get("guarantee_epic_or_legendary")):
			gilded = str((pack as Object).get("id"))
			break
	_session.call("add_pack", gilded, 2)
	var packs: Control = _open("res://ui/town/packs_screen.gd")
	await _wait(1.5)
	await _shot("p5_packs_open_all_counts_gilded")
	_press(packs, "OpenAll")
	await _wait(2.5)
	await _shot("p5_packs_open_all_result")
	packs.queue_free()
	await _wait(0.3)
	# 5.5: the reward box of a prize chest (the Head Chef's Ladle), with the hover info open
	var summary: Object = _session.call("queue_reward_box", "The prize chest", "The chest holds a piece of gear.", 0, 0, ["head_chef_ladle", "power_wraps"] as Array[String], "NEW GEAR!") as Object
	var popup: Control = (load("res://ui/screens/reward_popup.gd") as GDScript).call("make", summary) as Control
	root.add_child(popup)
	await _wait(1.6)
	for tile: Node in popup.find_children("Reward_*", "Control", true, false):
		if tile.has_meta(&"full_info"):
			(tile as Control).mouse_entered.emit()
			break
	await _wait(0.5)
	await _shot("p5_reward_box_waits_hover_info")
	popup.queue_free()
	await _wait(0.3)
