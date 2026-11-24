extends RefCounted
## The draft smoke: whole drafts, automated and headless, through the Session's own functions, with real fights played to the end
## by two AIs on the draft's stand-in profile.
##   Phase 1: a zone draft and run in each of the four zones (picks, one reroll, a save and a reload in the middle, the deck,
##            the rivals, the rewards, the kept card).
##   Fable big pass Nov 23 (Part 9.2): the Shuffle House opens both ways (four zone drafts won; three zones freed) and the main
##            quest follows; an Open Draft at an arena table; the Shuffled Halls walked room by room (fights, the pick after
##            each, the Trade Counter, the Kettle, the buff rooms, Trey, Octavia); a Mystery Mini; a zone dungeon as a draft.
##   Fable Nov 24 (Part 7): the four modes. A Classic Draft with two Paths (three opponents from the arena's cast, no Prismatic
##            Pack) and a High Rollers Draft (the fee, the opponents' equipment); the Shuffled Halls with their hand-made dealers
##            on a careful and a greedy route, and a run that cashes out at the Counting Halls; a Mystery Mini; a zone dungeon;
##            and one run through each other large dungeon of the Dungeon Draft's list (Primm's Castle, the Path-ology Lab, the
##            Shattered Gallery, Mount Swolympus).
##   Godot --headless --path . -s res://tools/draft_smoke.gd [-- --only=zones|house|high|halls|cashout|mystery|dungeon|large] [--tries=N]
##   (bash tools/run_draft_smoke.sh)

var checks: int = 0
var failed: int = 0
var only: String = ""
var tries: int = 3
## Runs cleared and runs made, by label (the Halls' clear rates).
var cleared_runs: Dictionary = {}
var made_runs: Dictionary = {}


func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("draft_smoke: FAILED - %s" % what)


func run() -> bool:
	for raw: String in OS.get_cmdline_user_args():
		if raw.begins_with("--only="):
			only = raw.trim_prefix("--only=")
		if raw.begins_with("--tries="):
			tries = int(raw.trim_prefix("--tries="))
	Session.save_enabled = false
	if _wanted("zones"):
		for zone_id: String in DraftChallenges.ZONES:
			_zone(zone_id)
	if _wanted("house"):
		_house_opens_by_zone_drafts()
		_house_opens_by_freed_zones()
		_arena_table()
	if _wanted("high"):
		_high_rollers()
	if _wanted("halls"):
		# the Halls by two kinds of player: a careful one (the heal and the buff rooms, as few tables as the map allows) and a
		# greedy one (every table and champion on the way, for the picks); --tries=N runs of each
		_dungeon_run("halls careful", DraftArena.HALLS_ID, [int(Affinity.Type.BEEFCAKE), int(Affinity.Type.NECROCRAT)] as Array[int], tries, false, false)
		_dungeon_run("halls greedy", DraftArena.HALLS_ID, [int(Affinity.Type.GOURMAND), int(Affinity.Type.REFUSEMANCER)] as Array[int], tries, true, false)
	if _wanted("cashout"):
		# a run that walks to the Counting Halls and cashes out: part of the prize, not a win
		_dungeon_run("halls cash out", DraftArena.HALLS_ID, [int(Affinity.Type.BEEFCAKE)] as Array[int], tries, false, true, 18)
	if _wanted("mystery"):
		_dungeon_run("mystery", DraftArena.MYSTERY_ID, [int(Affinity.Type.GOURMAND)] as Array[int], 3)
	if _wanted("dungeon"):
		_dungeon_run("dungeon", "", [int(Affinity.Type.REFUSEMANCER)] as Array[int], 3)
	if _wanted("large"):
		# every other large dungeon of the Dungeon Draft's list, once each: the run must hold together from the door to the end
		for key: String in [CapitalZone.ID, "D-LAB", "S-GALLERY", "S-BEEF"]:
			_dungeon_run("large %s" % key, DraftArena.dungeon_id(key), [int(Affinity.Type.BEEFCAKE), int(Affinity.Type.GOURMAND)] as Array[int], 1)
	print("draft_smoke: %s - %d checks, %d failed" % ["OK" if failed == 0 else "FAILED", checks, failed])
	return failed == 0


