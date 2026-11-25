class_name DraftHubScreen
extends OverlayScreen
## Fable big pass Nov 23: where a draft is chosen and where its run is watched, on a full-screen picture (not the glass page):
##   - **Trey Pickett's cart** in a Path zone (VS-TREY): that zone's draft and nothing else (the owner, Nov 23).
##   - **The Shuffle House** in Crosspath (UI-DRAFT-HALL), in the look of the mock-up UI-DRAFT-MOCK-ARENA. Fable Nov 24: the grid
##     of seventeen tiles is FOUR MODES, each a big clear choice (Classic Draft, Dungeon Draft, Mystery Mini, High Rollers Draft),
##     with the Draft of the Day under Classic and the Shuffled Halls' door under them all; Octavia Eightfold presents on the
##     left; the chosen mode's choices (your Paths as big toggles, which dungeon), its rewards and Start below.
##   - **The result of a finished draft**: the game's standard reward box over the house (not an empty table).
##   - **The next opponent** (UI-DRAFT-MOCK-VERSUS): before each fight the rival stands large in the middle, with your deck on the
##     left and what they drafted and wear on the right, then Fight.
##   - **The dungeon door** of a dungeon draft: its map in the middle, then Enter.
## The pick screen, the deck builder and the rewards are `DraftScreen`'s: when the draft moves there this screen asks to `reopen`.

signal reopen

## The zone whose host opened the table ("" in Crosspath: the Shuffle House).
var zone_id: String = ""
## Set by the scene after a fight: `Session.pending_draft_result`.
var result: Dictionary = {}

const ZONE_BACKDROP: String = "VS-TREY"
const HALL_BACKDROP: String = "UI-DRAFT-HALL"
const MODE_TILE: Vector2 = Vector2(318, 250)
const DOOR_HEIGHT: float = 92.0
const PATH_TOGGLE: Vector2 = Vector2(216, 92)
## The menu's choices beside the four modes of `DraftArena.MODES`, and the Dungeon Draft's Random option.
const DAILY: String = "daily"
const HALLS: String = "halls"
const RANDOM: String = "random"

## The arena menu: the mode chosen (one of `DraftArena.MODES`, DAILY or HALLS), the Paths switched on, the Dungeon Draft's
## dungeon (a `MainDungeons` key, or RANDOM), and the last reason a draft could not start.
var _mode: String = ""
var _dungeon: String = ""
## The menu's layout for the canvas it was built on: the size of a mode tile, whether Octavia stands beside the board, and the
## canvas width it was laid out for (it is laid out again when the window's shape changes).
var _tile: Vector2 = MODE_TILE
var _side_host: bool = true
var _laid_out_for: float = 0.0
## The pop-ups this screen opens: "too many Paths" and the result of a finished draft. They live beside the screen (in its
## parent), not inside it: the screen is scaled to the UI scale, and a pop-up inside it dimmed only part of the window.
var limit_popup: PopupFrame = null
var result_popup: RewardPopup = null
const PAGE_MARGIN: float = 96.0
var _paths: Array[int] = []
var _notice: String = ""
var _review: bool = false


func _init() -> void:
	screen_title = "The Draft Table"
	title_icon_id = "ICON-UI-DECK"


func in_arena() -> bool:
	return not DraftChallenges.ZONES.has(zone_id)


## The width of the canvas (1,920 at 16:9; less in a squarer window).
func canvas_width() -> float:
	return get_viewport_rect().size.x if is_inside_tree() and get_viewport_rect().size.x > 200.0 else 1920.0


## Where this screen's pop-ups go: beside it (its parent), so they cover the whole window whatever the UI scale.
func _popup_host() -> Node:
	return get_parent() if get_parent() != null else self


func _exit_tree() -> void:
	for popup: Node in [limit_popup, result_popup]:
		if popup != null and is_instance_valid(popup):
			popup.queue_free()
	limit_popup = null
	result_popup = null
	super._exit_tree()


