class_name DraftScreen
extends OverlayScreen
## Draft mode (docs/design/draft_mode.md): the draft table, a stained-glass page laid with green baize (UI-DRAFT-BG). Its faces
## follow `Session.draft`:
##   the pick screen (built from the owner's mock-up UI-DRAFT-MOCK-PICK: three large options that grow further on hover, the reroll,
##   and a side panel with the cost curve, the Paths, the equipment and the items so far) -> the deck builder (like the main one: the
##   drafted cards on the left, the whole deck with its checks, curve, stats and Infrastructure steppers on the right) -> the rewards
##   (and the card to keep after a full win).
## In a dungeon draft the same screen shows the pick of three after a fight, the Trade Counter and the Chained Vault (`dungeon_mode`).
## The challenges and the next-opponent reveal are `DraftHubScreen`'s; when the draft moves to one of its faces this screen asks
## its opener to `reopen`. Mouse and controller: every choice is a button (PadFocus is registered by OverlayScreen).

## The draft left this screen's faces (the run began, or there is no draft): the opener closes it and opens the right screen.
signal reopen

## The zone whose host opened the table ("" in Crosspath).
var zone_id: String = ""
## Set by the scene after a fight: `Session.pending_draft_result`.
var result: Dictionary = {}
## True on the dungeon map: only the offer on the table is shown, and the screen closes when it is resolved.
var dungeon_mode: bool = false

const PICK_SCALE: float = 1.36
## Fable Nov 24 (Part 3): the three options always fit side by side. In a window narrower than 16:9 the canvas is narrower
## too (1,570 px in the owner's window), and three cards at the full scale pushed the third off the page.
const PICK_SCALE_MIN: float = 0.72
const PICK_GAP: int = 22
const PAGE_MARGIN: float = 124.0
const SIDE_WIDTH_NARROW: float = 372.0
## The on-screen height (canvas px) an offered card grows to under the pointer (the owner: "cards enlarge more on hover").
const PICK_ZOOM_HEIGHT: float = 800.0
const GRID_SCALE: float = 0.56
const SWAP_SCALE: float = 0.34
const SIDE_WIDTH: float = 440.0
const DECK_PANEL_WIDTH: float = 500.0
const BAIZE_ID: String = "UI-DRAFT-BG"
const REROLL_ICON: String = "ICON-UI-REROLL"

var _notice: String = ""
## The dungeon pick: the option chosen (-1: none yet) and the deck card that leaves for it (-1: add without a swap).
var _chosen: int = -1
var _replace: int = -1
## The canvas width the pick screen was last laid out for (it is laid out again when the window's shape changes).
var _laid_out_for: float = 0.0
## The Trade Counter's and the pick's large card: the deck card under the pointer, shown whole and on top of everything.
var _swap_preview: Control = null


## The width of the canvas (1,920 at 16:9; less in a squarer window).
func canvas_width() -> float:
	return get_viewport_rect().size.x if is_inside_tree() and get_viewport_rect().size.x > 200.0 else 1920.0


## How wide the side panel is and how large the three options are drawn so that all three fit beside it.
func side_width() -> float:
	return SIDE_WIDTH if canvas_width() >= 1800.0 else SIDE_WIDTH_NARROW


func pick_scale(options: int = 3) -> float:
	return scale_for(canvas_width(), side_width(), options)


## The scale at which `options` cards fit side by side on a canvas `canvas` px wide, beside a side panel `side` px wide.
static func scale_for(canvas: float, side: float, options: int = 3) -> float:
	var room: float = canvas - PAGE_MARGIN - side - 22.0 - float(PICK_GAP * maxi(0, options - 1))
	return clampf(room / float(maxi(1, options)) / CardView.SIZE.x, PICK_SCALE_MIN, PICK_SCALE)


func _notification(what: int) -> void:
	# the window changed shape while the pick screen is up: lay the options out again so the third card never leaves the page
	if what == NOTIFICATION_RESIZED and _laid_out_for > 0.0 and absf(canvas_width() - _laid_out_for) > 24.0 and Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and not dungeon_mode:
		_laid_out_for = canvas_width()
		_refresh.call_deferred()


func _init() -> void:
	screen_title = "The Draft Table"
	title_icon_id = "ICON-UI-DECK"
	glass = true


func _build() -> void:
	_lay_baize()
	_fill()


## The green baize of the mock-up, inside the page's gold frame and under everything the page holds.
func _lay_baize() -> void:
	if not UiArt.has(BAIZE_ID) or not is_glass():
		return
	var baize: Control = DraftKit.backdrop(UiArt.texture(BAIZE_ID), 0.12)
	baize.name = "Baize"
	baize.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, GLASS_GAP + 22)
	baize.clip_contents = true
	add_child(baize)
	var page: Node = get_node_or_null("GlassPage")
	move_child(baize, page.get_index() + 1 if page != null else 0)


func _refresh() -> void:
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	for child: Node in header_extra.get_children():
		header_extra.remove_child(child)
		child.queue_free()
	_fill()
	UiInput.make_focusable(self)
	PadFocus.register(self)