func _wanted(part: String) -> bool:
	return only.is_empty() or only == part


func _fresh(level: int = 12) -> void:
	Session.new_game()
	Session.ensure_game()
	DevActions.set_level(level, true)
	Session.gold = 300


func _pick_all(label: String) -> void:
	var guard: int = 0
	while Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and guard < 120:
		guard += 1
		Session.draft_pick(guard % 3)
	check(Session.draft != null and Session.draft.phase != DraftState.PHASE_PICK, "%s: every pick made" % label)


# ---- Phase 1: the four zone drafts ---------------------------------------------------------------------------------------------------


func _zone(zone_id: String) -> void:
	_fresh()
	var id: String = DraftChallenges.zone_id_for(zone_id)
	var real: PlayerProfile = Session.profile
	var worn: int = real.equipment.size()
	var gold: int = Session.gold
	check(Session.draft_fee(id) == 0, "%s: entry is free" % zone_id)
	check(Session.start_draft(id, [] as Array[int]), "%s: the draft starts" % zone_id)
	check(Session.gold == gold, "%s: no gold taken at the table" % zone_id)
	var guard: int = 0
	var rerolled: bool = false
	var reloaded: bool = false
	while Session.draft != null and Session.draft.phase == DraftState.PHASE_PICK and guard < 100:
		guard += 1
		check((Session.draft.offer["options"] as Array).size() == 3, "%s: three options at step %d" % [zone_id, Session.draft.step])
		if guard == 6 and not rerolled:
			rerolled = Session.draft_reroll()
			check(rerolled, "%s: the reroll" % zone_id)
		if guard == 12 and not reloaded:
			reloaded = true
			var offer: Array = (Session.draft.offer["options"] as Array).duplicate()
			var data: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
			check(Session.from_dict(data), "%s: the save loads in the middle of a draft" % zone_id)
			check(Session.draft != null and (Session.draft.offer["options"] as Array) == offer, "%s: the same offer after the reload" % zone_id)
			real = Session.profile
			worn = real.equipment.size()
		Session.draft_pick(guard % 3)
	var draft: DraftState = Session.draft
	check(draft.cards.size() == DraftRules.card_picks(), "%s: %d cards picked (%d)" % [zone_id, DraftRules.card_picks(), draft.cards.size()])
	check(draft.equipment.size() == DraftRules.int_list("equipment_picks_after").size(), "%s: the equipment picks (%d)" % [zone_id, draft.equipment.size()])
	check(DraftEngine.deck_ready(draft), "%s: the default deck is ready (%d cards)" % [zone_id, DraftEngine.deck_size(draft)])
	check(Session.draft_begin_run(), "%s: the run begins" % zone_id)
	check(draft.rivals.size() == 3, "%s: three rivals" % zone_id)
	for rival: Dictionary in draft.rivals:
		check((rival.get("paths", []) as Array).size() == 1, "%s: %s drafted one Path" % [zone_id, str(rival["name"])])
	var fights: int = 0
	while not draft.is_finished() and fights < 6:
		fights += 1
		var context: BattleContext = Session.make_draft_battle()
		Session._draft_real_profile = Session.profile
		Session.profile = context.draft_profile
		check(context.draft_profile.equipment.size() == draft.equipment.size(), "%s fight %d: the drafted equipment only" % [zone_id, fights])
		_play(context)
		check(context.game.is_over(), "%s fight %d: the fight ends" % [zone_id, fights])
		var result: Dictionary = Session.resolve_draft_battle(context)
		check(Session.profile == real, "%s fight %d: the real profile is back" % [zone_id, fights])
		check(bool(result.get("over", false)) == draft.is_finished(), "%s fight %d: the result knows whether the run is over" % [zone_id, fights])
		print("draft_smoke: %s fight %d vs %s: %s (%d-%d)" % [zone_id, fights, context.enemy_name, "won" if context.won else "lost", draft.wins, draft.losses])
	check(draft.is_finished(), "%s: the run ends at 3 wins or 2 losses" % zone_id)
	check(int(draft.result.get("gold", 0)) > 0, "%s: something for every result" % zone_id)
	check(real.equipment.size() == worn, "%s: the main loadout is untouched" % zone_id)
	if draft.full_win():
		check(Session.flag(StringName(DraftChallenges.won_flag(id))), "%s: the win is recorded" % zone_id)
		check(Session.draft_keep(draft.cards[0]), "%s: one card is kept" % zone_id)
	else:
		check(not Session.draft_keep(draft.cards[0]), "%s: no card without a full win" % zone_id)
	Session.close_draft()
	check(Session.draft == null, "%s: the draft is put away" % zone_id)
	check(Session.draft_fee(id) == 0, "%s: the next attempt is free too" % zone_id)


