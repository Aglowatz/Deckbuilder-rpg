extends SceneTree
## Nov 2 pass, Part 4: how much one consumable is worth in a fight. For every encounter of a filter (EncounterCatalog, e.g. zone:beefcake)
## the expected player of each Path (ProgressionModel, --level overrides) plays `games` games with NO items, then with one charge of each
## item variant below; the table shows the win rate and the lift per variant. Variants that do not exist in the game are built here
## (Draw 1, the Field Bandage reworks (now Power Wraps), the high shelf retunes) so the choice is made on numbers.
##   Godot --headless --path . -s res://tools/item_sim.gd -- --filter=zone:beefcake --level=6 --games=16 --variants=insight --out=res://docs/design/sim/items_nov2_low.md
## --variants: all | low | high | insight | bandage | tonic | <comma list of variant keys>

var args: Dictionary = {}


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var ok: bool = _run()
	quit(0 if ok else 1)


func _item(id: String, name: String, uses: int, op: CardEnums.EffectOp, amount: int, amount2: int = 0, duration: CardEnums.Duration = CardEnums.Duration.PERMANENT, target: CardEnums.TargetKind = CardEnums.TargetKind.CONTROLLER, keyword: int = -1, token: CardData = null) -> ItemData:
	var item: ItemData = ItemData.new()
	item.id = id
	item.display_name = name
	item.uses = uses
	var effect: EffectData = EffectData.new()
	effect.trigger = CardEnums.Trigger.ON_ENTER
	effect.op = op
	effect.amount = amount
	effect.amount2 = amount2
	effect.duration = duration
	effect.target = target
	if keyword >= 0:
		effect.keyword = keyword as CardEnums.Keyword
	if token != null:
		effect.token = token
	item.effect = effect
	return item


## A reckless variant: backfires (1 damage to the user instead) with `chance`.
func _backfire(item: ItemData, chance: float) -> ItemData:
	item.backfire_chance = chance
	item.backfire_damage = 1
	return item


