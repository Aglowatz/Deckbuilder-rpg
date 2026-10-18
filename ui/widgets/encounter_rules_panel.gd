class_name EncounterRulesPanel
extends PanelContainer
## Rebalance Part E: the one-sided rules of this fight (`EncounterModifiers`), one row per rule with its icon, in the battle HUD
## (under the zone effects) and wherever a fight is previewed. Each row's tooltip carries the full text and which side it applies to.
## Rules that apply to the enemy are shown in red, rules that apply to the player in green.

const ENEMY: Color = Color("e8625a")
const PLAYER: Color = Color("6fbf73")


static func make(rules: Array[EncounterModifiers.Rule], title: String = "Encounter rules", compact: bool = false) -> EncounterRulesPanel:
	var panel: EncounterRulesPanel = EncounterRulesPanel.new()
	panel.name = "EncounterRulesPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(300, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = UIKit.vbox(5)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(column)
	column.add_child(UIKit.label(title, &"HeadingLabel", 21))
	var seen: Dictionary = {}
	for rule: EncounterModifiers.Rule in rules:
		# Rules split over several modifiers share a name and a text: one row.
		if seen.has(rule.name):
			continue
		seen[rule.name] = true
		column.add_child(_row(rule, compact))
	return panel


static func _row(rule: EncounterModifiers.Rule, compact: bool) -> HBoxContainer:
	var color: Color = ENEMY if rule.is_enemy_side() else PLAYER
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	var icon_id: String = rule.icon if IconArt.has(rule.icon) else EncounterModifiers.DEFAULT_ICON
	if IconArt.has(icon_id):
		var glyph: TextureRect = IconArt.rect(icon_id, 26.0)
		glyph.modulate = color
		glyph.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(glyph)
	var box: VBoxContainer = UIKit.vbox(0)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var head: Label = UIKit.label(rule.name, &"", 19, color)
	head.add_theme_font_override("font", UIStyle.font_bold())
	head.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(head)
	if not compact:
		var body: Label = UIKit.label(rule.text, &"MutedLabel", 15)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(240, 0)
		body.mouse_filter = Control.MOUSE_FILTER_PASS
		box.add_child(body)
	row.add_child(box)
	HoverTip.attach(row, rule.name, rule.tooltip(), color, icon_id)
	return row