func _fill() -> void:
	var draft: DraftState = Session.draft
	if draft == null:
		reopen.emit.call_deferred()
		return
	header_extra.add_child(UIKit.label(DraftChallenges.title(draft.challenge_id), &"", 36, GlassTheme.TITLE))
	var offer_kind: String = str(draft.offer.get("kind", ""))
	if offer_kind == DraftEngine.KIND_DUNGEON_PICK or offer_kind == DraftEngine.KIND_DUNGEON_TRADE:
		_fill_dungeon_pick(draft)
		return
	if dungeon_mode:
		closed.emit.call_deferred()
		return
	match draft.phase:
		DraftState.PHASE_PICK:
			_fill_pick(draft)
		DraftState.PHASE_DECK:
			_fill_deck(draft)
		DraftState.PHASE_RUN:
			reopen.emit.call_deferred()
		_:
			_fill_done(draft)


# ---- The pick screen (UI-DRAFT-MOCK-PICK) -----------------------------------------------------------------------------------------


func _fill_pick(draft: DraftState) -> void:
	var kind: String = str(draft.offer.get("kind", ""))
	_laid_out_for = canvas_width()
	var split: HBoxContainer = UIKit.hbox(22)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var left: VBoxContainer = UIKit.vbox(10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left)
	var head: HBoxContainer = UIKit.hbox(16)
	left.add_child(head)
	head.add_child(_pick_plaque(draft, kind))
	var note: Label = DraftKit.text(_pick_note(draft, kind), 26, DraftKit.CREAM)
	note.name = "PickNote"
	note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(note)
	var reroll: FancyButton = DraftKit.button("Reroll (%d left)" % draft.rerolls_left, "Reroll", _reroll, Vector2(330, 64))
	if IconArt.has(REROLL_ICON):
		reroll.icon = IconArt.texture(REROLL_ICON, 40.0)
		reroll.expand_icon = false
	reroll.disabled = draft.rerolls_left <= 0
	reroll.tooltip_text = "Three new options. One reroll per draft, for any offer."
	reroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(reroll)
	var options: HBoxContainer = UIKit.hbox(PICK_GAP)
	options.name = "Options"
	options.alignment = BoxContainer.ALIGNMENT_CENTER
	options.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(options)
	var ids: Array = draft.offer.get("options", []) as Array
	var scale_now: float = pick_scale(maxi(ids.size(), DraftRules.options()))
	options.set_meta(&"pick_scale", scale_now)
	for index: int in range(ids.size()):
		options.add_child(_option(kind, str(ids[index]), index, scale_now))
	if ids.size() < DraftRules.options():
		# one fewer only when the pool truly ran out, and the screen says so
		var short: Label = DraftKit.text("Only %d to choose from this time: the pool has nothing else left to offer." % ids.size(), 24, GlassTheme.CAUTION)
		short.name = "ShortOffer"
		short.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		left.add_child(short)
	split.add_child(_side_panel(draft))


## "Pick 12 of 25" on a dark plaque (the laurel pill of the mock-up).
func _pick_plaque(draft: DraftState, kind: String) -> Control:
	var words: String = "Pick %d of %d" % [int(draft.offer.get("pick", 1)), DraftRules.card_picks()]
	if kind == DraftEngine.KIND_EQUIPMENT:
		words = "Equipment %d of %d" % [int(draft.offer.get("pick", 1)), DraftRules.int_list("equipment_picks_after").size()]
	elif kind == DraftEngine.KIND_ITEM:
		words = "Item %d of %d" % [int(draft.offer.get("pick", 1)), DraftRules.item_slots()]
	var plaque: PanelContainer = DraftKit.plaque(0.92, DraftKit.NIGHT, DraftKit.MARQUEE, 30, 10.0)
	plaque.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var label: Label = UIKit.label("  %s  " % words, &"", 40, DraftKit.CREAM)
	label.name = "PickTitle"
	label.add_theme_font_override("font", UIStyle.font_bold())
	plaque.add_child(label)
	return plaque


func _pick_note(draft: DraftState, kind: String) -> String:
	if kind == DraftEngine.KIND_CARD and bool(draft.offer.get("high", false)):
		return "A rare find: Epic and Legendary cards."
	if kind == DraftEngine.KIND_EQUIPMENT:
		return "Choose your %s. You wear only what you draft." % EquipmentData.slot_name(int(draft.offer.get("slot", 0)) as EquipmentData.Slot).to_lower()
	if kind == DraftEngine.KIND_ITEM:
		return "Choose an item: one use in each fight."
	return "Take one of the three. Hover a card to read it."


