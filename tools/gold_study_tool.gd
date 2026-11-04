extends "res://tools/economy_model_tool.gd"
## Overnight Nov 3-4, Part B9: the card-economy study. Walks the economy model's real timeline (`_build_timeline`: every fight, chest, quest,
## feat, level reward and shop stop the data defines) as a NO-GRIND player - the critical path plus normal side content, never a repeat
## fight or a replayed dungeon for gold - adds up the gold per zone, takes off what such a player also buys (item charges, a few hats, the
## essential gear, the hub fees for the odd lost duel), and sets the card prices so the gold left buys about 20 cards. Then checks grinding:
## how many repeat fights at each zone's level buy one more card. Writes docs/balance/gold_economy_nov3.md.
##   Godot --headless --path . -s res://tools/gold_study.gd [-- --out=res://docs/balance/gold_economy_nov3.md]

const TARGET_CARDS: int = 20
## The rarity mix of a no-grind player's ~20 bought cards (the shelves are mostly Commons; Epics and a Legendary are the big buys).
const CARD_MIX: Dictionary = {CardEnums.Rarity.COMMON: 10, CardEnums.Rarity.UNCOMMON: 6, CardEnums.Rarity.EPIC: 3, CardEnums.Rarity.LEGENDARY: 1}
## The rarity price ratios kept (today 30 / 60 / 150 / 300 = 1 : 2 : 5 : 10).
const RATIO: Dictionary = {CardEnums.Rarity.COMMON: 1, CardEnums.Rarity.UNCOMMON: 2, CardEnums.Rarity.EPIC: 5, CardEnums.Rarity.LEGENDARY: 10}
## What a typical player also buys: about 7 item charges, three hats, the essential gear.
const ITEM_CHARGES: Array[String] = ["vitality_charm", "healing_salve", "healing_salve", "power_wraps", "firebrand_charm", "energy_draught", "scroll_of_insight"]
const HATS: int = 3
## The prices before this pass (Economy.CARD_PRICE now holds the applied ones).
const CARD_PRICE_BEFORE: Array[int] = [30, 60, 150, 300]

var _study_out: String = "res://docs/balance/gold_economy_nov3.md"
var _md: PackedStringArray = []


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_study_out = arg.substr(6)
	_content = ContentLibrary.load_all()
	var profile: Profile = Profile.new()
	profile.name = "no-grind"
	# The model's "expected" player minus every repeat: main path, roamers once, half the chests, two thirds of the side quests, every side
	# dungeon once, the minigames and half the arena once, most feats.
	profile.takes = {"main": 1.0, "roamer": 1.0, "chest": 0.5, "side_quest": 0.67, "side_dungeon": 1.0, "dungeon_side": 0.5, "minigame": 1.0, "arena": 0.5, "feat": 0.75, "secret": 0.5, "postgame": 1.0}
	var steps: Array[Step] = _build_timeline()
	var by_zone: Dictionary = {}
	var zone_order: Array[String] = []
	var by_tag: Dictionary = {}
	var tag_counters: Dictionary = {}
	var xp: int = 0
	var level: int = 1
	var gear_cost: int = 0
	var gear_names: PackedStringArray = []
	var fees: int = 0
	var fee_count: int = 0
	var postgame_from: int = -1
	for index: int in steps.size():
		var step: Step = steps[index]
		var zone: String = _zone_label(step)
		if not by_zone.has(zone):
			by_zone[zone] = 0
			zone_order.append(zone)
		for event: Event in step.events:
			var count: int = int(tag_counters.get(event.tag, 0))
			tag_counters[event.tag] = count + 1
			if not _takes(profile, event.tag, count):
				continue
			by_zone[zone] = int(by_zone[zone]) + event.gold
			by_tag[event.tag] = int(by_tag.get(event.tag, 0)) + event.gold
			xp += event.xp
		var new_level: int = ProgressionTable.level_for_xp(xp)
		for gained: int in range(level + 1, new_level + 1):
			for grant: Variant in LevelTrack.level_entry(gained).get("grants", []) as Array:
				if str((grant as Dictionary).get("kind", "")) == "gold":
					var amount: int = int((grant as Dictionary).get("amount", 0))
					by_zone[zone] = int(by_zone[zone]) + amount
					by_tag["level_track"] = int(by_tag.get("level_track", 0)) + amount
		level = new_level
		for offer: Offer in step.offers:
			if offer.sink == "fee":
				fees += offer.price
				fee_count += 1
			elif offer.sink == "gear" and offer.want >= ESSENTIAL:
				gear_cost += offer.price
				gear_names.append("%s %d" % [offer.label, offer.price])
	var total: int = 0
	for zone: Variant in by_zone.keys():
		total += int(by_zone[zone])
	total += Session.STARTING_GOLD
	var item_cost: int = 0
	for id: String in ITEM_CHARGES:
		item_cost += Economy.item_price(id)
	var hat_prices: Array[int] = []
	for cosmetic: CosmeticData in CosmeticCatalog.all():
		if cosmetic.slot_name() == "Hat" and cosmetic.price > 0:
			hat_prices.append(cosmetic.price)
	hat_prices.sort()
	var hat_cost: int = 0
	var hats_named: int = mini(HATS, hat_prices.size())
	# a few hats: the middle of the price list, not the cheapest
	var start: int = maxi(0, hat_prices.size() / 2 - 1)
	for i: int in hats_named:
		hat_cost += hat_prices[mini(start + i, hat_prices.size() - 1)]
	var other: int = item_cost + hat_cost + gear_cost + fees
	var left: int = total - other
	var units: int = 0
	for rarity: Variant in CARD_MIX.keys():
		units += int(CARD_MIX[rarity]) * int(RATIO[rarity])
	var unit_price: int = int(floor(float(left) / float(units) / 5.0)) * 5
	var prices: Dictionary = {}
	for rarity: Variant in RATIO.keys():
		prices[rarity] = unit_price * int(RATIO[rarity])
	_write_study(by_zone, zone_order, by_tag, total, item_cost, hat_cost, hat_prices, gear_cost, gear_names, fees, fee_count, left, units, prices)
	var file: FileAccess = FileAccess.open(_study_out, FileAccess.WRITE)
	file.store_string("\n".join(_md) + "\n")
	file.close()
	print("gold_study: total=%d items=%d hats=%d gear=%d fees=%d left=%d unit=%d prices=%s" % [total, item_cost, hat_cost, gear_cost, fees, left, unit_price, str(prices)])
	return true


