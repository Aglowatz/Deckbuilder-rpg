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
	var extra: Array[ModifierSource] = []
	if bool(rival.get("boss", false)):
		extra.append(house_rule())
	return PlayerSetup.create(deck, profile, extra, str(rival.get("name", "Rival")))


## Octavia Eightfold's rule as the boss of the Shuffled Halls: one more card each turn.
static func house_rule() -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = DraftRivals.HOUSE_RULE_NAME
	source.modifiers = [CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)] as Array[Modifier]
	return source


## What a rival brings to the fight, as badges under its name (the owner, Nov 23: "as in other fights"): one per piece of
## equipment it drafted, and the boss's own rule.
static func rival_badges(content: ContentSet, rival: Dictionary) -> Array[RuleBadges.Badge]:
	var result: Array[RuleBadges.Badge] = []
	if bool(rival.get("boss", false)):
		var house: RuleBadges.Badge = RuleBadges.special(DraftRivals.HOUSE_RULE_NAME, DraftRivals.HOUSE_RULE_TEXT, "lorc/scroll-unfurled", house_rule().modifiers)
		house.side = RuleBadges.SIDE_ENEMY
		result.append(house)
	for source: ModifierSource in DraftRivals.equipment_sources(content, rival):
		var piece: EquipmentData = source as EquipmentData
		if piece == null:
			continue
		var badge: RuleBadges.Badge = RuleBadges.special(piece.source_name, "%s wears this: %s" % [str(rival.get("name", "Your rival")), piece.description], "lorc/gem-pendant", piece.modifiers)
		badge.side = RuleBadges.SIDE_ENEMY
		result.append(badge)
	return result


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


## Leaves the deck builder: the rivals draft now (so they are saved with the run and stay the same after a quit). A table run
## has three; a dungeon draft meets its dungeon's own foes.
static func begin(content: ContentSet, state: DraftState) -> bool:
	if not DraftEngine.lock_deck(state):
		return false
	# a dungeon draft meets its dungeon's own foes; since Nov 24 that goes for the Shuffled Halls too (hand-made, static
	# encounters in data/dungeons/dungeon_content.json: no drafted rival copies the player's Paths any more)
	if not state.is_dungeon():
		state.rivals = DraftRivals.build_all(content, state)
	else:
		state.rivals = [] as Array[Dictionary]
	return true


## Ends a dungeon draft: `cleared` when its boss fell. The run pays once (`Session`), then the deck's card to keep is chosen.
static func finish_dungeon(state: DraftState, cleared: bool) -> void:
	if not state.is_dungeon() or state.dungeon_over:
		return
	state.dungeon_over = true
	state.dungeon_cleared = cleared
	state.offer = {}
	state.phase = DraftState.PHASE_DONE


## Books a finished fight of a TABLE run. Returns true when the run is over with it.
static func record(state: DraftState, won: bool) -> bool:
	if state.phase != DraftState.PHASE_RUN or state.is_finished() or state.is_dungeon():
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
