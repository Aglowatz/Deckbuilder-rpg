class_name PacksScreen
extends OverlayScreen
## The Packs menu entry: every unopened pack in the inventory with an Open button (the opening ceremony plays on top). Packs come from dungeons, quests and vendors.

var _list: VBoxContainer


func _init() -> void:
	screen_title = "Card Packs"
	close_text = "Close (Esc)"


func _build() -> void:
	var note: Label = UIKit.label("Unopened packs. Dungeons, quests and vendors give them.", &"MutedLabel", 22)
	body.add_child(note)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_list = UIKit.vbox(10)
	_list.custom_minimum_size = Vector2(1100, 0)
	scroll.add_child(_list)
	_refresh()


func _refresh() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	var shown: int = 0
	for pack: PackData in PackCatalog.all():
		var count: int = Session.profile.pack_count(pack.id)
		if count <= 0:
			continue
		shown += 1
		var row: HBoxContainer = UIKit.hbox(14)
		row.add_child(PackArt.icon(pack, 0.2))
		var name_label: Label = UIKit.label("%s   x%d" % [pack.display_name, count], &"", 30, UIStyle.PARCHMENT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var open: FancyButton = FancyButton.make("Open", &"PrimaryButton", Vector2(150, 50))
		open.name = "Open_%s" % pack.id
		open.pressed.connect(func() -> void:
			Audio.sfx(&"ui_confirm")
			PackOpeningScreen.open_from_inventory(self, pack.id, func() -> void: _refresh()))
		row.add_child(open)
		_list.add_child(row)
	if shown == 0:
		_list.add_child(UIKit.label("No unopened packs. Free a zone, finish quests, or visit the Pack Vendor.", &"MutedLabel", 26))
