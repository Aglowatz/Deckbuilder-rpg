extends GutTest
## Part E: the four zone dungeons - branching map structure, enemy decks, story text, events, treasure,
## the House of Gains rescue, boss defeat completing the zone.

const ZONES: Array[String] = ["gourmand", "beefcake", "necrocrat", "refusemancer"]
const NAMES: Dictionary = {
	"gourmand": "The Test Kitchen", "beefcake": "The House of Gains",
	"necrocrat": "The Hall of Final Approvals", "refusemancer": "The Rotheart",
}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)


func after_each() -> void:
	Session.main_dungeon_active = false
	Session.mini_active = false
	Session.run = null
	Session.dungeon_map = null
	Session.zone_run = null
	for zone_id: String in ZONES:
		ZoneStoryText.set_zone_freed(zone_id, false)


func _enter(zone_id: String) -> void:
	Session.zone_run = ZoneRun.enter(zone_id, Session.profile, Session.deck)
	Session.dungeon_map = MainDungeons.build_map(zone_id)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.run.life = Session.zone_run.life
	Session.main_dungeon_active = true
	Session.dungeon_story_seen = []


# ---- Structure -------------------------------------------------------------------------------------


func test_every_zone_has_a_dungeon_named_as_in_the_story() -> void:
	for zone_id: String in ZONES:
		assert_true(MainDungeons.has_def(zone_id), zone_id)
		assert_eq(MainDungeons.def(zone_id).dungeon_name, NAMES[zone_id])
		assert_eq(MainDungeons.build_map(zone_id).dungeon_name, NAMES[zone_id])
	assert_null(MainDungeons.def("nowhere"))


func test_maps_have_ten_to_fifteen_nodes_and_are_sound() -> void:
	for zone_id: String in ZONES:
		var map: DungeonMap = MainDungeons.build_map(zone_id)
		assert_between(map.nodes.size(), 10, 15, "%s node count" % zone_id)
		assert_eq(map.problems(), [] as Array[String], "%s map is structurally sound" % zone_id)
		assert_eq(map.node(0).kind, DungeonMap.Kind.START)
		assert_not_null(map.boss())


func test_routes_branch_and_rejoin() -> void:
	for zone_id: String in ZONES:
		var map: DungeonMap = MainDungeons.build_map(zone_id)
		assert_gte(map.branch_points().size(), 2, "%s has real choices of route" % zone_id)
		assert_gte(map.rejoin_points().size(), 2, "%s routes rejoin" % zone_id)
		assert_gte(map.route_count(), 4, "%s has several distinct routes to the boss" % zone_id)
		for branch_id: int in map.branch_points():
			# every branch must come back together before the boss
			var targets: Array[int] = map.node(branch_id).next
			var joined: bool = false
			for rejoin_id: int in map.rejoin_points():
				var reachable_from_all: bool = true
				for target: int in targets:
					if not map.reachable_from(target).has(rejoin_id):
						reachable_from_all = false
				if reachable_from_all:
					joined = true
			assert_true(joined, "%s: the routes after node %d rejoin" % [zone_id, branch_id])


func test_each_dungeon_mixes_every_node_type() -> void:
	for zone_id: String in ZONES:
		var kinds: Dictionary = {}
		for node: DungeonMap.MapNode in MainDungeons.build_map(zone_id).nodes:
			kinds[node.kind] = true
		for kind: DungeonMap.Kind in [DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE, DungeonMap.Kind.EVENT, DungeonMap.Kind.TREASURE, DungeonMap.Kind.SHRINE, DungeonMap.Kind.BOSS]:
			assert_true(kinds.has(kind), "%s has node kind %d" % [zone_id, kind])
	var gourmand_kinds: Dictionary = {}
	for node: DungeonMap.MapNode in MainDungeons.build_map("gourmand").nodes:
		gourmand_kinds[node.kind] = true
	assert_true(gourmand_kinds.has(DungeonMap.Kind.CHALLENGE), "the Test Kitchen has a deck challenge")


