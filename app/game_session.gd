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
## Part B: quest state (active/completed + counter baselines) and named progress counters
## (zone enemies beaten, minigames won...) that Condition.COUNTER reads.
var quest_log: QuestLog = QuestLog.new()
var counters: Dictionary = {}
## Level-ups earned outside a battle (quest rewards...) that the current scene still has to show.
var pending_level_ups: Array[LevelData] = []
var completed_quests: Array[String]:
	get:
		return quest_log.completed

## Part E: how many equipment-slot choices (levels 5/10/15/20/25) are waiting to be made. A
## counter, not a flag, so a single large XP grant that crosses more than one such level never
## silently loses a choice. The character screen/level-up screen show a choice while this is > 0.
var pending_equipment_choices: int = 0


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
	quest_log.reset()
	counters = {}
	zone_log = []
	zone_run = null
	pending_level_ups = []
	pending_equipment_choices = 0
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


## New brief (third), Part D: the hidden tunnel in the starting area's bottom-left corner - the
## player still picks their element (the same `ElementChoiceScreen`), then gets a real, legal
## 45-card deck (the 42-card starter + 3 *random* on-element cards, `CampaignStart.
## random_element_cards` - unlike the normal tutorial's 3 curated reward picks), the same total
## XP/gold the tutorial's battles/boss would have paid (`TrialOfTheHollow.
## total_tutorial_rewards`), and the same tutorial-complete flags a real clear leaves, so the town
## opens normally. Only usable before a profile exists (a first-ever run), like the tunnel itself.
const SECRET_TUNNEL_ID: String = "starting_area_tunnel"


func skip_tutorial_via_secret_tunnel(color: Affinity.Type) -> void:
	if profile != null:
		return
	profile = CampaignStart.new_profile(content, color)
	var picks: Array[CardData] = CampaignStart.random_element_cards(content, color, 3, rng)
	profile.owned_cards.append_array(picks)
	profile.intro_dungeon_cleared = true
	deck = CampaignStart.starter_deck(content, color)
	deck.cards.append_array(picks)
	deck.deck_name = DECK_NAME
	cleared_dungeons.append(TrialOfTheHollow.DUNGEON_NAME)
	set_flag(&"trial_cleared")
	discover_secret(SECRET_TUNNEL_ID)
	var totals: Dictionary = TrialOfTheHollow.total_tutorial_rewards()
	add_gold(int(totals.get("gold", 0)))
	add_xp(int(totals.get("xp", 0)))
	save_game()


func has_profile() -> bool:
	return profile != null


# ---- Gold, flags, collection ------------------------------------------------------------


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	EventBus.gold_changed.emit(gold)


## New brief, Part D: the price actually shown/charged after the profile's vendor_discount_percent
## reward(s) - the one place every vendor screen (cards, items, equipment) should read a price
## through, so a discount can never apply in some shops and not others.
func effective_price(base_price: int) -> int:
	return profile.discounted_price(base_price) if profile != null else base_price


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
	refresh_quests()


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
		refresh_quests()
		save_game()


## A plain-data snapshot for Condition.met() - see core/data/unlock_state.gd.
func unlock_state() -> UnlockState:
	var state: UnlockState = UnlockState.new()
	state.flags = flags
	state.cleared_dungeons = cleared_dungeons
	state.found_secrets = found_secrets
	state.gold_spent = gold_spent_total
	state.player_level = profile.level if profile != null else 0
	state.completed_quests = completed_quests
	state.counters = counters
	if profile != null:
		for card: CardData in profile.owned_cards:
			state.owned_cards[card.id] = int(state.owned_cards.get(card.id, 0)) + 1
	return state


func add_cards(cards: Array[CardData]) -> void:
	if profile == null:
		return
	profile.owned_cards.append_array(cards)
	EventBus.collection_changed.emit()
	refresh_quests()


## New brief, Part D: grants one consumable item (chests, and the item vendor in Part F). Owning
## an item id at all means one inventory entry with a shared uses-remaining count (see
## PlayerProfile.item_uses_remaining, keyed by id) - granting an already-owned item tops up its
## uses instead of appending a second, indistinguishable entry.
func add_item(item: ItemData) -> void:
	if profile == null or item == null:
		return
	if profile.owns_item(item):
		profile.item_uses_remaining[item.id] = profile.item_uses_left(item) + item.uses
	else:
		profile.owned_items.append(item)
		profile.item_uses_remaining[item.id] = item.uses
	EventBus.collection_changed.emit()


