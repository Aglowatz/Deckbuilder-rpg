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


## Overnight Nov 19 (Part 6.7): the preset deck's name for the "this bout uses a preset deck" screen.
static func preset_deck_name(encounter: ArenaEncounter) -> String:
	if encounter.is_puzzle():
		return "the puzzle's preset board and hand"
	match encounter.id:
		"arena_neutral_mile":
			return "the Gladiator's Kit"
		"arena_spells_only":
			return "the Spellslinger's Satchel"
	return "a preset deck"


## The preset deck's cards as lines ("3x Dropped Weights"), basic Infrastructure last as one line.
static func preset_deck_lines(content: ContentSet, encounter: ArenaEncounter) -> Array[String]:
	var lines: Array[String] = []
	var basics: int = 0
	var ids: Array = encounter.player_recipe.keys()
	if encounter.is_puzzle() and encounter.preset.has("player"):
		ids = ((encounter.preset["player"] as Dictionary).get("hand", {}) as Dictionary).keys()
	for id: Variant in ids:
		var card: CardData = content.card(str(id))
		var count: int = int(encounter.player_recipe.get(id, 1)) if not encounter.is_puzzle() else int((((encounter.preset["player"] as Dictionary).get("hand", {}) as Dictionary).get(id, 1)))
		if card == null:
			continue
		if card.is_unlimited():
			basics += count
			continue
		lines.append("%dx %s" % [count, card.display_name])
	if basics > 0:
		lines.append("%d basic Infrastructure" % basics)
	return lines


## The key of an arena fight's one-sided rules in data/encounters/modifiers.json.
static func rules_key(encounter: ArenaEncounter) -> String:
	return "arena:%s" % encounter.id


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
	# Daytime Oct 19: the one-sided encounter rules (data/encounters/modifiers.json, "arena:<id>") - the sim always had them, the game did not.
	var player_side: ModifierSource = EncounterModifiers.player_source(rules_key(encounter))
	if player_side != null:
		rules.append(player_side)
	var player: PlayerSetup = PlayerSetup.create(player_deck(content, encounter, own_deck), profile, rules, "You")
	if encounter.player_hp > 0:
		player.starting_hp = encounter.player_hp
	var game: GameState = GameState.new(options)
	game.add_player(player)
	var enemy: PlayerSetup = enemy_setup(content, encounter)
	EncounterModifiers.apply_to_enemy(enemy, rules_key(encounter))
	game.add_player(enemy)
	game.start()
	if not encounter.preset.is_empty():
		apply_preset(game, content, encounter.preset)
	return game


const RESOURCE_NAMES: Dictionary = {"iron": ResourceKind.Kind.IRON, "red_tape": ResourceKind.Kind.RED_TAPE, "contract": ResourceKind.Kind.CONTRACT, "ingredient": ResourceKind.Kind.INGREDIENT, "garbage": ResourceKind.Kind.GARBAGE}


## A preset card by id: a collectible card, or a token ("T-02").
static func _preset_card(content: ContentSet, card_id: String) -> CardData:
	var card: CardData = content.card(card_id)
	return card if card != null else TokenRegistry.data(card_id)


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
					state.hand.append(game.create_instance(_preset_card(content, str(card_id)), index))
		if spec.has("field"):
			state.field.clear()
			for card_id: Variant in (spec["field"] as Dictionary).keys():
				for copy: int in range(int((spec["field"] as Dictionary)[card_id])):
					var unit: CardInstance = game.create_instance(_preset_card(content, str(card_id)), index)
					# Fix pass Nov 4 (Part 1.3): the enemy's preset units have Just Arrived on its first turn; yours are ready.
					unit.just_arrived = index == 1
					state.field.append(unit)
		if spec.has("field") and index == 1:
			game.mark_placed_before_duel(1)
		if spec.has("infrastructure"):
			state.infrastructure.clear()
			for letter: Variant in (spec["infrastructure"] as Dictionary).keys():
				var path: int = int(Affinity.from_symbol(str(letter)))
				for copy: int in range(int((spec["infrastructure"] as Dictionary)[letter])):
					state.infrastructure.append(game.create_instance(content.infrastructure[path] as CardData, index))
		# Fable Nov 20 (Part 7): a puzzle may start with resources and Contracts ("resources": {"iron": 2, "red_tape": 1, "ingredient": 1,
		# "garbage": 1, "contract": 1}) - placed as they are, no "created" triggers.
		if spec.has("resources"):
			state.resources.clear()
			state.tokens.clear()
			for kind_name: Variant in (spec["resources"] as Dictionary).keys():
				var kind: int = RESOURCE_NAMES.get(str(kind_name), -1)
				if kind < 0:
					continue
				for copy: int in range(int((spec["resources"] as Dictionary)[kind_name])):
					state.zone_for_kind(kind as ResourceKind.Kind).append(game.create_instance(ResourceRules.data_for(kind as ResourceKind.Kind), index))
		if spec.has("refuse"):
			state.refuse_pile.clear()
			for card_id: Variant in (spec["refuse"] as Dictionary).keys():
				for copy: int in range(int((spec["refuse"] as Dictionary)[card_id])):
					state.refuse_pile.append(game.create_instance(_preset_card(content, str(card_id)), index))


