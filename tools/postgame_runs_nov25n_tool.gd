extends RefCounted
## Nov 25 night (Parts C to F): whole runs through the postgame dungeons, run by `tools/postgame_runs_nov25n.gd`.
##   Godot --headless --path . -s res://tools/postgame_runs_nov25n.gd -- --dungeon=S-GALLERY [--route=A] [--boon=thick] [--decks=ref|draft]
##       [--runs=4] [--seed=9100] [--out=res://docs/design/sim/nov25n/<file>.md]
## A run is one HP pool through the dungeon's fights along a route, in order, with the dungeon's heals (the Lab's break room: +5; the
## Gallery has none but the Silver Reserve boon `--boon`, "Mending Light" healing 8 before each fight). The hero is a strong, well-equipped
## player of the dungeon's level (`--decks=ref`: each Path's reference deck, gear and items) or a drafted deck (`--decks=draft`: a sensible
## Classic Draft of two Paths at that level, with the gear it drafted), played by the planning AI. Every foe has its rules and scripts and,
## as in the game, a full opening hand (`OpponentHands`). Not modelled: events' boons and curses, treasure, card picks on the way.
## The Vault's Warden (`--dungeon=VAULT`) is one fight. Measures; changes nothing. Appends one table row per call to `--out`.

const ROUTES: Dictionary = {
	"D-LAB": {"A": [3, 5, 8, "heal5", 10, 13, 15, 16], "B": [2, "heal5", 15, 16]},
	"S-BEEF": {"A": [1, 2, 3]},
	"S-GALLERY": {"A": [2, 4, 5, 7, "heal12", 9, 10, 11, 13]},
}
const DRAFT_PAIRS: Array = [["beefcake", "necrocrat"], ["gourmand", "refusemancer"], ["beefcake", "gourmand"], ["necrocrat", "refusemancer"]]

var args: Dictionary = {}
var content: ContentSet