## New brief, Part F: uses an equipped item mid-duel (the battle screen's item bar). Applies the
## effect against the live duel (GameState.use_item), then spends the charge in the profile -
## kept as two steps, not one, so a rejected use (wrong phase, no legal target) never spends a
## charge.
func use_equipped_item(game: GameState, player_index: int, item: ItemData, target: int = 0) -> bool:
	if profile == null or not profile.is_item_equipped(item):
		return false
	if not game.use_item(player_index, item, target):
		return false
	profile.spend_item_charge(item)
	save_game()
	return true


## New brief, Part F: buys one unit of `item` from a vendor (spends gold, grants the item via
## add_item's top-up-or-add logic above).
func buy_item(item: ItemData, price: int) -> bool:
	if item == null or not spend_gold(price):
		return false
	add_item(item)
	save_game()
	return true


# ---- Progression (Part E) ----------------------------------------------------------------


## Awards XP and applies every level gained (in order), including each level's reward. Returns
## the LevelData for every level gained (empty if the player did not level up).
func add_xp(amount: int) -> Array[LevelData]:
	if profile == null or amount <= 0:
		return []
	var old_level: int = profile.level
	profile.xp += amount
	var new_level: int = ProgressionTable.level_for_xp(profile.xp)
	var gained: Array[LevelData] = []
	for level: int in range(old_level + 1, new_level + 1):
		var row: LevelData = ProgressionTable.row(level)
		profile.apply_level(row)
		_apply_level_rewards(row)
		gained.append(row)
	if not gained.is_empty():
		EventBus.collection_changed.emit()
		save_game()
	return gained


## New brief (third), Part E: the town's Dev Shrine - each interaction grants exactly one level
## (up to MAX_LEVEL), running the real level-up flow (LevelUpScreen, rewards, equipment choices)
## exactly like a real battle's XP would - by handing `add_xp` exactly the XP needed to cross one
## more level threshold, no more, no less. Returns the granted LevelData in an array (empty if
## already at max level, matching `add_xp`'s own "empty means nothing happened" convention) - see
## DevTools.shrine_enabled() for whether the shrine exists at all.
func grant_dev_level() -> Array[LevelData]:
	if profile == null or profile.level >= ProgressionTable.MAX_LEVEL:
		return []
	var needed: int = ProgressionTable.xp_to_reach(profile.level + 1) - profile.xp
	return add_xp(maxi(needed, 1))


func _apply_level_rewards(row: LevelData) -> void:
	if row.reward_gold > 0:
		add_gold(row.reward_gold)
	if row.equipment_choice:
		pending_equipment_choices += 1
	if row.reward_vendor_discount_percent > 0:
		profile.vendor_discount_percent += row.reward_vendor_discount_percent
	# row.reward_equipment_vendor_unlock / reward_item_vendor_advanced_unlock need no action here:
	# EquipmentVendorScreen/ItemVendorScreen already gate their advanced stock on
	# Condition.player_level(...) read live against the profile, which apply_level() (above, in
	# add_xp) already updated before this runs. These two fields exist purely so the level-up
	# popup can announce the unlock (LevelUpScreen._bonuses_for).


## New brief, Part C: buys one piece of equipment from the equipment vendor. Unlike items,
## equipment isn't consumable - buying a piece already owned is refused rather than doing
## anything (there is nothing sensible to "top up").
func buy_equipment(piece: EquipmentData, price: int) -> bool:
	if profile == null or piece == null or profile.owned_equipment.has(piece):
		return false
	if not spend_gold(price):
		return false
	profile.owned_equipment.append(piece)
	EventBus.collection_changed.emit()
	save_game()
	return true


## New brief, Part E: grants one piece of equipment for free (a hidden chest). Same "already
## owned means no-op" rule as buy_equipment, just without the gold cost, and no save_game() of
## its own - matching add_cards/add_item, callers that grant several rewards at once save once.
func grant_equipment(piece: EquipmentData) -> bool:
	if profile == null or piece == null or profile.owned_equipment.has(piece):
		return false
	profile.owned_equipment.append(piece)
	EventBus.collection_changed.emit()
	return true


## Equips an owned piece, unequipping whatever was in that slot. Saves on success.
func equip_item(item: EquipmentData) -> bool:
	if profile == null or not profile.equip(item):
		return false
	save_game()
	return true