func _option(kind: String, id: String, index: int, card_scale: float = PICK_SCALE) -> Control:
	var column: VBoxContainer = UIKit.vbox(10)
	column.name = "Option%d" % index
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	var size: Vector2 = CardView.SIZE * card_scale
	var tile: Button = Button.new()
	tile.name = "Card%d" % index
	tile.flat = true
	tile.custom_minimum_size = size
	tile.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tile.pressed.connect(func() -> void: _pick(index))
	var label: String = "Take"
	match kind:
		DraftEngine.KIND_CARD:
			var card: CardData = Session.card_by_id(id)
			var view: Control = CardView.wrapped(card, card_scale)
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(view)
			tile.tooltip_text = ""
			CardHoverZoom.set_height(tile, PICK_ZOOM_HEIGHT)
			CardHoverZoom.attach(tile)
			label = "Take %s" % card.display_name
		DraftEngine.KIND_EQUIPMENT:
			var piece: EquipmentData = Session.content.equipment_piece(id)
			var gear: Control = DraftKit.equipment_card(piece, size)
			gear.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(gear)
			label = "Take %s" % piece.source_name
		_:
			var item: ItemData = Session.content.item(id)
			var item_card: Control = DraftKit.item_card(item, size)
			item_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(item_card)
			label = "Take %s" % item.display_name
	column.add_child(tile)
	var take: FancyButton = DraftKit.button(label, "Take%d" % index, func() -> void: _pick(index), Vector2(size.x, 62))
	take.clip_text = true
	take.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(take)
	return column


## The right-hand panel of the pick screen: the cost curve, the Paths, the equipment and the items so far, what comes next.
func _side_panel(draft: DraftState) -> Control:
	var panel: PanelContainer = DraftKit.plaque(0.9)
	panel.name = "DraftSoFar"
	panel.custom_minimum_size = Vector2(side_width(), 0)
	panel.clip_contents = true
	var box: VBoxContainer = UIKit.vbox(10)
	panel.add_child(box)
	var cards: Array[CardData] = DraftEngine.picked_cards(Session.content, draft)
	box.add_child(DraftKit.chip("Cost curve   (%d of %d cards)" % [cards.size(), DraftRules.card_picks()]))
	box.add_child(DraftKit.curve(DraftEngine.curve_of(cards), 132.0))
	box.add_child(DraftKit.chip("Paths"))
	var split: Dictionary = DraftEngine.path_split(cards)
	# a flow, not a row: with three or four Paths the badges wrap instead of widening the panel (which pushed a card off the page)
	var paths_row: HFlowContainer = HFlowContainer.new()
	paths_row.name = "PathSplit"
	paths_row.add_theme_constant_override("h_separation", 12)
	paths_row.add_theme_constant_override("v_separation", 6)
	box.add_child(paths_row)
	for path: int in draft.paths:
		paths_row.add_child(DraftKit.path_badge(path, 46.0, true, int(split.get(path, 0))))
	paths_row.add_child(DraftKit.path_badge(int(Affinity.Type.NEUTRAL), 46.0, true, int(split.get(0, 0))))
	var units: int = 0
	for card: CardData in cards:
		units += 1 if card.is_unit() else 0
	box.add_child(UIKit.label("Units %d    Other cards %d" % [units, cards.size() - units], &"", 24, GlassTheme.TEXT))
	box.add_child(DraftKit.chip("Equipment"))
	var gear_row: HBoxContainer = UIKit.hbox(8)
	gear_row.name = "EquipmentSlots"
	box.add_child(gear_row)
	var gear_total: int = DraftRules.int_list("equipment_picks_after").size()
	for index: int in range(gear_total):
		var piece: EquipmentData = Session.content.equipment_piece(draft.equipment[index]) if index < draft.equipment.size() else null
		gear_row.add_child(DraftKit.icon_slot(DraftKit.equipment_icon(piece, 64.0), GearText.tooltip(piece) if piece != null else "An empty slot: equipment comes after picks %s." % _list_words(DraftRules.int_list("equipment_picks_after")), 72.0))
	box.add_child(DraftKit.chip("Items"))
	var item_row: HBoxContainer = UIKit.hbox(8)
	item_row.name = "ItemSlots"
	box.add_child(item_row)
	for index: int in range(DraftRules.item_slots()):
		var item: ItemData = Session.content.item(draft.items[index]) if index < draft.items.size() else null
		item_row.add_child(DraftKit.icon_slot(DraftKit.item_icon(item, 64.0), GearText.item_tooltip(item) if item != null else "An empty slot: items come after picks %s." % _list_words(DraftRules.int_list("item_picks_after")), 72.0))
	box.add_child(UIKit.filler())
	var next: PanelContainer = DraftKit.plaque(0.9, DraftKit.VELVET_DEEP, DraftKit.MARQUEE, 14, 12.0)
	next.name = "NextUp"
	var next_label: Label = DraftKit.text(_next_words(draft), 25, DraftKit.CREAM)
	next.add_child(next_label)
	box.add_child(next)
	return panel


static func _list_words(numbers: Array[int]) -> String:
	var parts: PackedStringArray = []
	for number: int in numbers:
		parts.append(str(number))
	if parts.size() <= 1:
		return "".join(parts)
	var last: String = parts[parts.size() - 1]
	parts.remove_at(parts.size() - 1)
	return "%s and %s" % [", ".join(parts), last]


