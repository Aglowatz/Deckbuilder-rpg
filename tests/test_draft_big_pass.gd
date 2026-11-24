extends GutTest
## Fable big pass Nov 23 (Parts 3 and 4): the owner's draft feedback and the Shuffle House, rule by rule.
##   the equipment pool (the removals, variety, no repeats, Path-bound pieces), the rivals (random Paths, capped equipment), the Path
##   rule, the Shuffle House's opening, the win-three tables, the rewards, the dungeon drafts (the Shuffled Halls, the pick after a
##   fight, the Trade Counter, the clear rewards), and the eight new cards.

const P := Affinity.Type
const ENEMY_UNIT_TARGETS: Array[int] = [CardEnums.TargetKind.ALL_ENEMY_UNITS, CardEnums.TargetKind.RANDOM_ENEMY_UNIT, CardEnums.TargetKind.CHOSEN_UNIT_ENEMY,
	CardEnums.TargetKind.ALL_ATTACKERS, CardEnums.TargetKind.ALL_UNITS, CardEnums.TargetKind.RANDOM_UNIT, CardEnums.TargetKind.CHOSEN_UNIT_ANY]
const HARMFUL_OPS: Array[int] = [CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.EffectOp.DESTROY, CardEnums.EffectOp.SEND_BACK]
const OUTSIDE_BATTLE: Array[int] = [Modifier.Kind.OVERWORLD_SPEED_PERCENT, Modifier.Kind.XP_BONUS_PERCENT, Modifier.Kind.WORLD_IMMUNITY,
	Modifier.Kind.MAX_DECK_COLORS, Modifier.Kind.MIN_DECK_SIZE]

var content: ContentSet


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	Session.draft = null
	Session.pending_draft_result = {}
	content = Session.content
	DraftRules.reload()


func after_each() -> void:
	if Session.draft_dungeon_active:
		Session.resolve_draft_dungeon(false)
	Session.draft = null
	Session.pending_draft_result = {}


func _free(zones: Array[String]) -> void:
	for zone_id: String in zones:
		Session.flags[str(ZoneCompletion.flag_name(zone_id))] = true


func _open_house() -> void:
	Session.set_flag(StringName(DraftChallenges.ARENA_FLAG))


func _pick_all() -> void:
	var guard: int = 0
	while Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		Session.draft_pick(guard % 3)
		guard += 1


# ---- The equipment pool -------------------------------------------------------------------------------------------------------------


func test_the_owners_removals_are_out_of_the_pool() -> void:
	var pool: Dictionary = {}
	for piece: EquipmentData in DraftEngine.equipment_pool(content):
		pool[piece.id] = piece
	for id: String in ["gotta_go_galoshes", "flamethrower", "thorned_loincloth", "clipwells_shears", "gladiators_net", "hall_pass_slippers", "participation_trophy"]:
		assert_not_null(content.equipment_piece(id), "%s is still a piece of the main game" % id)
		assert_false(pool.has(id), "%s is not offered in drafts" % id)


func test_no_piece_in_the_pool_hurts_enemy_units_or_only_works_outside_battle() -> void:
	for piece: EquipmentData in DraftEngine.equipment_pool(content):
		var in_battle: bool = false
		for modifier: Modifier in piece.modifiers:
			if not OUTSIDE_BATTLE.has(int(modifier.kind)):
				in_battle = true
			if modifier.effect == null:
				continue
			var at_enemy_units: bool = ENEMY_UNIT_TARGETS.has(int(modifier.effect.target)) or (int(modifier.kind) == int(Modifier.Kind.ON_ENEMY_UNIT_ENTER_EFFECT) and int(modifier.effect.target) == int(CardEnums.TargetKind.TRIGGERING_CARD))
			if at_enemy_units:
				assert_false(HARMFUL_OPS.has(int(modifier.effect.op)), "%s does not damage or remove enemy units" % piece.id)
				assert_false(int(modifier.effect.op) == int(CardEnums.EffectOp.BUFF) and (modifier.effect.amount < 0 or modifier.effect.amount2 < 0), "%s gives no enemy unit minus toughness" % piece.id)
		assert_true(in_battle, "%s does something in battle" % piece.id)


func test_every_slot_is_well_stocked_and_weak_pieces_are_commoner() -> void:
	for slot: int in range(EquipmentData.Slot.size()):
		assert_gte(DraftEngine.equipment_pool(content, slot).size(), 6, "%s has at least six pieces to offer" % EquipmentData.slot_name(slot as EquipmentData.Slot))
	assert_gt(DraftRules.equipment_weight(EquipmentData.Rarity.COMMON), DraftRules.equipment_weight(EquipmentData.Rarity.UNCOMMON))
	assert_gt(DraftRules.equipment_weight(EquipmentData.Rarity.UNCOMMON), DraftRules.equipment_weight(EquipmentData.Rarity.RARE))
	assert_gt(DraftRules.equipment_weight(EquipmentData.Rarity.RARE), DraftRules.equipment_weight(EquipmentData.Rarity.LEGENDARY))
	var pooled: Dictionary = {}
	for piece: EquipmentData in DraftEngine.equipment_pool(content):
		pooled[piece.id] = true
	for id: String in DraftGear.ids():
		assert_true(pooled.has(id), "%s (a draft piece) is in the pool" % id)
	assert_eq(DraftGear.MODEST.size(), 11, "eleven new modest pieces (the twelfth name, the Cardboard Cuirass, was in the game already)")
	assert_true(pooled.has("cardboard_cuirass"))
	for id: String in DraftGear.MODEST:
		assert_lte(int(content.equipment_piece(id).rarity), int(EquipmentData.Rarity.UNCOMMON), "%s is weak to medium" % id)
		assert_true(DraftGear.VENDOR_PIECES.has(id), "%s is on Bertram's stall from the start" % id)