func unequip_slot(slot: EquipmentData.Slot) -> void:
	if profile == null or profile.unequip(slot) == null:
		return
	save_game()


## Part E: resolves one of the level-5/10/15/20/25 equipment-slot choices.
func choose_equipment_slot(slot: EquipmentData.Slot) -> bool:
	if profile == null or pending_equipment_choices <= 0 or not profile.unlock_equipment_slot(slot):
		return false
	pending_equipment_choices -= 1
	save_game()
	return true


## Uses one charge of an owned item against the current dungeon run (if any).
func use_item(item: ItemData) -> bool:
	if profile == null or not profile.use_item(item, life_run()):
		return false
	save_game()
	return true


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
	var owned_equipment_ids: Array[String] = []
	for piece: EquipmentData in profile.owned_equipment:
		owned_equipment_ids.append(piece.id)
	var equipped_ids: Array[String] = []
	for piece: ModifierSource in profile.equipment:
		equipped_ids.append((piece as EquipmentData).id)
	var item_saves: Array[Dictionary] = []
	for owned_item: ItemData in profile.owned_items:
		item_saves.append({"id": owned_item.id, "uses_left": profile.item_uses_left(owned_item)})
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
		"completed_quests": completed_quests,
		"quests": quest_log.to_dict(),
		"counters": counters,
		"zone_log": zone_log,
		"level": profile.level,
		"xp": profile.xp,
		"equipment_slots": profile.equipment_slots,
		"owned_equipment": owned_equipment_ids,
		"equipped": equipped_ids,
		"owned_items": item_saves,
		"equipped_items": profile.equipped_item_ids,
		"pending_equipment_choices": pending_equipment_choices,
		"vendor_discount_percent": profile.vendor_discount_percent,
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
	loaded.level = int(data.get("level", 1))
	loaded.xp = int(data.get("xp", 0))
	for slot: Variant in data.get("equipment_slots", []) as Array:
		loaded.equipment_slots.append(int(slot) as EquipmentData.Slot)
	for id: Variant in data.get("owned_equipment", []) as Array:
		var piece: EquipmentData = content.equipment_piece(str(id))
		if piece != null:
			loaded.owned_equipment.append(piece)
	for id: Variant in data.get("equipped", []) as Array:
		var piece: EquipmentData = content.equipment_piece(str(id))
		if piece != null:
			loaded.equipment.append(piece)
	for entry: Variant in data.get("owned_items", []) as Array:
		var entry_dict: Dictionary = entry as Dictionary
		var owned_item: ItemData = content.item(str(entry_dict.get("id", "")))
		if owned_item != null:
			loaded.owned_items.append(owned_item)
			loaded.item_uses_remaining[owned_item.id] = int(entry_dict.get("uses_left", owned_item.uses))
	for id: Variant in data.get("equipped_items", []) as Array:
		loaded.equipped_item_ids.append(str(id))
	loaded.vendor_discount_percent = int(data.get("vendor_discount_percent", 0))
	profile = loaded
	deck = Deck.new()
	deck.deck_name = DECK_NAME
	for id: Variant in data.get("deck", []) as Array:
		var card: CardData = card_by_id(str(id))
		if card != null:
			deck.cards.append(card)
	gold = int(data.get("gold", 0))
	flags = (data.get("flags", {}) as Dictionary).duplicate()
	# Part A rename (Grave -> Necrocrat): old saves used the "grave" zone id.
	if flags.has("grave_zone_unlocked") and not flags.has("necrocrat_zone_unlocked"):
		flags["necrocrat_zone_unlocked"] = flags["grave_zone_unlocked"]
	run = null
	dungeon_map = null
	gold_spent_total = int(data.get("gold_spent_total", 0))
	cleared_dungeons.assign(data.get("cleared_dungeons", []) as Array)
	seen_cards = {}
	for id: Variant in data.get("seen_cards", []) as Array:
		seen_cards[str(id)] = true
	found_secrets.assign(data.get("found_secrets", []) as Array)
	quest_log.from_dict(data.get("quests", {"completed": data.get("completed_quests", [])}) as Dictionary)
	counters = (data.get("counters", {}) as Dictionary).duplicate()
	zone_log.assign(data.get("zone_log", []) as Array)
	zone_run = null
	pending_level_ups = []
	pending_equipment_choices = int(data.get("pending_equipment_choices", 0))
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
	context.ai = AIPlayer.new(ZoneDecks.personality(content, node.ai_name) if mini_active else TrialOfTheHollow.personality(content, node.ai_name))
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
	var enemy: PlayerSetup = MiniDungeon.enemy_setup(content, node) if mini_active else TrialOfTheHollow.enemy_setup(content, node)
	var game: GameState = run.start_encounter(enemy, null, options)
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(ZoneDecks.personality(content, node.ai_name) if mini_active else TrialOfTheHollow.personality(content, node.ai_name))
	context.enemy_name = node.enemy_name
	context.enemy_icon = str(ENEMY_ICONS.get(node.enemy_name, "lorc/imp"))
	context.node_id = node.id
	context.tutorial = node.tutorial
	context.is_boss = node.kind == DungeonMap.Kind.BOSS
	context.gold_reward = node.gold_reward
	context.xp_reward = EncounterRewards.xp_for(node.difficulty)
	context.card_choices = node.card_choices
	return context


