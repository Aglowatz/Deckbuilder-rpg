class_name QuestMigration
extends RefCounted
## Overnight Oct 16: upgrades a quest log saved before quest categories, ordered objectives and milestone rewards (`QuestLog.version` 1).
## - "Clear the Paths" is retired (each zone's MAIN line starts with its gatekeeper now): it leaves the active list.
## - A zone counts as already entered when its rift station is unlocked or it was freed (the new "Cross into..." steps read `entered_<zone>`).
## - The new auto-given MAIN lines start at once; anything the save had already done is settled WITHOUT paying again (no retroactive packs
##   or gear for steps done before milestones existed, so an old save cannot double-dip), and a line whose every step is done is filed as
##   completed silently.
## Pure rules: works on the log, the catalog and the flags it is handed.


static func migrate(qlog: QuestLog, catalog: Array[QuestData], flags: Dictionary, state: UnlockState) -> void:
	if qlog.version >= QuestLog.VERSION:
		return
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
	for quest: QuestData in catalog:
		if qlog.is_active(quest.id):
			qlog.progress_seen[quest.id] = qlog.progress_value(quest, state)
	qlog.version = QuestLog.VERSION
