class_name DevActions
extends RefCounted
## Oct 20, Part 1: every Dev Menu action (`DevMenu`, F10, debug builds only - `DevTools.menu_enabled`). Each one goes through the real
## systems (Session, the quest log, flags, the scene manager) and returns the line the menu toasts. Kept apart from the panel so GUT can
## drive the actions without any UI. Docs: docs/dev_menu.md.

## An anchor/spot the next scene teleports the hero to once it is revealed (`DevMenu` applies it), "" = none.
static var pending_teleport: String = ""
## A scene method the next scene calls once it is revealed ("_open_arena"), "" = none.
static var pending_call: String = ""

const SNAPSHOT_DIR: String = "user://dev_saves/"
const DECK_MINE: int = -1


# ---- Travel ----------------------------------------------------------------------------------------------------------------------


static func travel_town() -> String:
	Session.ensure_game()
	Session.zone_run = null
	Session.pending_zone_id = ""
	Session.pending_zone_result = {}
	SceneManager.go_to_town()
	return "Travel: Crosspath"


static func travel_forest() -> String:
	Session.ensure_game()
	Session.zone_run = null
	SceneManager.go_to_start_area()
	return "Travel: the starting forest"


## A Path zone or the Capital ("final"), entered from town as a fresh visit (gatekeeper locks are ignored on purpose).
static func travel_zone(zone_id: String, anchor: String = "") -> String:
	Session.ensure_game()
	if not ZoneDefs.has_def(zone_id):
		return "Unknown zone %s" % zone_id
	pending_teleport = anchor
	Session.enter_zone(zone_id)
	return "Travel: %s%s" % [ZoneDefs.get_def(zone_id).display_name, (" (%s)" % anchor) if not anchor.is_empty() else ""]


## The Capital inside the gate: the gate counts as open and the hub as known (as after the real gate fight), then the Crease.
static func travel_capital_inside() -> String:
	Session.ensure_game()
	Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	return travel_zone(CapitalZone.ID, "crease_spawn").replace("(crease_spawn)", "(inside the gate)")


## The Undercroft arena: Crosspath, then the arena screen opens.
static func travel_arena() -> String:
	travel_town()
	pending_teleport = "arena"
	pending_call = "_open_arena"
	return "Travel: the Undercroft arena"


## Every dungeon the menu offers: id -> label (main dungeons, side dungeons, the Forgotten Cave, the Lab).
static func dungeon_choices() -> Dictionary:
	var result: Dictionary = {}
	for plan_id: String in DungeonCatalog.ids():
		var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(plan_id)
		result[plan_id] = "%s  %s" % [plan_id, plan.dungeon_name]
	return result


## Enters dungeon `dungeon_id` through its real entry (`Session.enter_main_dungeon`, `enter_mini_dungeon`, ...) and, with `node_id` >= 0,
## walks the map up to just before that node (the boss with `-2`), so the party stands next to it.
static func travel_dungeon(dungeon_id: String, node_id: int = -1) -> String:
	Session.ensure_game()
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
	if plan == null:
		return "Unknown dungeon %s" % dungeon_id
	if plan.type == DungeonCatalog.TYPE_TUTORIAL:
		Session.begin_trial()
	elif plan.id == PathologyLab.DUNGEON_ID:
		Session.enter_lab()
	elif plan.zone_id == "town":
		Session.enter_town_side_dungeon()
	elif not plan.is_side() and not plan.is_postgame() and MainDungeons.has_def(plan.zone_id):
		Session.begin_zone_visit(plan.zone_id)
		Session.enter_main_dungeon()
	elif ZoneDefs.has_def(plan.zone_id) and DungeonCatalog.side_for_zone(plan.zone_id) != null and DungeonCatalog.side_for_zone(plan.zone_id).id == plan.id:
		Session.begin_zone_visit(plan.zone_id)
		Session.enter_mini_dungeon()
	else:
		# A side dungeon with no reachable entry (S-BEEF behind its sealed gate): the same state the real entries set.
		if ZoneDefs.has_def(plan.zone_id):
			Session.begin_zone_visit(plan.zone_id)
		Session.dungeon_key = plan.id
		Session.dungeon_map = MainDungeons.build_map(plan.id)
		Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources if Session.zone_run != null else [] as Array[ModifierSource])
		Session.mini_active = true
		Session.main_dungeon_active = false
		Session.town_side_active = not ZoneDefs.has_def(plan.zone_id)
		Session.trial_finished = false
		Session.pending_reward = null
		SceneManager.change_scene("res://scenes/dungeon_map.tscn")
	# The scene changes after a fade, so the map can still be walked forward here.
	var target: int = node_id
	if target == -2 and Session.dungeon_map != null and Session.dungeon_map.boss() != null:
		target = Session.dungeon_map.boss().id
	var walked: int = walk_map_to(Session.dungeon_map, target) if target >= 0 else 0
	return "Travel: %s%s" % [dungeon_id, (" at node %d (%d cleared on the way)" % [target, walked]) if target >= 0 else ""]


