extends GutTest
## Oct 20, Part 5: quest objectives are revealed one at a time - the steps done (checked) and the current step, never a later one (the rest
## is one "???" line), in the core rule, the HUD tracker and the Quest Log - and no quest's title, summary or step names a twist early.

## Words that would spoil a reveal if a quest showed them before it happens.
const SPOILERS: Array[String] = [
	"Compostella", "Doppelg", "fake Chef", "fake Grand Chef", "free Grandmaster Flex", "Warmth", "The Cells", "The Coup", "A Name",
	"prince", "Siphon", "Elowen", "Rescuer", "Path-ology", "Lab ", "Warden",
]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.level_track_grants = false


func _texts(quest: QuestData) -> Array[String]:
	var result: Array[String] = [quest.title, Villain.fill(quest.summary)]
	for objective: QuestObjective in quest.objectives:
		result.append(objective.text)
	return result


func test_no_quest_exposes_a_step_beyond_the_current_one() -> void:
	for quest: QuestData in QuestCatalog.all():
		for step: int in range(quest.objectives.size()):
			Session.new_game()
			Session.ensure_game(Affinity.Type.BEEFCAKE)
			Session.level_track_grants = false
			DevActions.set_quest_step(quest.id, step)
			var state: UnlockState = Session.unlock_state()
			var qlog: QuestLog = Session.quest_log
			if not qlog.is_active(quest.id) or qlog.is_ready_to_turn_in(quest, state):
				continue
			var current: int = qlog.current_index(quest, state)
			var shown: Array[int] = qlog.visible_steps(quest, state)
			assert_eq(shown.size(), current + 1, "%s at step %d shows the steps done and the current one" % [quest.id, step])
			for index: int in shown:
				assert_true(index <= current, "%s: step %d is never past the current %d" % [quest.id, index, current])
				if index < current:
					assert_true(qlog.objective_met(quest, index, state), "%s: every earlier step shown is done" % quest.id)
			assert_eq(qlog.hidden_steps(quest, state), quest.objectives.size() - current - 1)


func test_a_later_step_met_early_stays_hidden_until_its_turn() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	Session.quest_log.completed.erase(quest.id)
	Session.quest_log.active.append(quest.id)
	Session.set_flag(&"tailor_seen")  # the last step, done first
	var shown: Array[int] = Session.quest_log.visible_steps(quest, Session.unlock_state())
	assert_eq(shown, [0] as Array[int], "only the current step (Sable) shows")


func test_a_finished_quest_shows_every_step() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("gourmand"))
	DevActions.set_quest_step(quest.id, 0)
	Session.quest_log.active.erase(quest.id)
	Session.quest_log.completed.append(quest.id)
	assert_eq(Session.quest_log.visible_steps(quest, Session.unlock_state()).size(), quest.objectives.size())
	assert_eq(Session.quest_log.hidden_steps(quest, Session.unlock_state()), 0)


func _label_text(root: Node) -> String:
	var text: String = ""
	for node: Node in root.find_children("*", "Label", true, false):
		text += (node as Label).text + "\n"
	return text


func test_the_hud_tracker_shows_only_the_current_step_and_question_marks() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("refusemancer"))
	DevActions.set_quest_step(quest.id, 1)
	Session.quest_log.track(quest.id)
	var tracker: QuestTracker = QuestTracker.new()
	add_child_autofree(tracker)
	await wait_process_frames(2)
	tracker.refresh()
	await wait_process_frames(1)
	var text: String = _label_text(tracker)
	assert_string_contains(text, quest.objectives[0].text, "the step done is shown")
	assert_string_contains(text, quest.objectives[1].text, "the current step is shown")
	assert_false(text.contains(quest.objectives[2].text), "the next step is not")
	assert_false(text.contains(quest.objectives[3].text), "nor the last")
	assert_string_contains(text, QuestLog.HIDDEN_STEPS_TEXT)


func test_the_quest_log_shows_only_the_current_step_and_question_marks() -> void:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.zone_main_id("gourmand"))
	DevActions.set_quest_step(quest.id, 0)
	Session.quest_log.track(quest.id)
	var screen: QuestLogScreen = QuestLogScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(3)
	screen._selected = quest.id
	screen._refresh()
	await wait_process_frames(2)
	var text: String = _label_text(screen)
	assert_string_contains(text, quest.objectives[0].text)
	for index: int in range(1, quest.objectives.size()):
		assert_false(text.contains(quest.objectives[index].text), "step %d stays hidden: %s" % [index + 1, quest.objectives[index].text])
	assert_string_contains(text, QuestLog.HIDDEN_STEPS_TEXT)


func test_no_quest_text_names_a_twist() -> void:
	for quest: QuestData in QuestCatalog.all():
		for text: String in _texts(quest):
			for word: String in SPOILERS:
				assert_false(text.to_lower().contains(word.to_lower()), "%s: \"%s\" in \"%s\"" % [quest.id, word, text])


func test_every_step_still_says_what_to_do() -> void:
	for quest: QuestData in QuestCatalog.all():
		for objective: QuestObjective in quest.objectives:
			assert_gt(objective.text.length(), 10, "%s: a real instruction (%s)" % [quest.id, objective.text])
			assert_lt(objective.text.length(), 80, "%s: short enough for the HUD (%s)" % [quest.id, objective.text])