func test_the_map_walks_from_start_to_boss_along_any_route() -> void:
	for zone_id: String in ZONES:
		for branch_choice: int in [0, 1]:
			var map: DungeonMap = MainDungeons.build_map(zone_id)
			var steps: int = 0
			while not map.is_complete() and steps < 40:
				var options: Array[DungeonMap.MapNode] = map.available()
				assert_false(options.is_empty(), "%s never dead-ends" % zone_id)
				assert_true(map.complete(options[branch_choice % options.size()].id))
				steps += 1
			assert_true(map.is_complete(), "%s reaches the boss (choice %d)" % [zone_id, branch_choice])


func test_a_synthetic_map_reports_its_structure() -> void:
	var map: DungeonMap = DungeonMap.new()
	var kinds: Array[DungeonMap.Kind] = [DungeonMap.Kind.START, DungeonMap.Kind.BATTLE, DungeonMap.Kind.BATTLE, DungeonMap.Kind.SHRINE, DungeonMap.Kind.BOSS]
	for kind: DungeonMap.Kind in kinds:
		var node: DungeonMap.MapNode = DungeonMap.MapNode.new()
		node.kind = kind
		map.add_node(node)
	map.connect_nodes(0, 1)
	map.connect_nodes(0, 2)
	map.connect_nodes(1, 3)
	map.connect_nodes(2, 3)
	map.connect_nodes(3, 4)
	assert_eq(map.branch_points(), [0] as Array[int])
	assert_eq(map.rejoin_points(), [3] as Array[int])
	assert_eq(map.route_count(), 2)
	assert_eq(map.problems().size(), 0)
	map.connect_nodes(4, 1)
	assert_gt(map.problems().size(), 0, "a boss with a way onward / a backwards link is flagged")


# ---- Enemies and decks -----------------------------------------------------------------------------


func test_every_battle_has_a_themed_legal_enemy_deck() -> void:
	for zone_id: String in ZONES:
		var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
		var path: Affinity.Type = ZoneEffects.path_of(zone_id)
		for node: DungeonMap.MapNode in MainDungeons.build_map(zone_id).nodes:
			if not DungeonMap.is_battle_kind(node.kind):
				continue
			var foe: MainDungeonDef.Foe = dungeon.foe(node.enemy_name)
			assert_not_null(foe, "%s: %s has a foe" % [zone_id, node.enemy_name])
			var setup: PlayerSetup = MainDungeons.enemy_setup(Session.content, node, zone_id)
			assert_gte(setup.deck.size(), 25, "%s deck is a real deck" % node.enemy_name)
			assert_eq(setup.starting_life, foe.life)
			for card: CardData in setup.deck.cards:
				assert_true(card.color == path or card.color == Affinity.Type.NEUTRAL, "%s only plays %d / neutral cards (%s)" % [node.enemy_name, int(path), card.id])


func test_bosses_and_elites_are_tougher_and_pay_a_card_choice() -> void:
	for zone_id: String in ZONES:
		var life_normal: int = 0
		var life_boss: int = 0
		for node: DungeonMap.MapNode in MainDungeons.build_map(zone_id).nodes:
			if node.kind == DungeonMap.Kind.BATTLE:
				life_normal = maxi(life_normal, node.enemy_life)
			elif node.kind == DungeonMap.Kind.BOSS:
				life_boss = node.enemy_life
				assert_eq(node.difficulty, DungeonMap.Difficulty.BOSS)
				assert_gt(node.card_choices, 0)
			elif node.kind == DungeonMap.Kind.ELITE:
				assert_eq(node.difficulty, DungeonMap.Difficulty.ELITE)
				assert_gt(node.card_choices, 0)
		assert_gt(life_boss, life_normal)


func test_a_dungeon_battle_carries_the_zone_effects_and_zone_life() -> void:
	for zone_id: String in ZONES:
		_enter(zone_id)
		Session.zone_run.damage(3)
		Session.run.life = Session.zone_run.life
		var node: DungeonMap.MapNode = Session.dungeon_map.available()[0]
		var context: BattleContext = Session.make_dungeon_battle(node)
		assert_eq(context.zone_id, zone_id)
		assert_eq(context.game.players[0].life, Session.zone_run.life, "zone life carries into the dungeon battle")
		var effect: ZoneEffects.Effect = ZoneEffects.for_zone(zone_id)
		for player: PlayerState in context.game.players:
			assert_gt(player.modifiers.modifiers.size(), 0)
		assert_true(context.game.players[1].modifiers.modifiers.has(effect.buff), "%s: the enemy gets the zone buff too" % zone_id)
		after_each()
		before_each()


