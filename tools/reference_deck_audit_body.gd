extends RefCounted
## Overnight Oct 22, Part 1: checks every card of the balance sim's reference-deck packages (`ProgressionModel.UPGRADES`) against what a
## player can really own at that level under the Oct 22 shops (docs/design/vendors.md): the Path zone's shelf (Commons + two Uncommons on
## arrival, the rest after the zone's boss, Legendaries in the postgame), the dungeon prizes, else only packs. Prints a markdown table.
## Run: Godot --headless --path . -s res://tools/reference_deck_audit.gd [-- --out=res://x.md]

const HOME: Dictionary = {"beefcake": ["zone:beefcake", "D-HOG"], "necrocrat": ["zone:necrocrat", "D-HFA"], "gourmand": ["zone:gourmand", "D-TTK"], "refusemancer": ["zone:refusemancer", "D-ROT"]}
const PRIZES: Dictionary = {"B-32": "D-HOG", "N-33": "D-HFA", "G-33": "D-TTK", "R-33": "D-ROT", "N-30": "S-NECRO", "B-30": "S-BEEF", "G-27": "S-GOUR", "R-27": "S-REF"}


func run() -> void:
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	var content: ContentSet = ContentLibrary.load_all()
	var curated: Dictionary = {"beefcake": ZoneCards.GAINLANDS_VENDOR_IDS, "necrocrat": ZoneCards.VENDOR_IDS, "gourmand": ZoneCards.BUFFET_VENDOR_IDS, "refusemancer": ZoneCards.HEAP_VENDOR_IDS}
	var lines: PackedStringArray = []
	lines.append("| Path | Package L | Card | Rarity | Earliest owned (shelf / prize) | Verdict |")
	lines.append("|---|---:|---|---|---|---|")
	for path: Affinity.Type in Affinity.colored_types():
		var zone_id: String = Affinity.display_name(path).to_lower()
		var home: Array = HOME[zone_id] as Array
		var arrive: int = ProgressionModel.level_for(str(home[0]))
		var freed: int = ProgressionModel.level_for(str(home[1]))
		var shelf: VendorData = VendorStocks.zone_shelf(content, path, zone_id, curated[zone_id] as Array[String], "x")
		var packages: Dictionary = ProgressionModel.UPGRADES[path] as Dictionary
		var levels: Array = packages.keys()
		levels.sort()
		for at: Variant in levels:
			for id: Variant in (packages[at] as Dictionary).keys():
				var card: CardData = content.card(str(id))
				if card == null:
					continue
				var earliest: int = -1
				var how: String = "packs only"
				if PRIZES.has(str(id)):
					earliest = ProgressionModel.level_for(str(PRIZES[str(id)]))
					how = "prize %s" % str(PRIZES[str(id)])
				else:
					for level: int in range(1, 31):
						var state: UnlockState = UnlockState.new()
						state.player_level = level
						state.postgame = level >= 21
						if level >= freed:
							state.flags[str(ZoneCompletion.flag_name(zone_id))] = true
						if level >= arrive and shelf.available_card_ids(state).has(card.id):
							earliest = level
							how = "shelf"
							break
				# Before the shelf: Sable's rotating sample (a Common of each Path and Colorless Commons per shelf), the level track's own-Path
				# Packs from 4 (Commons and Uncommons), the Black Market (Capital, 19+), the Capital quests' unique Epics (22).
				var packable: bool = not card.not_in_packs and not card.is_signature and not CapitalContent.BLACK_MARKET_CARD_IDS.has(card.id)
				if CapitalContent.BLACK_MARKET_CARD_IDS.has(card.id):
					earliest = 19
					how = "Black Market"
				elif CapitalContent.QUEST_REWARD_IDS.has(card.id):
					earliest = 22
					how = "Capital quest"
				elif (earliest < 0 or earliest > int(at)) and packable and card.rarity == CardEnums.Rarity.COMMON:
					earliest = 1
					how = "Sable's rotating sample"
				elif (earliest < 0 or earliest > int(at)) and packable and card.rarity == CardEnums.Rarity.UNCOMMON and int(at) >= 4:
					earliest = 4
					how = "own-Path Pack (level track)"
				var verdict: String = "ok" if earliest > 0 and earliest <= int(at) else "NOT YET"
				var rarity: String = str(CardEnums.Rarity.keys()[card.rarity]).capitalize()
				lines.append("| %s | %d | %s %s | %s%s | %s | %s |" % [Affinity.display_name(path), int(at), card.id, card.display_name, rarity,
					" (signature)" if card.is_signature else "", ("%s at L%d" % [how, earliest]) if earliest > 0 else how, verdict])
	var text: String = "\n".join(lines) + "\n"
	print(text)
	if not out.is_empty():
		var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
		file.store_string(text)
		file.close()
