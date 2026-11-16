extends GutTest
## Overnight Nov 16 (Part 3.1): a test run can never write the player's real saves (`SaveGuard`). Every way a test has reached the real
## folder before is tried here on purpose - the default paths, saving switched back on, the campaign folders, an absolute path - and
## the real folder must look exactly as it did when the run started.


var _old_dir: String
var _old_root: String
var _old_save_path: String
var _old_enabled: bool
var _old_feats: String


func before_each() -> void:
	_old_dir = SaveSlots.dir
	_old_root = CampaignSlots.root
	_old_save_path = Session.save_path
	_old_enabled = Session.save_enabled
	_old_feats = FeatAccount.path


func after_each() -> void:
	SaveSlots.dir = _old_dir
	CampaignSlots.root = _old_root
	CampaignSlots.active = 1
	Session.save_path = _old_save_path
	Session.save_enabled = _old_enabled
	FeatAccount.path = _old_feats


func _untouched(what: String) -> void:
	var changed: Array[String] = SaveGuard.changed_files(SaveGuard.startup_fingerprint, SaveGuard.real_fingerprint())
	assert_eq(changed, [] as Array[String], "%s: the player's real files are as they were when the run started" % what)


func test_a_gut_run_is_test_mode() -> void:
	assert_true(SaveGuard.test_mode(), "GUT on the command line means test mode, whatever other flags were passed")


func test_paths_into_the_real_save_folder_are_redirected() -> void:
	assert_eq(SaveGuard.redirected("user://saves/autosave.json"), "user://test_saves/saves/autosave.json")
	assert_eq(SaveGuard.redirected("user://saves/campaign_2/slot_3.json"), "user://test_saves/saves/campaign_2/slot_3.json")
	assert_eq(SaveGuard.redirected("user://saves/autosave.json.bak"), "user://test_saves/saves/autosave.json.bak")
	assert_eq(SaveGuard.redirected("user://saves/"), "user://test_saves/saves/")
	assert_eq(SaveGuard.redirected("user://saves"), "user://test_saves/saves")
	assert_eq(SaveGuard.redirected("user://save.json"), "user://test_saves/save.json")
	assert_eq(SaveGuard.redirected("user://save.json.migrated"), "user://test_saves/save.json.migrated")
	assert_eq(SaveGuard.redirected("user://feats_account.json"), "user://test_saves/feats_account.json")
	assert_eq(SaveGuard.redirected("user://meta.cfg"), "user://test_saves/meta.cfg")
	assert_eq(SaveGuard.redirected("user://settings.cfg"), "user://test_saves/settings.cfg")
	# dodges: "..", a doubled slash, back slashes, the absolute path of the real folder
	assert_eq(SaveGuard.redirected("user://logs/../saves/autosave.json"), "user://test_saves/saves/autosave.json")
	assert_eq(SaveGuard.redirected("user://saves//autosave.json"), "user://test_saves/saves/autosave.json")
	var absolute: String = ProjectSettings.globalize_path("user://saves/autosave.json")
	assert_eq(SaveGuard.redirected(absolute), "user://test_saves/saves/autosave.json", "an absolute path into the user folder")
	assert_eq(SaveGuard.redirected(absolute.replace("/", "\\")), "user://test_saves/saves/autosave.json", "with back slashes")
	# everything else is left alone, and a redirected path is not redirected twice
	for other: String in ["user://test_saves/saves/autosave.json", "user://gut_temp_directory/session_autosave.json", "user://test_campaigns/slot_1.json", "user://saves_backup/a.json", "res://data/x.json"]:
		assert_eq(SaveGuard.redirected(other), other, "%s is not the player's file" % other)
	assert_true(SaveGuard.is_protected("user://saves/slot_1.json"))
	assert_false(SaveGuard.is_protected("user://test_saves/saves/slot_1.json"))


