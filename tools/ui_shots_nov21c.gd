extends SceneTree
## Fable Nov 21 castle (Part 8): screenshots of Auntie Alembic's shop straight from its class (no walk through the town needed).
##   Godot --path . --resolution 1600x900 -s res://tools/ui_shots_nov21c.gd -- --out=res://docs/overnight_shots/nov21c --prefix=p8_after
## Shots: <prefix>_open (nothing chosen), <prefix>_two_paths (two jars chosen, the pool shown), <prefix>_brewing (mid brew),
## <prefix>_brewed (the card revealed). Windowed (it reads the viewport). Never saves a game.

var _out: String = "res://docs/overnight_shots/nov21c"
var _prefix: String = "p8"
var _session: Node


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg.begins_with("--prefix="):
			_prefix = arg.trim_prefix("--prefix=")
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	image.save_jpg("%s/%s_%s.jpg" % [_out, _prefix, name], 0.88)
	print("ui_shots: %s_%s" % [_prefix, name])


func _press(holder: Node, node_name: String) -> void:
	var button: BaseButton = holder.find_child(node_name, true, false) as BaseButton
	if button == null or button.disabled:
		print("ui_shots: no button %s" % node_name)
		return
	button.pressed.emit()


func _run() -> void:
	_session = root.get_node("Session")
	_session.set("save_enabled", false)
	_session.call("new_game")
	_session.call("ensure_game", 1)
	_session.set("gold", 6400)
	var profile: Object = _session.get("profile") as Object
	profile.set("level", 18)
	# Beefcake 18 (full), Necrocrat 13, Gourmand 7, Refusemancer 2
	for pair: Array in [[1, 18], [4, 13], [2, 7], [3, 2]]:
		profile.call("set_essence", int(pair[0]), int(pair[1]))
	var screen: Control = (load("res://ui/town/alchemist_screen.gd") as GDScript).new() as Control
	root.add_child(screen)
	await _wait(7.0)  # the new game's feat toasts are gone by then
	await _shot("open")
	_press(screen, "EssenceRow1")
	_press(screen, "EssenceRow4")
	await _wait(1.0)
	await _shot("two_paths")
	_press(screen, "CraftButton")
	await _wait(0.9)
	await _shot("brewing")
	await _wait(2.2)
	await _shot("brewed")
	quit()
