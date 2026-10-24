class_name CampaignSlots
extends RefCounted
## Overnight Oct 23, Part 6: three separate campaigns, each in its own save folder with its own autosave (+ crash-safe backup) and its own
## manual save slots (`SaveSlots`). Campaign 1 is the folder the game always used (`user://saves/`), so an existing save simply IS
## campaign 1 - nothing is moved; campaigns 2 and 3 live in `user://saves/campaign_2/` and `campaign_3/`. Picking a campaign points
## `SaveSlots.dir` at its folder, so every save, load, backup and the Report a Problem copy follow the active campaign.

const COUNT: int = 3

## The folder of campaign 1 (tests and tools point it somewhere else).
static var root: String = "user://saves/"
## The campaign being played (1..COUNT).
static var active: int = 1


static func dir_for(campaign: int) -> String:
	return root if campaign <= 1 else root.path_join("campaign_%d/" % campaign)


static func is_valid(campaign: int) -> bool:
	return campaign >= 1 and campaign <= COUNT


## Makes `campaign` the one every save and load uses.
static func activate(campaign: int) -> void:
	if not is_valid(campaign):
		return
	active = campaign
	SaveSlots.dir = dir_for(campaign)


## The newest save (autosave or manual) of a campaign as SaveSlots.info, plus "path" (Affinity.Type) and "campaign"; {} when empty.
static func info(campaign: int) -> Dictionary:
	var saved_dir: String = SaveSlots.dir
	SaveSlots.dir = dir_for(campaign)
	var slot: int = SaveSlots.latest_slot()
	var found: Dictionary = SaveSlots.info(slot) if slot >= 0 else {}
	if not found.is_empty():
		var data: Dictionary = SaveSlots.load_data(slot)
		found["path"] = int(data.get("primary", int(Affinity.Type.NEUTRAL)))
		found["campaign"] = campaign
		found["latest_slot"] = slot
	SaveSlots.dir = saved_dir
	return found


static func is_empty(campaign: int) -> bool:
	return info(campaign).is_empty()


## The campaign saved most recently, or -1 when no campaign has a save.
static func most_recent() -> int:
	var best: int = -1
	var best_time: int = -1
	for campaign: int in range(1, COUNT + 1):
		var found: Dictionary = info(campaign)
		if found.is_empty():
			continue
		if int(found.get("saved_at", 0)) > best_time:
			best_time = int(found.get("saved_at", 0))
			best = campaign
	return best


static func any_save() -> bool:
	return most_recent() >= 1


## The save files of a campaign's folder (top level only: campaign 1's folder also holds the other campaigns' folders).
static func files_of(campaign: int) -> Array[String]:
	var result: Array[String] = []
	var dir: DirAccess = DirAccess.open(dir_for(campaign))
	if dir == null:
		return result
	for file: String in dir.get_files():
		if file.ends_with(".json") or file.ends_with(".png") or file.ends_with(".bak") or file.ends_with(".tmp"):
			result.append(file)
	result.sort()
	return result


## Deletes every save of a campaign (its autosave, backup, manual slots and thumbnails). Other campaigns are untouched.
static func delete(campaign: int) -> void:
	if not is_valid(campaign):
		return
	for file: String in files_of(campaign):
		DirAccess.remove_absolute(dir_for(campaign).path_join(file))


## Copies campaign `from` over campaign `to` (whatever `to` held is deleted first). False when `from` is empty or they are the same.
static func copy(from: int, to: int) -> bool:
	if not is_valid(from) or not is_valid(to) or from == to or is_empty(from):
		return false
	delete(to)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_for(to)))
	for file: String in files_of(from):
		if file.ends_with(".tmp"):
			continue
		DirAccess.copy_absolute(dir_for(from).path_join(file), dir_for(to).path_join(file))
	return true
