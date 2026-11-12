class_name RulesBrief
extends Control
## Daytime Oct 19: the "Before the fight" card (Shiro's duel, the arena, and since Nov 12 the dungeon maps too): the fight's rules, one row
## each, and Continue. The same badges stay on screen in the battle HUD.
## Fable Nov 12c (Part B): built on `NodeCard`. It was a big empty box with a row of small icons and a line of text; now the foe's picture
## (the cut-out, or the Bestiary picture in a medallion) stands in the banner over the dungeon's map, and every rule is a row of
## icon + name + one line of text, a hidden trait as a "?" row with its explanation.

signal continued

const FIGHT_PREFIX: String = "Before the fight: "
const ENTER_PREFIX: String = "Entering "
## Rule colours for dark ink on the vellum body (the badges' own colours are made for dark panels).
const SCRIPTED_INK: Color = Color("6a3fa0")

var badges: Array[RuleBadges.Badge] = []
var card: NodeCard
var _columns: int = 1


## Shows the card over `parent` and calls `then` on Continue (at once when there are no rules). `in_layer`: on its own canvas layer over a
## world scene's HUD (the default), or as a plain child (the dungeon map, which is a Control). `node`: the dungeon room, for the banner.
static func open(parent: Node, rule_badges: Array[RuleBadges.Badge], title: String, then: Callable, in_layer: bool = true, node: DungeonMap.MapNode = null) -> RulesBrief:
	if rule_badges.is_empty() or parent == null:
		if then.is_valid():
			then.call()
		return null
	var brief: RulesBrief = RulesBrief.new()
	brief.name = "RulesBrief"
	brief.badges = rule_badges
	UIKit.full_rect(brief)
	brief.z_index = 140
	brief.mouse_filter = Control.MOUSE_FILTER_STOP
	var layer: CanvasLayer = null
	if in_layer:
		layer = CanvasLayer.new()
		layer.layer = 60
		layer.name = "RulesBriefLayer"
		parent.add_child(layer)
		layer.add_child(brief)
	else:
		parent.add_child(brief)
	brief._build(title, node)
	brief.continued.connect(func() -> void:
		if layer != null:
			layer.queue_free()
		else:
			brief.queue_free()
		if then.is_valid():
			then.call(), CONNECT_ONE_SHOT)
	return brief


## "Before the fight: Mortimer Grimsby" -> ["Before the fight", "Mortimer Grimsby", foe name]; "Entering the Hall" -> ["Dungeon rules",
## "the Hall", ""]; anything else is its own title.
static func split_title(title: String) -> Array[String]:
	if title.begins_with(FIGHT_PREFIX):
		var foe: String = title.substr(FIGHT_PREFIX.length())
		return ["Before the fight", foe, foe]
	if title.begins_with(ENTER_PREFIX):
		return ["Dungeon rules", title.substr(ENTER_PREFIX.length()), ""]
	return ["The rules in play", title, ""]


func _build(title: String, node: DungeonMap.MapNode = null) -> void:
	PadFocus.register(self)  # controller support (Oct 26)
	var parts: Array[String] = split_title(title)
	var rules: Array[RuleBadges.Badge] = distinct_by_name(badges)
	# many rules (a boss in a dungeon with zone rules): two columns and a lower banner, so the whole card fits the screen
	_columns = 2 if rules.size() > 5 else 1
	card = NodeCard.make(NodeCard.Kind.FIGHT, parts[1], 1180.0 if _columns == 2 else 980.0, parts[0], 190.0 if rules.size() > 5 else NodeCard.BANNER_HEIGHT)
	add_child(card)
	if node != null:
		card.set_banner_for_node(node)
		if node.kind == DungeonMap.Kind.BOSS:
			card.set_icon("ICON-NODE-BOSS")
		elif node.kind == DungeonMap.Kind.ELITE:
			card.set_icon("ICON-NODE-ELITE")
	if not parts[2].is_empty():
		var cutout: Texture2D = Bestiary.cutout(parts[2])
		if cutout != null:
			card.set_banner_portrait(cutout, true)
		else:
			var picture: Texture2D = Bestiary.art(parts[2])
			if picture != null:
				card.set_banner_portrait(picture, false)
	else:
		card.set_icon("ICON-MAP-DUNGEON")
	var note: Label = card.line("These rules are in play. The same icons stay on screen during the fight.", NodeCard.INK_SOFT, 19)
	note.name = "BriefNote"
	var rows: GridContainer = GridContainer.new()
	rows.name = "RuleRows"
	rows.columns = _columns
	rows.add_theme_constant_override("h_separation", 28)
	rows.add_theme_constant_override("v_separation", 8)
	card.content.add_child(rows)
	var scripted: GridContainer = null
	for badge: RuleBadges.Badge in rules:
		# Overnight Oct 23: the scripted events come after the rules, under their own heading (what CAN happen, once each).
		if badge.kind == "scripted" and scripted == null:
			var heading: Label = UIKit.label("What can happen in this fight (once each)", &"", NodeCard.text_px(19), SCRIPTED_INK)
			heading.name = "ScriptedHeading"
			heading.add_theme_font_override("font", UIStyle.font_bold())
			card.content.add_child(heading)
			scripted = GridContainer.new()
			scripted.name = "ScriptedRows"
			scripted.columns = _columns
			scripted.add_theme_constant_override("h_separation", 28)
			scripted.add_theme_constant_override("v_separation", 8)
			card.content.add_child(scripted)
		(scripted if badge.kind == "scripted" and scripted != null else rows).add_child(_row(badge))
	var go: FancyButton = card.button("Continue", true, "ICON-NODE-BATTLE" if not parts[2].is_empty() else "", 260.0)
	go.name = "BriefContinue"
	go.pressed.connect(func() -> void:
		Audio.sfx(&"ui_confirm")
		continued.emit())
	go.call_deferred(&"grab_focus")
	ConfirmKey.attach(card, go)  # Fresh eyes round 2 (Oct 31): E / Enter / Space / pad A continue
	Audio.sfx(&"ui_open")


