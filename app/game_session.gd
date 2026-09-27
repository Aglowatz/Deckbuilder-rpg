extends Node
## The running game's shared state: content, the player's profile/collection/deck, gold, story
## flags, and the current dungeon run. Everything here is plain data that SaveSystem stores.

const STARTING_GOLD: int = 120
const DECK_NAME: String = "Wanderer's Deck"

## Set to false by tools and tests so they never touch the player's real save file.
var save_enabled: bool = true
## Where the campaign is saved (tests use their own file).
var save_path: String = SaveSystem.PATH

var content: ContentSet
var profile: PlayerProfile
var gold: int = 0
var deck: Deck
var flags: Dictionary = {}
var run: DungeonRun
var dungeon_map: DungeonMap
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Everything a Condition (core/data/condition.gd) can check, beyond flags: see unlock_state().
## Lifetime gold spent (never decreases, unlike `gold`) - used by Condition.GOLD_SPENT.
var gold_spent_total: int = 0
## Dungeon names fully cleared - used by Condition.DUNGEON_CLEARED.
var cleared_dungeons: Array[String] = []
## card id -> true for every card owned, bought or faced in battle - the Codex (core/dungeon/
## card_codex.gd) shows these normally and everything else as a silhouette.
var seen_cards: Dictionary = {}
## Secret ids found (chests, hidden vendors...) - used by Condition.SECRET_FOUND.
var found_secrets: Array[String] = []
## Not driven by any mechanic yet; exists so Condition.PLAYER_LEVEL is usable by future content.
var player_level: int = 0
var completed_quests: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	rng.randomize()
	content = ContentLibrary.load_all()
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--no-save":
			save_enabled = false


# ---- Campaign lifecycle -----------------------------------------------------------------


func has_save() -> bool:
	return SaveSystem.exists(save_path)


## Starts a fresh campaign. The profile is created when the Wellspring is chosen.
func new_game() -> void:
	profile = null
	deck = Deck.new()
	deck.deck_name = DECK_NAME
	gold = STARTING_GOLD
	flags = {}
	run = null
	dungeon_map = null
	gold_spent_total = 0
	cleared_dungeons = []
	seen_cards = {}
	found_secrets = []
	player_level = 0
	completed_quests = []
	rng.randomize()


## Makes sure a complete, post-tutorial game exists (used when a scene - town, the vendor, the
## deck station... - is launched directly for testing/screenshots, skipping the starting area
## and the tutorial dungeon).
func ensure_game(color: Affinity.Type = Affinity.Type.A) -> void:
	if profile == null:
		new_game()
		profile = CampaignStart.new_profile(content, color)
		# Stand in for the 3 tutorial reward picks (Part C), so the fast-forwarded state is a
		# real, legal 45-card deck exactly like finishing the trial for real would leave it.
		var picks: Array[CardData] = ElementChoice.offer_for(content, color).sample_cards.duplicate()
		profile.owned_cards.append_array(picks)
		profile.intro_dungeon_cleared = true
		deck = CampaignStart.starter_deck(content, color)
		deck.cards.append_array(picks)
		deck.deck_name = DECK_NAME
		cleared_dungeons.append(TrialOfTheHollow.DUNGEON_NAME)
		set_flag(&"trial_cleared")


func has_profile() -> bool:
	return profile != null


# ---- Gold, flags, collection ------------------------------------------------------------


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	EventBus.gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if amount > gold:
		return false
	gold -= amount
	gold_spent_total += amount
	EventBus.gold_changed.emit(gold)
	return true


func flag(name: StringName) -> bool:
	return bool(flags.get(str(name), false))


func set_flag(name: StringName, value: bool = true) -> void:
	flags[str(name)] = value


## Any card (spell, token or basic land) by its id.
func card_by_id(id: String) -> CardData:
	var found: CardData = content.card(id)
	if found != null:
		return found
	for land: Variant in content.lands.values():
		if (land as CardData).id == id:
			return land as CardData
	return null


func owned_count(id: String) -> int:
	if profile == null:
		return 0
	var count: int = 0
	for card: CardData in profile.owned_cards:
		if card.id == id:
			count += 1
	return count