## The map dungeon `dungeon_id` would be entered on (the same builder its real entry uses), for the node picker. Null if unknown.
static func preview_map(dungeon_id: String) -> DungeonMap:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
	if plan == null:
		return null
	if plan.type == DungeonCatalog.TYPE_TUTORIAL:
		return TrialOfTheHollow.build_map()
	if not plan.is_side() and not plan.is_postgame() and MainDungeons.has_def(plan.zone_id):
		return MainDungeons.build_map(plan.zone_id)
	if ZoneDefs.has_def(plan.zone_id) and DungeonCatalog.side_for_zone(plan.zone_id) != null and DungeonCatalog.side_for_zone(plan.zone_id).id == plan.id:
		return MiniDungeon.build_map(plan.zone_id)
	return MainDungeons.build_map(plan.id)


## Completes the nodes on the shortest route from the map's current node to just before `target`. Returns how many it completed.
static func walk_map_to(map: DungeonMap, target: int) -> int:
	if map == null or map.node(target) == null:
		return 0
	var previous: Dictionary = {map.current: -1}
	var queue: Array[int] = [map.current]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		if at == target:
			break
		for next_id: int in map.node(at).next:
			if not previous.has(next_id) and not map.is_cleared(next_id):
				previous[next_id] = at
				queue.append(next_id)
	if not previous.has(target):
		return 0
	var route: Array[int] = []
	var step: int = int(previous[target])
	while step >= 0 and step != map.current:
		route.push_front(step)
		step = int(previous[step])
	var walked: int = 0
	for id: int in route:
		if map.complete(id):
			walked += 1
	return walked


# ---- Player ----------------------------------------------------------------------------------------------------------------------


## Sets the level. `silent` sets XP and the level's stats with no rewards (and can go down); otherwise the XP is added for real (level-up
## rewards, the reward track, the level-up box) and only goes up.
static func set_level(level: int, silent: bool) -> String:
	Session.ensure_game()
	var profile: PlayerProfile = Session.profile
	level = clampi(level, 1, ProgressionTable.MAX_LEVEL)
	if silent:
		profile.xp = ProgressionTable.xp_to_reach(level)
		profile.apply_level(ProgressionTable.row(level))
		EventBus.collection_changed.emit()
		Session.refresh_quests()
		Session.save_game()
		return "Level %d (silent)" % level
	if level <= profile.level:
		return "Already level %d (tick Silent to go down)" % profile.level
	var gained: Array[LevelData] = Session.add_xp(ProgressionTable.xp_to_reach(level) - profile.xp)
	Session.pending_level_ups.append_array(gained)
	return "Level %d (%d level-ups with rewards)" % [profile.level, gained.size()]


static func add_gold(amount: int) -> String:
	Session.ensure_game()
	Session.add_gold(amount)
	Session.save_game()
	return "+%d gold (%d)" % [amount, Session.gold]


## `pack_id` "" = one of every pack.
static func add_packs(pack_id: String, amount: int) -> String:
	Session.ensure_game()
	if pack_id.is_empty():
		Session.grant_dev_packs(amount)
		return "+%d of every pack" % amount
	if not Session.add_pack(pack_id, amount):
		return "Unknown pack %s" % pack_id
	return "+%d %s" % [amount, Session.pack_label(pack_id)]


