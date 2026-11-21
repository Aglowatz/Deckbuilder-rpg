extends GutTest
## Fable Nov 21 review (Part 2, softlocks): every choice room of every dungeon (the new heal rooms too). A hero with no gold and 1 HP
## always has a way out that costs nothing and does not end the run; every choice resolves with enough gold; a choice that cannot be
## paid for says why and changes nothing.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	CardSet.load_all()
	DungeonCatalog.reset()
	MainDungeons.reset()


func _key(blueprint: DungeonCatalog.Blueprint) -> String:
	return blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id


## Every (dungeon id, room title, event) of the game.
func _rooms() -> Array[Array]:
	var rooms: Array[Array] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		var map: DungeonMap = MainDungeons.build_map(_key(blueprint))
		var def: MainDungeonDef = MainDungeons.def(_key(blueprint))
		if map == null or def == null:
			continue
		for node: DungeonMap.MapNode in map.nodes:
			if node.event_id.is_empty():
				continue
			var event: DungeonEvent = def.event(node.event_id)
			if event != null:
				rooms.append([blueprint.id, node.title, event])
	return rooms


func test_the_choice_rooms_are_found() -> void:
	assert_gte(_rooms().size(), 20, "the choice rooms of every dungeon (%d)" % _rooms().size())


func test_a_broke_hero_at_one_hp_always_has_a_way_out() -> void:
	for room: Array in _rooms():
		var event: DungeonEvent = room[2] as DungeonEvent
		var ways_out: int = 0
		for index: int in range(event.choices.size()):
			var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
			run.hp = 1
			var result: EventResolver.Result = EventResolver.resolve(event, index, run, Session.content, 0, false)
			if result.ok and not run.failed and run.hp >= 1:
				ways_out += 1
		assert_gte(ways_out, 1, "%s, %s: a choice that needs no gold and does not end the run" % [room[0], room[1]])


func test_every_choice_resolves_with_gold_in_the_purse() -> void:
	var choices: int = 0
	for room: Array in _rooms():
		var event: DungeonEvent = room[2] as DungeonEvent
		assert_gte(event.choices.size(), 1, "%s, %s: has choices" % [room[0], room[1]])
		for index: int in range(event.choices.size()):
			var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
			var result: EventResolver.Result = EventResolver.resolve(event, index, run, Session.content, 99999, false)
			assert_true(result.ok, "%s, %s, choice %d resolves (%s)" % [room[0], room[1], index, result.reason])
			assert_false(event.choices[index].outcomes.is_empty(), "%s, %s, choice %d does something (or says 'nothing')" % [room[0], room[1], index])
			choices += 1
	assert_gte(choices, 50, "every choice was tried (%d)" % choices)


func test_a_choice_that_cannot_be_paid_changes_nothing_and_says_why() -> void:
	var paid_choices: int = 0
	for room: Array in _rooms():
		var event: DungeonEvent = room[2] as DungeonEvent
		for index: int in range(event.choices.size()):
			if event.choices[index].gold_cost() <= 0:
				continue
			paid_choices += 1
			var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
			run.hp = 3
			var deck_before: int = run.current_deck().cards.size()
			var result: EventResolver.Result = EventResolver.resolve(event, index, run, Session.content, event.choices[index].gold_cost() - 1, false)
			assert_false(result.ok, "%s, %s, choice %d is refused one gold short" % [room[0], room[1], index])
			assert_false(result.reason.is_empty(), "%s, %s: the refusal says why" % [room[0], room[1]])
			assert_eq([run.hp, run.current_deck().cards.size(), result.gold_delta, result.boons.size()], [3, deck_before, 0, 0], "%s, %s: nothing changed" % [room[0], room[1]])
	assert_gte(paid_choices, 4, "the paid choices were found (%d)" % paid_choices)