## What the table brings after this pick: "Next: equipment", "Next: an item", "Next: a rare find", or the deck.
func _next_words(draft: DraftState) -> String:
	var steps: Array[Dictionary] = DraftEngine.schedule()
	if draft.step + 1 >= steps.size():
		return "Next: build your deck."
	var step: Dictionary = steps[draft.step + 1]
	match str(step["kind"]):
		DraftEngine.KIND_EQUIPMENT:
			return "Next: a piece of equipment."
		DraftEngine.KIND_ITEM:
			return "Next: an item."
	if DraftRules.high_rarity_every() > 0 and int(step["pick"]) % DraftRules.high_rarity_every() == 0:
		return "Next: a rare find (Epic and Legendary cards)."
	return "Next: pick %d of %d." % [int(step["pick"]), DraftRules.card_picks()]


func _pick(index: int) -> void:
	if Session.draft_pick(index):
		Audio.sfx(&"ui_confirm")
	_refresh()


func _reroll() -> void:
	if Session.draft_reroll():
		Audio.sfx(&"ui_confirm")
	_refresh()


# ---- The deck builder (it looks and works like the Deck Station's) ----------------------------------------------------------------


func _fill_deck(draft: DraftState) -> void:
	var split: HBoxContainer = UIKit.hbox(20)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var left: VBoxContainer = UIKit.vbox(8)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left)
	var hint: Label = DraftKit.text("Everything you drafted. Click a card to leave it out of the deck or bring it back: play as many of the %d as you like, as long as the deck has at least %d cards with its Infrastructure." % [draft.cards.size(), DraftRules.deck_min()], 26, DraftKit.CREAM)
	hint.name = "DeckHint"
	left.add_child(hint)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "DraftedScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if GlassTheme.available():
		GlassTheme.style_scroll(scroll)
	left.add_child(scroll)
	var grid: HFlowContainer = HFlowContainer.new()
	grid.name = "DeckGrid"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	for index: int in range(draft.cards.size()):
		grid.add_child(_deck_card(draft, index))
	grid.queue_sort.call_deferred()  # the first row was laid out before the scroll bar took its width
	split.add_child(_deck_panel(draft))


func _deck_card(draft: DraftState, index: int) -> Control:
	var card: CardData = Session.card_by_id(draft.cards[index])
	var benched: bool = draft.bench.has(index)
	var tile: Button = Button.new()
	tile.name = "DeckCard%d" % index
	tile.flat = true
	tile.custom_minimum_size = CardView.SIZE * GRID_SCALE
	tile.tooltip_text = "%s: %s" % [card.display_name, "left out - click to bring it back" if benched else "in the deck - click to leave it out"]
	var view: Control = CardView.wrapped(card, GRID_SCALE)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(view)
	if benched:
		view.modulate = Color(0.42, 0.42, 0.5, 0.75)
		var out: Label = UIKit.label("left out", &"", 22, GlassTheme.CAUTION, HORIZONTAL_ALIGNMENT_CENTER)
		out.add_theme_font_override("font", UIStyle.font_bold())
		out.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 8)
		out.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(out)
	CardHoverZoom.attach(tile)
	tile.pressed.connect(func() -> void: _toggle(index))
	return tile