## Cards whose name or id contains `query` (case-insensitive), tokens left out, at most `limit`.
static func find_cards(query: String, limit: int = 40) -> Array[CardData]:
	var result: Array[CardData] = []
	var needle: String = query.strip_edges().to_lower()
	for card: CardData in Session.content.cards.values():
		if card.is_token:
			continue
		if needle.is_empty() or card.display_name.to_lower().contains(needle) or card.id.to_lower().contains(needle):
			result.append(card)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name < b.display_name)
	return result.slice(0, limit)


static func add_card(card_id: String, ignore_caps: bool) -> String:
	Session.ensure_game()
	var card: CardData = Session.card_by_id(card_id)
	if card == null:
		return "Unknown card %s" % card_id
	if not ignore_caps and Session.at_copy_cap(card):
		return "%s is at its copy cap (%d) - tick Ignore caps" % [card.display_name, Session.copy_cap(card)]
	if ignore_caps:
		Session.profile.owned_cards.append(card)  # past the cap on purpose: no essence conversion
		EventBus.collection_changed.emit()
		Session.refresh_quests()
	else:
		Session.add_cards([card] as Array[CardData])
	Session.save_game()
	return "+1 %s (own %d)" % [card.display_name, Session.profile.owned_copies(card.id)]


static func equipment_choices() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = GearCatalog.all_pieces(Session.content)
	result.sort_custom(func(a: EquipmentData, b: EquipmentData) -> bool: return a.source_name < b.source_name)
	return result


static func add_equipment(piece_id: String) -> String:
	Session.ensure_game()
	var piece: EquipmentData = Session.content.equipment_piece(piece_id)
	if piece == null:
		return "Unknown equipment %s" % piece_id
	if not Session.grant_equipment(piece):
		return "%s is already owned" % piece.source_name
	Session.save_game()
	return "+ %s" % piece.source_name


static func add_item(item_id: String) -> String:
	Session.ensure_game()
	var item: ItemData = Session.content.item(item_id)
	if item == null:
		return "Unknown item %s" % item_id
	Session.add_item(item)
	Session.save_game()
	return "+ %s" % item.display_name


static func unlock_deck_slots() -> String:
	Session.ensure_game()
	Session.set_flag(DEV_DECK_SLOTS)
	Session.save_game()
	return "All %d deck slots open" % DeckSlots.SLOT_COUNT


const DEV_DECK_SLOTS: StringName = &"dev_all_deck_slots"


## Full heal: the open battle's hero, else the dungeon run or zone visit (the town is always full HP).
static func full_heal(battle: BattleScreen = null) -> String:
	if battle != null and battle.game != null:
		var me: PlayerState = battle.game.players[0]
		me.hp = me.max_hp
		battle.dev_refresh()
		return "Healed to %d HP (battle)" % me.hp
	var hp_run: DungeonRun = Session.hp_run() if Session.has_profile() else null
	if hp_run == null:
		return "Full HP already (the town heals)"
	hp_run.hp = hp_run.max_hp()
	EventBus.zone_hp_changed.emit(hp_run.hp, hp_run.max_hp())
	return "Healed to %d HP" % hp_run.hp


static func set_hp(value: int, battle: BattleScreen = null) -> String:
	if battle != null and battle.game != null:
		var me: PlayerState = battle.game.players[0]
		me.hp = clampi(value, 1, maxi(me.max_hp, value))
		battle.dev_refresh()
		return "HP %d (battle)" % me.hp
	var hp_run: DungeonRun = Session.hp_run() if Session.has_profile() else null
	if hp_run == null:
		return "No HP pool here (the town is always full HP)"
	hp_run.hp = clampi(value, 1, hp_run.max_hp())
	EventBus.zone_hp_changed.emit(hp_run.hp, hp_run.max_hp())
	return "HP %d / %d" % [hp_run.hp, hp_run.max_hp()]


# ---- Progress --------------------------------------------------------------------------------------------------------------------