## Marks a card seen for the Codex (owned/bought already imply this; call for cards faced in
## battle - see BattleScreen._on_game_event).
func record_seen(id: String) -> void:
	if not seen_cards.has(id):
		seen_cards[id] = true
		EventBus.collection_changed.emit()


func has_seen(id: String) -> bool:
	return owned_count(id) > 0 or bool(seen_cards.get(id, false))


func found_secret(id: String) -> bool:
	return found_secrets.has(id)


func discover_secret(id: String) -> void:
	if not found_secrets.has(id):
		found_secrets.append(id)
		save_game()


## A plain-data snapshot for Condition.met() - see core/data/unlock_state.gd.
func unlock_state() -> UnlockState:
	var state: UnlockState = UnlockState.new()
	state.flags = flags
	state.cleared_dungeons = cleared_dungeons
	state.found_secrets = found_secrets
	state.gold_spent = gold_spent_total
	state.player_level = player_level
	state.completed_quests = completed_quests
	if profile != null:
		for card: CardData in profile.owned_cards:
			state.owned_cards[card.id] = int(state.owned_cards.get(card.id, 0)) + 1
	return state


func add_cards(cards: Array[CardData]) -> void:
	if profile == null:
		return
	profile.owned_cards.append_array(cards)
	EventBus.collection_changed.emit()


func deck_issues() -> Array[DeckValidator.Issue]:
	return DeckValidator.validate(deck, profile, null, true)


func deck_is_valid() -> bool:
	return profile != null and deck_issues().is_empty()


## Picks a legal starter-based deck automatically (used when the saved deck is missing/corrupt,
## e.g. an old save). CampaignStart.starter_deck is only 42 cards (Part C, meant to be topped up
## by tutorial rewards); pad it with a few more basic lands of the same color so this fallback is
## always a legal 45+ card deck outside the dungeon, where there is no size waiver.
func rebuild_starter_deck() -> void:
	deck = CampaignStart.starter_deck(content, profile.primary_affinity)
	var land: CardData = content.lands[int(profile.primary_affinity)] as CardData
	while deck.size() < DeckValidator.MIN_DECK_SIZE:
		deck.cards.append(land)
	deck.deck_name = DECK_NAME


# ---- Save / load ------------------------------------------------------------------------


func to_dict() -> Dictionary:
	var owned: Array[String] = []
	for card: CardData in profile.owned_cards:
		owned.append(card.id)
	var deck_ids: Array[String] = []
	for card: CardData in deck.cards:
		deck_ids.append(card.id)
	return {
		"gold": gold,
		"primary": int(profile.primary_affinity),
		"intro_cleared": profile.intro_dungeon_cleared,
		"postgame": profile.postgame_unlocked,
		"owned": owned,
		"deck": deck_ids,
		"flags": flags,
		"gold_spent_total": gold_spent_total,
		"cleared_dungeons": cleared_dungeons,
		"seen_cards": seen_cards.keys(),
		"found_secrets": found_secrets,
		"player_level": player_level,
		"completed_quests": completed_quests,
	}


func from_dict(data: Dictionary) -> bool:
	if not data.has("primary"):
		return false
	# The element is chosen before the profile is even created now (Part C), so a saved profile
	# always has a real color; NEUTRAL would only appear from a very old save predating that.
	var color: Affinity.Type = int(data["primary"]) as Affinity.Type
	var loaded: PlayerProfile = PlayerProfile.new()
	loaded.primary_affinity = color
	for id: Variant in data.get("owned", []) as Array:
		var card: CardData = card_by_id(str(id))
		if card != null:
			loaded.owned_cards.append(card)
	loaded.intro_dungeon_cleared = bool(data.get("intro_cleared", false))
	loaded.postgame_unlocked = bool(data.get("postgame", false))
	profile = loaded
	deck = Deck.new()
	deck.deck_name = DECK_NAME
	for id: Variant in data.get("deck", []) as Array:
		var card: CardData = card_by_id(str(id))
		if card != null:
			deck.cards.append(card)
	gold = int(data.get("gold", 0))
	flags = (data.get("flags", {}) as Dictionary).duplicate()
	run = null
	dungeon_map = null
	gold_spent_total = int(data.get("gold_spent_total", 0))
	cleared_dungeons.assign(data.get("cleared_dungeons", []) as Array)
	seen_cards = {}
	for id: Variant in data.get("seen_cards", []) as Array:
		seen_cards[str(id)] = true
	found_secrets.assign(data.get("found_secrets", []) as Array)
	player_level = int(data.get("player_level", 0))
	completed_quests.assign(data.get("completed_quests", []) as Array)
	if deck.size() == 0 and CampaignStart.is_valid_choice(color):
		rebuild_starter_deck()
	return true


