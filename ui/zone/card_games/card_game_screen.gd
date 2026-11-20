class_name CardGameScreen
extends OverlayScreen
## Fable Nov 16b (Part 2): what the four zone card minigames share ("Reps", "Order Up", "Sort It Out", "File in Order"). Each is played
## with the game's real cards on a full-screen table: the zone's painted minigame room where there is one (MG-BG-*), else the zone's
## loading painting, blurred, behind a wood and brass frame like Dex's table. Every game opens on a one-screen "How to play" (three
## short lines and a small moving example; the "?" in the corner brings it back) and ends on a win or lose panel with the reward.
## Mouse, keyboard and controller: every control is a button the D-pad reaches; each game adds its own quick keys.

signal game_finished(stars: int, reward: Dictionary)

const WOOD: Color = Color(0.17, 0.11, 0.08, 0.93)
const BRASS: Color = Color("c9a45a")
const PAPER: Color = Color("f1e6cc")

## The zone whose cards are dealt ("" = the zone the player is in).
var zone_id: String = ""
## A fixed deal for tests and shots (0 = a new deal every time).
var seed_value: int = 0
## Tests set false: no waits, no tweens between the steps of a turn.
var animate: bool = true
## Shots: open straight on the table (no "How to play" first).
var skip_how: bool = false

## "how", "playing" or "done".
var state: String = "how"
var _story: ZoneStoryText
var _status: Label
var _stage: PanelContainer
var _table: VBoxContainer
var _how: Control
var _result: Control
var _host_line: Label
var _deals: int = 0


# ---- what a game says about itself ------------------------------------------------------------

## The game's own name ("Reps").
func game_name() -> String:
	return ""


## The painted room behind the table (a UI-art id), or "".
func room_art() -> String:
	return ""


## The zone painting blurred behind the frame when there is no room (a key-art id).
func backdrop_art() -> String:
	return ""


## Three short lines.
func how_lines() -> Array[String]:
	return []


## The small moving example on the "How to play" screen, built into `box` (about 620 x 230).
func _build_example(_box: Control) -> void:
	pass


## The table, built into `box` once.
func _build_table(_box: VBoxContainer) -> void:
	pass


## Deals a new game onto the table.
func _new_game() -> void:
	pass


## Pays the result (the replaced game's own reward rule) and returns {gold, xp, item, first_win, stars, ...}.
func _pay(_stars: int) -> Dictionary:
	return {"gold": 0, "xp": 0, "item": "", "first_win": false, "stars": 0}


## The host's portrait id ("" = no host at the table).
func host_portrait() -> String:
	return ""


func host_name() -> String:
	return ""


# ---- building ---------------------------------------------------------------------------------

func _init() -> void:
	close_text = "Leave (Esc)"


func zone() -> String:
	if zone_id.is_empty():
		zone_id = ZoneDefs.current().id if ZoneDefs.current() != null else "beefcake"
	return zone_id


func music_cue() -> String:
	return MusicDirector.minigame(zone())


## A generator for one deal: seeded when `seed_value` is set (each new deal of the same screen then differs but repeats run to run).
func deal_rng() -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if seed_value != 0:
		rng.seed = seed_value + _deals * 7919
	else:
		rng.randomize()
	_deals += 1
	return rng