func test_a_piece_is_not_offered_twice_in_one_draft() -> void:
	for seed_value: int in [11, 222, 3333]:
		var state: DraftState = DraftEngine.start(content, "zone:beefcake", [int(P.BEEFCAKE)] as Array[int], 12, seed_value)
		var seen: Dictionary = {}
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			guard += 1
			if str(state.offer["kind"]) == DraftEngine.KIND_EQUIPMENT:
				if int(state.offer["pick"]) == 2:
					assert_true(DraftEngine.reroll(content, state), "a reroll shows fresh pieces too")
				for id: Variant in state.offer["options"] as Array:
					assert_false(seen.has(str(id)) and int(seen[str(id)]) != state.step, "%s is offered once (seed %d)" % [str(id), seed_value])
					seen[str(id)] = state.step
			DraftEngine.pick(content, state, 0)
		assert_gte(seen.size(), 15, "five offers of three different pieces")


func test_a_path_bound_piece_is_only_offered_to_its_path() -> void:
	var headband: EquipmentData = content.equipment_piece("hustle_headband")
	assert_true(DraftEngine.fits_paths(headband, [int(P.BEEFCAKE)] as Array[int]))
	assert_false(DraftEngine.fits_paths(headband, [int(P.NECROCRAT)] as Array[int]), "Beefcake units have Hustle: nothing for a Necrocrat draft")
	assert_true(DraftEngine.fits_paths(content.equipment_piece("thinking_cap"), [int(P.NECROCRAT)] as Array[int]), "a general piece fits any draft")
	assert_true(DraftEngine.fits_paths(content.equipment_piece("pathwork_waistcoat"), [int(P.NECROCRAT)] as Array[int]), "Iron and Red Tape work for anyone")
	assert_false(DraftEngine.fits_paths(content.equipment_piece("bin_lid"), [int(P.BEEFCAKE)] as Array[int]), "Garbage does nothing without Refusemancer cards")
	for piece: EquipmentData in DraftEngine.equipment_pool(content, -1, [int(P.NECROCRAT)] as Array[int]):
		assert_ne(piece.id, "hustle_headband")


func test_the_modest_pieces_do_what_they_say() -> void:
	var expect: Dictionary = {
		"practice_foil": [Modifier.Kind.FIRST_UNIT_STAT_CHANGE], "rolled_rulebook": [Modifier.Kind.FIRST_SPELL_COST_CHANGE], "tinkers_wrench": [Modifier.Kind.STAT_CHANGE],
		"thinking_cap": [Modifier.Kind.FIRST_TURN_EXTRA_DRAW], "dealers_visor": [Modifier.Kind.MAX_HAND_SIZE, Modifier.Kind.STARTING_HP],
		"pathwork_waistcoat": [Modifier.Kind.STARTING_RESOURCES, Modifier.Kind.STARTING_RESOURCES, Modifier.Kind.STARTING_RESOURCES, Modifier.Kind.STARTING_RESOURCES],
		"shuffle_slippers": [Modifier.Kind.START_OF_DUEL_EFFECT, Modifier.Kind.START_OF_DUEL_EFFECT], "steady_sandals": [Modifier.Kind.MAX_HP, Modifier.Kind.STARTING_HP],
		"lucky_dice": [Modifier.Kind.STARTING_HP, Modifier.Kind.FIRST_TURN_EXTRA_DRAW], "pocket_hourglass": [Modifier.Kind.FIRST_CARD_COST_CHANGE, Modifier.Kind.MAX_HP],
		"fair_play_badge": [Modifier.Kind.MAX_HP, Modifier.Kind.MAX_HAND_SIZE],
	}
	for id: Variant in expect.keys():
		var piece: EquipmentData = content.equipment_piece(str(id))
		assert_not_null(piece, str(id))
		var kinds: Array[int] = []
		for modifier: Modifier in piece.modifiers:
			kinds.append(int(modifier.kind))
		var wanted: Array[int] = []
		for kind: Variant in expect[id] as Array:
			wanted.append(int(kind))
		assert_eq(kinds, wanted, "%s: %s" % [str(id), piece.description])
		assert_false(piece.flavor_text.is_empty(), "%s has its flavour line" % str(id))
	assert_eq(content.equipment_piece("tinkers_wrench").modifiers[0].value2, 1, "+0/+1")
	assert_eq(content.equipment_piece("pocket_hourglass").modifiers[0].value, -1, "the first card each turn costs 1 less")
	assert_eq(content.equipment_piece("pocket_hourglass").modifiers[1].value, -3, "at a price")


# ---- The rivals ---------------------------------------------------------------------------------------------------------------------


func test_rivals_draft_random_paths_one_each_in_a_single_path_draft() -> void:
	var paths_seen: Dictionary = {}
	for seed_value: int in [5, 6, 7, 8]:
		var state: DraftState = DraftEngine.start(content, "zone:beefcake", [int(P.BEEFCAKE)] as Array[int], 12, seed_value)
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			DraftEngine.pick(content, state, 0)
			guard += 1
		assert_true(DraftRun.begin(content, state))
		assert_eq(state.rivals.size(), 3)
		for rival: Dictionary in state.rivals:
			var own: Array = rival["paths"] as Array
			assert_eq(own.size(), 1, "a single-Path draft meets single-Path rivals")
			paths_seen[int(own[0])] = true
			for id: Variant in (rival["recipe"] as Dictionary).keys():
				var card: CardData = content.card(str(id))
				for path: Affinity.Type in card.paths():
					assert_eq(int(path), int(own[0]), "%s plays only its own Path and Pathless cards (%s)" % [str(rival["name"]), card.display_name])
	assert_gte(paths_seen.size(), 3, "over a few drafts the rivals turn up on different Paths, not only the player's")