func save_game() -> void:
	if not save_enabled or profile == null:
		return
	SaveSystem.write(to_dict(), save_path)


## Loads the saved campaign. Returns false when there is none (a game that has not yet reached
## the starting area's cave mouth has no profile and is not saved).
func load_game() -> bool:
	var data: Dictionary = SaveSystem.read(save_path)
	if data.is_empty():
		return false
	return from_dict(data)


# ---- Battles ----------------------------------------------------------------------------

## The battle the battle scene should run next (set before changing to res://scenes/battle.tscn).
var pending_battle: BattleContext


## A standalone match against a dungeon enemy (used by screenshots and for testing).
func make_practice_battle(enemy_name: String = "Cave Scavenger", first_player: int = 0) -> BattleContext:
	ensure_game()
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var node: DungeonMap.MapNode = null
	for candidate: DungeonMap.MapNode in map.nodes:
		if candidate.enemy_name == enemy_name:
			node = candidate
	if node == null:
		node = map.node(1)
	var options: GameOptions = GameOptions.new()
	options.first_player = first_player
	var game: GameState = GameState.new(options)
	var player: PlayerSetup = PlayerSetup.create(deck, profile, [] as Array[ModifierSource], "You")
	game.add_player(player)
	game.add_player(TrialOfTheHollow.enemy_setup(content, node))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(TrialOfTheHollow.personality(content, node.ai_name))
	context.enemy_name = node.enemy_name
	context.practice = true
	return context


# ---- Dungeon flow -----------------------------------------------------------------------


