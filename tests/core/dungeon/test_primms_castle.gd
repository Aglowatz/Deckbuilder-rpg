extends GutTest
## Brief 10, Parts C and D: Primm's Castle (the final dungeon on the node-map system, 25+ nodes, heavy branching, dead-end side
## branches that double back, themed sections, all kinds of nodes, text keys) and the three-phase boss (Standardization,
## Reflection, Unraveling), the freed leaders' boons, and the flow of a boss run (phases, between-phase scenes, victory,
## the postgame unlock).

var _def: MainDungeonDef
var _map: DungeonMap
var _story: ZoneStoryText


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)
	_def = MainDungeons.def(PrimmsCastleDungeon.ZONE_ID)
	_map = MainDungeons.build_map(PrimmsCastleDungeon.ZONE_ID)
	_story = ZoneStoryText.for_zone(CapitalZone.ID)


func after_each() -> void:
	ZoneStoryText.set_zone_freed(CapitalZone.ID, false)
	Session.main_dungeon_active = false


# ---- Structure -------------------------------------------------------------------------------------------


func test_the_castle_is_registered_and_sound() -> void:
	assert_true(MainDungeons.has_def(CapitalZone.ID), "the Capital's main dungeon spot enters it")
	assert_eq(_map.dungeon_name, "Primm's Castle")
	assert_eq(_map.problems(), [] as Array[String], "a sound map")
	assert_gte(_map.nodes.size(), 25, "20+ nodes")


func test_heavy_branching_and_rejoining() -> void:
	assert_gte(_map.branch_points().size(), 8, "many real route choices")
	assert_gte(_map.rejoin_points().size(), 5, "routes rejoin")
	assert_gte(_map.route_count(), 8, "several distinct routes from the doors to the boss")


func test_dead_end_branches_double_back() -> void:
	var dead_ends: Array[int] = _map.dead_ends()
	assert_gte(dead_ends.size(), 6, "treasure, encounters, events and lore dead-end")
	var kinds: Dictionary = {}
	for id: int in dead_ends:
		var node: DungeonMap.MapNode = _map.node(id)
		assert_true(node.next.is_empty(), "%s leads nowhere forward" % node.title)
		assert_lt(node.return_to, node.id)
		assert_true(_map.node(node.return_to).next.has(id), "and hangs off %s" % _map.node(node.return_to).title)
		kinds[node.kind] = true
	assert_true(kinds.has(DungeonMap.Kind.TREASURE) and kinds.has(DungeonMap.Kind.EVENT) and kinds.has(DungeonMap.Kind.BATTLE), "dead ends of several kinds")


func test_doubling_back_returns_to_the_branch_point_and_the_main_route_stays_open() -> void:
	# Walk: doors -> hall -> portraits (a branch point) -> the alcove (a dead end) -> back at the portraits.
	_map.complete(0)
	_map.complete(1)
	var portraits: DungeonMap.MapNode = _map.node(2)
	assert_true(_map.is_available(portraits.id))
	_map.complete(portraits.id)
	var alcove: DungeonMap.MapNode = _map.node(4)
	assert_eq(alcove.return_to, portraits.id)
	assert_true(_map.is_available(alcove.id))
	assert_true(_map.complete(alcove.id))
	assert_eq(_map.current, portraits.id, "the party doubled back")
	assert_eq(_map.last_cleared, alcove.id)
	assert_true(_map.is_cleared(alcove.id))
	var choices: Array[int] = []
	for node: DungeonMap.MapNode in _map.available():
		choices.append(node.id)
	assert_false(choices.has(alcove.id), "the dead end is done")
	assert_true(choices.has(5), "the way forward is still open")


func test_the_four_wings_can_all_be_visited_from_the_junction() -> void:
	var junction: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in _map.nodes:
		if node.title == _story.text("dungeon.pc_junction.title"):
			junction = node
	assert_not_null(junction)
	var wings: int = 0
	for id: int in junction.next:
		if _map.node(id).return_to == junction.id:
			wings += 1
	assert_eq(wings, 4, "one dead-end wing per Path")
	_complete_path_to(_map, junction.id)
	assert_eq(_map.current, junction.id)
	for wing_id: int in junction.next.duplicate():
		if _map.node(wing_id).return_to == junction.id:
			assert_true(_map.complete(wing_id))
			assert_eq(_map.current, junction.id)
	assert_gte(_map.available().size(), 2, "the servants' corridor and the staircase are still open")