func run() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	content = ContentLibrary.load_all()
	var dungeon: String = str(args.get("dungeon", "S-GALLERY"))
	var route_name: String = str(args.get("route", "A"))
	var runs: int = int(args.get("runs", 4))
	var seed_value: int = int(args.get("seed", 9100))
	var decks: String = str(args.get("decks", "ref"))
	var boon: String = str(args.get("boon", ""))
	var out_path: String = str(args.get("out", "res://docs/design/sim/nov25n/postgame_runs_raw.md"))
	var started: int = Time.get_ticks_msec()
	var by_id: Dictionary = {}
	for spec: EncounterSpec in EncounterCatalog.all(content):
		by_id[spec.id] = spec
	var steps: Array = []
	if dungeon == "VAULT":
		for id: Variant in by_id.keys():
			if str(id).contains("vault"):
				steps.append(by_id[id])
				break
	else:
		for step: Variant in (ROUTES[dungeon] as Dictionary)[route_name] as Array:
			if step is String:
				steps.append(step)
			elif by_id.has("%s:%d" % [dungeon, int(step)]):
				steps.append(by_id["%s:%d" % [dungeon, int(step)]])
	var fights: Array[EncounterSpec] = []
	var foe_hp: int = int(args.get("foe_hp", 100))
	for step: Variant in steps:
		if step is EncounterSpec:
			if foe_hp != 100:
				(step as EncounterSpec).enemy_hp = maxi(1, int(round(float((step as EncounterSpec).enemy_hp) * float(foe_hp) / 100.0)))
			fights.append(step as EncounterSpec)
	if fights.is_empty():
		printerr("no fights for %s %s" % [dungeon, route_name])
		return false
	var reached: Dictionary = {}
	var won: Dictionary = {}
	var total: int = 0
	var cleared: int = 0
	var hp_sum: int = 0
	var fights_won_sum: int = 0
	var players: Array[PlayerSpec] = _players(fights[fights.size() - 1], decks, seed_value)
	BalanceSim.full_opponent_hands = str(args.get("hands", "on")) != "off"
	var extra_hp: int = int(args.get("extra_hp", 0))
	for player: PlayerSpec in players:
		if extra_hp != 0:
			player.extra_sources.append(CardBuilder.modifier_source("Measured extra HP", ModifierSource.SourceKind.BOON, [CardBuilder.modifier(Modifier.Kind.MAX_HP, extra_hp)] as Array[Modifier]))
		if boon != "" and boon != "best" and dungeon == ShatteredGallery.DUNGEON_ID:
			var source: ModifierSource = ShatteredGallery.silver_boon(boon)
			if source != null:
				player.extra_sources.append(source)
		var picked_source: ModifierSource = null
		for run_index: int in range(runs):
			total += 1
			# Nov 26 day (Part E): `--boon=best` - the Silver Reserve as a careful player meets it: the three boons this run offers, the
			# one that measured strongest (BOON_RANK, from docs/design/sim/nov25n/gallery_boons.md) taken
			var run_boon: String = boon
			if boon == "best" and dungeon == ShatteredGallery.DUNGEON_ID:
				run_boon = _best_boon(ShatteredGallery.silver_offer(seed_value + run_index * 31 + total))
				if picked_source != null:
					player.extra_sources.erase(picked_source)
				picked_source = ShatteredGallery.silver_boon(run_boon)
				if picked_source != null:
					player.extra_sources.append(picked_source)
				boons_taken[run_boon] = int(boons_taken.get(run_boon, 0)) + 1
			var hp: int = 0
			var max_hp: int = 0
			var items: Dictionary = player.items.duplicate()
			var alive: bool = true
			for index: int in range(steps.size()):
				var step: Variant = steps[index]
				if step is String:
					if str(step).begins_with("heal") and hp > 0 and max_hp > 0:
						hp = mini(max_hp, hp + int(str(step).substr(4)))
					continue
				var encounter: EncounterSpec = step as EncounterSpec
				reached[encounter.id] = int(reached.get(encounter.id, 0)) + 1
				if run_boon == "mend" and hp > 0 and max_hp > 0:
					hp = mini(max_hp, hp + 8)
				var scratch: BalanceSim.Result = BalanceSim.Result.new()
				scratch.encounter = encounter
				var first: int = encounter.first_player if encounter.first_player >= 0 else (run_index + index) % 2
				var game: GameState = BalanceSim.play_game(content, player, encounter, seed_value + run_index * 31 + index * 7 + total * 101, first, hp, items, scratch)
				max_hp = maxi(max_hp, game.players[0].max_hp)
				if args.has("verbose"):
					print("fight %s: %s vs %s, turns %d, you %d/%d HP, foe %d HP, winner %d, deck %d cards, hand at start %d" % [encounter.id, player.label, encounter.enemy_name, GameState.turn_number_of(game.turn), game.players[0].hp, game.players[0].max_hp, game.players[1].hp, game.winner, player.deck.size(), game.players[1].hand.size()])
				if game.winner != 0:
					alive = false
					break
				won[encounter.id] = int(won.get(encounter.id, 0)) + 1
				fights_won_sum += 1
				hp = maxi(1, game.players[0].hp)
			if alive:
				cleared += 1
				hp_sum += hp
	var per_fight: PackedStringArray = []
	for encounter: EncounterSpec in fights:
		var seen: int = int(reached.get(encounter.id, 0))
		per_fight.append("%s %s" % [encounter.enemy_name.get_slice(",", 0), ("%d/%d" % [int(won.get(encounter.id, 0)), seen]) if seen > 0 else "-"])
	var label: String = boon if boon != "" else "-"
	if not boons_taken.is_empty():
		var bits: PackedStringArray = []
		for id: Variant in boons_taken.keys():
			bits.append("%s %d" % [str(id), int(boons_taken[id])])
		label += " (%s)" % ", ".join(bits)
	if str(args.get("label", "")) != "":
		label += " [%s]" % str(args["label"])
	if not BalanceSim.full_opponent_hands:
		label += " (hands as before)"
	if extra_hp != 0:
		label += " (+%d HP)" % extra_hp
	if foe_hp != 100:
		label += " (foes at %d%% HP)" % foe_hp
	var row: String = "| %s | %s | %s | %s | %d | **%s** | %.1f of %d | %s | %s | %d s |" % [dungeon, route_name, decks, label, total,
		BalanceSim.percent(float(cleared) / float(maxi(1, total))), float(fights_won_sum) / float(maxi(1, total)), fights.size(), ("%.1f" % (float(hp_sum) / float(cleared))) if cleared > 0 else "-",
		"; ".join(per_fight), int((Time.get_ticks_msec() - started) / 1000.0)]
	print(row)
	var existing: String = FileAccess.get_file_as_string(out_path) if FileAccess.file_exists(out_path) else ""
	if existing.is_empty():
		existing = "# Postgame whole runs (Nov 25 night)

