extends GutTest
## Fable Nov 20 day (Part 3.1, the owner's answer): the Path-ology Lab's Night Shift Break Room follows the zone dungeons' rule - heal 5
## for a cost (gold, or a drawback in the next fight) or do nothing - scaled for a postgame dungeon. Primm's Castle keeps its full heal.

const ROOM: int = 9


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	CardSet.load_all()


func _event() -> DungeonEvent:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-LAB")
	return DungeonBuilder.build_def(plan).event(DungeonBuilder.event_id_of(plan, ROOM))


func test_the_break_room_is_a_choice_room_not_a_shrine() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-LAB")
	var content: Dictionary = DungeonCatalog.content_for("D-LAB")
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		if node.number == ROOM:
			assert_eq(node.node_name, "Night Shift Break Room")
			assert_eq(DungeonBuilder.node_kind(node, content), DungeonMap.Kind.EVENT, "a choice room")
		assert_ne(DungeonBuilder.node_kind(node, content), DungeonMap.Kind.SHRINE, "the Lab has no full heal (%s)" % node.node_name)


func test_two_ways_to_heal_five_each_with_a_cost_and_one_way_to_do_nothing() -> void:
	var event: DungeonEvent = _event()
	assert_not_null(event)
	assert_eq(event.choices.size(), 3)
	var pay: DungeonEvent.Choice = event.choices[0]
	assert_eq(pay.gold_cost(), 80, "the postgame price: more than the Dump's 50")
	var kinds: Array[int] = []
	for choice_index: int in [0, 1]:
		var heal: int = 0
		for outcome: DungeonEvent.Outcome in event.choices[choice_index].outcomes:
			kinds.append(int(outcome.kind))
			if outcome.kind == DungeonEvent.OutcomeKind.HEAL:
				heal += outcome.amount
		assert_eq(heal, 5, "option %d heals exactly 5" % choice_index)
	assert_has(kinds, int(DungeonEvent.OutcomeKind.PAY_GOLD))
	assert_has(kinds, int(DungeonEvent.OutcomeKind.BOON))
	var curse: ModifierSource = null
	for outcome: DungeonEvent.Outcome in event.choices[1].outcomes:
		if outcome.kind == DungeonEvent.OutcomeKind.BOON:
			curse = outcome.boon
	assert_not_null(curse)
	assert_true(BoonText.is_curse(curse), "the coffee is a drawback")
	assert_eq(curse.fights_left, 1, "for the next fight only")
	assert_eq(curse.source_name, "Night-Shift Jitters")
	assert_eq(event.choices[2].outcomes.size(), 0 if event.choices[2].outcomes.is_empty() else event.choices[2].outcomes.size())
	for outcome: DungeonEvent.Outcome in event.choices[2].outcomes:
		assert_false(outcome.kind in [DungeonEvent.OutcomeKind.HEAL, DungeonEvent.OutcomeKind.PAY_GOLD, DungeonEvent.OutcomeKind.BOON, DungeonEvent.OutcomeKind.DAMAGE], "doing nothing changes nothing")


func test_paying_heals_five_and_takes_eighty_gold() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.hp = 4
	var event: DungeonEvent = _event()
	var poor: EventResolver.Result = EventResolver.resolve(event, 0, run, Session.content, 79, false)
	assert_false(poor.ok, "80 gold is needed")
	assert_eq(run.hp, 4)
	var paid: EventResolver.Result = EventResolver.resolve(event, 0, run, Session.content, 80, false)
	assert_true(paid.ok)
	assert_eq(run.hp, 9, "5 HP, not a full heal")
	assert_eq(paid.gold_delta, -80)


func test_the_coffee_heals_five_and_the_next_fights_first_card_each_turn_costs_one_more() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.hp = 4
	var result: EventResolver.Result = EventResolver.resolve(_event(), 1, run, Session.content, 0, false)
	assert_true(result.ok)
	assert_eq(run.hp, 9)
	assert_eq(result.gold_delta, 0)
	assert_eq(result.boons.size(), 1)
	var kinds: Array[int] = []
	for modifier: Modifier in result.boons[0].modifiers:
		kinds.append(int(modifier.kind))
	assert_eq(DungeonBuilder.boon_from("Night-Shift Jitters|first_cost=1,next=1").modifiers[0].kind, result.boons[0].modifiers[0].kind, "the same rule the Corrupted Pantry's jars use (first card each turn costs 1 more)")


func test_walking_on_changes_nothing() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.hp = 4
	var none: EventResolver.Result = EventResolver.resolve(_event(), 2, run, Session.content, 500, false)
	assert_true(none.ok)
	assert_eq([none.hp_delta, none.gold_delta, none.boons.size()], [0, 0, 0])
	assert_eq(run.hp, 4)


func test_primms_castle_keeps_its_full_heal() -> void:
	var left: Array[String] = []
	for room: Array in DungeonBuilder.full_heal_rooms():
		left.append("%s %s" % [str(room[0]), str(room[1])])
	assert_has(left, "D-PC Resistance Safe Room")
