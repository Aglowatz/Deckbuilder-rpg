extends GutTest
## Overnight Nov 8-9, Part 1.1: the static quest completability audit (tools/quest_audit.gd) finds no errors. Warnings are for a human;
## `QUEST_AUDIT_WRITE=1` (tools/quest_audit.sh) writes the full report with the quest graph to docs/quests/quest_audit.md.


func test_every_quest_is_completable_on_paper() -> void:
	var audit: QuestAudit = QuestAudit.run()
	if OS.get_environment("QUEST_AUDIT_WRITE") == "1":
		var file: FileAccess = FileAccess.open("res://docs/quests/quest_audit.md", FileAccess.WRITE)
		if file != null:
			file.store_string(audit.report())
			file.close()
	assert_gt(audit.rows.size(), 40, "the audit saw the whole catalog")
	for e: String in audit.errors:
		gut.p("AUDIT ERROR: " + e)
	assert_eq(audit.errors.size(), 0, "quest audit errors:\n" + "\n".join(audit.errors))


func test_the_audit_catches_a_broken_quest() -> void:
	var audit: QuestAudit = QuestAudit.new()
	audit._scan()
	var broken: QuestData = QuestData.new()
	broken.id = "audit_probe"
	broken.giver_npc = "Nobody McNowhere"
	broken.giver_area = "town"
	broken.reward_item_ids = ["no_such_item"] as Array[String]
	broken.prerequisite = Condition.quest_completed("no_such_quest")
	broken.objectives = [QuestObjective.make("Do the impossible", Condition.flag("flag_nothing_sets_ever"))
		.at(QuestObjective.TargetKind.SPOT, "atlantis", "no_such_spot")] as Array[QuestObjective]
	audit._check_quest(broken)
	var text: String = "\n".join(audit.errors)
	for needle: String in ["no_such_item", "no_such_quest", "flag_nothing_sets_ever", "Nobody McNowhere", "atlantis", "no_such_spot"]:
		assert_string_contains(text, needle)


## The order trap the audit found: the Capital's recipe cards are once-ever pickups. Taken before Chef Marlo's quest, they still count.
func test_once_ever_pickups_taken_before_the_quest_still_count() -> void:
	var qlog: QuestLog = QuestLog.new()
	var state: UnlockState = UnlockState.new()
	state.counters[CapitalZone.COUNTER_RECIPES] = 3
	state.counters["dna_chests_opened"] = 4
	var recipes: QuestData = QuestCatalog.find(CapitalZone.QUEST_RECIPES)
	assert_not_null(recipes)
	assert_true(qlog.start(recipes, state))
	assert_true(qlog.objective_met(recipes, 0, state), "three recipe cards found before the quest still count")
	var audit_quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.AUDIT)
	assert_true(qlog.start(audit_quest, state))
	assert_true(qlog.objective_met(audit_quest, 1, state), "a stash opened before the audit still counts")
	# a repeatable counter still counts from acceptance
	state.counters["zone_enemies_defeated"] = 9
	var gerald: QuestData = QuestCatalog.find("side_s_necro")
	assert_true(qlog.start(gerald, state))
	assert_false(qlog.objective_met(gerald, 0, state), "roaming fights before the quest do not count")
	# an old save that already holds a baseline for a once-ever counter is unstuck
	qlog.baselines["%s|%s" % [CapitalZone.QUEST_RECIPES, CapitalZone.COUNTER_RECIPES]] = 3
	assert_true(qlog.objective_met(recipes, 0, state))
