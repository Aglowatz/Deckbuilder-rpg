extends RefCounted
## Fable Nov 21 review (Part 3.2): the Arena's six battles as they are, and each PROPOSED change played by the same sim, so the owner can
## approve line by line with a number beside every line. Changes nothing in the game: the variants live only in this file.
##   Godot --headless --path . -s res://tools/arena_proposals_nov21.gd -- [--games=12] [--only=arena_marshal] [--out=res://docs/design/sim/nov21r/arena_proposals.md]
## A variant: [label, what it changes in words, enemy HP (0 = as it is), cards added to the enemy's deck ({} = none), AI personality
## ("" = as it is)].

const VARIANTS: Dictionary = {
	"arena_warmup": [
		["A", "HP 14 -> 18", 18, {}, ""],
		["B", "HP 14 -> 22", 22, {}, ""],
		["C", "HP 14 -> 18, and two heavier bodies in the deck (1 Beefy Bouncer, 1 Hulking Hauler)", 18, {"B-11": 1, "B-13": 1}, ""],
	],
	"arena_neutral_mile": [
		["A", "HP 13 -> 18", 18, {}, ""],
		["B", "HP 13 -> 24", 24, {}, ""],
		["C", "HP 13 -> 18, and the Sentinel plays Balanced (it attacks when it is ahead) instead of Defensive", 18, {}, "Balanced"],
	],
	"arena_spells_only": [
		["A", "HP 6 -> 10", 10, {}, ""],
		["B", "HP 6 -> 14", 14, {}, ""],
		["C", "HP 6 -> 10, and it plays Balanced instead of Passive", 10, {}, "Balanced"],
	],
	"arena_four_fists": [
		["A", "HP 33 -> 40", 40, {}, ""],
		["B", "HP 33 -> 40, and 3 Old Kingdom Crossroads (energy of any Path) so its four-Path hand is playable", 40, {"INF-11": 3}, ""],
		["C", "HP 33 -> 44, 3 Old Kingdom Crossroads, 1 Hulking Hauler and 1 Post-Human Resources Ghoul", 44, {"INF-11": 3, "B-13": 1, "N-03": 1}, ""],
	],
	"arena_marshal": [
		["A", "HP 46 -> 56", 56, {}, ""],
		["B", "HP 46 -> 56, and 1 more Portal-Ripping Titan and 1 more Hulking Hauler", 56, {"B-28": 1, "B-13": 1}, ""],
		["C", "HP 46 -> 64, and 1 more Portal-Ripping Titan and 1 more Hulking Hauler", 64, {"B-28": 1, "B-13": 1}, ""],
	],
	"arena_four_fists_unbound": [
		["A", "3 Old Kingdom Crossroads (energy of any Path)", 0, {"INF-11": 3}, ""],
		["B", "HP 54 -> 62", 62, {}, ""],
		["C", "HP 54 -> 62 and 3 Old Kingdom Crossroads", 62, {"INF-11": 3}, ""],
	],
}

## Round 2 (after round 1 showed that HP alone moves a bout by a few points): the enemy plays at a higher skill ("ELITE" / "BOSS": fewer
## mistakes, as dungeon elites and bosses play), its units carry a stat rule and it may draw an extra opening card. A rule is written as the
## dungeon rooms write theirs (DungeonBuilder.boon_from); in the game it would be one entry in data/encounters/modifiers.json.
## A variant here: [label, words, HP, added cards, AI, skill ("" = as it is), rule ("" = none)].
const ROUND2: Dictionary = {
	"arena_warmup": [
		["D", "HP 14 -> 20, and the Rookie plays at Elite skill (it stops making the mistakes a Normal foe makes)", 20, {}, "", "ELITE", ""],
		["E", "HP 14 -> 20, and a rule \"Home Crowd\": its units get +1/+0", 20, {}, "", "", "Home Crowd|foe_atk=1"],
		["F", "HP 14 -> 20, Elite skill, and \"Home Crowd\": its units get +1/+1", 20, {}, "", "ELITE", "Home Crowd|foe_atk=1,foe_def=1"],
	],
	"arena_neutral_mile": [
		["D", "HP 13 -> 20, and the Sentinel plays at Elite skill", 20, {}, "", "ELITE", ""],
		["E", "HP 13 -> 20, and a rule \"Packed Sand\": its units get +0/+2", 20, {}, "", "", "Packed Sand|foe_def=2"],
		["F", "HP 13 -> 22, Elite skill, Balanced, and \"Packed Sand\": its units get +1/+1", 22, {}, "Balanced", "ELITE", "Packed Sand|foe_atk=1,foe_def=1"],
	],
	"arena_four_fists": [
		["D", "HP 33 -> 44, and the Champion plays at Boss skill", 44, {}, "", "BOSS", ""],
		["E", "HP 33 -> 44, 3 Old Kingdom Crossroads, and a rule \"Four Fists\": its units get +1/+1", 44, {"INF-11": 3}, "", "", "Four Fists|foe_atk=1,foe_def=1"],
		["F", "HP 33 -> 44, Boss skill, 3 Old Kingdom Crossroads, \"Four Fists\" +1/+1 and one more opening card", 44, {"INF-11": 3}, "", "BOSS", "Four Fists|foe_atk=1,foe_def=1,foe_draw=1"],
	],
	"arena_marshal": [
		["D", "HP 46 -> 64, and a rule \"The Crowd Roars\": his units get +1/+1", 64, {}, "", "", "The Crowd Roars|foe_atk=1,foe_def=1"],
		["E", "HP 46 -> 64, and \"The Crowd Roars\": his units get +2/+1", 64, {}, "", "", "The Crowd Roars|foe_atk=2,foe_def=1"],
		["F", "HP 46 -> 72, \"The Crowd Roars\" +2/+2 and one more opening card", 72, {}, "", "", "The Crowd Roars|foe_atk=2,foe_def=2,foe_draw=1"],
	],
	"arena_four_fists_unbound": [
		["D", "HP 54 -> 70, and a rule \"Unbound\": its units get +1/+1", 70, {"INF-11": 3}, "", "", "Unbound|foe_atk=1,foe_def=1"],
		["E", "HP 54 -> 70, and \"Unbound\": its units get +2/+2", 70, {"INF-11": 3}, "", "", "Unbound|foe_atk=2,foe_def=2"],
		["F", "HP 54 -> 80, \"Unbound\" +2/+2, one more opening card, 3 Old Kingdom Crossroads", 80, {"INF-11": 3}, "", "", "Unbound|foe_atk=2,foe_def=2,foe_draw=1"],
	],
}

