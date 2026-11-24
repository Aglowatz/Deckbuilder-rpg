class_name DraftScreen
extends OverlayScreen
## Draft mode, Phase 1 (docs/design/draft_mode.md): the draft host's table, one glass page with five faces that follow
## `Session.draft`:
##   the challenges (this zone's draft, the open draft with its Path choice, the fee) -> the pick screen (three options with hover
##   zoom, the reroll, the cost curve and the Path split, the equipment and item picks in the same flow) -> the deck builder (20 of
##   the 25, the 15 basics' split) -> the run (wins and losses, the next rival) -> the rewards (and the card to keep after a full win).
## Mouse and controller: every choice is a button (PadFocus is registered by OverlayScreen).

## The zone whose host opened the table ("" in Crosspath): which zone draft is on offer.
var zone_id: String = ""
## Set by the scene after a fight: `Session.pending_draft_result`.
var result: Dictionary = {}

const CARD_SCALE: float = 1.15
const DECK_SCALE: float = 0.52
const PATH_ORDER: Array[int] = [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]

var _open_paths: Array[int] = []
var _notice: String = ""


func _init() -> void:
	screen_title = "The Draft Table"
	title_icon_id = "ICON-UI-DECK"
	glass = true


func _build() -> void:
	_fill()


func _refresh() -> void:
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	for child: Node in header_extra.get_children():
		header_extra.remove_child(child)
		child.queue_free()
	_fill()
	PadFocus.register(self)


func _fill() -> void:
	var draft: DraftState = Session.draft
	if draft == null:
		_fill_challenges()
		return
	header_extra.add_child(UIKit.label(DraftChallenges.title(draft.challenge_id), &"", 36, GlassTheme.TITLE))
	match draft.phase:
		DraftState.PHASE_PICK:
			_fill_pick(draft)
		DraftState.PHASE_DECK:
			_fill_deck(draft)
		DraftState.PHASE_RUN:
			_fill_run(draft)
		_:
			_fill_done(draft)


func _text(text: String, size: int = 30, colour: Color = GlassTheme.TEXT) -> Label:
	var label: Label = UIKit.label(text, &"", size, colour)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _pane(lit: bool = false) -> PanelContainer:
	var pane: PanelContainer = PanelContainer.new()
	if GlassTheme.available():
		pane.add_theme_stylebox_override("panel", GlassTheme.pane(GlassTheme.SLATE, lit))
	return pane


func _button(text: String, node_name: String, action: Callable, size: Vector2 = Vector2(300, 66)) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, &"", size)
	button.name = node_name
	button.pressed.connect(action)
	return button


# ---- The challenges ---------------------------------------------------------------------------------------------------------------


func _fill_challenges() -> void:
	body.add_child(_text("Twenty-five picks, one of three each time. Five pieces of equipment and two items along the way. Then three fights with what you drafted: your own deck, gear and items stay at home.", 30, GlassTheme.SECONDARY))
	if not _notice.is_empty():
		body.add_child(_text(_notice, 30, GlassTheme.CAUTION))
	var ids: Array[String] = []
	if DraftChallenges.ZONES.has(zone_id):
		ids.append(DraftChallenges.zone_id_for(zone_id))
	if DraftChallenges.open_unlocked(Session.flags):
		ids.append(DraftChallenges.OPEN_ID)
	for id: String in ids:
		body.add_child(_challenge_row(id))
	if not DraftChallenges.open_unlocked(Session.flags):
		body.add_child(_text("The Open Draft (your choice of Path, repeatable) opens once you have won a zone draft.", 28, GlassTheme.SECONDARY))
	var won: int = DraftChallenges.zone_drafts_won(Session.flags)
	var tease: String = "Zone drafts won: %d of 4." % won
	if Session.flag(StringName(DraftChallenges.ARENA_FLAG)):
		tease += "  The Crosspath draft arena has heard of you. Its doors are being oiled; it opens soon."
	else:
		tease += "  Win all four and the Crosspath draft arena opens its doors."
	body.add_child(_text(tease, 28, GlassTheme.TITLE))


