extends GutTest
## Overnight Oct 17, Part 7: the level-up moment (full screen, the number, rewards revealed one by one, unlocks highlighted,
## skippable) and the reward boxes' one-by-one reveal.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _labels(root: Node) -> String:
	var texts: PackedStringArray = PackedStringArray()
	for label: Node in root.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	return " | ".join(texts)


func test_the_level_up_moment_shows_the_number_headline_and_rewards() -> void:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup([ProgressionTable.row(5)] as Array[LevelData])
	add_child_autofree(screen)
	await wait_process_frames(2)
	var joined: String = _labels(screen)
	assert_true(joined.contains("LEVEL UP"))
	assert_eq((screen.find_child("LevelNumber", true, false) as Label).text, "5")
	assert_true(joined.contains(ProgressionTable.row(5).headline), joined)
	assert_true(joined.contains("armory"), "the big unlock is listed")
	assert_true(joined.contains("NEW"), "and highlighted")


func test_unlock_lines_are_told_apart_from_number_lines() -> void:
	assert_true(LevelUpScreen.is_unlock("Deck Station: 4 to 6 deck slots."))
	assert_true(LevelUpScreen.is_unlock("Epic cards: up to 2 copies."))
	assert_false(LevelUpScreen.is_unlock("+1 starting HP (12)."))
	assert_false(LevelUpScreen.is_unlock("120 gold."))


func test_skipping_reveals_everything_then_moves_on() -> void:
	var screen: LevelUpScreen = LevelUpScreen.new()
	screen.setup([ProgressionTable.row(4), ProgressionTable.row(5)] as Array[LevelData])
	var done: Array[bool] = [false]
	screen.finished.connect(func() -> void: done[0] = true)
	add_child_autofree(screen)
	await wait_seconds(LevelUpScreen.GUARD_TIME + 0.1)
	assert_true(screen.is_revealing(), "rewards still coming in")
	screen.advance()
	assert_false(screen.is_revealing(), "the first press shows them all")
	assert_false(done[0])
	screen.advance()
	await wait_process_frames(1)
	assert_eq((screen.find_child("LevelNumber", true, false) as Label).text, "5", "the next level's moment")
	await wait_seconds(LevelUpScreen.GUARD_TIME + 0.1)
	screen.skip_all()
	assert_true(done[0], "Esc skips the rest")


func test_reward_boxes_reveal_their_rows_one_by_one() -> void:
	var summary: RewardSummary = Session.grant_chest_reward({"gold": 20, "equipment": "hover_boots"}, "Chest")
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await wait_process_frames(2)
	assert_true(popup.frame.is_revealing())
	assert_true(_labels(popup).contains("NEW GEAR!"))
	assert_true(_labels(popup).contains("Uncommon Boots"), "the gear's rarity is named")
	await wait_seconds(2.0)
	assert_false(popup.frame.is_revealing(), "short: everything is in within about a second")