func test_zone_rivals_never_wear_the_strongest_pieces_but_the_win_three_tables_rivals_may() -> void:
	assert_eq(DraftRules.rival_equipment_cap(DraftArena.KIND_ZONE), int(EquipmentData.Rarity.UNCOMMON), "the powerful pieces (Epic, Legendary) are the player's alone")
	assert_eq(DraftRules.rival_equipment_cap(DraftArena.KIND_HIGH), int(EquipmentData.Rarity.LEGENDARY))
	var strong_at_high: int = 0
	for seed_value: int in [21, 22, 23, 24, 25]:
		var zone: DraftState = DraftEngine.start(content, "zone:gourmand", [int(P.GOURMAND)] as Array[int], 12, seed_value)
		var high: DraftState = DraftEngine.start(content, DraftArena.HIGH_ID, [int(P.GOURMAND)] as Array[int], 12, seed_value)
		for index: int in range(3):
			for id: String in DraftRivals.draft(content, zone, DraftRivals.AGGRESSIVE, index, [int(P.GOURMAND)] as Array[int], DraftRules.rival_equipment_cap(DraftArena.KIND_ZONE)).equipment:
				assert_lte(int(content.equipment_piece(id).rarity), int(EquipmentData.Rarity.UNCOMMON), "a zone rival wears nothing above Uncommon (%s)" % id)
			for id: String in DraftRivals.draft(content, high, DraftRivals.AGGRESSIVE, index, [int(P.GOURMAND)] as Array[int], DraftRules.rival_equipment_cap(DraftArena.KIND_HIGH)).equipment:
				strong_at_high += 1 if int(content.equipment_piece(id).rarity) >= int(EquipmentData.Rarity.RARE) else 0
	assert_gt(strong_at_high, 0, "at the High Rollers Draft the opponents draft from the player's whole pool")
	# the player is never capped
	var epic_offered: bool = false
	for seed_value: int in range(40, 60):
		var state: DraftState = DraftEngine.start(content, "zone:gourmand", [int(P.GOURMAND)] as Array[int], 12, seed_value)
		for slot: int in range(EquipmentData.Slot.size()):
			for id: String in DraftEngine.equipment_offer(content, state, slot):
				epic_offered = epic_offered or int(content.equipment_piece(id).rarity) >= int(EquipmentData.Rarity.RARE)
	assert_true(epic_offered, "the player may still be offered the powerful pieces")


# ---- The Path rule and the Shuffle House ---------------------------------------------------------------------------------------------


func test_how_many_paths_a_draft_may_have_follows_the_story() -> void:
	assert_eq(DraftArena.max_paths({}), 1, "before any zone is freed: single-Path drafts only")
	assert_eq(DraftArena.max_paths({str(ZoneCompletion.flag_name("gourmand")): true}), 2, "two Paths after the first freed zone")
	assert_eq(DraftArena.max_paths({str(MultiPathLock.FLAG_UNLOCKED): true}), 4, "three and four after Primm")
	var open: Dictionary = {DraftChallenges.ARENA_FLAG: true}
	assert_false(DraftArena.locked_reason(DraftArena.pair_ids()[0], open).is_empty(), "a two-Path table is locked before a zone is freed")
	open[str(ZoneCompletion.flag_name("beefcake"))] = true
	assert_eq(DraftArena.locked_reason(DraftArena.pair_ids()[0], open), "")
	assert_true(DraftArena.locked_reason(DraftArena.trio_ids()[0], open).contains("Primm"))
	assert_true(DraftArena.locked_reason(DraftArena.QUAD_ID, open).contains("Primm"))
	open[str(MultiPathLock.FLAG_UNLOCKED)] = true
	assert_eq(DraftArena.locked_reason(DraftArena.QUAD_ID, open), "")
	for count: int in [1, 2, 4]:
		assert_true(DraftArena.paths_rule_text({} if count == 1 else open).length() > 20, "the menus say what is open and what opens next")
	assert_eq(DraftArena.pair_ids().size(), 6)
	assert_eq(DraftArena.trio_ids().size(), 4)
	assert_eq(DraftArena.high_ids().size(), 3)


func test_two_path_cards_are_drafted_once_a_zone_is_free() -> void:
	_open_house()
	_free(["beefcake"])
	# Fable Nov 24: the two-Path tables are Classic Drafts with two Paths switched on
	assert_false(Session.start_draft(DraftArena.pair_ids()[0], [] as Array[int]), "the separate two-Path tables are gone")
	assert_true(Session.start_draft(DraftArena.CLASSIC_ID, [int(P.BEEFCAKE), int(P.GOURMAND)] as Array[int]), "a Classic Draft with two Paths starts")
	assert_eq(Session.draft.paths.size(), 2)
	assert_true(Session.draft.two_path_ok, "two-Path cards are in its pool")
	assert_false(Session.draft.multi_path_ok)
	var two_path: int = 0
	for card: CardData in DraftEngine.card_pool(content, Session.draft):
		assert_lte(card.paths().size(), 2, "no three-Path card before Primm (%s)" % card.display_name)
		two_path += 1 if card.paths().size() == 2 else 0
	assert_gt(two_path, 5, "the pair's two-Path cards can be picked")
	Session.close_draft()
	# a single-Path draft never shows a two-Path card
	assert_true(Session.start_draft("open", [int(P.BEEFCAKE)] as Array[int]))
	for card: CardData in DraftEngine.card_pool(content, Session.draft):
		assert_lte(card.paths().size(), 1)