func _build() -> void:
	_story = ZoneStoryText.for_zone(zone())
	_add_backdrop()
	var column: VBoxContainer = UIKit.vbox(10)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(column)
	var help: FancyButton = FancyButton.make("?", &"", Vector2(58, 54))
	help.name = "HowToPlayButton"
	help.tooltip_text = "How to play"
	help.add_theme_font_size_override("font_size", 30)
	help.pressed.connect(show_how)
	header_extra.add_child(help)
	var seat: HBoxContainer = UIKit.hbox(18)
	seat.size_flags_vertical = Control.SIZE_EXPAND_FILL
	seat.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(seat)
	if not host_portrait().is_empty() and Portraits.texture_for(host_portrait()) != null:
		seat.add_child(_build_host())
	_stage = PanelContainer.new()
	_stage.name = "Table"
	_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var frame: StyleBoxFlat = UIStyle.box(WOOD if room_art().is_empty() or not UiArt.has(room_art()) else Color(0.06, 0.03, 0.09, 0.56), BRASS, 4, 18, 8)
	for side: String in ["left", "right", "top", "bottom"]:
		frame.set("content_margin_" + side, 18.0)
	_stage.add_theme_stylebox_override("panel", frame)
	seat.add_child(_stage)
	_table = UIKit.vbox(10)
	_table.alignment = BoxContainer.ALIGNMENT_CENTER
	_stage.add_child(_table)
	_status = UIKit.label("", &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_status.name = "Status"
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(600, 34)
	_table.add_child(_status)
	_build_table(_table)
	_new_game()
	if skip_how:
		state = "playing"
	else:
		show_how()


func _add_backdrop() -> void:
	var back: Control = null
	if not room_art().is_empty() and UiArt.has(room_art()):
		back = UiSkin.screen_background(room_art(), 0.3)
	elif not backdrop_art().is_empty() and KeyArt.has(backdrop_art()):
		var picture: TextureRect = TextureRect.new()
		picture.texture = KeyArt.texture(backdrop_art())
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var blur: ShaderMaterial = ShaderMaterial.new()
		blur.shader = load("res://ui/shaders/soft_blur.gdshader") as Shader
		picture.material = blur
		UIKit.full_rect(picture)
		back = picture
	if back == null:
		return
	back.name = "Backdrop"
	add_child(back)
	for child: Node in get_children():
		if child is MarginContainer:
			move_child(back, child.get_index())
			break


func _build_host() -> Control:
	var box: VBoxContainer = UIKit.vbox(8)
	box.name = "Host"
	box.custom_minimum_size = Vector2(250, 0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var portrait: TextureRect = TextureRect.new()
	portrait.name = "HostPortrait"
	portrait.texture = Portraits.texture_for(host_portrait())
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(250, 320)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(portrait)
	var plate: Label = UIKit.label(host_name(), &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(plate)
	_host_line = UIKit.label("", &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_host_line.name = "HostLine"
	_host_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_host_line.custom_minimum_size = Vector2(250, 150)
	_host_line.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.08, 0.72), Color(0, 0, 0, 0), 0, 10))
	box.add_child(_host_line)
	return box


## What the host says (or, with no host, nothing).
func host_say(text: String) -> void:
	if _host_line == null or text.is_empty():
		return
	_host_line.text = text
	if animate:
		_host_line.modulate.a = 0.3
		create_tween().tween_property(_host_line, "modulate:a", 1.0, 0.18)


## One of the story file's lines for `key`, by `index` (wrapping); "" when the zone has none.
func story_line(key: String, index: int = 0) -> String:
	if _story == null:
		return ""
	var lines: Array[String] = _story.get_lines(key)
	# Overnight Nov 17 (seen in the card games smoke's shots): a missing key comes back as "[missing text: ...]", which is not empty, so
	# the callers' own fallback lines never showed and the host said "[missing text: quiz.start]" in every zone
	if lines.is_empty() or lines[0].begins_with("[missing text"):
		return ""
	return lines[index % lines.size()]


func set_status(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	if _status != null:
		_status.text = text
		_status.add_theme_color_override("font_color", color)


# ---- cards ------------------------------------------------------------------------------------

## A real card, face up, at `card_scale` (art, name, cost, power / toughness, Path icon).
func face(card: CardData, card_scale: float) -> Control:
	var view: Control = CardView.wrapped(card, card_scale)
	view.name = "Face"
	CardHoverZoom.watch(view)  # Fable Nov 21 (Part 5.6): every face-up card of a card game grows under the pointer (never while dragging)
	return view


## A face-down card: the zone's Path card back.
func back(card_scale: float) -> Control:
	var path_card: CardData = Session.content.infrastructure.get(int(ZoneEffects.path_of(zone()))) as CardData
	var view: Control = CardView.wrapped(path_card, card_scale, CardView.Mode.BACK)
	view.name = "Back"
	return view


## Turns `holder` over: it closes sideways, `swap` changes what it shows, it opens again.
func flip(holder: Control, swap: Callable) -> void:
	Audio.sfx(&"pack_flip", -6.0, 0.1)
	if not animate or not is_inside_tree():
		swap.call()
		return
	holder.pivot_offset = holder.size * 0.5
	var turn: Tween = create_tween()
	turn.tween_property(holder, "scale:x", 0.05, 0.11)
	turn.tween_callback(swap)
	turn.tween_property(holder, "scale:x", 1.0, 0.13)
	await turn.finished


## A short wait between the steps of a turn (none when `animate` is off).
func pause(seconds: float) -> void:
	if animate and is_inside_tree():
		await get_tree().create_timer(seconds).timeout


## A little pop on `node` (a right guess, a filled ticket).
func pop(node: Control, amount: float = 1.1) -> void:
	if not animate or node == null:
		return
	node.pivot_offset = node.size * 0.5
	var pulse: Tween = create_tween()
	pulse.tween_property(node, "scale", Vector2(amount, amount), 0.09)
	pulse.tween_property(node, "scale", Vector2.ONE, 0.14)


## A miss shakes the table. The frame sits in a container: it is put back in its place afterwards (two shakes on top of each other, or a
## shake before the first layout, would otherwise leave it shifted).
func shake_table(strength: float = 8.0) -> void:
	if not animate or _stage == null or not is_inside_tree():
		return
	MinigameFx.shake(_stage, strength)
	get_tree().create_timer(0.5).timeout.connect(func() -> void:
		if is_instance_valid(_stage) and _stage.get_parent() is Container:
			(_stage.get_parent() as Container).queue_sort())


## A dark chip with gold text for a counter ("Rep 3 / 8").
func chip(text: String, node_name: String) -> Label:
	var label: Label = UIKit.label(text, &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = node_name
	label.add_theme_font_override("font", UIStyle.font_bold())
	var plate: StyleBoxFlat = UIStyle.box(Color(0.05, 0.03, 0.08, 0.8), UIStyle.GOLD_DIM, 2, 12)
	plate.content_margin_left = 16.0
	plate.content_margin_right = 16.0
	plate.content_margin_top = 4.0
	plate.content_margin_bottom = 4.0
	label.add_theme_stylebox_override("normal", plate)
	return label


## A game button that the keyboard and the controller reach (FancyButton turns its focus off on entering the tree).
func game_button(text: String, variation: StringName, min_size: Vector2, callback: Callable) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, variation, min_size)
	button.pressed.connect(callback)
	button.ready.connect(func() -> void: button.focus_mode = Control.FOCUS_ALL, CONNECT_ONE_SHOT)
	return button


# ---- How to play ------------------------------------------------------------------------------

func show_how() -> void:
	if _how != null and is_instance_valid(_how):
		return
	if state == "playing":
		state = "how"
	_how = _overlay_panel("HowToPlay")
	var box: VBoxContainer = _how.get_meta("box") as VBoxContainer
	var title: Label = UIKit.label("How to play: %s" % game_name(), &"HeadingLabel", 38, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(title)
	var lines: Array[String] = how_lines()
	for index: int in range(lines.size()):
		var line: Label = UIKit.label("%d.  %s" % [index + 1, lines[index]], &"", 25, UIStyle.PARCHMENT)
		line.name = "HowLine%d" % (index + 1)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(700, 0)
		box.add_child(line)
	var example: Control = Control.new()
	example.name = "Example"
	example.custom_minimum_size = Vector2(700, 240)
	example.mouse_filter = Control.MOUSE_FILTER_IGNORE
	example.clip_contents = true
	box.add_child(example)
	_build_example(example)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	var play: FancyButton = game_button("Play" if state != "done" else "Back", &"PrimaryButton", Vector2(260, 62), hide_how)
	play.name = "PlayButton"
	row.add_child(play)
	play.grab_focus.call_deferred()


func hide_how() -> void:
	if _how != null and is_instance_valid(_how):
		_how.queue_free()
	_how = null
	if state == "how":
		state = "playing"
		_on_play()
	_focus_table.call_deferred()


## Called when the "How to play" closes and play begins (or goes on).
func _on_play() -> void:
	pass


## The focus goes to the table's first button when an overlay closes.
func _focus_table() -> void:
	if is_inside_tree() and _table != null:
		UiInput.focus_first(_table)


func how_is_open() -> bool:
	return _how != null and is_instance_valid(_how)


## Overnight Nov 17 (the card games critic #5-6: with How to play open, the pad's A made a guess on the table under it; on the result
## screen the D-pad reached the header's "?"): while an overlay is up, nothing outside it takes focus; the old focus modes come back when
## it closes.
func _trap_focus(layer: Control) -> void:
	var held: Array[Control] = []
	for node: Node in find_children("*", "Control", true, false):
		var control: Control = node as Control
		if control == layer or layer.is_ancestor_of(control) or control.focus_mode == Control.FOCUS_NONE:
			continue
		control.set_meta(&"trap_focus_mode", control.focus_mode)
		control.focus_mode = Control.FOCUS_NONE
		held.append(control)
	layer.tree_exiting.connect(func() -> void:
		for control: Control in held:
			if is_instance_valid(control) and control.has_meta(&"trap_focus_mode"):
				control.focus_mode = int(control.get_meta(&"trap_focus_mode")) as Control.FocusMode
				control.remove_meta(&"trap_focus_mode"))


## A dimmed full-screen layer with a framed panel in the middle; the panel's content box is its "box" meta.
func _overlay_panel(layer_name: String) -> Control:
	var layer: Control = Control.new()
	layer.name = layer_name
	UIKit.full_rect(layer)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 60
	add_child(layer)
	_trap_focus(layer)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.04, 0.72)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.name = "Panel"
	panel.add_theme_stylebox_override("panel", UiSkin.popup_panel() if UiArt.has("UI-PANEL-POPUP") else UIStyle.box(WOOD, BRASS, 4, 18))
	center.add_child(panel)
	var pad: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 26)
	for side: String in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(pad)
	var box: VBoxContainer = UIKit.vbox(12)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	pad.add_child(box)
	layer.set_meta("box", box)
	if animate:
		layer.modulate.a = 0.0
		create_tween().tween_property(layer, "modulate:a", 1.0, 0.15)
	return layer


# ---- the end ----------------------------------------------------------------------------------

## Ends the game: pays it, plays the sting, shows the win or lose panel.
func finish(won: bool, stars: int, headline: String, detail: String) -> void:
	if state == "done":
		return
	state = "done"
	var reward: Dictionary = _pay(stars if won else 0)
	Audio.sting(&"STG-MINI-SUCCESS" if won else &"STG-MINI-FAIL")
	MinigameFx.finish(self, won)
	_result = _overlay_panel("ResultPanel")
	_result.set_meta("won", won)
	var box: VBoxContainer = _result.get_meta("box") as VBoxContainer
	var title: Label = UIKit.label(headline, &"HeadingLabel", 46, UIStyle.GOLD if won else Color("ff9d98"), HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Headline"
	box.add_child(title)
	var star_text: String = "★".repeat(stars) + "☆".repeat(3 - stars) if won else "☆☆☆"
	var star_label: Label = UIKit.label(star_text, &"", 60, UIStyle.GOLD if won else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	star_label.name = "Stars"
	box.add_child(star_label)
	if animate:
		star_label.pivot_offset = Vector2(120, 40)
		star_label.scale = Vector2(0.4, 0.4)
		create_tween().tween_property(star_label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var detail_label: Label = UIKit.label(detail, &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	detail_label.name = "Detail"
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(760, 0)
	box.add_child(detail_label)
	var reward_label: Label = UIKit.label(reward_text(reward, won), &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	reward_label.name = "Reward"
	reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reward_label.custom_minimum_size = Vector2(760, 0)
	box.add_child(reward_label)
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	var again: FancyButton = game_button("Play again", &"PrimaryButton", Vector2(260, 62), play_again)
	again.name = "PlayAgain"
	row.add_child(again)
	var leave: FancyButton = game_button("Leave", &"", Vector2(200, 62), request_close)
	leave.name = "LeaveButton"
	row.add_child(leave)
	again.grab_focus.call_deferred()
	game_finished.emit(stars if won else 0, reward)


## "+130 gold   +40 XP   Healing Salve" for a paid result; what a loss or a repeat says otherwise.
func reward_text(reward: Dictionary, won: bool) -> String:
	if not won:
		return "No reward this time. Try again whenever you like."
	var parts: PackedStringArray = []
	if int(reward.get("gold", 0)) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward.get("xp", 0)) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not PackRewards.minigame_text(reward).is_empty():
		parts.append(PackRewards.minigame_text(reward))
	var item_id: String = str(reward.get("item", ""))
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		parts.append(Session.content.item(item_id).display_name)
	if not str(reward.get("text", "")).is_empty():
		parts.append(str(reward["text"]))
	return "   ".join(parts) if not parts.is_empty() else "Already won: nothing more to earn here."


func play_again() -> void:
	if _result != null and is_instance_valid(_result):
		_result.queue_free()
	_result = null
	state = "playing"
	_new_game()
	_on_play()
	_focus_table.call_deferred()


func result_panel() -> Control:
	return _result if _result != null and is_instance_valid(_result) else null


# ---- shots ------------------------------------------------------------------------------------

## Screenshot states (`--mg=how|mid|win|lose` on a zone shot, tools/minigame_shots.sh): "how" leaves the How to play up; the others play the
## game without its waits to the middle, a win or a loss.
func shot_state(kind: String) -> void:
	if kind == "how" or kind.is_empty():
		return
	animate = false
	hide_how()
	match kind:
		"mid":
			await _shot_mid()
		"win":
			await _shot_end(true)
		"lose":
			await _shot_end(false)


func _shot_mid() -> void:
	pass


func _shot_end(_won: bool) -> void:
	pass