func start_battle(context: BattleContext) -> void:
	pending_battle = context
	SceneManager.change_scene("res://scenes/battle.tscn")


# ---- Corrupted NPCs (new brief, Part E) --------------------------------------------------

## Set by _complete_npc_challenge, read once by TownScene._ready() to show the right post-fight
## dialogue (and, on a first win, the reward toast), then cleared. {} when there is nothing to
## show (e.g. town was reached some other way).
var pending_npc_result: Dictionary = {}


## A duel against one of the 4 corrupted NPCs, using the player's real current deck/profile (not
## a "typical" reference deck - that only exists for balance simulation, see
## core/dungeon/corrupted_npcs.gd). Full life, like a fresh duel - not carried over from anywhere.
func make_npc_challenge_battle(id: String) -> BattleContext:
	ensure_game()
	var options: GameOptions = GameOptions.new()
	options.first_player = -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(deck, profile, [] as Array[ModifierSource], "You"))
	game.add_player(CorruptedNpcs.enemy_setup(content, id))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(CorruptedNpcs.personality(content, id))
	context.enemy_name = CorruptedNpcs.display_name(id)
	context.town_npc_id = id
	return context


func challenge_corrupted_npc(id: String) -> void:
	start_battle(make_npc_challenge_battle(id))


## Winning the first time grants a one-time reward (gold, XP, an item) and unlocks that element's
## zone entrance (D66's contract). Rematches (win or lose) are always allowed but never pay out
## again - see docs/design/open_questions.md D68 for why repeatable-but-unrewarded was chosen
## over "they no longer fight".
func _complete_npc_challenge(context: BattleContext) -> void:
	var id: String = context.town_npc_id
	var already_defeated: bool = flag(CorruptedNpcs.unlock_flag(id))
	var first_win: bool = context.won and not already_defeated
	pending_npc_result = {"id": id, "won": context.won, "first_win": first_win}
	if first_win:
		set_flag(CorruptedNpcs.unlock_flag(id))
		add_gold(CorruptedNpcs.reward_gold())
		var gained: Array[LevelData] = add_xp(CorruptedNpcs.reward_xp())
		pending_npc_result["levels_gained"] = gained
		var item: ItemData = CorruptedNpcs.reward_item(content, id)
		if item != null:
			add_item(item)
			pending_npc_result["item_name"] = item.display_name
	save_game()
	SceneManager.go_to_town()


# ---- The Graveyard (fourth brief, Part F) -------------------------------------------------

## Set by _complete_graveyard_challenge, read once by TownScene._ready() to show the right
## post-fight dialogue (and, on a first win, the reward toast), then cleared. {} when there is
## nothing to show. Mirrors pending_npc_result above.
var pending_graveyard_result: Dictionary = {}


## The Graveyard's scripted battle, using the player's real current deck/profile (not a
## reference deck) at full life - a real, standalone fight, not carried over from a dungeon run.
func make_graveyard_battle() -> BattleContext:
	ensure_game()
	var options: GameOptions = GameOptions.new()
	options.first_player = -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(deck, profile, [] as Array[ModifierSource], "You"))
	game.add_player(GraveyardBoss.enemy_setup(content))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(GraveyardBoss.personality(content))
	context.enemy_name = GraveyardBoss.DISPLAY_NAME
	context.is_boss = true
	context.is_graveyard_boss = true
	return context


func challenge_graveyard_boss() -> void:
	start_battle(make_graveyard_battle())