func test_the_shuffle_house_opens_with_four_zone_drafts_or_three_freed_zones() -> void:
	assert_false(DraftArena.is_open(Session.flags))
	assert_false(Session.open_shuffle_house_if_due())
	_free(["beefcake", "gourmand"])
	assert_false(DraftArena.is_open(Session.flags), "two zones are not enough")
	_free(["necrocrat"])
	assert_true(DraftArena.is_open(Session.flags), "three freed zones open it")
	assert_true(Session.open_shuffle_house_if_due())
	assert_true(Session.flag(StringName(DraftChallenges.ARENA_FLAG)))
	assert_false(Session.open_shuffle_house_if_due(), "once")
	# the other way in: all four zone drafts won
	Session.new_game()
	Session.ensure_game()
	for zone_id: String in DraftChallenges.ZONES:
		assert_false(DraftArena.is_open(Session.flags))
		Session.set_flag(StringName(DraftChallenges.won_flag(DraftChallenges.zone_id_for(zone_id))))
	assert_true(DraftArena.is_open(Session.flags), "all four zone drafts won open it")


func test_the_arena_quest_line_and_the_main_quest_are_registered() -> void:
	var by_id: Dictionary = {}
	for quest: QuestData in QuestDefinitions.build_all():
		by_id[quest.id] = quest
	for id: String in DraftArenaQuests.ids():
		assert_true(by_id.has(id), "%s is registered" % id)
		assert_true((by_id[id] as QuestData).auto_give, "%s is added by itself" % id)
		assert_gt((by_id[id] as QuestData).objectives.size(), 0)
	var main: QuestData = by_id[DraftArenaQuests.MAIN_QUEST] as QuestData
	assert_eq(main.category, QuestData.Category.MAIN, "a main quest")
	assert_eq(main.objectives.size(), 2, "meet Octavia, then play the Shuffled Halls once")
	assert_eq((by_id[DraftArenaQuests.PAIRS_QUEST] as QuestData).objectives.size(), 6)
	assert_eq((by_id[DraftArenaQuests.HALLS_QUEST] as QuestData).reward_card_ids, [DraftRivals.OCTAVIA_CARD] as Array[String], "Octavia's own card is the Halls' prize")
	assert_true((by_id[DraftHost.FINALE_QUEST] as QuestData).reward_card_ids.has(DraftRivals.TREY_CARD), "Trey's own card comes with his last quest")
	# the main quest: given at three freed zones, done by PLAYING the Halls (win or lose)
	_free(["beefcake", "gourmand", "necrocrat"])
	Session.open_shuffle_house_if_due()
	Session.offer_auto_quests()
	assert_true(Session.quest_log.is_active(DraftArenaQuests.MAIN_QUEST), "three freed zones give the main quest")
	assert_true(Session.quest_log.is_active(DraftArenaQuests.OPEN_QUEST), "and the arena line comes with the open house")
	Session.set_flag(StringName(DraftArena.MET_FLAG))
	Session.bump_counter("draft_halls_played")
	Session.refresh_quests()
	var state: UnlockState = Session.unlock_state()
	for objective: QuestObjective in main.objectives:
		assert_true(Condition.met(objective.condition, state), "done: %s" % objective.text)


func test_the_win_three_tables_are_retired_and_high_rollers_ends_like_classic() -> void:
	# Fable Nov 24: the three "win three" tables are the High Rollers Draft now - a Classic Draft for higher stakes (two losses)
	assert_eq(DraftChallenges.losses_to_finish(DraftArena.HIGH_ID), 2)
	assert_eq(DraftChallenges.losses_to_finish("zone:beefcake"), 2)
	_open_house()
	Session.gold = 1000
	assert_false(Session.start_draft("high:1", [int(P.NECROCRAT)] as Array[int]), "a retired table cannot be started")
	assert_true(Session.start_draft(DraftArena.HIGH_ID, [int(P.NECROCRAT)] as Array[int]))
	_pick_all()
	assert_true(Session.draft_begin_run())
	assert_false(DraftRun.record(Session.draft, false), "one loss: the run goes on")
	assert_true(DraftRun.record(Session.draft, false), "two losses and it is over")
	assert_true(Session.draft.is_finished())
	assert_false(Session.draft.full_win())