## Round 3: Diamond Sand was still won four times in five at +2/+2 and 80 HP (its deck is the Silver champion's, mostly Commons), so
## these rows also give it a postgame hand: Epics and Legendaries of all four Paths. Two middle rows for Bronze and Silver as well.
const ROUND3: Dictionary = {
	"arena_neutral_mile": [
		["G", "HP 13 -> 20, Elite skill, and \"Packed Sand\": its units get +0/+2 (it stays Defensive)", 20, {}, "", "ELITE", "Packed Sand|foe_def=2"],
	],
	"arena_four_fists": [
		["G", "HP 33 -> 40, 3 Old Kingdom Crossroads, and \"Four Fists\": its units get +1/+1", 40, {"INF-11": 3}, "", "", "Four Fists|foe_atk=1,foe_def=1"],
	],
	"arena_four_fists_unbound": [
		["G", "HP 54 -> 80, \"Unbound\" +3/+3, one more opening card, 3 Old Kingdom Crossroads", 80, {"INF-11": 3}, "", "", "Unbound|foe_atk=3,foe_def=3,foe_draw=1"],
		["H", "HP 54 -> 80, \"Unbound\" +2/+2, one more opening card, 3 Old Kingdom Crossroads, and a postgame hand: 2 more Champions of the Four Paths, 2 Portal-Ripping Titans, The Big Unit, Head Health Inspector, Mount Trashmore, Mass Layoffs", 80, {"INF-11": 3, "P4-01": 2, "B-28": 2, "B-32": 1, "G-29": 1, "R-29": 1, "N-29": 1}, "", "", "Unbound|foe_atk=2,foe_def=2,foe_draw=1"],
		["I", "HP 54 -> 90, \"Unbound\" +3/+3, two more opening cards, 3 Old Kingdom Crossroads, and the postgame hand of row H", 90, {"INF-11": 3, "P4-01": 2, "B-28": 2, "B-32": 1, "G-29": 1, "R-29": 1, "N-29": 1}, "", "", "Unbound|foe_atk=3,foe_def=3,foe_draw=2"],
	],
}

## Round 4: Diamond Sand once more. The Four Fists list does not get hard on numbers alone (75 % at +3/+3 and 80 HP, and a hand of
## Legendaries made it easier: 92 %), so two rows try the Marshal's own list under the Champion's name ("__base" = the bout whose deck
## is borrowed), which reached the band in Gold Sand.
const ROUND4: Dictionary = {
	"arena_four_fists_unbound": [
		["J", "HP 54 -> 80, \"Unbound\" +4/+4, one more opening card, 3 Old Kingdom Crossroads", 80, {"INF-11": 3}, "", "", "Unbound|foe_atk=4,foe_def=4,foe_draw=1"],
		["K", "the Marshal's deck (the Gold Sand list) in place of the Four Fists list, HP 54 -> 80, \"Unbound\" +2/+2, one more opening card", 80, {"__base": "arena_marshal"}, "", "", "Unbound|foe_atk=2,foe_def=2,foe_draw=1"],
		["L", "the Marshal's deck, HP 54 -> 80, \"Unbound\" +3/+2, one more opening card", 80, {"__base": "arena_marshal"}, "", "", "Unbound|foe_atk=3,foe_def=2,foe_draw=1"],
	],
}

