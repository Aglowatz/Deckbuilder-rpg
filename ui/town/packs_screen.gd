class_name PacksScreen
extends OverlayScreen
## The Packs menu entry: every unopened pack in the inventory with an Open button (the opening ceremony plays on top). Packs come from dungeons, quests and vendors.

var _list: VBoxContainer


func _init() -> void:
	screen_title = "Card Packs"
	title_icon_id = "ICON-UI-PACKS"
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
	# Fixes Oct 25, Part 6: the onboarding tip for the first pack (Make It Yours opens with one)
	TipPanel.show_once(self, &"tip_packs", "Opening packs", "Click [b]Open[/b] to tear a pack: its cards join your collection at once. A copy past its cap turns into essence and gold. Then put the new cards to work at the [b]Deck Station[/b].", Vector2(560, 860))


func _refresh() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	var shown: int = 0
	# Overnight Oct 31 - Nov 1 (mid-game critic #13): with two or more plain packs, "Open all" opens them in one go with one summary;
	# gilded packs (a guaranteed Epic or Legendary) keep their ceremony.
	var plain: int = plain_pack_count()
	if plain >= 2:
		var all_row: HBoxContainer = UIKit.hbox(16)
		var all_button: FancyButton = FancyButton.make("Open all (%d packs)" % plain, &"PrimaryButton", Vector2(300, 52))
		all_button.name = "OpenAll"
		all_button.pressed.connect(func() -> void:
			Audio.sfx(&"ui_confirm")
			_show_open_all(open_all()))
		all_row.add_child(all_button)
		# Fix pass Nov 7 (item 8, C3 F4): say what Open all leaves out.
		if gilded_pack_count() > 0:
			var skipped: Label = UIKit.label("Gilded packs (%d, a sure Epic or Legendary) are opened one at a time below." % gilded_pack_count(), &"MutedLabel", 20)
			skipped.name = "OpenAllSkips"
			skipped.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			all_row.add_child(skipped)
		_list.add_child(all_row)
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


## How many packs "Open all" would open (every pack but the gilded ones).
static func plain_pack_count() -> int:
	var total: int = 0
	for pack: PackData in PackCatalog.all():
		if not pack.guarantee_epic_or_legendary:
			total += Session.profile.pack_count(pack.id)
	return total


## Fix pass Nov 7 (item 8): the gilded packs "Open all" leaves for their own ceremony.
static func gilded_pack_count() -> int:
	var total: int = 0
	for pack: PackData in PackCatalog.all():
		if pack.guarantee_epic_or_legendary:
			total += Session.profile.pack_count(pack.id)
	return total


## Opens every plain pack in the inventory (cards join the collection as with one pack at a time) and returns the openings.
static func open_all() -> Array[PackOpening]:
	var openings: Array[PackOpening] = []
	for pack: PackData in PackCatalog.all():
		if pack.guarantee_epic_or_legendary:
			continue
		while Session.profile.pack_count(pack.id) > 0:
			var opening: PackOpening = Session.open_pack(pack.id)
			if opening == null:
				break
			openings.append(opening)
	return openings


## The summary of an "Open all": how many packs and cards, the new cards by name, the rest with copy counts, and what extra copies became.
static func summary_lines(openings: Array[PackOpening]) -> PackedStringArray:
	var lines: PackedStringArray = []
	var cards: int = 0
	var new_names: PackedStringArray = []
	var other: Dictionary = {}
	var essence: int = 0
	var gold: int = 0
	for opening: PackOpening in openings:
		for entry: PackOpening.Entry in opening.entries:
			cards += 1
			if entry.is_new and not new_names.has(entry.card.display_name):
				new_names.append(entry.card.display_name)
			elif not entry.converted:
				other[entry.card.display_name] = int(other.get(entry.card.display_name, 0)) + 1
			for path: Variant in entry.essence.keys():
				essence += int(entry.essence[path])
			gold += entry.gold
	lines.append("Opened %d pack%s: %d cards." % [openings.size(), "" if openings.size() == 1 else "s", cards])
	if not new_names.is_empty():
		lines.append("[color=#ffcf70]New: %s[/color]" % ", ".join(new_names))
	if not other.is_empty():
		var parts: PackedStringArray = []
		for card_name: Variant in other.keys():
			parts.append("%s%s" % [card_name, "" if int(other[card_name]) == 1 else " x%d" % int(other[card_name])])
		lines.append("More copies: %s" % ", ".join(parts))
	if essence > 0 or gold > 0:
		lines.append("Extra copies past the cap became %d essence and %d gold." % [essence, gold])
	return lines