## Winning the first time grants a one-time reward (gold, XP, a piece of equipment no vendor
## sells yet) - see GraveyardBoss.REWARD_*. Losing (or a rematch after already winning) pays
## nothing, but the fight can always be tried again - same "repeatable but unrewarded past the
## first win" choice as the corrupted NPCs (D68), for the same reason.
func _complete_graveyard_challenge(context: BattleContext) -> void:
	var already_won: bool = flag(&"graveyard_boss_defeated")
	var first_win: bool = context.won and not already_won
	pending_graveyard_result = {"won": context.won, "first_win": first_win}
	if first_win:
		set_flag(&"graveyard_boss_defeated")
		add_gold(GraveyardBoss.REWARD_GOLD)
		var gained: Array[LevelData] = add_xp(GraveyardBoss.REWARD_XP)
		pending_graveyard_result["levels_gained"] = gained
		var piece: EquipmentData = GraveyardBoss.reward_equipment(content)
		if piece != null and grant_equipment(piece):
			pending_graveyard_result["equipment_name"] = piece.source_name
	save_game()
	SceneManager.go_to_town()


# ---- Quests (brief 5, Part B) -------------------------------------------------------------

var _refreshing_quests: bool = false


## Adds `amount` to a named progress counter (Condition.COUNTER) and re-checks active quests.
func bump_counter(key: String, amount: int = 1) -> void:
	counters[key] = int(counters.get(key, 0)) + amount
	refresh_quests()


func counter(key: String) -> int:
	return int(counters.get(key, 0))


## Starts a quest if it exists, is not active/completed and its prerequisite is met.
func start_quest(quest_id: String) -> bool:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null or not quest_log.start(quest, unlock_state()):
		return false
	EventBus.quest_notice.emit("New quest: %s" % quest.title, true)
	EventBus.quest_changed.emit()
	save_game()
	refresh_quests()
	return true


## Starts every auto-given quest whose prerequisite is met (town entry calls this).
func offer_auto_quests() -> void:
	if profile == null:
		return
	for quest: QuestData in QuestCatalog.all():
		if quest.auto_give:
			start_quest(quest.id)


## Completes any active quest whose objectives are all met and that needs no turn-in, and tells
## the HUD to redraw. Cheap; called whenever a flag, secret, counter, card or XP value changes.
func refresh_quests() -> void:
	if _refreshing_quests or profile == null:
		return
	_refreshing_quests = true
	var state: UnlockState = unlock_state()
	for quest_id: String in quest_log.auto_completable(QuestCatalog.all(), state):
		complete_quest(quest_id)
	_refreshing_quests = false
	EventBus.quest_changed.emit()


## Completes an active quest and pays its rewards. Returns false if it was not active.
func complete_quest(quest_id: String) -> bool:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null or not quest_log.complete(quest_id):
		return false
	if quest.reward_gold > 0:
		add_gold(quest.reward_gold)
	for item_id: String in quest.reward_item_ids:
		add_item(content.item(item_id))
	var cards: Array[CardData] = []
	for card_id: String in quest.reward_card_ids:
		var card: CardData = card_by_id(card_id)
		if card != null:
			cards.append(card)
	if not cards.is_empty():
		add_cards(cards)
	for equipment_id: String in quest.reward_equipment_ids:
		grant_equipment(content.equipment_piece(equipment_id))
	for flag_name: String in quest.reward_unlock_flags:
		flags[flag_name] = true
	if quest.reward_xp > 0:
		pending_level_ups.append_array(add_xp(quest.reward_xp))
	var rewards: String = quest.reward_summary()
	var suffix: String = ("  (" + rewards + ")") if not rewards.is_empty() else ""
	EventBus.quest_notice.emit("Quest complete: %s%s" % [quest.title, suffix], false)
	EventBus.quest_changed.emit()
	save_game()
	return true


## Turn-in at an NPC: completes the quest if it is ready. Returns true on success.
func turn_in_quest(quest_id: String) -> bool:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null or not quest_log.is_ready_to_turn_in(quest, unlock_state()):
		return false
	return complete_quest(quest_id)


## Quests this NPC (display name) can currently offer, and quests ready to be handed in to them.
func quests_offered_by(npc_name: String) -> Array[QuestData]:
	var result: Array[QuestData] = []
	var state: UnlockState = unlock_state()
	for quest: QuestData in QuestCatalog.all():
		if quest.giver_npc == npc_name and quest_log.can_start(quest, state):
			result.append(quest)
	return result


