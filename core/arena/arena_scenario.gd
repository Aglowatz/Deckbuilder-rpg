class_name ArenaScenario
extends RefCounted
## Builds the duel of an `ArenaEncounter`: the opponent's deck and HP, the player's own or restricted deck, rule
## modifiers (no unit plays...), the goal's turn limit and, for puzzles, the preset board. The result is a normal
## `GameState`, so the battle screen, the AI and every engine rule work unchanged; `ArenaEncounter.player_won` judges it.


static func enemy_setup(content: ContentSet, encounter: ArenaEncounter) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, encounter.enemy_name, encounter.enemy_recipe)
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], encounter.enemy_name)
	setup.starting_hp = encounter.enemy_hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = maxi(encounter.enemy_hp, PlayerProfile.START_MAX_HP)
	return setup


## The deck the player fights with: the preset "gladiator's kit" of a restricted fight, else their own deck.
static func player_deck(content: ContentSet, encounter: ArenaEncounter, own_deck: Deck) -> Deck:
	if encounter.uses_restricted_deck():
		return ZoneDecks.from_recipe(content, "Gladiator's Kit", encounter.player_recipe)
	return own_deck


static func build_game(content: ContentSet, encounter: ArenaEncounter, profile: PlayerProfile, own_deck: Deck, seed_value: int) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = encounter.first_player if encounter.is_puzzle() else -1
	if encounter.turn_limit() > 0:
		options.turn_limit = encounter.turn_limit()
	options.free_mulligan = not encounter.is_puzzle()
	var rules: Array[ModifierSource] = []
	if not encounter.player_rules.is_empty():
		var source: ModifierSource = ModifierSource.new()
		source.source_name = "Arena rules"
		source.source_kind = ModifierSource.SourceKind.DUNGEON
		source.modifiers = encounter.player_rules.duplicate()
		rules.append(source)
	var player: PlayerSetup = PlayerSetup.create(player_deck(content, encounter, own_deck), profile, rules, "You")
	if encounter.player_hp > 0:
		player.starting_hp = encounter.player_hp
	var game: GameState = GameState.new(options)
	game.add_player(player)
	game.add_player(enemy_setup(content, encounter))
	game.start()
	if not encounter.preset.is_empty():
		apply_preset(game, content, encounter.preset)
	return game


## Replaces the dealt zones with the encounter's preset board, hands, infrastructure and HP.
static func apply_preset(game: GameState, content: ContentSet, preset: Dictionary) -> void:
	for side: String in ["player", "enemy"]:
		if not preset.has(side):
			continue
		var spec: Dictionary = preset[side] as Dictionary
		var index: int = 0 if side == "player" else 1
		var state: PlayerState = game.players[index]
		if spec.has("hp"):
			state.hp = int(spec["hp"])
		if spec.has("hand"):
			state.hand.clear()
			for card_id: Variant in (spec["hand"] as Dictionary).keys():
				for copy: int in range(int((spec["hand"] as Dictionary)[card_id])):
					state.hand.append(game.create_instance(content.card(str(card_id)), index))
		if spec.has("field"):
			state.field.clear()
			for card_id: Variant in (spec["field"] as Dictionary).keys():
				for copy: int in range(int((spec["field"] as Dictionary)[card_id])):
					var unit: CardInstance = game.create_instance(content.card(str(card_id)), index)
					unit.summoning_sick = false
					state.field.append(unit)
		if spec.has("infrastructure"):
			state.infrastructure.clear()
			var letters: Array[String] = ["", "A", "B", "C", "D"]
			for letter: Variant in (spec["infrastructure"] as Dictionary).keys():
				var path: int = letters.find(str(letter))
				for copy: int in range(int((spec["infrastructure"] as Dictionary)[letter])):
					state.infrastructure.append(game.create_instance(content.infrastructure[path] as CardData, index))
		if spec.has("graveyard"):
			state.refuse_pile.clear()
			for card_id: Variant in (spec["graveyard"] as Dictionary).keys():
				for copy: int in range(int((spec["graveyard"] as Dictionary)[card_id])):
					state.refuse_pile.append(game.create_instance(content.card(str(card_id)), index))


## The reward of a first clear with the "primary" Path resolved to the player's own, as
## {"gold", "xp", "essence": {Affinity.Type: amount}, "equipment", "item", "card"}.
static func resolve_reward(encounter: ArenaEncounter, primary: Affinity.Type) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in encounter.reward.keys():
		if str(key) != "essence":
			result[str(key)] = encounter.reward[key]
	var essence: Dictionary = {}
	var letters: Dictionary = {"A": Affinity.Type.BEEFCAKE, "B": Affinity.Type.GOURMAND, "C": Affinity.Type.REFUSEMANCER, "D": Affinity.Type.NECROCRAT}
	for key: Variant in (encounter.reward.get("essence", {}) as Dictionary).keys():
		var path: Affinity.Type = primary if str(key) == "primary" else letters[str(key)] as Affinity.Type
		essence[path] = int(essence.get(path, 0)) + int((encounter.reward["essence"] as Dictionary)[key])
	if not essence.is_empty():
		result["essence"] = essence
	return result