func test_table_rewards_pay_every_result_and_prismatic_packs_only_after_primm() -> void:
	var paths: Array[int] = [int(P.BEEFCAKE), int(P.GOURMAND)]
	var pair: String = DraftArena.CLASSIC_ID  # Fable Nov 24: the two-Path tables are Classic Drafts with two Paths switched on
	for wins: int in range(0, 3):
		var pay: Dictionary = DraftChallenges.reward(wins, false, false, pair, paths, false)
		assert_gt(int(pay["gold"]), 0, "%d wins still pay" % wins)
		assert_eq((pay["packs"] as Array).size(), 0)
		assert_false(bool(pay["keep_card"]))
	var replay: Dictionary = DraftChallenges.reward(3, true, false, pair, paths, false)
	var first: Dictionary = DraftChallenges.reward(3, true, true, pair, paths, false)
	assert_gt(int(replay["gold"]), int(DraftChallenges.reward(2, false, false, pair, paths, false)["gold"]), "more for three wins")
	assert_gt(int(first["gold"]), int(replay["gold"]) * 2, "much more the first time")
	assert_true(bool(replay["keep_card"]), "a full win keeps a card")
	assert_gt((first["packs"] as Array).size(), (replay["packs"] as Array).size())
	for pack: Variant in (first["packs"] as Array) + (replay["packs"] as Array):
		assert_ne(str(pack), PackRules.PRISMATIC_ID, "no Prismatic Pack before Primm")
		assert_not_null(PackCatalog.find(str(pack)), "%s is a real pack" % str(pack))
	var after: Dictionary = DraftChallenges.reward(3, true, true, pair, paths, true)
	assert_false((after["packs"] as Array).has(PackRules.PRISMATIC_ID), "Classic never pays a Prismatic Pack, after Primm either")
	var high_after: Dictionary = DraftChallenges.reward(3, true, true, DraftArena.HIGH_ID, paths, true)
	assert_true((high_after["packs"] as Array).has(PackRules.PRISMATIC_ID), "after Primm a High Rollers Draft pays a Prismatic Pack")
	var high_before: Dictionary = DraftChallenges.reward(3, true, true, DraftArena.HIGH_ID, paths, false)
	assert_false((high_before["packs"] as Array).has(PackRules.PRISMATIC_ID), "and a Gilded Pack before")
	var zone: Dictionary = DraftChallenges.reward(3, true, false, "zone:beefcake", [int(P.BEEFCAKE)] as Array[int], true)
	assert_eq(zone["packs"], [PackRules.path_pack_id(P.BEEFCAKE)], "a zone draft pays its Path Pack")


# ---- Dungeon drafts -----------------------------------------------------------------------------------------------------------------


func _start_halls() -> void:
	_open_house()
	assert_true(Session.start_draft(DraftArena.HALLS_ID, [int(P.BEEFCAKE)] as Array[int]), "the Shuffled Halls draft starts")
	_pick_all()
	assert_true(Session.draft_begin_run())


func test_the_shuffled_halls_has_its_eighteen_rooms_trey_and_octavia() -> void:
	var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(DraftArena.HALLS_DUNGEON)
	assert_not_null(plan)
	assert_true(plan.is_draft_only())
	assert_eq(plan.nodes.size(), 19, "the hidden way in and eighteen rooms")
	assert_eq(plan.map_id, "MAP-DRAFT")
	assert_eq(plan.battleboard_id, "BB-SHUFFLE")
	var map: DungeonMap = MainDungeons.build_map(DraftArena.HALLS_DUNGEON)
	assert_eq(map.problems(), [] as Array[String], "one start, one boss, every room reachable")
	assert_true(map.node(0).hidden, "the way in is not drawn")
	assert_eq(map.available().size(), 2, "two gates to choose from")
	# every route walks six rooms to the boss (seven by the Counting Room)
	var boss: DungeonMap.MapNode = map.boss()
	assert_eq(boss.number, 19)
	_start_halls()
	# Fable Nov 24: the Halls' cast is hand-made and static (tests/test_nov24_modes.gd): no rival is drafted for a room
	assert_true(Session.draft.rivals.is_empty(), "a dungeon draft drafts no rivals")
	var def: MainDungeonDef = MainDungeons.def(DraftArena.HALLS_DUNGEON)
	assert_eq(DungeonBuilder.foe_name_of(plan, plan.node(8)), "Trey Pickett", "Trey holds the Auction Ring")
	assert_true(def.foe("Trey Pickett").recipe.has(DraftRivals.TREY_CARD), "with his own card in his deck")
	assert_eq(DungeonBuilder.foe_name_of(plan, plan.node(14)), "Dex Shufflewick", "Dex runs the Roulette Pit")
	assert_eq(boss.enemy_name, "Octavia Eightfold")
	assert_gt(def.foe("Octavia Eightfold").hp_vs_player, def.foe("Trey Pickett").hp_vs_player, "she has more HP than a champion")
	assert_gt(def.foe("Trey Pickett").hp_vs_player, def.foe(DungeonBuilder.foe_name_of(plan, plan.node(2))).hp_vs_player, "and a champion more than a table dealer")
	var names: Dictionary = {}
	for node: DungeonMap.MapNode in map.nodes:
		if not DungeonMap.is_battle_kind(node.kind):
			continue
		assert_false(names.has(node.enemy_name), "%s sits in one room only" % node.enemy_name)
		names[node.enemy_name] = true
	assert_eq(names.size(), 10, "seven tables, two champions, the boss")


