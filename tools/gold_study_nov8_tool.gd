extends "res://tools/gold_study_tool.gd"
## Overnight Nov 7-8, Part 2: the friendlier economy's study, on the same no-grind timeline as the Nov 3-4 study (`gold_study_tool.gd`): gold earned,
## what such a player buys at the new prices (about 38 cards, 7 gear pieces, normal item use, a few hats and packs), how many cards are left
## over, and an estimate of the extra play a completionist needs to own one copy of every card. Prints a markdown block to paste into
## docs/balance/gold_economy_nov3.md and writes it to --out.
##   Godot --headless --path . -s res://tools/gold_study_nov8.gd [-- --out=res://docs/design/sim/nov8/gold_study_nov8.md]

## The shopping list of a no-grind player at the new prices.
const NOV8_CARD_MIX: Dictionary = {CardEnums.Rarity.COMMON: 19, CardEnums.Rarity.UNCOMMON: 11, CardEnums.Rarity.EPIC: 6, CardEnums.Rarity.LEGENDARY: 2}
const NOV8_GEAR: Array[String] = ["cardboard_cuirass", "saucepan_helmet", "wicked_dagger", "flamethrower", "solid_plate", "protein_shaker_bandolier", "dog_eared_bookmark"]
const NOV8_ITEM_CHARGES: int = 20
const NOV8_ITEM_AVERAGE: int = 75
const NOV8_PACKS: Array[String] = ["general_1", "general_1", "path_beefcake", "path_beefcake"]
## Minutes per event kind, for the playtime estimate (a duel about 4 minutes, a dungeon node 4, walking and talking between stops).
const MIN_PER_FIGHT: float = 4.0
const MIN_PER_OTHER: float = 1.5
const MIN_PER_STEP: float = 12.0
## A late repeat fight (the Capital's roamers) and a replayed late dungeon, for the grinding rate.
const GRIND_FIGHTS_PER_HOUR: int = 12

