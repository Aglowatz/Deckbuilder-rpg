extends GutTest
## Overnight Nov 9-10 (Part 4.1): the one "Text size" switch (Normal / Large / Larger) sets dialogue, card and tooltip text together;
## the per-kind rows still work and the switch shows "Custom" when they differ. Saved like the rest.

var _saved: Array[int] = []


func before_each() -> void:
	_saved = [Settings.text_dialogue, Settings.text_cards, Settings.text_tooltips]


func after_each() -> void:
	Settings.text_dialogue = _saved[0]
	Settings.text_cards = _saved[1]
	Settings.text_tooltips = _saved[2]
	Settings.apply_tooltip_theme()


func test_the_master_sets_all_three_kinds() -> void:
	Settings.set_text_master(1)
	assert_eq([Settings.text_dialogue, Settings.text_cards, Settings.text_tooltips], [2, 2, 2])
	assert_eq(Settings.text_master_level(), 1)
	assert_almost_eq(Settings.dialogue_text_scale(), 1.2, 0.001)
	Settings.set_text_master(2)
	assert_almost_eq(Settings.tooltip_text_scale(), 1.4, 0.001)
	assert_gt(Settings.tooltip_font(18), 24)
	Settings.set_text_master(0)
	assert_eq(Settings.text_master_level(), 0)
	assert_almost_eq(Settings.card_text_scale(), 1.0, 0.001)


func test_a_mixed_choice_reads_as_custom() -> void:
	Settings.set_text_master(0)
	Settings.text_cards = 3
	assert_eq(Settings.text_master_level(), -1)
	Settings.text_cards = 1
	Settings.text_dialogue = 0
	Settings.text_tooltips = 0
	assert_eq(Settings.text_master_level(), -1, "Small everywhere is a per-kind choice, not a master level")


func test_the_choice_is_saved_and_loaded() -> void:
	var path: String = "user://test_text_size_master_nov10.cfg"
	Settings.set_text_master(1)
	Settings.save_settings(path)
	Settings.set_text_master(0)
	Settings.load_settings(path)
	assert_eq(Settings.text_master_level(), 1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_the_settings_page_has_the_switch() -> void:
	var panel: SettingsPanel = SettingsPanel.new()
	panel.autosave = false
	add_child_autofree(panel)
	panel.show_page(1)
	await get_tree().process_frame
	var options: OptionButton = panel.find_child("TextSizeOptions", true, false) as OptionButton
	assert_not_null(options, "Settings > Text has a Text size switch")
	if options == null:
		return
	assert_eq(options.get_item_text(0), "Normal")
	assert_eq(options.get_item_text(2), "Larger")
	options.item_selected.emit(1)
	assert_eq(Settings.text_master_level(), 1)
	var cards: OptionButton = panel.find_child("CardTextOptions", true, false) as OptionButton
	assert_eq(cards.selected, 2, "the per-kind rows follow the switch")