## variant key -> ItemData (the id the sim equips; a variant of a shop item keeps that id so the policy treats it the same way)
func _variants(content: ContentSet, group: String) -> Dictionary:
	var militia: CardData = content.tokens.get("T-16") as CardData
	var all: Dictionary = {
		# the low shelf as it is
		"draught_3x3": _item("healing_draught", "Healing Draught (3 HP)", 3, CardEnums.EffectOp.GAIN_HP, 3),
		"vitality_2": _item("vitality_charm", "Vitality Charm (2 HP)", 2, CardEnums.EffectOp.GAIN_HP, 2),
		"tonic_5": _item("reckless_tonic", "Reckless Tonic (5 HP)", 1, CardEnums.EffectOp.GAIN_HP, 5),
		"tonic_7": _item("reckless_tonic", "Reckless Tonic (7 HP)", 1, CardEnums.EffectOp.GAIN_HP, 7),
		# Overnight Nov 2-3, Part 2: the reckless tonic heals 5 or backfires for 1 damage (odds 1 in 6 / 4 / 3)
		"tonic_5_b6": _backfire(_item("reckless_tonic", "Reckless Tonic (5 HP, 1 in 6 backfires)", 1, CardEnums.EffectOp.GAIN_HP, 5), 1.0 / 6.0),
		"tonic_5_b4": _backfire(_item("reckless_tonic", "Reckless Tonic (5 HP, 1 in 4 backfires)", 1, CardEnums.EffectOp.GAIN_HP, 5), 0.25),
		"tonic_5_b3": _backfire(_item("reckless_tonic", "Reckless Tonic (5 HP, 1 in 3 backfires)", 1, CardEnums.EffectOp.GAIN_HP, 5), 1.0 / 3.0),
		"salve_4": _item("healing_salve", "Healing Salve (4 HP)", 3, CardEnums.EffectOp.GAIN_HP, 4),
		"bandage_heal3": _item("power_wraps", "Power Wraps (mend 3)", 3, CardEnums.EffectOp.HEAL, 3, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
		"bandage_0_3_turn": _item("power_wraps", "Power Wraps (+0/+3 this turn)", 3, CardEnums.EffectOp.BUFF, 0, 3, CardEnums.Duration.END_OF_TURN, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
		"bandage_0_2_perm": _item("power_wraps", "Power Wraps (+0/+2 for the battle)", 3, CardEnums.EffectOp.BUFF, 0, 2, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
		"bandage_1_1_perm": _item("power_wraps", "Power Wraps (+1/+1 for the battle)", 3, CardEnums.EffectOp.BUFF, 1, 1, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
		"insight_draw2": _item("scroll_of_insight", "Scroll of Insight (draw 2)", 2, CardEnums.EffectOp.DRAW, 2),
		"insight_draw1": _item("scroll_of_insight", "Scroll of Insight (draw 1)", 2, CardEnums.EffectOp.DRAW, 1),
		"firebrand_2": _item("firebrand_charm", "Firebrand Charm (2 dmg)", 2, CardEnums.EffectOp.DEAL_DAMAGE, 2, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ENEMY),
		"stone_2_2": _item("sharpening_stone", "Sharpening Stone (+2/+2 turn)", 3, CardEnums.EffectOp.BUFF, 2, 2, CardEnums.Duration.END_OF_TURN, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
		# the high shelf as it is, and retuned
		"chains_1": _item("binding_chains", "Binding Chains (send back)", 1, CardEnums.EffectOp.SEND_BACK, 0, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ENEMY),
		"silence_1": _item("silence_powder", "Silence Powder (toss 1)", 2, CardEnums.EffectOp.TOSS, 1, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.OPPONENT),
		"silence_2": _item("silence_powder", "Silence Powder (toss 2)", 2, CardEnums.EffectOp.TOSS, 2, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.OPPONENT),
		"dust_3": _item("grave_dust", "Grave Dust (bury 3)", 2, CardEnums.EffectOp.BURY, 3, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.OPPONENT),
		"dust_6": _item("grave_dust", "Grave Dust (bury 6)", 2, CardEnums.EffectOp.BURY, 6, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.OPPONENT),
		"summon_1": _item("summoning_charm", "Summoning Charm (1 Militia)", 1, CardEnums.EffectOp.SUMMON_TOKEN, 1, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CONTROLLER, -1, militia),
		"summon_3": _item("summoning_charm", "Summoning Charm (3 Militia)", 1, CardEnums.EffectOp.SUMMON_TOKEN, 3, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CONTROLLER, -1, militia),
		"ward_1": _item("ward_sigil", "Ward Sigil (Untouchable turn)", 2, CardEnums.EffectOp.GRANT_KEYWORD, 0, 0, CardEnums.Duration.END_OF_TURN, CardEnums.TargetKind.CHOSEN_UNIT_ALLY, CardEnums.Keyword.UNTOUCHABLE),
		"firebrand_4": _item("firebrand_charm", "Firebrand Charm (4 dmg)", 2, CardEnums.EffectOp.DEAL_DAMAGE, 4, 0, CardEnums.Duration.PERMANENT, CardEnums.TargetKind.CHOSEN_UNIT_ENEMY),
		"stone_3_3": _item("sharpening_stone", "Sharpening Stone (+3/+3 turn)", 3, CardEnums.EffectOp.BUFF, 3, 3, CardEnums.Duration.END_OF_TURN, CardEnums.TargetKind.CHOSEN_UNIT_ALLY),
	}
	var groups: Dictionary = {
		"low": ["draught_3x3", "vitality_2", "tonic_5", "tonic_7", "salve_4", "bandage_heal3", "bandage_0_3_turn", "bandage_0_2_perm", "bandage_1_1_perm", "insight_draw2", "insight_draw1", "firebrand_2", "stone_2_2"],
		"high": ["chains_1", "silence_1", "silence_2", "dust_3", "dust_6", "summon_1", "summon_3", "ward_1", "firebrand_2", "firebrand_4", "stone_2_2", "stone_3_3", "salve_4"],
		"insight": ["insight_draw2", "insight_draw1", "draught_3x3", "firebrand_2"],
		"bandage": ["bandage_heal3", "bandage_0_3_turn", "bandage_0_2_perm", "bandage_1_1_perm", "stone_2_2"],
		"tonic": ["tonic_5", "tonic_5_b6", "tonic_5_b4", "tonic_5_b3", "vitality_2"],
	}
	var keys: Array = all.keys() if group == "all" else (groups.get(group, group.split(",", false)) as Array)
	var picked: Dictionary = {}
	for key: Variant in keys:
		if all.has(key):
			picked[key] = all[key]
	return picked


func _run() -> bool:
	var content: ContentSet = ContentLibrary.load_all()
	var filter: String = str(args.get("filter", "zone:beefcake"))
	var level: int = int(args.get("level", 0))
	var games: int = int(args.get("games", 12))
	var seed_value: int = int(args.get("seed", 7300))
	var out_path: String = str(args.get("out", "res://docs/design/sim/items_nov2.md"))
	var specs: Array[EncounterSpec] = EncounterCatalog.filtered(content, filter)
	if specs.is_empty():
		push_error("no encounters for %s" % filter)
		return false
	var variants: Dictionary = _variants(content, str(args.get("variants", "all")))
	var paths: Array[Affinity.Type] = [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.NECROCRAT, Affinity.Type.REFUSEMANCER]
	var started: int = Time.get_ticks_msec()
	var lines: PackedStringArray = []
	lines.append("# Item sim (Nov 2): %s, level %s, %d games per Path and encounter, seed %d" % [filter, str(level) if level > 0 else "expected", games, seed_value])
	lines.append("")
	lines.append("Player = ProgressionModel's expected player (reference deck, gear) with NO items, then with one charge of one item; the lift is the win-rate change in points (%d games, %d encounters, %d Paths)." % [games, specs.size(), paths.size()])
	lines.append("")
	lines.append("| Variant | Effect | Uses | Win % | Lift (pts) | Used in % of games | HP left on wins |")
	lines.append("|---|---|---:|---:|---:|---:|---:|")
	var base: Dictionary = _measure(content, specs, paths, level, games, seed_value, "", null)
	lines.append("| (no item) | - | - | %.1f | - | - | %.2f |" % [float(base["win"]), float(base["hp"])])
	print("item_sim: no item -> %.1f %%" % float(base["win"]))
	for key: String in variants.keys():
		var item: ItemData = variants[key] as ItemData
		var row: Dictionary = _measure(content, specs, paths, level, games, seed_value, key, item)
		var effect: String = "%s %d%s%s" % [str(CardEnums.EffectOp.keys()[item.effect.op]).to_lower(), item.effect.amount, ("/" + str(item.effect.amount2)) if item.effect.op == CardEnums.EffectOp.BUFF else "", " (turn)" if item.effect.duration == CardEnums.Duration.END_OF_TURN else ""]
		lines.append("| %s | %s | %d | %.1f | %+.1f | %.0f | %.2f |" % [item.display_name, effect, item.uses, float(row["win"]), float(row["win"]) - float(base["win"]), float(row["used"]), float(row["hp"])])
		print("item_sim: %-36s %.1f %% (%+.1f), used in %.0f %% of games" % [item.display_name, float(row["win"]), float(row["win"]) - float(base["win"]), float(row["used"])])
	lines.append("")
	lines.append("Simulated in %.1f s." % (float(Time.get_ticks_msec() - started) / 1000.0))
	var text: String = "\n".join(lines) + "\n"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path).get_base_dir())
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file != null:
		file.store_string(text)
		file.close()
	print(text)
	return true


## Win rate (%), the share of games the item was used in (%), the mean HP left on wins, over every encounter and Path.
func _measure(content: ContentSet, specs: Array[EncounterSpec], paths: Array[Affinity.Type], level: int, games: int, seed_value: int, key: String, item: ItemData) -> Dictionary:
	var original: ItemData = null
	if item != null:
		original = content.items.get(item.id) as ItemData
		content.items[item.id] = item
	var wins: int = 0
	var total: int = 0
	var used: int = 0
	var hp_sum: int = 0
	for spec: EncounterSpec in specs:
		for path: Affinity.Type in paths:
			var player: PlayerSpec = ProgressionModel.player_for(content, spec, path)
			if level > 0:
				player.level = level
				player.deck = ProgressionModel.reference_deck(content, path, level)
				player.equipment_ids = ProgressionModel.equipment_for(level)
			player.items = {item.id: 1} if item != null else {}
			var result: BalanceSim.Result = BalanceSim.run(content, player, spec, games, seed_value + int(path) * 100000 + key.hash() % 1000)
			wins += result.wins
			total += result.games
			used += result.items_used
			hp_sum += result.hp_left_on_win
	if item != null:
		if original != null:
			content.items[item.id] = original
		else:
			content.items.erase(item.id)
	return {"win": 100.0 * float(wins) / float(maxi(total, 1)), "used": 100.0 * float(used) / float(maxi(total, 1)), "hp": float(hp_sum) / float(maxi(wins, 1))}