# ---- the Shuffle House ------------------------------------------------------------------------------------------------------------------


func _house_opens_by_zone_drafts() -> void:
	_fresh()
	check(not DraftArena.is_open(Session.flags), "house: closed in a new game")
	for zone_id: String in DraftChallenges.ZONES:
		check(Session.start_draft(DraftChallenges.zone_id_for(zone_id), [] as Array[int]), "house: the %s table" % zone_id)
		_pick_all("house %s" % zone_id)
		check(Session.draft_begin_run(), "house: the %s run" % zone_id)
		for win: int in range(DraftChallenges.wins_to_finish(Session.draft.challenge_id)):
			DraftRun.record(Session.draft, true)
		Session._pay_draft_rewards()
		Session.close_draft()
	check(DraftArena.is_open(Session.flags), "house: four zone drafts won open it")
	Session.open_shuffle_house_if_due()
	check(Session.flag(StringName(DraftChallenges.ARENA_FLAG)), "house: the opening is recorded")
	print("draft_smoke: house opened by four zone drafts")


func _house_opens_by_freed_zones() -> void:
	_fresh(16)
	var freed: int = 0
	for zone_id: String in ZoneDefs.ids():
		if freed >= DraftArena.ZONES_TO_OPEN:
			break
		check(not DraftArena.is_open(Session.flags), "house: still closed with %d zones freed" % freed)
		Session.complete_zone(zone_id)
		freed += 1
	check(DraftArena.is_open(Session.flags), "house: three freed zones open it")
	Session.refresh_quests()
	var main: QuestData = QuestCatalog.find(DraftArenaQuests.MAIN_QUEST)
	check(main != null, "house: the main quest exists")
	check(main != null and (Session.quest_log.is_active(main.id) or Session.quest_log.is_completed(main.id)), "house: The House Always Deals starts with three zones freed")
	check(DraftArena.max_paths(Session.flags) == 2, "house: two-Path drafts with a zone freed, three and four wait for Primm")
	print("draft_smoke: house opened by three freed zones; main quest active: %s" % str(main != null and Session.quest_log.is_active(main.id)))


func _arena_table() -> void:
	var paths: Array[int] = [int(Affinity.Type.BEEFCAKE), int(Affinity.Type.GOURMAND)] as Array[int]
	check(Session.draft_start_problem(DraftArena.CLASSIC_ID, paths).is_empty(), "arena: a Classic Draft takes two Paths (%s)" % Session.draft_start_problem(DraftArena.CLASSIC_ID, paths))
	check(not Session.draft_start_problem(DraftArena.pair_ids()[0], paths).is_empty(), "arena: the separate two-Path tables are gone")
	check(Session.draft_fee(DraftArena.CLASSIC_ID) == 0, "arena: Classic is free")
	check(Session.start_draft(DraftArena.CLASSIC_ID, paths), "arena: the Classic Draft starts")
	_pick_all("arena classic")
	check(Session.draft_begin_run(), "arena: the run begins")
	var draft: DraftState = Session.draft
	_check_opponents("arena", draft, int(EquipmentData.Rarity.UNCOMMON))
	var fights: int = 0
	while not draft.is_finished() and fights < 6:
		fights += 1
		var context: BattleContext = Session.make_draft_battle()
		Session._draft_real_profile = Session.profile
		Session.profile = context.draft_profile
		check(context.board_key == "draft", "arena fight %d: on the house table" % fights)
		_play(context)
		Session.resolve_draft_battle(context)
		print("draft_smoke: arena fight %d vs %s: %s (%d-%d)" % [fights, context.enemy_name, "won" if context.won else "lost", draft.wins, draft.losses])
	check(draft.is_finished(), "arena: the run ends")
	check(int(draft.result.get("gold", 0)) > 0, "arena: something for every result")
	check(not (draft.result.get("packs", []) as Array).has(PackRules.PRISMATIC_ID), "arena: Classic pays no Prismatic Pack")
	if draft.full_win():
		check(Session.flag(StringName(DraftArena.paths_goal_flag(draft.paths))), "arena: a Classic win with two Paths counts for that pair")
	Session.close_draft()