## The controller starts on the chosen mode's tile in the menu (not on the Close button); the other faces start as usual.
func pad_first_focus() -> Control:
	if Session.draft == null and in_arena():
		var tile: Control = find_child("Mode_%s" % _mode, true, false) as Control
		if tile != null:
			return tile
	return UiInput.focus_first(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _laid_out_for > 0.0 and absf(canvas_width() - _laid_out_for) > 24.0 and Session.draft == null and in_arena():
		_laid_out_for = canvas_width()
		_refresh.call_deferred()


## The draft screen for the moment, opened at Trey's cart in `zone` ("" = the Shuffle House): this hub while a draft is being
## chosen or its run is on, the draft table (`DraftScreen`) for the picks, the deck and the rewards. Both emit `closed` and
## `reopen` (the draft moved to the other screen's faces: the opener closes this one and asks again).
static func for_state(zone: String, fight_result: Dictionary) -> OverlayScreen:
	var draft: DraftState = Session.draft
	if shows(draft):
		var hub: DraftHubScreen = DraftHubScreen.new()
		hub.zone_id = zone
		hub.result = fight_result
		return hub
	var table: DraftScreen = DraftScreen.new()
	table.zone_id = zone
	table.result = fight_result
	return table


func _build() -> void:
	if GlassTheme.available():
		GlassTheme.apply(self)
	var id: String = HALL_BACKDROP if in_arena() else ZONE_BACKDROP
	var picture: Texture2D = UiArt.texture(id) if UiArt.has(id) else (KeyArt.texture(id) if KeyArt.has(id) else null)
	if picture != null:
		var backdrop: Control = DraftKit.backdrop(picture, 0.2)
		add_child(backdrop)
		# just under the content (the last child before this one): over the screen's own shade and glow
		move_child(backdrop, maxi(0, get_child_count() - 2))
	if title_label != null:
		title_label.text = "The Shuffle House" if in_arena() else "Trey Pickett's Draft Cart"
	_fill()


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
		if in_arena():
			_fill_arena()
		else:
			_fill_zone()
		return
	if not shows(draft):
		reopen.emit.call_deferred()
		return
	if draft.phase == DraftState.PHASE_DONE:
		# Fable Nov 24 (Part 3): the finished draft's result is a standard pop-up over the house (it was an empty green table)
		_fill_result.call_deferred(draft)
		return
	header_extra.add_child(UIKit.label(DraftChallenges.title(draft.challenge_id), &"", 36, DraftKit.MARQUEE))
	if draft.is_dungeon():
		_fill_door(draft)
	else:
		_fill_versus(draft)


# ---- Trey Pickett's cart: this zone's draft ---------------------------------------------------------------------------------------


func _fill_zone() -> void:
	var id: String = DraftChallenges.zone_id_for(zone_id)
	var won: bool = Session.flag(StringName(DraftChallenges.won_flag(id)))
	var row: HBoxContainer = UIKit.hbox(24)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	row.add_child(_host_portrait(DraftHost.portrait_id(), 600.0))
	var column: VBoxContainer = UIKit.vbox(16)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(column)
	var card: PanelContainer = DraftKit.plaque(0.93, DraftKit.VELVET_DEEP, DraftKit.MARQUEE, 22, 26.0)
	card.name = "Challenge_%s" % id.replace(":", "_")
	column.add_child(card)
	var words: VBoxContainer = UIKit.vbox(10)
	card.add_child(words)
	var heading: HBoxContainer = UIKit.hbox(14)
	words.add_child(heading)
	heading.add_child(DraftKit.path_row(DraftChallenges.fixed_paths(id), 64.0))
	var title: Label = UIKit.label(DraftChallenges.title(id) + ("   (won)" if won else ""), &"", 52, DraftKit.MARQUEE)
	title.name = "ChallengeTitle"
	heading.add_child(title)
	words.add_child(DraftKit.text(DraftChallenges.summary(id), 30, DraftKit.CREAM))
	words.add_child(DraftKit.text("How it goes: twenty-five picks, one of three each time. Five pieces of equipment and two items along the way. Then three fights at full HP with what you drafted; three wins take the prize, two losses end the run. Your own deck, gear and items stay at home.", 26, GlassTheme.SECONDARY))
	var first: Dictionary = DraftChallenges.reward(3, true, not won, id, DraftChallenges.fixed_paths(id), Session.flag(MultiPathLock.FLAG_UNLOCKED))
	var pay: Label = DraftKit.text("Entry: free.   Three wins pay %s%s, and you keep one drafted card." % [DraftKit.reward_words(first), "" if won else " (the first time)"], 28, GlassTheme.GOOD)
	pay.name = "RewardLine"
	words.add_child(pay)
	if not _notice.is_empty():
		words.add_child(DraftKit.text(_notice, 28, GlassTheme.CAUTION))
	var start: FancyButton = DraftKit.button("Start the draft", "Start_%s" % id.replace(":", "_"), func() -> void: _start(id), Vector2(420, 78), &"PrimaryButton")
	start.size_flags_horizontal = Control.SIZE_SHRINK_END
	words.add_child(start)
	var house: PanelContainer = DraftKit.plaque(0.88, DraftKit.NIGHT, GlassTheme.GOLD_LINE, 18, 18.0)
	house.name = "ShuffleHouseNote"
	column.add_child(house)
	house.add_child(DraftKit.text(_house_words(), 26, DraftKit.CREAM))


## What the zone menu says about the Shuffle House: how it opens, and that choosing Paths happens there.
func _house_words() -> String:
	var won: int = DraftChallenges.zone_drafts_won(Session.flags)
	if DraftArena.is_open(Session.flags):
		return "Zone drafts won: %d of 4.  My aunt Octavia's Shuffle House is OPEN in Crosspath: four games (Classic, Dungeon Draft, Mystery Mini, High Rollers) with your own choice of Paths, and the Shuffled Halls behind the stage. %s" % [won, DraftArena.paths_rule_text(Session.flags)]
	return "Zone drafts won: %d of 4.  Win all four, or free three zones, and my aunt Octavia opens the Shuffle House in Crosspath. That is where you choose your own Paths. %s" % [won, DraftArena.paths_rule_text(Session.flags)]


func _host_portrait(portrait_id: String, width: float) -> Control:
	var picture: TextureRect = TextureRect.new()
	picture.name = "HostPortrait"
	picture.texture = Portraits.texture_for(portrait_id) if Portraits.has_portrait(portrait_id) else null
	picture.custom_minimum_size = Vector2(width, 0)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture


func _start(id: String) -> void:
	_notice = Session.draft_start_problem(id, _paths)
	if _notice.is_empty() and Session.start_draft(id, _paths):
		Audio.sfx(&"ui_confirm")
		reopen.emit()
		return
	if not _notice.is_empty():
		Audio.sfx(&"ui_error")
	_refresh()


# ---- The Shuffle House: four modes and one door (Fable Nov 24; the look of UI-DRAFT-MOCK-ARENA on UI-DRAFT-HALL) -------------------


## The menu: Octavia Eightfold presenting on the left; on the right a marquee, the four modes as big tiles, under them the Draft
## of the Day (below Classic) and the Shuffled Halls' door, and the chosen mode's choices, rewards and Start.
func _fill_arena() -> void:
	if _mode.is_empty():
		_mode = DraftArena.MODE_CLASSIC
	# the layout follows the canvas: 1,920 wide at 16:9, narrower in a squarer window (the owner's is about 1,570). Octavia stands
	# beside the board while there is room for her; in a narrow window she presents from the marquee instead.
	_laid_out_for = canvas_width()
	var portrait: float = clampf(canvas_width() - 1500.0, 0.0, 430.0)
	_side_host = portrait >= 220.0
	var board_room: float = canvas_width() - PAGE_MARGIN - 32.0 - (portrait + 14.0 if _side_host else 0.0)
	_tile = Vector2(clampf((board_room - 36.0) / 4.0, 236.0, MODE_TILE.x), MODE_TILE.y)
	var row: HBoxContainer = UIKit.hbox(14)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	if _side_host:
		row.add_child(_host_portrait(DraftArena.NPC_ID, portrait))
	var board: PanelContainer = DraftKit.plaque(0.9, DraftKit.VELVET_DEEP, DraftKit.MARQUEE, 26, 16.0)
	board.name = "ArenaBoard"
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(board)
	var column: VBoxContainer = UIKit.vbox(10)
	board.add_child(column)
	column.add_child(_marquee())
	var modes: HBoxContainer = UIKit.hbox(12)
	modes.name = "Modes"
	modes.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(modes)
	for mode: String in DraftArena.MODES:
		modes.add_child(_mode_tile(mode))
	var doors: HBoxContainer = UIKit.hbox(12)
	doors.name = "Doors"
	doors.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(doors)
	doors.add_child(_daily_tile())
	doors.add_child(_halls_door())
	column.add_child(_details())


## "The Shuffle House" in marquee gold between two rows of bulbs, with the Path rule of the moment under it.
func _marquee() -> Control:
	var sign: PanelContainer = PanelContainer.new()
	sign.name = "Marquee"
	var box: StyleBoxFlat = UIStyle.box(DraftKit.VELVET, DraftKit.MARQUEE, 4, 30)
	box.content_margin_left = 26.0
	box.content_margin_right = 26.0
	box.content_margin_top = 4.0
	box.content_margin_bottom = 6.0
	sign.add_theme_stylebox_override("panel", box)
	sign.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var words: VBoxContainer = UIKit.vbox(0)
	sign.add_child(words)
	var line: HBoxContainer = UIKit.hbox(14)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	words.add_child(line)
	if not _side_host and Portraits.has_portrait(DraftArena.NPC_ID):
		# a narrow window has no room for Octavia beside the board: she presents from the marquee
		var bust: TextureRect = TextureRect.new()
		bust.name = "HostBust"
		bust.texture = Portraits.texture_for(DraftArena.NPC_ID)
		bust.custom_minimum_size = Vector2(76, 76)
		bust.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bust.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bust.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(bust)
	line.add_child(_bulbs(5))
	var title: Label = UIKit.label("Step right up: four games and one door", &"", 34, DraftKit.MARQUEE, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "MarqueeTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	line.add_child(title)
	line.add_child(_bulbs(5))
	var rule: Label = UIKit.label(DraftArena.paths_rule_text(Session.flags), &"", 21, DraftKit.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	rule.name = "PathsRule"
	words.add_child(rule)
	return sign


## A row of marquee bulbs (small warm discs).
func _bulbs(count: int) -> Control:
	var row: HBoxContainer = UIKit.hbox(8)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for index: int in range(count):
		var bulb: Panel = Panel.new()
		bulb.custom_minimum_size = Vector2(14, 14)
		bulb.add_theme_stylebox_override("panel", UIStyle.box(Color("fff3c4") if index % 2 == 0 else DraftKit.MARQUEE, Color("b5791f"), 2, 7))
		bulb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(bulb)
	return row


## Every Control under `node` lets the mouse through, so the button that holds it gets the click (the Path badges' discs
## swallowed it: that was why the Path toggles of Nov 23 did nothing).
static func ignore_mouse(node: Node) -> void:
	for child: Node in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		ignore_mouse(child)


## The frame of a big choice: velvet, a gold rim, brighter and thicker when it is the chosen one.
func _frame_button(node_name: String, size: Vector2, lit: bool, locked: bool, fill: Color = DraftKit.VELVET) -> Button:
	var made: Button = Button.new()
	made.name = node_name
	made.custom_minimum_size = size
	made.toggle_mode = true
	made.button_pressed = lit
	made.clip_contents = true
	for state: String in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		var base: Color = Color("26222e") if locked else fill
		var shade: Color = base.lightened(0.16) if lit else (base.lightened(0.08) if state.begins_with("hover") or state == "focus" else base.darkened(0.25))
		var rim: Color = DraftKit.MARQUEE if lit else (Color(0.45, 0.45, 0.5) if locked else GlassTheme.GOLD_LINE.darkened(0.2))
		var box: StyleBoxFlat = UIStyle.box(shade, Color.WHITE if state == "focus" and not lit else rim, 5 if lit else 3, 20)
		box.set_content_margin_all(10.0)
		if lit:
			box.shadow_color = Color(DraftKit.MARQUEE, 0.45)
			box.shadow_size = 10
		made.add_theme_stylebox_override(state, box)
	return made


## The gold ribbon a tile's name is written on.
func _ribbon(words: String, size: int, lit: bool) -> PanelContainer:
	var ribbon: PanelContainer = PanelContainer.new()
	ribbon.name = "Ribbon"
	var box: StyleBoxFlat = UIStyle.box(DraftKit.MARQUEE if lit else Color("c99a3a"), Color("7a4a12"), 2, 10)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 1.0
	box.content_margin_bottom = 3.0
	ribbon.add_theme_stylebox_override("panel", box)
	ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var label: Label = UIKit.label(words, &"", size, DraftKit.VELVET_DEEP, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Title"
	label.add_theme_font_override("font", UIStyle.font_title())
	ribbon.add_child(label)
	return ribbon


## A small tag on a tile ("Prismatic Packs", "Entry: 200 gold").
func _tag(words: String, colour: Color) -> PanelContainer:
	var tag: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = UIStyle.box(Color(0.04, 0.02, 0.08, 0.75), Color(colour, 0.8), 2, 10)
	box.content_margin_left = 10.0
	box.content_margin_right = 10.0
	box.content_margin_top = 0.0
	box.content_margin_bottom = 2.0
	tag.add_theme_stylebox_override("panel", box)
	tag.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var label: Label = UIKit.label(words, &"", 18, colour, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Tag"
	label.add_theme_font_override("font", UIStyle.font_bold())
	tag.add_child(label)
	return tag


## One of the four modes: its emblem, its name on a ribbon, one line of pitch and its tag.
func _mode_tile(mode: String) -> Control:
	var lit: bool = _mode == mode
	var tile: Button = _frame_button("Mode_%s" % mode, _tile, lit, false)
	tile.tooltip_text = DraftArena.mode_title(mode)
	tile.pressed.connect(func() -> void: _choose_mode(mode))
	var box: VBoxContainer = UIKit.vbox(6)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(box)
	var emblem: Control = _mode_emblem(mode)
	emblem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(emblem)
	box.add_child(_ribbon(DraftArena.mode_title(mode), 28 if DraftArena.mode_title(mode).length() <= 14 else 23, lit))
	var pitch: Label = UIKit.label(DraftArena.mode_pitch(mode), &"", 21, DraftKit.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	pitch.name = "Pitch"
	pitch.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pitch.custom_minimum_size = Vector2(_tile.x - 44.0, 0)
	pitch.add_theme_constant_override("line_spacing", -3)
	box.add_child(pitch)
	box.add_child(_tag(_mode_tag(mode), _mode_tag_colour(mode)))
	ignore_mouse(tile)
	return tile


func _mode_tag(mode: String) -> String:
	match mode:
		DraftArena.MODE_CLASSIC:
			return "Free - Path Packs"
		DraftArena.MODE_DUNGEON:
			return "Free - Prismatic Packs" if Session.flag(MultiPathLock.FLAG_UNLOCKED) else "Free - Gilded Packs"
		DraftArena.MODE_MYSTERY:
			return "Free - a pack of its Path"
	return "Entry: %d gold" % Session.draft_fee(DraftArena.HIGH_ID)


func _mode_tag_colour(mode: String) -> Color:
	return DraftKit.MARQUEE if mode == DraftArena.MODE_HIGH else Color("9fe6b0")


## The picture of a mode: the four Paths fanned out for Classic, a castle for the Dungeon Draft, the wheel's question mark for
## Mystery Mini, a pile of coins for High Rollers.
func _mode_emblem(mode: String) -> Control:
	match mode:
		DraftArena.MODE_CLASSIC:
			var fan: HBoxContainer = UIKit.hbox(-8)
			for path: int in DraftKit.PATH_ORDER:
				fan.add_child(DraftKit.path_badge(path, 62.0))
			return fan
		DraftArena.MODE_MYSTERY:
			var mark: Label = UIKit.label("?", &"", 78, DraftKit.MARQUEE, HORIZONTAL_ALIGNMENT_CENTER)
			mark.add_theme_font_override("font", UIStyle.font_title())
			mark.custom_minimum_size = Vector2(0, 72)
			return mark
	var key: String = "delapouite/castle" if mode == DraftArena.MODE_DUNGEON else "delapouite/coins-pile"
	return CardIcons.glyph(CardIcons.named(key), DraftKit.MARQUEE, Vector2(76, 76))


func _choose_mode(mode: String) -> void:
	_mode = mode
	_notice = ""
	Audio.sfx(&"ui_select")
	_refresh()


## The Draft of the Day, a small tile under Classic.
func _daily_tile() -> Control:
	var lit: bool = _mode == DAILY
	var won_today: bool = Session.flag(StringName(DraftChallenges.won_flag(DraftArena.daily_id())))
	var tile: Button = _frame_button("Mode_daily", Vector2(_tile.x, DOOR_HEIGHT), lit, false, Color("3a1420"))
	tile.tooltip_text = "Draft of the Day: a Classic Draft that is the same for everybody today."
	tile.pressed.connect(func() -> void: _choose_mode(DAILY))
	var box: VBoxContainer = UIKit.vbox(2)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(box)
	var name_label: Label = UIKit.label("Draft of the Day%s" % ("  (won)" if won_today else ""), &"", 24, DraftKit.MARQUEE if lit else DraftKit.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "Title"
	name_label.add_theme_font_override("font", UIStyle.font_bold())
	box.add_child(name_label)
	var paths: HBoxContainer = DraftKit.path_row(DraftArena.daily_paths(DraftArena.daily_id(), DraftArena.max_paths(Session.flags)), 34.0)
	paths.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(paths)
	ignore_mouse(tile)
	return tile


## The Shuffled Halls: its own big door under the four modes.
func _halls_door() -> Control:
	var lit: bool = _mode == HALLS
	var cleared: bool = Session.flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID)))
	var door: Button = _frame_button("Mode_halls", Vector2(_tile.x * 3.0 + 24.0, DOOR_HEIGHT), lit, false, Color("4a1030"))
	door.tooltip_text = "The Shuffled Halls: the house's own dungeon."
	door.pressed.connect(func() -> void: _choose_mode(HALLS))
	var line: HBoxContainer = UIKit.hbox(18)
	line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	door.add_child(line)
	if IconArt.has("ICON-MAP-DRAFT"):
		line.add_child(IconArt.rect("ICON-MAP-DRAFT", 66.0))
	var words: VBoxContainer = UIKit.vbox(0)
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_child(words)
	words.add_child(_ribbon("The Shuffled Halls", 30, lit))
	var pitch: Label = UIKit.label("The house's own dungeon: eighteen rooms, a dealer at every table, and me at the Big Wheel.%s" % ("  Cleared." if cleared else ""), &"", 20, DraftKit.CREAM, HORIZONTAL_ALIGNMENT_CENTER)
	pitch.name = "Pitch"
	words.add_child(pitch)
	if IconArt.has("ICON-MAP-DRAFT"):
		line.add_child(IconArt.rect("ICON-MAP-DRAFT", 66.0))
	ignore_mouse(door)
	return door


## The challenge the menu would start now ("" while the Dungeon Draft has no dungeon to offer).
func selected_challenge() -> String:
	match _mode:
		HALLS:
			return DraftArena.HALLS_ID
		DAILY:
			return DraftArena.daily_id()
		DraftArena.MODE_DUNGEON:
			var keys: Array[String] = Session.draft_dungeon_keys()
			if keys.is_empty():
				return ""
			if _dungeon == RANDOM or not keys.has(_dungeon):
				return RANDOM
			return DraftArena.dungeon_id(_dungeon)
	return DraftArena.mode_challenge(_mode)


## Under the tiles: the chosen mode in words, its choices (your Paths, which dungeon), what it pays and the Start button.
func _details() -> Control:
	var strip: PanelContainer = DraftKit.plaque(0.94, DraftKit.NIGHT, DraftKit.MARQUEE, 20, 14.0)
	strip.name = "Details"
	strip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var row: HBoxContainer = UIKit.hbox(18)
	strip.add_child(row)
	var words: VBoxContainer = UIKit.vbox(8)
	words.name = "Words"
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	var id: String = selected_challenge()
	var shown: String = DraftArena.dungeon_id(Session.draft_dungeon_keys()[0]) if id == RANDOM else id
	var heading: String = DraftArena.mode_title(_mode) if _mode in DraftArena.MODES else DraftChallenges.title(id)
	var title: Label = UIKit.label(heading, &"", 36, DraftKit.MARQUEE)
	title.name = "DetailsTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	words.add_child(title)
	if _mode == DraftArena.MODE_DUNGEON:
		words.add_child(DraftKit.text("Draft a deck, then play a large dungeon you have already cleared with your own deck, on one HP pool. After each fight, pick one of three cards.", 23, DraftKit.CREAM))
		words.add_child(_dungeon_choice())
	else:
		words.add_child(DraftKit.text(DraftChallenges.summary(id), 23, DraftKit.CREAM))
	if _mode == DAILY:
		var today: HBoxContainer = UIKit.hbox(10)
		today.name = "DailyPaths"
		today.add_child(UIKit.label("Today's Paths:", &"", 24, GlassTheme.SECONDARY))
		today.add_child(DraftKit.path_row(DraftArena.daily_paths(id, DraftArena.max_paths(Session.flags)), 50.0))
		words.add_child(today)
	elif not id.is_empty():
		words.add_child(_path_choice(shown))
	var locked: String = "" if id.is_empty() or id == RANDOM else DraftArena.locked_reason(id, Session.flags)
	var note: String = _notice if not _notice.is_empty() else locked
	if not note.is_empty():
		var warning: Label = DraftKit.text(note, 24, GlassTheme.CAUTION)
		warning.name = "Notice"
		words.add_child(warning)
	var how: Label = DraftKit.text(_how_it_goes(), 21, GlassTheme.SECONDARY)
	how.name = "HowItGoes"
	words.add_child(how)
	if _mode == DraftArena.MODE_CLASSIC or _mode == DraftArena.MODE_HIGH or _mode == DAILY:
		words.add_child(_crowd())
	var side: VBoxContainer = UIKit.vbox(8)
	side.name = "Side"
	side.custom_minimum_size = Vector2(420, 0)
	side.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(side)
	side.add_child(DraftKit.chip("Rewards"))
	if not id.is_empty():
		side.add_child(_reward_chips(shown))
		var pay: Label = DraftKit.text(_reward_words(shown), 20, GlassTheme.GOOD)
		pay.name = "RewardLine"
		side.add_child(pay)
	var fee: int = Session.draft_fee(shown) if not id.is_empty() else 0
	if fee > 0:
		var fee_label: Label = DraftKit.text("Entry fee: %d gold (you have %d)." % [fee, Session.gold], 22, DraftKit.MARQUEE if Session.gold >= fee else GlassTheme.CAUTION)
		fee_label.name = "FeeLine"
		side.add_child(fee_label)
	var start_words: String = "Start" if fee <= 0 else "Pay %d gold and start" % fee
	var start: FancyButton = DraftKit.button(start_words, "Start", _start_selected, Vector2(420, 78), &"PrimaryButton")
	start.add_theme_font_size_override("font_size", 36 if fee <= 0 else 28)
	start.disabled = id.is_empty() or not locked.is_empty()
	side.add_child(start)
	return strip


## The chosen mode's run in two short lines (the rules that differ between the modes).
func _how_it_goes() -> String:
	var picks: String = "Twenty-five picks of three, five pieces of equipment and two items; your own deck and gear stay at home."
	match _mode:
		DraftArena.MODE_DUNGEON:
			return "%s  Then the dungeon on ONE pool of HP: the run ends at the first loss, and heal rooms cost real gold." % picks
		DraftArena.MODE_MYSTERY:
			return "%s  Then three fights on ONE pool of HP, in a mini dungeon you only learn at the door." % picks
		HALLS:
			return "%s  Rooms you have never stepped on show as question marks. The Counting Halls, off the last corridor, let you cash out." % picks
	return "%s  Then three fights at full HP each: three wins take the prize, two losses end the run." % picks


## "Who might sit down": a row of faces from the arena's cast, a different handful every day (the tables' opponents are random).
func _crowd() -> Control:
	var box: VBoxContainer = UIKit.vbox(4)
	box.name = "Crowd"
	var caption: Label = UIKit.label("Who might sit down (%d regulars from all over the kingdom):" % DraftRivals.ARENA_ROSTER.size(), &"", 21, GlassTheme.SECONDARY)
	box.add_child(caption)
	var row: HBoxContainer = UIKit.hbox(8)
	row.name = "Faces"
	box.add_child(row)
	var pool: Array = DraftRivals.ARENA_ROSTER.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = DraftArena.daily_seed(DraftArena.daily_id()) + 5
	for index: int in range(CROWD_FACES):
		if pool.is_empty():
			break
		var at: int = rng.randi() % pool.size()
		var who: Array = pool[at] as Array
		pool.remove_at(at)
		if not Portraits.has_portrait(str(who[0])):
			continue
		var frame: PanelContainer = PanelContainer.new()
		var style: StyleBoxFlat = UIStyle.box(Color(0.04, 0.03, 0.1, 0.9), GlassTheme.GOLD_LINE.darkened(0.15), 2, 10)
		style.set_content_margin_all(3.0)
		frame.add_theme_stylebox_override("panel", style)
		frame.tooltip_text = "%s: %s" % [str(who[1]), str(DraftRivals.TITLES.get(str(who[2]), ""))]
		var face: TextureRect = TextureRect.new()
		face.texture = Portraits.texture_for(str(who[0]))
		face.custom_minimum_size = Vector2(70, 70)
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(face)
		row.add_child(frame)
	return box
const CROWD_FACES: int = 9


## The Dungeon Draft's list: Random first, then every large dungeon the player has cleared (the Shuffled Halls among them after
## their first clear), and how many are still to be cleared.
func _dungeon_choice() -> Control:
	var keys: Array[String] = Session.draft_dungeon_keys()
	var box: VBoxContainer = UIKit.vbox(4)
	box.name = "DungeonChoice"
	if keys.is_empty():
		var none: Label = DraftKit.text("No large dungeon cleared yet. Clear one with your own deck first: every zone's main dungeon counts, and the big ones beyond (Primm's Castle, the Path-ology Lab, Mount Swolympus, the Shattered Gallery).", 23, GlassTheme.CAUTION)
		none.name = "NoDungeons"
		box.add_child(none)
		return box
	if _dungeon.is_empty() or (_dungeon != RANDOM and not keys.has(_dungeon)):
		_dungeon = RANDOM
	var flow: HFlowContainer = HFlowContainer.new()
	flow.name = "Dungeons"
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 6)
	box.add_child(flow)
	flow.add_child(_dungeon_button(RANDOM, "Random dungeon"))
	for key: String in keys:
		var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(key)
		flow.add_child(_dungeon_button(key, plan.dungeon_name if plan != null else key))
	return box


func _dungeon_button(key: String, words: String) -> Button:
	var lit: bool = _dungeon == key
	var pick: Button = _frame_button("Dungeon_%s" % key.replace(":", "_"), Vector2(0, 50), lit, false, Color("2c2450"))
	pick.text = "  %s  " % words
	pick.add_theme_font_size_override("font_size", 22)
	pick.add_theme_color_override("font_color", DraftKit.CREAM)
	pick.add_theme_color_override("font_pressed_color", DraftKit.MARQUEE)
	pick.add_theme_color_override("font_hover_color", DraftKit.CREAM)
	pick.add_theme_color_override("font_hover_pressed_color", DraftKit.MARQUEE)
	pick.add_theme_color_override("font_focus_color", DraftKit.CREAM)
	pick.pressed.connect(func() -> void:
		_dungeon = key
		_notice = ""
		_refresh())
	return pick


## How many Paths the draft may have now: the challenge's own range, cut by the story's rule.
func _most_paths(id: String) -> int:
	return maxi(1, mini(DraftArena.choice_range(id)[1], DraftChallenges.max_open_paths(Session.flags)))


## Your Paths: four big rectangles you switch on and off, lit when on, with the Path's icon and name. Switching on more than
## the story allows opens a pop-up that says why (the toggles of Nov 23 could not be clicked at all).
func _path_choice(id: String) -> Control:
	var most: int = _most_paths(id)
	if _paths.is_empty() and Session.profile != null:
		_paths.append(int(Session.profile.primary_affinity) if int(Session.profile.primary_affinity) != 0 else DraftKit.PATH_ORDER[0])
	while _paths.size() > most:
		_paths.pop_back()
	var box: VBoxContainer = UIKit.vbox(4)
	box.name = "PathChoice"
	var how_many: String = str({1: "one", 2: "one or two", 3: "up to three", 4: "up to four"}.get(most, "one"))
	var caption: Label = UIKit.label("Your Paths: switch on %s.  (%d on)" % [how_many, _paths.size()], &"", 22, GlassTheme.SECONDARY)
	caption.name = "PathCaption"
	box.add_child(caption)
	var row: HBoxContainer = UIKit.hbox(10)
	row.name = "PathToggles"
	box.add_child(row)
	for path: int in DraftKit.PATH_ORDER:
		row.add_child(_path_toggle(path))
	return box


func _path_toggle(path: int) -> Button:
	var on: bool = _paths.has(path)
	var colour: Color = UIStyle.affinity_color(path as Affinity.Type)
	var toggle: Button = Button.new()
	toggle.name = "PathToggle_%d" % path
	toggle.custom_minimum_size = PATH_TOGGLE
	toggle.toggle_mode = true
	toggle.button_pressed = on
	toggle.tooltip_text = "%s: %s" % [Affinity.display_name(path as Affinity.Type), "on - click to switch it off" if on else "off - click to switch it on"]
	for state: String in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		var fill: Color = colour.darkened(0.25) if on else Color(colour.darkened(0.78), 0.92)
		if state.begins_with("hover") or state == "focus":
			fill = fill.lightened(0.1)
		var box: StyleBoxFlat = UIStyle.box(fill, Color.WHITE if state == "focus" else (DraftKit.MARQUEE if on else Color(0.5, 0.5, 0.56)), 5 if on else 2, 14)
		box.set_content_margin_all(6.0)
		if on:
			box.shadow_color = Color(colour.lightened(0.3), 0.55)
			box.shadow_size = 9
		toggle.add_theme_stylebox_override(state, box)
	var line: HBoxContainer = UIKit.hbox(10)
	line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	toggle.add_child(line)
	var symbol: TextureRect = IconArt.rect(IconArt.energy_id(path as Affinity.Type), 52.0)
	if symbol != null:
		symbol.modulate = Color.WHITE if on else Color(1, 1, 1, 0.5)
		symbol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(symbol)
	var words: VBoxContainer = UIKit.vbox(-4)
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_child(words)
	var path_name: String = Affinity.display_name(path as Affinity.Type)
	var name_label: Label = UIKit.label(path_name, &"", 26 if path_name.length() <= 9 else 21, Color.WHITE if on else Color("b9b4c4"))
	name_label.name = "PathName"
	name_label.add_theme_font_override("font", UIStyle.font_bold())
	words.add_child(name_label)
	var state_label: Label = UIKit.label("ON" if on else "off", &"", 20, DraftKit.MARQUEE if on else Color("8d8aa6"))
	state_label.name = "State"
	state_label.add_theme_font_override("font", UIStyle.font_bold())
	words.add_child(state_label)
	ignore_mouse(toggle)
	toggle.pressed.connect(func() -> void: toggle_path(path))
	return toggle


## Switches a Path on or off. One more than the story allows is refused with a pop-up.
func toggle_path(path: int) -> void:
	var id: String = selected_challenge()
	var most: int = _most_paths(DraftArena.CLASSIC_ID if id.is_empty() or id == RANDOM else id)
	_notice = ""
	if _paths.has(path):
		_paths.erase(path)
		Audio.sfx(&"ui_select")
	elif _paths.size() < most:
		_paths.append(path)
		Audio.sfx(&"ui_confirm")
	else:
		_refresh()
		_too_many_paths(most)
		return
	_refresh()


## "Too many Paths": the house limit of the moment, and what opens the next one.
func _too_many_paths(most: int) -> void:
	if limit_popup != null and is_instance_valid(limit_popup):
		return
	var popup: PopupFrame = PopupFrame.make("HOUSE LIMIT", "ICON-UI-DECK", DraftKit.MARQUEE)
	popup.name = "TooManyPaths"
	popup.set_heading("%s for now" % ("One Path" if most <= 1 else ("Two Paths" if most == 2 else "%d Paths" % most)), DraftArena.too_many_paths_text(Session.flags))
	var hint: Label = UIKit.label("Switch one of your Paths off first, then switch this one on.", &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(PopupFrame.PANEL_WIDTH - 80.0, 0)
	popup.body.add_child(hint)
	popup.set_button_text("Very well")
	popup.z_index = 200
	limit_popup = popup
	_popup_host().add_child(popup)
	popup.reveal_body()
	popup.confirmed.connect(func() -> void:
		popup.queue_free()
		limit_popup = null
		UiInput.make_focusable(self)
		PadFocus.register(self), CONNECT_ONE_SHOT)
	Audio.sfx(&"ui_error")


func _start_selected() -> void:
	var id: String = selected_challenge()
	if id.is_empty():
		return
	if id == RANDOM:
		var key: String = Session.draft_random_dungeon()
		if key.is_empty():
			return
		id = DraftArena.dungeon_id(key)
	_start(id)


## What a challenge pays, as a row of icons with their names (the mock-up's Rewards strip).
func _reward_chips(id: String) -> Control:
	var flow: HFlowContainer = HFlowContainer.new()
	flow.name = "RewardChips"
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 6)
	var pay: Dictionary = reward_preview(id)
	if int(pay.get("gold", 0)) > 0:
		flow.add_child(_reward_chip("ICON-GOLD", "%d gold" % int(pay["gold"]), UIStyle.GOLD))
	if int(pay.get("xp", 0)) > 0:
		flow.add_child(_reward_chip("ICON-XP", "%d XP" % int(pay["xp"]), UIStyle.GOOD))
	for pack: Variant in pay.get("packs", []) as Array:
		flow.add_child(_reward_chip("ICON-UI-PACKS", DraftKit.pack_name(str(pack)), DraftKit.CREAM))
	for extra: Variant in pay.get("extras", []) as Array:
		flow.add_child(_reward_chip("", str(extra), DraftKit.CREAM))
	if bool(pay.get("keep_card", false)):
		flow.add_child(_reward_chip("ICON-UI-DECK", "Keep one card", DraftKit.CREAM))
	return flow


func _reward_chip(icon_id: String, words: String, colour: Color) -> Control:
	var chip: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = UIStyle.box(Color(0.04, 0.03, 0.1, 0.8), Color(colour, 0.6), 2, 12)
	box.content_margin_left = 8.0
	box.content_margin_right = 12.0
	box.content_margin_top = 2.0
	box.content_margin_bottom = 3.0
	chip.add_theme_stylebox_override("panel", box)
	var line: HBoxContainer = UIKit.hbox(6)
	chip.add_child(line)
	if not icon_id.is_empty() and IconArt.has(icon_id):
		var icon: TextureRect = IconArt.rect(icon_id, 30.0)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(icon)
	var label: Label = UIKit.label(words, &"", 21, colour)
	label.add_theme_font_override("font", UIStyle.font_bold())
	line.add_child(label)
	return chip


## The best a challenge pays now, for the Rewards strip: {"gold", "xp", "packs", "extras", "keep_card"}.
func reward_preview(id: String) -> Dictionary:
	var won: bool = Session.flag(StringName(DraftChallenges.won_flag(id)))
	var after_primm: bool = Session.flag(MultiPathLock.FLAG_UNLOCKED)
	var extras: Array[String] = []
	if DraftArena.is_dungeon(id):
		var table: Dictionary = DraftRules.dungeon_rewards()
		var extra_pack: String = DraftChallenges.pack_id(str(table.get("extra_pack_after_primm", "prismatic")) if after_primm else str(table.get("extra_pack", "gilded_general")), [] as Array[int], after_primm)
		var packs: Array[String] = []
		var gold: int = 0
		var xp: int = 0
		match DraftArena.kind_of(id):
			DraftArena.KIND_HALLS:
				gold = int(table.get("halls_clear_gold", 0)) + (0 if won else int(table.get("halls_first_clear_gold", 0)))
				xp = int(table.get("halls_clear_xp", 0)) + (0 if won else int(table.get("halls_first_clear_xp", 0)))
				packs.append("general_1")
				packs.append(extra_pack)
				if not won:
					packs.append(str(table.get("halls_first_clear_pack", "gilded_general")))
					extras.append("A piece of draft equipment")
			DraftArena.KIND_MYSTERY:
				gold = DungeonBuilder.SIDE_REPEAT_GOLD
				extras.append("A pack of the dungeon's Path")
			_:
				extras.append("The dungeon's own clear rewards")
				packs.append(extra_pack)
		return {"gold": gold, "xp": xp, "packs": packs, "extras": extras, "keep_card": true}
	var paths: Array[int] = _paths
	if DraftArena.kind_of(id) == DraftArena.KIND_DAILY:
		paths = DraftArena.daily_paths(id, DraftArena.max_paths(Session.flags))
	var full: Dictionary = DraftChallenges.reward(3, true, not won, id, paths, after_primm)
	full["extras"] = extras
	return full


func _reward_words(id: String) -> String:
	var won: bool = Session.flag(StringName(DraftChallenges.won_flag(id)))
	match DraftArena.kind_of(id):
		DraftArena.KIND_HALLS:
			return "For beating Octavia%s. Cashing out at the Counting Halls pays part of it, and is not a win." % ("" if won else " (the first clear pays more)")
		DraftArena.KIND_MYSTERY:
			return "For clearing the mini dungeon. Every fight won pays a little even if the run ends."
		DraftArena.KIND_DUNGEON:
			return "For a clear.%s Every fight won pays a little even if the run ends." % ("" if Session.flag(MultiPathLock.FLAG_UNLOCKED) else " (Prismatic Packs once Primm is defeated; a Gilded Pack until then.)")
		DraftArena.KIND_HIGH:
			return "For three wins%s. Fewer wins pay less.%s" % ["" if won else " (the first time)", "" if Session.flag(MultiPathLock.FLAG_UNLOCKED) else " A Gilded Pack until Primm is defeated, a Prismatic Pack after."]
	return "For three wins%s. Fewer wins still pay gold and XP. No Prismatic Packs here." % ("" if won else " (the first time)")


# ---- The result of a finished draft: a standard pop-up (Fable Nov 24, Part 3) -------------------------------------------------------


## True when this screen shows the draft as it stands: no draft (the menu), a run in progress (the next opponent, the dungeon's
## door), or a finished one whose result is ready to show (after the card to keep is chosen, when there is one to choose).
static func shows(draft: DraftState) -> bool:
	if draft == null or draft.phase == DraftState.PHASE_RUN:
		return true
	return draft.phase == DraftState.PHASE_DONE and not needs_keep(draft)


## A full win whose card to keep is not chosen yet (the draft table shows the picks to choose from).
static func needs_keep(draft: DraftState) -> bool:
	return draft != null and draft.phase == DraftState.PHASE_DONE and draft.full_win() and draft.kept_card.is_empty() and not draft.cards.is_empty()


## What the finished draft paid, as the game's standard reward box: the result in words, gold and XP, the packs and the piece
## of equipment as icons with their names, the kept card as a card.
static func result_summary(draft: DraftState) -> RewardSummary:
	var pay: Dictionary = draft.result
	var summary: RewardSummary = RewardSummary.new()
	summary.kind = RewardSummary.Kind.CHEST
	summary.title = DraftChallenges.title(draft.challenge_id)
	if draft.is_dungeon():
		var place: String = str(pay.get("dungeon", "the dungeon"))
		if bool(pay.get("cashed_out", false)):
			summary.header = "CASHED OUT"
			summary.subtitle = "You cashed out at the Counting Halls after %d fight%s won. Part of the prize is yours. It does not count as a win." % [draft.fights_won, "" if draft.fights_won == 1 else "s"]
		elif draft.full_win():
			summary.header = "DUNGEON CLEARED"
			summary.subtitle = "%s is cleared with a drafted deck. Fights won: %d.%s" % [place, draft.fights_won, "  That includes the first-clear prize." if bool(pay.get("first_win", false)) else ""]
		else:
			summary.header = "RUN OVER"
			summary.subtitle = "The run through %s is over. Fights won: %d." % [place, draft.fights_won]
	else:
		summary.header = "DRAFT WON" if draft.full_win() else "RUN OVER"
		summary.subtitle = "Wins %d of %d.  Losses %d of %d.%s" % [draft.wins, DraftChallenges.wins_to_finish(draft.challenge_id), draft.losses, DraftChallenges.losses_to_finish(draft.challenge_id), "  That includes the first-win prize." if bool(pay.get("first_win", false)) else ""]
	summary.gold = int(pay.get("gold", 0))
	summary.xp = int(pay.get("xp", 0))
	for pack: Variant in pay.get("packs", []) as Array:
		if PackCatalog.find(str(pack)) != null:
			summary.add_pack(str(pack), DraftKit.pack_name(str(pack)))
	if pay.has("equipment") and Session.content != null and Session.content.equipment_piece(str(pay["equipment"])) != null:
		summary.equipment.append(Session.content.equipment_piece(str(pay["equipment"])))
	var kept: CardData = Session.card_by_id(draft.kept_card) if not draft.kept_card.is_empty() else null
	if kept != null:
		summary.cards.append(kept)
	return summary


func _fill_result(draft: DraftState) -> void:
	if (result_popup != null and is_instance_valid(result_popup)) or not is_inside_tree():
		return
	var popup: RewardPopup = RewardPopup.make(result_summary(draft))
	popup.name = "DraftResult"
	popup.frame.set_button_text("Finish")
	popup.z_index = 150
	result_popup = popup
	_popup_host().add_child(popup)
	popup.finished.connect(func() -> void:
		popup.queue_free()
		result_popup = null
		_finish_result(), CONNECT_ONE_SHOT)


func _finish_result() -> void:
	Session.close_draft()
	result = {}
	_refresh()


# ---- The next opponent (UI-DRAFT-MOCK-VERSUS) --------------------------------------------------------------------------------------


func _fill_versus(draft: DraftState) -> void:
	var rival: Dictionary = DraftRun.next_rival(draft)
	if not result.is_empty():
		var banner: Label = DraftKit.text(("You beat %s." if bool(result.get("won", false)) else "%s beat you.") % str(result.get("enemy", "your rival")), 36, GlassTheme.GOOD if bool(result.get("won", false)) else GlassTheme.CAUTION)
		banner.name = "FightResult"
		banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(banner)
	var row: HBoxContainer = UIKit.hbox(18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	row.add_child(_deck_panel(draft))
	row.add_child(_stage(str(rival.get("npc_id", "")), str(rival.get("name", ""))))
	row.add_child(_rival_panel(draft, rival))
	body.add_child(_run_buttons("Fight %s" % str(rival.get("name", "your rival")), _fight))


## The middle of the reveal: the opponent large under a marquee arch.
func _stage(npc_id: String, shown_name: String) -> Control:
	var arch: PanelContainer = PanelContainer.new()
	arch.name = "OpponentStage"
	arch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var box: StyleBoxFlat = UIStyle.box(Color(DraftKit.VELVET, 0.55), DraftKit.MARQUEE, 6, 240)
	box.corner_radius_bottom_left = 18
	box.corner_radius_bottom_right = 18
	box.set_content_margin_all(14.0)
	arch.add_theme_stylebox_override("panel", box)
	var column: VBoxContainer = UIKit.vbox(4)
	arch.add_child(column)
	var picture: TextureRect = TextureRect.new()
	picture.name = "OpponentPortrait"
	var art: Texture2D = Bestiary.art(shown_name)
	if art == null and Portraits.has_portrait(npc_id):
		art = Portraits.texture_for(npc_id)
	picture.texture = art
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(picture)
	var name_label: Label = UIKit.label(shown_name, &"", 46, DraftKit.MARQUEE, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "OpponentName"
	name_label.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(name_label)
	return arch


## "Your Deck": its size, curve and what you wear and carry.
func _deck_panel(draft: DraftState) -> Control:
	var panel: PanelContainer = DraftKit.plaque(0.9, DraftKit.NIGHT, DraftKit.MARQUEE, 18, 16.0)
	panel.name = "YourDeck"
	panel.custom_minimum_size = Vector2(430, 0)
	var box: VBoxContainer = UIKit.vbox(10)
	panel.add_child(box)
	box.add_child(DraftKit.chip("Your deck", 28))
	var spells: Array[CardData] = DraftEngine.deck_cards(Session.content, draft)
	var units: int = 0
	for card: CardData in spells:
		units += 1 if card.is_unit() else 0
	box.add_child(DraftKit.path_row(draft.paths, 52.0))
	box.add_child(DraftKit.text("%d cards: %d units, %d other cards, %d Infrastructure." % [spells.size() + DraftEngine.basics_total(draft), units, spells.size() - units, DraftEngine.basics_total(draft)], 25, DraftKit.CREAM))
	box.add_child(DraftKit.curve(DraftEngine.curve_of(spells), 118.0))
	box.add_child(DraftKit.chip("Equipment"))
	var gear: HBoxContainer = UIKit.hbox(6)
	box.add_child(gear)
	for id: String in draft.equipment:
		var piece: EquipmentData = Session.content.equipment_piece(id)
		gear.add_child(DraftKit.icon_slot(DraftKit.equipment_icon(piece, 60.0), GearText.tooltip(piece), 68.0))
	box.add_child(DraftKit.chip("Items"))
	var items: HBoxContainer = UIKit.hbox(6)
	box.add_child(items)
	for id: String in draft.items:
		var item: ItemData = Session.content.item(id)
		items.add_child(DraftKit.icon_slot(DraftKit.item_icon(item, 60.0), GearText.item_tooltip(item), 68.0))
	if _review:
		box.add_child(DraftKit.chip("The cards"))
		var scroll: ScrollContainer = ScrollContainer.new()
		scroll.name = "ReviewScroll"
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		box.add_child(scroll)
		var list: VBoxContainer = UIKit.vbox(1)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		var copies: Dictionary = {}
		var order: Array[CardData] = []
		for card: CardData in spells:
			if not copies.has(card.id):
				order.append(card)
			copies[card.id] = int(copies.get(card.id, 0)) + 1
		order.sort_custom(func(a: CardData, b: CardData) -> bool: return a.energy_value() < b.energy_value() if a.energy_value() != b.energy_value() else a.display_name < b.display_name)
		for card: CardData in order:
			var line: Label = UIKit.label("%d   %s%s" % [card.energy_value(), card.display_name, "  x%d" % int(copies[card.id]) if int(copies[card.id]) > 1 else ""], &"", 21, GlassTheme.TEXT)
			line.tooltip_text = card.rules_text
			line.mouse_filter = Control.MOUSE_FILTER_STOP
			list.add_child(line)
	return panel


## The opponent's side: who they are, the Paths they drafted, what they wear (the owner: their equipment bonuses shown as battle
## effects under their name), and the run's score in trophies and crosses.
func _rival_panel(draft: DraftState, rival: Dictionary) -> Control:
	var panel: PanelContainer = DraftKit.plaque(0.9, DraftKit.NIGHT, DraftKit.MARQUEE, 18, 16.0)
	panel.name = "RivalPanel"
	panel.custom_minimum_size = Vector2(470, 0)
	var box: VBoxContainer = UIKit.vbox(8)
	panel.add_child(box)
	var heading: Label = UIKit.label(str(rival.get("name", "")), &"", 38, DraftKit.MARQUEE)
	heading.name = "RivalName"
	heading.add_theme_font_override("font", UIStyle.font_title())
	box.add_child(heading)
	box.add_child(DraftKit.path_row(rival.get("paths", draft.paths) as Array, 52.0))
	box.add_child(DraftKit.text("%s: %s." % [str(rival.get("personality", "")).capitalize(), str(rival.get("title", ""))], 24, DraftKit.CREAM))
	box.add_child(UIKit.label("%d HP" % int(rival.get("hp", 0)), &"", 26, GlassTheme.TEXT))
	box.add_child(DraftKit.chip("Battle effects"))
	var effects: VBoxContainer = UIKit.vbox(4)
	effects.name = "RivalGear"
	box.add_child(effects)
	var worn: Array[ModifierSource] = DraftRivals.equipment_sources(Session.content, rival)
	if bool(rival.get("boss", false)):
		effects.add_child(DraftKit.text("%s: %s" % [DraftRivals.HOUSE_RULE_NAME, DraftRivals.HOUSE_RULE_TEXT], 21, GlassTheme.CAUTION))
	if worn.is_empty() and not bool(rival.get("boss", false)):
		effects.add_child(DraftKit.text("None: they wear nothing that changes the fight.", 22, GlassTheme.SECONDARY))
	for source: ModifierSource in worn:
		var piece: EquipmentData = source as EquipmentData
		if piece == null:
			continue
		var line: HBoxContainer = UIKit.hbox(8)
		line.add_child(DraftKit.icon_slot(DraftKit.equipment_icon(piece, 40.0), GearText.tooltip(piece), 48.0))
		var words: Label = DraftKit.text("%s: %s" % [piece.source_name, GearText.effect(piece)], 20, GlassTheme.TEXT)
		line.add_child(words)
		effects.add_child(line)
	box.add_child(UIKit.filler())
	var score: HBoxContainer = UIKit.hbox(8)
	score.name = "Score"
	box.add_child(score)
	for index: int in range(DraftChallenges.wins_to_finish(draft.challenge_id)):
		score.add_child(_token("W", index < draft.wins, Color("e9b53a")))
	score.add_child(UIKit.spacer(0, 12))
	for index: int in range(DraftChallenges.losses_to_finish(draft.challenge_id)):
		score.add_child(_token("X", index < draft.losses, Color("d6454d")))
	box.add_child(UIKit.label("Wins %d of %d   Losses %d of %d" % [draft.wins, DraftChallenges.wins_to_finish(draft.challenge_id), draft.losses, DraftChallenges.losses_to_finish(draft.challenge_id)], &"", 22, GlassTheme.SECONDARY))
	return panel


## A round token of the score row: gold for a win had, red for a loss taken, hollow for one still open.
func _token(letter: String, filled: bool, colour: Color) -> Control:
	var disc: PanelContainer = PanelContainer.new()
	disc.custom_minimum_size = Vector2(54, 54)
	disc.add_theme_stylebox_override("panel", UIStyle.box(colour if filled else Color(0, 0, 0, 0.3), colour if filled else Color(colour, 0.5), 3, 27))
	var label: Label = UIKit.label(letter if filled else "", &"", 26, DraftKit.VELVET_DEEP, HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_font_override("font", UIStyle.font_bold())
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	disc.add_child(label)
	return disc


## The bottom row of a run: Review Deck, the big action, and giving up.
func _run_buttons(action_words: String, action: Callable) -> Control:
	var row: HBoxContainer = UIKit.hbox(16)
	row.name = "RunButtons"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(DraftKit.button("Hide the cards" if _review else "Review deck", "ReviewDeck", func() -> void:
		_review = not _review
		_refresh(), Vector2(330, 70)))
	var go: FancyButton = DraftKit.button(action_words, "Fight", action, Vector2(620, 86), &"PrimaryButton")
	go.add_theme_font_size_override("font_size", 38)
	go.clip_text = true
	row.add_child(go)
	row.add_child(DraftKit.button("Give up this draft", "GiveUp", _give_up, Vector2(330, 58), &"DangerButton"))
	return row


func _fight() -> void:
	Session.start_draft_fight()


func _give_up() -> void:
	Session.close_draft()
	result = {}
	_refresh()


# ---- The dungeon door --------------------------------------------------------------------------------------------------------------


func _fill_door(draft: DraftState) -> void:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(draft.dungeon_key) if MainDungeons.has_def(draft.dungeon_key) else null
	var row: HBoxContainer = UIKit.hbox(18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	row.add_child(_deck_panel(draft))
	var stage: PanelContainer = DraftKit.plaque(0.6, DraftKit.VELVET, DraftKit.MARQUEE, 22, 12.0)
	stage.name = "DungeonStage"
	stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(stage)
	var column: VBoxContainer = UIKit.vbox(6)
	stage.add_child(column)
	var picture: TextureRect = TextureRect.new()
	picture.name = "DungeonMap"
	picture.texture = MapArt.texture_for(plan.map_id) if plan != null and MapArt.has_map(plan.map_id) else null
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(picture)
	var name_label: Label = UIKit.label(plan.dungeon_name if plan != null else "The dungeon", &"", 46, DraftKit.MARQUEE, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "DungeonName"
	name_label.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(name_label)
	var info: PanelContainer = DraftKit.plaque(0.9, DraftKit.NIGHT, DraftKit.MARQUEE, 18, 16.0)
	info.name = "DungeonInfo"
	info.custom_minimum_size = Vector2(470, 0)
	row.add_child(info)
	var words: VBoxContainer = UIKit.vbox(10)
	info.add_child(words)
	words.add_child(DraftKit.chip("The rules", 28))
	if DraftArena.kind_of(draft.challenge_id) == DraftArena.KIND_MYSTERY:
		words.add_child(DraftKit.text("The wheel has spoken: %s." % (plan.dungeon_name if plan != null else "a mini dungeon"), 26, DraftKit.MARQUEE))
	words.add_child(DraftKit.text("One HP pool for the whole dungeon: the run ends at the first loss.", 25, DraftKit.CREAM))
	words.add_child(DraftKit.text("After each fight you win, pick one of three cards: add it, swap it for a card of your deck, or pass.", 25, DraftKit.CREAM))
	if plan != null and not plan.buffs.is_empty() and draft.dungeon_key != DraftArena.HALLS_DUNGEON:
		words.add_child(DraftKit.text("Here: %s" % plan.buffs, 23, GlassTheme.SECONDARY))
	words.add_child(DraftKit.chip("Rewards"))
	words.add_child(DraftKit.text(_reward_words(draft.challenge_id), 23, GlassTheme.GOOD))
	body.add_child(_run_buttons("Enter %s" % (plan.dungeon_name if plan != null else "the dungeon"), _enter))


func _enter() -> void:
	Session.start_draft_dungeon()