# ---- Story text ---------------------------------------------------------------------------------------


func test_every_node_event_and_cutscene_has_story_text() -> void:
	for zone_id: String in ZONES:
		var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
		var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
		for node: DungeonMap.MapNode in MainDungeons.build_map(zone_id).nodes:
			assert_false(node.title.begins_with("[missing"), "%s node %d has a title" % [zone_id, node.id])
			assert_false(node.blurb.begins_with("[missing"), "%s node %d has a blurb" % [zone_id, node.id])
			if node.kind == DungeonMap.Kind.EVENT:
				assert_not_null(dungeon.event(node.event_id), node.event_id)
			if node.kind == DungeonMap.Kind.CHALLENGE:
				assert_not_null(dungeon.challenge(node.challenge_id), node.challenge_id)
		var map: DungeonMap = MainDungeons.build_map(zone_id)
		assert_false(map.node(0).story_before.is_empty(), "%s: story at the entrance" % zone_id)
		assert_false(map.boss().story_before.is_empty(), "%s: dialogue before the boss" % zone_id)
		assert_false(map.boss().story_after.is_empty(), "%s: dialogue after the boss" % zone_id)
		for event: DungeonEvent in dungeon.events.values():
			assert_true(story.lines.has(event.title_key()), event.id)
			assert_true(story.lines.has(event.body_key()), event.id)
			for index: int in range(event.choices.size()):
				assert_true(story.lines.has(event.choice_key(index)), "%s choice %d" % [event.id, index])
				assert_true(story.lines.has(event.result_key(index)), "%s result %d" % [event.id, index])
		for challenge: ChallengeData in dungeon.challenges.values():
			assert_false(challenge.display_name.begins_with("[missing"), challenge.id)
			assert_false(challenge.description.begins_with("[missing"), challenge.id)
		for key: String in ["ui.main.title", "ui.main.body", "ui.main.body_cleared", "ui.main.button"]:
			assert_true(story.lines.has(key), "%s %s" % [zone_id, key])


func test_the_cutscenes_have_every_beat_and_speaker() -> void:
	for scene_id: String in CutsceneDefs.SCENES.keys():
		var story: ZoneStoryText = ZoneStoryText.for_zone(CutsceneDefs.zone_of(scene_id))
		var beats: Array[Dictionary] = CutsceneDefs.beats(scene_id)
		assert_gte(beats.size(), 3, scene_id)
		for beat: Dictionary in beats:
			assert_true(story.lines.has(str(beat["key"])), "%s %s" % [scene_id, str(beat["key"])])
			assert_true(story.lines.has(str(beat["speaker_key"])), "%s %s" % [scene_id, str(beat["speaker_key"])])
	assert_true(MainDungeons.build_map("gourmand").boss().scene == "reveal", "the Test Kitchen boss has the reveal moment")
	assert_true(MainDungeons.build_map("beefcake").boss().scene == "flex", "the House of Gains boss has the clothing reveal")
	assert_true(MainDungeons.build_map("refusemancer").boss().after_scene == "sever")


# ---- Events, treasure ---------------------------------------------------------------------------------


func test_every_event_choice_resolves_and_chains_exist() -> void:
	for zone_id: String in ZONES:
		var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
		for event: DungeonEvent in dungeon.events.values():
			for index: int in range(event.choices.size()):
				_enter(zone_id)
				Session.gold = 500
				var result: EventResolver.Result = Session.resolve_dungeon_event(event, index)
				assert_true(result.ok, "%s choice %d" % [event.id, index])
				if not result.next_event.is_empty():
					assert_not_null(dungeon.event(result.next_event), "%s chains to a real event" % event.id)
				after_each()
				before_each()