func test_a_dungeon_draft_swaps_the_hero_in_and_out_and_pays_once() -> void:
	var real: PlayerProfile = Session.profile
	var real_deck: Deck = Session.deck
	var gold: int = Session.gold
	_start_halls()
	assert_true(Session.prepare_draft_dungeon())
	assert_true(Session.draft_dungeon_active)
	assert_ne(Session.profile, real, "the draft's stand-in walks the dungeon")
	assert_eq(Session.deck.cards.size(), 35, "with the drafted deck")
	assert_eq(Session.run.hp, Session.run.max_hp(), "one HP pool, full at the door")
	assert_eq(Session.counter("draft_halls_played"), 1, "walking in counts as playing the Halls")
	assert_eq(Session.dungeon_key, DraftArena.HALLS_DUNGEON)
	var gate: DungeonMap.MapNode = Session.dungeon_map.available()[0]
	assert_true(["Maurice, Head of Security", "Tilda Tinsel, Confetti Cannoneer"].has(gate.enemy_name), "a gate's own dealer waits there (%s)" % gate.enemy_name)
	# a fight won: no gold or XP of its own, the rival's equipment as badges, then three cards on the table
	var context: BattleContext = Session.make_dungeon_battle(gate)
	assert_true(context.draft)
	assert_eq(context.gold_reward, 0)
	assert_eq(context.board_key, "BB-SHUFFLE", "on the house table")
	var badges: int = 0
	for badge: RuleBadges.Badge in context.rule_badges:
		badges += 1 if badge.side == RuleBadges.SIDE_ENEMY and badge.text.contains("wears this") else 0
	assert_eq(badges, MainDungeons.equipment_of(content, DraftArena.HALLS_DUNGEON, gate.enemy_name).size(), "the dealer's fixed equipment shows as battle effects")
	assert_gt(badges, 0)
	context.game.winner = 0
	var fight: Dictionary = Session.resolve_draft_dungeon_battle(context)
	assert_false(bool(fight["over"]))
	assert_eq(str(Session.draft.offer["kind"]), DraftEngine.KIND_DUNGEON_PICK)
	assert_eq((Session.draft.offer["options"] as Array).size(), 3)
	# add a card
	assert_true(Session.draft_dungeon_pick(0, -1))
	assert_eq(Session.deck.cards.size(), 36, "the pick joins the deck")
	assert_eq(Session.run.current_deck().cards.size(), 36)
	assert_true(Session.draft.offer.is_empty())
	# the next fight: swap a card in
	var next: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in Session.dungeon_map.available():
		if DungeonMap.is_battle_kind(node.kind):
			next = node
	assert_not_null(next, "a fight room in the second column")
	context = Session.make_dungeon_battle(next)
	context.game.winner = 0
	Session.resolve_draft_dungeon_battle(context)
	var out: int = -1
	for index: int in range(Session.draft.cards.size()):
		if not Session.draft.bench.has(index):
			out = index
			break
	assert_true(Session.draft_dungeon_pick(1, out), "swap")
	assert_eq(Session.deck.cards.size(), 36, "a swap keeps the deck's size")
	assert_true(Session.draft.bench.has(out))
	# a loss ends the run: the real hero is back, the run pays its consolation once
	var third: DungeonMap.MapNode = Session.dungeon_map.available()[0]
	if DungeonMap.is_battle_kind(third.kind):
		context = Session.make_dungeon_battle(third)
		context.game.winner = 1
		assert_true(bool(Session.resolve_draft_dungeon_battle(context)["over"]))
	else:
		Session.resolve_draft_dungeon(false)
	assert_false(Session.draft_dungeon_active)
	assert_eq(Session.profile, real, "the real hero is back")
	assert_eq(Session.deck, real_deck, "with the real deck")
	assert_null(Session.run)
	assert_true(Session.draft.dungeon_over)
	assert_false(Session.draft.full_win())
	assert_eq(Session.draft.fights_won, 2)
	assert_gt(Session.gold, gold, "two fights won pay a little")
	assert_false(Session.draft_keep(Session.draft.cards[0]), "no card without a clear")
	assert_false(Session.pending_draft_result.is_empty(), "the Shuffle House opens again on the result")


func test_clearing_the_halls_pays_more_and_the_first_clear_a_draft_piece() -> void:
	_start_halls()
	assert_true(Session.prepare_draft_dungeon())
	var owned: int = Session.owned_equipment_ids().size()
	var gold: int = Session.gold
	var pay: Dictionary = Session.resolve_draft_dungeon(true)
	assert_true(bool(pay["cleared"]))
	assert_true(bool(pay["first_win"]))
	assert_true(pay.has("equipment"), "the first clear guarantees a piece of draft equipment")
	assert_true(DraftGear.ids().has(str(pay["equipment"])))
	assert_eq(Session.owned_equipment_ids().size(), owned + 1)
	assert_gte((pay["packs"] as Array).size(), 3, "its own pack, the first-clear pack and the extra pack")
	assert_gt(Session.gold - gold, 300)
	assert_true(Session.flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID))))
	assert_true(Session.draft.full_win())
	assert_true(Session.draft_keep(Session.draft.cards[0]), "and one card of the draft deck is kept")
	Session.close_draft()
	# a later clear: no second piece, still the extra pack
	_start_halls()
	Session.prepare_draft_dungeon()
	var again: Dictionary = Session.resolve_draft_dungeon(true)
	assert_false(again.has("equipment"))
	assert_false(bool(again["first_win"]))
	assert_gte((again["packs"] as Array).size(), 2)
	assert_lt(int(again["gold"]), int(pay["gold"]))


func test_the_trade_counter_takes_a_card_for_a_card() -> void:
	_open_house()
	_free(["beefcake"])
	assert_true(Session.start_draft(DraftArena.HALLS_ID, [int(P.BEEFCAKE), int(P.GOURMAND)] as Array[int]))
	_pick_all()
	Session.draft_begin_run()
	Session.prepare_draft_dungeon()
	DraftEngine.make_trade_offer(content, Session.draft, 4)
	assert_eq(str(Session.draft.offer["kind"]), DraftEngine.KIND_DUNGEON_TRADE)
	var options: Array = Session.draft.offer["options"] as Array
	assert_eq(options.size(), 3)
	var multi: int = 0
	for id: Variant in options:
		multi += 1 if content.card(str(id)).paths().size() >= 2 else 0
	assert_gt(multi, 0, "a two-Path draft is shown two-Path cards")
	assert_false(Session.draft_dungeon_pick(0, -1), "a trade needs a card of the deck in exchange")
	var size: int = Session.deck.cards.size()
	var out: int = -1
	for index: int in range(Session.draft.cards.size()):
		if not Session.draft.bench.has(index):
			out = index
			break
	assert_true(Session.draft_dungeon_pick(0, out))
	assert_eq(Session.deck.cards.size(), size)
	# the rooms of the Halls that put an offer on the table
	var rooms: Dictionary = DungeonCatalog.content_for(DraftArena.HALLS_DUNGEON)["draft_rooms"] as Dictionary
	assert_eq(str(rooms["4"]), "trade")
	assert_eq(str(rooms["11"]), "vault")