## Three different opponents from the arena's cast, each with a description, Paths of their own (never more than the story has
## opened) and equipment no rarer than `cap`.
func _check_opponents(label: String, draft: DraftState, cap: int) -> void:
	var names: Dictionary = {}
	for rival: Dictionary in draft.rivals:
		names[str(rival["name"])] = true
		check(not DraftRivals.portrait_id(str(rival["name"])).is_empty(), "%s: %s is one of the cast" % [label, str(rival["name"])])
		check(not str(rival.get("title", "")).is_empty(), "%s: %s has a description for the next-opponent screen" % [label, str(rival["name"])])
		check((rival.get("paths", []) as Array).size() >= 1 and (rival.get("paths", []) as Array).size() <= maxi(1, DraftArena.max_paths(Session.flags)), "%s: %s drafted Paths of their own (%s)" % [label, str(rival["name"]), str(rival.get("paths", []))])
		for piece_id: Variant in rival.get("equipment", []) as Array:
			check(int(Session.content.equipment_piece(str(piece_id)).rarity) <= cap, "%s: %s wears nothing above the cap (%s)" % [label, str(rival["name"]), str(piece_id)])
	check(names.size() == 3, "%s: three different opponents (%s)" % [label, ", ".join(names.keys())])
	print("draft_smoke: %s opponents: %s" % [label, ", ".join(names.keys())])


## A High Rollers Draft: the fee at the door, opponents who may wear anything, and more gold than Classic for the same result.
func _high_rollers() -> void:
	_fresh(16)
	for zone_id: String in ZoneDefs.ids().slice(0, DraftArena.ZONES_TO_OPEN):
		Session.complete_zone(zone_id)
	Session.open_shuffle_house_if_due()
	var paths: Array[int] = [int(Affinity.Type.NECROCRAT), int(Affinity.Type.REFUSEMANCER)] as Array[int]
	var fee: int = Session.draft_fee(DraftArena.HIGH_ID)
	check(fee > 0, "high: there is an entry fee (%d)" % fee)
	Session.gold = fee - 1
	check(not Session.draft_start_problem(DraftArena.HIGH_ID, paths).is_empty(), "high: no seat without the fee")
	Session.gold = fee + 50
	check(Session.start_draft(DraftArena.HIGH_ID, paths), "high: the draft starts")
	check(Session.gold == 50, "high: the fee is paid at the door")
	_pick_all("high")
	check(Session.draft_begin_run(), "high: the run begins")
	var draft: DraftState = Session.draft
	_check_opponents("high", draft, int(EquipmentData.Rarity.LEGENDARY))
	var fights: int = 0
	while not draft.is_finished() and fights < 6:
		fights += 1
		var context: BattleContext = Session.make_draft_battle()
		Session._draft_real_profile = Session.profile
		Session.profile = context.draft_profile
		_play(context)
		Session.resolve_draft_battle(context)
		print("draft_smoke: high fight %d vs %s: %s (%d-%d)" % [fights, context.enemy_name, "won" if context.won else "lost", draft.wins, draft.losses])
	check(draft.is_finished(), "high: the run ends at three wins or two losses")
	check(draft.losses <= 2, "high: two losses end it, like Classic")
	var classic: Dictionary = DraftChallenges.reward(draft.wins, draft.full_win(), false, DraftArena.CLASSIC_ID, paths, false)
	check(int(draft.result.get("gold", 0)) > int(classic["gold"]), "high: more gold than Classic for the same result (%d against %d)" % [int(draft.result.get("gold", 0)), int(classic["gold"])])
	Session.close_draft()


