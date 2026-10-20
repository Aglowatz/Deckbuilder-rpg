class_name QuestMigration
extends RefCounted
## Overnight Oct 16: upgrades a quest log saved before quest categories, ordered objectives and milestone rewards (`QuestLog.version` 1).
## - "Clear the Paths" is retired (each zone's MAIN line starts with its gatekeeper now): it leaves the active list.
## - A zone counts as already entered when its rift station is unlocked or it was freed (the new "Cross into..." steps read `entered_<zone>`).
## - The new auto-given MAIN lines start at once; anything the save had already done is settled WITHOUT paying again (no retroactive packs
##   or gear for steps done before milestones existed, so an old save cannot double-dip), and a line whose every step is done is filed as
##   completed silently.
## Oct 20, Part 4 (version 2 -> 3): the story's main quests now wait for Maren's early-game chain (`QuestDefinitions.story_gate`). A save
## from before that which is already out of the Forgotten Cave (or already holds a story quest) is past that point: it gets
## `QuestDefinitions.LEGACY_FLAG`, so it keeps every quest it has and keeps receiving the story quests; nothing it already has is locked
## again. Its unfinished chain errands stay as they are (Maren takes them back and hands out the next ones as usual).
## Pure rules: works on the log, the catalog and the flags it is handed.

## Quests whose presence in a log means the save already had the story's main quests.
const STORY_QUESTS: Array[String] = [
	"main_beefcake", "main_necrocrat", "main_gourmand", "main_refusemancer", "free_the_kingdom", "fragments", "clear_the_paths",
]


static func migrate(qlog: QuestLog, catalog: Array[QuestData], flags: Dictionary, state: UnlockState) -> void:
	if qlog.version >= QuestLog.VERSION:
		return
	if is_past_early_chain(qlog, flags):
		flags[QuestDefinitions.LEGACY_FLAG] = true
		state.flags[QuestDefinitions.LEGACY_FLAG] = true
	if qlog.version < 2:
		_migrate_v1(qlog, catalog, flags, state)
	for quest: QuestData in catalog:
		if qlog.is_active(quest.id):
			qlog.progress_seen[quest.id] = qlog.progress_value(quest, state)
	qlog.version = QuestLog.VERSION


## True for a save from before the early-game chain that is already past it: out of the cave, or holding any story quest.
static func is_past_early_chain(qlog: QuestLog, flags: Dictionary) -> bool:
	if bool(flags.get("trial_cleared", false)):
		return true
	for quest_id: String in STORY_QUESTS:
		if qlog.is_active(quest_id) or qlog.is_completed(quest_id):
			return true
	return false


static func _migrate_v1(qlog: QuestLog, catalog: Array[QuestData], flags: Dictionary, state: UnlockState) -> void:
	for zone_id: String in Gatekeepers.IDS:
		if bool(flags.get(str(FastTravel.unlock_flag(zone_id)), false)) or bool(flags.get(str(ZoneCompletion.flag_name(zone_id)), false)):
			flags[str(Gatekeepers.entered_flag(zone_id))] = true
	qlog.active.erase(QuestDefinitions.RETIRED_PATHS)
	if qlog.tracked == QuestDefinitions.RETIRED_PATHS:
		qlog.tracked = ""
	for quest: QuestData in catalog:
		if qlog.is_completed(quest.id):
			continue
		if not qlog.is_active(quest.id):
			if not quest.auto_give or not qlog.can_start(quest, state):
				continue
			qlog.start(quest, state)
		qlog.settle_milestones(quest, state)
		if quest.turn_in_npc.is_empty() and qlog.all_objectives_met(quest, state):
			qlog.complete(quest.id)
