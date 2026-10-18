extends GutTest
## Overnight Oct 17, Part 9: the first battles teach Resources by doing (made by an Infrastructure, spent on a unit or by a card,
## then why they matter), and the first deck edit is a tiny quest. The windowed tools/run_first_battles_smoke.sh plays it.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func _ids() -> Array[String]:
	var ids: Array[String] = []
	for step: Dictionary in TutorialLayer.STEPS:
		ids.append(str(step["id"]))
	return ids


func test_the_resource_steps_come_right_after_the_first_infrastructure() -> void:
	var ids: Array[String] = _ids()
	for id: String in ["resource_made", "resource_use", "resource_spend", "resource_why"]:
		assert_true(ids.has(id), id)
	assert_lt(ids.find("energy"), ids.find("resource_made"), "made right after the energy lesson")
	assert_lt(ids.find("resource_made"), ids.find("resource_use"))
	assert_lt(ids.find("resource_use"), ids.find("resource_why"))
	assert_lt(ids.find("resource_why"), ids.find("trap"), "before the later topics")


func test_every_starter_path_has_a_card_that_spends_or_a_resource_with_its_own_use() -> void:
	var content: ContentSet = Session.content
	for path: Affinity.Type in Affinity.colored_types():
		var kind: int = ResourceKind.created_by_basic(path)
		if ResourceKind.has_use_ability(kind as ResourceKind.Kind):
			continue
		var spends: bool = false
		for card: CardData in CampaignStart.path_package(content, path):
			if TutorialLayer._spends(card):
				spends = true
		assert_true(spends, "%s's starter package can spend its Resource" % Affinity.display_name(path))


func test_prompts_are_short() -> void:
	for step: Dictionary in TutorialLayer.STEPS:
		assert_lt(str(step["text"]).length(), 280, "%s is short" % step["id"])


func test_the_first_deck_edit_quest_starts_after_the_cave_and_ends_with_a_save() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.refresh_quests()
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(QuestDefinitions.FIRST_DECK_EDIT), "auto-given once the trial is cleared")
	Session.save_deck_to_slot(0, Session.deck, "Main")
	assert_true(Session.quest_log.is_completed(QuestDefinitions.FIRST_DECK_EDIT))


func test_veteran_saves_skip_the_first_deck_edit() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.add_xp(ProgressionTable.xp_to_reach(4))
	Session.quest_log.active.erase(QuestDefinitions.FIRST_DECK_EDIT)
	Session.quest_log.completed.erase(QuestDefinitions.FIRST_DECK_EDIT)
	assert_true(Session.from_dict(Session.to_dict()))
	assert_true(Session.quest_log.is_completed(QuestDefinitions.FIRST_DECK_EDIT))
