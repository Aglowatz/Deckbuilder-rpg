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
	rng.randomize()


## Makes sure a complete, post-tutorial game exists (used when a scene - town, the vendor, the
## deck station... - is launched directly for testing/screenshots, skipping the starting area
## and the tutorial dungeon).
func ensure_game(color: Affinity.Type = Affinity.Type.A) -> void:
	if profile == null:
		new_game()
		profile = PlayerProfile.new()
		profile.owned_cards = CampaignStart.starter_spells(content)
		choose_starting_deck(color)


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


func add_cards(cards: Array[CardData]) -> void:
	if profile == null:
		return
	profile.owned_cards.append_array(cards)
	EventBus.collection_changed.emit()


func deck_issues() -> Array[DeckValidator.Issue]:
	return DeckValidator.validate(deck, profile, null, true)


func deck_is_valid() -> bool:
	return profile != null and deck_issues().is_empty()


## Picks a legal starter-based deck automatically (used when the saved deck is not legal).
func rebuild_starter_deck() -> void:
	deck = CampaignStart.starter_deck(content, profile.primary_affinity)
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
	}


func from_dict(data: Dictionary) -> bool:
	if not data.has("primary"):
		return false
	# NEUTRAL here means a save from mid-intro-trial, before a starting deck was chosen; the
	# profile still exists (gold/collection earned so far) even though there is no color yet.
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
## `begin_intro_trial()` instead.
func begin_trial() -> void:
	dungeon_map = TrialOfTheHollow.build_map()
	run = DungeonRun.enter(profile, deck, [] as Array[ModifierSource])
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Enters the Trial of the Hollow for the very first time, from the starting area, before the
## player has a real deck: a fixed neutral tutorial deck (`CampaignStart.STARTER_DECK_NAME`).
## Clearing it and choosing a starting deck (`choose_starting_deck`) is what unlocks the town.
func begin_intro_trial() -> void:
	if profile == null:
		profile = PlayerProfile.new()
		profile.owned_cards = CampaignStart.starter_spells(content)
	dungeon_map = TrialOfTheHollow.build_map()
	var tutorial_deck: Deck = content.deck(CampaignStart.STARTER_DECK_NAME)
	run = DungeonRun.enter(profile, tutorial_deck, [] as Array[ModifierSource])
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## The starting-deck choice at the end of the intro trial: sets the primary affinity, hands the
## player the whole chosen deck (so it is legal immediately) and unlocks the town. False for an
## invalid color or if the intro trial has not produced a profile yet.
func choose_starting_deck(color: Affinity.Type) -> bool:
	if profile == null or not CampaignStart.is_valid_choice(color):
		return false
	var chosen: Deck = StartingDecks.deck_for(content, color)
	if chosen == null:
		return false
	profile.primary_affinity = color
	profile.owned_cards.append_array(chosen.cards)
	profile.intro_dungeon_cleared = true
	deck = chosen
	deck.deck_name = DECK_NAME
	set_flag(&"trial_cleared")
	EventBus.collection_changed.emit()
	save_game()
	return true


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
	offer.cards = RewardGenerator.card_choices(content, profile, rng, context.card_choices, context.is_boss)
	pending_reward = offer
	trial_finished = context.is_boss
	SceneManager.change_scene("res://scenes/rewards.tscn")


## Applies the rewards the player chose. Returns true when the dungeon continues (the caller
## then goes back to the map); false after the boss, when the trial-complete step follows.
func apply_rewards() -> bool:
	if pending_reward != null:
		add_gold(pending_reward.gold)
		if pending_reward.taken != null:
			add_cards([pending_reward.taken] as Array[CardData])
	pending_reward = null
	save_game()
	return not trial_finished


## Clears the run's dungeon bookkeeping once the boss falls. On the very first clear, the
## starting-deck choice screen (`choose_starting_deck`) is what actually unlocks the town; on a
## replay `trial_cleared` is already set and there is nothing left to unlock.
func complete_trial() -> void:
	trial_finished = false
	run = null
	dungeon_map = null
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