func test_dungeon_drafts_are_for_dungeons_cleared_with_your_own_deck() -> void:
	_open_house()
	assert_eq(Session.draft_dungeon_keys(), [] as Array[String], "nothing cleared, nothing to draft")
	assert_false(Session.start_draft(DraftArena.dungeon_id("beefcake"), [int(P.BEEFCAKE)] as Array[int]))
	_free(["beefcake"])
	assert_true(Session.draft_dungeon_keys().has("beefcake"), "a freed zone's main dungeon")
	assert_false(Session.draft_dungeon_keys().has(PrimmsCastleDungeon.ZONE_ID), "the castle only once it is cleared (Fable Nov 24)")
	var vault: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone("town")
	Session.set_flag(Session.side_cleared_flag(vault))
	assert_false(Session.draft_dungeon_keys().has(vault.id), "a mini dungeon is Mystery Mini's, not the Dungeon Draft's (Fable Nov 24)")
	assert_true(Session.draft_mystery_pool().has(vault.id), "the vault, once cleared, is on the wheel")
	# Mystery Mini lands on a mini dungeon of its pool
	assert_true(Session.start_draft(DraftArena.MYSTERY_ID, [int(P.BEEFCAKE)] as Array[int]))
	_pick_all()
	assert_true(Session.draft_begin_run())
	assert_true(Session.draft_mystery_pool().has(Session.draft.dungeon_key))
	Session.draft.dungeon_key = vault.id
	assert_true(Session.prepare_draft_dungeon())
	assert_eq(Session.dungeon_key, vault.id)
	var first: DungeonMap.MapNode = Session.dungeon_map.available()[0]
	var context: BattleContext = Session.make_dungeon_battle(first)
	assert_true(context.draft)
	assert_eq(context.xp_reward, 0)
	# a clear pays the mini dungeon's gold and a pack (of its Path; a General Pack for the vault, which has none)
	var gold: int = Session.gold
	var pay: Dictionary = Session.resolve_draft_dungeon(true)
	assert_gte(Session.gold - gold, DungeonBuilder.SIDE_REPEAT_GOLD)
	assert_eq((pay["packs"] as Array).size(), 1, "one pack: the dungeon's Path's")
	assert_true(bool(pay["keep_card"]))
	Session.close_draft()
	# a zone's main dungeon with a drafted deck
	assert_true(Session.start_draft(DraftArena.dungeon_id("beefcake"), [int(P.NECROCRAT)] as Array[int]))
	_pick_all()
	Session.draft_begin_run()
	assert_true(Session.prepare_draft_dungeon())
	assert_eq(Session.dungeon_map.dungeon_name, MainDungeons.blueprint("beefcake").dungeon_name, "on its own map")
	var main_pay: Dictionary = Session.resolve_draft_dungeon(true)
	assert_true((main_pay["packs"] as Array).has(PackRules.path_pack_id(P.BEEFCAKE)), "its own Path Pack")


func test_a_chest_in_a_draft_dungeon_holds_gold_only() -> void:
	# Fable Nov 24: the Halls' Counting Room is the Counting Halls now (a cash-out, not a chest); a zone dungeon has a chest
	_open_house()
	_free(["beefcake"])
	assert_true(Session.start_draft(DraftArena.dungeon_id("beefcake"), [int(P.BEEFCAKE)] as Array[int]))
	_pick_all()
	assert_true(Session.draft_begin_run())
	Session.prepare_draft_dungeon()
	var room: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.kind == DungeonMap.Kind.TREASURE:
			room = node
	assert_not_null(room, "the dungeon's treasure room")
	var items: int = Session.profile.owned_items.size()
	var granted: Dictionary = Session.apply_treasure(room)
	assert_true(granted.has("gold"))
	assert_false(granted.has("xp"))
	assert_false(granted.has("equipment"))
	assert_eq(Session.profile.owned_items.size(), items)


# ---- The eight new cards ------------------------------------------------------------------------------------------------------------


func _card(id: String) -> CardData:
	var card: CardData = content.card(id)
	assert_not_null(card, id)
	return card


func _game_with_energy(colors: Array[int], each: int = 4) -> GameState:
	var game: GameState = GameFactory.blank_game(7)
	for color: int in colors:
		GameFactory.add_infrastructure_cards(game, 0, each, color as Affinity.Type)
	return game


func test_the_new_cards_are_in_the_sheet_with_scripts_that_parse() -> void:
	var expect: Dictionary = {"C-37": "First Pick", "C-38": "Wheel the Table", "C-39": "Signal Reader", "C-40": "Trey Pickett", "B-38": "Bomb in the Pack", "R-37": "Late-Pick Hero", "GN-17": "Table Captain", "P4-04": "Octavia Eightfold"}
	for id: Variant in expect.keys():
		var card: CardData = _card(str(id))
		assert_eq(card.display_name, str(expect[id]))
		assert_false(card.script_text.is_empty(), "%s is scripted" % str(id))
	assert_eq(_card("P4-04").paths().size(), 4, "Octavia is a four-Path card")
	assert_eq(int(_card("P4-04").rarity), int(CardEnums.Rarity.LEGENDARY))
	assert_eq(_card("C-40").paths().size(), 0, "Trey is Pathless")
	assert_eq(int(_card("C-40").rarity), int(CardEnums.Rarity.EPIC))
	assert_eq(_card("GN-17").paths().size(), 2)


