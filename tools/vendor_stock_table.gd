extends SceneTree
## UI + economy fixes Oct 22, Part 5: prints the card vendors' shelves (Sable at several points of a run, each Path zone's tiers) as
## markdown for docs/design/vendors.md. Run: Godot --headless --path . -s res://tools/vendor_stock_table.gd [-- --out=res://x.md]


func _initialize() -> void:
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	var content: ContentSet = ContentLibrary.load_all()
	var lines: PackedStringArray = []
	var gate: Condition = Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME)
	lines.append("### Sable's shelf at points of a run (one rotation each; Path in brackets, rarity C/U/E)")
	lines.append("")
	lines.append("| Point | Cards | Shelf |")
	lines.append("|---|---:|---|")
	for point: Array in [["Level 1 (after the cave)", 1, 0], ["Level 3", 3, 0], ["Level 5", 5, 0], ["Level 9, one zone freed", 9, 1], ["Level 17, three zones", 17, 3], ["Level 27, postgame", 27, 4]]:
		var state: UnlockState = _state(int(point[1]), int(point[2]))
		var shelf: VendorData = VendorStocks.sable_sample(content, state, gate)
		var ids: Array[String] = shelf.available_card_ids(state)
		lines.append("| %s | %d | %s |" % [str(point[0]), ids.size(), _names(content, ids)])
	lines.append("")
	lines.append("### Path zone shelves")
	lines.append("")
	lines.append("| Zone | Opening (first visit) | + after the boss | + postgame |")
	lines.append("|---|---|---|---|")
	var curated: Dictionary = {"beefcake": ZoneCards.GAINLANDS_VENDOR_IDS, "necrocrat": ZoneCards.VENDOR_IDS, "gourmand": ZoneCards.BUFFET_VENDOR_IDS, "refusemancer": ZoneCards.HEAP_VENDOR_IDS}
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		var path: Affinity.Type = PackRules.path_for_zone(zone_id)
		var shelf: VendorData = VendorStocks.zone_shelf(content, path, zone_id, curated[zone_id] as Array[String], zone_id)
		var opening: Array[String] = shelf.available_card_ids(_state(5, 0))
		var freed: Array[String] = shelf.available_card_ids(_state(12, 1, {str(ZoneCompletion.flag_name(zone_id)): true}))
		var late: Array[String] = shelf.available_card_ids(_state(30, 4, {str(ZoneCompletion.flag_name(zone_id)): true}, true))
		lines.append("| %s (%d / %d / %d) | %s | %s | %s |" % [Affinity.display_name(path), opening.size(), freed.size(), late.size(), _names(content, opening), _names(content, _minus(freed, opening)), _names(content, _minus(late, freed))])
	var text: String = "\n".join(lines) + "\n"
	print(text)
	if out != "":
		var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
		file.store_string(text)
	quit(0)


func _state(level: int, zones: int, flags: Dictionary = {}, postgame: bool = false) -> UnlockState:
	var state: UnlockState = UnlockState.new()
	state.player_level = level
	state.zones_completed = zones
	state.flags = flags
	state.postgame = postgame
	state.cleared_dungeons = [TrialOfTheHollow.DUNGEON_NAME] as Array[String]
	return state


func _minus(all: Array[String], taken: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for id: String in all:
		if not taken.has(id):
			result.append(id)
	return result


func _names(content: ContentSet, ids: Array[String]) -> String:
	var parts: PackedStringArray = []
	for id: String in ids:
		var card: CardData = content.card(id)
		var path_text: String = "" if card.paths().is_empty() else " [%s]" % Affinity.display_name(card.paths()[0])
		parts.append("%s%s %s" % [card.display_name, path_text, "CUEL"[int(card.rarity)]])
	return ", ".join(parts) if not parts.is_empty() else "-"
