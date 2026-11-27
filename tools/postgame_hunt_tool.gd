extends RefCounted
## Nov 26 night (Part D): the postgame solution hunt (changes nothing in the game). For each postgame fight, a library of builds - a late
## deck (each Path's reference deck at the fight's level, and hand-built late decks from the full pool, drafted multi-Path cards
## included) x a gear kit (five slots, one piece a slot, picked to counter: model, sturdy, aggro, control) x the items (heals or burn)
## - each played `--games` times by the improved sim player against the fight as the game builds it (rules, scripts, full hands).
##   --mode=fights  --dungeon=D-LAB|S-GALLERY|S-BEEF|VAULT --fights=3,5,8 (node numbers; VAULT: none) [--games=2] [--decks=all|ref|late]
##   --mode=runs    the whole route with named builds (--builds=deck/kit/items;...) and the Lab's heal / the Gallery's best Silver boon
## Writes a Markdown table to --out (appends rows).

const LATE_DECKS: Dictionary = {
	"late_beef": {"label": "Late Beefcake Titans", "cards": {"B-28": 3, "B-13": 3, "B-38": 3, "B-27": 3, "B-29": 3, "B-37": 3, "B-11": 3, "B-26": 3, "B-25": 3, "B-21": 3, "B-32": 2, "B-30": 2, "B-34": 3, "BAS-B": 18}},
	"late_necro": {"label": "Late Necrocrat Control", "cards": {"N-29": 3, "N-34": 3, "N-15": 3, "N-28": 3, "N-23": 3, "N-03": 3, "N-07": 3, "N-26": 3, "N-06": 3, "N-38": 3, "N-35": 3, "N-27": 2, "N-32": 2, "INF-02": 3, "BAS-N": 15}},
	"late_gour": {"label": "Late Gourmand Golems", "cards": {"G-33": 2, "G-28": 3, "G-30": 2, "G-32": 1, "G-29": 3, "G-27": 3, "G-12": 3, "G-22": 3, "G-08": 3, "G-25": 3, "G-26": 2, "G-20": 3, "G-05": 3, "BAS-G": 16}},
	"late_ref": {"label": "Late Refusemancer Heap", "cards": {"R-33": 2, "R-30": 2, "R-29": 2, "R-36": 3, "R-28": 3, "R-27": 2, "R-35": 3, "R-22": 3, "R-25": 3, "R-09": 3, "R-07": 3, "R-05": 3, "BAS-R": 16}},
	"late_gb": {"label": "Late Beef-Gourmand Feast (drafted two-Path cards)", "cards": {"GB-13": 3, "GB-12": 3, "GB-03": 3, "GB-02": 3, "GB-01": 3, "B-28": 3, "B-13": 3, "G-22": 3, "G-29": 2, "B-38": 3, "GB-11": 3, "GB-10": 2, "INF-08": 3, "BAS-B": 9, "BAS-G": 9}},
	"late_nr": {"label": "Late Necro-Refuse Rats (drafted two-Path cards)", "cards": {"NR-16": 2, "NR-14": 3, "NR-12": 3, "NR-15": 3, "NR-01": 3, "NR-03": 3, "NR-09": 3, "NR-10": 3, "N-29": 3, "R-35": 3, "N-28": 2, "R-29": 2, "INF-07": 3, "BAS-N": 9, "BAS-R": 9}},
}
## Gear kits: pieces in preference order; the first piece of each slot is worn (one piece a slot, five slots).
const KITS: Dictionary = {
	"sturdy": ["four_seal_signet", "first_water_phial", "flamethrower", "colonels_ladle", "booster_wrapper_cape", "swole_belt", "compost_boots", "bloodsand_boots", "quotas_stopwatch", "sideboard_satchel", "tinkers_wrench"],
	"aggro": ["glass_jaw_gauntlets", "earned_blade", "elastic_waistband", "curve_topper_boots", "compliance_clipboard", "quotas_stopwatch", "four_seal_signet", "first_water_phial"],
	"control": ["flamethrower", "clipwells_shears", "gladiators_net", "seed_satchel", "booster_wrapper_cape", "compost_boots", "sideboard_satchel", "four_seal_signet", "first_water_phial"],
}
const ITEMS: Dictionary = {
	"heal": {"hearty_pie": 2, "healing_salve": 2},
	"burn": {"firebrand_charm": 2, "sharpening_stone": 1, "hearty_pie": 1},
}
const ROUTES: Dictionary = {
	"D-LAB": {"A": [3, 5, 8, "heal5", 10, 13, 15, 16], "B": [2, "heal5", 15, 16]},
	"S-BEEF": {"A": [1, 2, 3]},
	"S-GALLERY": {"A": [2, 4, 5, 7, "heal12", 9, 10, 11, 13]},
}
const PATH_WORDS: Dictionary = {"beefcake": Affinity.Type.BEEFCAKE, "gourmand": Affinity.Type.GOURMAND, "necrocrat": Affinity.Type.NECROCRAT, "refusemancer": Affinity.Type.REFUSEMANCER}