## The colour of a rule's name on the vellum: good for the player, against the player, shared, a scripted event.
static func ink_of(badge: RuleBadges.Badge) -> Color:
	if badge.kind == "scripted":
		return SCRIPTED_INK
	var light: Color = badge.color()
	if light.g > light.r and light.g > light.b:
		return NodeCard.GOOD_INK
	if light.r > light.g * 1.25:
		return NodeCard.BAD_INK
	return NodeCard.GOLD_INK


## One rule: its icon in a round plate, its name, one line of what it does. A hidden trait shows a "?" and says how it is revealed.
func _row(badge: RuleBadges.Badge) -> Control:
	var ink: Color = ink_of(badge)
	var row: HBoxContainer = UIKit.hbox(14)
	row.name = "Rule_%s" % badge.name.replace(" ", "_")
	var plate: Panel = Panel.new()
	plate.custom_minimum_size = Vector2(52, 52)
	plate.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	plate.add_theme_stylebox_override("panel", UIStyle.box(Color(0.14, 0.1, 0.18), ink, 2, 26))
	plate.tooltip_text = badge.tooltip() if badge.has_method("tooltip") else badge.text
	row.add_child(plate)
	if badge.hidden:
		var mark: Label = UIKit.label("?", &"", 32, Color("ffe08a"), HORIZONTAL_ALIGNMENT_CENTER)
		mark.name = "HiddenMark"
		mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		mark.add_theme_font_override("font", UIStyle.font_title())
		mark.size = Vector2(52, 52)
		plate.add_child(mark)
	else:
		var glyph: TextureRect = IconArt.glyph_or(badge.icon, CardIcons.named(badge.icon) if not badge.icon.begins_with("ICON-") else CardIcons.named(RuleBadges.DEFAULT_ICON), badge.color(), 36.0)
		if glyph != null:
			glyph.position = Vector2(8, 8)
			glyph.size = Vector2(36, 36)
			glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
			plate.add_child(glyph)
	var words: VBoxContainer = UIKit.vbox(0)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label: Label = UIKit.label(badge.name, &"", NodeCard.text_px(22), ink)
	name_label.name = "RuleName"
	name_label.add_theme_font_override("font", UIStyle.font_bold())
	words.add_child(name_label)
	var text: String = rule_text(badge, badges)
	if not text.is_empty():
		var line: Label = UIKit.label(text, &"", NodeCard.text_px(19), NodeCard.INK)
		line.name = "RuleText"
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2((card.card_width - 110.0) / float(_columns) - 110.0, 0)
		words.add_child(line)
	row.add_child(words)
	return row


## Fresh eyes round 2 (Oct 31): one line per rule NAME. A zone rule and a boss rule of the same name ("Red Tape Everywhere" from the Hall
## and from Mortimer) used to print as two lines; the second made the critic doubt the rest. The first badge of a name keeps the line and
## `line_text` folds the others' texts into it; the icon row still shows every badge.
static func distinct_by_name(rule_badges: Array[RuleBadges.Badge]) -> Array[RuleBadges.Badge]:
	var seen: Dictionary = {}
	var result: Array[RuleBadges.Badge] = []
	for badge: RuleBadges.Badge in rule_badges:
		if seen.has(badge.name):
			continue
		seen[badge.name] = true
		result.append(badge)
	return result


## "Red Tape Everywhere: Start each battle with one Red Tape. Also: Starts the duel with 3 Red Tape." - the first line of every badge of
## that name, in order, identical texts once.
static func line_text(badge: RuleBadges.Badge, rule_badges: Array[RuleBadges.Badge]) -> String:
	var text: String = rule_text(badge, rule_badges)
	if text.is_empty():
		return badge.name
	return "%s: %s" % [badge.name, text]


## The text of `line_text` without the name in front (the row prints the name on its own line).
static func rule_text(badge: RuleBadges.Badge, rule_badges: Array[RuleBadges.Badge]) -> String:
	var texts: PackedStringArray = []
	for other: RuleBadges.Badge in rule_badges:
		if other.name != badge.name:
			continue
		var first: String = other.text.split("\n")[0].strip_edges()
		if not first.is_empty() and not texts.has(first):
			texts.append(first)
	return " Also: ".join(texts)