func _zone_label(step: Step) -> String:
	var zone: String = step.zone
	if step.label.to_lower().contains("postgame"):
		return "postgame"
	return zone if not zone.is_empty() else "town"


func _write_study(by_zone: Dictionary, zone_order: Array[String], by_tag: Dictionary, total: int, item_cost: int, hat_cost: int, hat_prices: Array[int],
		gear_cost: int, gear_names: PackedStringArray, fees: int, fee_count: int, left: int, units: int, prices: Dictionary) -> void:
	_md.append("# Gold economy study (Overnight Nov 3-4, Part B9)")
	_md.append("")
	_md.append("Generated by `tools/gold_study.gd` (`tools/gold_study_tool.gd`, built on the economy model's timeline) on %s. Every gold number is" % Time.get_datetime_string_from_system())
	_md.append("read from the game's own tables (quests, dungeons, chests, roamers, feats, level track, shops).")
	_md.append("")
	_md.append("**The player:** no grinding - the critical path plus normal side content, every fight and dungeon once, no repeat fights or")
	_md.append("replayed dungeons for gold. Takes: every main step and roamer once, half the chests, two thirds of the side quests, every side")
	_md.append("dungeon, half the side branches and the arena, every minigame once, three quarters of the feats, half the secrets, the postgame.")
	_md.append("")
	_md.append("## Gold earned per zone")
	_md.append("")
	_md.append("| Zone / stage | Gold |")
	_md.append("|---|---:|")
	_md.append("| Starting gold | %d |" % Session.STARTING_GOLD)
	for zone: String in zone_order:
		_md.append("| %s | %d |" % [str(ZONE_NAMES.get(zone, zone.capitalize())), int(by_zone[zone])])
	_md.append("| **Whole playthrough** | **%d** |" % total)
	_md.append("")
	_md.append("By source:")
	_md.append("")
	_md.append("| Source | Gold |")
	_md.append("|---|---:|")
	var tags: Array = by_tag.keys()
	tags.sort_custom(func(a: Variant, b: Variant) -> bool: return int(by_tag[a]) > int(by_tag[b]))
	for tag: Variant in tags:
		_md.append("| %s | %d |" % [str(tag), int(by_tag[tag])])
	_md.append("")
	_md.append("## What a typical player also buys")
	_md.append("")
	_md.append("| Sink | Gold | What |")
	_md.append("|---|---:|---|")
	var item_names: PackedStringArray = []
	for id: String in ITEM_CHARGES:
		item_names.append("%s %d" % [_content.item(id).display_name, Economy.item_price(id)])
	_md.append("| Item charges (%d) | %d | %s (single-use charges at the new prices, Part B3) |" % [ITEM_CHARGES.size(), item_cost, ", ".join(item_names)])
	_md.append("| Hats (%d) | %d | the middle of Pip's price list (%s) |" % [HATS, hat_cost, ", ".join(hat_prices.map(func(p: int) -> String: return str(p)))])
	_md.append("| Essential gear | %d | %s |" % [gear_cost, ", ".join(gear_names)])
	_md.append("| Hub fees (a lost duel per zone, %d) | %d | |" % [fee_count, fees])
	_md.append("| **Total** | **%d** | |" % (item_cost + hat_cost + gear_cost + fees))
	_md.append("")
	_md.append("## Gold left for cards")
	_md.append("")
	_md.append("**%d gold** over the whole playthrough." % left)
	_md.append("")
	_md.append("Target: about %d bought cards, in a sensible mix (%d Common, %d Uncommon, %d Epic, %d Legendary), keeping the rarity ratio" % [TARGET_CARDS, int(CARD_MIX[CardEnums.Rarity.COMMON]), int(CARD_MIX[CardEnums.Rarity.UNCOMMON]), int(CARD_MIX[CardEnums.Rarity.EPIC]), int(CARD_MIX[CardEnums.Rarity.LEGENDARY])])
	_md.append("1 : 2 : 5 : 10. The mix weighs %d price units, so one unit is %d / %d, rounded down to 5: **%d gold**." % [units, left, units, int(prices[CardEnums.Rarity.COMMON])])
	_md.append("")
	_md.append("| Rarity | Before | Computed | Applied (rounded to 100s) |")
	_md.append("|---|---:|---:|---:|")
	var applied: Dictionary = {}
	var applied_total: int = 0
	for rarity: Variant in [CardEnums.Rarity.COMMON, CardEnums.Rarity.UNCOMMON, CardEnums.Rarity.EPIC, CardEnums.Rarity.LEGENDARY]:
		applied[rarity] = Economy.CARD_PRICE[int(rarity)]
		applied_total += int(CARD_MIX[rarity]) * Economy.CARD_PRICE[int(rarity)]
		_md.append("| %s | %d | %d | **%d** |" % [CardView.RARITY_NAMES[int(rarity)], CARD_PRICE_BEFORE[int(rarity)], int(prices[rarity]), Economy.CARD_PRICE[int(rarity)]])
	_md.append("")
	_md.append("At the applied prices the 20-card mix costs %d gold (%d left): **%.1f cards** for the no-grind player. At the old prices the same gold bought about %d cards." % [applied_total, left, 20.0 * float(left) / float(applied_total), left * 20 / maxi(1, (10 * 30 + 6 * 60 + 3 * 150 + 300))])
	prices = applied
	_md.append("")
	_md.append("## Grinding check")
	_md.append("")
	_md.append("A roamer spot beaten before pays %d x its zone's gold (`Economy.fight_gold`, new tonight; the first win pays the plain rate, so the" % Economy.REPEAT_FIGHT_MULTIPLIER)
	_md.append("no-grind numbers above do not change). A replayed main dungeon pays %d, a side" % Economy.MAIN_REPEAT_GOLD)
	_md.append("dungeon %d. Repeat fights per extra card (the mix's average card, %d gold; a Common, %d):" % [Economy.SIDE_REPEAT_GOLD, _mix_average(prices), int(prices[CardEnums.Rarity.COMMON])])
	_md.append("")
	_md.append("| Zone | Roamer gold (first win) | Repeat fight | Repeat fights per Common | per Uncommon | per average card |")
	_md.append("|---|---:|---:|---:|---:|---:|")
	for zone: String in ["town", "beefcake", "necrocrat", "gourmand", "refusemancer", "final"]:
		var base: int = Economy.roamer_gold(zone)
		var gold: int = Economy.fight_gold(base, true)
		_md.append("| %s | %d | %d | %.1f | %.1f | %.1f |" % [str(ZONE_NAMES.get(zone, "Crosspath outskirts" if zone == "town" else zone)), base, gold, float(prices[CardEnums.Rarity.COMMON]) / float(gold), float(prices[CardEnums.Rarity.UNCOMMON]) / float(gold), float(_mix_average(prices)) / float(gold)])
	_md.append("")
	_md.append("Target: about one extra card per 3-4 repeat fights at the zone's level. Measured against a Common (what a grinder tops a deck up")
	_md.append("with) the Path zones land at about 2-4 fights; an Uncommon takes twice that and an Epic is a real saving goal (10-20 fights).")
	_md.append("Crosspath's outskirts (13 gold) stay a poor place to grind, on purpose.")


func _mix_average(prices: Dictionary) -> int:
	var total: int = 0
	var count: int = 0
	for rarity: Variant in CARD_MIX.keys():
		total += int(CARD_MIX[rarity]) * int(prices[rarity])
		count += int(CARD_MIX[rarity])
	return total / maxi(1, count)