static func set_gatekeeper(zone_id: String, beaten: bool) -> String:
	Session.ensure_game()
	Session.set_flag(CorruptedNpcs.unlock_flag(zone_id), beaten)
	Session.refresh_quests()
	Session.save_game()
	return "%s gatekeeper: %s" % [ZoneDefs.get_def(zone_id).display_name, "beaten" if beaten else "not beaten"]


## Zone freed = its main dungeon's boss beaten (the game keeps one flag for both). On: `Session.complete_zone` (the real path: freed story,
## the Arena / Alchemist unlocks, quests). Off: the flag goes and the zone's story is corrupted again.
static func set_zone_freed(zone_id: String, freed: bool) -> String:
	Session.ensure_game()
	if freed:
		Session.complete_zone(zone_id)
	else:
		Session.flags.erase(str(ZoneCompletion.flag_name(zone_id)))
		Session._sync_freed_stories()
		Session.sync_path_limit()
		Session.refresh_quests()
		Session.save_game()
	return "%s: %s" % [ZoneDefs.get_def(zone_id).display_name, "freed (boss beaten)" if freed else "corrupted again"]


static func set_primm_defeated(defeated: bool) -> String:
	Session.ensure_game()
	if defeated:
		Session.unlock_postgame()
		return "Primm defeated: postgame open"
	Session.set_flag(&"primm_defeated", false)
	Session.profile.postgame_unlocked = false
	Session.refresh_quests()
	Session.save_game()
	return "Primm not defeated (postgame closed)"


## Every quest id -> "Title (id)", for the quest picker.
static func quest_choices() -> Dictionary:
	var result: Dictionary = {}
	for quest: QuestData in QuestCatalog.all():
		result[quest.id] = "%s (%s)" % [quest.title, quest.id]
	return result


## Puts quest `quest_id` at step `step` (0-based; `objectives.size()` = every step done): the quest becomes active if it is not, steps
## before `step` have their conditions met (flags set, counters raised, required quests filed as done) and later ones are un-met. A quest
## with no turn-in then completes by itself through the real quest system (and pays its reward).
static func set_quest_step(quest_id: String, step: int) -> String:
	Session.ensure_game()
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null:
		return "Unknown quest %s" % quest_id
	var qlog: QuestLog = Session.quest_log
	step = clampi(step, 0, quest.objectives.size())
	if qlog.is_completed(quest_id):
		qlog.completed.erase(quest_id)
	if not qlog.is_active(quest_id):
		qlog.active.append(quest_id)
		for objective: QuestObjective in quest.objectives:
			if objective.condition != null and objective.condition.kind == Condition.Kind.COUNTER:
				qlog.baselines["%s|%s" % [quest_id, objective.condition.key]] = Session.counter(objective.condition.key)
	for index: int in range(quest.objectives.size()):
		var objective: QuestObjective = quest.objectives[index]
		if index < step:
			_satisfy(quest_id, objective.condition)
			if objective.milestone != null:
				# The step is set by hand: its milestone counts as paid so the menu never hands out a quest line's packs or gear.
				if not qlog.milestone_paid(quest_id, index):
					qlog.milestones_paid.append("%s#%d" % [quest_id, index])
		else:
			_unsatisfy(quest_id, objective.condition)
			qlog.milestones_paid.erase("%s#%d" % [quest_id, index])
	qlog.track(quest_id)
	qlog.progress_seen[quest_id] = qlog.progress_value(quest, Session.unlock_state())
	Session.refresh_quests()
	Session.save_game()
	var where: String = "every step done" if step >= quest.objectives.size() else "step %d of %d" % [step + 1, quest.objectives.size()]
	return "%s: %s%s" % [quest.title, where, " (completed)" if qlog.is_completed(quest_id) else ""]