var _out_nov8: String = "res://docs/design/sim/nov8/gold_study_nov8.md"


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out_nov8 = arg.substr(6)
	_content = ContentLibrary.load_all()
	for quest: QuestData in QuestCatalog.all():
		_quests[quest.id] = quest
	var profile: Profile = Profile.new()
	profile.takes = {"clear_bonus": 1.0, "main": 1.0, "roamer": 1.0, "chest": 0.5, "side_quest": 0.67, "side_dungeon": 1.0, "dungeon_side": 0.5, "minigame": 1.0, "arena": 0.5, "feat": 0.75, "secret": 0.5, "postgame": 1.0}
	var steps: Array[Step] = _build_timeline()
	var total: int = Session.STARTING_GOLD
	var xp: int = 0
	var level: int = 1
	var fights: int = 0
	var others: int = 0
	var packs: int = 0
	var picks: int = 3  # the cave's three picks
	var counters: Dictionary = {}
	for step: Step in steps:
		for event: Event in step.events:
			var count: int = int(counters.get(event.tag, 0))
			counters[event.tag] = count + 1
			if not _takes(profile, event.tag, count):
				continue
			total += event.gold
			xp += event.xp
			packs += event.packs
			var label: String = event.label.to_lower()
			if label.contains("battle") or label.contains("elite") or label.contains("boss") or label.contains("roamer") or label.contains("gatekeeper") or label.contains("fight"):
				fights += 1
				if label.contains("elite") or label.contains("boss"):
					picks += 1
			else:
				others += 1
		var new_level: int = ProgressionTable.level_for_xp(xp)
		for gained: int in range(level + 1, new_level + 1):
			for grant: Variant in LevelTrack.level_entry(gained).get("grants", []) as Array:
				var kind: String = str((grant as Dictionary).get("kind", ""))
				if kind == "gold":
					total += int((grant as Dictionary).get("amount", 0))
				elif kind == "pack":
					packs += 1
		level = new_level
	var minutes: float = float(fights) * MIN_PER_FIGHT + float(others) * MIN_PER_OTHER + float(steps.size()) * MIN_PER_STEP
	# the shopping list
	var cards_cost: int = 0
	var cards_count: int = 0
	for rarity: Variant in NOV8_CARD_MIX.keys():
		cards_cost += int(NOV8_CARD_MIX[rarity]) * Economy.card_price(rarity as CardEnums.Rarity)
		cards_count += int(NOV8_CARD_MIX[rarity])
	var gear_cost: int = 0
	var gear_names: PackedStringArray = []
	for id: String in NOV8_GEAR:
		var piece: EquipmentData = _content.equipment_piece(id)
		if piece == null:
			continue
		var price: int = Economy.gear_price(piece.rarity, maxi(1, piece.tier))
		gear_cost += price
		gear_names.append("%s %d" % [piece.source_name, price])
	var item_cost: int = NOV8_ITEM_CHARGES * NOV8_ITEM_AVERAGE
	var hat_cost: int = 700
	var pack_cost: int = 0
	for id: String in NOV8_PACKS:
		pack_cost += PackCatalog.find(id).price
	var spend: int = cards_cost + gear_cost + item_cost + hat_cost + pack_cost
	var left: int = total - spend
	var average_card: float = float(cards_cost) / float(cards_count)
	# one copy of every card: the shelf price of each, less what a no-grind player owns without buying (starter, picks, packs) and the bought mix
	var pool: Dictionary = {}
	var one_each: int = 0
	for card: CardData in _content.cards.values():
		if card.is_token or card.is_infrastructure() or CardAvailability.is_enemy_only(card):
			continue
		pool[int(card.rarity)] = int(pool.get(int(card.rarity), 0)) + 1
		one_each += Economy.card_price(card.rarity)
	var distinct: int = 0
	for rarity: Variant in pool.keys():
		distinct += int(pool[rarity])
	# Per rarity: the free cards (picks and pack cards, drawn at a Path Pack's odds 60 / 28 / 10 / 2) find distinct cards with repeats
	# (n draws from a pool of k: k (1 - e^(-n/k))); the starter adds about 18 distinct Commons. What is still missing costs its shelf price;
	# half the bought mix lands on missing cards (the rest are second copies for the deck), then the gold left over buys missing cards.
	var free_cards: float = float(packs * 3 + picks)
	var odds: Array[float] = [0.6, 0.28, 0.1, 0.02]
	var missing_cost: float = 0.0
	var free_distinct: float = 0.0
	for rarity: Variant in pool.keys():
		var k: float = float(pool[rarity])
		var found: float = k * (1.0 - exp(-free_cards * odds[int(rarity)] / k))
		if int(rarity) == int(CardEnums.Rarity.COMMON):
			found = minf(k, found + 18.0 * (1.0 - found / k))
		var bought: float = float(NOV8_CARD_MIX.get(rarity, 0)) * 0.5
		var still: float = maxf(0.0, k - found - bought)
		free_distinct += found
		missing_cost += still * float(Economy.card_price(rarity as CardEnums.Rarity))
	missing_cost = maxf(0.0, missing_cost - float(maxi(0, left)))
	var owned_without_grind: float = float(distinct) - missing_cost / (float(one_each) / float(distinct))
	var missing: float = float(distinct) - owned_without_grind
	var grind_gold_per_hour: float = float(Economy.roamer_gold("final")) * float(GRIND_FIGHTS_PER_HOUR)
	var grind_hours: float = missing_cost / grind_gold_per_hour
	var md: PackedStringArray = []
	md.append("| | Value |")
	md.append("|---|---:|")
	md.append("| Gold earned, no grinding | %d |" % total)
	md.append("| Estimated playthrough (%d fights x %d min, %d other stops x %.1f min, %d stops x %d min walking) | %.1f h |" % [fights, int(MIN_PER_FIGHT), others, MIN_PER_OTHER, steps.size(), int(MIN_PER_STEP), minutes / 60.0])
	md.append("| %d cards (%d Common, %d Uncommon, %d Epic, %d Legendary) | %d |" % [cards_count, int(NOV8_CARD_MIX[CardEnums.Rarity.COMMON]), int(NOV8_CARD_MIX[CardEnums.Rarity.UNCOMMON]), int(NOV8_CARD_MIX[CardEnums.Rarity.EPIC]), int(NOV8_CARD_MIX[CardEnums.Rarity.LEGENDARY]), cards_cost])
	md.append("| %d gear pieces (%s) | %d |" % [gear_names.size(), ", ".join(gear_names), gear_cost])
	md.append("| Items: %d charges (about %d each) | %d |" % [NOV8_ITEM_CHARGES, NOV8_ITEM_AVERAGE, item_cost])
	md.append("| Hats (3) | %d |" % hat_cost)
	md.append("| Packs (%d) | %d |" % [NOV8_PACKS.size(), pack_cost])
	md.append("| **Left after all that** | **%d** (about %d more cards at the mix's average, %d) |" % [left, int(float(left) / average_card), int(average_card)])
	md.append("| Packs earned without buying | %d |" % packs)
	md.append("| One copy of every card (%d cards) at shelf prices | %d |" % [distinct, one_each])
	md.append("| Owned without grinding (estimate: starter, picks and packs, the bought cards) | %d of %d |" % [int(owned_without_grind), distinct])
	md.append("| Still missing, at shelf prices (skewed rare) | about %d gold |" % int(missing_cost))
	md.append("| Grinding at the Capital (%d gold a fight, %d fights an hour) | %.1f h = **%d %% extra playtime** |" % [Economy.roamer_gold("final"), GRIND_FIGHTS_PER_HOUR, grind_hours, int(round(grind_hours / (minutes / 60.0) * 100.0))])
	_completion(md, total, spend, packs, picks, minutes)
	var text: String = "\n".join(md)
	print(text)
	var file: FileAccess = FileAccess.open(_out_nov8, FileAccess.WRITE)
	file.store_string(text + "\n")
	file.close()
	return true


