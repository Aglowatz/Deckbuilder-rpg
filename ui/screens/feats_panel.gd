class_name FeatsPanel
extends PanelContainer
## Overnight Oct 27-28, Part 3: the Feats page of the pause menu - every feat by group, earned ones bright with the date, hidden ones as
## "???" until earned, the account total at the top. Controller: the pause menu's root owns focus; the right stick scrolls the list.

signal closed

var _list: VBoxContainer
var _title: Label


static func make() -> FeatsPanel:
	var panel: FeatsPanel = FeatsPanel.new()
	panel.name = "FeatsPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(980, 760)
	panel._build()
	return panel


func _build() -> void:
	var column: VBoxContainer = UIKit.vbox(10)
	add_child(column)
	var head: HBoxContainer = UIKit.hbox(10)
	column.add_child(head)
	_title = UIKit.label("Feats", &"HeadingLabel", 36)
	_title.name = "FeatsTitle"
	head.add_child(_title)
	head.add_child(UIKit.filler())
	var back: FancyButton = FancyButton.make("Back", &"GhostButton", Vector2(140, 44))
	back.name = "FeatsBack"
	back.pressed.connect(func() -> void: closed.emit())
	head.add_child(back)
	var summary: Label = UIKit.label(summary_text(), &"MutedLabel", 18)
	summary.name = "FeatsSummary"
	column.add_child(summary)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(940, 620)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_list = UIKit.vbox(8)
	_list.custom_minimum_size = Vector2(910, 0)
	scroll.add_child(_list)
	refresh()


## "12 of 40 earned (this campaign 9)".
static func summary_text() -> String:
	var total: int = FeatDefs.count()
	var account: int = FeatAccount.count()
	var slot: int = Session.feats.state.count() if Session.feats != null else 0
	return "%d of %d earned on this account (this campaign: %d). Hidden feats show as ??? until earned." % [account, total, slot]


func refresh() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	for group: String in FeatDefs.GROUP_ORDER:
		var defs: Array[FeatDefs.Def] = FeatDefs.in_group(group)
		if defs.is_empty():
			continue
		var heading: Label = UIKit.label(group, &"", 24, UIStyle.GOLD)
		heading.name = "Group_%s" % group.replace(" ", "_")
		heading.add_theme_font_override("font", UIStyle.font_bold())
		# Art import Oct 29: the group's feat icon beside its heading.
		var heading_row: HBoxContainer = UIKit.hbox(10)
		if IconArt.has(FeatDefs.group_icon(group)):
			heading_row.add_child(IconArt.rect(FeatDefs.group_icon(group), 40.0))
		heading_row.add_child(heading)
		_list.add_child(heading_row)
		for def: FeatDefs.Def in defs:
			_list.add_child(_row(def))


## The [title, text] a feat shows: "???" and "A hidden feat." until a hidden one is earned.
static func row_texts(def: FeatDefs.Def) -> Array[String]:
	var earned: bool = FeatAccount.has(def.id)
	if def.hidden and not earned:
		return ["???", "A hidden feat."]
	var text: String = def.earned_by
	var reward: String = def.reward_text()
	if not reward.is_empty():
		text += "  (%s)" % reward
	return [def.name, text]


func _row(def: FeatDefs.Def) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(12)
	row.name = "Feat_%s" % def.id
	var earned: bool = FeatAccount.has(def.id)
	var icon_id: String = FeatDefs.icon_for(def, earned)
	if IconArt.has(icon_id):
		row.add_child(IconArt.rect(icon_id, 34.0))
	var box: VBoxContainer = UIKit.vbox(2)
	var texts: Array[String] = row_texts(def)
	var head: Label = UIKit.label(texts[0], &"", 22, UIStyle.GOLD if earned else UIStyle.PARCHMENT)
	head.add_theme_font_override("font", UIStyle.font_bold())
	box.add_child(head)
	var body: Label = UIKit.label(texts[1], &"", 18, UIStyle.PARCHMENT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(800, 0)
	box.add_child(body)
	row.add_child(box)
	row.add_child(UIKit.filler())
	var mark: Label = UIKit.label("Earned" if earned else "", &"MutedLabel", 16)
	mark.name = "Mark"
	if earned and Session.feats != null and Session.feats.state.has(def.id):
		mark.text = "Earned here"
	row.add_child(mark)
	row.modulate = Color(1, 1, 1, 1) if earned else Color(1, 1, 1, 0.62)
	return row
