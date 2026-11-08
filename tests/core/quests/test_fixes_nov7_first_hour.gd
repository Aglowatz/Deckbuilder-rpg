extends GutTest
## Fix pass Nov 7, Part 1 (critic items 1, 4, 5 with owner decisions D2, D3, D6): the Path choice gives and tracks that Path's gatekeeper
## line with a standing "Your Path" line; Maren's errands are the "Settling In" side line; Wild Growth waits until round 3 on a main
## dungeon's first nodes; the cave's second duel is a real step and the Warden's swarm smaller; the Refusemancer starter is sturdier.

const PATHS: Array[Affinity.Type] = [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func after_each() -> void:
	Session.save_enabled = true


func test_the_path_choice_starts_and_tracks_that_paths_gatekeeper_line() -> void:
	for path: Affinity.Type in PATHS:
		Session.new_game()
		Session.choose_starting_path(path)
		var zone_id: String = PathDirection.zone_of(path)
		var own: String = QuestDefinitions.zone_main_id(zone_id)
		assert_true(Session.flag(StringName(QuestDefinitions.own_path_flag(zone_id))), "%s: the own-Path flag" % zone_id)
		assert_true(Session.quest_log.is_active(own), "%s: its line starts at the choice" % zone_id)
		assert_eq(Session.quest_log.tracked_id(), own, "%s: and is tracked" % zone_id)
		for other: String in Gatekeepers.IDS:
			if other != zone_id:
				assert_false(Session.quest_log.is_active(QuestDefinitions.zone_main_id(other)), "the other lines wait for town (%s)" % other)


func test_the_story_opens_on_arrival_in_town_without_the_errands() -> void:
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.set_flag(&"trial_cleared")
	Session.offer_auto_quests()
	for zone_id: String in Gatekeepers.IDS:
		assert_true(Session.quest_log.is_active(QuestDefinitions.zone_main_id(zone_id)), "every gatekeeper can be fought at any point: %s" % zone_id)
	assert_true(Session.quest_log.is_active(MemoryDefs.QUEST_ID), "Fragments too")
	assert_false(Session.quest_log.is_completed(QuestDefinitions.ARMORY))
	assert_eq(Session.quest_log.tracked_id(), PathDirection.own_main_quest(Affinity.Type.BEEFCAKE), "the Path line stays tracked")


func test_errands_are_the_settling_in_side_line() -> void:
	for quest_id: String in [QuestDefinitions.MERCHANTS, QuestDefinitions.FIRST_DECK_EDIT, QuestDefinitions.GHOSTS, QuestDefinitions.ARMORY]:
		var quest: QuestData = QuestCatalog.find(quest_id)
		assert_eq(quest.line, QuestDefinitions.SETTLING_IN, quest_id)
		assert_eq(quest.category, QuestData.Category.SIDE, quest_id)
		assert_eq(quest.category_tag(), "SETTLING IN")


func test_an_old_save_learns_its_own_path_on_load() -> void:
	Session.choose_starting_path(Affinity.Type.REFUSEMANCER)
	var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	(data["flags"] as Dictionary).erase(QuestDefinitions.own_path_flag("refusemancer"))
	assert_true(Session.from_dict(data))
	assert_true(Session.flag(StringName(QuestDefinitions.own_path_flag("refusemancer"))))


func test_your_path_line_names_the_gatekeeper_and_the_road_until_beaten() -> void:
	var flags: Dictionary = {}
	assert_eq(PathDirection.tracker_line(Affinity.Type.BEEFCAKE, flags), "Face Brick Bronson on the Gainlands road")
	for path: Affinity.Type in PATHS:
		var line: String = PathDirection.tracker_line(path, flags)
		var zone_id: String = PathDirection.zone_of(path)
		assert_string_contains(line, CorruptedNpcs.display_name(zone_id).get_slice(",", 0))
		assert_string_contains(line, PathDirection.road_of(zone_id))
	flags[str(CorruptedNpcs.unlock_flag("beefcake"))] = true
	assert_eq(PathDirection.tracker_line(Affinity.Type.BEEFCAKE, flags), "", "gone once the gatekeeper is beaten")


func test_marens_cave_mouth_lines_name_the_gatekeeper_and_the_road() -> void:
	for path: Affinity.Type in PATHS:
		var zone_id: String = PathDirection.zone_of(path)
		var text: String = "\n".join(PathDirection.lines(path, PathDirection.CAVE_TEXT_KEY))
		assert_false(text.contains("{"), "every token filled")
		assert_string_contains(text, CorruptedNpcs.display_name(zone_id).get_slice(",", 0))
		assert_string_contains(text, PathDirection.road_of(zone_id))
		assert_string_contains(text, ZoneDefs.get_def(zone_id).display_name)


func test_marens_path_talk_waits_for_her_greeting_not_the_armory() -> void:
	Session.choose_starting_path(Affinity.Type.GOURMAND)
	Session.set_flag(&"trial_cleared")
	assert_false(PathDirection.due(Session.quest_log, Session.flags, Affinity.Type.GOURMAND), "not before she has greeted the hero")
	Session.set_flag(&"elder_greeted")
	assert_true(PathDirection.due(Session.quest_log, Session.flags, Affinity.Type.GOURMAND), "right after, armory or not")


func test_wild_growth_waits_until_round_3_on_the_first_nodes() -> void:
	var first: ModifierSource = DungeonRules.shared_source("refusemancer", 2)
	var later: ModifierSource = DungeonRules.shared_source("refusemancer", 6)
	assert_eq(_growth(first).value2, DungeonRules.GROWTH_DELAY_ROUND, "node 2 delays it")
	assert_lte(_growth(later).value2, 1, "node 6 grows from the start")
	assert_lte(_growth(DungeonRules.shared_source("refusemancer", 2)).value2, DungeonRules.GROWTH_DELAY_ROUND)
	# the shared rule data is never changed by the delay
	assert_lte(_growth(DungeonRules.shared_source("refusemancer", 0)).value2, 1)


func test_growth_start_round_reads_the_modifiers() -> void:
	var game: GameState = GameFactory.new_game(5)
	assert_eq(game.growth_start_round(), 1)
	var delayed: Modifier = CardBuilder.modifier(Modifier.Kind.OVERGROWTH, 1, Modifier.ANY_COLOR, 3)
	game.players[0].modifiers.modifiers.append(delayed)
	assert_eq(game.growth_start_round(), 3)
	assert_eq(game.current_round(), 1)


func test_the_cave_is_smoothed() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var stalker: DungeonMap.MapNode = null
	for map_node: DungeonMap.MapNode in map.nodes:
		if map_node.enemy_name == "Hollow Stalker":
			stalker = map_node
	assert_not_null(stalker)
	assert_between(stalker.enemy_hp, 4, 6, "duel 2 at 4-6 HP (Overnight Nov 7-8 ramp 3 -> 5 -> 9)")
	assert_true(TrialOfTheHollow.enemy_recipe("Hollow Stalker").has("C-05"), "with a blocker")
	var warden: Dictionary = TrialOfTheHollow.enemy_recipe("Hollow Warden")
	var units: int = 0
	for id: Variant in warden.keys():
		if not str(id).begins_with("BAS-"):
			units += int(warden[id])
	assert_lte(units, 6, "a smaller Warden swarm")


func test_the_refusemancer_starter_is_sturdier() -> void:
	var recipe: Dictionary = CampaignStart.STARTING_DECKS[Affinity.Type.REFUSEMANCER] as Dictionary
	var total: int = 0
	for id: Variant in recipe.keys():
		total += int(recipe[id])
	assert_eq(total, CampaignStart.SPELL_COUNT)
	assert_false(recipe.has("C-15"), "no 4-cost Desperate Measures")
	assert_eq(int(recipe.get("C-03", 0)), 3)
	assert_eq(int(recipe.get("R-05", 0)), 1)


func test_the_map_tip_states_the_dungeon_rule() -> void:
	var text: String = DungeonMapScreen.map_tip_text()
	assert_string_contains(text, "Leaving resets this dungeon. Cards and gold you've won are kept.")
	assert_false(text.contains("fee"), "no defeat fee (D1)")


func _growth(source: ModifierSource) -> Modifier:
	for modifier: Modifier in source.modifiers:
		if modifier.kind == Modifier.Kind.OVERGROWTH:
			return modifier
	return Modifier.new()


## Overnight Nov 7-8, Part 0 (critic CF #3): the cave ramps 3 -> 5 -> boss 9.
func test_the_cave_ramps_up_to_the_boss() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var hp: Dictionary = {}
	for map_node: DungeonMap.MapNode in map.nodes:
		if map_node.enemy_name != "":
			hp[map_node.enemy_name] = map_node.enemy_hp
	assert_lt(int(hp["Cave Scavenger"]), int(hp["Hollow Stalker"]))
	assert_lt(int(hp["Hollow Stalker"]), int(hp["Hollow Warden"]))
	assert_between(int(hp["Hollow Warden"]), 8, 10)