## Fixes Nov 8 (owner): the completionist goal - THREE copies of every single-Path and Colorless card, then one of every multi-Path card from
## the Alchemist. What a no-grind run's gold covers, and the extra grinding to finish (late roamer fights, 12 an hour). Free copies: the
## starter, the reward picks and every pack card (each counts toward a 3x set until its card is complete; past that it is essence). Crafting:
## one brew per multi-Path card (the cauldron favours missing cards), its gold plus its essence; essence beyond the free supply is bought as
## packs of already-complete cards (each card past its cap converts, `Essence.VALUE_BY_RARITY`).
func _completion(md: PackedStringArray, total: int, spend: int, packs: int, picks: int, minutes: float) -> void:
	var singles: Dictionary = {}  # rarity -> count
	var dual: int = 0
	var tri: int = 0
	for card: CardData in _content.cards.values():
		if card.is_token or card.is_infrastructure() or CardAvailability.is_enemy_only(card) or card.is_multipath():
			continue
		singles[int(card.rarity)] = int(singles.get(int(card.rarity), 0)) + 1
	for value: Variant in _content.multipath_cards.values():
		var multi: CardData = value as CardData
		if multi == null or CardAvailability.is_enemy_only(multi):
			continue
		if multi.paths().size() >= 3:
			tri += 1
		else:
			dual += 1
	var copies: int = 0
	var shelf: int = 0
	for rarity: Variant in singles.keys():
		copies += 3 * int(singles[rarity])
		shelf += 3 * int(singles[rarity]) * Economy.card_price(rarity as CardEnums.Rarity)
	var average_copy: float = float(shelf) / float(maxi(1, copies))
	var free: float = float(packs * 3 + picks) + 25.0  # the starter's non-Infrastructure copies
	var free_value: float = free * average_copy * 0.75  # pack cards lean Common, cheaper than the average copy
	var buy_singles: float = maxf(0.0, float(shelf) - free_value)
	var craft_gold: int = dual * Alchemy.GOLD_COST + tri * Alchemy.TRI_GOLD_COST
	var craft_essence: int = dual * Alchemy.MIN_ESSENCE_PER_PATH * 2 + tri * Alchemy.MIN_ESSENCE_PER_PATH * 3
	var free_essence: float = float(ShatteredGallery.FIRST_CLEAR_ESSENCE * 4) + free * 0.1 * 3.0  # the Gallery, and the odd pack card past its cap
	var essence_gap: float = maxf(0.0, float(craft_essence) - free_essence)
	var pack: PackData = PackCatalog.find("path_beefcake")
	var essence_per_pack: float = 0.0
	for index: int in range(pack.rarity_weights.size()):
		essence_per_pack += float(pack.rarity_weights[index]) / 100.0 * float(Essence.value_for(index as CardEnums.Rarity))
	essence_per_pack *= float(pack.card_count)
	var essence_gold: float = essence_gap / maxf(0.01, essence_per_pack) * float(pack.price)
	var goal: float = buy_singles + float(craft_gold) + essence_gold
	var available: float = float(total - spend) + float(spend) * 0.0
	var covered: float = clampf(available / goal, 0.0, 1.0)
	var gap: float = maxf(0.0, goal - available)
	var per_fight: float = float(Economy.fight_gold(Economy.roamer_gold("final"), true, ProgressionModel.level_for("zone:final", 1)))
	var roamer_hour: float = per_fight * float(GRIND_FIGHTS_PER_HOUR)
	# The better grind: replaying a late dungeon (the Lab, L25) - its fights at the late rate, the clear bonus, the repeat clear's gold and its
	# Path Pack (counted at its price), at 4 minutes a fight plus 5 to walk in and out.
	var replay: Dictionary = _replay("D-LAB")
	var replay_hour: float = float(replay["gold"]) / (float(replay["minutes"]) / 60.0)
	var best_hour: float = maxf(roamer_hour, replay_hour)
	var hours: float = gap / best_hour
	var fights: float = hours * 60.0 / MIN_PER_FIGHT
	md.append("| **The completionist goal** | |")
	md.append("| Three copies of every single-Path and Colorless card (%d copies) at shelf prices | %d |" % [copies, shelf])
	md.append("| Copies a no-grind run gets free (starter, %d picks, %d packs x 3) | about %d (worth about %d) |" % [picks, packs, int(free), int(free_value)])
	md.append("| Multi-Path cards to craft (%d dual, %d tri): gold | %d |" % [dual, tri, craft_gold])
	md.append("| ... and essence (%d needed, about %d free; the rest from packs of finished cards, %.1f essence a Path Pack) | %d gold |" % [craft_essence, int(free_essence), essence_per_pack, int(essence_gold)])
	md.append("| **Total to finish everything** | **%d gold** |" % int(goal))
	md.append("| Gold a no-grind run has left after its shopping list | %d (covers about %d %%) |" % [total - spend, int(covered * 100.0)])
	md.append("| Grinding rates | Capital roamer repeats %d gold a fight = %d an hour; replaying the Lab %d gold in %d min = %d an hour |" % [int(per_fight), int(roamer_hour), int(replay["gold"]), int(replay["minutes"]), int(replay_hour)])
	md.append("| **Extra grinding to finish** (at the better rate) | **about %d fights = %.1f h = %d %% on top of a %.1f h run** |" % [int(fights), hours, int(round(hours / (minutes / 60.0) * 100.0)), minutes / 60.0])