func _challenge_row(id: String) -> Control:
	var pane: PanelContainer = _pane(true)
	pane.name = "Challenge_%s" % id.replace(":", "_")
	var row: HBoxContainer = UIKit.hbox(18)
	pane.add_child(row)
	var words: VBoxContainer = UIKit.vbox(4)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	var won: bool = Session.flag(StringName(DraftChallenges.won_flag(id)))
	words.add_child(UIKit.label(DraftChallenges.title(id) + ("   (won)" if won else ""), &"", 42, GlassTheme.TITLE))
	words.add_child(_text(DraftChallenges.summary(id), 28))
	var fee: int = Session.draft_fee(id)
	var first: Dictionary = DraftChallenges.reward(3, true, not won)
	words.add_child(_text("Entry: %s.   Three wins pay %d gold and %d XP%s, and you keep one drafted card." % ["free (your first attempt)" if fee == 0 else "%d gold" % fee, int(first["gold"]), int(first["xp"]), "" if won else " (the first time)"], 28, GlassTheme.SECONDARY))
	if id == DraftChallenges.OPEN_ID:
		words.add_child(_path_choice())
	var start: FancyButton = _button("Start the draft", "Start_%s" % id.replace(":", "_"), func() -> void: _start(id))
	start.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	start.disabled = fee > Session.gold
	if start.disabled:
		start.tooltip_text = "You need %d gold." % fee
	row.add_child(start)
	return pane


func _path_choice() -> Control:
	var row: HBoxContainer = UIKit.hbox(10)
	var limit: int = DraftChallenges.max_open_paths(Session.flags)
	if _open_paths.is_empty() and Session.profile != null:
		_open_paths.append(int(Session.profile.primary_affinity) if int(Session.profile.primary_affinity) != 0 else PATH_ORDER[0])
	row.add_child(UIKit.label("Paths (%s):" % ("one" if limit == 1 else "up to %d" % limit), &"", 28, GlassTheme.TEXT))
	for path: int in PATH_ORDER:
		var toggle: FancyButton = FancyButton.make(Affinity.display_name(path as Affinity.Type), &"GhostButton", Vector2(230, 58))
		toggle.name = "Path_%d" % path
		toggle.toggle_mode = true
		toggle.button_pressed = _open_paths.has(path)
		toggle.pressed.connect(func() -> void: _toggle_path(path, limit))
		row.add_child(toggle)
	return row


func _toggle_path(path: int, limit: int) -> void:
	if _open_paths.has(path):
		if _open_paths.size() > 1:
			_open_paths.erase(path)
	elif limit <= 1:
		_open_paths = [path] as Array[int]
	elif _open_paths.size() < limit:
		_open_paths.append(path)
	_refresh()


func _start(id: String) -> void:
	_notice = ""
	if not Session.start_draft(id, _open_paths):
		_notice = "The draft could not start (not enough gold, or another draft is still on the table)."
	Audio.sfx(&"ui_confirm")
	_refresh()


# ---- The pick screen --------------------------------------------------------------------------------------------------------------


func _fill_pick(draft: DraftState) -> void:
	var kind: String = str(draft.offer.get("kind", ""))
	var head: HBoxContainer = UIKit.hbox(16)
	body.add_child(head)
	var title_text: String = "Pick %d of %d" % [int(draft.offer.get("pick", 1)), DraftRules.card_picks()]
	if kind == DraftEngine.KIND_CARD and bool(draft.offer.get("high", false)):
		title_text += "   -   a rare find: Epic and Legendary cards"
	elif kind == DraftEngine.KIND_EQUIPMENT:
		title_text = "Equipment %d of 5   -   choose your %s" % [int(draft.offer.get("pick", 1)), EquipmentData.slot_name(int(draft.offer.get("slot", 0)) as EquipmentData.Slot).to_lower()]
	elif kind == DraftEngine.KIND_ITEM:
		title_text = "Item %d of %d   -   one use in each fight" % [int(draft.offer.get("pick", 1)), DraftRules.item_slots()]
	var title_label: Label = UIKit.label(title_text, &"", 42, GlassTheme.TITLE)
	title_label.name = "PickTitle"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_label)
	var reroll: FancyButton = _button("Reroll (%d left)" % draft.rerolls_left, "Reroll", _reroll, Vector2(300, 60))
	reroll.disabled = draft.rerolls_left <= 0
	reroll.tooltip_text = "Three new options. One reroll per draft, for any offer."
	head.add_child(reroll)
	var split: HBoxContainer = UIKit.hbox(24)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var options: HBoxContainer = UIKit.hbox(26)
	options.name = "Options"
	options.alignment = BoxContainer.ALIGNMENT_CENTER
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(options)
	var ids: Array = draft.offer.get("options", []) as Array
	for index: int in range(ids.size()):
		options.add_child(_option(kind, str(ids[index]), index))
	split.add_child(_side_panel(draft))