# ---- dungeon drafts: the Shuffled Halls, a Mystery Mini, a zone dungeon ------------------------------------------------------------------


## A dungeon draft walked room by room, up to `tries` attempts until one is cleared. `challenge` "" = the first zone dungeon on offer.
## `cash_out_room` > 0: the run heads for that room (the Counting Halls) and cashes out there.
func _dungeon_run(label: String, challenge: String, paths: Array[int], attempts: int, greedy: bool = true, stop_at_clear: bool = true, cash_out_room: int = 0) -> void:
	_fresh(20 if label.begins_with("large") else 16)
	for zone_id: String in ZoneDefs.ids().slice(0, DraftArena.ZONES_TO_OPEN):
		Session.complete_zone(zone_id)
	if label.begins_with("large"):
		# the whole story behind the player: every zone and the Capital freed, every side and postgame dungeon cleared once
		for zone_id: String in ZoneDefs.ids():
			Session.complete_zone(zone_id)
		Session.complete_zone(CapitalZone.ID)
		for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
			if plan.is_side() or plan.is_postgame():
				Session.set_flag(Session.side_cleared_flag(plan))
		check(Session.draft_dungeon_keys().has(DraftArena.dungeon_key_of(challenge)), "%s: on the Dungeon Draft's list once cleared" % label)
	if challenge == DraftArena.MYSTERY_ID:
		# the wheel lands on a mini dungeon already cleared with the player's own deck
		for plan: DungeonCatalog.Blueprint in DungeonCatalog.all():
			if plan.is_side():
				Session.set_flag(Session.side_cleared_flag(plan))
				break
		check(not Session.draft_mystery_pool().is_empty(), "mystery: a cleared mini dungeon is in the wheel")
	Session.open_shuffle_house_if_due()
	var real: PlayerProfile = Session.profile
	var id: String = challenge
	if id.is_empty():
		var keys: Array[String] = Session.draft_dungeon_keys()
		check(not keys.is_empty(), "%s: a cleared dungeon is on offer as a draft" % label)
		if keys.is_empty():
			return
		id = DraftArena.dungeon_id(keys[0])
	var cleared: bool = false
	made_runs[label] = 0
	cleared_runs[label] = 0
	for attempt: int in range(1, attempts + 1):
		cleared = false
		made_runs[label] = int(made_runs[label]) + 1
		check(Session.draft_start_problem(id, paths).is_empty(), "%s: may start (%s)" % [label, Session.draft_start_problem(id, paths)])
		if not Session.start_draft(id, paths):
			check(false, "%s: the draft starts" % label)
			return
		_pick_all(label)
		check(Session.draft_begin_run(), "%s: the deck is locked" % label)
		check(Session.draft.is_dungeon(), "%s: a dungeon draft" % label)
		check(Session.prepare_draft_dungeon(), "%s: into the dungeon (%s)" % [label, Session.draft.dungeon_key])
		var key: String = Session.dungeon_key
		var hp_start: int = Session.run.hp
		var rooms: int = 0
		var fights: int = 0
		var over: bool = false
		while not over and rooms < 40 and Session.dungeon_map != null:
			var choices: Array[DungeonMap.MapNode] = Session.dungeon_map.available()
			if choices.is_empty():
				break
			var node: DungeonMap.MapNode = _choose(choices, greedy, Session.run.hp < Session.run.max_hp() * 0.7)
			if cash_out_room > 0:
				node = _toward(choices, cash_out_room, node)
			if label.begins_with("halls") and attempt == 1 and rooms == 0:
				check(Session.draft.rivals.is_empty(), "%s: the dealers are the dungeon's own, not drafted" % label)
			rooms += 1
			match node.kind:
				DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE, DungeonMap.Kind.BOSS:
					fights += 1
					var context: BattleContext = Session.make_dungeon_battle(node)
					check(context.draft, "%s room %d: a draft fight" % [label, node.number])
					_play(context)
					var hp_before: int = Session.run.hp
					var result: Dictionary = Session.resolve_draft_dungeon_battle(context)
					print("draft_smoke: %s try %d room %d (%s) vs %s: %s, HP %d -> %s" % [label, attempt, node.number, node.title, context.enemy_name, "won" if bool(result["won"]) else "LOST", hp_before, str(Session.run.hp) if Session.run != null else "-"])
					over = bool(result["over"])
					cleared = bool(result.get("cleared", false))
					if not over:
						check(str(Session.draft.offer.get("kind", "")) == DraftEngine.KIND_DUNGEON_PICK, "%s room %d: three cards on the table after the fight" % [label, node.number])
						# pass, add, swap in turn
						var how: int = fights % 3
						check(Session.draft_dungeon_pick(-1 if how == 0 else 0, _a_deck_card() if how == 2 else -1), "%s room %d: the pick (%s)" % [label, node.number, ["pass", "add", "swap"][how]])
				DungeonMap.Kind.EVENT, DungeonMap.Kind.RESCUE:
					var event: DungeonEvent = MainDungeons.def(key).event(node.event_id)
					if event != null:
						# the Counting Halls: the first choice cashes out (only the run that came for it takes it)
						var cashier: bool = key == DraftArena.HALLS_DUNGEON and node.number == 18
						var outcome: EventResolver.Result = Session.resolve_dungeon_event(event, 1 if cashier and cash_out_room != node.number else 0)
						if not outcome.ok:
							outcome = Session.resolve_dungeon_event(event, event.choices.size() - 1)
						if cashier:
							check(Session.draft_cash_out_pending == (cash_out_room == node.number), "%s: the cashier pays out only when asked" % label)
						if Session.draft_cash_out_pending:
							var gold_before: int = Session.gold
							var cash: Dictionary = Session.resolve_draft_dungeon(false, true)
							check(bool(cash.get("cashed_out", false)) and Session.gold > gold_before, "%s: cashing out pays part of the prize (%s)" % [label, str(cash).substr(0, 160)])
							check(not Session.draft.full_win() and not Session.flag(StringName(DraftChallenges.won_flag(DraftArena.HALLS_ID))), "%s: cashing out is not a win" % label)
							check(not Session.draft_keep(Session.draft.cards[0]), "%s: no card to keep after a cash-out" % label)
							print("draft_smoke: %s try %d room %d: cashed out with %s" % [label, attempt, node.number, str(cash).substr(0, 200)])
							over = true
							break
						check(outcome.ok, "%s room %d: the event resolves (%s)" % [label, node.number, outcome.reason])
						var kind: String = str(Session.draft.offer.get("kind", ""))
						if kind == DraftEngine.KIND_DUNGEON_TRADE:
							check(Session.draft_dungeon_pick(0, _a_deck_card()), "%s room %d: a card traded at the counter" % [label, node.number])
						elif kind == DraftEngine.KIND_DUNGEON_PICK:
							check(Session.draft_dungeon_pick(0, -1), "%s room %d: the vault's card taken" % [label, node.number])
					Session.dungeon_map.complete(node.id)
				DungeonMap.Kind.TREASURE:
					var gold_before: int = Session.gold
					Session.apply_treasure(node)
					check(Session.gold >= gold_before, "%s room %d: the treasure pays" % [label, node.number])
					Session.dungeon_map.complete(node.id)
				_:
					Session.dungeon_map.complete(node.id)
		if not over and Session.draft_dungeon_active:
			# a guard stop, or a dungeon that ends without a boss fight: leave it
			Session.resolve_draft_dungeon(false)
		check(not Session.draft_dungeon_active, "%s: out of the dungeon" % label)
		check(Session.profile == real, "%s: the real hero is back" % label)
		var pay: Dictionary = Session.draft.result if Session.draft != null else {}
		print("draft_smoke: %s try %d: %s after %d rooms and %d fights (HP at the door %d); paid %s" % [label, attempt, "CLEARED" if cleared else "not cleared", rooms, fights, hp_start, str(pay).substr(0, 220)])
		check(not pay.is_empty(), "%s: the run is paid" % label)
		if cleared:
			check(Session.draft.full_win(), "%s: a clear is a full win" % label)
			check(Session.draft_keep(Session.draft.cards[0]), "%s: one card kept" % label)
		Session.close_draft()
		if cleared:
			cleared_runs[label] = int(cleared_runs[label]) + 1
			if stop_at_clear:
				break
	if challenge == DraftArena.HALLS_ID:
		check(Session.counter("draft_halls_played") >= 1, "halls: playing counts for the main quest")
		Session.refresh_quests()
		var main: QuestData = QuestCatalog.find(DraftArenaQuests.MAIN_QUEST)
		print("draft_smoke: halls main quest ready or done: %s" % str(main != null and (Session.quest_log.is_completed(main.id) or Session.quest_log.is_ready_to_turn_in(main, Session.unlock_state()))))
	print("draft_smoke: %s: %d of %d runs cleared" % [label, int(cleared_runs[label]), int(made_runs[label])])