var args: Dictionary = {}


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var games: int = int(args.get("games", 12))
	var out_path: String = str(args.get("out", "res://docs/design/sim/nov21r/arena_proposals.md"))
	var content: ContentSet = ContentLibrary.load_all()
	var started: int = Time.get_ticks_msec()
	var lines: PackedStringArray = []
	lines.append("# The Arena's battles and each proposed change, simulated (%d games per Path and row, seed 7100)" % games)
	lines.append("")
	lines.append("Generated by `tools/arena_proposals_nov21.gd` on %s. The player is the expected player of the tier's level (reference deck, gear, items) played by the planning AI at Elite skill; the enemy plays at Normal skill in Bronze, Elite in Silver, Boss in Gold and Diamond, as in the game. **Nothing here is in the game: the rows marked A, B, C exist only in the tool.**" % Time.get_datetime_string_from_system())
	lines.append("")
	lines.append("| Battle | Row | Change | L | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Turns | HP left (wins) |")
	lines.append("|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|")
	for spec: EncounterSpec in EncounterCatalog.all(content):
		if spec.group != "arena":
			continue
		var arena_id: String = spec.id.trim_prefix("arena:")
		if args.has("only") and str(args["only"]) != arena_id:
			continue
		var base_hp: int = spec.enemy_hp
		var base_recipe: Dictionary = spec.enemy_recipe
		var base_ai: String = spec.enemy_ai_name
		var base_kind: EncounterSpec.Kind = spec.kind
		var base_sources: Array[ModifierSource] = spec.enemy_sources.duplicate()
		var table: Dictionary = {"1": VARIANTS, "2": ROUND2, "3": ROUND3, "4": ROUND4}.get(str(args.get("round", "1")), VARIANTS) as Dictionary
		if not table.has(arena_id):
			continue
		var rows: Array = [["now", "as it is today (HP %d, %s)" % [base_hp, base_ai], 0, {}, ""]]
		rows.append_array(table.get(arena_id, []) as Array)
		for row: Array in rows:
			spec.enemy_hp = int(row[2]) if int(row[2]) > 0 else base_hp
			var added: Dictionary = (row[3] as Dictionary).duplicate()
			var row_recipe: Dictionary = base_recipe
			if added.has("__base"):
				var lender: ArenaEncounter = ArenaDefs.find(str(added["__base"]))
				row_recipe = lender.enemy_recipe if lender != null else base_recipe
				added.erase("__base")
			spec.enemy_recipe = EnemyDecks.with_cards(row_recipe, added)
			spec.enemy_ai_name = str(row[4]) if not str(row[4]).is_empty() else base_ai
			spec.kind = base_kind
			if row.size() > 5 and str(row[5]) == "ELITE":
				spec.kind = EncounterSpec.Kind.ELITE
			elif row.size() > 5 and str(row[5]) == "BOSS":
				spec.kind = EncounterSpec.Kind.BOSS
			spec.enemy_sources = base_sources.duplicate()
			if row.size() > 6 and not str(row[6]).is_empty():
				var rule: ModifierSource = DungeonBuilder.boon_from(str(row[6]))
				rule.for_enemy = false  # it sits on the enemy's own seat here: the modifiers apply to the seat that carries the source
				spec.enemy_sources.append(rule)
			var cells: PackedStringArray = []
			var merged: BalanceSim.Result = BalanceSim.Result.new()
			merged.encounter = spec
			for path: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]:
				var result: BalanceSim.Result = BalanceSim.run(content, ProgressionModel.player_for(content, spec, path), spec, games, 7100 + int(path) * 100000)
				cells.append(BalanceSim.percent(result.win_rate()))
				merged.merge(result)
			var line: String = "| %s | %s | %s | %d | %s | %s | %s | %s | **%s** | %.1f | %.1f |" % [spec.enemy_name if str(row[0]) == "now" else "", str(row[0]), str(row[1]),
				spec.expected_level, cells[0], cells[1], cells[2], cells[3], BalanceSim.percent(merged.win_rate()), merged.avg_player_turns(), merged.avg_hp_left_on_win()]
			lines.append(line)
			print(line)
			_flush(out_path, lines)
		spec.enemy_hp = base_hp
		spec.enemy_recipe = base_recipe
		spec.enemy_ai_name = base_ai
		spec.kind = base_kind
		spec.enemy_sources = base_sources
	lines.append("")
	lines.append("Simulated in %.0f s." % (float(Time.get_ticks_msec() - started) / 1000.0))
	_flush(out_path, lines)
	print("Wrote %s" % out_path)
	return true


func _flush(out_path: String, lines: PackedStringArray) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path).get_base_dir())
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")
		file.close()