func _option(kind: String, id: String, index: int) -> Control:
	var column: VBoxContainer = UIKit.vbox(10)
	column.name = "Option%d" % index
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	var label: String = "Take"
	match kind:
		DraftEngine.KIND_CARD:
			var card: CardData = Session.card_by_id(id)
			var view: Control = CardView.wrapped(card, CARD_SCALE)
			CardHoverZoom.attach(view)
			column.add_child(view)
			label = "Take %s" % card.display_name
		DraftEngine.KIND_EQUIPMENT:
			var piece: EquipmentData = Session.content.equipment_piece(id)
			column.add_child(_gear_pane(piece.source_name, "%s  -  %s" % [EquipmentData.slot_name(piece.slot), EquipmentRarity.display_name(int(piece.rarity))], piece.tooltip_text(), IconArt.equipment_texture(piece, 128.0) if IconArt.has_equipment_icon(piece) else null))
			label = "Take %s" % piece.source_name
		_:
			var item: ItemData = Session.content.item(id)
			column.add_child(_gear_pane(item.display_name, "Item  -  one use each fight", item.description, IconArt.item_texture(item, 128.0) if IconArt.has_item_icon(item) else null))
			label = "Take %s" % item.display_name
	var take: FancyButton = _button(label, "Take%d" % index, func() -> void: _pick(index), Vector2(345, 62))
	take.clip_text = true
	take.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(take)
	return column


func _gear_pane(title_text: String, kind_text: String, text: String, icon: Texture2D) -> Control:
	var pane: PanelContainer = _pane(true)
	pane.custom_minimum_size = Vector2(345, 517)
	var box: VBoxContainer = UIKit.vbox(10)
	pane.add_child(box)
	if icon != null:
		var picture: TextureRect = TextureRect.new()
		picture.texture = icon
		picture.custom_minimum_size = Vector2(128, 128)
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		box.add_child(picture)
	var name_label: Label = _text(title_text, 36, GlassTheme.TITLE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_label)
	var kind_label: Label = _text(kind_text, 26, GlassTheme.SECONDARY)
	kind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(kind_label)
	box.add_child(_text(text, 27))
	return pane