## Fix pass Nov 7 (item 8): every card of an Open all, the new ones first (one tile per card; a copy past its cap stays, dimmed).
static func result_entries(openings: Array[PackOpening]) -> Array[PackOpening.Entry]:
	var fresh: Array[PackOpening.Entry] = []
	var rest: Array[PackOpening.Entry] = []
	var seen_new: Dictionary = {}
	for opening: PackOpening in openings:
		for entry: PackOpening.Entry in opening.entries:
			if entry.is_new and not seen_new.has(entry.card.id):
				seen_new[entry.card.id] = true
				fresh.append(entry)
			else:
				rest.append(entry)
	fresh.append_array(rest)
	return fresh


func _result_tile(entry: PackOpening.Entry) -> Control:
	var holder: Control = CardView.wrapped(entry.card, 0.5)
	holder.name = "Result_%s" % entry.card.id
	if entry.converted:
		holder.modulate = Color(0.6, 0.6, 0.66)
	if entry.is_new:
		var badge: Label = UIKit.label("NEW", &"", 20, Color("1d1408"), HORIZONTAL_ALIGNMENT_CENTER)
		badge.name = "NewBadge"
		badge.add_theme_font_override("font", UIStyle.font_bold())
		badge.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
		badge.position = Vector2(6, 6)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(badge)
	return holder


## Overnight Nov 7-8, Part 1.11: the Open-all grid's zoomed card (tests read it).
var open_all_preview: HoverPreview = null


func _show_open_all(openings: Array[PackOpening]) -> void:
	if openings.is_empty():
		return
	if AudioRegistry.has_id("STG-PACK-COMMON"):
		Audio.sting(&"STG-PACK-COMMON")
	var layer: Control = Control.new()
	layer.name = "OpenAllSummary"
	UIKit.full_rect(layer)
	layer.z_index = 200
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.8)
	UIKit.full_rect(shade)
	layer.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(1500, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	column.add_child(UIKit.label("Packs opened", &"HeadingLabel", 36, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	# Fix pass Nov 7 (item 8, C3 F4): the cards themselves, new ones first with a NEW badge, then the one-line totals.
	var lines: PackedStringArray = summary_lines(openings)
	var totals: Label = UIKit.label(lines[0], &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(totals)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "OpenAllCards"
	scroll.custom_minimum_size = Vector2(1460, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	# Overnight Nov 7-8, Part 1.11: the result cards are small - hovering one (or focusing it with the keyboard or a pad) shows it whole and
	# readable beside it, like the Deck Station's hover.
	var preview: HoverPreview = HoverPreview.new()
	preview.name = "OpenAllPreview"
	layer.add_child(preview)
	open_all_preview = preview
	for entry: PackOpening.Entry in result_entries(openings):
		var tile: Control = _result_tile(entry)
		var card: CardData = entry.card
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.focus_mode = Control.FOCUS_ALL
		tile.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
		tile.mouse_entered.connect(func() -> void: preview.show_for(tile, card))
		tile.mouse_exited.connect(preview.hide_preview)
		tile.focus_entered.connect(func() -> void:
			preview.show_for(tile, card)
			scroll.ensure_control_visible(tile))
		tile.focus_exited.connect(preview.hide_preview)
		grid.add_child(tile)
	var extra: PackedStringArray = []
	for index: int in range(1, lines.size()):
		if not lines[index].begins_with("[color=#ffcf70]New:") and not lines[index].begins_with("More copies:"):
			extra.append(lines[index])
	if not extra.is_empty():
		column.add_child(UIKit.label(" ".join(extra), &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if Session.toasts != null:
		Session.toasts.hold()  # Fix pass Nov 7 (item 8): no toast over the cards
		layer.tree_exiting.connect(func() -> void: Session.toasts.release())
	column.add_child(UIKit.label("Every card is in your collection now: build with them at the Deck Station (B).", &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var done: FancyButton = FancyButton.make("Done", &"PrimaryButton", Vector2(220, 56))
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.pressed.connect(func() -> void:
		layer.queue_free()
		_refresh())
	column.add_child(done)
	ConfirmKey.attach(layer, done)
	(func() -> void:
		if is_instance_valid(done) and done.focus_mode != Control.FOCUS_NONE and done.is_visible_in_tree():
			done.grab_focus()).call_deferred()  # keyboard mode keeps FancyButtons unfocusable (the old plain grab_focus warned)
