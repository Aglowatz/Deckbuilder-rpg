extends GutTest
## Nov 27 day (Part A): fixes found by the random-play soak bot (`tools/soak_bot.gd`), one test each.


## The bot's first trial pressed Copy on the title's campaign screen in a `--no-save` run and copied campaign 1 over the owner's
## campaign 3: `--no-save` stopped the autosave but not the campaign screen's Copy and Delete. A `--no-save` run is now a protected
## run (SaveGuard redirects every save-system path under user://test_saves/), like a GUT run or WAYWARD_TEST_SAVES=1.
func test_a_no_save_run_is_protected_by_the_save_guard() -> void:
	assert_true(SaveGuard.detects(PackedStringArray(["--no-save"]), ""), "a --no-save run is a protected run")
	assert_true(SaveGuard.detects(PackedStringArray(["--no-save", "--script=x.txt"]), ""), "with other arguments too")
	assert_true(SaveGuard.detects(PackedStringArray([]), "1"), "WAYWARD_TEST_SAVES=1 still protects")
	assert_false(SaveGuard.detects(PackedStringArray(["--seed=3"]), ""), "a normal run is not redirected")
	assert_false(SaveGuard.detects(PackedStringArray([]), "0"), "WAYWARD_TEST_SAVES=0 is a normal run")


## Every tool that drives the real game window with `--no-save` therefore never reaches the player's campaign folders.
func test_the_campaign_folders_are_redirected_in_a_protected_run() -> void:
	assert_true(SaveGuard.test_mode(), "the test run is protected")
	for campaign: int in range(1, CampaignSlots.COUNT + 1):
		var real: String = "user://saves/" if campaign == 1 else "user://saves/campaign_%d/" % campaign
		assert_ne(SaveGuard.safe(real), real, "campaign %d is redirected" % campaign)
		assert_true(SaveGuard.safe(real).begins_with(SaveGuard.TEST_DIR), "under the test folder")


## The soak bot itself refuses to press Copy, Delete, Restore or Start Over, and refuses to run unless the save guard is on.
func test_the_soak_bot_never_presses_save_file_buttons() -> void:
	var source: String = FileAccess.get_file_as_string("res://tools/soak_bot.gd")
	for word: String in ["\"copy\"", "\"delete\"", "\"restore\"", "\"start over\"", "\"overwrite\""]:
		assert_true(source.contains(word), "the deny list holds %s" % word)
	assert_true(source.contains("SaveGuard.test_mode()"), "the bot checks the save guard before it plays")
	assert_true(FileAccess.get_file_as_string("res://tools/soak_bot.sh").contains("WAYWARD_TEST_SAVES=1"), "the wrapper sets the guard")