## The right-hand column of the pick screen: the cost curve, the Path split and what was drafted so far.
func _side_panel(draft: DraftState) -> Control:
	var pane: PanelContainer = _pane()
	pane.name = "DraftSoFar"
	pane.custom_minimum_size = Vector2(470, 0)
	var box: VBoxContainer = UIKit.vbox(8)
	pane.add_child(box)
	var cards: Array[CardData] = DraftEngine.picked_cards(Session.content, draft)
	box.add_child(UIKit.label("Your draft: %d of %d cards" % [cards.size(), DraftRules.card_picks()], &"", 30, GlassTheme.TITLE))
	box.add_child(UIKit.label("Cost curve", &"", 26, GlassTheme.SECONDARY))
	box.add_child(_curve(DraftEngine.curve_of(cards)))
	box.add_child(UIKit.label("Paths", &"", 26, GlassTheme.SECONDARY))
	var split: Dictionary = DraftEngine.path_split(cards)
	var paths_row: HBoxContainer = UIKit.hbox(8)
	paths_row.name = "PathSplit"
	box.add_child(paths_row)
	for path: int in draft.paths:
		paths_row.add_child(GlassTheme.path_tag(path as Affinity.Type, "%s %d" % [Affinity.display_name(path as Affinity.Type), int(split.get(path, 0))]) if GlassTheme.available() else UIKit.label("%s %d" % [Affinity.display_name(path as Affinity.Type), int(split.get(path, 0))], &"", 26))
	paths_row.add_child(UIKit.label("Pathless %d" % int(split.get(0, 0)), &"", 26, GlassTheme.TEXT))
	var units: int = 0
	for card: CardData in cards:
		units += 1 if card.is_unit() else 0
	box.add_child(UIKit.label("Units %d   -   other cards %d" % [units, cards.size() - units], &"", 26, GlassTheme.TEXT))
	box.add_child(UIKit.label("Equipment", &"", 26, GlassTheme.SECONDARY))
	if draft.equipment.is_empty():
		box.add_child(UIKit.label("none yet (after picks 4, 9, 14, 19, 23)", &"", 24, GlassTheme.SECONDARY))
	for id: String in draft.equipment:
		var piece: EquipmentData = Session.content.equipment_piece(id)
		var line: Label = UIKit.label("%s: %s" % [EquipmentData.slot_name(piece.slot), piece.source_name], &"", 25, GlassTheme.TEXT)
		line.tooltip_text = piece.tooltip_text()
		line.mouse_filter = Control.MOUSE_FILTER_STOP
		box.add_child(line)
	box.add_child(UIKit.label("Items", &"", 26, GlassTheme.SECONDARY))
	if draft.items.is_empty():
		box.add_child(UIKit.label("none yet (after picks 7 and 17)", &"", 24, GlassTheme.SECONDARY))
	for id: String in draft.items:
		var item: ItemData = Session.content.item(id)
		var line: Label = UIKit.label(item.display_name, &"", 25, GlassTheme.TEXT)
		line.tooltip_text = item.description
		line.mouse_filter = Control.MOUSE_FILTER_STOP
		box.add_child(line)
	return pane