func test_sections_and_node_kinds() -> void:
	var sections: Dictionary = {}
	var kinds: Dictionary = {}
	for node: DungeonMap.MapNode in _map.nodes:
		sections[node.section] = true
		kinds[node.kind] = true
	for section: String in ["the Great Hall", "the Portrait Gallery", "the Hall of Mirrors", "the Ministry of Correction", "the Four Wings", "the Archive of Good Intentions", "the Scale Model Chamber",
			"the Gourmand Wing", "the Beefcake Wing", "the Necrocrat Wing", "the Refusemancer Wing"]:
		assert_true(sections.has(section), section)
	for kind: DungeonMap.Kind in [DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE, DungeonMap.Kind.CHALLENGE, DungeonMap.Kind.EVENT, DungeonMap.Kind.SHRINE, DungeonMap.Kind.TREASURE, DungeonMap.Kind.BOSS]:
		assert_true(kinds.has(kind), "node kind %d" % kind)
	var challenges: int = 0
	for node: DungeonMap.MapNode in _map.nodes:
		if node.kind == DungeonMap.Kind.CHALLENGE:
			challenges += 1
	assert_gte(challenges, 3, "deck challenges")


func test_the_final_chamber_and_the_boss() -> void:
	var boss: DungeonMap.MapNode = _map.boss()
	assert_not_null(boss)
	assert_eq(boss.enemy_name, PrimmBoss.BOSS_FOE)
	assert_eq(boss.section, "the Scale Model Chamber")
	assert_eq(boss.scene, "primm_intro")
	assert_eq(boss.after_scene, "primm_end")
	assert_true(CutsceneDefs.has_scene("primm_intro") and CutsceneDefs.has_scene("primm_p1") and CutsceneDefs.has_scene("primm_p2") and CutsceneDefs.has_scene("primm_end"))
	assert_eq(_def.backdrop, "castle")
	assert_eq(_def.reward_card_id, "the_paths_united")
	assert_not_null(Session.card_by_id(_def.reward_card_id))


func test_every_foe_deck_is_real_and_every_icon_exists() -> void:
	for node: DungeonMap.MapNode in _map.nodes:
		if not DungeonMap.is_battle_kind(node.kind):
			continue
		var foe: MainDungeonDef.Foe = _def.foe(node.enemy_name)
		assert_not_null(foe, node.enemy_name)
		var deck: Deck = ZoneDecks.from_recipe(Session.content, foe.enemy_name, foe.recipe)
		assert_gt(deck.size(), 20, "%s has a deck" % foe.enemy_name)
		for key: Variant in foe.recipe.keys():
			if not str(key).begins_with("infrastructure:"):
				assert_not_null(Session.content.card(str(key)), "%s: card %s" % [foe.enemy_name, str(key)])
		assert_not_null(CardIcons.named(foe.icon), "icon %s" % foe.icon)


func test_every_text_key_the_castle_uses_exists() -> void:
	var missing: Array[String] = []
	for node: DungeonMap.MapNode in _map.nodes:
		_check(node.title, "node %d title" % node.id, missing)
		_check(node.blurb, "node %d blurb" % node.id, missing)
		if not node.story_before.is_empty():
			_check(_story.text(node.story_before), node.story_before, missing)
		if not node.story_after.is_empty():
			_check(_story.text(node.story_after), node.story_after, missing)
	for event_id: Variant in _def.events.keys():
		var event: DungeonEvent = _def.events[event_id] as DungeonEvent
		_check(_story.text(event.title_key()), event.title_key(), missing)
		_check(_story.text(event.body_key()), event.body_key(), missing)
		for index: int in range(event.choices.size()):
			_check(_story.text(event.choice_key(index)), event.choice_key(index), missing)
			_check(_story.text(event.result_key(index)), event.result_key(index), missing)
	for challenge_id: Variant in _def.challenges.keys():
		_check(_story.text("challenge.%s.title" % str(challenge_id)), "challenge %s title" % str(challenge_id), missing)
		_check(_story.text("challenge.%s.text" % str(challenge_id)), "challenge %s text" % str(challenge_id), missing)
	for scene_id: String in ["primm_intro", "primm_p1", "primm_p2", "primm_end"]:
		for beat: Dictionary in CutsceneDefs.beats(scene_id):
			_check(_story.text(str(beat["key"])), str(beat["key"]), missing)
			_check(_story.text(str(beat["speaker_key"])), str(beat["speaker_key"]), missing)
	for key: String in PrimmBoss.PHASE_KEYS:
		_check(_story.text("boss.phase.%s.title" % key), key + " title", missing)
		_check(_story.text("boss.phase.%s.rule" % key), key + " rule", missing)
	for zone_id: String in PrimmBoss.LEADERS.keys():
		_check(_story.text("boon.%s.name" % zone_id), "boon name " + zone_id, missing)
		_check(_story.text("boon.%s.line" % zone_id), "boon line " + zone_id, missing)
	assert_eq(missing, [] as Array[String], "missing castle text")


