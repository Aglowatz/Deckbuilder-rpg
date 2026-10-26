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
	for badge: RuleBadges.Badge in badges:
		# Overnight Oct 23: the scripted events come after the rules, under their own heading (what CAN happen, once each).
		if badge.kind == "scripted" and not scripted_heading:
			scripted_heading = true
			var heading: Label = UIKit.label("What can happen in this fight (once each):", &"", 18, RuleBadges.SCRIPTED_COLOR)
			heading.name = "ScriptedHeading"
			heading.add_theme_font_override("font", UIStyle.font_bold())
			column.add_child(heading)
		var line: Label = UIKit.label("%s: %s" % [badge.name, badge.text.split("\n")[0]], &"", 19, badge.color())
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
	UIKit.pop_in(panel)
