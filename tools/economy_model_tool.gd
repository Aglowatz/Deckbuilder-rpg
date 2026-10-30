extends RefCounted
## Overnight Oct 29, Part 1: the gold and essence economy over a whole run, for three player profiles.
##
## Every source the data defines (tutorial, roamers, gatekeepers, dungeon nodes and first / repeat clears, quests, chests, minigames,
## arena, feats, level track) is laid on the story's timeline (Crosspath -> Gainlands -> D.N.A. -> Buffet -> Dump -> Capital -> castle ->
## postgame) and every sink (items, gear, cards, packs, cosmetics, alchemy, zone fees) is offered at the shop stops where it is for sale.
## Three profiles walk the timeline: "rusher" (main path only), "expected" (main path plus a normal amount of side content) and
## "thorough" (everything once, a little repeat content). Each buys from a want list by priority, and the report shows the gold curve,
## what was bought when, droughts (shop stops with wants but nothing affordable), hoarding (gold piling up past every want) and sinks
## never used. Levels come from the XP actually earned on the timeline (`ProgressionTable`).
##
## Run: Godot --headless --path . -s res://tools/economy_model.gd (the loader; this file is the body) [-- --out=res://docs/design/sim/economy_model.md --profile=expected]
## Pure data: no Session. Numbers are read from the game's own tables, so a price change shows here without touching this file.

const ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]
const ZONE_NAMES: Dictionary = {"beefcake": "Gainlands", "necrocrat": "D.N.A.", "gourmand": "Buffet", "refusemancer": "Dump", "final": "Capital"}
const SIDE_DUNGEON: Dictionary = {"beefcake": "S-IRON", "necrocrat": "S-NECRO", "gourmand": "S-GOUR", "refusemancer": "S-REF", "final": "S-CAP"}
const MAIN_DUNGEON: Dictionary = {"beefcake": "D-HOG", "necrocrat": "D-HFA", "gourmand": "D-TTK", "refusemancer": "D-ROT", "final": "D-PC"}
const ZONE_QUEST_IDS: Dictionary = {
	"beefcake": ["gain_power", "gain_spot_me", "gain_lanes", "side_s_beef"],
	"necrocrat": ["dna_backlog", "dna_onboarding", "dna_audit", "side_s_necro"],
	"gourmand": ["buf_pantry", "buf_pie", "buf_mend", "side_s_gour"],
	"refusemancer": ["heap_herd", "heap_fert", "heap_dam", "side_s_ref"],
	"final": ["cap_burial", "cap_wheels", "cap_recipes", "cap_untidy", "side_s_cap"],
}
const MAIN_QUEST_IDS: Dictionary = {"beefcake": "main_beefcake", "necrocrat": "main_necrocrat", "gourmand": "main_gourmand", "refusemancer": "main_refusemancer"}
## Roamer kinds per zone (ids of `<Zone>Enemies.info`), and how many fights a first visit offers (spots on the map, about two per kind).
const ROAMERS: Dictionary = {
	"beefcake": ["brute", "golem", "sprite"], "necrocrat": ["manager", "intern", "courier"], "gourmand": ["loaf", "jelly", "meatball"],
	"refusemancer": ["golem", "scarecrow", "gulls"], "final": ["officer", "inspector", "tidybot", "wretch", "swarm"],
}
const ZONE_ELITE: Dictionary = {"gourmand": "casserole", "final": "spotless"}
const ROAMER_SPOTS_PER_KIND: int = 2
## Minigame per zone (first clear at 2 stars, the model's "normal" result: STAR_REWARDS[2] * 2 + the first-clear bonus).
const MINIGAME_FIRST: Dictionary = {"beefcake": 140, "necrocrat": 0, "gourmand": 140, "refusemancer": 140, "final": 0}
const MINIGAME_REPEAT: int = 32  # 45 / 2 + 10

## Want levels: 3 = essential (a profile buys these first), 2 = nice, 1 = luxury.
const ESSENTIAL: int = 3
const NICE: int = 2
const LUXURY: int = 1

var _content: ContentSet
var _quests: Dictionary = {}
var _out: String = "res://docs/design/sim/economy_model.md"
var _only_profile: String = ""
var _lines: PackedStringArray = []
## XP Pass Oct 30: profile name -> rows of {step, model, xp_before, xp_after} for the level timeline (before / after the re-based curve).
var _timelines: Dictionary = {}
var _timeline_order: Array[String] = []


class Event:
	extends RefCounted
	var label: String = ""
	var tag: String = ""  # main, roamer, roamer_repeat, chest, side_quest, side_dungeon, dungeon_side, minigame, minigame_repeat, arena, feat, secret, postgame, repeat_clear
	var gold: int = 0
	var xp: int = 0
	var essence: int = 0
	var packs: int = 0

	static func make(label_value: String, tag_value: String, gold_value: int, xp_value: int = 0) -> Event:
		var event: Event = Event.new()
		event.label = label_value
		event.tag = tag_value
		event.gold = gold_value
		event.xp = xp_value
		return event


class Offer:
	extends RefCounted
	var id: String = ""
	var label: String = ""
	var sink: String = ""  # item, gear, card, pack, cosmetic, alchemy, fee
	var price: int = 0
	var want: int = 1
	var repeat: bool = false  # may be bought again at a later stop (packs, items)
	var min_level: int = 0
	var zone: String = ""
	var bought: int = 0

	static func make(id_value: String, label_value: String, sink_value: String, price_value: int, want_value: int, min_level_value: int = 0) -> Offer:
		var offer: Offer = Offer.new()
		offer.id = id_value
		offer.label = label_value
		offer.sink = sink_value
		offer.price = price_value
		offer.want = want_value
		offer.min_level = min_level_value
		return offer


class Step:
	extends RefCounted
	var label: String = ""
	var zone: String = ""
	var expected_level: int = 0
	var events: Array[Event] = []
	var offers: Array[Offer] = []  # new offers that open at this stop
	var shop: bool = false


class Profile:
	extends RefCounted
	var name: String = ""
	## tag -> fraction of such events taken (0..1); missing = 0.
	var takes: Dictionary = {}
	## The lowest want level bought outright; a want one below is bought only when the gold left after it stays above `flush`.
	var min_want: int = NICE
	var flush: int = 300
	var reserve: int = 30
	var packs_per_stop: int = 1
	var fee_per_zone: int = 1


class RunState:
	extends RefCounted
	var gold: int = 0
	var xp: int = 0
	var level: int = 1
	var income: Dictionary = {}  # tag -> gold
	var spend: Dictionary = {}  # sink -> gold
	var packs: int = 0
	var essence: int = 0
	var rows: Array[Dictionary] = []
	var open_offers: Array[Offer] = []
	var droughts: Array[String] = []
	var hoards: Array[String] = []
	var zones_freed: int = 0
	var unaffordable_since: Dictionary = {}  # offer id -> step index first seen unaffordable
	var waits: Array[Dictionary] = []


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--profile="):
			_only_profile = arg.substr(10)
	_content = ContentLibrary.load_all()
	for quest: QuestData in QuestDefinitions.build_all():
		_quests[quest.id] = quest
	for quest: QuestData in ZoneQuestDefinitions.build_all():
		_quests[quest.id] = quest
	_lines = ["# Economy model (Overnight Oct 29, Part 1)", "", "Generated by `tools/economy_model.gd` on %s. Every number is read from the game's tables." % Time.get_datetime_string_from_system(), ""]
	_write_sources()
	_write_prices()
	for profile: Profile in _profiles():
		if not _only_profile.is_empty() and profile.name != _only_profile:
			continue
		_simulate(profile, _build_timeline())  # a fresh timeline per profile: offers carry their bought counts
	_write_level_timeline()
	var text: String = "\n".join(_lines) + "\n"
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
	print(text)
	return true


