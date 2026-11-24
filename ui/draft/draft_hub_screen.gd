class_name DraftHubScreen
extends OverlayScreen
## Fable big pass Nov 23: where a draft is chosen and where its run is watched, on a full-screen picture (not the glass page):
##   - **Trey Pickett's cart** in a Path zone (VS-TREY): that zone's draft and nothing else (the owner, Nov 23).
##   - **The Shuffle House** in Crosspath (UI-DRAFT-HALL), built from the mock-up UI-DRAFT-MOCK-ARENA: Octavia Eightfold on the left,
##     the board of tiles on the right (the Open Draft, the six two-Path tables, three and four Paths, the win-three tables, the
##     Shuffled Halls, Mystery Mini, the dungeon drafts), the chosen tile's rewards and the Start button under it.
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
const TILE_SIZE: Vector2 = Vector2(196, 150)
const TRIO: String = "trio"
const DUNGEONS: String = "dungeons"

## The arena menu: the tile chosen (a challenge id, or TRIO / DUNGEONS for a tile that opens a choice), the Paths chosen for a
## draft with a free choice, and the last reason a draft could not start.
var _selected: String = ""
var _paths: Array[int] = []
var _notice: String = ""
var _review: bool = false


func _init() -> void:
	screen_title = "The Draft Table"
	title_icon_id = "ICON-UI-DECK"


func in_arena() -> bool:
	return not DraftChallenges.ZONES.has(zone_id)


## The draft screen for the moment, opened at Trey's cart in `zone` ("" = the Shuffle House): this hub while a draft is being
## chosen or its run is on, the draft table (`DraftScreen`) for the picks, the deck and the rewards. Both emit `closed` and
## `reopen` (the draft moved to the other screen's faces: the opener closes this one and asks again).
static func for_state(zone: String, fight_result: Dictionary) -> OverlayScreen:
	var draft: DraftState = Session.draft
	if draft == null or draft.phase == DraftState.PHASE_RUN:
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
	if draft.phase != DraftState.PHASE_RUN:
		reopen.emit.call_deferred()
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
		return "Zone drafts won: %d of 4.  My aunt Octavia's Shuffle House is OPEN in Crosspath: choose your own Paths there, play the two-Path tables and walk the Shuffled Halls. %s" % [won, DraftArena.paths_rule_text(Session.flags)]
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
	_refresh()


# ---- The Shuffle House (UI-DRAFT-MOCK-ARENA) ---------------------------------------------------------------------------------------


