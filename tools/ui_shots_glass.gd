extends SceneTree
## Fable Nov 20 day (Part 2): the stained-glass pieces a walk through the menus does not reach, straight from their classes - a hover
## tooltip, the reward box, a one-button notice, the buy-anyway question, the Collection Book.
##   Godot --path . --resolution 1920x1080 -s res://tools/ui_shots_glass.gd -- --out=res://docs/overnight_shots/nov20b/ui_after [--pad=true]
## --pad=true moves the controller focus onto a button first (the lit focus state). Windowed (it reads the viewport). Never saves a game.

var _out: String = "res://docs/overnight_shots/nov20b/ui_after"
var _pad: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		if arg == "--pad=true":
			_pad = true
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _shot(name: String) -> void:
	await process_frame
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	image.save_jpg("%s/%s.jpg" % [_out, name], 0.88)
	print("ui_shots_glass: %s" % name)


func _backdrop() -> Control:
	# a stand-in for the game behind a pop-up: a painted scene
	var holder: Control = Control.new()
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var picture: TextureRect = TextureRect.new()
	picture.texture = load("res://assets/art/keyart/STORY-REVEAL-KITCHEN.webp") as Texture2D
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(picture)
	root.add_child(holder)
	return holder


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out))
	var session: Node = root.get_node("Session")
	session.set("save_enabled", false)
	session.call("new_game")
	session.call("ensure_game", 1)
	session.set("gold", 900)
	var back: Control = _backdrop()
	await _wait(0.5)
	# ---- a hover tooltip ----
	var chip: Button = Button.new()
	chip.text = "Sucker Punch"
	chip.position = Vector2(520, 420)
	chip.size = Vector2(220, 50)
	back.add_child(chip)
	var tip: Control = (load("res://ui/widgets/hover_tip.gd") as GDScript).call("_show", chip, "Sucker Punch", "Deals combat damage before units without it. If that destroys the other unit, this one takes no damage back.", Color("f4ce78"), "ICON-KW-SUCKERPUNCH") as Control
	await _wait(0.4)
	await _shot("ui_20_tooltip")
	if tip != null:
		tip.queue_free()
	chip.queue_free()
	# ---- a one-button notice (the sealed-card pop-up's kind) and a question with a safe answer ----
	var confirm: GDScript = load("res://ui/widgets/confirm_dialog.gd") as GDScript
	var notice: Node = confirm.call("notice", back, "Reunion of the Paths", "A card of three or four Paths stays sealed until Primm is defeated. It waits in your collection.") as Node
	await _wait(0.6)
	await _shot("ui_21_notice_popup")
	notice.queue_free()
	var ask: Node = confirm.call("ask", back, "Buy it anyway?", "You already own as many copies as a deck may hold. A further copy turns into essence and gold.", "Buy", "Keep my gold") as Node
	await _wait(0.6)
	if _pad:
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = JOY_BUTTON_DPAD_RIGHT
		event.pressed = true
		Input.parse_input_event(event)
		await _wait(0.3)
	await _shot("ui_22_question_popup")
	ask.queue_free()
	# ---- the reward box ----
	var names: Array[String] = ["Field Bandage", "general_1"]
	var summary: Object = session.call("queue_reward_box", "The Stew Cook's Chest", "Hidden behind the orange plateau.", 120, 60, names, "REWARD") as Object
	var popup: Control = (load("res://ui/screens/reward_popup.gd") as GDScript).call("make", summary) as Control
	back.add_child(popup)
	await _wait(2.6)
	await _shot("ui_23_reward_box")
	popup.queue_free()
	(session.get("pending_popups") as Array).clear()
	# ---- the Collection Book ----
	var codex: Control = (load("res://ui/town/codex_screen.gd") as GDScript).new() as Control
	root.add_child(codex)
	await _wait(1.5)
	await _shot("ui_24_collection_book")
	codex.queue_free()
	await _wait(0.2)
	quit(0)