# ---- Sources and prices (the inventory) --------------------------------------------------------------------------------------


func _write_sources() -> void:
	_lines.append("## Gold sources (one of everything)")
	_lines.append("")
	_lines.append("| Source | Count | Gold | XP | Notes |")
	_lines.append("|---|---:|---:|---:|---|")
	var tutorial: Dictionary = TrialOfTheHollow.total_tutorial_rewards()
	_lines.append("| Forgotten Cave (tutorial) | 1 run | %d | %d | starting gold %d on top |" % [int(tutorial["gold"]), int(tutorial["xp"]), 120])
	var level_gold: int = 0
	var level_packs: int = 0
	for level: int in range(2, 31):
		for grant: Variant in LevelTrack.level_entry(level).get("grants", []) as Array:
			if str((grant as Dictionary).get("kind", "")) == "gold":
				level_gold += int((grant as Dictionary).get("amount", 0))
			elif str((grant as Dictionary).get("kind", "")) == "pack":
				level_packs += 1
	_lines.append("| Level track L2-30 | 29 levels | %d | - | + %d packs, 5 cosmetics |" % [level_gold, level_packs])
	var main_gold: int = 0
	var main_xp: int = 0
	var side_gold: int = 0
	var side_xp: int = 0
	var main_count: int = 0
	var side_count: int = 0
	for quest: QuestData in _quests.values():
		if quest.category == QuestData.Category.MAIN:
			main_gold += quest.reward_gold
			main_xp += quest.reward_xp
			main_count += 1
		else:
			side_gold += quest.reward_gold
			side_xp += quest.reward_xp
			side_count += 1
	_lines.append("| Main quests | %d | %d | %d | + 4 x 40 at the gatekeepers (objective pay) |" % [main_count, main_gold, main_xp])
	_lines.append("| Side quests | %d | %d | %d | items, cards, gear, packs on top |" % [side_count, side_gold, side_xp])
	_lines.append("| Corrupted NPC gatekeepers (4) | 4 | %d | %d | once each |" % [CorruptedNpcs.reward_gold() * 4, CorruptedNpcs.reward_xp() * 4])
	_lines.append("| Graveyard (Restless Dead) | 1 | %d | %d | once |" % [GraveyardBoss.REWARD_GOLD, EncounterRewards.xp_for(DungeonMap.Difficulty.ELITE)])
	_lines.append("| Store room ghosts | 1 | 15 | 30 | once |")
	var node_rows: Array[Dictionary] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID:
			continue
		node_rows.append(_dungeon_summary(blueprint))
	var main_nodes: int = 0
	var main_node_gold: int = 0
	var main_node_xp: int = 0
	var side_nodes: int = 0
	var side_node_gold: int = 0
	var side_node_xp: int = 0
	var clears_gold: int = 0
	var clears_xp: int = 0
	var treasure_gold: int = 0
	for row: Dictionary in node_rows:
		main_nodes += int(row["main_nodes"])
		main_node_gold += int(row["main_gold"])
		main_node_xp += int(row["main_xp"])
		side_nodes += int(row["side_nodes"])
		side_node_gold += int(row["side_gold"])
		side_node_xp += int(row["side_xp"])
		clears_gold += int(row["clear_gold"])
		clears_xp += int(row["clear_xp"])
		treasure_gold += int(row["treasure_gold"])
	_lines.append("| Dungeon battle nodes on the main route | %d | %d | %d | half the open-world rate (`EncounterRewards.gold_for / 2`) |" % [main_nodes, main_node_gold, main_node_xp])
	_lines.append("| Dungeon battle nodes on side branches | %d | %d | %d | optional |" % [side_nodes, side_node_gold, side_node_xp])
	_lines.append("| Dungeon treasure nodes | - | %d | - | `loot` in dungeon_content.json |" % treasure_gold)
	_lines.append("| Dungeon first clears (14) | 14 | %d | %d | main dungeons also +%d gold (PackConfig) + a Gilded Pack; repeats: main %d + Path Pack, side %d + pack |" % [clears_gold, clears_xp, PackCatalog.config().first_clear_bonus_gold, DungeonBuilder.MAIN_REPEAT_GOLD, DungeonBuilder.SIDE_REWARD_GOLD])
	var chest_gold: int = 0
	var chest_count: int = 0
	for zone_id: String in ZONES:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def == null:
			continue
		for key: Variant in def.chest_rewards.keys():
			chest_gold += int((def.chest_rewards[key] as Dictionary).get("gold", 0))
			chest_count += 1
	var town_gold: int = 0
	for key: Variant in TownScene.HIDDEN_CHEST_REWARDS.keys():
		town_gold += int((TownScene.HIDDEN_CHEST_REWARDS[key] as Dictionary).get("gold", 0))
		chest_count += 1
	_lines.append("| Hidden chests (town + zones) | %d | %d | - | plus items, cards, gear, packs, cosmetics; 20-30%% roll a piece of gear |" % [chest_count, chest_gold + town_gold])
	var rift_gold: int = 0
	for rift: Variant in CapitalRifts.all():
		rift_gold += int(((rift as Dictionary).get("reward", {}) as Dictionary).get("gold", 0))
	_lines.append("| Capital rifts (sealed) | %d | %d | - | once each |" % [CapitalRifts.all().size(), rift_gold])
	var roamer_gold: int = 0
	var roamer_xp: int = 0
	var roamer_count: int = 0
	for zone_id: String in ZONES:
		for kind: String in ROAMERS[zone_id] as Array:
			var info: ZoneEnemyInfo = _roamer(zone_id, kind)
			if info != null:
				roamer_gold += info.gold_reward * ROAMER_SPOTS_PER_KIND
				roamer_xp += info.xp_reward * ROAMER_SPOTS_PER_KIND
				roamer_count += ROAMER_SPOTS_PER_KIND
	_lines.append("| Zone roamers, one sweep (%d per kind) | %d | %d | %d | respawn; Crosspath outskirts 12-14 each |" % [ROAMER_SPOTS_PER_KIND, roamer_count, roamer_gold, roamer_xp])
	for zone_id: String in ZONE_ELITE.keys():
		var elite: ZoneEnemyInfo = _roamer(zone_id, str(ZONE_ELITE[zone_id]))
		if elite != null:
			_lines.append("| %s (%s elite) | 1 | %d | %d | repeatable |" % [elite.display_name, str(ZONE_NAMES[zone_id]), elite.gold_reward, elite.xp_reward])
	var arena_gold: int = 0
	var arena_xp: int = 0
	for encounter: ArenaEncounter in ArenaDefs.all():
		arena_gold += int(encounter.reward.get("gold", 0))
		arena_xp += int(encounter.reward.get("xp", 0))
	_lines.append("| Arena first clears | %d | %d | %d | replays %d; essence and gear on top |" % [ArenaDefs.all().size(), arena_gold, arena_xp, 15])
	var minigame_gold: int = 0
	for zone_id: String in MINIGAME_FIRST.keys():
		minigame_gold += int(MINIGAME_FIRST[zone_id])
	_lines.append("| Minigames, first clear at 2 stars | 3 | %d | 40 each | repeats about %d |" % [minigame_gold, MINIGAME_REPEAT])
	var feat_gold: int = 0
	var feat_essence: int = 0
	for feat: FeatDefs.Def in FeatDefs.all():
		feat_gold += feat.reward_gold
		feat_essence += feat.reward_essence
	_lines.append("| Feats (%d) | %d | %d | - | once per account; %d essence |" % [FeatDefs.count(), FeatDefs.count(), feat_gold, feat_essence])
	_lines.append("| Collection milestones | 1 | 200 | - | 50%%: 200 gold; 25 / 75 / 100%%: packs |")
	_lines.append("| Lieutenants' yards (Capital) | 1 | %d | - | once |" % Lieutenants.YARDS_GOLD)
	_lines.append("")
	_lines.append("Per dungeon (main route nodes / side nodes / first clear):")
	_lines.append("")
	_lines.append("| Dungeon | Zone | Main nodes | Gold | XP | Side nodes | Gold | XP | Treasure | First clear gold | XP |")
	_lines.append("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
	for row: Dictionary in node_rows:
		_lines.append("| %s | %s | %d | %d | %d | %d | %d | %d | %d | %d | %d |" % [str(row["id"]), str(row["zone"]), int(row["main_nodes"]), int(row["main_gold"]), int(row["main_xp"]), int(row["side_nodes"]), int(row["side_gold"]), int(row["side_xp"]), int(row["treasure_gold"]), int(row["clear_gold"]), int(row["clear_xp"])])
	_lines.append("")


func _dungeon_summary(blueprint: DungeonCatalog.Blueprint) -> Dictionary:
	var row: Dictionary = {"id": blueprint.id, "zone": blueprint.zone_id, "main_nodes": 0, "main_gold": 0, "main_xp": 0, "side_nodes": 0, "side_gold": 0, "side_xp": 0, "treasure_gold": 0, "clear_gold": 0, "clear_xp": 0}
	var def: MainDungeonDef = DungeonBuilder.build_def(blueprint)
	row["clear_gold"] = def.reward_gold
	row["clear_xp"] = def.reward_xp
	if not blueprint.is_side():
		row["clear_gold"] = int(row["clear_gold"]) + PackCatalog.config().first_clear_bonus_gold
		row["clear_xp"] = int(row["clear_xp"]) + PackCatalog.config().first_clear_bonus_xp
	var loot: Dictionary = _loot_table(blueprint.id)
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var kind: DungeonMap.Kind = DungeonBuilder.kind_of(node.type)
		var difficulty: int = -1
		if kind == DungeonMap.Kind.BOSS:
			difficulty = DungeonMap.Difficulty.BOSS
		elif kind == DungeonMap.Kind.ELITE:
			difficulty = DungeonMap.Difficulty.ELITE
		elif kind == DungeonMap.Kind.BATTLE:
			difficulty = DungeonMap.Difficulty.NORMAL
		if kind == DungeonMap.Kind.TREASURE:
			var entry: Variant = loot.get(str(node.number))
			row["treasure_gold"] = int(row["treasure_gold"]) + (int((entry as Dictionary).get("gold", 0)) if entry is Dictionary else 60)
		if difficulty < 0:
			continue
		var gold: int = EncounterRewards.gold_for(difficulty as DungeonMap.Difficulty) / 2
		var xp: int = EncounterRewards.xp_for(difficulty as DungeonMap.Difficulty)
		if node.side:
			row["side_nodes"] = int(row["side_nodes"]) + 1
			row["side_gold"] = int(row["side_gold"]) + gold
			row["side_xp"] = int(row["side_xp"]) + xp
		else:
			row["main_nodes"] = int(row["main_nodes"]) + 1
			row["main_gold"] = int(row["main_gold"]) + gold
			row["main_xp"] = int(row["main_xp"]) + xp
	return row


func _loot_table(dungeon_id: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json"))
	if parsed is Dictionary and (parsed as Dictionary).has(dungeon_id):
		return ((parsed as Dictionary)[dungeon_id] as Dictionary).get("loot", {}) as Dictionary
	return {}


func _roamer(zone_id: String, kind: String) -> ZoneEnemyInfo:
	match zone_id:
		"beefcake":
			return GainlandsEnemies.info(kind)
		"necrocrat":
			return DnaEnemies.info(kind)
		"gourmand":
			return BuffetEnemies.info(kind)
		"refusemancer":
			return HeapEnemies.info(kind)
		"final":
			return CapitalEnemies.info(kind)
	return null


func _write_prices() -> void:
	_lines.append("## Prices (sinks)")
	_lines.append("")
	_lines.append("| Sink | Prices |")
	_lines.append("|---|---|")
	var by_rarity: Dictionary = {}
	for card: CardData in _content.cards.values():
		if card.is_token or card.is_infrastructure():
			continue
		var key: int = int(card.rarity)
		if not by_rarity.has(key):
			by_rarity[key] = []
		(by_rarity[key] as Array).append(CardPricing.price(card))
	var parts: PackedStringArray = []
	for rarity: int in range(4):
		var prices: Array = by_rarity.get(rarity, []) as Array
		if prices.is_empty():
			continue
		var total: int = 0
		for price: Variant in prices:
			total += int(price)
		_mean_prices[rarity] = int(round(float(total) / float(prices.size())))
		_lines.append("| Cards, %s (%d) | %d-%d, mean %d |" % [CardEnums.Rarity.keys()[rarity].capitalize(), prices.size(), prices.min(), prices.max(), _mean_prices[rarity]])
	for pack: PackData in PackCatalog.all():
		parts.append("%s %d" % [pack.display_name, pack.price])
	_lines.append("| Packs | %s |" % ", ".join(parts))
	parts = []
	for entry: EquipmentVendorEntry in EquipmentVendorScreen.default_stock().entries:
		parts.append("%s %d%s" % [_gear_name(entry.equipment_id), entry.price, " (L13)" if entry.unlock != null and entry.unlock.kind == Condition.Kind.PLAYER_LEVEL else ""])
	_lines.append("| Bertram's gear (Crosspath) | %s |" % ", ".join(parts))
	for zone_id: String in ZONES:
		var stock: EquipmentVendorData = ExpansionGear.zone_vendor_stock(zone_id)
		if stock.entries.is_empty():
			continue
		parts = []
		for entry: EquipmentVendorEntry in stock.entries:
			parts.append("%s %d%s" % [_gear_name(entry.equipment_id), entry.price, " (freed)" if entry.unlock != null else ""])
		_lines.append("| Gear, %s | %s |" % [str(ZONE_NAMES[zone_id]), ", ".join(parts)])
	parts = []
	for entry: ItemVendorEntry in ItemVendorScreen.default_stock().entries:
		var item: ItemData = _content.item(entry.item_id)
		parts.append("%s %d%s" % [item.display_name if item != null else entry.item_id, entry.price, " (L6)" if entry.unlock != null else ""])
	_lines.append("| Tilly's items (Crosspath) | %s |" % ", ".join(parts))
	parts = []
	for item: CosmeticData in CosmeticCatalog.all():
		if item.price > 0:
			parts.append("%s %d" % [item.display_name, item.price])
	_lines.append("| Cosmetics (Pip) | %s |" % ", ".join(parts))
	_lines.append("| Alchemist | %d gold + all essence of two Paths (min %d each) |" % [Alchemy.GOLD_COST, Alchemy.MIN_ESSENCE_PER_PATH])
	parts = []
	for zone_id: String in ZONES:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		if def != null:
			parts.append("%s %d" % [str(ZONE_NAMES[zone_id]), def.fee])
	_lines.append("| Zone fee (waking at the hub after a loss) | %s |" % ", ".join(parts))
	_lines.append("| Arena replays | 15 gold paid to the player (a source, not a sink) |")
	_lines.append("| Not in the game | inn / healing for gold, rerolls, selling cards or gear, repairs, upgrades |")
	_lines.append("")


var _mean_prices: Dictionary = {0: 27, 1: 50, 2: 100, 3: 185}


func _gear_name(id: String) -> String:
	var piece: EquipmentData = _content.equipment_piece(id)
	return piece.source_name if piece != null else id


func _price_of_gear(id: String) -> int:
	for entry: EquipmentVendorEntry in EquipmentVendorScreen.default_stock().entries:
		if entry.equipment_id == id:
			return entry.price
	for zone_id: String in ZONES:
		for entry: EquipmentVendorEntry in ExpansionGear.zone_vendor_stock(zone_id).entries:
			if entry.equipment_id == id:
				return entry.price
	return 0


func _price_of_item(id: String) -> int:
	for entry: ItemVendorEntry in ItemVendorScreen.default_stock().entries:
		if entry.item_id == id:
			return entry.price
	return 0


func _price_of_pack(id: String) -> int:
	var pack: PackData = PackCatalog.find(id)
	return pack.price if pack != null else 0


func _price_of_cosmetic(id: String) -> int:
	var item: CosmeticData = CosmeticCatalog.find(id)
	return item.price if item != null else 0


# ---- The timeline -------------------------------------------------------------------------------------------------------------


func _quest_event(id: String, tag: String) -> Event:
	var quest: QuestData = _quests.get(id) as QuestData
	if quest == null:
		return Event.make("quest %s (missing)" % id, tag, 0, 0)
	var event: Event = Event.make("quest: %s" % quest.title, tag, quest.reward_gold, quest.reward_xp)
	event.packs = quest.reward_pack_ids.size()
	return event


func _fight(label: String, tag: String, difficulty: DungeonMap.Difficulty, halved: bool = false) -> Event:
	var gold: int = EncounterRewards.gold_for(difficulty)
	return Event.make(label, tag, gold / 2 if halved else gold, EncounterRewards.xp_for(difficulty))


func _dungeon_steps(dungeon_id: String, zone_id: String, tag_main: String, label: String, expected_level: int) -> Step:
	var step: Step = Step.new()
	step.label = label
	step.zone = zone_id
	step.expected_level = expected_level
	var blueprint: DungeonCatalog.Blueprint = null
	for candidate: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if candidate.id == dungeon_id:
			blueprint = candidate
	if blueprint == null:
		return step
	var loot: Dictionary = _loot_table(dungeon_id)
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var kind: DungeonMap.Kind = DungeonBuilder.kind_of(node.type)
		var tag: String = "dungeon_side" if node.side else tag_main
		if kind == DungeonMap.Kind.TREASURE:
			var entry: Variant = loot.get(str(node.number))
			step.events.append(Event.make("%s treasure" % dungeon_id, tag, int((entry as Dictionary).get("gold", 0)) if entry is Dictionary else 60, int((entry as Dictionary).get("xp", 0)) if entry is Dictionary else 30))
		elif kind == DungeonMap.Kind.BOSS:
			step.events.append(_fight("%s boss" % dungeon_id, tag, DungeonMap.Difficulty.BOSS, true))
		elif kind == DungeonMap.Kind.ELITE:
			step.events.append(_fight("%s elite" % dungeon_id, tag, DungeonMap.Difficulty.ELITE, true))
		elif kind == DungeonMap.Kind.BATTLE:
			step.events.append(_fight("%s battle" % dungeon_id, tag, DungeonMap.Difficulty.NORMAL, true))
	var def: MainDungeonDef = DungeonBuilder.build_def(blueprint)
	var clear: Event = Event.make("%s first clear" % dungeon_id, tag_main, def.reward_gold, def.reward_xp)
	if not blueprint.is_side():
		clear.gold += PackCatalog.config().first_clear_bonus_gold
		clear.xp += PackCatalog.config().first_clear_bonus_xp
		clear.packs = PackCatalog.config().dungeon_pack_count + PackCatalog.config().first_clear_gilded_packs
	else:
		clear.packs = 0
	step.events.append(clear)
	return step


func _chest_events(zone_id: String) -> Array[Event]:
	var result: Array[Event] = []
	var rewards: Dictionary = TownScene.HIDDEN_CHEST_REWARDS if zone_id == "town" else ZoneDefs.get_def(zone_id).chest_rewards
	var keys: Array = rewards.keys()
	keys.sort()
	for key: Variant in keys:
		var reward: Dictionary = rewards[key] as Dictionary
		var event: Event = Event.make("chest %s" % str(key), "chest", int(reward.get("gold", 0)), 0)
		event.packs = 1 if reward.has("pack") else 0
		result.append(event)
	return result


func _roamer_events(zone_id: String, tag: String, spots: int) -> Array[Event]:
	var result: Array[Event] = []
	for kind: String in ROAMERS[zone_id] as Array:
		var info: ZoneEnemyInfo = _roamer(zone_id, kind)
		if info == null:
			continue
		for spot: int in range(spots):
			result.append(Event.make("%s roamer %s" % [str(ZONE_NAMES[zone_id]), info.display_name], tag, info.gold_reward, info.xp_reward))
	return result


func _card_offers(zone_id: String, path_label: String, commons: int, uncommons: int, epics: int, legendaries: int, want_common: int, min_level: int = 0) -> Array[Offer]:
	var result: Array[Offer] = []
	for index: int in range(commons):
		result.append(Offer.make("card_c_%s_%d" % [zone_id, index], "%s Common card" % path_label, "card", int(_mean_prices[0]), want_common, min_level))
	for index: int in range(uncommons):
		result.append(Offer.make("card_u_%s_%d" % [zone_id, index], "%s Uncommon card" % path_label, "card", int(_mean_prices[1]), want_common, min_level))
	for index: int in range(epics):
		result.append(Offer.make("card_e_%s_%d" % [zone_id, index], "%s Epic card" % path_label, "card", int(_mean_prices[2]), ESSENTIAL, min_level))
	for index: int in range(legendaries):
		result.append(Offer.make("card_l_%s_%d" % [zone_id, index], "%s Legendary card" % path_label, "card", int(_mean_prices[3]), NICE, min_level))
	for offer: Offer in result:
		offer.zone = zone_id
	return result


func _item_offer(id: String, want: int, min_level: int = 0) -> Offer:
	var item: ItemData = _content.item(id)
	var offer: Offer = Offer.make("item_%s" % id, item.display_name if item != null else id, "item", _price_of_item(id), want, min_level)
	offer.repeat = true
	return offer


func _gear_offer(id: String, want: int, min_level: int = 5) -> Offer:
	return Offer.make("gear_%s" % id, _gear_name(id), "gear", _price_of_gear(id), want, min_level)


func _pack_offer(id: String, want: int, min_level: int = 0) -> Offer:
	var pack: PackData = PackCatalog.find(id)
	var offer: Offer = Offer.make("pack_%s" % id, pack.display_name if pack != null else id, "pack", _price_of_pack(id), want, min_level)
	offer.repeat = true
	return offer


func _cosmetic_offer(id: String, want: int, min_level: int = 0) -> Offer:
	var item: CosmeticData = CosmeticCatalog.find(id)
	return Offer.make("cos_%s" % id, item.display_name if item != null else id, "cosmetic", _price_of_cosmetic(id), want, min_level)


func _step(label: String, zone: String, expected_level: int, shop: bool = false) -> Step:
	var step: Step = Step.new()
	step.label = label
	step.zone = zone
	step.expected_level = expected_level
	step.shop = shop
	return step


## The story order, with the shops that open at each stop. Levels are `ProgressionModel.LEVELS` where it has a key.
func _build_timeline() -> Array[Step]:
	var steps: Array[Step] = []
	var tutorial: Dictionary = TrialOfTheHollow.total_tutorial_rewards()
	var cave: Step = _step("Forgotten Cave", "town", 1)
	cave.events.append(Event.make("starting gold", "main", 120, 0))
	cave.events.append(Event.make("the cave (3 fights + boss)", "main", int(tutorial["gold"]), int(tutorial["xp"])))
	cave.events.append(Event.make("feat: Leaves in Your Hair + Old Stone", "feat", 35, 0))
	steps.append(cave)
	var arrival: Step = _step("Crosspath arrival (Sable, Tilly, Pip, Bertram)", "town", 1, true)
	arrival.events.append(_quest_event("meet_the_merchants", "main"))
	arrival.events.append(_quest_event("first_deck_edit", "main"))
	arrival.events.append(Event.make("feat: Right Up to My Door", "feat", 10, 0))
	for index: int in range(3):
		arrival.events.append(Event.make("outskirts roamer", "roamer", 13, 31))
	for index: int in range(6):
		arrival.events.append(Event.make("outskirts roamer (again)", "roamer_repeat", 13, 31))
	arrival.offers.append(_item_offer("healing_draught", ESSENTIAL))
	arrival.offers.append(_item_offer("vitality_charm", LUXURY))
	arrival.offers.append(_item_offer("reckless_tonic", NICE))
	arrival.offers.append_array(_card_offers("town", "Sable", 3, 1, 0, 0, NICE))
	arrival.offers.append(_pack_offer("general_1", NICE))
	arrival.offers.append(_cosmetic_offer("hat_wide_brim", LUXURY))
	arrival.offers.append(_cosmetic_offer("hat_chef", LUXURY))
	arrival.offers.append(_cosmetic_offer("hat_bowler", LUXURY))
	steps.append(arrival)
	var storeroom: Step = _step("Store room ghosts, town chests", "town", 3, true)
	storeroom.events.append(Event.make("store room ghosts", "main", 15, 30))
	storeroom.events.append(_quest_event("storeroom_ghosts", "main"))
	storeroom.events.append_array(_chest_events("town"))
	storeroom.events.append(_quest_event("side_s_town", "side_quest"))
	storeroom.offers.append(_item_offer("healing_salve", NICE, 3))
	storeroom.offers.append(_item_offer("firebrand_charm", NICE, 6))
	storeroom.offers.append(_item_offer("scroll_of_insight", LUXURY, 3))
	storeroom.offers.append(_cosmetic_offer("cloak_patchwork", LUXURY, 4))
	steps.append(storeroom)
	var armory: Step = _step("Level 5: the armory opens (Bertram)", "town", 5, true)
	armory.offers.append(_gear_offer("cardboard_cuirass", ESSENTIAL))
	armory.offers.append(_gear_offer("saucepan_helmet", ESSENTIAL))
	armory.offers.append(_gear_offer("extra_pocket", NICE))
	armory.offers.append(_gear_offer("travelers_boots", NICE))
	armory.offers.append(_gear_offer("solid_plate", NICE))
	armory.offers.append(_gear_offer("wicked_dagger", ESSENTIAL))
	armory.offers.append(_gear_offer("xray_goggles", LUXURY))
	armory.offers.append(_cosmetic_offer("hat_tricorn", LUXURY, 5))
	var gate_names: Dictionary = {"beefcake": "Brick Bronson", "necrocrat": "Prudence Pallor", "gourmand": "Chef Gravois", "refusemancer": "Moss Mulligan"}
	# XP Pass Oct 30: the stops' model levels come from ProgressionModel (the zone on arrival, its main dungeon + 2 once freed).
	var zone_levels: Dictionary = {}
	var freed_levels: Dictionary = {}
	for zone_key: String in ZONES:
		zone_levels[zone_key] = ProgressionModel.level_for("zone:%s" % zone_key)
		freed_levels[zone_key] = ProgressionModel.level_for(str(MAIN_DUNGEON[zone_key])) + 2
	var path_labels: Dictionary = {"beefcake": "Beefcake", "necrocrat": "Necrocrat", "gourmand": "Gourmand", "refusemancer": "Refusemancer", "final": "Capital"}
	for zone_id: String in ZONES:
		var zone_name: String = str(ZONE_NAMES[zone_id])
		var level: int = int(zone_levels[zone_id])
		if gate_names.has(zone_id):
			var gate_step: Step = _step("Crosspath: gatekeeper %s" % str(gate_names[zone_id]), "town", maxi(3, level - 2), true)
			var gate: Event = Event.make("gatekeeper %s" % str(gate_names[zone_id]), "main", CorruptedNpcs.reward_gold() + 40, CorruptedNpcs.reward_xp())
			gate.packs = 1
			gate_step.events.append(gate)
			if zone_id == "beefcake":
				gate_step.events.append(Event.make("feat: The Spotter Is Spotted", "feat", 25, 0))
				steps.append(gate_step)
				steps.append(armory)
			else:
				steps.append(gate_step)
		var arrive: Step = _step("%s arrival (roamers, vendor, side quests)" % zone_name, zone_id, level, true)
		arrive.events.append_array(_roamer_events(zone_id, "roamer", ROAMER_SPOTS_PER_KIND))
		if ZONE_ELITE.has(zone_id):
			var elite: ZoneEnemyInfo = _roamer(zone_id, str(ZONE_ELITE[zone_id]))
			if elite != null:
				arrive.events.append(Event.make("%s elite %s" % [zone_name, elite.display_name], "side_quest", elite.gold_reward, elite.xp_reward))
		arrive.events.append_array(_chest_events(zone_id))
		for quest_id: String in ZONE_QUEST_IDS[zone_id] as Array:
			arrive.events.append(_quest_event(quest_id, "side_quest"))
		if int(MINIGAME_FIRST[zone_id]) > 0:
			arrive.events.append(Event.make("%s minigame first clear" % zone_name, "minigame", int(MINIGAME_FIRST[zone_id]), 40))
			arrive.events.append(Event.make("%s minigame repeat" % zone_name, "minigame_repeat", MINIGAME_REPEAT, 20))
		if zone_id == "final":
			arrive.events.append(Event.make("lieutenants' yards", "side_quest", Lieutenants.YARDS_GOLD, 60))
			var rift_total: int = 0
			for rift: Variant in CapitalRifts.all():
				rift_total += int(((rift as Dictionary).get("reward", {}) as Dictionary).get("gold", 0))
			arrive.events.append(Event.make("Capital rifts sealed", "chest", rift_total, 0))
		# Phase 2: the reroll of a world pick (the gatekeeper on the way in, the zone elite) - a repeatable sink priced by level.
		var reroll: Offer = Offer.make("reroll_%s" % zone_id, "Pick reroll (%s)" % zone_name, "reroll", Economy.reroll_price(level), NICE)
		reroll.repeat = true
		arrive.offers.append(reroll)
		var zone_fee: ZoneDef = ZoneDefs.get_def(zone_id)
		var fee: Offer = Offer.make("fee_%s" % zone_id, "%s hub fee (a loss)" % zone_name, "fee", zone_fee.fee if zone_fee != null else 15, ESSENTIAL)
		arrive.offers.append(fee)
		if zone_id != "final":
			arrive.offers.append_array(_card_offers(zone_id, str(path_labels[zone_id]), 5, 2, 0, 0, NICE))
			for entry: EquipmentVendorEntry in ExpansionGear.zone_vendor_stock(zone_id).entries:
				if entry.unlock == null:
					arrive.offers.append(_gear_offer(entry.equipment_id, NICE))
		if zone_id == "beefcake":
			arrive.offers.append(_item_offer("binding_chains", NICE, 6))
			arrive.offers.append(_cosmetic_offer("hat_wizard", LUXURY, 7))
			arrive.offers.append(_cosmetic_offer("cloak_red_cape", LUXURY, 7))
		steps.append(arrive)
		var side: Step = _dungeon_steps(str(SIDE_DUNGEON[zone_id]), zone_id, "side_dungeon", "%s side dungeon (%s)" % [zone_name, str(SIDE_DUNGEON[zone_id])], ProgressionModel.level_for(str(SIDE_DUNGEON[zone_id])))
		side.events.append(Event.make("feat: side dungeon", "feat", 25, 0))
		steps.append(side)
		if zone_id == "beefcake":
			var vault: Step = _dungeon_steps("S-TOWN", "town", "side_dungeon", "The Forgotten Vault (S-TOWN)", ProgressionModel.level_for("S-TOWN"))
			vault.events.append(Event.make("feat: Four Banners", "feat", 25, 0))
			steps.append(vault)
			var graveyard: Step = _step("Crosspath: the Graveyard, arena tier 1", "town", ProgressionModel.level_for("town:graveyard"), true)
			graveyard.events.append(Event.make("the Restless Dead", "side_quest", GraveyardBoss.REWARD_GOLD, EncounterRewards.xp_for(DungeonMap.Difficulty.ELITE)))
			steps.append(graveyard)
		var main: Step = _dungeon_steps(str(MAIN_DUNGEON[zone_id]), zone_id, "main", "%s main dungeon (%s)" % [zone_name, str(MAIN_DUNGEON[zone_id])], ProgressionModel.level_for(str(MAIN_DUNGEON[zone_id])))
		# Phase 2: the dungeon's elite and boss picks reroll too (two rerolls a dungeon for the player who wants them).
		var dungeon_reroll: Offer = Offer.make("reroll_dungeon_%s" % zone_id, "Pick reroll (%s dungeon)" % zone_name, "reroll", Economy.reroll_price(ProgressionModel.level_for(str(MAIN_DUNGEON[zone_id]))), NICE)
		dungeon_reroll.repeat = true
		main.offers.append(dungeon_reroll)
		main.shop = true
		if MAIN_QUEST_IDS.has(zone_id):
			main.events.append(_quest_event(str(MAIN_QUEST_IDS[zone_id]), "main"))
			main.events.append(Event.make("feat: zone freed", "feat", 50, 0))
		steps.append(main)
		if zone_id != "final":
			var freed: Step = _step("%s freed: vendor's second tier, Path Pack stall, hub" % zone_name, zone_id, int(freed_levels[zone_id]), true)
			freed.events.append(Event.make("main dungeon repeat clear", "repeat_clear", DungeonBuilder.MAIN_REPEAT_GOLD, 120))
			freed.events.append_array(_roamer_events(zone_id, "roamer_repeat", 1))
			freed.offers.append_array(_card_offers(zone_id + "_freed", str(path_labels[zone_id]), 0, 3, 1, 0, NICE))
			for entry: EquipmentVendorEntry in ExpansionGear.zone_vendor_stock(zone_id).entries:
				if entry.unlock != null:
					freed.offers.append(_gear_offer(entry.equipment_id, NICE))
			freed.offers.append(_pack_offer("path_%s" % zone_id, NICE))
			if zone_id == "beefcake":
				freed.offers.append(_pack_offer("gilded_beefcake", LUXURY))
				freed.offers.append(Offer.make("alchemy_1", "Alchemist brew", "alchemy", Alchemy.GOLD_COST, LUXURY, 12))
				freed.offers.append(_cosmetic_offer("hat_leaf_crown", LUXURY, 13))
				freed.offers.append(_cosmetic_offer("cloak_tattered", LUXURY, 13))
				for index: int in range(2):
					freed.events.append(Event.make("arena tier 1 clear", "arena", 100, 40))
			if zone_id == "necrocrat":
				freed.offers.append(_pack_offer("general_2", NICE, 10))
				freed.events.append(Event.make("arena tier 2 clear", "arena", 150, 80))
				freed.events.append(Event.make("the Ninja's chests", "secret", 0, 0))
			if zone_id == "gourmand":
				freed.offers.append(_gear_offer("flamethrower", ESSENTIAL, 13))
				freed.offers.append(_gear_offer("big_brain_beret", NICE, 13))
				freed.offers.append(_gear_offer("cheaters_dice", LUXURY, 13))
				freed.offers.append(_gear_offer("hover_boots", LUXURY, 13))
				freed.offers.append(_gear_offer("thorned_loincloth", LUXURY, 13))
				freed.offers.append(_pack_offer("gilded_gourmand", LUXURY))
				freed.offers.append(Offer.make("alchemy_2", "Alchemist brew", "alchemy", Alchemy.GOLD_COST, LUXURY, 15))
			if zone_id == "refusemancer":
				freed.events.append(_quest_event("secret_old_well", "secret"))
				freed.events.append(Event.make("feat: Four Paths, One Kingdom", "feat", 0, 0))
				freed.events.append(_quest_event("fragments", "main"))
				freed.offers.append(_pack_offer("gilded_refusemancer", LUXURY))
				freed.offers.append(Offer.make("alchemy_3", "Alchemist brew", "alchemy", Alchemy.GOLD_COST, LUXURY, 18))
			steps.append(freed)
	var castle: Step = _step("The Capital: arena tier 3, Secret Dealer era", "final", ProgressionModel.level_for("arena:3"), true)
	castle.events.append(Event.make("arena tier 3 clear", "arena", 200, 120))
	castle.events.append(Event.make("arena: the Marshal", "arena", 500, 250))
	castle.events.append(_quest_event("free_the_kingdom", "main"))
	castle.events.append(Event.make("feat: Sorry About the Hats + A Name", "feat", 150, 0))
	castle.offers.append(_pack_offer("prismatic", LUXURY, 22))
	castle.offers.append(_cosmetic_offer("cloak_royal", LUXURY, 22))
	castle.offers.append_array(_card_offers("postgame", "postgame Legendary", 0, 0, 0, 2, NICE, 22))
	castle.offers.append(Offer.make("alchemy_4", "Alchemist brew", "alchemy", Alchemy.GOLD_COST, LUXURY, 22))
	steps.append(castle)
	var postgame: Step = _step("Postgame: Mount Swolympus, the Vault, the Lab, Paste Works", "final", 24, true)
	postgame.events.append_array(_dungeon_steps("S-BEEF", "beefcake", "postgame", "", 22).events)
	postgame.events.append_array(_dungeon_steps("S-PASTE", "gourmand", "postgame", "", 19).events)
	postgame.events.append_array(_dungeon_steps("D-LAB", "final", "postgame", "", 26).events)
	postgame.events.append(Event.make("the Four-Seal Vault", "postgame", 0, 120))
	postgame.events.append(Event.make("feats: One More Rep, Took You Long Enough, Hardest Duel", "feat", 250, 0))
	postgame.events.append(Event.make("collection 50%", "feat", 200, 0))
	for zone_id: String in ZONES:
		postgame.events.append(Event.make("%s main dungeon repeat" % str(ZONE_NAMES[zone_id]), "repeat_clear", DungeonBuilder.MAIN_REPEAT_GOLD, 120))
	postgame.offers.append_array(_card_offers("postgame_epics", "late Epic (Black Market / shelves)", 0, 0, 4, 0, NICE, 22))
	steps.append(postgame)
	return steps


# ---- Profiles -------------------------------------------------------------------------------------------------------------------


func _profiles() -> Array[Profile]:
	var rusher: Profile = Profile.new()
	rusher.name = "rusher"
	rusher.takes = {"main": 1.0, "roamer": 0.34, "feat": 0.5, "repeat_clear": 0.0}
	rusher.min_want = ESSENTIAL
	rusher.flush = 400
	rusher.reserve = 0
	rusher.packs_per_stop = 0
	rusher.fee_per_zone = 1
	var expected: Profile = Profile.new()
	expected.name = "expected"
	expected.takes = {"main": 1.0, "roamer": 1.0, "roamer_repeat": 0.34, "chest": 0.5, "side_quest": 0.67, "side_dungeon": 1.0, "dungeon_side": 0.5, "minigame": 1.0, "arena": 0.5, "feat": 0.75, "secret": 0.5, "postgame": 1.0, "repeat_clear": 0.0}
	expected.min_want = NICE
	expected.flush = 300
	expected.reserve = 30
	expected.packs_per_stop = 1
	expected.fee_per_zone = 1
	var thorough: Profile = Profile.new()
	thorough.name = "thorough"
	thorough.takes = {"main": 1.0, "roamer": 1.0, "roamer_repeat": 1.0, "chest": 1.0, "side_quest": 1.0, "side_dungeon": 1.0, "dungeon_side": 1.0, "minigame": 1.0, "minigame_repeat": 1.0, "arena": 1.0, "feat": 1.0, "secret": 1.0, "postgame": 1.0, "repeat_clear": 1.0}
	thorough.min_want = LUXURY
	thorough.flush = 150
	thorough.reserve = 20
	thorough.packs_per_stop = 2
	thorough.fee_per_zone = 0
	return [rusher, expected, thorough]


func _takes(profile: Profile, tag: String, index: int) -> bool:
	var fraction: float = float(profile.takes.get(tag, 0.0))
	if fraction <= 0.0:
		return false
	if fraction >= 1.0:
		return true
	return floori(float(index + 1) * fraction) > floori(float(index) * fraction)


# ---- The walk ---------------------------------------------------------------------------------------------------------------------


func _simulate(profile: Profile, steps: Array[Step]) -> void:
	var state: RunState = RunState.new()
	var tag_counters: Dictionary = {}
	var step_index: int = 0
	for step: Step in steps:
		step_index += 1
		var gold_in: int = 0
		var xp_in: int = 0
		var packs_before: int = state.packs
		var taken: PackedStringArray = []
		for event: Event in step.events:
			var count: int = int(tag_counters.get(event.tag, 0))
			tag_counters[event.tag] = count + 1
			if not _takes(profile, event.tag, count):
				continue
			gold_in += event.gold
			xp_in += event.xp
			state.packs += event.packs
			state.income[event.tag] = int(state.income.get(event.tag, 0)) + event.gold
			if event.gold > 0 or event.xp > 0:
				taken.append(event.label)
		state.gold += gold_in
		var level_before: int = state.level
		var xp_before: int = state.xp
		state.xp += xp_in
		state.level = ProgressionTable.level_for_xp(state.xp)
		var level_gold: int = 0
		for level: int in range(level_before + 1, state.level + 1):
			for grant: Variant in LevelTrack.level_entry(level).get("grants", []) as Array:
				var kind: String = str((grant as Dictionary).get("kind", ""))
				if kind == "gold":
					level_gold += int((grant as Dictionary).get("amount", 0))
				elif kind == "pack":
					state.packs += 1
		state.gold += level_gold
		state.income["level_track"] = int(state.income.get("level_track", 0)) + level_gold
		# Essence: a rough guess - from the moment a Path's zone is freed, each pack and shelf card of that Path starts to duplicate.
		if step.label.find("freed") >= 0:
			state.zones_freed += 1
		state.essence += (state.packs - packs_before) * mini(4, state.zones_freed) / 2
		var stock_cost: int = 0
		for offer: Offer in step.offers:
			if offer.sink != "fee" and offer.want >= NICE:
				stock_cost += offer.price
			if offer.sink == "fee":
				if profile.fee_per_zone > 0:
					var paid: int = mini(state.gold, offer.price * profile.fee_per_zone)
					state.gold -= paid
					state.spend["fee"] = int(state.spend.get("fee", 0)) + paid
				continue
			state.open_offers.append(offer)
		var bought: PackedStringArray = []
		var spent: int = 0
		var affordable_unbought: int = 0
		var wanted_unaffordable: PackedStringArray = []
		if step.shop:
			var packs_bought: int = 0
			var items_bought: int = 0
			var progress: bool = true
			while progress:
				progress = false
				var best: Offer = null
				for offer: Offer in state.open_offers:
					if offer.price <= 0 or state.level < offer.min_level:
						continue
					if offer.bought > 0 and not offer.repeat:
						continue
					if offer.sink == "pack" and packs_bought >= profile.packs_per_stop:
						continue
					if offer.sink == "item" and offer.bought > 0 and items_bought >= 2:
						continue
					if offer.sink == "reroll" and offer.bought >= 2:
						continue  # about two picks rerolled per zone
					if offer.sink == "alchemy" and state.essence < Alchemy.MIN_ESSENCE_PER_PATH * 2:
						continue
					var wants: bool = offer.want >= profile.min_want or (offer.want == profile.min_want - 1 and state.gold - offer.price >= profile.flush)
					if not wants:
						continue
					if state.gold - offer.price < profile.reserve:
						continue
					if best == null or offer.want > best.want or (offer.want == best.want and offer.price > best.price):
						best = offer
				if best != null:
					state.gold -= best.price
					spent += best.price
					best.bought += 1
					if best.sink == "pack":
						packs_bought += 1
						state.packs += 1
					if best.sink == "item":
						items_bought += 1
					state.spend[best.sink] = int(state.spend.get(best.sink, 0)) + best.price
					bought.append("%s %d" % [best.label, best.price])
					progress = true
			for offer: Offer in state.open_offers:
				if offer.price <= 0 or state.level < offer.min_level or (offer.bought > 0 and not offer.repeat) or offer.sink == "fee":
					continue
				if offer.want < profile.min_want - 1:
					continue
				if offer.price <= state.gold:
					if offer.want >= profile.min_want:
						affordable_unbought += 1
				else:
					wanted_unaffordable.append("%s %d" % [offer.label, offer.price])
					if not state.unaffordable_since.has(offer.id):
						state.unaffordable_since[offer.id] = step_index
			for offer: Offer in state.open_offers:
				if offer.bought > 0 and state.unaffordable_since.has(offer.id):
					state.waits.append({"label": offer.label, "price": offer.price, "stops": step_index - int(state.unaffordable_since[offer.id])})
					state.unaffordable_since.erase(offer.id)
			if bought.is_empty() and not wanted_unaffordable.is_empty():
				state.droughts.append("%s (gold %d, wanted: %s)" % [step.label, state.gold, ", ".join(wanted_unaffordable.slice(0, 3))])
			if wanted_unaffordable.is_empty() and state.gold >= 2 * maxi(150, _priciest_open(state)):
				state.hoards.append("%s (gold %d, nothing left to want)" % [step.label, state.gold])
		var row: Dictionary = {
			"step": step.label, "zone": step.zone, "expected_level": step.expected_level, "level": state.level, "gold_in": gold_in + level_gold,
			"spent": spent, "gold": state.gold, "bought": ", ".join(bought), "fights": taken.size(), "packs": state.packs, "essence": state.essence,
			"unaffordable": ", ".join(wanted_unaffordable.slice(0, 4)), "affordable_unbought": affordable_unbought, "stock_cost": stock_cost, "gold_before": state.gold + spent,
		}
		state.rows.append(row)
		if not _timelines.has(profile.name):
			_timelines[profile.name] = []
			_timeline_order.append(profile.name)
		(_timelines[profile.name] as Array).append({"step": step.label, "model": step.expected_level, "xp_before": xp_before, "xp_after": state.xp})
	_write_profile(profile, state)


func _priciest_open(state: RunState) -> int:
	var top: int = 0
	for offer: Offer in state.open_offers:
		if offer.bought == 0 or offer.repeat:
			top = maxi(top, offer.price)
	return top


func _write_profile(profile: Profile, state: RunState) -> void:
	_lines.append("## Profile: %s" % profile.name)
	_lines.append("")
	var takes: PackedStringArray = []
	for key: Variant in profile.takes.keys():
		takes.append("%s %d%%" % [str(key), int(round(float(profile.takes[key]) * 100.0))])
	_lines.append("Takes: %s. Buys want >= %d outright, one level lower when %d gold would stay; reserve %d; packs per stop %d." % [", ".join(takes), profile.min_want, profile.flush, profile.reserve, profile.packs_per_stop])
	_lines.append("")
	_lines.append("| # | Stop | Zone | Model L | Expected L | Gold in | New stock (want 2+) | Gold at the shop | Spent | Gold after | Bought | Wanted, not affordable | Afford. unbought |")
	_lines.append("|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---:|")
	var index: int = 0
	for row: Dictionary in state.rows:
		index += 1
		_lines.append("| %d | %s | %s | %d | %d | %d | %d | %d | %d | %d | %s | %s | %d |" % [index, str(row["step"]), str(row["zone"]), int(row["level"]), int(row["expected_level"]), int(row["gold_in"]), int(row["stock_cost"]), int(row["gold_before"]), int(row["spent"]), int(row["gold"]), str(row["bought"]), str(row["unaffordable"]), int(row["affordable_unbought"])])
	_lines.append("")
	var total_in: int = 0
	var income_parts: PackedStringArray = []
	var income_keys: Array = state.income.keys()
	income_keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(state.income[a]) > int(state.income[b]))
	for key: Variant in income_keys:
		total_in += int(state.income[key])
		income_parts.append("%s %d" % [str(key), int(state.income[key])])
	var total_out: int = 0
	var spend_parts: PackedStringArray = []
	var spend_keys: Array = state.spend.keys()
	spend_keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(state.spend[a]) > int(state.spend[b]))
	for key: Variant in spend_keys:
		total_out += int(state.spend[key])
		spend_parts.append("%s %d" % [str(key), int(state.spend[key])])
	_lines.append("- **Income %d**: %s." % [total_in, ", ".join(income_parts)])
	_lines.append("- **Spent %d** (%d%% of income): %s. Left over: %d. Packs received or bought: %d; essence (rough): %d." % [total_out, int(round(100.0 * float(total_out) / float(maxi(1, total_in)))), ", ".join(spend_parts), state.gold, state.packs, state.essence])
	var unused: PackedStringArray = []
	for sink: String in ["item", "gear", "card", "pack", "cosmetic", "alchemy", "reroll"]:
		if int(state.spend.get(sink, 0)) == 0:
			unused.append(sink)
	_lines.append("- **Sinks never used**: %s." % (", ".join(unused) if not unused.is_empty() else "none"))
	_lines.append("- **Droughts** (a shop stop with wants but nothing bought): %s" % ("none" if state.droughts.is_empty() else ""))
	for drought: String in state.droughts:
		_lines.append("  - %s" % drought)
	_lines.append("- **Hoarding** (gold at twice the priciest open want): %s" % ("none" if state.hoards.is_empty() else ""))
	for hoard: String in state.hoards:
		_lines.append("  - %s" % hoard)
	if not state.waits.is_empty():
		var wait_parts: PackedStringArray = []
		for wait: Dictionary in state.waits:
			if int(wait["stops"]) >= 2:
				wait_parts.append("%s (%d) %d stops" % [str(wait["label"]), int(wait["price"]), int(wait["stops"])])
		_lines.append("- **Waited for** (stops between first wanting and buying): %s." % (", ".join(wait_parts) if not wait_parts.is_empty() else "nothing over one stop"))
	var never: PackedStringArray = []
	for offer: Offer in state.open_offers:
		if offer.bought == 0 and offer.want >= profile.min_want and offer.sink != "fee":
			never.append("%s %d" % [offer.label, offer.price])
	_lines.append("- **Wanted but never bought**: %s." % (", ".join(never) if not never.is_empty() else "nothing"))
	_lines.append("")


