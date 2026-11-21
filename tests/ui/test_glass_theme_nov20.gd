extends GutTest
## Fable Nov 20 day (Part 2): the stained-glass info screens. One theme (GlassTheme) that every info screen reads; the rules of the style
## guide - one amber button per screen, no pale grey text, lit glass for the chosen thing, colour only where a Path is meant, and
## body text at 4.5:1 or better. The contrast numbers are written to docs/review/glass_contrast.txt.

const INFO_SCREEN_FILES: Array[String] = [
	"res://ui/screens/pause_menu.gd", "res://ui/screens/settings_panel.gd", "res://ui/screens/glossary_panel.gd", "res://ui/screens/feats_panel.gd",
	"res://ui/screens/credits_panel.gd", "res://ui/screens/save_slots_screen.gd", "res://ui/quests/quest_log_screen.gd", "res://ui/town/codex_screen.gd",
	"res://ui/minimap/full_map_screen.gd", "res://ui/widgets/confirm_dialog.gd",
]


func before_each() -> void:
	GlassTheme.reset()  # another test may have emptied the art cache the theme's textures came from
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(1)


func _average(id: String, from: Vector2, to: Vector2, tint: Color = Color.WHITE) -> Color:
	var image: Image = UiArt.texture(id).get_image()
	if image.is_compressed():
		image.decompress()
	var size: Vector2i = image.get_size()
	var sum: Color = Color(0, 0, 0, 0)
	var count: int = 0
	for y: int in range(int(size.y * from.y), int(size.y * to.y), 2):
		for x: int in range(int(size.x * from.x), int(size.x * to.x), 2):
			sum += image.get_pixel(x, y)
			count += 1
	var c: Color = sum / float(count)
	return Color(c.r * tint.r, c.g * tint.g, c.b * tint.b)


func test_the_set_is_in_the_game_and_there_is_one_theme() -> void:
	assert_true(GlassTheme.available())
	var theme: Theme = GlassTheme.theme()
	assert_same(theme, GlassTheme.theme(), "built once, the same resource for every screen")
	for type_name: String in ["PanelContainer", "GlassPage", "GlassPopup", "GlassTooltip", "GlassQuestBox", "GlassRow", "RewardPanel", "TooltipPanel"]:
		assert_true(theme.has_stylebox("panel", type_name), "%s has its glass panel" % type_name)
	for type_name: String in ["Button", "PrimaryButton", "DangerButton", "GhostButton", "OptionButton"]:
		for state: String in ["normal", "hover", "pressed", "focus"]:
			assert_true(theme.has_stylebox(state, type_name), "%s: %s" % [type_name, state])
	for bar: String in ["VScrollBar", "HScrollBar"]:
		assert_true(theme.get_stylebox("grabber", bar) is StyleBoxTexture, "%s: the painted grip" % bar)
		assert_true(theme.get_stylebox("scroll", bar) is StyleBoxTexture, "%s: the painted rail" % bar)
	assert_eq((theme.get_stylebox("panel", "GlassPage") as StyleBoxTexture).texture, UiArt.scaled_texture(GlassTheme.PAGE_ART, GlassTheme.PAGE_FACTOR), "the page is UI-INFO-PAGE")