static func _satisfy(quest_id: String, condition: Condition) -> void:
	if condition == null:
		return
	match condition.kind:
		Condition.Kind.FLAG_SET:
			Session.flags[condition.key] = true
		Condition.Kind.COUNTER:
			var base: int = int(Session.quest_log.baselines.get("%s|%s" % [quest_id, condition.key], 0))
			Session.counters[condition.key] = maxi(Session.counter(condition.key), base + condition.amount)
		Condition.Kind.QUEST_COMPLETED:
			if not Session.quest_log.is_completed(condition.key):
				Session.quest_log.active.erase(condition.key)
				Session.quest_log.completed.append(condition.key)
		Condition.Kind.SECRET_FOUND:
			if not Session.found_secrets.has(condition.key):
				Session.found_secrets.append(condition.key)
		Condition.Kind.ALL_OF:
			for sub: Condition in condition.sub_conditions:
				_satisfy(quest_id, sub)
		Condition.Kind.ANY_OF:
			if not condition.sub_conditions.is_empty():
				_satisfy(quest_id, condition.sub_conditions[0])
		Condition.Kind.ZONES_COMPLETED:
			for zone_id: String in ZoneDefs.ids().slice(0, condition.amount):
				Session.flags[str(ZoneCompletion.flag_name(zone_id))] = true
		_:
			pass  # a level, gold spent, a card owned: left to the player (Player tab)


static func _unsatisfy(quest_id: String, condition: Condition) -> void:
	if condition == null:
		return
	match condition.kind:
		Condition.Kind.FLAG_SET:
			Session.flags.erase(condition.key)
		Condition.Kind.COUNTER:
			Session.counters[condition.key] = int(Session.quest_log.baselines.get("%s|%s" % [quest_id, condition.key], 0))
		Condition.Kind.QUEST_COMPLETED:
			Session.quest_log.completed.erase(condition.key)
		Condition.Kind.SECRET_FOUND:
			Session.found_secrets.erase(condition.key)
		Condition.Kind.ALL_OF, Condition.Kind.ANY_OF:
			for sub: Condition in condition.sub_conditions:
				_unsatisfy(quest_id, sub)
		_:
			pass


## The area the current scene is (a zone id, "town" or "start"), "" in a battle, a dungeon or a menu.
static func current_area(scene: Node) -> String:
	if scene is TownScene:
		return "town"
	if scene is StartingAreaScene:
		return "start"
	if scene is ZoneScene:
		return (scene as ZoneScene).def.id
	return ""


## Reveals the whole map of the current area (fog of war and the minimap).
static func reveal_map(scene: Node) -> String:
	var minimap: MinimapHud = scene.get("minimap") as MinimapHud if scene != null and "minimap" in scene else null
	if minimap == null:
		return "No map here"
	minimap.reveal_all_for_screenshot()
	Session.save_game()
	return "Map revealed: %s" % current_area(scene)


## Opens every hidden chest of the current area for real (secret found, the chest's rewards paid, the lid opened).
static func open_all_chests(scene: Node) -> String:
	var opened: int = 0
	if scene is ZoneScene:
		var zone: ZoneScene = scene as ZoneScene
		for id: Variant in zone.builder.chest_positions().keys():
			var secret: String = "%s%s" % [zone.def.secret_prefix, str(id)]
			if Session.found_secret(secret):
				continue
			Session.discover_secret(secret)
			var reward: Dictionary = ChestLoot.with_roll(zone.def.chest_rewards.get(str(id), {}) as Dictionary, zone.def.id, Session.owned_equipment_ids(), Session.rng)
			Session.grant_chest_reward(reward, "Hidden chest")
			Session.bump_counter(zone.def.counter_chests)
			ChestKit.open_animated(zone.builder.chest_nodes.get(str(id)) as Node3D)
			opened += 1
	elif scene is TownScene:
		var town: TownScene = scene as TownScene
		for id: Variant in TownScene.HIDDEN_CHEST_REWARDS.keys():
			var secret: String = TownScene._hidden_chest_secret(str(id))
			if Session.found_secret(secret):
				continue
			Session.discover_secret(secret)
			var reward: Dictionary = ChestLoot.with_roll(TownScene.HIDDEN_CHEST_REWARDS[id] as Dictionary, "town", Session.owned_equipment_ids(), Session.rng)
			Session.grant_chest_reward(reward, "Hidden chest")
			town._animate_chest_open(str(id))
			opened += 1
	else:
		return "No chests here (Crosspath or a zone)"
	Session.save_game()
	return "Opened %d chest%s" % [opened, "" if opened == 1 else "s"]