func test_events_heal_hurt_and_pay_through_the_run_and_gold() -> void:
	_enter("necrocrat")
	var dungeon: MainDungeonDef = MainDungeons.def("necrocrat")
	Session.run.life = 5
	Session.gold = 100
	var number: DungeonEvent = dungeon.event("ha_take_a_number")
	var paid: EventResolver.Result = Session.resolve_dungeon_event(number, 1)
	assert_true(paid.ok)
	assert_eq(Session.gold, 70, "the expedite fee was paid")
	assert_eq(Session.run.life, 7, "and the wait healed 2")
	Session.gold = 10
	var broke: EventResolver.Result = Session.resolve_dungeon_event(number, 1)
	assert_false(broke.ok, "cannot pay without the gold")
	assert_eq(Session.gold, 10)
	var hurt: EventResolver.Result = Session.resolve_dungeon_event(number, 2)
	assert_eq(Session.run.life, 5)
	assert_eq(hurt.life_delta, -2)


func test_forms_that_require_forms_chain_three_steps() -> void:
	var dungeon: MainDungeonDef = MainDungeons.def("necrocrat")
	var event: DungeonEvent = dungeon.event("ha_form_a")
	var steps: int = 0
	while event != null and steps < 6:
		steps += 1
		var next_id: String = ""
		for outcome: DungeonEvent.Outcome in event.choices[0].outcomes:
			if outcome.kind == DungeonEvent.OutcomeKind.NEXT:
				next_id = outcome.event_id
		event = dungeon.event(next_id) if not next_id.is_empty() else null
	assert_eq(steps, 3, "Form 13-B needs 13-A needs 12-F")


func test_treasure_grants_loot() -> void:
	_enter("gourmand")
	var chest: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.kind == DungeonMap.Kind.TREASURE:
			chest = node
	var gold_before: int = Session.gold
	var granted: Dictionary = Session.apply_treasure(chest)
	assert_eq(Session.gold, gold_before + int(chest.treasure["gold"]))
	assert_true(granted.has("item"), "a healing item")
	assert_true(Session.profile.owns_item(Session.content.item("healing_draught")))


# ---- The House of Gains rescue ----------------------------------------------------------------------


func test_rescuing_heartlift_adds_a_dungeon_wide_boon() -> void:
	_enter("beefcake")
	var dungeon: MainDungeonDef = MainDungeons.def("beefcake")
	var life_before: int = Session.run.max_life()
	assert_eq(Session.run.modifiers().stat_bonus(Affinity.Type.A), Vector2i.ZERO)
	var rescue: EventResolver.Result = Session.resolve_dungeon_event(dungeon.event("hg_rescue"), 0)
	assert_true(rescue.ok)
	assert_eq(rescue.boons.size(), 1)
	assert_eq(Session.run.modifiers().stat_bonus(Affinity.Type.A), Vector2i(1, 1), "Heartlift fights beside you: +1/+1")
	assert_eq(Session.run.max_life(), life_before + 3)
	# The boon is carried into the next duel for the rest of the run.
	var map: DungeonMap = Session.dungeon_map
	var node: DungeonMap.MapNode = map.available()[0]
	var context: BattleContext = Session.make_dungeon_battle(node)
	assert_gte(context.game.players[0].modifiers.stat_bonus(Affinity.Type.A).x, 1)


func test_the_prison_is_a_section_and_the_rescue_comes_before_the_boss() -> void:
	var map: DungeonMap = MainDungeons.build_map("beefcake")
	var prison: Array[int] = []
	var rescue_id: int = -1
	for node: DungeonMap.MapNode in map.nodes:
		if node.section == "prison":
			prison.append(node.id)
		if node.event_id == "hg_rescue":
			rescue_id = node.id
			assert_eq(node.scene, "rescue")
	assert_gte(prison.size(), 5, "the Iron-less Prison is a major section")
	assert_true(prison.has(rescue_id))
	assert_true(map.reachable_from(rescue_id).has(map.boss().id), "after the rescue the player continues through the House to the boss")
	for node: DungeonMap.MapNode in map.nodes:
		if node.id < rescue_id and node.id != 0:
			assert_false(map.reachable_from(rescue_id).has(node.id), "no way back")