func test_body_text_is_readable_on_the_real_glass() -> void:
	var page: Color = _average(GlassTheme.PAGE_ART, Vector2(0.3, 0.3), Vector2(0.7, 0.7))
	var popup: Color = _average(GlassTheme.POPUP_ART, Vector2(0.3, 0.3), Vector2(0.7, 0.7))
	var quest_box: Color = _average(GlassTheme.QUESTBOX_ART, Vector2(0.3, 0.3), Vector2(0.7, 0.7))
	var row: Color = _average(GlassTheme.PANE_ART, Vector2(0.3, 0.35), Vector2(0.7, 0.65), GlassTheme.ROW)
	var slate: Color = _average(GlassTheme.BUTTON_ART, Vector2(0.3, 0.4), Vector2(0.7, 0.7), GlassTheme.SLATE)
	var tab_lit: Color = _average(GlassTheme.PANE_LIT_ART, Vector2(0.3, 0.35), Vector2(0.7, 0.65), GlassTheme.SLATE_LIT)
	var amber: Color = _average(GlassTheme.AMBER_ART, Vector2(0.3, 0.4), Vector2(0.7, 0.7))
	var pairs: Array = [
		["body text on the page", GlassTheme.TEXT, page, 4.5], ["secondary text on the page", GlassTheme.SECONDARY, page, 4.5],
		["headings on the page", GlassTheme.TITLE, page, 4.5], ["body text on a pop-up / tooltip", GlassTheme.TEXT, popup, 4.5],
		["secondary text on a pop-up", GlassTheme.SECONDARY, popup, 4.5], ["body text in the quest box", GlassTheme.TEXT, quest_box, 4.5],
		["secondary text in the quest box", GlassTheme.SECONDARY, quest_box, 4.5], ["body text on a row plate", GlassTheme.TEXT, row, 4.5],
		["secondary text on a row plate", GlassTheme.SECONDARY, row, 4.5], ["a slate button's label", GlassTheme.TEXT, slate, 4.5],
		["the caution label on slate", GlassTheme.CAUTION, slate, 3.0], ["ink on a lit tab", GlassTheme.INK, tab_lit, 4.5],
		["ink on the amber button", GlassTheme.AMBER_INK, amber, 4.5],
	]
	for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]:
		var lit: Color = _average(GlassTheme.PANE_LIT_ART, Vector2(0.3, 0.35), Vector2(0.7, 0.65), GlassTheme.lit(PathPalette.main(path)))
		var rest: Color = _average(GlassTheme.PANE_ART, Vector2(0.3, 0.35), Vector2(0.7, 0.65), PathPalette.main(path).darkened(0.45))
		pairs.append(["ink on a lit %s pane (the chosen quest)" % UIStyle.affinity_name(path), GlassTheme.INK, lit, 4.5])
		pairs.append(["text on a %s pane at rest" % UIStyle.affinity_name(path), GlassTheme.TEXT, rest, 4.5])
	var lines: PackedStringArray = ["Stained-glass info screens: contrast (WCAG ratio; body text needs 4.5, large bold labels 3.0).",
		"Made by tests/ui/test_glass_theme_nov20.gd from the real art (the middle of each piece, tinted as the game tints it).", ""]
	for entry: Array in pairs:
		var ratio: float = GlassTheme.contrast(entry[1] as Color, entry[2] as Color)
		lines.append("%-48s #%s on #%s   %.1f : 1   (needs %.1f)" % [str(entry[0]), (entry[1] as Color).to_html(false), (entry[2] as Color).to_html(false), ratio, float(entry[3])])
		assert_gte(ratio, float(entry[3]), "%s: %.2f" % [str(entry[0]), ratio])
	var file: FileAccess = FileAccess.open("res://docs/review/glass_contrast.txt", FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()


func test_no_pale_grey_text_in_the_info_screens() -> void:
	for path: String in INFO_SCREEN_FILES:
		var source: String = FileAccess.get_file_as_string(path)
		assert_false(source.is_empty(), path)
		for line: String in source.split("\n"):
			if line.contains("UIStyle.MUTED") and not line.contains("GlassTheme"):
				fail_test("%s still paints text pale grey: %s" % [path, line.strip_edges().left(100)])
	assert_gt(GlassTheme.SECONDARY.b, GlassTheme.SECONDARY.r, "secondary text is a blue-violet tint of the page, not grey")
	assert_gt(GlassTheme.SECONDARY.s, 0.15)
	assert_eq(GlassTheme.theme().get_color("font_color", "MutedLabel"), GlassTheme.SECONDARY)


func test_every_info_screen_reads_the_theme() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var settings: SettingsPanel = SettingsPanel.new()
	holder.add_child(settings)
	var glossary: GlossaryPanel = GlossaryPanel.make()
	holder.add_child(glossary)
	var feats: FeatsPanel = FeatsPanel.make()
	holder.add_child(feats)
	var credits: CreditsPanel = CreditsPanel.make()
	holder.add_child(credits)
	var slots: SaveSlotsScreen = SaveSlotsScreen.make(SaveSlotsScreen.Mode.LOAD)
	holder.add_child(slots)
	var dialog: ConfirmDialog = ConfirmDialog.ask(holder, "Quit the game?", "Your game is saved before it closes.", "Quit", "Keep playing", true)
	var tracker: QuestTracker = QuestTracker.new()
	holder.add_child(tracker)
	var frame: PopupFrame = PopupFrame.make("REWARD", "ICON-GOLD")
	holder.add_child(frame)
	await wait_frames(2)
	for screen: Control in [settings, glossary, feats, credits, slots, dialog, tracker, frame]:
		assert_same(screen.theme, GlassTheme.theme(), "%s reads the glass theme" % screen.get_class() + " " + str(screen.name))
	assert_eq(tracker.theme_type_variation, &"GlassQuestBox")
	var quest_log: OverlayScreen = (load("res://ui/quests/quest_log_screen.gd") as GDScript).new() as OverlayScreen
	assert_true(quest_log.glass, "the quest log is a glass page")
	quest_log.free()
	for script_path: String in ["res://ui/minimap/full_map_screen.gd", "res://ui/town/codex_screen.gd"]:
		assert_true(FileAccess.get_file_as_string(script_path).contains("	glass = true"), "%s is a glass page" % script_path)
	var shop: OverlayScreen = (load("res://ui/town/tailor_screen.gd") as GDScript).new() as OverlayScreen
	assert_false(shop.glass, "a shop keeps its gold-framed screen")
	shop.free()
	# the pieces: the strip on top, the title between the divider's diamonds, plates under the settings
	assert_not_null(settings.find_child("GlassStrip", true, false))
	assert_not_null(settings.find_child("GlassTitle", true, false))
	var plated: int = 0
	for plate: Node in settings.find_children("Row_*", "PanelContainer", true, false):
		if (plate as PanelContainer).theme_type_variation == &"GlassRow":
			plated += 1
	assert_gt(plated, 5, "the settings sit on plates of glass")
	# the pop-up is the small dark panel
	assert_not_null(dialog.find_children("*", "PanelContainer", true, false).filter(func(p: Node) -> bool: return (p as PanelContainer).theme_type_variation == &"GlassPopup").front())


func _primary_buttons(root_node: Node) -> Array[Button]:
	var found: Array[Button] = []
	for node: Node in root_node.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.theme_type_variation == &"PrimaryButton" and button.is_visible_in_tree() and not button.is_queued_for_deletion():
			found.append(button)
	return found


func test_one_amber_button_per_screen() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var menu: PauseMenu = PauseMenu.new()
	add_child_autofree(menu)
	menu.visible = true
	await wait_frames(3)
	var primary: Array[Button] = _primary_buttons(menu)
	assert_eq(primary.size(), 1, "the pause menu has one amber button")
	if primary.size() == 1:
		assert_eq(primary[0].text, "Resume")
	assert_not_null(menu.find_child("Emblem", true, false), "the rose window tops the menu")
	assert_eq((menu.find_child("Emblem", true, false) as TextureRect).texture, UiArt.texture(GlassTheme.ROSE_ART))
	menu.visible = false
	for mode: int in [SaveSlotsScreen.Mode.LOAD, SaveSlotsScreen.Mode.SAVE]:
		var slots: SaveSlotsScreen = SaveSlotsScreen.make(mode as SaveSlotsScreen.Mode)
		holder.add_child(slots)
		await wait_frames(2)
		assert_lte(_primary_buttons(slots).size(), 1, "the save / load list has at most one amber button")
		slots.free()
	var danger: ConfirmDialog = ConfirmDialog.ask(holder, "Delete this save?", "It cannot be brought back.", "Delete", "Keep it", true)
	await wait_frames(2)
	var safe: Array[Button] = _primary_buttons(danger)
	assert_eq(safe.size(), 1)
	if safe.size() == 1:
		assert_eq(safe[0].text, "Keep it", "for a dangerous question the amber button is the safe answer")
	danger.free()
	var settings: SettingsPanel = SettingsPanel.new()
	holder.add_child(settings)
	await wait_frames(2)
	for page: int in range(SettingsPanel.PAGES.size()):
		settings.show_page(page)
		await wait_frames(2)
		assert_eq(_primary_buttons(settings).size(), 1, "settings, %s: one amber button (Done)" % SettingsPanel.PAGES[page])


func test_lit_glass_marks_the_chosen_tab() -> void:
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var glossary: GlossaryPanel = GlossaryPanel.make()
	holder.add_child(glossary)
	glossary.show_tab(2)
	await wait_frames(2)
	var lit: int = 0
	for tab: Node in glossary.find_children("Tab_*", "Button", true, false):
		var button: Button = tab as Button
		assert_true(button.toggle_mode)
		assert_almost_eq(button.modulate.a, 1.0, 0.01, "no tab is faded")
		if button.button_pressed:
			lit += 1
			assert_eq(button.name, &"Tab_Statuses")
	assert_eq(lit, 1, "exactly one tab is the lit pane")
	var theme: Theme = GlassTheme.theme()
	assert_eq((theme.get_stylebox("pressed", "GhostButton") as StyleBoxTexture).texture, UiArt.scaled_texture(GlassTheme.PANE_LIT_ART, GlassTheme.PANE_FACTOR), "chosen = UI-GLASS-PANE-LIT")
	assert_eq((theme.get_stylebox("normal", "GhostButton") as StyleBoxTexture).texture, UiArt.scaled_texture(GlassTheme.PANE_ART, GlassTheme.PANE_FACTOR), "at rest = UI-GLASS-PANE")


func test_a_quest_wears_its_zones_colour_and_a_quest_of_no_zone_is_slate() -> void:
	for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT]:
		var quest: QuestData = QuestCatalog.find("main_%s" % PackRules.zone_for_path(path))
		assert_not_null(quest)
		assert_eq(QuestLogScreen.quest_path(quest), path)
		assert_eq(QuestLogScreen.quest_glass(quest), PathPalette.main(path), "the colour comes from path_palette.json")
	var plain: QuestData = QuestData.new()
	plain.id = "side_of_nowhere"
	plain.giver_area = "town"
	assert_eq(QuestLogScreen.quest_path(plain), Affinity.Type.NEUTRAL)
	assert_eq(QuestLogScreen.quest_glass(plain), GlassTheme.SLATE_LIT, "no Path: slate, not a Path colour")
	# the Path's icon stands beside its colour
	var tag: PanelContainer = GlassTheme.path_tag(Affinity.Type.GOURMAND, "The Endless Buffet")
	add_child_autofree(tag)
	assert_gt(tag.find_children("*", "TextureRect", true, false).size(), 0, "a Path tag carries the Path's icon")


