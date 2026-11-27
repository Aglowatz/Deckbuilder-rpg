extends RefCounted
## Nov 26 night (Part B): the draft balance audit's raw data. A sensible player drafts (the pick that fits best by a plain taste, gear
## that suits its Paths, the first item offered) in each config, builds the default deck and plays the run's fights as the game builds
## them (`DraftRun.build_game`: the rivals' full hands, their gear, their skill); a Mystery Mini plays a random mini dungeon's three
## fights on one HP pool. Every offer, pick, deck, piece of gear, item and result goes to a JSON file; tools/nov26n_draft_report.py
## turns the files into docs/design/sim/nov26n/draft_balance.md.
##   Godot --headless --path . -s res://tools/draft_audit.gd -- --configs=open:beefcake,high:beefcake+gourmand,zone:necrocrat,mini:gourmand
##        [--drafts=6] [--games=2] [--level=18] [--seed_from=0] [--out=res://docs/design/sim/nov26n/raw/<label>.json]
## A config: <mode>:<paths> with mode open (Classic), high (High Rollers), zone (Trey's zone draft; one Path) or mini (Mystery Mini),
## and paths joined by "+". Three- and four-Path sets need --level=22 (after Primm). --override=<json file> applies a proposal (sim only).

const PATHS: Dictionary = {"beefcake": Affinity.Type.BEEFCAKE, "gourmand": Affinity.Type.GOURMAND, "necrocrat": Affinity.Type.NECROCRAT, "refusemancer": Affinity.Type.REFUSEMANCER}
const MAX_STEPS: int = 4000

var args: Dictionary = {}
var content: ContentSet
var minis: Dictionary = {}


func run() -> bool:
	for raw: String in OS.get_cmdline_user_args():
		if raw.begins_with("--") and raw.contains("="):
			args[raw.substr(2, raw.find("=") - 2)] = raw.substr(raw.find("=") + 1)
	content = ContentLibrary.load_all()
	if args.has("override"):
		_apply_override(str(args["override"]))
	var drafts_each: int = int(args.get("drafts", 6))
	var games: int = int(args.get("games", 2))
	var level: int = int(args.get("level", 18))
	var seed_from: int = int(args.get("seed_from", 0))
	var records: Array = []
	var started: int = Time.get_ticks_msec()
	for config: String in str(args.get("configs", "open:beefcake")).split(",", false):
		var mode: String = config.get_slice(":", 0)
		var words: String = config.get_slice(":", 1)
		var paths: Array[int] = []
		for part: String in words.split("+", false):
			paths.append(int(PATHS[part]))
		for index: int in range(seed_from, seed_from + drafts_each):
			var seed_value: int = 1000 + index * 37 + paths.size() * 7 + hash(config) % 1000
			var tick: int = Time.get_ticks_msec()
			var record: Dictionary = _one(mode, paths, words, level, seed_value, games)
			record["config"] = config
			record["seconds"] = float(Time.get_ticks_msec() - tick) / 1000.0
			records.append(record)
			print("audit %s draft %d: %d/%d fights won in %.0f s" % [config, index, int(record["wins"]), int(record["games"]), float(record["seconds"])])
	var out: String = str(args.get("out", "res://docs/design/sim/nov26n/raw/audit.json"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()))
	var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	file.store_string(JSON.stringify({"level": level, "games": games, "seconds": float(Time.get_ticks_msec() - started) / 1000.0, "override": str(args.get("override", "")), "drafts": records}))
	file.close()
	print("Wrote %s (%d drafts)" % [out, records.size()])
	return true


func _challenge(mode: String, words: String) -> String:
	match mode:
		"open":
			return DraftArena.mode_challenge(DraftArena.MODE_CLASSIC)
		"high":
			return DraftArena.mode_challenge(DraftArena.MODE_HIGH)
		"mini":
			return DraftArena.MYSTERY_ID
	return DraftChallenges.zone_id_for(words)


func _one(mode: String, paths: Array[int], words: String, level: int, seed_value: int, games: int) -> Dictionary:
	var state: DraftState = DraftEngine.start(content, _challenge(mode, words), paths, level, seed_value, paths.size() >= 2, paths.size() >= 3)
	state.max_paths = 4 if level >= 21 else 2
	var picks: Array = []
	var guard: int = 0
	while state.phase == DraftState.PHASE_PICK and guard < 100:
		guard += 1
		var kind: String = str(state.offer["kind"])
		var options: Array = (state.offer["options"] as Array).duplicate()
		var choice: int = _choose(state, kind, options)
		picks.append({"kind": kind, "options": options, "picked": str(options[choice]) if choice < options.size() else ""})
		DraftEngine.pick(content, state, choice)
	var deck: Deck = DraftEngine.build_deck(content, state)
	var deck_ids: Array[String] = []
	for card: CardData in deck.cards:
		if not card.is_basic:
			deck_ids.append(card.id)
	var wins: int = 0
	var played: int = 0
	var fights: Array = []
	if mode == "mini":
		var cleared: int = _mini(state, level, seed_value, games)
		wins = cleared
		played = games
		fights.append({"mini": str(state.get_meta("mini_key", "")), "cleared": cleared, "runs": games})
	else:
		DraftRun.begin(content, state)
		var profile: PlayerProfile = DraftRun.player_profile(content, state)
		for i: int in range(state.rivals.size()):
			var rival: Dictionary = state.rivals[i]
			var rival_wins: int = 0
			for g: int in range(games):
				var game: GameState = DraftRun.build_game(content, state, profile, rival, seed_value * 13 + i * 101 + g)
				if _play(game, state.items, str(rival.get("ai", "Balanced")), str(rival.get("name", ""))):
					rival_wins += 1
			wins += rival_wins
			played += games
			fights.append({"rival": str(rival.get("name", "")), "paths": rival.get("paths", []), "gear": rival.get("equipment", []), "wins": rival_wins, "games": games})
	return {"mode": mode, "paths": words, "level": level, "seed": seed_value, "picks": picks, "deck": deck_ids, "equipment": state.equipment.duplicate(),
		"items": state.items.duplicate(), "wins": wins, "games": played, "fights": fights}