## The reward of a first clear with the "primary" Path resolved to the player's own, as
## The prize multiplier: the player's level over the tier's expected level (`ProgressionModel` "arena:<tier>"), at least 1.
static func prize_factor(tier: int, level: int) -> float:
	if level <= 0:
		return 1.0
	var expected: int = maxi(1, ProgressionModel.level_for("arena:%d" % tier, level))
	return maxf(1.0, float(level) / float(expected))


## {"gold", "xp", "essence": {Affinity.Type: amount}, "equipment", "item", "card"}.
static func resolve_reward(encounter: ArenaEncounter, primary: Affinity.Type, level: int = 0) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in encounter.reward.keys():
		if str(key) != "essence":
			result[str(key)] = encounter.reward[key]
	# Fable pass Nov 1 (Part 7): the gold and XP of a first clear scale with the player's level above the tier's expected level (a postgame
	# L23 player at tier 1 paid 90 gold); never below the printed prize.
	var factor: float = prize_factor(encounter.tier, level)
	for key: String in ["gold", "xp"]:
		if result.has(key):
			result[key] = int(round(float(int(result[key])) * factor / 5.0)) * 5
	# Overnight Nov 19 (Part 6.3): every win pays a pack; "primary" is the player's own Path Pack.
	if result.has("pack") and str(result["pack"]) == "primary":
		var path_pack: PackData = PackCatalog.path_pack(primary)
		result["pack"] = path_pack.id if path_pack != null else "general_1"
	var essence: Dictionary = {}
	for key: Variant in (encounter.reward.get("essence", {}) as Dictionary).keys():
		var path: Affinity.Type = primary if str(key) == "primary" else Affinity.from_symbol(str(key))
		essence[path] = int(essence.get(path, 0)) + int((encounter.reward["essence"] as Dictionary)[key])
	if not essence.is_empty():
		result["essence"] = essence
	return result


## Fable Nov 15 (Part 4): an arena fight's own rules for the player (the spells-only bout) as badges; they were applied with no entry.
const PLAYER_RULE_TEXTS: Dictionary = {
	Modifier.Kind.NO_UNIT_PLAYS: ["Spells Only", "You cannot play units in this bout: spells, traps and tools only.", "delapouite/book-cover"],
}


static func player_rule_badges(encounter: ArenaEncounter) -> Array[RuleBadges.Badge]:
	var result: Array[RuleBadges.Badge] = []
	if encounter == null:
		return result
	# Overnight Nov 19 (Part 1.4): the bout itself first - its name and its rules or goal (the banner across the top used to say this).
	var story: StoryText = StoryText.shared()
	var bout: RuleBadges.Badge = RuleBadges.special(encounter.title(), encounter.rules(), "lorc/crossed-swords", [] as Array[Modifier], true)
	bout.kind = "arena"
	result.append(bout)
	for modifier: Modifier in encounter.player_rules:
		var words: Array = PLAYER_RULE_TEXTS.get(modifier.kind, [modifier.label if not modifier.label.is_empty() else "Arena rule", "A rule of this bout: %s." % modifier.label, RuleBadges.DEFAULT_ICON]) as Array
		var badge: RuleBadges.Badge = RuleBadges.special(str(words[0]), str(words[1]), str(words[2]), [modifier] as Array[Modifier])
		badge.side = RuleBadges.SIDE_PLAYER
		result.append(badge)
	return result