## The way through. The boss when it is on offer. A greedy player takes every champion and table (for the picks) unless hurt,
## when an event room (a heal, a buff) comes first; a careful player takes the event rooms and the treasure, and fights only
## where the map leaves no other door.
func _choose(choices: Array[DungeonMap.MapNode], greedy: bool, hurt: bool) -> DungeonMap.MapNode:
	var order: Array[int] = [DungeonMap.Kind.BOSS, DungeonMap.Kind.EVENT, DungeonMap.Kind.TREASURE, DungeonMap.Kind.BATTLE, DungeonMap.Kind.ELITE]
	if greedy and not hurt:
		order = [DungeonMap.Kind.BOSS, DungeonMap.Kind.ELITE, DungeonMap.Kind.BATTLE, DungeonMap.Kind.EVENT, DungeonMap.Kind.TREASURE]
	if not greedy:
		# a careful player reads the map: the door behind which the fewest fights stand between here and the boss
		var best: DungeonMap.MapNode = choices[0]
		var fewest: int = 999
		for node: DungeonMap.MapNode in choices:
			var fights: int = _fights_ahead(node, 0)
			if fights < fewest:
				fewest = fights
				best = node
		return best
	for wanted: int in order:
		for node: DungeonMap.MapNode in choices:
			if int(node.kind) == wanted:
				return node
	return choices[0]


