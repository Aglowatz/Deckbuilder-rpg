extends GutTest
## Overnight Oct 19-20, Part 6: the Old Well secret quest (`OldWellQuest`) - the chain from the well's vision through both hums in either order to
## the Echo's duel and a reward paid once, save/load mid-quest, the one-sided rule's wiring (duel and sim) and its icon, the relic, the two hums on
## walkable ground off the routes, and the words (box fit, no retired names).

const QUALITY := preload("res://tests/test_dialogue_quality.gd")

var _content: ContentSet
var _box: DialogueBox


func before_all() -> void:
	_content = ContentLibrary.load_all()
	_box = DialogueBox.new()
	add_child(_box)


func after_all() -> void:
	_box.queue_free()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(_content, Affinity.Type.GOURMAND)
	Session.deck = CampaignStart.starter_deck(_content, Affinity.Type.GOURMAND)


func _free_a_zone() -> void:
	Session.set_flag(ZoneCompletion.flag_name("beefcake"))


func _begin() -> void:
	_free_a_zone()
	assert_true(Session.begin_old_well_quest(), "the vision starts the quest")


# ---- The quest chain ---------------------------------------------------------------------------------------------------------


func test_the_quest_is_a_hidden_side_quest_with_no_markers() -> void:
	var quest: QuestData = QuestCatalog.find(OldWellQuest.QUEST_ID)
	assert_not_null(quest, "in the code-defined catalog")
	assert_eq(quest.category, QuestData.Category.SIDE)
	assert_false(quest.auto_give, "never auto-given")
	assert_eq(quest.giver_npc, "", "no giver: the well starts it")
	assert_null(quest.prerequisite, "no prerequisite on the quest (it never shows up as 'New quest available')")
	assert_eq(quest.objectives.size(), 3)
	for objective: QuestObjective in quest.objectives:
		assert_false(objective.has_marker(), "%s: no world marker for a secret" % objective.text)
		assert_false(objective.hint.is_empty(), "%s: a where-to-go line" % objective.text)
		assert_false(objective.text.contains("[missing"), objective.text)
		assert_false(objective.hint.contains("[missing") or objective.hint.contains("{"), objective.hint)
	assert_false(quest.title.contains("[missing") or quest.summary.contains("[missing"))
	assert_has(quest.reward_equipment_ids, OldWellQuest.REWARD_EQUIPMENT_ID)