var args: Dictionary = {}
var content: ContentSet
var by_id: Dictionary = {}


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	content = ContentLibrary.load_all()
	for spec: EncounterSpec in EncounterCatalog.all(content):
		by_id[spec.id] = spec
	BalanceSim.full_opponent_hands = true
	if str(args.get("mode", "fights")) == "runs":
		return _runs()
	return _fights()


func _fight_specs(dungeon: String, numbers: String) -> Array[EncounterSpec]:
	var result: Array[EncounterSpec] = []
	if dungeon == "VAULT":
		for id: Variant in by_id.keys():
			if str(id).contains("vault"):
				result.append(by_id[id])
				break
		return result
	for word: String in numbers.split(",", false):
		var key: String = "%s:%d" % [dungeon, int(word)]
		if by_id.has(key):
			result.append(by_id[key])
	return result


## The build names: "<deck>/<kit>/<items>" with deck ref_<path> or a LATE_DECKS key, kit model or a KITS key, items model or an ITEMS key.
func _build_names() -> Array[String]:
	var decks: Array[String] = []
	var which: String = str(args.get("decks", "all"))
	if which != "late":
		for word: String in PATH_WORDS.keys():
			decks.append("ref_%s" % word)
	if which != "ref":
		for key: Variant in LATE_DECKS.keys():
			decks.append(str(key))
	var kits: Array = str(args.get("kits", "model,sturdy,aggro,control")).split(",", false)
	var item_sets: Array = str(args.get("items", "heal")).split(",", false)
	var result: Array[String] = []
	for deck: String in decks:
		for kit: Variant in kits:
			for items: Variant in item_sets:
				result.append("%s/%s/%s" % [deck, str(kit), str(items)])
	return result


func player(build: String, level: int) -> PlayerSpec:
	var parts: PackedStringArray = build.split("/")
	var deck: Deck = null
	if parts[0].begins_with("ref_"):
		deck = ProgressionModel.reference_deck(content, PATH_WORDS[parts[0].trim_prefix("ref_")] as Affinity.Type, level)
	else:
		deck = ZoneDecks.from_recipe(content, str((LATE_DECKS[parts[0]] as Dictionary)["label"]), (LATE_DECKS[parts[0]] as Dictionary)["cards"] as Dictionary)
	var spec: PlayerSpec = PlayerSpec.make(deck, level, build)
	spec.equipment_ids = ProgressionModel.equipment_for(level) if parts[1] == "model" else _kit(KITS[parts[1]] as Array)
	spec.items = ProgressionModel.items_for(level) if parts.size() < 3 or parts[2] == "model" else (ITEMS[parts[2]] as Dictionary).duplicate()
	return spec


func _kit(preference: Array) -> Array[String]:
	var worn: Array[String] = []
	var slots: Dictionary = {}
	for id: Variant in preference:
		var piece: EquipmentData = content.equipment_piece(str(id))
		if piece == null or slots.has(int(piece.slot)):
			continue
		slots[int(piece.slot)] = true
		worn.append(str(id))
	return worn


func _fights() -> bool:
	var dungeon: String = str(args.get("dungeon", "S-BEEF"))
	var games: int = int(args.get("games", 2))
	var specs: Array[EncounterSpec] = _fight_specs(dungeon, str(args.get("fights", "1,2,3")))
	var out_path: String = str(args.get("out", "res://docs/design/sim/nov26n/postgame_fights.md"))
	var builds: Array[String] = _build_names()
	for spec: EncounterSpec in specs:
		var level: int = maxi(spec.expected_level, 25)
		var rows: Array = []
		var started: int = Time.get_ticks_msec()
		for build: String in builds:
			var result: BalanceSim.Result = BalanceSim.run(content, player(build, level), spec, games, 9300 + spec.node_number * 101)
			rows.append([build, result.wins, result.games, result.avg_player_turns()])
		rows.sort_custom(func(a: Array, b: Array) -> bool: return int(a[1]) > int(b[1]))
		var won: int = 0
		var total: int = 0
		var winners: PackedStringArray = []
		for row: Array in rows:
			won += int(row[1])
			total += int(row[2])
			if int(row[1]) * 2 >= int(row[2]) and int(row[1]) > 0:
				winners.append("%s %d/%d" % [str(row[0]), int(row[1]), int(row[2])])
		var best: Array = rows[0]
		var line: String = "| %s | %s | %d | %d | %s | %d/%d over all builds | %s | %d s |" % [spec.id, spec.enemy_name, level, builds.size(), "%s %d/%d" % [str(best[0]), int(best[1]), int(best[2])],
			won, total, "; ".join(winners.slice(0, 8)) if not winners.is_empty() else "**none**", int((Time.get_ticks_msec() - started) / 1000.0)]
		print(line)
		_append(out_path, line, "| Fight | Foe | L | Builds | Best build | All | Builds winning half or more (top 8) | Took |\n|---|---|---:|---:|---|---|---|---:|")
	return true