## Resets the current area: its hidden chests close again, its map fog comes back, its enemies return (a fresh visit; Crosspath's
## outskirts roamers wake up), then the scene reloads. Flags (gatekeepers, freed, quests) are left alone: the Progress tab owns those.
static func reset_area(scene: Node) -> String:
	var area: String = current_area(scene)
	if area.is_empty():
		return "Nothing to reset here"
	if scene is ZoneScene:
		var zone: ZoneScene = scene as ZoneScene
		for id: Variant in zone.builder.chest_positions().keys():
			Session.found_secrets.erase("%s%s" % [zone.def.secret_prefix, str(id)])
	elif scene is TownScene:
		for id: Variant in TownScene.HIDDEN_CHEST_REWARDS.keys():
			Session.found_secrets.erase(TownScene._hidden_chest_secret(str(id)))
		for key: Variant in Session.counters.keys():
			if str(key).begins_with("town_roamer_beaten:"):
				Session.counters.erase(key)
	Session.map_fog.erase(area)
	Session._fog_live.erase(area)
	Session.save_game()
	match area:
		"town":
			travel_town()
		"start":
			travel_forest()
		_:
			travel_zone(area)
	return "Reset %s (chests, map, enemies)" % area


# ---- Battle ----------------------------------------------------------------------------------------------------------------------


## Encounters whose id, title, enemy or group contains `query`, at most `limit`.
static func find_encounters(query: String, limit: int = 60) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	var needle: String = query.strip_edges().to_lower()
	for spec: EncounterSpec in EncounterCatalog.all(Session.content):
		var text: String = "%s %s %s %s" % [spec.id, spec.title, spec.enemy_name, spec.group]
		if needle.is_empty() or text.to_lower().contains(needle):
			result.append(spec)
		if result.size() >= limit:
			break
	return result


## Starts encounter `spec_id` (the balance sim's catalog: every roamer, elite, gatekeeper, dungeon node, boss, arena fight) with the
## player's deck (`DECK_MINE`) or a Path's starting deck (`Affinity.Type`). Winning or losing goes back to Crosspath; nothing is paid.
static func start_encounter(spec_id: String, deck_choice: int = DECK_MINE) -> String:
	Session.ensure_game()
	var context: BattleContext = make_encounter_battle(spec_id, deck_choice)
	if context == null:
		return "Unknown encounter %s" % spec_id
	Session.start_battle(context)
	return "Battle: %s" % context.enemy_name


static func make_encounter_battle(spec_id: String, deck_choice: int = DECK_MINE) -> BattleContext:
	var content: ContentSet = Session.content
	var spec: EncounterSpec = EncounterCatalog.find(content, spec_id)
	if spec == null:
		return null
	var deck: Deck = Session.deck if deck_choice == DECK_MINE else CampaignStart.starter_deck(content, deck_choice as Affinity.Type)
	if not spec.player_recipe.is_empty():
		deck = ZoneDecks.from_recipe(content, "Arena kit", spec.player_recipe)
	var sources: Array[ModifierSource] = []
	var shared: ModifierSource = spec.shared_source()
	if shared != null:
		sources.append(shared)
	var player_rules: ModifierSource = spec.player_rules_source()
	if player_rules != null:
		sources.append(player_rules)
	sources.append_array(spec.player_sources)
	var setup: PlayerSetup = PlayerSetup.create(deck, Session.profile, sources, "You")
	if spec.player_hp > 0:
		setup.starting_hp = spec.player_hp
	var enemy: PlayerSetup = spec.build_enemy(content, deck)
	if shared != null:
		enemy.modifiers.add_source(shared)
	var options: GameOptions = GameOptions.new()
	options.first_player = spec.first_player
	options.rng_seed = Session.rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	game.add_player(setup)
	game.add_player(enemy)
	game.start()
	for token_id: String in spec.ally_token_ids:
		var data: CardData = TokenRegistry.data(token_id)
		if data != null:
			game.create_token(0, data).summoning_sick = false
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(ZoneDecks.personality(content, spec.enemy_ai_name))
	context.enemy_name = spec.enemy_name
	context.is_boss = spec.kind == EncounterSpec.Kind.BOSS
	context.dev_battle = true
	return context