func test_the_well_keeps_its_old_greeting_until_a_zone_is_free() -> void:
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.HIDDEN)
	assert_false(Session.old_well_can_begin(), "a fresh Wanderer only hears the old greeting")
	assert_false(Session.begin_old_well_quest())
	assert_false(Session.quest_log.is_active(OldWellQuest.QUEST_ID))
	_free_a_zone()
	assert_true(Session.old_well_can_begin())
	assert_true(Session.begin_old_well_quest())
	assert_true(Session.quest_log.is_active(OldWellQuest.QUEST_ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.LISTENING)
	assert_false(Session.old_well_can_begin(), "only once")
	assert_false(Session.begin_old_well_quest())


func test_the_hums_only_answer_while_their_step_is_open() -> void:
	assert_false(Session.old_well_task_open(BuffetZone.ID), "nothing before the vision")
	assert_false(Session.find_old_well_hum(BuffetZone.ID))
	assert_false(Session.flag(OldWellQuest.FLAG_BUFFET))
	_begin()
	assert_true(Session.old_well_task_open(BuffetZone.ID))
	assert_true(Session.old_well_task_open(HeapZone.ID))
	assert_false(Session.old_well_task_open("beefcake"), "no hum in the Gainlands")
	assert_false(Session.find_old_well_hum("beefcake"))
	assert_true(Session.find_old_well_hum(BuffetZone.ID))
	assert_false(Session.old_well_task_open(BuffetZone.ID), "found: the spot is not built again")
	assert_false(Session.find_old_well_hum(BuffetZone.ID), "once")


func test_buffet_first_then_dump_reaches_the_echo() -> void:
	_begin()
	assert_true(Session.find_old_well_hum(BuffetZone.ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.LISTENING)
	var quest: QuestData = QuestCatalog.find(OldWellQuest.QUEST_ID)
	assert_true(Session.quest_log.objective_met(quest, 1, Session.unlock_state()), "the Buffet step is ticked off out of order")
	assert_true(Session.find_old_well_hum(HeapZone.ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.READY)
	assert_eq(Session.quest_log.current_index(quest, Session.unlock_state()), 2, "the current step is the Echo")
	assert_true(Session.quest_log.is_active(OldWellQuest.QUEST_ID), "not done before the duel")


func test_dump_first_then_buffet_reaches_the_echo() -> void:
	_begin()
	assert_true(Session.find_old_well_hum(HeapZone.ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.LISTENING)
	assert_true(Session.find_old_well_hum(BuffetZone.ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.READY)


func test_the_echo_pays_once_and_a_loss_pays_nothing() -> void:
	_begin()
	Session.find_old_well_hum(HeapZone.ID)
	Session.find_old_well_hum(BuffetZone.ID)
	var gold_before: int = Session.gold
	var lost: Dictionary = Session.apply_old_well_result(false)
	assert_false(bool(lost["first_win"]))
	assert_true(Session.quest_log.is_active(OldWellQuest.QUEST_ID), "a loss changes nothing")
	assert_eq(Session.gold, gold_before)
	var won: Dictionary = Session.apply_old_well_result(true)
	assert_true(bool(won["first_win"]))
	assert_true(Session.flag(OldWellQuest.FLAG_DEFEATED))
	assert_true(Session.quest_log.is_completed(OldWellQuest.QUEST_ID), "the quest completes")
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.DONE)
	# the quest's own gold, plus whatever the 300 XP's level-ups pay on the level track
	assert_gte(Session.gold, gold_before + OldWellQuest.REWARD_GOLD)
	var gold_after_win: int = Session.gold
	assert_true(Session.owned_equipment_ids().has(OldWellQuest.REWARD_EQUIPMENT_ID), "the Phial of First Water (run tools/generate_content.gd first)")
	assert_false(Session.pending_popups.is_empty(), "the Quest Complete box is queued")
	var again: Dictionary = Session.apply_old_well_result(true)
	assert_false(bool(again["first_win"]), "never twice")
	assert_eq(Session.gold, gold_after_win, "a second win pays nothing")
	assert_eq(Session.owned_equipment_ids().count(OldWellQuest.REWARD_EQUIPMENT_ID), 1)


func test_a_win_without_the_quest_does_nothing() -> void:
	var result: Dictionary = Session.apply_old_well_result(true)
	assert_false(bool(result["first_win"]))
	assert_false(Session.flag(OldWellQuest.FLAG_DEFEATED))


func test_progress_survives_a_save_round_trip() -> void:
	_begin()
	Session.find_old_well_hum(HeapZone.ID)
	var json: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
	Session.new_game()
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.HIDDEN)
	assert_true(Session.from_dict(json))
	assert_true(Session.quest_log.is_active(OldWellQuest.QUEST_ID))
	assert_true(Session.flag(OldWellQuest.FLAG_HEAP))
	assert_false(Session.old_well_task_open(HeapZone.ID))
	assert_true(Session.old_well_task_open(BuffetZone.ID))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.LISTENING)


func test_a_save_from_before_the_quest_loads_hidden() -> void:
	var data: Dictionary = Session.to_dict()
	var json: Dictionary = JSON.parse_string(JSON.stringify(data)) as Dictionary
	Session.new_game()
	assert_true(Session.from_dict(json))
	assert_eq(Session.old_well_stage(), OldWellQuest.Stage.HIDDEN)
	assert_false(Session.quest_log.is_active(OldWellQuest.QUEST_ID))


func test_stage_rules_are_pure() -> void:
	assert_eq(OldWellQuest.stage(false, false, {}), OldWellQuest.Stage.HIDDEN)
	assert_eq(OldWellQuest.stage(true, false, {}), OldWellQuest.Stage.LISTENING)
	assert_eq(OldWellQuest.stage(true, false, {"old_well_heap_found": true}), OldWellQuest.Stage.LISTENING)
	assert_eq(OldWellQuest.stage(true, false, {"old_well_heap_found": true, "old_well_buffet_found": true}), OldWellQuest.Stage.READY)
	assert_eq(OldWellQuest.stage(false, true, {}), OldWellQuest.Stage.DONE)
	assert_false(OldWellQuest.can_begin(true, {}))
	assert_true(OldWellQuest.can_begin(true, {str(ZoneCompletion.flag_name("necrocrat")): true}))
	assert_false(OldWellQuest.can_begin(false, {str(ZoneCompletion.flag_name("necrocrat")): true}))


# ---- The Echo: the rule (duel and sim), the deck, the relic ------------------------------------------------------------------


func test_the_duel_carries_and_lists_its_one_sided_rule() -> void:
	Session.ensure_game(Affinity.Type.GOURMAND)
	var context: BattleContext = Session.make_old_well_battle()
	assert_true(context.is_old_well_boss)
	assert_true(context.is_boss)
	assert_eq(context.enemy_name, OldWellQuest.DISPLAY_NAME)
	assert_eq(context.encounter_rules.size(), EncounterModifiers.rules(OldWellQuest.RULES_KEY).size())
	assert_gt(context.encounter_rules.size(), 0, "town:old_well has rules")
	assert_eq(context.rule_badges.size(), 2, "The Spring Remembers (its parts share a name) and, on your side, First, Water (Oct 21)")
	assert_eq(context.rule_badges[0].name, "The Spring Remembers")
	assert_eq(context.rule_badges[0].side, RuleBadges.SIDE_ENEMY)
	assert_true(context.game.players[1].modifiers.has(Modifier.Kind.START_OF_TURN_EFFECT), "the heal is on the Echo's seat")
	assert_true(context.game.players[1].modifiers.has(Modifier.Kind.STARTING_RESOURCES), "and the four resources")
	assert_false(context.game.players[0].modifiers.has(Modifier.Kind.STARTING_RESOURCES), "and not on yours")


func test_the_rule_parses_and_its_icon_exists() -> void:
	EncounterModifiers.reset()
	var rules: Array[EncounterModifiers.Rule] = EncounterModifiers.rules(OldWellQuest.RULES_KEY)
	assert_eq(rules.size(), 7, "a stat entry (+2/+2, balanced overnight Oct 19), a heal, four starting resources and First, Water")
	assert_eq(EncounterModifiers.problems().size(), 0, ", ".join(EncounterModifiers.problems()))
	for rule: EncounterModifiers.Rule in rules:
		assert_eq(rule.is_enemy_side(), rule.name != "First, Water", "the Echo's rule is one-sided; First, Water is yours")
		assert_true(ResourceLoader.exists("%s%s.svg" % [CardIcons.BASE, rule.icon]), "icon %s exists" % rule.icon)
	# Oct 21: Gourmand's window against the Echo (the blue stream fed the first stockpot): Gourmand units +0/+1, nobody else's.
	var yours: ModifierSource = EncounterModifiers.player_source(OldWellQuest.RULES_KEY)
	assert_not_null(yours)
	var set: ModifierSet = ModifierSet.new()
	set.add_source(yours)
	assert_eq(set.stat_bonus(Affinity.Type.GOURMAND), Vector2i(0, 1))
	assert_eq(set.stat_bonus(Affinity.Type.NECROCRAT), Vector2i.ZERO)


func test_the_sim_can_find_and_build_the_echo() -> void:
	var specs: Array[EncounterSpec] = EncounterCatalog.filtered(_content, "old_well")
	assert_eq(specs.size(), 1)
	var spec: EncounterSpec = specs[0]
	assert_eq(spec.id, OldWellQuest.SIM_ID)
	assert_eq(spec.group, OldWellQuest.SIM_GROUP)
	assert_eq(spec.expected_level, OldWellQuest.EXPECTED_LEVEL)
	assert_eq(spec.kind, EncounterSpec.Kind.BOSS)
	assert_eq(spec.enemy_sources.size(), 1, "the sim plays the same rule (EncounterCatalog._attach_rules)")
	var seat: PlayerSetup = spec.build_enemy(_content, null)
	assert_eq(seat.deck.size(), 40)
	assert_eq(seat.starting_hp, OldWellQuest.STARTING_HP)
	assert_true(seat.modifiers.has(Modifier.Kind.START_OF_TURN_EFFECT))


func test_the_deck_is_existing_cards_from_all_four_paths() -> void:
	var total: int = 0
	for id: Variant in OldWellQuest.DECK_RECIPE.keys():
		assert_not_null(_content.card(str(id)), "%s is a real card" % id)
		total += int(OldWellQuest.DECK_RECIPE[id])
	assert_eq(total, 40)
	for basic: String in ["BAS-B", "BAS-G", "BAS-N", "BAS-R"]:
		assert_eq(int(OldWellQuest.DECK_RECIPE.get(basic, 0)), 5, "%s: every Path's Infrastructure, in equal parts" % basic)
	assert_eq(OldWellQuest.deck(_content).size(), 40)


func test_the_relic_uses_existing_modifier_kinds() -> void:
	var piece: EquipmentData = ProgressionContent.zone_equipment()[OldWellQuest.REWARD_EQUIPMENT_ID] as EquipmentData
	assert_not_null(piece)
	assert_eq(piece.slot, EquipmentData.Slot.RELIC)
	assert_eq(piece.modifiers.size(), 2)
	assert_eq(piece.modifiers[0].kind, Modifier.Kind.MULTIPATH_COST_CHANGE)
	assert_eq(piece.modifiers[0].value, -1)
	assert_eq(piece.modifiers[1].kind, Modifier.Kind.START_OF_TURN_EFFECT)
	assert_eq(piece.modifiers[1].effect.op, CardEnums.EffectOp.GAIN_HP)
	assert_false(piece.flavor_text.is_empty() or piece.source.is_empty() or piece.description.is_empty())
	assert_true(CardIcons.BY_EQUIPMENT_ID.has(piece.id), "it has an icon")
	assert_true(ResourceLoader.exists("%s%s.svg" % [CardIcons.BASE, str(CardIcons.BY_EQUIPMENT_ID[piece.id])]))


# ---- The two hums: walkable, reachable, off the routes ----------------------------------------------------------------------


func test_the_dump_hum_is_on_the_highest_terrace_and_reachable() -> void:
	var heap: HeapBuilder = HeapBuilder.new()
	heap.layout.build()
	heap._index_obstacles()
	for barricade: String in heap.layout.barricade_positions.keys():
		heap.smash_barricade(barricade)
	heap.mounted = true  # as the zone walkability test: the scree is walkable on a mount (the hum is not on it)
	var pos: Vector3 = OldWellQuest.spot_for(HeapZone.ID)
	assert_eq(HeapLayout.tier_at(pos.x, pos.z), 3, "the Overgrown Plateau, the highest terrace")
	assert_eq(heap.layout.surface_at(pos.x, pos.z), HeapLayout.Surface.GROUND, "plain ground, not scree, water or a cliff")
	assert_false(heap.layout.in_scree(pos.x, pos.z))
	assert_true(heap.is_walkable(pos, 0.35), "nothing solid stands on it")
	var edge: float = heap.layout.path_edge_distance(pos.x, pos.z)
	assert_gt(edge, 0.0, "off the routes")
	assert_lt(edge, HeapLayout.PATH_CLEARANCE, "inside a route's kept-clear band, so nothing scattered or solid is ever put on it")
	var can_stand: Callable = func(at: Vector3) -> bool: return heap.is_walkable(at, 0.22)
	var links: Array = [[heap.anchor("mound_a"), heap.anchor("ladder_a_top")], [heap.anchor("mound_b"), heap.anchor("ladder_b_top")]]
	var reached: Dictionary = WalkProbe.flood_linked(can_stand, heap.anchor("spawn"), heap.map_bounds(), links)
	assert_eq(WalkProbe.missing_from(reached, {"hum": pos}, 1.0), [] as Array[String], "the hero can stand at the hum")


func test_the_buffet_hum_is_on_the_pond_bank_and_reachable() -> void:
	var buffet: BuffetBuilder = BuffetBuilder.new()
	buffet.layout.build()
	buffet._index_obstacles()
	var pos: Vector3 = OldWellQuest.spot_for(BuffetZone.ID)
	assert_eq(buffet.layout.surface_at(pos.x, pos.z), BuffetLayout.Surface.GROUND, "dry ground, not the gravy")
	var pond: Vector3 = buffet.layout.ponds[0]
	assert_lt(Vector2(pos.x - pond.x, pos.z - pond.y).length(), pond.z + 3.0, "beside the pond")
	assert_lt(buffet.layout.soup_depth(pos.x, pos.z), -1.0, "on the bank, not in it")
	assert_true(buffet.is_walkable(pos, 0.35), "nothing solid stands on it")
	var edge: float = buffet.layout.path_edge_distance(pos.x, pos.z)
	assert_gt(edge, 0.0, "off the forest road")
	assert_lt(edge, BuffetLayout.PATH_CLEARANCE, "inside the road's kept-clear band, so nothing scattered or solid is ever put on it")
	var can_stand: Callable = func(at: Vector3) -> bool: return buffet.is_walkable(at, 0.22)
	var reached: Dictionary = WalkProbe.flood(can_stand, buffet.anchor("spawn"), buffet.map_bounds())
	assert_eq(WalkProbe.missing_from(reached, {"hum": pos}, 1.0), [] as Array[String], "the hero can stand at the hum (no gate, no raft)")


func test_the_hums_are_clear_of_the_other_interact_spots() -> void:
	var heap: HeapLayout = HeapLayout.new()
	heap.build()
	var buffet: BuffetLayout = BuffetLayout.new()
	buffet.build()
	for entry: Array in [[heap.anchors, OldWellQuest.spot_for(HeapZone.ID)], [buffet.anchors, OldWellQuest.spot_for(BuffetZone.ID)]]:
		var pos: Vector3 = entry[1] as Vector3
		for key: Variant in (entry[0] as Dictionary).keys():
			var anchor: Vector3 = (entry[0] as Dictionary)[key] as Vector3
			assert_gt(Vector2(anchor.x - pos.x, anchor.z - pos.z).length(), 3.5, "the hum does not steal the E from %s" % key)


# ---- The words --------------------------------------------------------------------------------------------------------------------


func test_every_line_fits_the_box() -> void:
	var lines: Dictionary = OldWellStory.shared().all_dialogue_lines()
	assert_gt(lines.size(), 30, "the whole file is read")
	var too_long: PackedStringArray = []
	for key: Variant in lines.keys():
		var text: String = Villain.fill(str(lines[key]))
		if _box.wrapped_lines(text, 1.0) > 4 or _box.wrapped_lines(text, 1.4) > 6:
			too_long.append("%s: %s" % [key, text.substr(0, 60)])
		assert_lte(text.length(), 240, "%s: at most 240 characters" % key)
		assert_false(text.contains("{"), "%s: every token filled" % key)
	assert_eq(too_long.size(), 0, "lines too long for the box:\n%s" % "\n".join(too_long))


func test_every_beat_and_text_the_code_uses_exists() -> void:
	var story: OldWellStory = OldWellStory.shared()
	for key: String in ["vision.start", "touch.listening", "touch.left.heap", "touch.left.buffet", "find.refusemancer", "find.gourmand", "find.one",
			"find.both", "touch.ready", "echo.before", "echo.lose", "echo.reveal"]:
		var beats: Array[OldWellStory.Beat] = story.get_beats(key)
		assert_false(beats[0].lines[0].begins_with("[missing"), "beats %s" % key)
	for key: String in ["quest.title", "quest.summary", "quest.step.heap", "quest.step.buffet", "quest.step.echo", "quest.hint.heap", "quest.hint.buffet",
			"quest.hint.echo", "prompt.refusemancer", "prompt.gourmand", "prompt.well.ready", "touch.done", "confirm.title", "confirm.body",
			"confirm.yes", "confirm.no", "toast.found", "toast.both"]:
		assert_false(story.text(key).begins_with("[missing"), "text %s" % key)


func test_no_retired_or_unrevealed_name_in_the_text() -> void:
	var banned: Array = QUALITY.banned_names()
	assert_gt(banned.size(), 20)
	var raw: String = FileAccess.get_file_as_string(OldWellStory.PATH)
	for name: Variant in banned:
		assert_false(raw.contains(str(name)), "retired name %s" % name)
	for word: String in ["Pathwork", "Elowen", "{prince}", "{prince_full}", "Tessar", "Wayweaver", "Primm"]:
		assert_false(raw.contains(word), "%s is not spoken here" % word)
