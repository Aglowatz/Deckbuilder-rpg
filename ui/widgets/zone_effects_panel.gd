class_name ZoneEffectsPanel
extends PanelContainer
## Part C: shows a zone's buff (green) and debuff (red) with their mechanical text, and a tooltip with
## the flavor and the reminder that both sides are affected. Used by the zone HUD and the battle HUD.

const GOOD: Color = Color("6fbf73")
const BAD: Color = Color("e8625a")


## Builds the panel for `effect`; `title` is the zone's name. `compact` drops the mechanic lines (the
## tooltips still carry them).
static func make(effect: ZoneEffects.Effect, title: String, compact: bool = false) -> ZoneEffectsPanel:
	var panel: ZoneEffectsPanel = ZoneEffectsPanel.new()
	panel.name = "ZoneEffectsPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(300, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = UIKit.vbox(5)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(column)
	column.add_child(UIKit.label(title if not title.is_empty() else "Zone effects", &"HeadingLabel", 21))
	column.add_child(_row("+", effect.buff_name(), effect.buff_mechanic(), GOOD, effect.buff_flavor(), compact))
	column.add_child(_row("-", effect.debuff_name(), effect.debuff_mechanic(), BAD, effect.debuff_flavor(), compact))
	return panel


static func _row(sign_text: String, title: String, mechanic: String, color: Color, flavor: String, compact: bool) -> VBoxContainer:
	var box: VBoxContainer = UIKit.vbox(0)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var head: Label = UIKit.label("%s  %s" % [sign_text, title], &"", 20, color)
	head.add_theme_font_override("font", UIStyle.font_bold())
	head.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(head)
	if not compact:
		var body: Label = UIKit.label(mechanic, &"MutedLabel", 16)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(270, 0)
		body.mouse_filter = Control.MOUSE_FILTER_PASS
		box.add_child(body)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	var prefix: String = "Buff: " if sign_text == "+" else "Debuff: "
	HoverTip.attach(box, prefix + title, "%s\n\n%s\n\nApplies to you and to the enemy." % [mechanic, flavor], color)
	return box