## One replay of a dungeon: {gold, minutes} - its fights' gold as Session pays it (the node share, the late scale), the clear bonus, the
## repeat clear's gold and the repeat Path Pack at its price.
func _replay(dungeon_id: String) -> Dictionary:
	var blueprint: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_id)
	var gold: float = 0.0
	var fights: int = 0
	if blueprint != null:
		for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
			if node.side:
				continue
			var kind: DungeonMap.Kind = DungeonBuilder.kind_of(node.type)
			var difficulty: int = -1
			if kind == DungeonMap.Kind.BATTLE:
				difficulty = DungeonMap.Difficulty.NORMAL
			elif kind == DungeonMap.Kind.ELITE:
				difficulty = DungeonMap.Difficulty.ELITE
			elif kind == DungeonMap.Kind.BOSS:
				difficulty = DungeonMap.Difficulty.BOSS
			if difficulty >= 0:
				fights += 1
				gold += float(Economy.late_gold(EncounterRewards.dungeon_fight_gold(difficulty as DungeonMap.Difficulty), ProgressionModel.level_for(dungeon_id, 1)))
	gold += gold * Economy.CLEAR_BONUS_SHARE + float(Economy.SIDE_REPEAT_GOLD) + float(PackCatalog.find("path_beefcake").price)
	return {"gold": gold, "minutes": float(fights) * MIN_PER_FIGHT + 5.0}