func test_bomb_in_the_pack_hits_every_enemy_unit_and_spares_yours() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE)], 6)
	var mine: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var small: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 3))
	var big: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(3, 6))
	var bomb: CardInstance = GameFactory.add_to_hand(game, 0, _card("B-38"))
	assert_true(game.play_card(0, bomb.uid))
	assert_false(game.players[1].field.has(small), "a 1/3 dies to 4 damage")
	assert_true(game.players[1].field.has(big), "a 3/6 lives")
	assert_eq(big.damage, 4)
	assert_true(game.players[0].field.has(mine), "your own units are spared")
	assert_eq(mine.damage, 0)


func test_wheel_the_table_reshuffles_both_hands_and_deals_four_each() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE)], 4)
	for i: int in range(6):
		GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	var wheel: CardInstance = GameFactory.add_to_hand(game, 0, _card("C-38"))
	var deck_one: int = game.players[1].deck.size()
	assert_true(game.play_card(0, wheel.uid))
	assert_eq(game.players[0].hand.size(), 4, "you draw four")
	assert_eq(game.players[1].hand.size(), 4, "and so does the opponent")
	assert_eq(game.players[1].deck.size(), deck_one + 6 - 4, "their six went back into the deck first")


func test_signal_reader_shows_the_opponents_hand() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE)], 3)
	GameFactory.add_to_hand(game, 1, _card("C-37"))
	GameFactory.add_to_hand(game, 1, _card("B-38"))
	var reader: CardInstance = GameFactory.add_to_hand(game, 0, _card("C-39"))
	assert_true(game.play_card(0, reader.uid))
	var seen: GameEvent = null
	for event: GameEvent in game.events:
		if event.type == GameEvent.Type.HAND_REVEALED:
			seen = event
	assert_not_null(seen, "the hand is revealed")
	assert_eq(seen.player, 0)
	assert_eq(seen.other, 1)
	assert_eq(seen.amount, 2)
	assert_true(seen.detail.contains("First Pick") and seen.detail.contains("Bomb in the Pack"))
	assert_eq(game.players[1].hand.size(), 2, "nothing moves")


func test_first_pick_peeks_three_and_draws() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE)], 2)
	var pick: CardInstance = GameFactory.add_to_hand(game, 0, _card("C-37"))
	var deck: int = game.players[0].deck.size()
	assert_true(game.play_card(0, pick.uid))
	assert_eq(game.players[0].hand.size(), 1, "one card drawn")
	assert_eq(game.players[0].deck.size(), deck - 1)
	assert_gt(GameFactory.count_events(game, GameEvent.Type.PEEKED), 0, "after a Peek")


func test_late_pick_hero_grows_with_the_refuse_pile_up_to_plus_four() -> void:
	var game: GameState = GameFactory.blank_game(3)
	var hero: CardInstance = GameFactory.add_to_field(game, 0, _card("R-37"))
	assert_eq(game.get_attack(hero), 1)
	for i: int in range(2):
		game.players[0].refuse_pile.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	assert_eq(game.get_attack(hero), 3)
	assert_eq(game.get_defense(hero), 3)
	for i: int in range(6):
		game.players[0].refuse_pile.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	assert_eq(game.get_attack(hero), 5, "never more than +4/+4")
	assert_eq(game.get_defense(hero), 5)


func test_table_captain_brings_two_resources_and_toughens_the_others() -> void:
	var game: GameState = _game_with_energy([int(P.GOURMAND), int(P.NECROCRAT)], 3)
	var friend: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var captain: CardInstance = GameFactory.add_to_hand(game, 0, _card("GN-17"))
	var before: int = game.players[0].resources.size()
	assert_true(game.play_card(0, captain.uid))
	assert_eq(game.players[0].resources.size(), before + 2, "an Ingredient and a Red Tape")
	assert_eq(game.get_defense(friend), 3, "your other units get +0/+1")
	assert_eq(game.get_attack(friend), 2)
	assert_eq(game.get_defense(captain), 4, "not himself")


func test_octavia_eightfold_deals_four_cards() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE), int(P.GOURMAND), int(P.NECROCRAT), int(P.REFUSEMANCER)], 2)
	var octavia: CardInstance = GameFactory.add_to_hand(game, 0, _card("P4-04"))
	assert_true(game.play_card(0, octavia.uid), "six energy with one of each Path")
	assert_eq(game.players[0].hand.size(), 4, "the house deals four")
	assert_true(game.players[0].field.has(octavia))
	assert_eq(octavia.data.attack, 4)
	assert_eq(octavia.data.defense, 8)
	assert_true(octavia.data.keywords.has(CardEnums.Keyword.SWAT))


func test_trey_pickett_offers_one_of_three_every_turn() -> void:
	var game: GameState = _game_with_energy([int(P.BEEFCAKE)], 4)
	var trey: CardInstance = GameFactory.add_to_hand(game, 0, _card("C-40"))
	assert_true(game.play_card(0, trey.uid))
	assert_gt(GameFactory.count_events(game, GameEvent.Type.PEEKED), 0, "he looks at three when he enters")
	var hand: int = game.players[0].hand.size()
	var hp: int = game.players[0].hp
	var buffs: int = trey.buffs if "buffs" in trey else 0
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	var got: int = (1 if game.players[0].hand.size() > hand + 1 else 0) + (1 if game.players[0].hp > hp else 0) + (1 if ("buffs" in trey and trey.buffs > buffs) else 0)
	assert_eq(got, 1, "at the start of your turn exactly one of the three happens (a card, 2 HP or a buff)")
