extends GutTest
## Overnight Oct 23, Part 6: three campaigns, each with its own folder of saves (CampaignSlots); campaign 1 is the old save folder.

var _old_root: String
var _old_dir: String
var _old_active: int


func before_each() -> void:
	_old_root = CampaignSlots.root
	_old_dir = SaveSlots.dir
	_old_active = CampaignSlots.active
	CampaignSlots.root = "user://test_campaigns/"
	for campaign: int in range(1, CampaignSlots.COUNT + 1):
		CampaignSlots.delete(campaign)


func after_each() -> void:
	for campaign: int in range(1, CampaignSlots.COUNT + 1):
		CampaignSlots.delete(campaign)
	CampaignSlots.root = _old_root
	SaveSlots.dir = _old_dir
	CampaignSlots.active = _old_active


func _write(campaign: int, level: int, saved_at: int, primary: int) -> void:
	CampaignSlots.activate(campaign)
	var data: Dictionary = {"level": level, "primary": primary, "save_format": Session.SAVE_FORMAT, "playtime": 125.0,
		"meta": {"saved_at": saved_at, "level": level, "location": "Crosspath", "playtime": 125.0}}
	assert_true(SaveSlots.write(SaveSlots.AUTOSAVE, data, null))


func test_campaign_one_is_the_old_folder_and_the_others_have_their_own() -> void:
	assert_eq(CampaignSlots.dir_for(1), CampaignSlots.root)
	assert_ne(CampaignSlots.dir_for(2), CampaignSlots.dir_for(3))
	CampaignSlots.activate(2)
	assert_eq(SaveSlots.dir, CampaignSlots.dir_for(2), "saving follows the active campaign")


func test_info_most_recent_copy_and_delete() -> void:
	assert_eq(CampaignSlots.most_recent(), -1)
	_write(1, 4, 1000, int(Affinity.Type.BEEFCAKE))
	_write(3, 9, 2000, int(Affinity.Type.GOURMAND))
	assert_eq(CampaignSlots.most_recent(), 3, "Continue loads the newest campaign")
	var info: Dictionary = CampaignSlots.info(3)
	assert_eq(int(info["level"]), 9)
	assert_eq(int(info["path"]), int(Affinity.Type.GOURMAND))
	assert_true(CampaignSlots.is_empty(2))
	var lines: Array[String] = CampaignSlotsScreen.card_lines(3)
	assert_eq(lines[1], "Gourmand Path")
	assert_eq(lines[2], "Level 9")
	assert_eq(lines[3], "Crosspath")
	assert_string_contains(lines[4], "Play time")
	assert_string_contains(lines[5], "Last played")
	assert_eq(CampaignSlotsScreen.card_lines(2), ["Slot 2", "Empty"] as Array[String])
	assert_true(CampaignSlots.copy(3, 2))
	assert_eq(int(CampaignSlots.info(2)["level"]), 9, "a copy")
	CampaignSlots.delete(3)
	assert_true(CampaignSlots.is_empty(3))
	assert_false(CampaignSlots.is_empty(1), "deleting one campaign leaves the others")
	assert_false(CampaignSlots.is_empty(2))


func test_deleting_campaign_one_keeps_the_other_folders() -> void:
	_write(2, 5, 1000, int(Affinity.Type.NECROCRAT))
	_write(1, 3, 900, int(Affinity.Type.NECROCRAT))
	CampaignSlots.delete(1)
	assert_true(CampaignSlots.is_empty(1))
	assert_false(CampaignSlots.is_empty(2), "campaign 2 lives in a folder inside campaign 1's and survives")
