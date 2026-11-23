class_name DraftRun
extends RefCounted
## Draft mode, Phase 1: the run after the draft. Three fights against the three rivals, each at full HP, until 3 wins or 2
## losses. The player fights as a separate person: the base HP and hand size of their level, only the drafted equipment and the
## drafted items (one charge of each per fight), the 35-card draft deck. The main game's loadout is never touched: the fight is
## built from a profile made here.


## The profile the draft's fights are played with. `base` (the real profile, may be null) lends its looks only.
static func player_profile(content: ContentSet, state: DraftState, base: PlayerProfile = null) -> PlayerProfile:
	var made: PlayerProfile = (base.duplicate(true) as PlayerProfile) if base != null else PlayerProfile.new()
	var row: LevelData = ProgressionTable.row(clampi(state.level, 1, ProgressionTable.MAX_LEVEL))
	made.apply_level(row)
	made.max_hp = row.max_hp
	made.equipment = [] as Array[ModifierSource]
	for id: String in state.equipment:
		var piece: EquipmentData = content.equipment_piece(id)
		if piece != null:
			made.equipment.append(piece)
	made.owned_items = [] as Array[ItemData]
	made.item_uses_remaining = {}
	made.equipped_item_ids = [] as Array[String]
	made.item_slots = maxi(DraftRules.item_slots(), state.items.size())
	for id: String in state.items:
		var item: ItemData = content.item(id)
		if item == null:
			continue
		made.owned_items.append(item)
		made.item_uses_remaining[item.id] = 1
		made.equipped_item_ids.append(item.id)
	return made


## The rival of the next fight (null data when the run is over).
static func next_rival(state: DraftState) -> Dictionary:
	if state.is_finished() or state.rivals.is_empty():
		return {}
	return state.rivals[mini(state.fights_played(), state.rivals.size() - 1)]


static func enemy_setup(content: ContentSet, rival: Dictionary) -> PlayerSetup:
	var deck: Deck = ZoneDecks.from_recipe(content, str(rival.get("name", "Rival")), rival.get("recipe", {}) as Dictionary)
	# the rival's seat: its base HP and the equipment it drafted (as rule sources; a max-HP piece moves its HP like the player's)
	var profile: PlayerProfile = PlayerProfile.new()
	profile.max_hp = maxi(int(rival.get("hp", 20)), 1)
	for piece: ModifierSource in DraftRivals.equipment_sources(content, rival):
		profile.equipment.append(piece)
	return PlayerSetup.create(deck, profile, [] as Array[ModifierSource], str(rival.get("name", "Rival")))


## The duel against `rival`: an ordinary GameState, so the battle screen, the AI and every rule work unchanged.
static func build_game(content: ContentSet, state: DraftState, profile: PlayerProfile, rival: Dictionary, seed_value: int) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = -1
	options.free_mulligan = true
	var player: PlayerSetup = PlayerSetup.create(DraftEngine.build_deck(content, state), profile, [] as Array[ModifierSource], "You")
	var game: GameState = GameState.new(options)
	game.add_player(player)
	game.add_player(enemy_setup(content, rival))
	game.start()
	return game


static func skill() -> AIPlayer.Skill:
	match str(DraftRules.rivals().get("skill", "elite")):
		"normal":
			return AIPlayer.Skill.NORMAL
		"boss":
			return AIPlayer.Skill.BOSS
	return AIPlayer.Skill.ELITE


## Leaves the deck builder: the three rivals draft now (so they are saved with the run and stay the same after a quit).
static func begin(content: ContentSet, state: DraftState) -> bool:
	if not DraftEngine.lock_deck(state):
		return false
	state.rivals = DraftRivals.build_all(content, state)
	return true


## Books a finished fight. Returns true when the run is over with it.
static func record(state: DraftState, won: bool) -> bool:
	if state.phase != DraftState.PHASE_RUN or state.is_finished():
		return state.is_finished()
	if won:
		state.wins += 1
	else:
		state.losses += 1
	if state.is_finished():
		state.phase = DraftState.PHASE_DONE
	return state.is_finished()


## Keeps one drafted card after a full win (once). True when `card_id` was one of the picks.
static func keep(state: DraftState, card_id: String) -> bool:
	if not state.full_win() or not state.kept_card.is_empty() or not state.cards.has(card_id):
		return false
	state.kept_card = card_id
	return true