## The sensible player: cards by taste + fit + rarity; gear by rarity plus a bonus for pieces that name a drafted Path (minus for another
## Path's); items: a heal first, then a damage item, then the first offered.
func _choose(state: DraftState, kind: String, options: Array) -> int:
	var choice: int = 0
	var best: float = -1000.0
	match kind:
		DraftEngine.KIND_CARD:
			var picked: Array[CardData] = DraftEngine.picked_cards(content, state)
			for i: int in range(options.size()):
				var card: CardData = content.card(str(options[i]))
				if card == null:
					continue
				var cost: int = card.energy_value()
				var taste: float = (1.6 + 0.3 * float(card.attack + card.defense) - 0.5 * float(cost)) if card.is_unit() else (0.9 - 0.2 * float(cost))
				var value: float = taste + 2.0 * DraftEngine.fit(card, picked, state.paths) + 0.4 * float(int(card.rarity))
				if value > best:
					best = value
					choice = i
		DraftEngine.KIND_EQUIPMENT:
			for i: int in range(options.size()):
				var piece: EquipmentData = content.equipment_piece(str(options[i]))
				if piece == null:
					continue
				var value: float = float(int(piece.rarity))
				for modifier: Modifier in piece.modifiers:
					if modifier.color != Modifier.ANY_COLOR:
						value += 1.5 if state.paths.has(modifier.color) else -3.0
				if value > best:
					best = value
					choice = i
		DraftEngine.KIND_ITEM:
			for i: int in range(options.size()):
				var item: ItemData = content.item(str(options[i]))
				if item == null or item.effect == null:
					continue
				var value: float = 0.0
				match item.effect.op:
					CardEnums.EffectOp.GAIN_HP, CardEnums.EffectOp.HEAL:
						value = 3.0
					CardEnums.EffectOp.DEAL_DAMAGE:
						value = 2.0
					_:
						value = 1.0
				if value > best:
					best = value
					choice = i
	return choice


## Plays one draft fight (player at Elite, the rival at the draft's skill, both deterministic); true when the player won.
func _play(game: GameState, item_ids: Array, rival_ai: String, rival_name: String) -> bool:
	game.options.record_events = false
	var me: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, "Balanced"), AIPlayer.Skill.ELITE)
	me.deterministic = true
	var foe: AIPlayer = AIPlayer.for_foe(ZoneDecks.personality(content, rival_ai), DraftRun.skill(), rival_name)
	foe.deterministic = true
	var ais: Array[AIPlayer] = [me, foe]
	var items: Dictionary = {}
	for id: Variant in item_ids:
		items[str(id)] = int(items.get(str(id), 0)) + 1
	var item_turn: int = -1
	var used: Dictionary = {}
	var steps: int = 0
	while not game.is_over() and steps < MAX_STEPS:
		steps += 1
		var who: int = game.awaiting_player()
		if who == 0 and not items.is_empty() and game.stage == GameState.Stage.PLAYING and game.in_main_phase():
			if item_turn != game.turn:
				item_turn = game.turn
				used.clear()
			if SimItemPolicy.act(game, 0, items, content, used):
				continue
		var action: GameAction = ais[who].choose_action(game)
		if not game.apply_action(action):
			if not game.apply_action(GameAction.pass_phase(who)):
				break
	return game.winner == 0


## Mystery Mini: a mini dungeon (three fights) picked from the seed, played on one HP pool `runs` times; returns the clears.
func _mini(state: DraftState, level: int, seed_value: int, runs: int) -> int:
	if minis.is_empty():
		for spec: EncounterSpec in EncounterCatalog.dungeons():
			if spec.group.begins_with("side:"):
				var key: String = spec.group.trim_prefix("side:")
				if not minis.has(key):
					minis[key] = [] as Array[EncounterSpec]
				(minis[key] as Array[EncounterSpec]).append(spec)
	var keys: Array = minis.keys().filter(func(key: Variant) -> bool: return (minis[key] as Array).size() == 3)
	keys.sort()
	if keys.is_empty():
		return 0
	var key: String = str(keys[seed_value % keys.size()])
	state.set_meta("mini_key", key)
	var player: PlayerSpec = PlayerSpec.make(DraftEngine.build_deck(content, state), level, "draft")
	player.equipment_ids.assign(state.equipment)
	for id: Variant in state.items:
		player.items[str(id)] = 1
	var encounters: Array[EncounterSpec] = []
	encounters.assign(minis[key] as Array)
	var result: BalanceSim.SequenceResult = BalanceSim.run_sequence(content, player, encounters, runs, seed_value)
	return result.cleared


## A proposal, sim only: {"cards": {id: {"generic_cost": n, "attack": n, "defense": n}}, "rewards": {...}} applied to the loaded content.
func _apply_override(path: String) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return
	for id: Variant in ((parsed as Dictionary).get("cards", {}) as Dictionary).keys():
		var card: CardData = content.card(str(id))
		if card == null:
			continue
		var change: Dictionary = (parsed as Dictionary)["cards"][id] as Dictionary
		for field: Variant in change.keys():
			card.set(str(field), change[field])
	for id: Variant in ((parsed as Dictionary).get("equipment_rarity", {}) as Dictionary).keys():
		var piece: EquipmentData = content.equipment_piece(str(id))
		if piece != null:
			piece.rarity = int((parsed as Dictionary)["equipment_rarity"][id])