func _runs() -> bool:
	var dungeon: String = str(args.get("dungeon", "S-BEEF"))
	var route: String = str(args.get("route", "A"))
	var runs: int = int(args.get("runs", 4))
	var out_path: String = str(args.get("out", "res://docs/design/sim/nov26n/postgame_runs.md"))
	var steps: Array = []
	if dungeon == "VAULT":
		steps.append_array(_fight_specs("VAULT", ""))
	else:
		for step: Variant in (ROUTES[dungeon] as Dictionary)[route] as Array:
			if step is String:
				steps.append(step)
			elif by_id.has("%s:%d" % [dungeon, int(step)]):
				steps.append(by_id["%s:%d" % [dungeon, int(step)]])
	for build: String in str(args.get("builds", "")).split(";", false):
		var level: int = 25
		for step: Variant in steps:
			if step is EncounterSpec:
				level = maxi(level, (step as EncounterSpec).expected_level)
		var hero: PlayerSpec = player(build, level)
		var cleared: int = 0
		var fights_won: int = 0
		var started: int = Time.get_ticks_msec()
		for run_index: int in range(runs):
			var hp: int = 0
			var max_hp: int = 0
			var items: Dictionary = hero.items.duplicate()
			var boon_source: ModifierSource = null
			if dungeon == ShatteredGallery.DUNGEON_ID:
				var boon: String = _best_boon(ShatteredGallery.silver_offer(9400 + run_index * 31))
				boon_source = ShatteredGallery.silver_boon(boon)
				if boon_source != null:
					hero.extra_sources.append(boon_source)
			var alive: bool = true
			for index: int in range(steps.size()):
				var step: Variant = steps[index]
				if step is String:
					if hp > 0 and max_hp > 0:
						hp = mini(max_hp, hp + int(str(step).substr(4)))
					continue
				var encounter: EncounterSpec = step as EncounterSpec
				var scratch: BalanceSim.Result = BalanceSim.Result.new()
				var first: int = encounter.first_player if encounter.first_player >= 0 else (run_index + index) % 2
				var game: GameState = BalanceSim.play_game(content, hero, encounter, 9400 + run_index * 31 + index * 7, first, hp, items, scratch)
				max_hp = maxi(max_hp, game.players[0].max_hp)
				if game.winner != 0:
					alive = false
					break
				fights_won += 1
				hp = maxi(1, game.players[0].hp)
			if boon_source != null:
				hero.extra_sources.erase(boon_source)
			if alive:
				cleared += 1
		var line: String = "| %s | %s | %s | %d | **%d/%d** | %.1f | %d s |" % [dungeon, route, build, runs, cleared, runs, float(fights_won) / float(runs), int((Time.get_ticks_msec() - started) / 1000.0)]
		print(line)
		_append(out_path, line, "| Dungeon | Route | Build (deck/kit/items) | Runs | Cleared | Fights won (avg) | Took |\n|---|---|---|---:|---:|---:|---:|")
	return true


## The Silver Reserve as a careful player meets it: the strongest of the offered boons (the Nov 25 night ranking).
const BOON_RANK: Array[String] = ["thick", "start", "look", "guard", "edge", "first", "mend", "purse", "hand"]


func _best_boon(offer: Array) -> String:
	for id: String in BOON_RANK:
		if offer.has(id):
			return id
	return str(offer[0]) if not offer.is_empty() else ""


func _append(path: String, line: String, header: String) -> void:
	var existing: String = FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	if existing.is_empty():
		existing = "# Postgame solution hunt (Nov 26 night)\n\nGenerated by `tools/postgame_hunt_tool.gd`.\n\n%s\n" % header
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path).get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(existing + line + "\n")
	file.close()
