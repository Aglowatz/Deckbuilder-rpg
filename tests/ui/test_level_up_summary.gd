extends GutTest
## Overnight Oct 17 (Phase 2 cycle 22): several levels at once -> "All N levels on one page" shows every remaining reward, then Continue finishes.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_summary_lists_every_remaining_level() -> void:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup([ProgressionTable.row(2), ProgressionTable.row(3), ProgressionTable.row(4)] as Array[LevelData])
	add_child_autofree(screen)
	await wait_frames(2)
	var all_button: FancyButton = screen.find_child("AllLevelsButton", true, false) as FancyButton
	assert_not_null(all_button, "three levels: the one-page button is offered")
	assert_eq(all_button.text, "All 3 levels on one page")
	screen.show_summary()
	await wait_frames(2)
	assert_not_null(screen.find_child("LevelSummary", true, false))
	var headers: int = 0
	for node: Node in screen.find_child("LevelSummary", true, false).find_children("*", "Label", true, false):
		if (node as Label).text.begins_with("Level ") and not (node as Label).text.begins_with("Level up"):
			headers += 1
	assert_eq(headers, 3, "one header per level")
	watch_signals(screen)
	screen.advance()
	assert_signal_emitted(screen, "finished")


func test_a_single_level_has_no_summary_button() -> void:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup([ProgressionTable.row(2)] as Array[LevelData])
	add_child_autofree(screen)
	await wait_frames(2)
	assert_null(screen.find_child("AllLevelsButton", true, false))