## The deck column: the whole deck with its checks, cost curve and stats, the Infrastructure steppers, the list by type, and the
## lock button (the Deck Station's column, for a drafted deck).
func _deck_panel(draft: DraftState) -> Control:
	var panel: PanelContainer = DraftKit.plaque(0.94, Color("120f26"), GlassTheme.GOLD_LINE, 12, 12.0)
	panel.name = "DeckPanel"
	panel.custom_minimum_size = Vector2(DECK_PANEL_WIDTH, 0)
	var column: VBoxContainer = UIKit.vbox(6)
	panel.add_child(column)
	var deck: Deck = DraftEngine.build_deck(Session.content, draft)
	var spells: Array[CardData] = DraftEngine.deck_cards(Session.content, draft)
	var ready: bool = DraftEngine.deck_ready(draft)
	var name_row: HBoxContainer = UIKit.hbox(8)
	column.add_child(name_row)
	var name_label: Label = UIKit.label("Your Draft Deck", &"HeadingLabel", 30, GlassTheme.TITLE)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_label)
	var count: Label = UIKit.label("%d cards" % deck.cards.size(), &"", 30, GlassTheme.GOOD if ready else GlassTheme.CAUTION)
	count.name = "DeckCount"
	count.add_theme_font_override("font", UIStyle.font_bold())
	name_row.add_child(count)
	var rules_row: HBoxContainer = UIKit.hbox(10)
	rules_row.name = "RulesRow"
	column.add_child(rules_row)
	var checks: VBoxContainer = UIKit.vbox(2)
	checks.name = "RuleChecks"
	checks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_row.add_child(checks)
	checks.add_child(_check(deck.cards.size() >= DraftRules.deck_min(), "At least %d cards (%d now)" % [DraftRules.deck_min(), deck.cards.size()]))
	checks.add_child(_check(not spells.is_empty(), "Drafted cards in the deck: %d of %d" % [spells.size(), draft.cards.size()]))
	checks.add_child(_check(true, "Infrastructure: %d" % DraftEngine.basics_total(draft)))
	var chart: DeckCurveChart = DeckCurveChart.new()
	chart.name = "CostCurve"
	chart.custom_minimum_size = Vector2(190, 92)
	chart.set_curve(DeckInsights.cost_curve(spells))
	rules_row.add_child(chart)
	var stats: Label = DraftKit.text(_stats_line(spells), 22, GlassTheme.SECONDARY)
	stats.name = "DeckStats"
	column.add_child(stats)
	var problem: String = DraftEngine.deck_problem(draft)
	if not problem.is_empty():
		var warning: Label = DraftKit.text(problem, 23, GlassTheme.CAUTION)
		warning.name = "DeckProblem"
		column.add_child(warning)
	column.add_child(_group_header("Basic Infrastructure  %d" % DraftEngine.basics_total(draft)))
	for path: int in draft.paths:
		column.add_child(_basic_row(draft, path))
	var frame: PanelContainer = PanelContainer.new()
	frame.name = "DeckListFrame"
	var list_box: StyleBoxFlat = UIStyle.box(Color(0, 0, 0, 0.32), Color(1, 1, 1, 0.08), 1, 8)
	list_box.set_content_margin_all(4.0)
	frame.add_theme_stylebox_override("panel", list_box)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(frame)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "DeckListScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if GlassTheme.available():
		GlassTheme.style_scroll(scroll)
	frame.add_child(scroll)
	var list: VBoxContainer = UIKit.vbox(2)
	list.name = "DeckList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for group: Array in DeckbuilderScreen.list_groups(spells):
		var spec: Array = DeckbuilderScreen.LIST_GROUPS[int(group[0])]
		list.add_child(_group_header("%s  %d" % [str(spec[1]), int(group[1])]))
		for entry: Array in group[2]:
			list.add_child(_list_row(draft, entry[0] as CardData, int(entry[1])))
	var buttons: HBoxContainer = UIKit.hbox(8)
	buttons.name = "DeckButtons"
	column.add_child(buttons)
	var auto: FancyButton = DraftKit.button("Suggested deck", "SuggestDeck", _suggest, Vector2(190, 58))
	auto.tooltip_text = "Back to the suggested deck: the best 20 of your picks and 15 basic Infrastructure split by your Paths."
	buttons.add_child(auto)
	var go: FancyButton = DraftKit.button("Lock the deck", "LockDeck", _begin_run, Vector2(270, 62), &"PrimaryButton")
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.disabled = not ready
	go.tooltip_text = problem if not ready else "Lock this deck and meet what waits for it."
	buttons.add_child(go)
	return panel


func _check(ok: bool, words: String) -> Control:
	var row: HBoxContainer = UIKit.hbox(6)
	var mark: Label = UIKit.label("OK" if ok else "!!", &"", 18, GlassTheme.GOOD if ok else GlassTheme.CAUTION)
	mark.add_theme_font_override("font", UIStyle.font_bold())
	mark.custom_minimum_size = Vector2(30, 0)
	row.add_child(mark)
	row.add_child(UIKit.label(words, &"", 21, GlassTheme.TEXT if ok else GlassTheme.CAUTION))
	return row


func _stats_line(cards: Array[CardData]) -> String:
	var units: int = 0
	var total_cost: int = 0
	for card: CardData in cards:
		units += 1 if card.is_unit() else 0
		total_cost += card.energy_value()
	var average: float = float(total_cost) / float(maxi(1, cards.size()))
	return "Units %d    Other cards %d    Average cost %.1f" % [units, cards.size() - units, average]


func _group_header(words: String) -> Control:
	var label: Label = UIKit.label(words, &"", 20, GlassTheme.GOLD_LINE.lightened(0.25))
	label.add_theme_font_override("font", UIStyle.font_bold())
	return label


func _row_frame(row_name: String) -> Array:
	var row: PanelContainer = PanelContainer.new()
	row.name = row_name
	var plain: StyleBoxFlat = UIStyle.box(Color(1, 1, 1, 0.06), Color(0, 0, 0, 0), 0, 5)
	plain.content_margin_left = 6.0
	plain.content_margin_right = 4.0
	plain.content_margin_top = 1.0
	plain.content_margin_bottom = 1.0
	row.add_theme_stylebox_override("panel", plain)
	row.custom_minimum_size = Vector2(0, 34)
	var line: HBoxContainer = UIKit.hbox(6)
	row.add_child(line)
	return [row, line]


func _step(symbol: String, node_name: String, action: Callable, tip: String) -> Button:
	var made: Button = Button.new()
	made.name = node_name
	made.text = symbol
	made.custom_minimum_size = Vector2(38, 30)
	made.add_theme_font_size_override("font_size", 22)
	made.tooltip_text = tip
	made.pressed.connect(action)
	return made


