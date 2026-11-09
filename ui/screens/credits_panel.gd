class_name CreditsPanel
extends PanelContainer
## Overnight Nov 8-9 (Part 4, release basics): the Credits page (title menu > Credits): who made the game, Godot's licence notice and its
## third-party components, the fonts, the music and soundfont, the sounds, the models and icons, and the plain note about AI tools. The text
## lives in data/credits/credits.txt; the creator's name and the donation link in data/credits/credits.cfg ("Support the game" stays
## hidden while the link is empty).

signal closed

const TEXT_PATH: String = "res://data/credits/credits.txt"
const CONFIG_PATH: String = "res://data/credits/credits.cfg"

var _scroll: ScrollContainer


static func make() -> CreditsPanel:
	var panel: CreditsPanel = CreditsPanel.new()
	panel.name = "CreditsPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(1100, 820)
	panel._build()
	return panel


## The donation page from credits.cfg ("" = none: the Support buttons stay hidden).
static func support_url() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return ""
	return str(config.get_value("support", "url", "")).strip_edges()


static func creator() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return ""
	return str(config.get_value("credits", "creator", "")).strip_edges()


## A "Support the game" button that opens the donation page, or null when no page is set.
static func support_button(size: Vector2 = Vector2(260, 52)) -> FancyButton:
	var url: String = support_url()
	if url.is_empty():
		return null
	var button: FancyButton = FancyButton.make("Support the game", &"", size)
	button.name = "SupportButton"
	button.tooltip_text = "Opens %s in your browser. The game is free; a tip is kind but never needed." % url
	button.pressed.connect(func() -> void: OS.shell_open(url))
	return button


## The credits as paragraphs: [kind, text] with kind "h1", "h2" or "p". Comment lines (";") are dropped, {creator}/{version} filled.
static func paragraphs() -> Array[Array]:
	var result: Array[Array] = []
	var text: String = FileAccess.get_file_as_string(TEXT_PATH) if FileAccess.file_exists(TEXT_PATH) else ""
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	var who: String = creator()
	for raw: String in text.replace("\r", "").split("\n"):
		var line: String = raw.strip_edges()
		if line.is_empty() or line.begins_with(";"):
			continue
		line = line.replace("{version}", version)
		if line.contains("{creator}") or line.contains("{creator_name}"):
			if who.is_empty():
				continue
			line = line.replace("{creator}", "A game by %s" % who).replace("{creator_name}", who)
		if line.begins_with("## "):
			result.append(["h2", line.substr(3)])
		elif line.begins_with("# "):
			result.append(["h1", line.substr(2)])
		else:
			result.append(["p", line])
	return result


func _build() -> void:
	var column: VBoxContainer = UIKit.vbox(12)
	add_child(column)
	var head: HBoxContainer = UIKit.hbox(12)
	var title: Label = UIKit.label("Credits", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var support: FancyButton = support_button(Vector2(240, 46))
	if support != null:
		head.add_child(support)
	var close: FancyButton = FancyButton.make("Close", &"GhostButton", Vector2(140, 46))
	close.name = "CloseCredits"
	close.pressed.connect(func() -> void: closed.emit())
	head.add_child(close)
	column.add_child(head)
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(1060, 720)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_scroll)
	var body: VBoxContainer = UIKit.vbox(8)
	body.custom_minimum_size = Vector2(1030, 0)
	_scroll.add_child(body)
	for row: Array in paragraphs():
		body.add_child(_line(str(row[0]), str(row[1])))
	# Godot's third-party components, from the engine itself (the licence notices the MIT licence and theirs ask for).
	body.add_child(_line("h2", "Third-party components in Godot Engine"))
	var parts: PackedStringArray = []
	for info: Dictionary in Engine.get_copyright_info():
		var holders: PackedStringArray = []
		for part: Dictionary in info.get("parts", []) as Array:
			for holder: Variant in part.get("copyright", []) as Array:
				holders.append(str(holder))
			holders.append("(%s)" % str(part.get("license", "")))
		parts.append("%s: %s" % [str(info.get("name", "")), " ".join(holders)])
	body.add_child(_line("small", "\n".join(parts)))
	var licences: Dictionary = Engine.get_license_info()
	for licence_name: Variant in licences.keys():
		body.add_child(_line("h2", str(licence_name)))
		body.add_child(_line("small", str(licences[licence_name])))


func _line(kind: String, text: String) -> Label:
	var size: int = 20
	var colour: Color = UIStyle.PARCHMENT
	match kind:
		"h1":
			size = 30
			colour = UIStyle.GOLD
		"h2":
			size = 24
			colour = UIStyle.GOLD
		"small":
			size = 15
			colour = UIStyle.MUTED
	var label: Label = UIKit.label(text, &"", size, colour, HORIZONTAL_ALIGNMENT_CENTER if kind == "h1" else HORIZONTAL_ALIGNMENT_LEFT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(1020, 0)
	if kind == "h1":
		label.add_theme_font_override("font", UIStyle.font_title())
	return label


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		closed.emit()
		get_viewport().set_input_as_handled()
