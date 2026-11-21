extends GutTest
## Fable Nov 21 review (Part 1.6): the info screens follow the Text size setting (MenuText). At Normal nothing is touched; at Large and
## Larger the theme's sizes and every explicit label size under a glass screen grow by the menu factor; cards keep their own setting.


var _saved_tooltips: int = 1


func before_each() -> void:
	_saved_tooltips = Settings.text_tooltips
	MenuText.forced_scale = -1.0


func after_each() -> void:
	Settings.text_tooltips = _saved_tooltips
	MenuText.forced_scale = -1.0
	MenuText.refresh()
	GlassTheme.reset()


func _screen() -> PanelContainer:
	var root: PanelContainer = PanelContainer.new()
	var column: VBoxContainer = UIKit.vbox(8)
	column.name = "Column"
	root.add_child(column)
	var sized: Label = UIKit.label("A quest step", &"", 20)
	sized.name = "Sized"
	column.add_child(sized)
	var plain: Label = UIKit.label("Theme size")
	plain.name = "Plain"
	column.add_child(plain)
	add_child_autofree(root)
	return root


func test_the_menu_factor_follows_the_tooltip_and_menu_row() -> void:
	Settings.text_tooltips = 0
	assert_eq(MenuText.scale(), 1.0, "Small never shrinks a menu")
	Settings.text_tooltips = 1
	assert_eq(MenuText.scale(), 1.0)
	Settings.text_tooltips = 2
	assert_gt(MenuText.scale(), 1.1)
	Settings.text_tooltips = 3
	assert_gt(MenuText.scale(), MenuText.SCALES[2])
	Settings.set_text_master(1)
	assert_eq(MenuText.scale(), MenuText.SCALES[2], "the Text size switch at Large reaches the menus")


func test_at_normal_nothing_is_touched() -> void:
	Settings.text_tooltips = 1
	var root: PanelContainer = _screen()
	MenuText.follow(root)
	var sized: Label = root.find_child("Sized", true, false) as Label
	assert_eq(sized.get_theme_font_size(&"font_size"), 20)
	assert_false(sized.has_meta(MenuText.META_BASE), "no bookkeeping at the default size")


func test_large_scales_explicit_sizes_and_the_theme() -> void:
	if not GlassTheme.available():
		pass_test("no glass art in this build")
		return
	Settings.text_tooltips = 3
	MenuText.refresh()
	var root: PanelContainer = _screen()
	GlassTheme.apply(root)
	var sized: Label = root.find_child("Sized", true, false) as Label
	var plain: Label = root.find_child("Plain", true, false) as Label
	assert_eq(sized.get_theme_font_size(&"font_size"), MenuText.size(20), "an explicit 20 px is 26 px at Larger")
	assert_eq(plain.get_theme_font_size(&"font_size"), MenuText.size(22), "the theme's body size grew too")
	# a second pass never compounds
	MenuText.rescale(root)
	assert_eq(sized.get_theme_font_size(&"font_size"), MenuText.size(20))
	# back to Normal: the screen's own sizes return
	Settings.text_tooltips = 1
	MenuText.refresh()
	assert_eq(sized.get_theme_font_size(&"font_size"), 20)
	assert_eq(plain.get_theme_font_size(&"font_size"), 22)


func test_a_label_built_later_is_scaled_too() -> void:
	if not GlassTheme.available():
		pass_test("no glass art in this build")
		return
	Settings.text_tooltips = 2
	MenuText.refresh()
	var root: PanelContainer = _screen()
	GlassTheme.apply(root)
	var late: Label = UIKit.label("Built after the page opened", &"", 18)
	root.find_child("Column", true, false).add_child(late)
	await wait_frames(2)
	assert_eq(late.get_theme_font_size(&"font_size"), MenuText.size(18))
	# a size the screen sets again later is the new base, not a scaled one scaled twice
	late.add_theme_font_size_override("font_size", 30)
	MenuText.rescale(root)
	assert_eq(late.get_theme_font_size(&"font_size"), MenuText.size(30))


func test_cards_and_skipped_nodes_keep_their_size() -> void:
	Settings.text_tooltips = 3
	MenuText.refresh()
	var root: PanelContainer = _screen()
	var kept: Label = UIKit.label("The dialogue sample", &"", 27)
	MenuText.skip(kept)
	root.get_child(0).add_child(kept)
	var holder: CardView = CardView.new()
	root.get_child(0).add_child(holder)
	var inside: Label = UIKit.label("card text", &"", 16)
	holder.add_child(inside)
	MenuText.follow(root)
	await wait_frames(2)
	assert_eq(kept.get_theme_font_size(&"font_size"), 27)
	assert_eq(inside.get_theme_font_size(&"font_size"), 16, "a card's text follows the card setting, not the menu's")


func test_the_real_screens_grow_at_larger_and_fit_the_screen() -> void:
	if not GlassTheme.available():
		pass_test("no glass art in this build")
		return
	Settings.text_tooltips = 3
	MenuText.refresh()
	var limit: Vector2 = Vector2(1920, 1080)
	for make: Callable in [func() -> Control: return GlossaryPanel.make(), func() -> Control: return FeatsPanel.make(), func() -> Control: return CreditsPanel.make()]:
		var page: Control = make.call() as Control
		add_child_autofree(page)
		await wait_frames(3)
		var min_size: Vector2 = page.get_combined_minimum_size()
		assert_lte(min_size.x, limit.x - 80.0, "%s is no wider than the screen at Larger (%.0f)" % [page.get_script().get_global_name(), min_size.x])
		assert_lte(min_size.y, limit.y - 60.0, "%s is no taller than the screen at Larger (%.0f)" % [page.get_script().get_global_name(), min_size.y])
	var settings_page: SettingsPanel = SettingsPanel.new()
	settings_page.autosave = false
	add_child_autofree(settings_page)
	await wait_frames(3)
	for index: int in range(SettingsPanel.PAGES.size()):
		settings_page.show_page(index)
		await wait_frames(2)
		var size_now: Vector2 = settings_page.get_combined_minimum_size()
		assert_lte(size_now.x, limit.x - 80.0, "Settings / %s is no wider than the screen at Larger (%.0f)" % [SettingsPanel.PAGES[index], size_now.x])
		assert_lte(size_now.y, limit.y - 60.0, "Settings / %s is no taller than the screen at Larger (%.0f)" % [SettingsPanel.PAGES[index], size_now.y])


## Part 6 (polish): the feats list stops short of its scroll bar ("Earned here" lay under the bar).
func test_the_feats_list_stops_short_of_the_scroll_bar() -> void:
	var page: FeatsPanel = FeatsPanel.make()
	add_child_autofree(page)
	await wait_frames(3)
	var scroll: ScrollContainer = _first_scroll(page)
	assert_not_null(scroll)
	if scroll == null:
		return
	var bar: VScrollBar = scroll.get_v_scroll_bar()
	var list: Control = scroll.get_child(0) as Control
	for child: Node in scroll.get_children():
		if child is VBoxContainer:
			list = child as Control
	assert_lte(list.size.x, scroll.size.x - maxf(bar.size.x, 24.0), "the rows end before the bar (%.0f of %.0f, bar %.0f)" % [list.size.x, scroll.size.x, bar.size.x])


func _first_scroll(node: Node) -> ScrollContainer:
	if node is ScrollContainer:
		return node as ScrollContainer
	for child: Node in node.get_children():
		var found: ScrollContainer = _first_scroll(child)
		if found != null:
			return found
	return null