# ---- Completing the zone -------------------------------------------------------------------------------


func test_beating_the_boss_completes_the_zone_with_the_unique_card() -> void:
	for zone_id: String in ZONES:
		_enter(zone_id)
		var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
		var gold_before: int = Session.gold
		var xp_before: int = Session.profile.xp
		assert_false(Session.is_zone_completed(zone_id))
		var result: Dictionary = Session.resolve_main_dungeon(true)
		assert_true(Session.is_zone_completed(zone_id), "%s is freed" % zone_id)
		assert_eq(str(result["kind"]), "zone_freed")
		assert_true(bool(result["first_clear"]))
		assert_eq(Session.owned_count(dungeon.reward_card_id), 1, "the unique card %s" % dungeon.reward_card_id)
		assert_gte(Session.gold, gold_before + dungeon.reward_gold)  # level-up bonus gold may add to it
		assert_gt(Session.profile.xp, xp_before)
		assert_true(Session.cleared_dungeons.has(dungeon.dungeon_name))
		assert_false(Session.main_dungeon_active)
		assert_false(Session.pending_zone_result.is_empty(), "the zone scene is told to announce it")
		# Replaying does not pay the completion rewards twice.
		_enter(zone_id)
		var gold_mid: int = Session.gold
		var again: Dictionary = Session.resolve_main_dungeon(true)
		assert_eq(Session.gold, gold_mid)
		assert_eq(Session.owned_count(dungeon.reward_card_id), 1)
		assert_eq(str(again["kind"]), "main")
		after_each()
		before_each()


func test_first_completion_opens_the_arena_and_the_second_the_alchemist() -> void:
	_enter("beefcake")
	var first: Dictionary = Session.resolve_main_dungeon(true)
	assert_true(bool(first["arena_opened"]))
	assert_false(bool(first["alchemist_opened"]))
	assert_eq(Session.completed_zone_count(), 1)
	_enter("necrocrat")
	var second: Dictionary = Session.resolve_main_dungeon(true)
	assert_false(bool(second["arena_opened"]), "the arena only announces once")
	assert_true(bool(second["alchemist_opened"]))
	assert_eq(Session.completed_zone_count(), 2)


func test_losing_in_the_dungeon_wakes_you_at_the_hub_without_completing() -> void:
	_enter("refusemancer")
	var gold_before: int = Session.gold
	Session.zone_run.damage(100)
	Session.run.life = 0
	var result: Dictionary = Session.resolve_main_dungeon(false, true)
	assert_false(Session.is_zone_completed("refusemancer"))
	assert_true(bool(result.get("woke_at_hub", false)))
	assert_lt(Session.gold, gold_before + 1)


func test_the_unique_cards_are_legendary_and_of_their_path() -> void:
	var expected: Dictionary = {"gourmand": Affinity.Type.B, "beefcake": Affinity.Type.A, "necrocrat": Affinity.Type.D, "refusemancer": Affinity.Type.C}
	for zone_id: String in ZONES:
		var card: CardData = Session.content.card(MainDungeons.def(zone_id).reward_card_id)
		assert_not_null(card, zone_id)
		assert_eq(card.rarity, CardEnums.Rarity.LEGENDARY)
		assert_eq(card.color, expected[zone_id])


func test_the_main_dungeon_icons_exist() -> void:
	for zone_id: String in ZONES:
		for foe: MainDungeonDef.Foe in MainDungeons.def(zone_id).foes.values():
			assert_not_null(CardIcons.named(foe.icon), "%s icon %s" % [foe.enemy_name, foe.icon])


func test_the_backdrops_build_for_every_theme() -> void:
	for theme: String in ["kitchen", "house", "hall", "rotheart"]:
		var backdrop: DungeonBackdrop = DungeonBackdrop.make(theme)
		add_child_autofree(backdrop)
		await wait_frames(2)
		assert_gt(backdrop.get_child_count(), 20, "%s backdrop has props" % theme)
