extends GutTest
## The Event and Rescue nodes of the dungeon list have real scenes: 2-3 choices with their own results and outcomes, all text in data/dungeons/dungeon_content.json.

func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func _event_nodes(plan: DungeonCatalog.Blueprint) -> Array[DungeonCatalog.BlueprintNode]:
	var result: Array[DungeonCatalog.BlueprintNode] = []
	for node: DungeonCatalog.BlueprintNode in plan.nodes:
		if node.type == "event" or node.type == "rescue":
			result.append(node)
	return result


func _key_of(plan: DungeonCatalog.Blueprint) -> String:
	return plan.id if (plan.is_side() or plan.is_postgame()) else plan.zone_id


func test_every_event_and_rescue_node_has_content() -> void:
	var count: int = 0
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var events: Dictionary = DungeonCatalog.content_for(plan.id).get("events", {}) as Dictionary
		for node: DungeonCatalog.BlueprintNode in _event_nodes(plan):
			if plan.is_postgame() and node.type == "rescue":
				continue # the Path-ology Lab's Rescuer's Cell is a hand-built serious scene (`PathologyLab`)
			count += 1
			assert_true(events.has(str(node.number)), "%s node %d (%s) has an event" % [plan.id, node.number, node.node_name])
	assert_gte(count, 15, "the sheet's event and rescue nodes were all found")


func test_written_events_have_two_or_three_choices_with_results() -> void:
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var events: Dictionary = DungeonCatalog.content_for(plan.id).get("events", {}) as Dictionary
		for number: String in events.keys():
			var spec: Dictionary = events[number] as Dictionary
			if spec.has("ref"):
				continue
			var label: String = "%s node %s" % [plan.id, number]
			assert_false(str(spec.get("body", "")).contains("worth a closer look"), "%s is not the placeholder scene" % label)
			var choices: Array = spec.get("choices", []) as Array
			assert_between(choices.size(), 2, 3, "%s has 2 or 3 choices" % label)
			var distinct: Dictionary = {}
			for choice: Variant in choices:
				var parts: Array = choice as Array
				assert_gte(parts.size(), 3, "%s: every choice has a label, a result and an effect" % label)
				assert_gt(str(parts[1]).length(), 30, "%s: the result is a sentence" % label)
				distinct[str(parts[0])] = true
			assert_eq(distinct.size(), choices.size(), "%s: choices are distinct" % label)


func test_built_events_match_their_data_and_cards_exist() -> void:
	for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var events: Dictionary = DungeonCatalog.content_for(plan.id).get("events", {}) as Dictionary
		var def: MainDungeonDef = MainDungeons.def(_key_of(plan))
		for number: String in events.keys():
			var spec: Dictionary = events[number] as Dictionary
			if spec.has("ref"):
				continue
			var event: DungeonEvent = def.event(DungeonBuilder.event_id_of(plan, int(number)))
			assert_not_null(event, "%s node %s was built" % [plan.id, number])
			if event == null:
				continue
			assert_eq(event.choices.size(), (spec["choices"] as Array).size())
			for choice: Array in spec["choices"]:
				for index: int in range(2, choice.size()):
					var token: String = str(choice[index])
					if token.begins_with("card:"):
						assert_true(Session.content.cards.has(token.substr(5)), "%s node %s: card %s exists" % [plan.id, number, token.substr(5)])
			for built: DungeonEvent.Choice in event.choices:
				assert_false(built.outcomes.is_empty(), "%s node %s: every choice does something" % [plan.id, number])


func test_a_curse_is_a_boon_with_negative_numbers_and_says_so() -> void:
	var def: MainDungeonDef = MainDungeons.def("beefcake")
	var curse: DungeonEvent.Outcome = DungeonBuilder.event_outcome("curse:Spotter Knows|max_hp=-1", def)
	assert_eq(curse.kind, DungeonEvent.OutcomeKind.BOON)
	assert_eq(curse.boon.modifiers[0].value, -1)
	assert_true(curse.describe().begins_with("curse: "))
	var boon: DungeonEvent.Outcome = DungeonBuilder.event_outcome("boon:Lucky Towel|max_hp=2", def)
	assert_true(boon.describe().begins_with("boon: "))


func test_the_gym_locker_room_lets_you_take_a_curse_for_gold() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("D-HOG")
	var event: DungeonEvent = MainDungeons.def("beefcake").event(DungeonBuilder.event_id_of(plan, 5))
	var hints: Array[String] = []
	for choice: DungeonEvent.Choice in event.choices:
		hints.append(choice.hint())
	assert_true(hints[1].contains("gain 60 gold") and hints[1].contains("curse: Spotter Knows"), "raiding the bag pays and curses: %s" % hints[1])
