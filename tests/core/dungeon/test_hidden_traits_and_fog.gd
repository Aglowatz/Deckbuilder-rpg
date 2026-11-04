extends GutTest
## Overnight Nov 3-4, Parts B7 + B8: enemy triggers stay "Hidden trait ?" until they fired once in this save; dungeon fog per save (nodes
## "?" until stepped on, the name "???" until entered), saved, reset by a new game, migrated from old saves.

const BARON: String = "Baron Quadzilla"


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	EncounterScripts.hide_unseen = true


func _names(rules: Array[EncounterModifiers.Rule]) -> Array[String]:
	var names: Array[String] = []
	for rule: EncounterModifiers.Rule in rules:
		names.append(rule.name)
	return names


# ---- B7 ----------------------------------------------------------------------------------------------------------------------


func test_a_never_seen_trigger_reads_hidden_trait() -> void:
	assert_true(EncounterScripts.hide_unseen, "the game hides unseen triggers")
	var triggers: Array[EncounterScripts.Trigger] = EncounterScripts.triggers(BARON)
	assert_gt(triggers.size(), 1)
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules(BARON)
	var names: Array[String] = _names(rules)
	assert_has(names, EncounterScripts.HIDDEN_NAME)
	for each: EncounterScripts.Trigger in triggers:
		assert_does_not_have(names, each.name, "%s stays hidden" % each.name)
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_encounter(rules)
	var hidden: Array[RuleBadges.Badge] = []
	for badge: RuleBadges.Badge in badges:
		if badge.hidden:
			hidden.append(badge)
	assert_eq(hidden.size(), 1, "one chip for every unseen trigger")
	assert_eq(hidden[0].refs.size(), triggers.size())
	assert_eq(hidden[0].tooltip(), "Something happens in this fight you haven't seen yet.")


func test_after_it_fires_once_it_shows_in_every_later_description() -> void:
	var first: EncounterScripts.Trigger = EncounterScripts.triggers(BARON)[0]
	var ref: String = EncounterScripts.ref_of(BARON, first.id)
	var before: Array[RuleBadges.Badge] = RuleBadges.for_encounter(EncounterModifiers.rules(BARON))
	assert_true(Session.note_trigger_seen(ref))
	assert_false(Session.note_trigger_seen(ref), "only the first time counts")
	var revealed: Array[RuleBadges.Badge] = RuleBadges.reveal(before, ref, first)
	var revealed_names: Array[String] = []
	for badge: RuleBadges.Badge in revealed:
		revealed_names.append(badge.name)
	assert_has(revealed_names, first.name, "the battle row swaps in the real badge")
	assert_has(revealed_names, EncounterScripts.HIDDEN_NAME, "the other trigger is still unseen")
	var names: Array[String] = _names(EncounterModifiers.rules(BARON))
	assert_has(names, first.name, "the pre-fight description shows it from now on")
	# saved per save, gone in a new game
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_does_not_have(_names(EncounterModifiers.rules(BARON)), first.name, "a new game starts hidden")
	assert_true(Session.from_dict(saved))
	assert_has(_names(EncounterModifiers.rules(BARON)), first.name, "loaded back")


func test_a_fired_trigger_is_seen_from_the_duel_event() -> void:
	var first: EncounterScripts.Trigger = EncounterScripts.triggers(BARON)[0]
	var detail: String = EncounterScripts.ref_of(BARON, first.id)
	assert_eq(EncounterScripts.trigger_for_event(detail), first, "the SCRIPT_TRIGGERED detail is the seen ref")


# ---- B8 ----------------------------------------------------------------------------------------------------------------------


func test_fog_per_save_nodes_and_names() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.main_for_zone("beefcake")
	assert_false(Session.dungeon_entered(plan.id))
	assert_eq(SpoilerFree.dungeon_name(plan.id, plan.dungeon_name), "???", "the name is hidden before the first visit")
	assert_false(Session.node_revealed(plan.id, 3))
	Session.note_dungeon_entered(plan.id)
	Session.note_node_seen(plan.id, 3)
	assert_eq(SpoilerFree.dungeon_name(plan.id, plan.dungeon_name), plan.dungeon_name)
	assert_true(Session.node_revealed(plan.id, 3))
	assert_false(Session.node_revealed(plan.id, 4), "only the nodes stepped on")
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_false(Session.node_revealed(plan.id, 3), "a new game is all hidden again")
	assert_eq(SpoilerFree.dungeon_name(plan.id, plan.dungeon_name), "???")
	assert_true(Session.from_dict(saved))
	assert_true(Session.node_revealed(plan.id, 3), "kept in the save")


func test_old_saves_keep_cleared_dungeons_revealed() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.main_for_zone("beefcake")
	var other: DungeonCatalog.Blueprint = DungeonCatalog.main_for_zone("gourmand")
	Session.cleared_dungeons.append(plan.dungeon_name)
	var saved: Dictionary = Session.to_dict()
	saved.erase("dungeon_fog")
	assert_true(Session.from_dict(saved))
	assert_true(Session.dungeon_entered(plan.id))
	assert_true(Session.node_revealed(plan.id, 5), "a cleared dungeon's map is known")
	assert_false(Session.dungeon_entered(other.id), "the rest start hidden")


func test_a_fogged_node_shows_a_question_mark_and_no_name() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var node: DungeonMap.MapNode = map.nodes[map.nodes.size() - 1]
	var button: MapNodeButton = MapNodeButton.new()
	button.fogged = true
	button.setup(node, false, false)
	add_child_autofree(button)
	await get_tree().process_frame
	assert_not_null(button.find_child("FogMark", true, false))
	var names: Array[String] = []
	for label: Node in button.find_children("*", "Label", true, false):
		names.append((label as Label).text)
	assert_has(names, "???")
	assert_does_not_have(names, node.title)