func test_the_story_beats_are_in_the_story_data_not_in_code() -> void:
	var source: String = FileAccess.get_file_as_string("res://core/dungeon/primms_castle_dungeon.gd")
	assert_false(source.contains("LAB NOTES"), "no story text in the dungeon script")
	var text: String = FileAccess.get_file_as_string("res://data/story/capital_story.tres")
	for needle: String in ["LAB NOTES", "COUP ORDERS", "FORM 1-A (NOTARIZED)", "THE SEED", "Year 1: Wells", "IMPROVED"]:
		assert_true(text.contains(needle), needle)


# ---- The boss -------------------------------------------------------------------------------------------------


func test_three_phases_with_their_own_rules() -> void:
	assert_eq(PrimmBoss.PHASES, 3)
	var standard: PrimmBoss.Phase = PrimmBoss.phase(0)
	var found_standard: bool = false
	for modifier: Modifier in standard.enemy_modifiers:
		found_standard = found_standard or modifier.kind == Modifier.Kind.STANDARDIZE_CREATURES
	assert_true(found_standard, "Standardization: every creature has the same stats")
	assert_eq(PrimmBoss.player_rules(0).modifiers[0].kind, Modifier.Kind.MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN, "and you may cast only two spells a turn")
	assert_true(PrimmBoss.phase(1).mirror, "Reflection: he copies your cards")
	assert_null(PrimmBoss.player_rules(1))
	var unravel: PrimmBoss.Phase = PrimmBoss.phase(2)
	var self_damage: bool = false
	for modifier: Modifier in unravel.enemy_modifiers:
		self_damage = self_damage or (modifier.kind == Modifier.Kind.START_OF_TURN_EFFECT and modifier.effect != null and modifier.effect.op == CardEnums.EffectOp.LOSE_LIFE)
	assert_true(self_damage, "Unraveling: his own rules hurt him")
	for index: int in range(3):
		assert_false(PrimmBoss.phase(index).title().begins_with("[missing"))
		assert_false(PrimmBoss.phase(index).rule_text().begins_with("[missing"))


func test_standardization_makes_every_creature_the_same_in_a_real_duel() -> void:
	_start_castle_run()
	var boss: DungeonMap.MapNode = _map.boss()
	Session.boss_phase = 0
	var context: BattleContext = Session.make_dungeon_battle(boss)
	assert_eq(context.boss_phase, 0)
	assert_true(context.enemy_name.contains("Standardization"))
	assert_ne(context.rules_text, "")
	assert_eq(context.music, &"primm")
	var game: GameState = context.game
	var big: CardInstance = game.create_instance(Session.card_by_id("ironclad"), 0)
	var small: CardInstance = game.create_instance(Session.card_by_id("cave_bat"), 1)
	game.players[0].battlefield.append(big)
	game.players[1].battlefield.append(small)
	assert_eq(game.get_power(big), PrimmBoss.STANDARD_POWER)
	assert_eq(game.get_toughness(big), PrimmBoss.STANDARD_TOUGHNESS)
	assert_eq(game.get_power(small), PrimmBoss.STANDARD_POWER)
	assert_eq(game.players[0].non_infrastructure_cast_cap, PrimmBoss.SPELL_CAP, "two spells a turn")
	assert_eq(game.players[1].life, PrimmBoss.phase(0).life)


func test_reflection_copies_the_players_deck() -> void:
	_start_castle_run()
	Session.boss_phase = 1
	var context: BattleContext = Session.make_dungeon_battle(_map.boss())
	var mine: Dictionary = Session.run.current_deck().copy_counts()
	var his: Dictionary = {}
	for card: CardInstance in context.game.players[1].library:
		his[card.data.id] = int(his.get(card.data.id, 0)) + 1
	for card: CardInstance in context.game.players[1].hand:
		his[card.data.id] = int(his.get(card.data.id, 0)) + 1
	assert_eq(his, mine, "a perfect copy: he can only imitate")
	assert_eq(context.game.players[0].non_infrastructure_cast_cap, -1, "no restriction in this phase")


func test_unraveling_hurts_him_each_turn_and_makes_him_stronger() -> void:
	_start_castle_run()
	Session.boss_phase = 2
	var context: BattleContext = Session.make_dungeon_battle(_map.boss())
	var mods: ModifierSet = context.game.players[1].modifiers
	assert_eq(mods.stat_bonus(Affinity.Type.NEUTRAL), Vector2i(1, 1))
	assert_gt(mods.sum(Modifier.Kind.EXTRA_DRAWS), 0)
	assert_eq(mods.effects_of(Modifier.Kind.START_OF_TURN_EFFECT).size(), 1)