## Seven bars, cost 0 to 6+, each with its count.
func _curve(counts: Array[int]) -> Control:
	var row: HBoxContainer = UIKit.hbox(6)
	row.name = "CostCurve"
	row.custom_minimum_size = Vector2(0, 150)
	var top: int = 1
	for count: int in counts:
		top = maxi(top, count)
	for bucket: int in range(counts.size()):
		var column: VBoxContainer = UIKit.vbox(2)
		column.alignment = BoxContainer.ALIGNMENT_END
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_child(UIKit.label(str(counts[bucket]), &"", 22, GlassTheme.TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		var bar: ColorRect = ColorRect.new()
		bar.color = GlassTheme.GOLD_LINE
		bar.custom_minimum_size = Vector2(30, 4.0 + 80.0 * float(counts[bucket]) / float(top))
		column.add_child(bar)
		column.add_child(UIKit.label("%d%s" % [bucket, "+" if bucket == counts.size() - 1 else ""], &"", 22, GlassTheme.SECONDARY, HORIZONTAL_ALIGNMENT_CENTER))
		row.add_child(column)
	return row


func _pick(index: int) -> void:
	if Session.draft_pick(index):
		Audio.sfx(&"ui_confirm")
	_refresh()


func _reroll() -> void:
	if Session.draft_reroll():
		Audio.sfx(&"ui_confirm")
	_refresh()


# ---- The deck builder -------------------------------------------------------------------------------------------------------------


func _fill_deck(draft: DraftState) -> void:
	var in_deck: int = draft.cards.size() - draft.bench.size()
	var head: HBoxContainer = UIKit.hbox(16)
	body.add_child(head)
	var count: Label = UIKit.label("Your deck: %d of %d drafted cards, and %d basic Infrastructure. Click a card to leave it out or bring it back." % [in_deck, DraftRules.deck_cards(), DraftRules.deck_basics()], &"", 30, GlassTheme.TEXT if DraftEngine.deck_ready(draft) else GlassTheme.CAUTION)
	count.name = "DeckCount"
	count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(count)
	var go: FancyButton = _button("Lock the deck and meet your rivals", "LockDeck", _begin_run, Vector2(560, 66))
	go.disabled = not DraftEngine.deck_ready(draft)
	head.add_child(go)
	var basics: HBoxContainer = UIKit.hbox(12)
	basics.name = "Basics"
	body.add_child(basics)
	basics.add_child(UIKit.label("Basic Infrastructure:", &"", 28, GlassTheme.SECONDARY))
	for path: int in draft.paths:
		var basic: CardData = Session.content.infrastructure.get(path) as CardData
		basics.add_child(UIKit.label("%s %d" % [basic.display_name if basic != null else Affinity.display_name(path as Affinity.Type), int(draft.basics.get(path, 0))], &"", 28, GlassTheme.TEXT))
		if draft.paths.size() > 1:
			var other: int = draft.paths[(draft.paths.find(path) + 1) % draft.paths.size()]
			basics.add_child(_button("+1", "BasicPlus_%d" % path, func() -> void: _move_basic(other, path), Vector2(80, 54)))
	basics.add_child(UIKit.label("   Cost curve of the 20:", &"", 28, GlassTheme.SECONDARY))
	var curve: Control = _curve(DraftEngine.curve_of(DraftEngine.deck_cards(Session.content, draft)))
	curve.custom_minimum_size = Vector2(420, 130)
	basics.add_child(curve)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if GlassTheme.available():
		GlassTheme.style_scroll(scroll)
	body.add_child(scroll)
	var grid: HFlowContainer = HFlowContainer.new()
	grid.name = "DeckGrid"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	for index: int in range(draft.cards.size()):
		grid.add_child(_deck_card(draft, index))


func _deck_card(draft: DraftState, index: int) -> Control:
	var card: CardData = Session.card_by_id(draft.cards[index])
	var benched: bool = draft.bench.has(index)
	var button: Button = Button.new()
	button.name = "DeckCard%d" % index
	button.flat = true
	button.custom_minimum_size = CardView.SIZE * DECK_SCALE
	button.tooltip_text = "%s: %s" % [card.display_name, "left out - click to bring it back" if benched else "in the deck - click to leave it out"]
	var view: Control = CardView.wrapped(card, DECK_SCALE)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(view)
	if benched:
		view.modulate = Color(0.45, 0.45, 0.55, 0.7)
	CardHoverZoom.attach(button, view)
	button.pressed.connect(func() -> void: _toggle(index))
	return button


func _toggle(index: int) -> void:
	if Session.draft != null and DraftEngine.toggle_bench(Session.draft, index):
		Session.save_game()
	_refresh()


func _move_basic(from: int, to: int) -> void:
	if Session.draft != null and DraftEngine.move_basic(Session.draft, from, to):
		Session.save_game()
	_refresh()


func _begin_run() -> void:
	if Session.draft_begin_run():
		Audio.sfx(&"ui_confirm")
	_refresh()


# ---- The run ----------------------------------------------------------------------------------------------------------------------


func _score(draft: DraftState) -> Label:
	var label: Label = UIKit.label("Wins %d of %d      Losses %d of %d" % [draft.wins, DraftRules.wins_to_finish(), draft.losses, DraftRules.losses_to_finish()], &"", 46, GlassTheme.TITLE)
	label.name = "Score"
	return label


func _fill_run(draft: DraftState) -> void:
	if not result.is_empty():
		var banner: Label = _text(("You beat %s." if bool(result.get("won", false)) else "%s beat you.") % str(result.get("enemy", "your rival")), 36, GlassTheme.GOOD if bool(result.get("won", false)) else GlassTheme.CAUTION)
		banner.name = "FightResult"
		body.add_child(banner)
	body.add_child(_score(draft))
	body.add_child(_text("Three fights at full HP each. Three wins take the prize; two losses end the run.", 28, GlassTheme.SECONDARY))
	var rivals: HBoxContainer = UIKit.hbox(18)
	rivals.name = "Rivals"
	body.add_child(rivals)
	var next: int = draft.fights_played()
	for index: int in range(draft.rivals.size()):
		var rival: Dictionary = draft.rivals[index]
		var pane: PanelContainer = _pane(index == mini(next, draft.rivals.size() - 1))
		pane.custom_minimum_size = Vector2(460, 420)
		pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box: VBoxContainer = UIKit.vbox(6)
		pane.add_child(box)
		var portrait: Texture2D = Portraits.texture_for(str(rival.get("npc_id", ""))) if Portraits.has_portrait(str(rival.get("npc_id", ""))) else null
		if portrait != null:
			var picture: TextureRect = TextureRect.new()
			picture.texture = portrait
			picture.custom_minimum_size = Vector2(230, 230)
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			box.add_child(picture)
		box.add_child(_text(str(rival.get("name", "")), 34, GlassTheme.TITLE))
		box.add_child(_text("%s: %s." % [str(rival.get("personality", "")).capitalize(), str(rival.get("title", ""))], 26))
		box.add_child(_text("%d HP" % int(rival.get("hp", 0)), 22, GlassTheme.SECONDARY))
		var worn: PackedStringArray = []
		for piece: ModifierSource in DraftRivals.equipment_sources(Session.content, rival):
			worn.append(piece.source_name)
		if not worn.is_empty():
			var gear_line: Label = _text("Wears: %s." % ", ".join(worn), 22, GlassTheme.SECONDARY)
			gear_line.name = "RivalGear"
			box.add_child(gear_line)
		if index < next:
			pane.modulate = Color(0.7, 0.7, 0.75)
		rivals.add_child(pane)
	var row: HBoxContainer = UIKit.hbox(16)
	body.add_child(row)
	var rival_name: String = str(DraftRun.next_rival(draft).get("name", "your rival"))
	row.add_child(_button("Fight %s" % rival_name, "Fight", _fight, Vector2(560, 70)))
	row.add_child(UIKit.filler())
	row.add_child(_button("Give up this draft", "GiveUp", _give_up, Vector2(330, 58)))


func _fight() -> void:
	Session.start_draft_fight()


func _give_up() -> void:
	Session.close_draft()
	result = {}
	_refresh()


# ---- The rewards ------------------------------------------------------------------------------------------------------------------


func _fill_done(draft: DraftState) -> void:
	var pay: Dictionary = draft.result
	var headline: String = "Three wins. The table is yours." if draft.full_win() else "The run is over: %d win%s." % [draft.wins, "" if draft.wins == 1 else "s"]
	var head: Label = UIKit.label(headline, &"", 50, GlassTheme.TITLE)
	head.name = "RunOver"
	body.add_child(head)
	body.add_child(_score(draft))
	var line: String = "You earned %d gold and %d XP." % [int(pay.get("gold", 0)), int(pay.get("xp", 0))]
	if bool(pay.get("first_win", false)):
		line += "  That includes the first-win prize for %s." % DraftChallenges.title(draft.challenge_id)
	var reward: Label = _text(line, 34, GlassTheme.GOOD)
	reward.name = "RewardLine"
	body.add_child(reward)
	if draft.full_win() and draft.kept_card.is_empty():
		body.add_child(_text("Keep one card you drafted. It goes into your collection.", 34))
		var scroll: ScrollContainer = ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		body.add_child(scroll)
		var grid: HFlowContainer = HFlowContainer.new()
		grid.name = "KeepGrid"
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(grid)
		var seen: Dictionary = {}
		for id: String in draft.cards:
			if seen.has(id):
				continue
			seen[id] = true
			var card: CardData = Session.card_by_id(id)
			var button: Button = Button.new()
			button.name = "Keep_%s" % id
			button.flat = true
			button.custom_minimum_size = CardView.SIZE * DECK_SCALE
			button.tooltip_text = "Keep %s" % card.display_name
			var view: Control = CardView.wrapped(card, DECK_SCALE)
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(view)
			CardHoverZoom.attach(button, view)
			button.pressed.connect(func() -> void: _keep(id))
			grid.add_child(button)
		return
	if not draft.kept_card.is_empty():
		var kept: CardData = Session.card_by_id(draft.kept_card)
		body.add_child(_text("You kept %s." % (kept.display_name if kept != null else draft.kept_card), 34))
	body.add_child(_button("Finish", "Finish", _finish, Vector2(340, 70)))


func _keep(card_id: String) -> void:
	if Session.draft_keep(card_id):
		Audio.sfx(&"ui_confirm")
	_refresh()


func _finish() -> void:
	Session.close_draft()
	result = {}
	_refresh()
