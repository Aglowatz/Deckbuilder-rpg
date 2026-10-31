class_name RulesBrief
extends Control
## Daytime Oct 19: the "Before the fight" card outside the dungeon maps (Shiro's duel, the arena): the fight's rule icons (hover = text),
## one line per rule, and Continue. The same badges stay on screen in the battle HUD. The dungeon map has its own copy of this card.

signal continued

var badges: Array[RuleBadges.Badge] = []


## Shows the card over `parent` and calls `then` on Continue (at once when there are no rules).
static func open(parent: Node, rule_badges: Array[RuleBadges.Badge], title: String, then: Callable) -> RulesBrief:
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
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	layer.name = "RulesBriefLayer"
	parent.add_child(layer)
	layer.add_child(brief)
	brief._build(title)
	brief.continued.connect(func() -> void:
		layer.queue_free()
		if then.is_valid():
			then.call(), CONNECT_ONE_SHOT)
	return brief


func _build(title: String) -> void:
	PadFocus.register(self)  # controller support (Oct 26)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.6)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label(title, &"HeadingLabel", 32, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.label("The rules in play. Hover an icon for its text; the same icons stay on screen during the fight.", &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row: RuleIconRow = RuleIconRow.make(badges, "", true)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(row)
	var scripted_heading: bool = false
	for badge: RuleBadges.Badge in distinct_by_name(badges):
		# Overnight Oct 23: the scripted events come after the rules, under their own heading (what CAN happen, once each).
		if badge.kind == "scripted" and not scripted_heading:
			scripted_heading = true
			var heading: Label = UIKit.label("What can happen in this fight (once each):", &"", 18, RuleBadges.SCRIPTED_COLOR)
			heading.name = "ScriptedHeading"
			heading.add_theme_font_override("font", UIStyle.font_bold())
			column.add_child(heading)
		var line: Label = UIKit.label(line_text(badge, badges), &"", 19, badge.color())
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(760, 0)
		column.add_child(line)
	var go: FancyButton = FancyButton.make("Continue", &"PrimaryButton", Vector2(220, 56))
	go.name = "BriefContinue"
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.pressed.connect(func() -> void: continued.emit())
	column.add_child(go)
	go.focus_mode = Control.FOCUS_ALL
	go.call_deferred(&"grab_focus")
	ConfirmKey.attach(self, go)  # Fresh eyes round 2 (Oct 31): E / Enter / Space / pad A continue
	UIKit.pop_in(panel)


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
	var texts: PackedStringArray = []
	for other: RuleBadges.Badge in rule_badges:
		if other.name != badge.name:
			continue
		var first: String = other.text.split("\n")[0].strip_edges()
		if not first.is_empty() and not texts.has(first):
			texts.append(first)
	if texts.is_empty():
		return badge.name
	return "%s: %s" % [badge.name, " Also: ".join(texts)]