func test_capital_debuffs_apply_to_castle_duels_too() -> void:
	_start_castle_run()
	var hall: DungeonMap.MapNode = _map.node(1)
	var context: BattleContext = Session.make_dungeon_battle(hall)
	assert_eq(context.game.players[1].modifiers.sum(Modifier.Kind.GRAVEYARD_RETURN_CHANCE), CapitalDebuffs.RETURN_CHANCE_PERCENT, "Restless Dead until the D.N.A. is free")
	var junk: int = 0
	for card: CardInstance in context.game.players[0].library:
		junk += 1 if card.data.id == CapitalContent.JUNK_ID else 0
	for card: CardInstance in context.game.players[0].hand:
		junk += 1 if card.data.id == CapitalContent.JUNK_ID else 0
	assert_eq(junk, CapitalDebuffs.JUNK_COUNT, "Clutter until the Dump is free")


func test_freed_leaders_lend_a_boon_each() -> void:
	assert_eq(PrimmBoss.leader_boons(Session.flags).size(), 0, "nobody stands beside you at first")
	assert_true(PrimmBoss.leader_lines(Session.flags)[0].contains("Nobody stands beside you"))
	_start_castle_run()
	var life_before: int = Session.run.max_life()
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		Session.complete_zone(zone_id)
	var boons: Array[ModifierSource] = PrimmBoss.leader_boons(Session.flags)
	assert_eq(boons.size(), 4)
	for boon: ModifierSource in boons:
		assert_eq(boon.source_kind, ModifierSource.SourceKind.BOON)
		assert_false(boon.source_name.begins_with("[missing"))
	var lines: Array[String] = Session.begin_primm_fight()
	assert_gte(lines.size(), 4, "each leader speaks")
	assert_gt(Session.run.max_life(), life_before, "+2 max life each")
	var after: int = Session.run.max_life()
	Session.begin_primm_fight()
	assert_eq(Session.run.max_life(), after, "boons are given once per run")


# ---- The flow of a boss run, ending, and the postgame ---------------------------------------------------------------------


func test_winning_a_phase_goes_on_to_the_next_and_the_last_completes_the_node() -> void:
	_start_castle_run()
	var boss: DungeonMap.MapNode = _map.boss()
	_complete_path_to(Session.dungeon_map, boss.id - 1)
	assert_true(Session.dungeon_map.is_available(boss.id))
	for phase_index: int in range(PrimmBoss.PHASES):
		Session.boss_phase = phase_index
		var context: BattleContext = Session.make_dungeon_battle(boss)
		assert_eq(context.boss_phase, phase_index)
		context.won = true
		context.game.players[1].life = 0
		context.game.winner = 0
		_finish_battle(context)
		if phase_index < PrimmBoss.PHASES - 1:
			assert_true(Session.boss_phase_pending, "the next phase waits for the scene")
			assert_eq(Session.boss_phase, phase_index + 1)
			assert_false(Session.dungeon_map.is_cleared(boss.id), "the boss node is not done yet")
			Session.boss_phase_pending = false
	assert_true(Session.dungeon_map.is_cleared(boss.id), "the third phase completes it")


func test_beating_primm_unlocks_the_postgame_and_sets_the_ending() -> void:
	_start_castle_run()
	assert_false(Session.profile.postgame_unlocked)
	var result: Dictionary = Session.resolve_main_dungeon(true, false)
	assert_eq(result["kind"], "primm_defeated")
	assert_true(bool(result["postgame_unlocked"]))
	assert_true(Session.profile.postgame_unlocked)
	assert_true(Session.flag(&"primm_defeated"))
	assert_true(Session.is_zone_completed(CapitalZone.ID), "the Capital is freed")
	assert_gt(Session.owned_count("the_paths_united"), 0, "the unique reward card")
	assert_eq(Session.pack_count(PackRules.PRISMATIC_ID), PackCatalog.config().primm_prismatic_packs, "Primm's fall pays a Prismatic Pack")
	assert_false(Session.pending_ending_packs.is_empty(), "announced after the ending")
	_start_castle_run()
	var again: Dictionary = Session.resolve_main_dungeon(true, false)
	assert_ne(again.get("kind"), "primm_defeated", "only the first time")
	assert_eq(Session.pack_count(PackRules.PRISMATIC_ID), PackCatalog.config().primm_prismatic_packs, "only the first time")