## One kind of basic Infrastructure with its count and the - / + steppers (the owner: "the player sets the amount of each kind").
func _basic_row(draft: DraftState, path: int) -> Control:
	var basic: CardData = Session.content.infrastructure.get(path) as CardData
	var parts: Array = _row_frame("Basic_%d" % path)
	var line: HBoxContainer = parts[1] as HBoxContainer
	var symbol: TextureRect = IconArt.rect(IconArt.energy_id(path as Affinity.Type), 26.0)
	if symbol != null:
		symbol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(symbol)
	var name_label: Label = UIKit.label(basic.display_name if basic != null and not basic.display_name.is_empty() else "%s Infrastructure" % Affinity.display_name(path as Affinity.Type), &"", 23, GlassTheme.TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	line.add_child(name_label)
	line.add_child(_step("-", "BasicMinus_%d" % path, func() -> void: _add_basic(path, -1), "One fewer"))
	var count: Label = UIKit.label("x%d" % int(draft.basics.get(path, 0)), &"", 24, GlassTheme.TITLE, HORIZONTAL_ALIGNMENT_CENTER)
	count.name = "Count"
	count.custom_minimum_size = Vector2(52, 0)
	line.add_child(count)
	line.add_child(_step("+", "BasicPlus_%d" % path, func() -> void: _add_basic(path, 1), "One more"))
	return parts[0] as Control


## A card of the deck: its cost, its name, its copies, and a - that leaves one copy out.
func _list_row(draft: DraftState, card: CardData, copies: int) -> Control:
	var parts: Array = _row_frame("Row_%s" % card.id)
	var row: PanelContainer = parts[0] as PanelContainer
	var line: HBoxContainer = parts[1] as HBoxContainer
	var cost: Label = UIKit.label(str(card.energy_value()), &"", 20, GlassTheme.INK, HORIZONTAL_ALIGNMENT_CENTER)
	cost.custom_minimum_size = Vector2(28, 28)
	cost.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost.add_theme_font_override("font", UIStyle.font_bold())
	cost.add_theme_stylebox_override("normal", UIStyle.box(Color("cdc5d6"), Color(0, 0, 0, 0), 0, 14))
	line.add_child(cost)
	var own: Array[Affinity.Type] = card.paths()
	if own.is_empty():
		own = [Affinity.Type.NEUTRAL]
	for path: Affinity.Type in own:
		var symbol: TextureRect = IconArt.rect(IconArt.energy_id(path), 24.0)
		if symbol != null:
			symbol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line.add_child(symbol)
	var name_label: Label = UIKit.label(card.display_name, &"", 23, GlassTheme.TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	line.add_child(name_label)
	line.add_child(UIKit.label("x%d" % copies, &"", 23, GlassTheme.TITLE))
	line.add_child(_step("-", "Minus", func() -> void: _leave_out(card.id), "Leave one copy out of the deck"))
	row.tooltip_text = card.rules_text
	return row


func _toggle(index: int) -> void:
	Session.draft_toggle_card(index)
	_refresh()


## Leaves out the last copy of `card_id` that is in the deck.
func _leave_out(card_id: String) -> void:
	var draft: DraftState = Session.draft
	if draft == null:
		return
	for index: int in range(draft.cards.size() - 1, -1, -1):
		if draft.cards[index] == card_id and not draft.bench.has(index):
			Session.draft_toggle_card(index)
			break
	_refresh()


func _add_basic(path: int, delta: int) -> void:
	Session.draft_add_basic(path, delta)
	_refresh()


func _suggest() -> void:
	if Session.draft != null and Session.draft.phase == DraftState.PHASE_DECK:
		DraftEngine.auto_deck(Session.content, Session.draft)
		Session.save_game()
	_refresh()


func _begin_run() -> void:
	if Session.draft_begin_run():
		Audio.sfx(&"ui_confirm")
	_refresh()


# ---- The rewards ------------------------------------------------------------------------------------------------------------------


func _fill_done(draft: DraftState) -> void:
	# Fable Nov 24 (Part 3): the result is the hub's standard pop-up (`DraftHubScreen.result_summary`); this table shows only the
	# cards to choose the kept one from. There is nothing to choose: hand over to the pop-up at once.
	if not DraftHubScreen.needs_keep(draft):
		reopen.emit.call_deferred()
		return
	var pay: Dictionary = draft.result
	var headline: String = ""
	if draft.is_dungeon():
		var place: String = str(pay.get("dungeon", "the dungeon"))
		headline = "%s is cleared. Take a bow!" % place if draft.full_win() else "The run through %s is over." % place
	else:
		headline = "Three wins. The table is yours." if draft.full_win() else "The run is over: %d win%s." % [draft.wins, "" if draft.wins == 1 else "s"]
	var head: Label = UIKit.label(headline, &"", 50, GlassTheme.TITLE)
	head.name = "RunOver"
	body.add_child(head)
	if draft.is_dungeon():
		body.add_child(DraftKit.text("Fights won: %d." % draft.fights_won, 32, DraftKit.CREAM))
	else:
		var score: Label = UIKit.label("Wins %d of %d      Losses %d of %d" % [draft.wins, DraftChallenges.wins_to_finish(draft.challenge_id), draft.losses, DraftChallenges.losses_to_finish(draft.challenge_id)], &"", 42, DraftKit.CREAM)
		score.name = "Score"
		body.add_child(score)
	var line: String = "You earned %s." % DraftKit.reward_words(pay)
	if bool(pay.get("first_win", false)):
		line += "  That includes the first-win prize for %s." % DraftChallenges.title(draft.challenge_id)
	var reward: Label = DraftKit.text(line, 34, GlassTheme.GOOD)
	reward.name = "RewardLine"
	body.add_child(reward)
	if draft.full_win() and draft.kept_card.is_empty():
		body.add_child(DraftKit.text("Keep one card of your drafted deck. It goes into your collection.", 34, DraftKit.CREAM))
		var scroll: ScrollContainer = ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		if GlassTheme.available():
			GlassTheme.style_scroll(scroll)
		body.add_child(scroll)
		# Fable Nov 24: a draft's cards fit the page without scrolling, so the list does not clip: the card under the pointer grows
		# whole (the first card of the row was cut off at the list's left and top edges).
		scroll.clip_contents = draft.cards.size() > 36
		var grid: HFlowContainer = HFlowContainer.new()
		grid.name = "KeepGrid"
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		scroll.add_child(grid)
		var seen: Dictionary = {}
		for id: String in draft.cards:
			if seen.has(id):
				continue
			seen[id] = true
			var card: CardData = Session.card_by_id(id)
			var tile: Button = Button.new()
			tile.name = "Keep_%s" % id
			tile.flat = true
			tile.custom_minimum_size = CardView.SIZE * GRID_SCALE
			# Fable Nov 24: no tooltip here: it lay across the grown card (the line above the list says what a click does)
			var view: Control = CardView.wrapped(card, GRID_SCALE)
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(view)
			CardHoverZoom.attach(tile)
			tile.pressed.connect(func() -> void: _keep(id))
			grid.add_child(tile)
		return
	if not draft.kept_card.is_empty():
		var kept: CardData = Session.card_by_id(draft.kept_card)
		body.add_child(DraftKit.text("You kept %s." % (kept.display_name if kept != null else draft.kept_card), 34, DraftKit.CREAM))
	body.add_child(UIKit.filler())
	body.add_child(DraftKit.button("Finish", "Finish", _finish, Vector2(340, 70), &"PrimaryButton"))


func _keep(card_id: String) -> void:
	if Session.draft_keep(card_id):
		Audio.sfx(&"ui_confirm")
		reopen.emit()  # on to the result pop-up, with the kept card shown as a card
		return
	_refresh()


func _finish() -> void:
	Session.close_draft()
	result = {}
	reopen.emit()


# ---- A dungeon draft: the pick of three after a fight, the Trade Counter, the Chained Vault ---------------------------------------


func _fill_dungeon_pick(draft: DraftState) -> void:
	var trade: bool = str(draft.offer.get("kind", "")) == DraftEngine.KIND_DUNGEON_TRADE
	var ids: Array = draft.offer.get("options", []) as Array
	var title_words: String = "The Trade Counter: take one of these for a card of your deck." if trade else ("A champion's prize: take one of three." if bool(draft.offer.get("high", false)) else "The fight is won: take one of three.")
	var head: Label = UIKit.label(title_words, &"", 40, GlassTheme.TITLE)
	head.name = "DungeonPickTitle"
	body.add_child(head)
	body.add_child(DraftKit.text("Choose a card, then add it to your deck, or click a card of your deck below to swap that one out for it. Or pass." if not trade else "Choose a card, then click the card of your deck below that you give up for it. Or walk on.", 26, DraftKit.CREAM))
	var options: HBoxContainer = UIKit.hbox(26)
	options.name = "Options"
	options.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(options)
	for index: int in range(ids.size()):
		var card: CardData = Session.card_by_id(str(ids[index]))
		var tile: Button = Button.new()
		tile.name = "Card%d" % index
		tile.flat = true
		tile.toggle_mode = true
		tile.button_pressed = index == _chosen
		tile.custom_minimum_size = CardView.SIZE * 0.9
		var view: Control = CardView.wrapped(card, 0.9)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		view.modulate = Color.WHITE if (_chosen < 0 or index == _chosen) else Color(0.55, 0.55, 0.62)
		tile.add_child(view)
		tile.z_index = 2  # an option grows over the deck below it, never under
		CardHoverZoom.set_height(tile, 640.0)
		CardHoverZoom.attach(tile)
		tile.pressed.connect(func() -> void:
			_chosen = index
			_refresh())
		options.add_child(tile)
	body.add_child(DraftKit.chip("Your deck (%d drafted cards in it)" % (draft.cards.size() - draft.bench.size())))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "SwapScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if GlassTheme.available():
		GlassTheme.style_scroll(scroll)
	body.add_child(scroll)
	var grid: HFlowContainer = HFlowContainer.new()
	grid.name = "SwapGrid"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)
	for index: int in range(draft.cards.size()):
		if draft.bench.has(index):
			continue
		var card: CardData = Session.card_by_id(draft.cards[index])
		var tile: Button = Button.new()
		tile.name = "Swap%d" % index
		tile.flat = true
		tile.custom_minimum_size = CardView.SIZE * SWAP_SCALE
		var view: Control = CardView.wrapped(card, SWAP_SCALE)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		view.modulate = Color(1.0, 0.6, 0.55) if index == _replace else Color.WHITE
		tile.add_child(view)
		if index == _replace:
			var out: Label = UIKit.label("leaves", &"", 20, GlassTheme.CAUTION, HORIZONTAL_ALIGNMENT_CENTER)
			out.add_theme_font_override("font", UIStyle.font_bold())
			out.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 4)
			out.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.add_child(out)
		# Fable Nov 24 (Part 3): the card under the pointer was grown in place, inside the scrolling list, so the list cut it off
		# and its "Swap X out" tooltip lay across it. It is shown whole in a layer of its own now, with the label clear of it.
		var words: String = "Swap %s out" % card.display_name
		tile.mouse_entered.connect(func() -> void: show_swap_preview(card, tile, words))
		tile.focus_entered.connect(func() -> void: show_swap_preview(card, tile, words))
		tile.mouse_exited.connect(hide_swap_preview)
		tile.focus_exited.connect(hide_swap_preview)
		tile.pressed.connect(func() -> void:
			_replace = -1 if _replace == index else index
			hide_swap_preview()
			_refresh())
		grid.add_child(tile)
	var row: HBoxContainer = UIKit.hbox(14)
	body.add_child(row)
	var picked: CardData = Session.card_by_id(str(ids[_chosen])) if _chosen >= 0 and _chosen < ids.size() else null
	var leaving: CardData = Session.card_by_id(draft.cards[_replace]) if _replace >= 0 and _replace < draft.cards.size() else null
	var words: String = "Choose a card first"
	if picked != null and leaving != null:
		words = "Swap %s for %s" % [leaving.display_name, picked.display_name]
	elif picked != null:
		words = "Choose the card you give up" if trade else "Add %s to the deck" % picked.display_name
	var take: FancyButton = DraftKit.button(words, "TakePick", _take_dungeon_pick, Vector2(760, 66), &"PrimaryButton")
	take.clip_text = true
	take.disabled = picked == null or (trade and leaving == null)
	row.add_child(take)
	row.add_child(UIKit.filler())
	row.add_child(DraftKit.button("Take nothing" if not trade else "Walk on", "PassPick", _pass_dungeon_pick, Vector2(300, 62)))