func quests_ready_for(npc_name: String) -> Array[QuestData]:
	var result: Array[QuestData] = []
	var state: UnlockState = unlock_state()
	for quest: QuestData in QuestCatalog.all():
		if quest.turn_in_npc == npc_name and quest_log.is_ready_to_turn_in(quest, state):
			result.append(quest)
	return result


# ---- Zones (brief 5: the D.N.A.) ----------------------------------------------------------

const DNA_SCENE: String = "res://scenes/dna_zone.tscn"
const ZONE_LOG_LIMIT: int = 40

## The current zone visit (null in town). Holds the life that persists across the whole visit.
var zone_run: ZoneRun
## Set when the zone scene (re)loads after a battle/minigame, read once by it: {} when nothing.
var pending_zone_result: Dictionary = {}
## Every paperwork fee ever charged ("log it") - newest last, saved with the campaign.
var zone_log: Array[String] = []


func in_zone() -> bool:
	return zone_run != null


## The run that item use and healing apply to: the dungeon run, else the zone visit's life.
func life_run() -> DungeonRun:
	if in_dungeon():
		return run
	return zone_run.run if zone_run != null else null


## Entering from town: a brand-new visit, always at full life (town heals fully).
func enter_dna() -> void:
	zone_run = ZoneRun.enter(DnaZone.ID, profile, deck)
	pending_zone_result = {}
	SceneManager.change_scene(DNA_SCENE)


## Walking back out to town. Town is a full heal, so the visit simply ends.
func leave_zone() -> void:
	zone_run = null
	pending_zone_result = {}
	SceneManager.go_to_town()


func log_paperwork_fee(line: String) -> void:
	zone_log.append(line)
	while zone_log.size() > ZONE_LOG_LIMIT:
		zone_log.remove_at(0)


## Carried to the hub at 0 life: full life again, pay the paperwork fee, log it. Returns the fee.
func zone_wake_at_hub(cause: String) -> int:
	if zone_run == null:
		return 0
	var fee: int = zone_run.wake_at_hub(gold, cause)
	if fee > 0:
		spend_gold(fee)
	log_paperwork_fee("Paperwork fee %d gold - %s" % [fee, cause])
	counters["paperwork_fees_paid"] = int(counters.get("paperwork_fees_paid", 0)) + fee
	zone_run.has_return_position = false
	save_game()
	return fee


## A duel against a roaming zone enemy: the player's real deck at the zone's persistent life.
func make_zone_battle(enemy_type: String, enemy_instance_id: String) -> BattleContext:
	ensure_game()
	var data: DnaEnemies.Info = DnaEnemies.info(enemy_type)
	var options: GameOptions = GameOptions.new()
	options.first_player = -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	var buffs: Array[ModifierSource] = []
	if zone_run != null:
		buffs = zone_run.run.dungeon_sources
	var player: PlayerSetup = PlayerSetup.create(deck, profile, buffs, "You")
	if zone_run != null:
		player.starting_life = zone_run.life
	game.add_player(player)
	game.add_player(DnaEnemies.enemy_setup(content, enemy_type))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(DnaEnemies.personality(content, enemy_type))
	context.enemy_name = data.display_name
	context.zone_battle = true
	context.zone_enemy_id = enemy_instance_id
	context.zone_enemy_type = enemy_type
	context.gold_reward = data.gold_reward
	context.xp_reward = data.xp_reward
	return context


func start_zone_battle(enemy_type: String, enemy_instance_id: String) -> void:
	start_battle(make_zone_battle(enemy_type, enemy_instance_id))


## After a zone duel: life carries over (no post-battle heal). A win removes that enemy for the rest
## of the visit and pays a small reward; a loss (0 life) wakes the player at the hub, minus the fee.
func _complete_zone_battle(context: BattleContext) -> void:
	var result: Dictionary = {"kind": "battle", "won": context.won, "enemy": context.enemy_name}
	if zone_run == null:
		zone_run = ZoneRun.enter(DnaZone.ID, profile, deck)
	zone_run.finish_battle(context.game)
	if context.won:
		zone_run.mark_defeated(context.zone_enemy_id)
		add_gold(context.gold_reward)
		result["gold"] = context.gold_reward
		result["levels_gained"] = add_xp(context.xp_reward)
		result["xp"] = context.xp_reward
		bump_counter("zone_enemies_defeated")
	if zone_run.is_down() or not context.won:
		var fee: int = zone_wake_at_hub("beaten by a %s" % context.enemy_name)
		result["woke_at_hub"] = true
		result["fee"] = fee
	pending_zone_result = result
	save_game()
	SceneManager.change_scene(DNA_SCENE)