## In a battle: ends it now as a win or a loss (the real result panel and the real completion follow).
static func end_battle(battle: BattleScreen, won: bool) -> String:
	if battle == null:
		return "Not in a battle"
	battle.dev_end(won)
	return "Battle: %s now" % ("win" if won else "lose")


static func draw_cards(battle: BattleScreen, count: int) -> String:
	if battle == null:
		return "Not in a battle"
	battle.game.draw_cards(0, count)
	battle.dev_refresh()
	return "Drew %d" % count


## One energy of any Path for this turn (it empties at the end of the turn, like all floating energy).
static func add_energy(battle: BattleScreen, amount: int = 1) -> String:
	if battle == null:
		return "Not in a battle"
	for _i: int in range(amount):
		battle.game.players[0].pool.append(PlayerState.POOL_ANY)
	battle.dev_refresh()
	return "+%d energy (this turn)" % amount


static func add_resource(battle: BattleScreen, kind: ResourceKind.Kind, amount: int = 1) -> String:
	if battle == null:
		return "Not in a battle"
	ResourceRules.create(battle.game, 0, kind, amount)
	battle.dev_refresh()
	return "+%d %s" % [amount, ResourceKind.Kind.keys()[kind].capitalize()]


static func reveal_enemy_hand(battle: BattleScreen) -> String:
	if battle == null:
		return "Not in a battle"
	var me: PlayerState = battle.game.players[0]
	if not me.modifiers.has(Modifier.Kind.REVEAL_OPPONENT_HAND):
		me.modifiers.add_source(CardBuilder.modifier_source("Dev Menu", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.REVEAL_OPPONENT_HAND, 1)] as Array[Modifier]))
	battle.dev_refresh()
	return "Enemy hand shown"


# ---- Saves -----------------------------------------------------------------------------------------------------------------------


static func snapshot_path(snapshot_name: String) -> String:
	var safe: String = snapshot_name.strip_edges().to_lower().replace(" ", "_").validate_filename()
	return SNAPSHOT_DIR + (safe if not safe.is_empty() else "snapshot") + ".json"


## Saves the whole game as a named snapshot (separate from the five save slots).
static func save_snapshot(snapshot_name: String) -> String:
	if not Session.has_profile():
		return "Nothing to save yet"
	DirAccess.make_dir_recursive_absolute(SNAPSHOT_DIR)
	var data: Dictionary = Session.to_dict()
	data["meta"] = Session.slot_meta(snapshot_name)
	if not SaveSystem.write(data, snapshot_path(snapshot_name)):
		return "Could not save %s" % snapshot_name
	return "Snapshot saved: %s" % snapshot_name


## Snapshot names on disk, newest first.
static func snapshots() -> Array[String]:
	var result: Array[String] = []
	var dir: DirAccess = DirAccess.open(SNAPSHOT_DIR)
	if dir == null:
		return result
	var stamped: Array[Array] = []
	for file: String in dir.get_files():
		if file.ends_with(".json"):
			stamped.append([FileAccess.get_modified_time(SNAPSHOT_DIR + file), file.trim_suffix(".json")])
	stamped.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
	for row: Array in stamped:
		result.append(str(row[1]))
	return result


## Loads a snapshot and resumes it where it was saved (the same path as loading a save slot).
static func load_snapshot(snapshot_name: String) -> String:
	var data: Dictionary = SaveSystem.read(snapshot_path(snapshot_name))
	if data.is_empty() or not Session.from_dict(data):
		return "Could not load %s" % snapshot_name
	var meta: Dictionary = data.get("meta", {}) as Dictionary
	Session.pending_resume_scene = str(meta.get("scene", "town"))
	Session.resume_loaded_game()
	return "Snapshot loaded: %s" % snapshot_name


static func delete_snapshot(snapshot_name: String) -> String:
	DirAccess.remove_absolute(snapshot_path(snapshot_name))
	return "Snapshot deleted: %s" % snapshot_name