## The large card of the deck card under the pointer: whole, on top of every other thing on the page, beside or above the small
## card it belongs to and inside the screen; its "Swap X out" label on a plate of its own under it, never across it.
func show_swap_preview(card: CardData, tile: Control, words: String) -> void:
	hide_swap_preview()
	if card == null or tile == null or not is_inside_tree():
		return
	var holder: Control = Control.new()
	holder.name = "SwapPreview"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = 140
	holder.top_level = true
	var view: Control = CardView.wrapped(card, SWAP_PREVIEW_SCALE)
	view.name = "Card"
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(view)
	var plate: PanelContainer = DraftKit.plaque(0.96, DraftKit.NIGHT, DraftKit.MARQUEE, 12, 8.0)
	plate.name = "Plate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label: Label = UIKit.label(words, &"", 26, DraftKit.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Words"
	label.add_theme_font_override("font", UIStyle.font_bold())
	plate.add_child(label)
	holder.add_child(plate)
	add_child(holder)
	_swap_preview = holder
	var card_size: Vector2 = CardView.SIZE * SWAP_PREVIEW_SCALE
	var plate_height: float = 52.0
	var screen: Vector2 = get_viewport_rect().size
	var anchor: Rect2 = tile.get_global_rect()
	# above the small card when there is room for the card and its plate, else to the side that has room
	var spot: Vector2 = Vector2(anchor.get_center().x - card_size.x * 0.5, anchor.position.y - card_size.y - plate_height - 14.0)
	if spot.y < 8.0:
		spot.y = clampf(anchor.get_center().y - card_size.y * 0.5, 8.0, maxf(8.0, screen.y - card_size.y - plate_height - 14.0))
		spot.x = anchor.end.x + 16.0 if anchor.end.x + 16.0 + card_size.x < screen.x - 8.0 else anchor.position.x - card_size.x - 16.0
	spot.x = clampf(spot.x, 8.0, maxf(8.0, screen.x - card_size.x - 8.0))
	holder.global_position = spot
	holder.size = card_size + Vector2(0.0, plate_height + 6.0)
	view.position = Vector2.ZERO
	plate.position = Vector2(0.0, card_size.y + 6.0)
	plate.custom_minimum_size = Vector2(card_size.x, plate_height)
	plate.size = Vector2(card_size.x, plate_height)


func hide_swap_preview() -> void:
	if _swap_preview != null and is_instance_valid(_swap_preview):
		_swap_preview.queue_free()
	_swap_preview = null


const SWAP_PREVIEW_SCALE: float = 0.9


func _take_dungeon_pick() -> void:
	if Session.draft_dungeon_pick(_chosen, _replace):
		Audio.sfx(&"ui_confirm")
		_chosen = -1
		_replace = -1
		closed.emit()
		return
	_refresh()


func _pass_dungeon_pick() -> void:
	Session.draft_dungeon_pick(-1)
	_chosen = -1
	_replace = -1
	closed.emit()


## Esc (or the close button) on a dungeon pick passes: the offer never stays on the table.
func request_close() -> void:
	if dungeon_mode and Session.draft != null and not Session.draft.offer.is_empty():
		Session.draft_dungeon_pick(-1)
	super.request_close()
