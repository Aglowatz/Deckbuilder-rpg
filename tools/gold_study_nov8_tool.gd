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
	var text: String = "\n".join(md)
	print(text)
	var file: FileAccess = FileAccess.open(_out_nov8, FileAccess.WRITE)
	file.store_string(text + "\n")
	file.close()
	return true