Generated by `tools/postgame_runs_nov25n_tool.gd` (see its header for what is modelled). Per fight: won / reached.

| Dungeon | Route | Decks | Silver boon | Runs | Cleared | Fights won (average) | HP left | Per fight | Took |
|---|---|---|---|---:|---:|---:|---:|---|---:|
"
	var file: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if file != null:
		file.store_string(existing + row + "\n")
		file.close()
	return true


## The heroes: each Path's reference player at the last fight's level, or four drafted decks at that level.
func _players(last: EncounterSpec, decks: String, seed_value: int) -> Array[PlayerSpec]:
	var result: Array[PlayerSpec] = []
	if decks != "draft":
		for path: Affinity.Type in Affinity.colored_types():
			result.append(ProgressionModel.player_for(content, last, path))
		return result
	var index: int = 0
	for pair: Array in DRAFT_PAIRS:
		index += 1
		var paths: Array[int] = []
		for word: Variant in pair:
			paths.append(_path_of(str(word)))
		var state: DraftState = DraftEngine.start(content, "open", paths, last.expected_level, seed_value + index * 977, true, false)
		var guard: int = 0
		while state.phase == DraftState.PHASE_PICK and guard < 100:
			guard += 1
			var options: Array = state.offer["options"] as Array
			var choice: int = 0
			if str(state.offer["kind"]) == DraftEngine.KIND_CARD:
				var picked: Array[CardData] = DraftEngine.picked_cards(content, state)
				var best: float = -1000.0
				for i: int in range(options.size()):
					var card: CardData = content.card(str(options[i]))
					var cost: int = card.energy_value()
					var taste: float = (1.6 + 0.3 * float(card.attack + card.defense) - 0.5 * float(cost)) if card.is_unit() else (0.9 - 0.2 * float(cost))
					var value: float = taste + 2.0 * DraftEngine.fit(card, picked, state.paths) + 0.4 * float(int(card.rarity))
					if value > best:
						best = value
						choice = i
			elif str(state.offer["kind"]) == DraftEngine.KIND_EQUIPMENT:
				# Nov 26 day (Part E): gear that suits the deck - rarity, plus pieces whose Path-bound modifiers name a drafted Path,
				# minus pieces built for a Path the deck does not have (it used to take the rarest piece, whatever it did)
				var top: float = -1000.0
				for i: int in range(options.size()):
					var piece: EquipmentData = content.equipment_piece(str(options[i]))
					if piece == null:
						continue
					var value: float = float(int(piece.rarity))
					for modifier: Modifier in piece.modifiers:
						if modifier.color != Modifier.ANY_COLOR:
							value += 1.5 if state.paths.has(modifier.color) else -3.0
					if value > top:
						top = value
						choice = i
			DraftEngine.pick(content, state, choice)
		DraftEngine.lock_deck(state)
		var spec: PlayerSpec = PlayerSpec.make(DraftEngine.build_deck(content, state), last.expected_level, "draft %s" % "+".join(pair))
		for id: Variant in state.equipment:
			spec.equipment_ids.append(str(id))
		for id: Variant in state.items:
			spec.items[str(id)] = 1
		result.append(spec)
	return result


## Part E: the strongest of the offered Silver Reserve boons (fights won on average, Nov 25 night: thick and start 2.2, look 1.7 ...).
const BOON_RANK: Array[String] = ["thick", "start", "look", "guard", "edge", "first", "mend", "purse", "hand"]
var boons_taken: Dictionary = {}


func _best_boon(offer: Array[String]) -> String:
	for id: String in BOON_RANK:
		if offer.has(id):
			return id
	return offer[0] if not offer.is_empty() else "thick"


func _path_of(word: String) -> int:
	for path: Affinity.Type in Affinity.colored_types():
		if Affinity.display_name(path).to_lower() == word:
			return int(path)
	return int(Affinity.Type.BEEFCAKE)