## The door that leads to room `target` (that room itself when it is on offer); `fallback` when none does.
func _toward(choices: Array[DungeonMap.MapNode], target: int, fallback: DungeonMap.MapNode) -> DungeonMap.MapNode:
	var best: DungeonMap.MapNode = null
	var fewest: int = 999
	for node: DungeonMap.MapNode in choices:
		if node.number == target:
			return node
		if _leads_to(node, target, 0):
			var fights: int = _fights_ahead(node, 0)
			if fights < fewest:
				fewest = fights
				best = node
	return best if best != null else fallback


func _leads_to(node: DungeonMap.MapNode, target: int, depth: int) -> bool:
	if node == null or depth > 30:
		return false
	if node.number == target:
		return true
	for next_id: int in node.next:
		if _leads_to(Session.dungeon_map.node(next_id), target, depth + 1):
			return true
	return false


## The fewest fights from `node` (itself counted) to the boss, the boss not counted.
func _fights_ahead(node: DungeonMap.MapNode, depth: int) -> int:
	if node == null or node.kind == DungeonMap.Kind.BOSS or depth > 30:
		return 0
	var own: int = 1 if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.ELITE else 0
	var least: int = 999
	for next_id: int in node.next:
		least = mini(least, _fights_ahead(Session.dungeon_map.node(next_id), depth + 1))
	return own + (0 if least == 999 else least)


## The index (in the draft's picks) of a card that is in the deck now.
func _a_deck_card() -> int:
	for index: int in range(Session.draft.cards.size()):
		if not Session.draft.bench.has(index):
			return index
	return -1


## Plays a fight to the end: a decent player (Elite search) against the foe's own AI.
func _play(context: BattleContext) -> void:
	var game: GameState = context.game
	var player_ai: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(Session.content, "Balanced"), AIPlayer.Skill.ELITE)
	player_ai.deterministic = true
	context.ai.deterministic = true
	var ais: Array[AIPlayer] = [player_ai, context.ai]
	var steps: int = 0
	while not game.is_over() and steps < BalanceSim.MAX_STEPS_PER_GAME:
		steps += 1
		var who: int = game.awaiting_player()
		var action: GameAction = ais[who].choose_action(game)
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
