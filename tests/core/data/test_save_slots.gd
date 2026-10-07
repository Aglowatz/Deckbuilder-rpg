extends GutTest
## Brief 16, Group E: manual save slots + the autosave: round-trips through two slots, overwrite and delete, the autosave staying separate, the migration of the
## old single save into slot 1 and the slot list data (name, date, playtime, level, location, gold).

var _content: ContentSet
var _old_dir: String
var _old_path: String


func before_all() -> void:
	_content = ContentLibrary.load_all()


func before_each() -> void:
	_old_dir = SaveSlots.dir
	_old_path = Session.save_path
	SaveSlots.dir = "user://test_saves/"
	for slot: int in range(0, SaveSlots.SLOT_COUNT + 1):
		SaveSlots.delete(slot)
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.GOURMAND)
	Session.deck = CampaignStart.starter_deck(_content, Affinity.Type.GOURMAND)
	Session.set_flag(&"trial_cleared")
	Session.gold = 100


func after_each() -> void:
	for slot: int in range(0, SaveSlots.SLOT_COUNT + 1):
		SaveSlots.delete(slot)
	SaveSlots.dir = _old_dir
	Session.save_path = _old_path
	Session.save_enabled = true
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_saves/"))


func test_there_are_five_manual_slots_and_one_autosave() -> void:
	assert_eq(SaveSlots.SLOT_COUNT, 5)
	assert_true(SaveSlots.is_valid_slot(0) and SaveSlots.is_valid_slot(5))
	assert_false(SaveSlots.is_valid_slot(6))
	assert_eq(SaveSlots.slot_label(0), "Autosave")
	assert_eq(SaveSlots.slot_label(3), "Slot 3")


func test_two_slots_round_trip_independently() -> void:
	Session.playtime_seconds = 3725.0
	Session.gold = 111
	assert_true(Session.save_to_slot(1, "First"))
	Session.gold = 222
	Session.profile.level = 4
	Session.playtime_seconds = 9000.0
	assert_true(Session.save_to_slot(2, "Second"))
	Session.new_game()
	assert_true(Session.load_from_slot(1))
	assert_eq(Session.gold, 111)
	assert_eq(Session.profile.level, 1)
	assert_almost_eq(Session.playtime_seconds, 3725.0, 0.1)
	assert_eq(Session.active_slot, 1)
	assert_true(Session.load_from_slot(2))
	assert_eq(Session.gold, 222)
	assert_eq(Session.profile.level, 4)
	assert_almost_eq(Session.playtime_seconds, 9000.0, 0.1)


func test_the_slot_list_shows_name_date_playtime_level_location_and_gold() -> void:
	Session.last_location = "The Gainlands"
	Session.playtime_seconds = 3725.0
	Session.profile.level = 3
	Session.save_to_slot(4, "Before the boss")
	var info: Dictionary = SaveSlots.info(4)
	assert_eq(str(info["name"]), "Before the boss")
	assert_gt(int(info["saved_at"]), 1700000000, "a real date")
	assert_almost_eq(float(info["playtime"]), 3725.0, 0.1)
	assert_eq(int(info["level"]), 3)
	assert_eq(int(info["gold"]), 100)
	assert_true(bool(info["compatible"]))
	assert_eq(SaveSlots.format_playtime(3725.0), "1h 02m")
	assert_true(SaveSlots.format_date(int(info["saved_at"])).length() == 16)
	assert_true(SaveSlots.info(5).is_empty(), "an empty slot has no info")


func test_overwriting_replaces_the_slot() -> void:
	Session.gold = 10
	Session.save_to_slot(1, "A")
	Session.gold = 20
	Session.save_to_slot(1, "B")
	assert_eq(str(SaveSlots.info(1)["name"]), "B")
	Session.load_from_slot(1)
	assert_eq(Session.gold, 20)


func test_deleting_a_slot_empties_it() -> void:
	Session.save_to_slot(3, "Gone soon")
	assert_true(SaveSlots.exists(3))
	SaveSlots.delete(3)
	assert_false(SaveSlots.exists(3))
	assert_false(Session.load_from_slot(3), "an empty slot cannot be loaded")


func test_the_autosave_is_separate_from_manual_slots() -> void:
	Session.save_enabled = true
	Session.save_path = SaveSystem.PATH
	Session.gold = 77
	Session.save_game()
	Session.save_enabled = false
	assert_true(SaveSlots.exists(SaveSlots.AUTOSAVE))
	assert_false(SaveSlots.exists(1), "a manual slot is not touched by autosaves")
	Session.gold = 5
	Session.save_to_slot(1, "Manual")
	Session.save_enabled = true
	Session.gold = 99
	Session.save_game()
	Session.save_enabled = false
	assert_eq(int(SaveSlots.info(1)["gold"]), 5, "slot 1 keeps its own state")
	assert_eq(int(SaveSlots.info(0)["gold"]), 99)


func test_latest_slot_is_the_most_recent_save() -> void:
	assert_eq(SaveSlots.latest_slot(), -1)
	Session.save_to_slot(2, "Older")
	var data: Dictionary = SaveSlots.load_data(2)
	(data["meta"] as Dictionary)["saved_at"] = 1700000000
	SaveSystem.write(data, SaveSlots.path_for(2))
	Session.save_to_slot(4, "Newer")
	assert_eq(SaveSlots.latest_slot(), 4)


func test_the_old_single_save_moves_into_slot_one() -> void:
	var legacy_backup: String = ""
	var had_legacy: bool = FileAccess.file_exists(SaveSlots.LEGACY_PATH)
	if had_legacy:
		legacy_backup = FileAccess.get_file_as_string(SaveSlots.LEGACY_PATH)
	Session.gold = 321
	Session.profile.level = 2
	var data: Dictionary = Session.to_dict()
	data.erase("meta")
	SaveSystem.write(data, SaveSlots.LEGACY_PATH)
	assert_true(SaveSlots.migrate_legacy())
	assert_false(FileAccess.file_exists(SaveSlots.LEGACY_PATH), "the old file was renamed")
	assert_true(SaveSlots.exists(1))
	assert_eq(int(SaveSlots.info(1)["gold"]), 321)
	assert_eq(str(SaveSlots.info(1)["name"]), "Earlier save")
	assert_true(Session.load_from_slot(1))
	assert_eq(Session.gold, 321)
	DirAccess.remove_absolute(SaveSlots.LEGACY_PATH + ".migrated")
	if had_legacy:
		var file: FileAccess = FileAccess.open(SaveSlots.LEGACY_PATH, FileAccess.WRITE)
		file.store_string(legacy_backup)


func test_loading_returns_the_hero_to_where_the_save_was_made() -> void:
	Session.last_location = "The Endless Buffet"
	Session.save_to_slot(1, "Zone save")
	var data: Dictionary = SaveSlots.load_data(1)
	(data["meta"] as Dictionary)["scene"] = "zone:gourmand"
	SaveSystem.write(data, SaveSlots.path_for(1))
	Session.load_from_slot(1)
	assert_eq(Session.pending_resume_scene, "zone:gourmand")
	assert_eq(Session.last_location, "The Endless Buffet")


func test_saving_is_blocked_during_a_battle() -> void:
	Session.pending_battle = Session.make_ninja_battle()
	assert_false(Session.can_save_now())
	Session.pending_battle = null