# ---- Level timeline (XP Pass Oct 30) ------------------------------------------------------------------------------------------


## The curve before the XP pass (Oct 17 - Oct 29): 15 L (L - 1) to 20, then 27 (L - 20)(L - 19) on top. Kept here so the timeline
## shows both curves side by side.
static func _old_xp_to_reach(level: int) -> int:
	if level <= 1:
		return 0
	var capped: int = mini(level, 20)
	var total: int = 15 * capped * (capped - 1)
	if level > 20:
		total += 27 * (level - 20) * (level - 19)
	return total


static func _old_level_for_xp(total_xp: int) -> int:
	var level: int = 1
	for candidate: int in range(2, ProgressionTable.MAX_LEVEL + 1):
		if total_xp >= _old_xp_to_reach(candidate):
			level = candidate
		else:
			break
	return level


## Per stop and profile: the XP and level on arrival (before the stop's own XP) and on leaving, under the old curve and the
## current `ProgressionTable`, beside the progression model's level for that stop.
func _write_level_timeline() -> void:
	if _timeline_order.is_empty():
		return
	_lines.append("## Level timeline (arrival -> leaving; old curve | current curve)")
	_lines.append("")
	_lines.append("XP is what the timeline really pays each profile (quests, gatekeepers, roamers, dungeon nodes and bosses, first clears, arena, minigames). \"Model\" is the progression model's level for the stop (`ProgressionModel`, the encounter bands).")
	_lines.append("")
	var header: String = "| # | Stop | Model |"
	var rule: String = "|---:|---|---:|"
	for name: String in _timeline_order:
		header += " %s XP | %s old | %s now |" % [name, name, name]
		rule += "---:|---:|---:|"
	_lines.append(header)
	_lines.append(rule)
	var count: int = (_timelines[_timeline_order[0]] as Array).size()
	for index: int in range(count):
		var first: Dictionary = (_timelines[_timeline_order[0]] as Array)[index]
		var line: String = "| %d | %s | %d |" % [index + 1, str(first["step"]), int(first["model"])]
		for name: String in _timeline_order:
			var row: Dictionary = (_timelines[name] as Array)[index]
			var before: int = int(row["xp_before"])
			var after: int = int(row["xp_after"])
			line += " %d -> %d | %d -> %d | %d -> %d |" % [before, after, _old_level_for_xp(before), _old_level_for_xp(after), ProgressionTable.level_for_xp(before), ProgressionTable.level_for_xp(after)]
		_lines.append(line)
	_lines.append("")
	_lines.append("XP to reach each level (old | current):")
	_lines.append("")
	_lines.append("| Level | Old | Old step | Current | Current step |")
	_lines.append("|---:|---:|---:|---:|---:|")
	for level: int in range(2, ProgressionTable.MAX_LEVEL + 1):
		_lines.append("| %d | %d | %d | %d | %d |" % [level, _old_xp_to_reach(level), _old_xp_to_reach(level) - _old_xp_to_reach(level - 1), ProgressionTable.xp_to_reach(level), ProgressionTable.xp_to_reach(level) - ProgressionTable.xp_to_reach(level - 1)])
	_lines.append("")