# ---- Mini dungeon (brief 5, Part E) -------------------------------------------------------

## True while a run on `MiniDungeon`'s map is going (so the shared dungeon screens know to return
## to the zone instead of town).
var mini_active: bool = false


## From the zone's elevator: a run that starts at the zone's current life (no healing).
func enter_mini_dungeon() -> void:
	if zone_run == null:
		return
	dungeon_map = MiniDungeon.build_map()
	run = DungeonRun.enter(profile, deck, zone_run.run.dungeon_sources)
	run.life = clampi(zone_run.life, 1, run.max_life())
	mini_active = true
	trial_finished = false
	pending_reward = null
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Leaves the mini dungeon back to the zone. The life left goes back to the zone; clearing it the
## first time grants the unique card. `failed` (0 life) wakes the player at the hub with the fee.
func finish_mini_dungeon(cleared: bool, failed: bool = false) -> void:
	resolve_mini_dungeon(cleared, failed)
	SceneManager.change_scene(DNA_SCENE)


## The state changes of leaving the mini dungeon (no scene change, so tests can run it).
func resolve_mini_dungeon(cleared: bool, failed: bool = false) -> Dictionary:
	var result: Dictionary = {"kind": "mini", "cleared": cleared, "failed": failed}
	if zone_run != null and run != null:
		zone_run.life = run.life
	if cleared and not flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED):
		set_flag(DnaZone.FLAG_MINI_DUNGEON_CLEARED)
		var card: CardData = card_by_id(MiniDungeon.REWARD_CARD_ID)
		if card != null:
			add_cards([card] as Array[CardData])
			result["card"] = card.display_name
		result["first_clear"] = true
	run = null
	dungeon_map = null
	mini_active = false
	trial_finished = false
	pending_reward = null
	if zone_run != null and (failed or zone_run.is_down()):
		result["fee"] = zone_wake_at_hub("sent home from Quarterly Reviews")
		result["woke_at_hub"] = true
	pending_zone_result = result
	save_game()
	return result


# ---- Zone portals (Part G) ---------------------------------------------------------------

## Which placeholder zone (`ZonePortals.Info.id`) the placeholder scene should show.
var pending_zone_id: String = ""


func enter_zone_portal(zone_id: String) -> void:
	pending_zone_id = zone_id
	SceneManager.change_scene("res://scenes/zone_placeholder.tscn")


## Called by the battle screen when the player leaves the result panel.
func complete_battle(context: BattleContext) -> void:
	pending_battle = null
	if not context.town_npc_id.is_empty():
		_complete_npc_challenge(context)
		return
	if context.zone_battle:
		_complete_zone_battle(context)
		return
	if context.is_graveyard_boss:
		_complete_graveyard_challenge(context)
		return
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
	offer.xp = context.xp_reward
	offer.is_boss = context.is_boss
	offer.enemy_name = context.enemy_name
	offer.levels_gained = add_xp(context.xp_reward)
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
		# Safety net: the Hollow Well challenge can cost a card (D51/D62) - normally the 3
		# reward picks land exactly on 45, but if the challenge went badly the player would
		# otherwise walk into town one card short of a legal deck. A basic land of their own
		# color always keeps it legal without changing the "3 on-element picks" story.
		if deck.size() < DeckValidator.MIN_DECK_SIZE:
			var land: CardData = content.lands[int(profile.primary_affinity)] as CardData
			while deck.size() < DeckValidator.MIN_DECK_SIZE:
				deck.cards.append(land)
	profile.intro_dungeon_cleared = true
	set_flag(&"trial_cleared")
	run = null
	dungeon_map = null
	if not cleared_dungeons.has(TrialOfTheHollow.DUNGEON_NAME):
		cleared_dungeons.append(TrialOfTheHollow.DUNGEON_NAME)
	EventBus.collection_changed.emit()
	save_game()


func abandon_run(notice: String = "") -> void:
	if mini_active:
		finish_mini_dungeon(false, run != null and (run.failed or run.life <= 0))
		return
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