func test_the_quest_box_uses_the_painted_marks_and_never_fades_a_step() -> void:
	Session.start_quest("main_gourmand", false)
	var tracker: QuestTracker = QuestTracker.new()
	add_child_autofree(tracker)
	await wait_frames(2)
	tracker.refresh()
	await wait_frames(2)
	if not tracker.visible:
		pass_test("no quest is tracked in this state")
		return
	assert_gt(tracker.find_children("QuestMark", "TextureRect", true, false).size(), 0, "the steps wear the painted marks")
	for row: Node in tracker.find_children("Objective", "HBoxContainer", true, false):
		for label: Node in row.find_children("*", "Label", true, false):
			var colour: Color = (label as Label).get_theme_color("font_color")
			assert_almost_eq(colour.a, 1.0, 0.01, "a step is never half see-through")


func test_the_three_marks_are_three_cells_of_one_strip() -> void:
	var seen: Dictionary = {}
	for which: int in [GlassTheme.Mark.OPEN, GlassTheme.Mark.DONE, GlassTheme.Mark.NEXT]:
		var mark: TextureRect = GlassTheme.mark(which as GlassTheme.Mark, 24.0)
		autofree(mark)
		var cell: AtlasTexture = mark.texture as AtlasTexture
		assert_not_null(cell)
		assert_eq(cell.atlas, UiArt.texture(GlassTheme.MARKS_ART))
		seen[cell.region.position.x] = true
	assert_eq(seen.size(), 3)