func test_losing_a_phase_sends_you_home_and_resets_the_boss() -> void:
	_start_castle_run()
	Session.boss_phase = 1
	Session.boss_phase_pending = true
	var result: Dictionary = Session.resolve_main_dungeon(false, true)
	assert_true(bool(result.get("woke_at_hub", false)))
	assert_eq(Session.boss_phase, 0)
	assert_false(Session.boss_phase_pending)
	assert_false(Session.profile.postgame_unlocked)


# ---- Helpers -------------------------------------------------------------------------------------------------------------------


func _check(text: String, what: String, missing: Array[String]) -> void:
	if text.is_empty() or text.begins_with("[missing"):
		missing.append(what)


func _start_castle_run() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	_map = Session.dungeon_map
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.run.life = clampi(Session.zone_run.life, 1, Session.run.max_life())
	Session.main_dungeon_active = true
	Session.boss_phase = 0
	Session.boss_phase_pending = false
	Session.boss_boons_given = false


## Completes nodes along the forward routes until the party stands on `target_id`.
func _complete_path_to(map: DungeonMap, target_id: int) -> void:
	var guard: int = 0
	while map.current != target_id and guard < 80:
		guard += 1
		var options: Array[DungeonMap.MapNode] = map.available()
		if options.is_empty():
			return
		var pick: DungeonMap.MapNode = null
		for option: DungeonMap.MapNode in options:
			if option.return_to < 0 and map.reachable_from(option.id).has(target_id):
				pick = option
				break
		if pick == null:
			return
		map.complete(pick.id)


## What `Session.complete_battle` does for a finished duel, without the scene change.
func _finish_battle(context: BattleContext) -> void:
	Session.run.finish_encounter(context.game)
	if context.boss_phase >= 0 and context.boss_phase < PrimmBoss.PHASES - 1:
		Session.boss_phase = context.boss_phase + 1
		Session.boss_phase_pending = true
		return
	Session.dungeon_map.complete(context.node_id)


func test_every_castle_node_resolves_through_the_session_api_in_a_full_run() -> void:
	# A headless run: the first forward route to the boss with a dead end taken on the way; every node kind is resolved by the same
	# Session / resolver calls the map screens use (battles are won by decree).
	Session.profile.max_life = PlayerProfile.ENDGAME_MAX_LIFE
	_start_castle_run()
	var map: DungeonMap = Session.dungeon_map
	var dead_end_taken: bool = false
	var guard: int = 0
	while not map.is_complete() and guard < 80:
		guard += 1
		var options: Array[DungeonMap.MapNode] = map.available()
		assert_false(options.is_empty(), "never stuck (current node %d)" % map.current)
		if options.is_empty():
			return
		var node: DungeonMap.MapNode = options[0]
		for option: DungeonMap.MapNode in options:
			if option.return_to >= 0 and not dead_end_taken:
				node = option
				dead_end_taken = true
				break
			if option.return_to < 0 and (node.return_to >= 0 and dead_end_taken):
				node = option
		match node.kind:
			DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE:
				var context: BattleContext = Session.make_dungeon_battle(node)
				context.game._end_game(0, false)
				Session.run.finish_encounter(context.game)
				assert_false(Session.run.failed)
				map.complete(node.id)
			DungeonMap.Kind.BOSS:
				for phase_index: int in range(PrimmBoss.PHASES):
					Session.boss_phase = phase_index
					var boss_context: BattleContext = Session.make_dungeon_battle(node)
					boss_context.game._end_game(0, false)
					Session.run.finish_encounter(boss_context.game)
				map.complete(node.id)
			DungeonMap.Kind.EVENT:
				var event: DungeonEvent = _def.event(node.event_id)
				assert_not_null(event, node.event_id)
				var result: EventResolver.Result = Session.resolve_dungeon_event(event, 0)
				assert_true(result.ok, node.event_id)
				map.complete(node.id)
			DungeonMap.Kind.CHALLENGE:
				var challenge: ChallengeData = _def.challenge(node.challenge_id)
				assert_not_null(challenge, node.challenge_id)
				ChallengeResolver.resolve(challenge, Session.run, Session.rng)
				map.complete(node.id)
			DungeonMap.Kind.SHRINE:
				Session.run.heal(node.heal_amount)
				map.complete(node.id)
			DungeonMap.Kind.TREASURE:
				var granted: Dictionary = Session.apply_treasure(node)
				assert_false(granted.is_empty(), "the chest held something")
				map.complete(node.id)
			_:
				map.complete(node.id)
		Session.run.life = maxi(Session.run.life, 1)
	assert_true(map.is_complete(), "reached and cleared the boss through %d steps" % guard)
	assert_true(dead_end_taken)
