extends GutTest
## Fable Nov 12c (A10), the owner's decision on inbox "Fable Nov 12" item 11:
## (a) a dungeon room's type shows one step ahead - it is known once a room that leads to it can be reached;
## (b) every fight of Primm's Castle (level 21 and up) offers at least one Uncommon or better among its three reward cards.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()


func after_all() -> void:
	Session.new_game()


## start -> a -> b -> c -> d, with a side room s off a.
func _chain() -> Dictionary:
	var map: DungeonMap = DungeonMap.new()
	var nodes: Dictionary = {}
	for key: String in ["start", "a", "b", "c", "d", "s"]:
		nodes[key] = map.add_node(DungeonMap.MapNode.new())
	(nodes["start"] as DungeonMap.MapNode).kind = DungeonMap.Kind.START
	map.connect_nodes((nodes["start"] as DungeonMap.MapNode).id, (nodes["a"] as DungeonMap.MapNode).id)
	map.connect_nodes((nodes["a"] as DungeonMap.MapNode).id, (nodes["b"] as DungeonMap.MapNode).id)
	map.connect_nodes((nodes["a"] as DungeonMap.MapNode).id, (nodes["s"] as DungeonMap.MapNode).id)
	map.connect_nodes((nodes["b"] as DungeonMap.MapNode).id, (nodes["c"] as DungeonMap.MapNode).id)
	map.connect_nodes((nodes["c"] as DungeonMap.MapNode).id, (nodes["d"] as DungeonMap.MapNode).id)
	map.current = (nodes["start"] as DungeonMap.MapNode).id
	nodes["map"] = map
	return nodes


func _id(nodes: Dictionary, key: String) -> int:
	return (nodes[key] as DungeonMap.MapNode).id


func test_a_room_is_known_once_the_room_before_it_can_be_reached() -> void:
	var nodes: Dictionary = _chain()
	var map: DungeonMap = nodes["map"] as DungeonMap
	# at the start: a is open to walk into, so a is known (as before) AND b and the side room s behind it are known (one step ahead)
	assert_true(map.is_available(_id(nodes, "a")))
	assert_true(map.known_one_step_ahead(_id(nodes, "a")))
	assert_true(map.known_one_step_ahead(_id(nodes, "b")), "one step ahead: the room behind the open one")
	assert_true(map.known_one_step_ahead(_id(nodes, "s")), "the side room behind it too")
	assert_false(map.neighbour_cleared(_id(nodes, "b")), "the old rule kept it '???'")
	assert_false(map.known_one_step_ahead(_id(nodes, "c")), "two steps ahead stays unknown")
	assert_false(map.known_one_step_ahead(_id(nodes, "d")))
	assert_true(map.complete(_id(nodes, "a")))
	assert_true(map.known_one_step_ahead(_id(nodes, "c")), "the view moves on with the party")
	assert_false(map.known_one_step_ahead(_id(nodes, "d")))
	assert_true(map.complete(_id(nodes, "b")))
	assert_true(map.known_one_step_ahead(_id(nodes, "d")))


func test_the_castle_map_uses_the_rule() -> void:
	assert_true(DungeonMapScreen.NEIGHBOUR_REVEAL.has(PrimmsCastleDungeon.DUNGEON_ID))
	var source: String = FileAccess.get_file_as_string("res://ui/dungeon/dungeon_map_screen.gd")
	assert_true(source.contains("map.known_one_step_ahead(node.id)"), "the map screen asks the one-step-ahead rule")
	# on the real castle: from the gate, the courtyard is open and the three rooms behind it are known
	var castle: DungeonMap = MainDungeons.build_map(CapitalZone.ID)
	var open: Array[DungeonMap.MapNode] = castle.available()
	assert_gt(open.size(), 0)
	var behind: int = 0
	for room: DungeonMap.MapNode in open:
		for next_id: int in room.next:
			behind += 1
			assert_true(castle.known_one_step_ahead(next_id), "%s, behind %s, shows its type" % [castle.node(next_id).title, room.title])
	assert_gt(behind, 1, "the first room has rooms behind it")


func _common_pick() -> Array[CardData]:
	var commons: Array[CardData] = []
	var ids: Array = Session.content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = Session.content.cards[id] as CardData
		if card.rarity == CardEnums.Rarity.COMMON and not card.is_infrastructure() and CardAvailability.allowed(card, {}):
			commons.append(card)
		if commons.size() == 3:
			break
	return commons


func test_a_pick_of_three_commons_gets_an_uncommon_or_better() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for seed_value: int in range(1, 30):
		rng.seed = seed_value
		var cards: Array[CardData] = _common_pick()
		assert_false(RewardGenerator.has_rarity(cards, CardEnums.Rarity.UNCOMMON))
		var first_two: Array[CardData] = [cards[0], cards[1]]
		RewardGenerator.with_rarity_floor(cards, Session.content, Session.profile, rng)
		assert_eq(cards.size(), 3, "still three cards")
		assert_true(RewardGenerator.has_rarity(cards, CardEnums.Rarity.UNCOMMON), "seed %d: one of them is Uncommon or better" % seed_value)
		assert_eq([cards[0], cards[1]], first_two, "only the last card is replaced")
		assert_false(cards[2] == cards[0] or cards[2] == cards[1], "never a card already in the pick")
		assert_false(cards[2].is_infrastructure())


func test_a_pick_that_already_has_one_is_left_alone() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var cards: Array[CardData] = _common_pick()
	var uncommon: CardData = null
	for value: Variant in Session.content.cards.values():
		if (value as CardData).rarity == CardEnums.Rarity.UNCOMMON and not (value as CardData).is_infrastructure():
			uncommon = value as CardData
			break
	cards[1] = uncommon
	var before: Array[CardData] = cards.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	RewardGenerator.with_rarity_floor(cards, Session.content, Session.profile, rng)
	assert_eq(cards, before)


func test_only_the_castle_has_the_floor() -> void:
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var context: BattleContext = BattleContext.new()
	# another dungeon: three commons stay three commons
	Session.main_dungeon_active = true
	Session.dungeon_key = "beefcake"
	assert_false(Session.in_castle_run())
	var cards: Array[CardData] = _common_pick()
	Session._castle_rarity_floor(cards, context)
	assert_false(RewardGenerator.has_rarity(cards, CardEnums.Rarity.UNCOMMON), "the House of Gains keeps its own odds")
	# the castle: every fight's pick
	Session.dungeon_key = CapitalZone.ID
	assert_true(Session.in_castle_run())
	for seed_value: int in range(1, 12):
		Session.rng.seed = seed_value
		var pick: Array[CardData] = _common_pick()
		Session._castle_rarity_floor(pick, context)
		assert_true(RewardGenerator.has_rarity(pick, Session.CASTLE_REWARD_FLOOR), "a castle fight's three cards include an Uncommon or better")
	Session.main_dungeon_active = false
	Session.dungeon_key = ""


func test_the_reroll_keeps_the_floor() -> void:
	var source: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	assert_eq(source.count("_castle_rarity_floor("), 3, "the first offer, the reroll and the function itself")
