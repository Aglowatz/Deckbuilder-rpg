class_name ServiceDebuffsPanel
extends PanelContainer
## The Capital's broken services in the zone HUD: one row per Path (green and "restored" once that Path's zone is free, red while
## its service is still broken), each with a tooltip that explains the debuff (and what changed once it is lifted).

const GOOD: Color = Color("6fbf73")
const BAD: Color = Color("e8625a")


static func make(flags: Dictionary) -> ServiceDebuffsPanel:
	var panel: ServiceDebuffsPanel = ServiceDebuffsPanel.new()
	panel.name = "ServiceDebuffsPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(300, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = UIKit.vbox(5)
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(column)
	var active_count: int = CapitalDebuffs.active(flags).size()
	column.add_child(UIKit.label("Broken services (%d of 4)" % active_count, &"HeadingLabel", 21))
	panel.tooltip_text = "The kingdom's four services are broken. Free each Path's zone to restore its service here."
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.all():
		var active: bool = CapitalDebuffs.is_active(flags, debuff.zone_id)
		column.add_child(_row(debuff, active))
	return panel


static func _row(debuff: CapitalDebuffs.Debuff, active: bool) -> VBoxContainer:
	var box: VBoxContainer = UIKit.vbox(0)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var sign_text: String = "-" if active else "+"
	var head: Label = UIKit.label("%s  %s  (%s)" % [sign_text, debuff.name_text(), Affinity.display_name(debuff.path)], &"", 19, BAD if active else GOOD)
	head.add_theme_font_override("font", UIStyle.font_bold())
	head.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(head)
	box.tooltip_text = debuff.tooltip(active)
	return box