func test_the_save_system_s_default_path_lands_in_the_test_folder() -> void:
	assert_true(SaveSystem.write({"probe": 1}))
	assert_true(FileAccess.file_exists("user://test_saves/saves/autosave.json"), "the default autosave path was redirected")
	assert_eq(int(SaveSystem.read().get("probe", 0)), 1, "and reads come from the same place")
	assert_true(SaveSystem.write({"probe": 2}, ProjectSettings.globalize_path("user://saves/slot_4.json")), "an absolute path too")
	assert_true(FileAccess.file_exists("user://test_saves/saves/slot_4.json"))
	SaveSystem.delete()
	SaveSystem.delete("user://saves/slot_4.json")
	_untouched("SaveSystem at its default path")


func test_the_slots_and_campaigns_pointed_at_the_real_folder_land_in_the_test_folder() -> void:
	SaveSlots.dir = "user://saves/"
	CampaignSlots.root = "user://saves/"
	assert_true(SaveSlots.path_for(SaveSlots.AUTOSAVE).begins_with(SaveGuard.TEST_DIR))
	assert_true(SaveSlots.thumb_path(2).begins_with(SaveGuard.TEST_DIR))
	var picture: Image = Image.create(32, 18, false, Image.FORMAT_RGB8)
	assert_true(SaveSlots.write(SaveSlots.AUTOSAVE, {"level": 3}, picture))
	assert_true(SaveSlots.write(2, {"level": 4}, picture))
	assert_true(FileAccess.file_exists("user://test_saves/saves/slot_2.json"))
	assert_true(FileAccess.file_exists("user://test_saves/saves/slot_2.png"), "the thumbnail too")
	for campaign: int in [2, 3]:
		assert_true(CampaignSlots.dir_for(campaign).begins_with(SaveGuard.TEST_DIR), "campaign %d's folder" % campaign)
		CampaignSlots.activate(campaign)
		assert_true(SaveSlots.dir.begins_with(SaveGuard.TEST_DIR))
		assert_true(SaveSlots.write(1, {"level": 5}, null))
	CampaignSlots.copy(2, 3)  # (these bare probe saves count as empty campaigns; the call must still stay out of the real folder)
	CampaignSlots.delete(2)
	CampaignSlots.delete(3)
	CampaignSlots.activate(1)
	SaveSlots.delete(SaveSlots.AUTOSAVE)
	SaveSlots.delete(2)
	_untouched("the slots and the campaigns")


func test_the_session_with_saving_switched_back_on_lands_in_the_test_folder() -> void:
	# what twelve test files did before Nov 12: saving on, at the real default path
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.save_enabled = true
	Session.save_path = SaveSystem.PATH
	SaveSlots.dir = "user://saves/"
	Session.save_game()
	assert_true(FileAccess.file_exists("user://test_saves/saves/autosave.json"), "the autosave went to the test folder")
	assert_true(Session.has_save())
	assert_false(Session.discard_incompatible_save(), "a fresh save is compatible")
	Session.save_enabled = false
	SaveSlots.delete(SaveSlots.AUTOSAVE)
	_untouched("the Session saving at the default path")


func test_the_legacy_save_migration_never_renames_the_player_s_old_save() -> void:
	SaveSlots.dir = "user://saves/"
	SaveSlots.migrate_legacy()
	_untouched("migrate_legacy")


func test_the_account_feats_the_title_memory_and_the_settings_are_written_to_the_test_folder() -> void:
	FeatAccount.path = "user://feats_account.json"
	FeatAccount.reset()
	FeatAccount.record("save_guard_probe", true)
	assert_true(FileAccess.file_exists("user://test_saves/feats_account.json"))
	FeatAccount.reset()
	TitleMeta.mark_postgame()
	assert_true(FileAccess.file_exists("user://test_saves/meta.cfg"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_saves/meta.cfg"))
	Settings.save_settings()
	assert_true(FileAccess.file_exists("user://test_saves/settings.cfg"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_saves/settings.cfg"))
	_untouched("the feats, the title's memory and the settings")


func test_zz_the_real_save_folder_is_untouched_by_this_run() -> void:
	# whatever ran before this file in the same process (the full suite runs in shards of ten files): nothing of the player's changed
	_untouched("every test that ran before this one in this process")