func _fill_arena() -> void:
	var row: HBoxContainer = UIKit.hbox(18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	row.add_child(_host_portrait(DraftArena.NPC_ID, 520.0))
	var board: PanelContainer = DraftKit.plaque(0.9, DraftKit.VELVET_DEEP, DraftKit.MARQUEE, 24, 18.0)
	board.name = "ArenaBoard"
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(board)
	var column: VBoxContainer = UIKit.vbox(12)
	board.add_child(column)
	var rule: Label = DraftKit.text(DraftArena.paths_rule_text(Session.flags), 24, DraftKit.CREAM)
	rule.name = "PathsRule"
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(rule)
	var grid: GridContainer = GridContainer.new()
	grid.name = "Tiles"
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(grid)
	var pairs: Array[String] = DraftArena.pair_ids()
	var highs: Array[String] = DraftArena.high_ids()
	# three rows of six, the mock-up's order: the Open Draft and the house's own rooms on the left, the two-Path tables in the
	# middle, the win-three tables and the Draft of the Day on the right
	var order: Array[String] = [DraftArena.OPEN_ID, pairs[0], pairs[1], pairs[2], highs[0], DraftArena.daily_id(),
		DraftArena.HALLS_ID, pairs[3], pairs[4], pairs[5], highs[1], DraftArena.MYSTERY_ID,
		DUNGEONS, TRIO, DraftArena.QUAD_ID, "", highs[2], ""]
	if _selected.is_empty():
		_selected = DraftArena.OPEN_ID
	for id: String in order:
		if id.is_empty():
			var gap: Control = Control.new()
			gap.custom_minimum_size = TILE_SIZE
			grid.add_child(gap)
		else:
			grid.add_child(_tile(id))
	column.add_child(_details())


## The challenge a tile stands for when it is checked for locks and wins (a tile that opens a choice answers for its first entry).
func _tile_challenge(id: String) -> String:
	if id == TRIO:
		return DraftArena.trio_ids()[0]
	if id == DUNGEONS:
		return ""
	return id


func _tile_selected(id: String) -> bool:
	if id == TRIO:
		return DraftArena.kind_of(_selected) == DraftArena.KIND_TRIO or _selected == TRIO
	if id == DUNGEONS:
		return DraftArena.kind_of(_selected) == DraftArena.KIND_DUNGEON or _selected == DUNGEONS
	return _selected == id


func _tile(id: String) -> Control:
	var challenge: String = _tile_challenge(id)
	var locked: String = DraftArena.locked_reason(challenge, Session.flags) if not challenge.is_empty() else ""
	if id == DUNGEONS and Session.draft_dungeon_keys().is_empty():
		locked = "Clear a dungeon first."
	var won: bool = not challenge.is_empty() and Session.flag(StringName(DraftChallenges.won_flag(challenge)))
	if id == TRIO:
		won = true
		for trio: String in DraftArena.trio_ids():
			won = won and Session.flag(StringName(DraftChallenges.won_flag(trio)))
	var tile: Button = Button.new()
	tile.name = "Tile_%s" % (DraftArena.KIND_DAILY if DraftArena.kind_of(id) == DraftArena.KIND_DAILY else id.replace(":", "_").replace("+", "_"))
	tile.custom_minimum_size = TILE_SIZE
	tile.toggle_mode = true
	tile.button_pressed = _tile_selected(id)
	var lit: bool = _tile_selected(id)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var fill: Color = Color("3a1420") if locked.is_empty() else Color("26222e")
		var box: StyleBoxFlat = UIStyle.box(fill.lightened(0.12) if (state == "hover" or lit) else fill, DraftKit.MARQUEE if lit else (GlassTheme.GOLD_LINE.darkened(0.25) if locked.is_empty() else Color(0.45, 0.45, 0.5)), 4 if lit else 2, 16)
		box.set_content_margin_all(8.0)
		tile.add_theme_stylebox_override(state, box)
	tile.pressed.connect(func() -> void:
		_selected = id
		_notice = ""
		_refresh())
	var box_in: VBoxContainer = UIKit.vbox(4)
	box_in.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	box_in.alignment = BoxContainer.ALIGNMENT_CENTER
	box_in.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(box_in)
	var picture: Control = _tile_picture(id, locked.is_empty())
	picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box_in.add_child(picture)
	# Fable big pass Nov 23: a long table name wraps inside its tile (it ran off the edge: "Beefcake x Gourmanc")
	var long_name: bool = _tile_title(id).length() > 14
	var title: Label = UIKit.label(_tile_title(id), &"", 18 if long_name else 22, DraftKit.CREAM if locked.is_empty() else Color("b9b4c4"), HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	title.add_theme_font_override("font", UIStyle.font_bold())
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(TILE_SIZE.x - 18.0, 0)
	title.add_theme_constant_override("line_spacing", -3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box_in.add_child(title)
	var state_words: String = ""
	if not locked.is_empty():
		state_words = "Opens after Primm" if locked.contains("Primm") else ("Opens with the first freed zone" if locked.contains("first zone") else locked)
	elif won:
		state_words = "Won"
	if not state_words.is_empty():
		var state_label: Label = UIKit.label(state_words, &"", 15, DraftKit.MARQUEE if won and locked.is_empty() else Color("d0c8dc"), HORIZONTAL_ALIGNMENT_CENTER)
		state_label.name = "State"
		state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		state_label.custom_minimum_size = Vector2(TILE_SIZE.x - 18.0, 0)
		state_label.add_theme_constant_override("line_spacing", -3)
		state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box_in.add_child(state_label)
	tile.tooltip_text = locked if not locked.is_empty() else _tile_title(id)
	return tile


func _tile_title(id: String) -> String:
	match id:
		TRIO:
			return "Three Paths"
		DUNGEONS:
			return "Dungeon Drafts"
	if id == DraftArena.QUAD_ID:
		return "Four Paths"
	return DraftChallenges.title(id)


## The picture of a tile: the Path badges of its challenge, or a symbol for the house's own rooms.
func _tile_picture(id: String, open: bool) -> Control:
	var paths: Array[int] = []
	match id:
		TRIO:
			paths = [DraftArena.PATHS[0], DraftArena.PATHS[1], DraftArena.PATHS[2]] as Array[int]
		DUNGEONS, DraftArena.HALLS_ID, DraftArena.MYSTERY_ID:
			var symbol: Label = UIKit.label("?" if id == DraftArena.MYSTERY_ID else ("Halls" if id == DraftArena.HALLS_ID else "Maps"), &"", 34, DraftKit.MARQUEE, HORIZONTAL_ALIGNMENT_CENTER)
			symbol.add_theme_font_override("font", UIStyle.font_title())
			symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if id == DraftArena.HALLS_ID and IconArt.has("ICON-MAP-DRAFT"):
				var icon: TextureRect = IconArt.rect("ICON-MAP-DRAFT", 60.0)
				icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
				return icon
			return symbol
		_:
			paths = DraftArena.fixed_paths(id)
			if DraftArena.kind_of(id) == DraftArena.KIND_DAILY:
				paths = DraftArena.daily_paths(id, DraftArena.max_paths(Session.flags))
			if paths.is_empty():
				var count: int = DraftArena.choice_range(id)[0] if DraftArena.kind_of(id) == DraftArena.KIND_HIGH else 4
				for i: int in range(count):
					paths.append(DraftArena.PATHS[i])
	var row: HBoxContainer = UIKit.hbox(4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for path: int in paths:
		var badge: Control = DraftKit.path_badge(path, 46.0 if paths.size() <= 3 else 40.0, open)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(badge)
	return row


## Under the tiles: the chosen challenge in words, its choices (which three Paths, which dungeon, your own Paths), what it pays
## and the Start button (the mock-up's Rewards strip).
func _details() -> Control:
	var strip: PanelContainer = DraftKit.plaque(0.92, DraftKit.NIGHT, DraftKit.MARQUEE, 18, 16.0)
	strip.name = "Details"
	strip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var row: HBoxContainer = UIKit.hbox(18)
	strip.add_child(row)
	var words: VBoxContainer = UIKit.vbox(8)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	if _selected == TRIO:
		_selected = DraftArena.trio_ids()[0]
	if _selected == DUNGEONS:
		var keys: Array[String] = Session.draft_dungeon_keys()
		_selected = DraftArena.dungeon_id(keys[0]) if not keys.is_empty() else DUNGEONS
	var id: String = _selected
	var title: Label = UIKit.label(_tile_title(DUNGEONS) if id == DUNGEONS else DraftChallenges.title(id), &"", 38, DraftKit.MARQUEE)
	title.name = "DetailsTitle"
	words.add_child(title)
	if id == DUNGEONS:
		words.add_child(DraftKit.text("Any dungeon you have cleared with your own deck can be played again with a drafted one: the main dungeon of every freed zone, the mini dungeons, the vault and the postgame dungeons. Clear one first.", 26, DraftKit.CREAM))
		return strip
	words.add_child(DraftKit.text(DraftChallenges.summary(id), 26, DraftKit.CREAM))
	match DraftArena.kind_of(id):
		DraftArena.KIND_TRIO:
			words.add_child(_choice_row("Which three:", DraftArena.trio_ids(), func(choice: String) -> String: return DraftArena.path_names(DraftArena.fixed_paths(choice), ", ")))
		DraftArena.KIND_DUNGEON:
			var ids: Array[String] = []
			for key: String in Session.draft_dungeon_keys():
				ids.append(DraftArena.dungeon_id(key))
			words.add_child(_choice_row("Which dungeon:", ids, func(choice: String) -> String:
				var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(DraftArena.dungeon_key_of(choice))
				return plan.dungeon_name if plan != null else choice))
	if DraftArena.kind_of(id) == DraftArena.KIND_DAILY:
		var today: HBoxContainer = UIKit.hbox(10)
		today.name = "DailyPaths"
		today.add_child(UIKit.label("Today's Paths:", &"", 24, GlassTheme.SECONDARY))
		today.add_child(DraftKit.path_row(DraftArena.daily_paths(id, DraftArena.max_paths(Session.flags)), 52.0))
		words.add_child(today)
	elif DraftChallenges.fixed_paths(id).is_empty():
		words.add_child(_path_choice(id))
	var locked: String = DraftArena.locked_reason(id, Session.flags)
	var note: String = _notice if not _notice.is_empty() else locked
	if not note.is_empty():
		var warning: Label = DraftKit.text(note, 26, GlassTheme.CAUTION)
		warning.name = "Notice"
		words.add_child(warning)
	var side: VBoxContainer = UIKit.vbox(10)
	side.custom_minimum_size = Vector2(430, 0)
	side.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(side)
	side.add_child(DraftKit.chip("Rewards"))
	var pay: Label = DraftKit.text(_reward_words(id), 24, GlassTheme.GOOD)
	pay.name = "RewardLine"
	side.add_child(pay)
	var start: FancyButton = DraftKit.button("Start", "Start", func() -> void: _start(id), Vector2(420, 84), &"PrimaryButton")
	start.add_theme_font_size_override("font_size", 40)
	start.disabled = not locked.is_empty()
	side.add_child(start)
	return strip


## A row of small buttons that changes which challenge the tile stands for (which three Paths, which dungeon).
func _choice_row(caption: String, ids: Array[String], words: Callable) -> Control:
	var flow: HFlowContainer = HFlowContainer.new()
	flow.name = "Choices"
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 6)
	flow.add_child(UIKit.label(caption, &"", 24, GlassTheme.SECONDARY))
	for choice: String in ids:
		var pick: FancyButton = FancyButton.make(str(words.call(choice)), &"GhostButton", Vector2(0, 46))
		pick.name = "Choice_%s" % choice.replace(":", "_").replace("+", "_")
		pick.add_theme_font_size_override("font_size", 22)
		pick.toggle_mode = true
		pick.button_pressed = choice == _selected
		pick.pressed.connect(func() -> void:
			_selected = choice
			_notice = ""
			_refresh())
		flow.add_child(pick)
	return flow


## The Paths of a draft with a free choice: four toggles, as many on as the challenge and the story allow.
func _path_choice(id: String) -> Control:
	var bounds: Array[int] = DraftArena.choice_range(id)
	var most: int = mini(bounds[1], DraftChallenges.max_open_paths(Session.flags))
	var least: int = bounds[0]
	if _paths.is_empty() and Session.profile != null:
		_paths.append(int(Session.profile.primary_affinity) if int(Session.profile.primary_affinity) != 0 else DraftKit.PATH_ORDER[0])
	while _paths.size() > maxi(most, 1):
		_paths.pop_back()
	if least == 4:
		_paths = DraftArena.PATHS.duplicate()
	var row: HBoxContainer = UIKit.hbox(10)
	row.name = "PathChoice"
	var caption: String = "Your Paths (all four):" if least == 4 else ("Your Paths (%s):" % ("one" if most <= 1 else ("exactly %d" % least if least == most else "up to %d" % most)))
	row.add_child(UIKit.label(caption, &"", 24, GlassTheme.SECONDARY))
	for path: int in DraftKit.PATH_ORDER:
		var toggle: Button = Button.new()
		toggle.name = "Path_%d" % path
		toggle.flat = true
		toggle.toggle_mode = true
		toggle.button_pressed = _paths.has(path)
		toggle.custom_minimum_size = Vector2(64, 64)
		toggle.tooltip_text = Affinity.display_name(path as Affinity.Type)
		var badge: Control = DraftKit.path_badge(path, 58.0, _paths.has(path))
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		toggle.add_child(badge)
		toggle.disabled = least == 4
		toggle.pressed.connect(func() -> void: _toggle_path(path, most))
		row.add_child(toggle)
	row.add_child(UIKit.label(DraftArena.path_names(_paths), &"", 24, DraftKit.CREAM))
	return row


func _toggle_path(path: int, most: int) -> void:
	if _paths.has(path):
		if _paths.size() > 1:
			_paths.erase(path)
	elif most <= 1:
		_paths = [path] as Array[int]
	elif _paths.size() < most:
		_paths.append(path)
	else:
		_paths.pop_front()
		_paths.append(path)
	_notice = ""
	_refresh()


func _reward_words(id: String) -> String:
	var won: bool = Session.flag(StringName(DraftChallenges.won_flag(id)))
	var after_primm: bool = Session.flag(MultiPathLock.FLAG_UNLOCKED)
	if DraftArena.is_dungeon(id):
		var table: Dictionary = DraftRules.dungeon_rewards()
		var extra: String = DraftKit.pack_name(str(table.get("extra_pack_after_primm", "prismatic")) if after_primm else str(table.get("extra_pack", "gilded_general")))
		if id == DraftArena.HALLS_ID:
			return "A clear: %d gold, %d XP, a General Pack and %s; keep one card.%s" % [int(table.get("halls_clear_gold", 0)), int(table.get("halls_clear_xp", 0)), extra, "" if won else "  The first clear: a piece of draft equipment, a Gilded Pack and more gold on top."]
		return "A clear: the dungeon's own clear rewards, plus %s; keep one card.  Every fight won pays a little even if the run ends." % extra
	var paths: Array[int] = DraftChallenges.fixed_paths(id) if not DraftChallenges.fixed_paths(id).is_empty() else _paths
	if DraftArena.kind_of(id) == DraftArena.KIND_DAILY:
		paths = DraftArena.daily_paths(id, DraftArena.max_paths(Session.flags))
	var full: Dictionary = DraftChallenges.reward(3, true, not won, id, paths, after_primm)
	return "Three wins: %s%s; keep one card.  Fewer wins still pay gold and XP." % [DraftKit.reward_words(full), "" if won else " (the first time)"]


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