## Enters the Trial of the Hollow with the current deck (the player is fully healed). Used to
## replay it from town once it has already been cleared; the very first run is
## `begin_intro_trial(color)` instead.
func begin_trial() -> void:
	dungeon_map = TrialOfTheHollow.build_map()
	run = DungeonRun.enter(profile, deck, [] as Array[ModifierSource])
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Enters the Trial of the Hollow for the very first time, from the starting area, right after
## the player has chosen their element (`ElementChoiceScreen`, Part C): a fresh profile owning
## only the 23 neutral starter spells, and a 42-card starter deck (those spells plus 19 basic
## lands of `color`) - short of the normal 45-card minimum until the 3 tutorial reward picks fill
## it out (`deck_size_waiver()`). Retrying after an abandoned first attempt reuses the same
## profile/color (still no real deck exists until this trial is actually cleared).
func begin_intro_trial(color: Affinity.Type) -> void:
	if profile == null:
		profile = CampaignStart.new_profile(content, color)
	dungeon_map = TrialOfTheHollow.build_map()
	deck = CampaignStart.starter_deck(content, profile.primary_affinity)
	deck.deck_name = DECK_NAME
	run = DungeonRun.enter(profile, deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Set when the player is carried out of the dungeon or finishes it; the town shows it once.
var town_notice: String = ""
var pending_reward: RewardOffer
## True after the boss fell: the rewards screen then runs the trial-complete step.
var trial_finished: bool = false

const ENEMY_ICONS: Dictionary = {
	"Cave Scavenger": "lorc/bat-wing",
	"Hollow Stalker": "lorc/wolf-head",
	"Hollow Warden": "delapouite/skull-staff",
}


func in_dungeon() -> bool:
	return run != null and dungeon_map != null


## Builds the duel for a battle or boss node. Life carries over from the run.
func make_dungeon_battle(node: DungeonMap.MapNode) -> BattleContext:
	var options: GameOptions = GameOptions.new()
	options.first_player = 0 if node.tutorial else -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var enemy: PlayerSetup = TrialOfTheHollow.enemy_setup(content, node)
	var game: GameState = run.start_encounter(enemy, null, options)
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(TrialOfTheHollow.personality(content, node.ai_name))
	context.enemy_name = node.enemy_name
	context.enemy_icon = str(ENEMY_ICONS.get(node.enemy_name, "lorc/imp"))
	context.node_id = node.id
	context.tutorial = node.tutorial
	context.is_boss = node.kind == DungeonMap.Kind.BOSS
	context.gold_reward = node.gold_reward
	context.card_choices = node.card_choices
	return context


func start_battle(context: BattleContext) -> void:
	pending_battle = context
	SceneManager.change_scene("res://scenes/battle.tscn")


## Called by the battle screen when the player leaves the result panel.
func complete_battle(context: BattleContext) -> void:
	pending_battle = null
	if not in_dungeon():
		SceneManager.go_to_town()
		return
	run.finish_encounter(context.game)
	if not context.won or run.failed:
		abandon_run("You were carried out of the Hollow. Your collection is safe.")
		return
	dungeon_map.complete(context.node_id)
	var offer: RewardOffer = RewardOffer.new()
	offer.gold = context.gold_reward
	offer.is_boss = context.is_boss
	offer.enemy_name = context.enemy_name
	# Part C: the player's first time through the trial only ever offers cards of their own
	# chosen element, so the only on-color cards they own by the end are the 3 they picked here.
	# A later replay (intro_dungeon_cleared already true) is a normal dungeon with normal variety.
	if not profile.intro_dungeon_cleared:
		offer.cards = RewardGenerator.card_choices_for_color(content, profile.primary_affinity, rng, context.card_choices, context.is_boss)
	else:
		offer.cards = RewardGenerator.card_choices(content, profile, rng, context.card_choices, context.is_boss)
	pending_reward = offer
	trial_finished = context.is_boss
	SceneManager.change_scene("res://scenes/rewards.tscn")


## Applies the rewards the player chose. The card (if any) joins the collection AND the current
## run's deck (`DungeonRun.gain_card`), so it is usable in the very next encounter, not just after
## the dungeon. Returns true when the dungeon continues (the caller then goes back to the map);
## false after the boss, when the trial-complete step follows.
func apply_rewards() -> bool:
	if pending_reward != null:
		add_gold(pending_reward.gold)
		if pending_reward.taken != null:
			add_cards([pending_reward.taken] as Array[CardData])
			if run != null:
				run.gain_card(pending_reward.taken)
	pending_reward = null
	save_game()
	return not trial_finished


## Clears the run's dungeon bookkeeping once the boss falls. On the very first clear (Part C),
## this is what actually unlocks the town: the run's current deck (42-card starter + the 3
## on-element reward picks = 45, a real legal deck) becomes the player's real deck, and
## `intro_dungeon_cleared`/`trial_cleared` are set - there is no separate deck-choice step any
## more. On a replay, both are already set and there is nothing left to unlock.
func complete_trial() -> void:
	trial_finished = false
	if run != null:
		deck = run.current_deck()
		deck.deck_name = DECK_NAME
	profile.intro_dungeon_cleared = true
	set_flag(&"trial_cleared")
	run = null
	dungeon_map = null
	if not cleared_dungeons.has(TrialOfTheHollow.DUNGEON_NAME):
		cleared_dungeons.append(TrialOfTheHollow.DUNGEON_NAME)
	EventBus.collection_changed.emit()
	save_game()


func abandon_run(notice: String = "") -> void:
	run = null
	dungeon_map = null
	trial_finished = false
	pending_reward = null
	town_notice = notice
	save_game()
	if flag(&"trial_cleared"):
		SceneManager.go_to_town()
	else:
		# The town has not unlocked yet - a loss in the intro trial sends the player back to
		# the starting area to try again, not to a town they have not reached.
		SceneManager.go_to_start_area()
