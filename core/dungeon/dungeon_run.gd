class_name DungeonRun
extends RefCounted
## State of one dungeon run: HP carries between encounters, the deck can lose/gain cards for
## the duration of the dungeon, and dungeon-wide modifiers (rules, boons) apply to every duel.

var profile: PlayerProfile
var base_deck: Deck
var hp: int = 0
var encounters_won: int = 0
var failed: bool = false
## Cards lost / gained for this dungeon only (the profile's collection is never touched).
var lost_cards: Array[CardData] = []
var gained_cards: Array[CardData] = []
## Dungeon rules and boons; they feed the same ModifierPipeline as equipment.
var dungeon_sources: Array[ModifierSource] = []


## Enters a dungeon: the player is fully healed.
static func enter(
	player_profile: PlayerProfile,
	player_deck: Deck,
	dungeon_modifiers: Array[ModifierSource] = [],
) -> DungeonRun:
	var run: DungeonRun = DungeonRun.new()
	run.profile = player_profile
	run.base_deck = player_deck
	run.dungeon_sources = dungeon_modifiers.duplicate()
	run.hp = run.max_hp()
	return run


func modifiers(zone: ModifierSource = null) -> ModifierSet:
	return ModifierPipeline.build(profile, zone, dungeon_sources)


func max_hp() -> int:
	return maxi(1, profile.base_max_hp() + modifiers().sum(Modifier.Kind.MAX_HP))


func is_over() -> bool:
	return failed


## The deck as it stands now: base deck minus lost cards plus gained cards.
func current_deck() -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = base_deck.deck_name
	var remaining: Array[CardData] = base_deck.cards.duplicate()
	for lost: CardData in lost_cards:
		remaining.erase(lost)
	deck.cards = remaining
	deck.cards.append_array(gained_cards)
	return deck


func heal(amount: int) -> void:
	if amount > 0:
		hp = maxi(hp, mini(hp + amount, max_hp()))


func lose_hp(amount: int) -> void:
	if amount <= 0:
		return
	hp = maxi(0, hp - amount)
	if hp <= 0:
		failed = true


func lose_card(card: CardData) -> bool:
	if not current_deck().cards.has(card):
		return false
	lost_cards.append(card)
	return true


func gain_card(card: CardData) -> void:
	gained_cards.append(card)


## Adds a dungeon-wide source. A max-HP increase also raises current HP by the same amount.
func add_dungeon_source(source: ModifierSource) -> void:
	var before: int = max_hp()
	dungeon_sources.append(source)
	var gained: int = max_hp() - before
	if gained > 0:
		hp += gained


## Builds a duel for the next encounter: the player enters with the carried-over HP.
## The enemy is seat 1.
func start_encounter(
	enemy: PlayerSetup,
	zone: ModifierSource = null,
	options: GameOptions = null,
	player_rules: ModifierSource = null,
) -> GameState:
	var player: PlayerSetup = PlayerSetup.new()
	player.player_name = "Player"
	player.deck = current_deck()
	player.profile = profile
	player.modifiers = modifiers(zone)
	if player_rules != null:
		player.modifiers.add_source(player_rules)
	player.starting_hp = hp
	# Zone/dungeon effects apply to the enemy too (ModifierPipeline.build_for_enemy's contract).
	if zone != null:
		enemy.modifiers.add_source(zone)
	var game: GameState = GameState.new(options)
	game.add_player(player)
	game.add_player(enemy)
	game.start()
	return game


## Records the result of a finished duel: HP carries over; a loss fails the run.
func finish_encounter(game: GameState) -> void:
	hp = maxi(0, game.players[0].hp)
	if game.winner == 0:
		encounters_won += 1
	else:
		failed = true
