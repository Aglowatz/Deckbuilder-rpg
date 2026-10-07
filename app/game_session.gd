extends Node
## The running game's shared state: content, the player's profile/collection/deck, gold, story
## flags, and the current dungeon run. Everything here is plain data that SaveSystem stores.

const STARTING_GOLD: int = 120
const DECK_NAME: String = "Wanderer's Deck"

## Set to false by tools and tests so they never touch the player's real save file.
var save_enabled: bool = true
## Where the campaign is saved (tests use their own file).
var save_path: String = SaveSystem.PATH
## Brief 16: seconds played (saved with the campaign, shown in the save slot list), the last place the hero was saved in and when the autosave thumbnail was last taken.
var playtime_seconds: float = 0.0
var last_location: String = "Concord Crossing"
var _last_autosave_thumb_msec: int = -100000
## Which slot the game was last loaded from or saved to (0 = the autosave).
var active_slot: int = 0

var content: ContentSet
## The global notification layer (essence conversions, toasts) - see `ToastLayer`.
var toasts: ToastLayer
var profile: PlayerProfile
var gold: int = 0
## The ACTIVE deck: what battles and dungeons use. It always mirrors the active slot of `deck_box` (assigning it writes the cards into that slot).
var deck: Deck:
	set(value):
		deck = value
		_sync_active_deck()
## Brief 16: the saved decks (names + card ids). See DeckBox.
var deck_box: DeckBox = DeckBox.new()
var _deck_sync_paused: bool = false
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
## Hats, cloaks and dyes (purely visual; saved with the campaign).
var cosmetics: CosmeticState = CosmeticState.new()
## Level-ups earned outside a battle (quest rewards...) that the current scene still has to show.
var pending_level_ups: Array[LevelData] = []
## Polish round: reward boxes waiting to be shown (a finished quest's "Quest Complete" box). The world scenes show them one by one before any level-up popup.
var pending_popups: Array[RewardSummary] = []
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
	toasts = ToastLayer.new()
	toasts.name = "ToastLayer"
	add_child(toasts)
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--no-save":
			save_enabled = false
	if save_enabled and save_path == SaveSystem.PATH:
		SaveSlots.migrate_legacy()



func _process(delta: float) -> void:
	if profile != null and not get_tree().paused:
		playtime_seconds += delta

# ---- Campaign lifecycle -----------------------------------------------------------------


## Version of the campaign save layout. Bump it whenever a change makes old saves unreadable (ids
## renamed, systems added); `discard_incompatible_save` then resets the old save gracefully.
const SAVE_FORMAT: int = 3

## Set when an old save was reset; the title screen shows it once and clears it.
var save_reset_message: String = ""


func has_save() -> bool:
	return SaveSystem.exists(save_path)


## True when the file at `save_path` was written by this save format.
func save_is_compatible() -> bool:
	return int(SaveSystem.read(save_path).get("save_format", 1)) == SAVE_FORMAT


## Resets a save from an older format (proof-of-concept policy: no migration). The old file is kept
## next to the new one as `<name>.old`, and `save_reset_message` explains what happened. Returns
## true when a save was discarded.
func discard_incompatible_save() -> bool:
	if not has_save() or save_is_compatible():
		return false
	var backup: String = save_path + ".old"
	if FileAccess.file_exists(backup):
		DirAccess.remove_absolute(backup)
	DirAccess.rename_absolute(save_path, backup)
	save_reset_message = "Your old save came from an earlier version of the game (the new card set, Resources and renamed terms) and could not be loaded. It was reset - please start a new game. (The old file was kept as save.json.old.)"
	return true


## Starts a fresh campaign. The profile is created when the Wellspring is chosen.
func new_game() -> void:
	profile = null
	deck_box = DeckBox.new()
	deck = Deck.new()
	deck.deck_name = DECK_NAME
	gold = STARTING_GOLD
	flags = {}
	playtime_seconds = 0.0
	active_slot = 0
	_sync_freed_stories()
	run = null
	dungeon_map = null
	gold_spent_total = 0
	cleared_dungeons = []
	seen_cards = {}
	found_secrets = []
	quest_log.reset()
	counters = {}
	cosmetics = CosmeticState.new()
	zone_log = []
	map_fog = {}
	_fog_live = {}
	zone_run = null
	pending_level_ups = []
	pending_popups = []
	pending_equipment_choices = 0
	rng.randomize()


## Makes sure a complete, post-tutorial game exists (used when a scene - town, the vendor, the
## deck station... - is launched directly for testing/screenshots, skipping the starting area
## and the tutorial dungeon).
func ensure_game(color: Affinity.Type = Affinity.Type.BEEFCAKE) -> void:
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
		choose_starting_look("hat_wide_brim", "cloak_short", 1, 0)  # screenshot/test launches skip the starting area: a default look


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


## ---- Zone completion (Part D) -------------------------------------------------------------


func is_zone_completed(zone_id: String) -> bool:
	return ZoneCompletion.is_completed(flags, zone_id)


func completed_zone_count() -> int:
	return ZoneCompletion.count(flags)


func arena_unlocked() -> bool:
	return ZoneCompletion.arena_unlocked(flags)


func alchemist_unlocked() -> bool:
	return ZoneCompletion.alchemist_unlocked(flags)


## Frees a zone (its dungeon boss was defeated): sets the saved flag once, switches the zone's story
## to its freed text, fires `EventBus.zone_completed` (the Arena and the Alchemist unlock from it)
## and saves. Returns true only the first time.
func complete_zone(zone_id: String) -> bool:
	if not ZoneDefs.has_def(zone_id) or is_zone_completed(zone_id):
		return false
	flags[str(ZoneCompletion.flag_name(zone_id))] = true
	_sync_freed_stories()
	refresh_quests()
	EventBus.zone_completed.emit(zone_id)
	save_game()
	return true


## Makes every zone story agree with the completion flags (after a load, a new game or a completion).
func _sync_freed_stories() -> void:
	for zone_id: String in ZoneDefs.all_ids():
		ZoneStoryText.set_zone_freed(zone_id, is_zone_completed(zone_id))


func flag(name: StringName) -> bool:
	return bool(flags.get(str(name), false))


func set_flag(name: StringName, value: bool = true) -> void:
	flags[str(name)] = value
	refresh_quests()


## Any card (spell, token or basic infrastructure) by its id.
func card_by_id(id: String) -> CardData:
	var found: CardData = content.card(id)
	if found != null:
		return found
	for infra: Variant in content.infrastructure.values():
		if (infra as CardData).id == id:
			return infra as CardData
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
	state.zones_completed = ZoneCompletion.count(flags)
	state.postgame = profile != null and profile.postgame_unlocked
	if profile != null:
		for card: CardData in profile.owned_cards:
			state.owned_cards[card.id] = int(state.owned_cards.get(card.id, 0)) + 1
	return state


## The Alchemist (Part F): trades ALL essence of two Paths plus gold for a random dual-Path card of those Paths
## (`Alchemy.craft`). On success the gold is paid and the card joins the collection (an extra copy converts like any
## other). The result says why a trade could not be made.
func craft_dual_card(first: Affinity.Type, second: Affinity.Type) -> Alchemy.Result:
	if profile == null:
		return Alchemy.Result.new()
	var result: Alchemy.Result = Alchemy.craft(content, profile, gold, first, second, rng)
	if result.ok:
		spend_gold(result.gold_spent)
		add_cards([result.card] as Array[CardData])
		bump_counter("cards_crafted")
		save_game()
	return result

## Adds cards to the collection. A player may own at most `DeckValidator.MAX_COPIES` (4) copies of a card:
## an extra copy is NOT kept but converts into Path essence of its Path (more for higher rarity), or into gold
## for a neutral card (`Essence`); each conversion fires `EventBus.essence_converted` (the toast layer shows
## it). Infrastructure is unlimited. Returns the conversion messages (empty when nothing converted).
func add_cards(cards: Array[CardData]) -> Array[String]:
	var notices: Array[String] = []
	if profile == null:
		return notices
	for card: CardData in cards:
		if card.is_unlimited() or profile.owned_copies(card.id) < DeckValidator.MAX_COPIES:
			profile.owned_cards.append(card)
			continue
		var conversion: Dictionary = Essence.conversion(card)
		var essence_by_path: Dictionary = conversion["essence"] as Dictionary
		for path: Variant in essence_by_path.keys():
			profile.add_essence(int(path) as Affinity.Type, int(essence_by_path[path]))
		var gold_amount: int = int(conversion["gold"])
		if gold_amount > 0:
			add_gold(gold_amount)
		var text: String = Essence.message(card, conversion)
		notices.append(text)
		EventBus.essence_converted.emit(text, essence_by_path, gold_amount)
	EventBus.collection_changed.emit()
	refresh_quests()
	return notices


# ---- Card packs -----------------------------------------------------------------------------


func pack_count(pack_id: String) -> int:
	return profile.pack_count(pack_id) if profile != null else 0


## Puts unopened packs into the inventory. False for an unknown pack id.
func add_pack(pack_id: String, amount: int = 1) -> bool:
	if profile == null or PackCatalog.find(pack_id) == null or amount <= 0:
		return false
	profile.add_pack(pack_id, amount)
	EventBus.packs_changed.emit()
	return true


## Buys one pack from a vendor: pays the price (with the vendor discount) and adds it to the inventory.
func buy_pack(pack: PackData) -> bool:
	if profile == null or pack == null:
		return false
	if not spend_gold(PackShop.price_for(pack, profile)):
		return false
	add_pack(pack.id)
	bump_counter("packs_bought")
	save_game()
	return true


## Opens one pack from the inventory (a seeded `rng` can be passed for tests): rolls its cards, adds them to the collection (an
## extra copy beyond 4 converts into essence/gold, exactly like any other card) and returns what came out. Null if there is no
## such pack in the inventory.
func open_pack(pack_id: String, pack_rng: RandomNumberGenerator = null) -> PackOpening:
	var pack: PackData = PackCatalog.find(pack_id)
	if profile == null or pack == null or not profile.take_pack(pack_id):
		return null
	var opening: PackOpening = PackOpening.new()
	opening.pack = pack
	for card: CardData in PackRoller.roll(pack, content, pack_rng if pack_rng != null else rng):
		var entry: PackOpening.Entry = PackOpening.Entry.new()
		entry.card = card
		entry.is_new = owned_count(card.id) == 0 and not card.is_unlimited()
		if not card.is_unlimited() and owned_count(card.id) >= DeckValidator.MAX_COPIES:
			var conversion: Dictionary = Essence.conversion(card)
			entry.converted = true
			entry.essence = (conversion["essence"] as Dictionary).duplicate()
			entry.gold = int(conversion["gold"])
			entry.notice = Essence.message(card, conversion)
		add_cards([card] as Array[CardData])
		opening.entries.append(entry)
	bump_counter("packs_opened")
	EventBus.packs_changed.emit()
	save_game()
	return opening


## "Beefcake Pack" / "2x Gilded Necrocrat Pack" for reward text.
func pack_label(pack_id: String, amount: int = 1) -> String:
	var pack: PackData = PackCatalog.find(pack_id)
	var title: String = pack.display_name if pack != null else pack_id
	return title if amount == 1 else "%dx %s" % [amount, title]


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


## The Capital's Famine debuff: while the Gourmand zone is not free, healing consumables (the kingdom's food and provisions) do
## nothing in the Capital and its castle. Used by `use_item` and the character screen.
func healing_blocked_for(item: ItemData) -> bool:
	if item == null or item.effect == null or item.effect.op != CardEnums.EffectOp.GAIN_HP:
		return false
	if zone_run == null or zone_run.zone_id != CapitalZone.ID:
		return false
	return CapitalDebuffs.food_healing_blocked(flags)


## Uses one charge of an owned item against the current dungeon run (if any).
func use_item(item: ItemData) -> bool:
	if healing_blocked_for(item):
		return false
	if profile == null or not profile.use_item(item, hp_run()):
		return false
	save_game()
	return true


func deck_issues() -> Array[DeckValidator.Issue]:
	return DeckValidator.validate(deck, profile, null, true)


func deck_is_valid() -> bool:
	return profile != null and deck_issues().is_empty()


## True when at least one saved deck is legal (the player can then pick it before a dungeon or an arena fight).
func any_deck_valid() -> bool:
	if profile == null:
		return false
	for index: int in range(deck_box.size()):
		var candidate: Deck = deck_box.build(index, deck_lookup())
		if DeckValidator.validate(candidate, profile, null, true).is_empty():
			return true
	return deck_is_valid()


## Picks a legal starter-based deck automatically (used when the saved deck is missing/corrupt,
## e.g. an old save). CampaignStart.starter_deck is only 42 cards (Part C, meant to be topped up
## by tutorial rewards); pad it with a few more basic infrastructure of the same color so this fallback is
## always a legal 45+ card deck outside the dungeon, where there is no size waiver.
func rebuild_starter_deck() -> void:
	deck = CampaignStart.starter_deck(content, profile.primary_affinity)
	var infra: CardData = content.infrastructure[int(profile.primary_affinity)] as CardData
	while deck.size() < DeckValidator.MIN_DECK_SIZE:
		deck.cards.append(infra)
	deck.deck_name = DECK_NAME


# ---- Save / load ------------------------------------------------------------------------


func to_dict() -> Dictionary:
	_sync_active_deck()  # code that appended cards to `deck` in place is picked up here
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
		"save_format": SAVE_FORMAT,
		"primary": int(profile.primary_affinity),
		"intro_cleared": profile.intro_dungeon_cleared,
		"postgame": profile.postgame_unlocked,
		"owned": owned,
		"deck": deck_ids,
		"decks": deck_box.to_array(),
		"active_deck": deck_box.active,
		"flags": flags,
		"gold_spent_total": gold_spent_total,
		"cleared_dungeons": cleared_dungeons,
		"seen_cards": seen_cards.keys(),
		"found_secrets": found_secrets,
		"completed_quests": completed_quests,
		"quests": quest_log.to_dict(),
		"counters": counters,
		"zone_log": zone_log,
		"map_fog": _fog_to_dict(),
		"level": profile.level,
		"xp": profile.xp,
		"equipment_slots": profile.equipment_slots,
		"owned_equipment": owned_equipment_ids,
		"equipped": equipped_ids,
		"owned_items": item_saves,
		"equipped_items": profile.equipped_item_ids,
		"pending_equipment_choices": pending_equipment_choices,
		"vendor_discount_percent": profile.vendor_discount_percent,
		"essence": _essence_to_dict(),
		"packs": profile.packs.duplicate(),
		"cosmetics": cosmetics.to_dict(),
		"playtime": playtime_seconds,
		"meta": slot_meta(),
	}


func from_dict(data: Dictionary) -> bool:
	if int(data.get("save_format", 1)) != SAVE_FORMAT:
		return false
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
	var level_row: LevelData = ProgressionTable.row(loaded.level)
	if level_row != null:
		loaded.apply_level(level_row)  # max HP, hand sizes, item and deck slots follow the level (a loaded game used to start from level-1 stats)
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
	for pack_key: Variant in (data.get("packs", {}) as Dictionary).keys():
		loaded.packs[str(pack_key)] = int((data["packs"] as Dictionary)[pack_key])
	for path_key: Variant in (data.get("essence", {}) as Dictionary).keys():
		loaded.essence[int(str(path_key))] = int((data["essence"] as Dictionary)[path_key])
	profile = loaded
	_deck_sync_paused = true
	deck = Deck.new()
	deck.deck_name = DECK_NAME
	for id: Variant in data.get("deck", []) as Array:
		var card: CardData = card_by_id(str(id))
		if card != null:
			deck.cards.append(card)
	if data.has("decks"):
		deck_box = DeckBox.from_array(data["decks"] as Array, int(data.get("active_deck", 0)))
	else:
		deck_box = DeckBox.new()
		deck_box.create(DECK_NAME, DeckBox.ids_of(deck), ProgressionTable.EXPANDED_DECK_SLOTS)
	if deck_box.size() == 0:
		deck_box.create(DECK_NAME, DeckBox.ids_of(deck), ProgressionTable.EXPANDED_DECK_SLOTS)
	_deck_sync_paused = false
	deck = deck_box.build(deck_box.active, deck_lookup())
	gold = int(data.get("gold", 0))
	flags = (data.get("flags", {}) as Dictionary).duplicate()
	playtime_seconds = float(data.get("playtime", 0.0))
	_sync_freed_stories()
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
	cosmetics = CosmeticState.new()
	if data.has("cosmetics"):
		cosmetics.from_dict(data["cosmetics"] as Dictionary)
	else:
		cosmetics.look_chosen = true  # a save from before cosmetics: nothing to choose
	zone_log.assign(data.get("zone_log", []) as Array)
	map_fog = (data.get("map_fog", {}) as Dictionary).duplicate(true)
	_fog_live = {}
	zone_run = null
	pending_level_ups = []
	pending_popups = []
	pending_equipment_choices = int(data.get("pending_equipment_choices", 0))
	if deck.size() == 0 and CampaignStart.is_valid_choice(color):
		rebuild_starter_deck()
	return true


func _essence_to_dict() -> Dictionary:
	var result: Dictionary = {}
	for path: Variant in profile.essence.keys():
		result[str(int(path))] = int(profile.essence[path])
	return result


func save_game() -> void:
	if not save_enabled or profile == null:
		return
	last_location = location_name()
	if save_path != SaveSystem.PATH:
		SaveSystem.write(to_dict(), save_path)
		return
	# The autosave also keeps a small screenshot, refreshed at most every 20 seconds (grabbing the frame is not free).
	var now: int = Time.get_ticks_msec()
	var thumbnail: Image = null
	if now - _last_autosave_thumb_msec > 20000:
		thumbnail = capture_thumbnail()
		if thumbnail != null:
			_last_autosave_thumb_msec = now
	SaveSlots.write(SaveSlots.AUTOSAVE, to_dict(), thumbnail)


## Loads the saved campaign. Returns false when there is none (a game that has not yet reached
## the starting area's cave mouth has no profile and is not saved).
func load_game() -> bool:
	var data: Dictionary = SaveSystem.read(save_path)
	if data.is_empty():
		return false
	return from_dict(data)


# ---- Saved decks (brief 16, Group E) -----------------------------------------------------------------


func _sync_active_deck() -> void:
	if _deck_sync_paused or deck == null:
		return
	if deck_box.size() == 0:
		deck_box.create(deck.deck_name if not deck.deck_name.is_empty() else DECK_NAME, DeckBox.ids_of(deck), ProgressionTable.EXPANDED_DECK_SLOTS)
		deck_box.active = 0
		return
	deck_box.set_cards(deck_box.active, DeckBox.ids_of(deck))


func deck_lookup() -> Callable:
	return func(id: String) -> CardData: return card_by_id(id)


## How many saved decks the player may have (5, then 10 after the deck box expansion reward).
func deck_capacity() -> int:
	return profile.deck_slots if profile != null else ProgressionTable.BASE_DECK_SLOTS


## Makes saved deck `index` the active one (what battles and dungeons play).
func use_deck(index: int) -> bool:
	if not deck_box.set_active(index):
		return false
	_deck_sync_paused = true
	deck = deck_box.build(index, deck_lookup())
	_deck_sync_paused = false
	save_game()
	return true


## Stores the cards of `edited` in saved deck `index` (and refreshes the active deck when that is the one).
func store_deck(index: int, edited: Deck) -> bool:
	if not deck_box.set_cards(index, DeckBox.ids_of(edited)):
		return false
	if index == deck_box.active:
		_deck_sync_paused = true
		deck = deck_box.build(index, deck_lookup())
		_deck_sync_paused = false
	save_game()
	return true


func new_saved_deck(deck_name: String = DeckBox.DEFAULT_NAME, ids: Array[String] = [] as Array[String]) -> int:
	var index: int = deck_box.create(deck_name, ids, deck_capacity())
	if index >= 0:
		save_game()
	return index


func duplicate_saved_deck(index: int) -> int:
	var created: int = deck_box.duplicate_deck(index, deck_capacity())
	if created >= 0:
		save_game()
	return created


func delete_saved_deck(index: int) -> bool:
	var was_active: bool = index == deck_box.active
	if not deck_box.delete(index):
		return false
	if was_active:
		use_deck(deck_box.active)
	else:
		_sync_active_deck()
		save_game()
	return true


func rename_saved_deck(index: int, new_name: String) -> bool:
	var done: bool = deck_box.rename(index, new_name)
	if done:
		if index == deck_box.active and deck != null:
			deck.deck_name = deck_box.decks[index].name
		save_game()
	return done


## Plain-language warnings about a saved deck: cards it uses that are no longer owned or no longer exist (the deck still loads; those cards are simply skipped).
func deck_warnings(index: int) -> Array[String]:
	var warnings: Array[String] = []
	if not deck_box.is_valid_index(index):
		return warnings
	for id: String in deck_box.unknown_ids(index, deck_lookup()):
		warnings.append("Unknown card %s was removed from this deck." % id)
	var missing: Dictionary = deck_box.missing_cards(index, profile, deck_lookup())
	for id: Variant in missing.keys():
		var card: CardData = card_by_id(str(id))
		warnings.append("You no longer own %d x %s." % [int(missing[id]), card.display_name if card != null else str(id)])
	return warnings



# ---- Save slots (brief 16, Group E) ---------------------------------------------------------------


## What the slot list shows about this moment: name (set by the caller), date, playtime, level, location, gold.
func slot_meta(save_name: String = "") -> Dictionary:
	return {
		"name": save_name,
		"saved_at": int(Time.get_unix_time_from_system()),
		"playtime": playtime_seconds,
		"level": profile.level if profile != null else 1,
		"location": last_location,
		"scene": scene_kind(),
		"gold": gold,
	}


## The place the hero is in, for the slot list ("Concord Crossing", "The Gainlands"...).
func location_name() -> String:
	var tree: SceneTree = get_tree()
	var scene: Node = tree.current_scene if tree != null else null
	if scene is ZoneScene and (scene as ZoneScene).def != null:
		return (scene as ZoneScene).def.display_name
	if scene is TownScene:
		return "Concord Crossing"
	if scene is StartingAreaScene:
		return "The Hollow's Edge"
	return last_location


## "town", "start" or "zone:<zone id>": where loading that save puts the hero back.
func scene_kind() -> String:
	var tree: SceneTree = get_tree()
	var scene: Node = tree.current_scene if tree != null else null
	if scene is ZoneScene and (scene as ZoneScene).def != null:
		return "zone:%s" % (scene as ZoneScene).def.id
	if scene is StartingAreaScene or not flag(&"trial_cleared"):
		return "start"
	return "town"


## Manual saves are allowed in the town, the zones and the starting area; never mid-battle, in a dungeon map, a reward screen or the ending.
func can_save_now() -> bool:
	if profile == null or in_dungeon() or pending_battle != null:
		return false
	var tree: SceneTree = get_tree()
	var scene: Node = tree.current_scene if tree != null else null
	if scene == null:
		return true
	return scene is TownScene or scene is ZoneScene or scene is StartingAreaScene or scene is ZonePlaceholderScene


## A screenshot of the game for the slot list (null in a headless run).
func capture_thumbnail() -> Image:
	if DisplayServer.get_name() == "headless" or get_viewport() == null:
		return null
	var texture: ViewportTexture = get_viewport().get_texture()
	var image: Image = texture.get_image() if texture != null else null
	if image == null or image.is_empty():
		return null
	return image


## Saves the campaign into manual slot `slot` (1..5) under `save_name`. `thumbnail` is the screenshot taken when the pause menu opened.
func save_to_slot(slot: int, save_name: String, thumbnail: Image = null) -> bool:
	if profile == null or slot < 1 or slot > SaveSlots.SLOT_COUNT:
		return false
	last_location = location_name()
	var data: Dictionary = to_dict()
	data["meta"] = slot_meta(save_name)
	if not SaveSlots.write(slot, data, thumbnail):
		return false
	active_slot = slot
	return true


## Loads a slot (0 = the autosave). False for an empty, unreadable or older-format slot. The caller changes scene (`resume_scene_path`).
func load_from_slot(slot: int) -> bool:
	var data: Dictionary = SaveSlots.load_data(slot)
	if data.is_empty() or not from_dict(data):
		return false
	active_slot = slot
	var meta: Dictionary = data.get("meta", {}) as Dictionary
	last_location = str(meta.get("location", last_location))
	pending_resume_scene = str(meta.get("scene", "start" if not flag(&"trial_cleared") else "town"))
	return true


## "town", "start" or "zone:<id>" from the last `load_from_slot` (read once by `resume_loaded_game`).
var pending_resume_scene: String = "town"


## Goes to the place a loaded save was made in (the zone's hub for a zone: the visit starts fresh), the starting area before the trial is cleared, otherwise town.
func resume_loaded_game() -> void:
	var kind: String = pending_resume_scene
	pending_resume_scene = "town"
	if not flag(&"trial_cleared"):
		SceneManager.go_to_start_area()
	elif kind.begins_with("zone:") and ZoneDefs.has_def(kind.trim_prefix("zone:")):
		enter_zone(kind.trim_prefix("zone:"))
	else:
		SceneManager.go_to_town()

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
	context.board_key = "dungeon:hollow"
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
## infrastructure of `color`) - short of the normal 45-card minimum until the 3 tutorial reward picks fill
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


## Builds the duel for a battle or boss node. HP carries over from the run.
func make_dungeon_battle(node: DungeonMap.MapNode) -> BattleContext:
	var options: GameOptions = GameOptions.new()
	options.first_player = 0 if node.tutorial else -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var enemy: PlayerSetup
	var player_rules: ModifierSource = null
	var phase: PrimmBoss.Phase = null
	var capital: bool = main_dungeon_active and zone_def().id == CapitalZone.ID
	if capital and node.kind == DungeonMap.Kind.BOSS:
		# The final boss: a duel per phase (see `PrimmBoss`); phase `boss_phase` is the one being fought.
		phase = PrimmBoss.phase(boss_phase)
		enemy = PrimmBoss.enemy_setup(content, boss_phase, run.current_deck())
		player_rules = PrimmBoss.player_rules(boss_phase)
	elif main_dungeon_active or mini_active:
		enemy = MainDungeons.enemy_setup(content, node, dungeon_key)
		# Severing the Heart Roots (D-ROT) weakens the Rotheart.
		if node.kind == DungeonMap.Kind.BOSS and dungeon_key == RotheartDungeon.ZONE_ID and RotheartDungeon.severed(run):
			enemy.starting_hp = maxi(enemy.starting_hp - RotheartDungeon.SEVERED_HP_LOSS, 5)
	else:
		enemy = TrialOfTheHollow.enemy_setup(content, node)
	var effect_zone: String = zone_def().id if ((mini_active or main_dungeon_active) and zone_run != null) else ""
	if capital:
		var rules: ModifierSource = CapitalDebuffs.enemy_source(flags, content)
		if rules != null:
			enemy.modifiers.add_source(rules)
	var zone_source: ModifierSource = ZoneEffects.source_for(effect_zone)
	if main_dungeon_active or mini_active:
		# The dungeon list's own buffs and debuffs, on top of the zone effects (`DungeonRules`).
		zone_source = DungeonRules.with_shared(zone_source, dungeon_key)
		if player_rules == null:
			player_rules = DungeonRules.player_source(dungeon_key)
	var game: GameState = run.start_encounter(enemy, zone_source, options, player_rules)
	# Grandmaster Flex, the Unbroken fights beside you in the House of Gains boss duel if you rescued him in this run.
	if main_dungeon_active and node.kind == DungeonMap.Kind.BOSS and dungeon_key == HouseOfGainsDungeon.ZONE_ID and HouseOfGainsDungeon.rescued(run):
		HouseOfGainsDungeon.place_ally(game)
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.zone_id = effect_zone
	if phase != null:
		context.board_key = "boss:final"
	elif main_dungeon_active or mini_active:
		# The dungeon list names each dungeon's battleboard (`DungeonCatalog.Blueprint.battleboard_id`).
		var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(dungeon_key)
		context.board_key = plan.battleboard_id if plan != null else ("dungeon:%s" % dungeon_key)
	else:
		context.board_key = "dungeon:hollow"
	if phase != null:
		context.boss_phase = phase.index
		context.rules_text = phase.rule_text()
		context.music = phase.music
	context.ai = AIPlayer.new(ZoneDecks.personality(content, node.ai_name) if (mini_active or main_dungeon_active) else TrialOfTheHollow.personality(content, node.ai_name))
	context.enemy_name = node.enemy_name if phase == null else "%s - %s" % [Villain.display_name(), phase.title()]
	context.enemy_icon = MainDungeons.enemy_icon(dungeon_key, node.enemy_name) if (main_dungeon_active or mini_active) else str(ENEMY_ICONS.get(node.enemy_name, "lorc/imp"))
	context.node_id = node.id
	context.tutorial = node.tutorial
	context.is_boss = node.kind == DungeonMap.Kind.BOSS
	context.gold_reward = node.gold_reward
	context.xp_reward = EncounterRewards.xp_for(node.difficulty)
	context.card_choices = node.card_choices
	return context


## Where the hero stood in town when a duel started (an NPC challenge, the Graveyard, the Arena), so town puts them back there.
var town_return_position: Vector3 = Vector3.ZERO
var has_town_return_position: bool = false


func start_battle(context: BattleContext) -> void:
	pending_battle = context
	var scene: Node = get_tree().current_scene if get_tree() != null else null
	if scene is TownScene and (scene as TownScene).player != null:
		town_return_position = (scene as TownScene).player.position
		has_town_return_position = true
	SceneManager.change_scene("res://scenes/battle.tscn")


# ---- Corrupted NPCs (new brief, Part E) --------------------------------------------------

## Set by _complete_npc_challenge, read once by TownScene._ready() to show the right post-fight
## dialogue (and, on a first win, the reward toast), then cleared. {} when there is nothing to
## show (e.g. town was reached some other way).
var pending_npc_result: Dictionary = {}


## A duel against one of the 4 corrupted NPCs, using the player's real current deck/profile (not
## a "typical" reference deck - that only exists for balance simulation, see
## core/dungeon/corrupted_npcs.gd). Full HP, like a fresh duel - not carried over from anywhere.
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
	context.board_key = "town"
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
## reference deck) at full HP - a real, standalone fight, not carried over from a dungeon run.
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
	context.board_key = "graveyard"
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


# ---- Shiro Swindle and the giant chests (brief 16, Group B) ---------------------------------

## Set by _complete_ninja_challenge, read once by TownScene._ready() to show the right post-fight dialogue and the reward toast, then cleared.
var pending_ninja_result: Dictionary = {}


func ninja_chest_opened(chest_id: String) -> bool:
	return found_secret(NinjaBoss.secret_id(chest_id))


func ninja_chests_opened() -> int:
	return NinjaBoss.opened_count(found_secrets)


func ninja_defeated() -> bool:
	return flag(NinjaBoss.FLAG_DEFEATED)


## All five chests are open and he has not been beaten yet: the original chest closes again and glows.
func ninja_ready() -> bool:
	return NinjaBoss.all_opened(found_secrets) and not ninja_defeated()


## The player opens a giant chest for the first time: starts the questline, takes the gold (50, or all of it), records the chest and counts it.
## Returns {"chest", "stolen", "count", "is_fifth", "first"}; {} when the chest was already opened.
func open_giant_chest(chest_id: String) -> Dictionary:
	if not NinjaBoss.is_chest_id(chest_id) or ninja_chest_opened(chest_id):
		return {}
	var first: bool = ninja_chests_opened() == 0
	if first:
		start_quest(NinjaBoss.QUEST_ID)
	var stolen: int = NinjaBoss.steal_amount(gold)
	if stolen > 0:
		gold -= stolen
		EventBus.gold_changed.emit(gold)
	counters[NinjaBoss.COUNTER_STOLEN] = int(counters.get(NinjaBoss.COUNTER_STOLEN, 0)) + stolen
	discover_secret(NinjaBoss.secret_id(chest_id))
	bump_counter(NinjaBoss.COUNTER_OPENED)
	var count: int = ninja_chests_opened()
	return {"chest": chest_id, "stolen": stolen, "count": count, "is_fifth": count == NinjaBoss.CHEST_IDS.size(), "first": first}


## The duel against Shiro Swindle on the town battleboard, using the player's real deck at full HP.
func make_ninja_battle() -> BattleContext:
	ensure_game()
	var options: GameOptions = GameOptions.new()
	options.first_player = -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(deck, profile, [] as Array[ModifierSource], "You"))
	game.add_player(NinjaBoss.enemy_setup(content))
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(NinjaBoss.personality(content))
	context.enemy_name = NinjaBoss.DISPLAY_NAME
	context.is_boss = true
	context.is_ninja_boss = true
	context.board_key = "town"
	return context


func challenge_ninja() -> void:
	start_battle(make_ninja_battle())


## Winning returns every coin he took and pays 3 Gilded Packs (one random Path each), ends the questline and leaves the chest open for good.
## Losing changes nothing: the chest stays closed and glowing so the fight can be retried.
func _complete_ninja_challenge(context: BattleContext) -> void:
	pending_ninja_result = {"won": context.won, "first_win": false}
	if context.won and not ninja_defeated():
		pending_ninja_result = apply_ninja_win()
	save_game()
	SceneManager.go_to_town()


## The first win over Shiro Swindle: every stolen coin comes back, 3 Gilded Packs (one random Path each) are paid and the questline ends.
func apply_ninja_win() -> Dictionary:
	var returned: int = int(counters.get(NinjaBoss.COUNTER_STOLEN, 0))
	counters[NinjaBoss.COUNTER_STOLEN] = 0
	if returned > 0:
		add_gold(returned)
	var packs: Array[String] = []
	for path: Affinity.Type in NinjaBoss.reward_paths(rng):
		var pack_id: String = PackRules.gilded_pack_id(path)
		if add_pack(pack_id):
			packs.append(pack_id)
	set_flag(NinjaBoss.FLAG_DEFEATED)
	refresh_quests()
	return {"won": true, "first_win": true, "gold_returned": returned, "packs": packs}


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


## Completes an active quest and pays its rewards. Returns false if it was not active. A "Quest Complete" box (`RewardSummary`) is queued in
## `pending_popups` for the world scenes to show before any level-up popup the XP caused.
func complete_quest(quest_id: String) -> bool:
	var quest: QuestData = QuestCatalog.find(quest_id)
	if quest == null or not quest_log.is_active(quest_id):
		return false
	var before: UnlockDigest = UnlockDigest.capture(flags, profile.level if profile != null else 1, _startable_quests())
	if not quest_log.complete(quest_id):
		return false
	var summary: RewardSummary = RewardSummary.new()
	summary.kind = RewardSummary.Kind.QUEST
	summary.title = quest.title
	summary.subtitle = Villain.fill(quest.summary)
	if quest.reward_gold > 0:
		add_gold(quest.reward_gold)
		summary.gold = quest.reward_gold
	for item_id: String in quest.reward_item_ids:
		var item: ItemData = content.item(item_id)
		add_item(item)
		if item != null:
			summary.items.append(item)
	var cards: Array[CardData] = []
	for card_id: String in quest.reward_card_ids:
		var card: CardData = card_by_id(card_id)
		if card != null:
			cards.append(card)
	if not cards.is_empty():
		add_cards(cards)
		summary.cards.append_array(cards)
	for pack_id: String in quest.reward_pack_ids:
		if add_pack(pack_id):
			var pack: PackData = PackCatalog.find(pack_id)
			summary.add_pack(pack_id, pack.display_name if pack != null else pack_id)
	for equipment_id: String in quest.reward_equipment_ids:
		var piece: EquipmentData = content.equipment_piece(equipment_id)
		grant_equipment(piece)
		if piece != null:
			summary.equipment.append(piece)
	for flag_name: String in quest.reward_unlock_flags:
		flags[flag_name] = true
		if flag_name.begins_with("capital_insight_"):
			summary.unlocks.append("Insight into %s" % Villain.display_name())
	if quest.reward_xp > 0:
		summary.xp = quest.reward_xp
		var gained: Array[LevelData] = add_xp(quest.reward_xp)
		pending_level_ups.append_array(gained)
		for row: LevelData in gained:
			summary.levels_reached.append(row.level)
	summary.unlocks.append_array(UnlockDigest.capture(flags, profile.level if profile != null else 1, _startable_quests()).lines_since(before))
	pending_popups.append(summary)
	var rewards: String = quest.reward_summary()
	var suffix: String = ("  (" + rewards + ")") if not rewards.is_empty() else ""
	EventBus.quest_notice.emit("Quest complete: %s%s" % [quest.title, suffix], false)
	EventBus.quest_changed.emit()
	save_game()
	return true


## Quest id -> title for every quest that could be started right now (the "what this opened up" diff of a finished quest).
func _startable_quests() -> Dictionary:
	var result: Dictionary = {}
	if profile == null:
		return result
	var state: UnlockState = unlock_state()
	for quest: QuestData in QuestCatalog.all():
		if quest_log.can_start(quest, state):
			result[quest.id] = quest.title
	return result


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


# ---- Map fog of war (brief 6, Part C) ----------------------------------------------------

## Saved fog per area id (zone ids, plus "town" and "start"): `FogOfWar.to_dict()` each.
var map_fog: Dictionary = {}
## The live `FogOfWar` objects of areas visited this session (written back into `map_fog` on save).
var _fog_live: Dictionary = {}


## The fog of war of an area, restored from the save the first time it is asked for.
func fog_for(area_id: String, bounds: Rect2) -> FogOfWar:
	if not _fog_live.has(area_id):
		_fog_live[area_id] = FogOfWar.from_dict(map_fog.get(area_id, {}) as Dictionary, bounds)
	return _fog_live[area_id] as FogOfWar


func _fog_to_dict() -> Dictionary:
	for area_id: Variant in _fog_live.keys():
		map_fog[str(area_id)] = (_fog_live[area_id] as FogOfWar).to_dict()
	return map_fog


# ---- Zones (brief 5: the D.N.A.) ----------------------------------------------------------

const DNA_SCENE: String = "res://scenes/dna_zone.tscn"  # kept for older callers; the zone scene comes from ZoneDef.scene_path
const ZONE_LOG_LIMIT: int = 40

## The current zone visit (null in town). Holds the HP that persists across the whole visit.
var zone_run: ZoneRun
## Set when the zone scene (re)loads after a battle/minigame, read once by it: {} when nothing.
var pending_zone_result: Dictionary = {}
## Every paperwork fee ever charged ("log it") - newest last, saved with the campaign.
var zone_log: Array[String] = []
## Pack rewards from beating Primm, announced once when the hero is back in the Capital after the ending.
var pending_ending_packs: Array[String] = []


func in_zone() -> bool:
	return zone_run != null


## The run that item use and healing apply to: the dungeon run, else the zone visit's HP.
func hp_run() -> DungeonRun:
	if in_dungeon():
		return run
	return zone_run.run if zone_run != null else null


## Entering from town: a brand-new visit, always at full HP (town heals fully).
func enter_dna() -> void:
	enter_zone(DnaZone.ID)


## Entering any zone (`ZoneDefs`) from town: a brand-new visit, always at full HP.
func enter_zone(zone_id: String) -> void:
	begin_zone_visit(zone_id)
	pending_zone_result = {}
	SceneManager.change_scene(ZoneDefs.get_def(zone_id).scene_path)


# ---- The Beefcake Rift Express (brief 10b) ----------------------------------------------------------------------------

## Set just before a rift trip: the next scene puts the hero at that scene's Rift Station instead of its usual spawn (read once).
var arrive_at_station: bool = false


func fast_travel_unlocked(station_id: String) -> bool:
	return FastTravel.is_unlocked(flags, station_id)


## Reaching a zone's town unlocks its station. Returns true the first time (the caller toasts it).
func unlock_fast_travel(station_id: String) -> bool:
	if not FastTravel.unlock(flags, station_id):
		return false
	save_game()
	return true


## Rips the hero to another station: to the town, or into a fresh visit of a zone (full HP, the visit's enemies are back, like walking
## in from town). Does nothing for a station that is not unlocked.
func fast_travel_to(destination: String) -> bool:
	if not FastTravel.is_unlocked(flags, destination):
		return false
	arrive_at_station = true
	pending_zone_result = {}
	if destination == FastTravel.TOWN:
		zone_run = null
		save_game()
		SceneManager.go_to_town()
		return true
	begin_zone_visit(destination)
	save_game()
	SceneManager.change_scene(ZoneDefs.get_def(destination).scene_path)
	return true


## Starts a visit to `zone_id` (full HP). The Capital's broken-service debuffs (`CapitalDebuffs`) join the visit's modifiers
## here, so they apply to every duel and to the zone HP (Famine lowers max HP).
func begin_zone_visit(zone_id: String) -> ZoneRun:
	zone_run = ZoneRun.enter(zone_id, profile, deck)
	if zone_id == CapitalZone.ID:
		var debuffs: ModifierSource = CapitalDebuffs.player_source(flags, content)
		if debuffs != null:
			zone_run.run.dungeon_sources.append(debuffs)
			zone_run.run.hp = zone_run.run.max_hp()
	return zone_run


## The def of the zone the player is visiting (the D.N.A. when not in a zone).
func zone_def() -> ZoneDef:
	return ZoneDefs.current()


## Brief 11: the central town is always a full heal. The town has no HP of its own, so arriving ends any zone visit (the next visit starts at
## full HP) and tops up any run that is somehow still open. Called by the town scene whenever the hero is in town, however they got there
## (walking out of a zone, the Rift Express, waking up after a loss).
func arrive_in_town() -> void:
	zone_run = null
	if run != null:
		run.hp = run.max_hp()


## Walking back out to town. Town is a full heal, so the visit simply ends.
func leave_zone() -> void:
	zone_run = null
	pending_zone_result = {}
	SceneManager.go_to_town()


## Anything worth logging in a zone (falls, fees...): newest last, saved with the campaign.
func log_zone_event(line: String) -> void:
	log_paperwork_fee(line)


func log_paperwork_fee(line: String) -> void:
	zone_log.append(line)
	while zone_log.size() > ZONE_LOG_LIMIT:
		zone_log.remove_at(0)


## Carried to the hub at 0 HP: full HP again, pay the paperwork fee, log it. Returns the fee.
func zone_wake_at_hub(cause: String) -> int:
	if zone_run == null:
		return 0
	var fee: int = zone_run.wake_at_hub(gold, cause)
	if fee > 0:
		spend_gold(fee)
	log_paperwork_fee("%s %d gold - %s" % [zone_def().fee_label, fee, cause])
	counters["paperwork_fees_paid"] = int(counters.get("paperwork_fees_paid", 0)) + fee
	zone_run.has_return_position = false
	save_game()
	return fee


## A duel against a roaming zone enemy: the player's real deck at the zone's persistent HP.
func make_zone_battle(enemy_type: String, enemy_instance_id: String) -> BattleContext:
	ensure_game()
	var zone_id: String = zone_def().id
	var data: ZoneEnemyInfo = ZoneEnemies.info(zone_id, enemy_type)
	var options: GameOptions = GameOptions.new()
	options.first_player = -1
	options.rng_seed = rng.randi() % 1000000 + 1
	var game: GameState = GameState.new(options)
	var buffs: Array[ModifierSource] = []
	if zone_run != null:
		buffs = zone_run.run.dungeon_sources
	var zone_source: ModifierSource = ZoneEffects.source_for(zone_id)
	if zone_source != null:
		buffs = buffs.duplicate()
		buffs.append(zone_source)
	var player: PlayerSetup = PlayerSetup.create(deck, profile, buffs, "You")
	if zone_run != null:
		player.starting_hp = zone_run.hp
	game.add_player(player)
	var zone_enemy: PlayerSetup = ZoneEnemies.enemy_setup(content, zone_id, enemy_type)
	if zone_source != null:
		zone_enemy.modifiers.add_source(zone_source)
	if zone_id == CapitalZone.ID:
		_add_capital_enemy_rules(zone_enemy, zone_empower_next)
	zone_empower_next = false
	game.add_player(zone_enemy)
	game.start()
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(ZoneEnemies.personality(content, zone_id, enemy_type))
	context.enemy_name = data.display_name
	context.zone_id = zone_id
	context.zone_battle = true
	context.board_key = _zone_board_key(zone_id, enemy_type)
	context.zone_enemy_id = enemy_instance_id
	context.zone_enemy_type = enemy_type
	context.gold_reward = data.gold_reward
	context.xp_reward = data.xp_reward
	return context


## The battleboard key of an overworld duel: the zone's board, or in the Capital the one outside the walls (the Gate Captain's exam, or before the
## hero has gone through the gate) and the one inside.
func _zone_board_key(zone_id: String, enemy_type: String) -> String:
	if zone_id == CapitalZone.ID:
		return "capital:in" if flag(CapitalZone.FLAG_INSIDE) and enemy_type != CapitalEnemies.GATE_CAPTAIN else "capital:out"
	return "zone:%s" % zone_id


func start_zone_battle(enemy_type: String, enemy_instance_id: String) -> void:
	start_battle(make_zone_battle(enemy_type, enemy_instance_id))


## Set by the Capital scene just before a battle: the enemy stood near an unsealed rift, so it fights empowered
## (`CapitalRifts.EMPOWER_LIFE` more HP and +1/+1 on its units). Read and cleared by `make_zone_battle`.
var zone_empower_next: bool = false


## The Capital's rules for the enemy's side: the Necrocrat debuff (its units may return from the graveyard) and a rift's empowering.
func _add_capital_enemy_rules(enemy: PlayerSetup, empowered: bool) -> void:
	var rules: ModifierSource = CapitalDebuffs.enemy_source(flags, content)
	if rules != null:
		enemy.modifiers.add_source(rules)
	if empowered:
		var boost: Modifier = CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, CapitalRifts.EMPOWER_STAT, Modifier.ANY_COLOR, CapitalRifts.EMPOWER_STAT)
		enemy.modifiers.add_source(CardBuilder.modifier_source("Rift-empowered", ModifierSource.SourceKind.ZONE, [boost] as Array[Modifier]))
		enemy.starting_hp += CapitalRifts.EMPOWER_HP


## The Gate Captain's entry examination: the CHALLENGING card battle that opens the Capital's gate.
func start_gate_battle() -> void:
	start_zone_battle(CapitalEnemies.GATE_CAPTAIN, CapitalEnemies.GATE_CAPTAIN)


## After a zone duel: HP carries over (no post-battle heal). A win removes that enemy for the rest
## of the visit and pays a small reward; a loss (0 HP) wakes the player at the hub, minus the fee.
func _complete_zone_battle(context: BattleContext) -> void:
	resolve_zone_battle(context)
	SceneManager.change_scene(zone_def().scene_path)


## The state changes of a finished zone duel (no scene change, so tests can run it).
func resolve_zone_battle(context: BattleContext) -> Dictionary:
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
		if zone_def().counter_enemies != "zone_enemies_defeated":
			bump_counter(zone_def().counter_enemies)
		if zone_def().id == CapitalZone.ID and context.zone_enemy_type == CapitalEnemies.GATE_CAPTAIN:
			set_flag(CapitalZone.FLAG_GATE_OPEN)
			set_flag(CapitalZone.FLAG_INSIDE)
			result["gate_opened"] = true
	if zone_run.is_down() or not context.won:
		var fee: int = zone_wake_at_hub("beaten by a %s" % context.enemy_name)
		result["woke_at_hub"] = true
		result["fee"] = fee
	pending_zone_result = result
	save_game()
	return result


# ---- Mini dungeon (brief 5, Part E) -------------------------------------------------------

## True while a run on `MiniDungeon`'s map is going (so the shared dungeon screens know to return
## to the zone instead of town).
var mini_active: bool = false
## True while inside a zone's main (final) dungeon (the Test Kitchen, the House of Gains, ...). Part E.
var main_dungeon_active: bool = false
## The dungeon being run, as a `MainDungeons` key: the zone id of a final dungeon ("beefcake"), the dungeon ID of a side dungeon ("S-BEEF"). "" in the Trial of the Hollow.
var dungeon_key: String = ""
## True while the town's side dungeon (the Forgotten Vault) is running: no zone visit, full HP, and the party is carried back to the town.
var town_side_active: bool = false
## Node ids whose "after" story has been shown in the current dungeon run (so it plays once).
var dungeon_story_seen: Array[int] = []
## Brief 10: the phase of the final boss being fought (0-2), whether the next phase is waiting to start (the map plays the scene
## between phases, then starts it) and whether the freed leaders' boons have been given for this run.
var boss_phase: int = 0
var boss_phase_pending: bool = false
var boss_boons_given: bool = false


## Entering the final boss's chamber: each freed leader lends a boon (once per run). Returns what they say (story lines).
func begin_primm_fight() -> Array[String]:
	var lines: Array[String] = PrimmBoss.leader_lines(flags)
	if not boss_boons_given and run != null:
		boss_boons_given = true
		for boon: ModifierSource in PrimmBoss.leader_boons(flags):
			run.add_dungeon_source(boon)
	return lines


## From the zone's elevator: a run that starts at the zone's current HP (no healing).
func enter_mini_dungeon() -> void:
	if zone_run == null:
		return
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone(zone_run.zone_id)
	if plan == null:
		return
	dungeon_key = plan.id
	dungeon_map = MiniDungeon.build_map(zone_run.zone_id)
	run = DungeonRun.enter(profile, deck, zone_run.run.dungeon_sources)
	run.hp = clampi(zone_run.hp, 1, run.max_hp())
	mini_active = true
	town_side_active = false
	trial_finished = false
	pending_reward = null
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Leaves the side dungeon back to the zone (or the town). The HP left goes back to the zone; clearing it the
## first time grants the unique card, repeat clears pay gold and a pack. `failed` (0 HP) wakes the player at the hub with the fee.
func finish_mini_dungeon(cleared: bool, failed: bool = false) -> void:
	var was_town: bool = town_side_active
	resolve_mini_dungeon(cleared, failed)
	if was_town:
		SceneManager.go_to_town()
		return
	SceneManager.change_scene(zone_def().scene_path)


## The flag a side dungeon sets on its first clear (zones keep theirs in their `ZoneDef`; the Forgotten Vault under the town has its own).
func side_cleared_flag(plan: DungeonCatalog.Blueprint) -> StringName:
	if plan != null and ZoneDefs.has_def(plan.zone_id) and not ZoneDefs.get_def(plan.zone_id).flag_mini_cleared.is_empty():
		return ZoneDefs.get_def(plan.zone_id).flag_mini_cleared
	return &"town_vault_cleared"


## The flag a side dungeon's quest sets when it is done: the dungeon's entrance only opens once it is set.
static func side_unlock_flag(dungeon_id: String) -> StringName:
	return DungeonCatalog.side_unlock_flag(dungeon_id)


func side_unlocked(dungeon_id: String) -> bool:
	return flag(side_unlock_flag(dungeon_id))


## The state changes of leaving the side dungeon (no scene change, so tests can run it).
func resolve_mini_dungeon(cleared: bool, failed: bool = false) -> Dictionary:
	var result: Dictionary = {"kind": "mini", "cleared": cleared, "failed": failed, "dungeon": dungeon_key}
	if zone_run != null and run != null:
		zone_run.hp = run.hp
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(dungeon_key)
	var dungeon: MainDungeonDef = MainDungeons.def(dungeon_key)
	if cleared and plan != null:
		if dungeon != null and not cleared_dungeons.has(dungeon.dungeon_name):
			cleared_dungeons.append(dungeon.dungeon_name)
		if plan.id == "S-CAP":
			# The Old Service Tunnels double as the secret way into the Capital: the party comes up inside the walls, in the Crease.
			set_flag(CapitalZone.FLAG_TUNNEL_FOUND)
			set_flag(CapitalZone.FLAG_HUB_KNOWN)
			set_flag(CapitalZone.FLAG_INSIDE)
			result["secret_way"] = true
		var cleared_flag: StringName = side_cleared_flag(plan)
		if not flag(cleared_flag):
			set_flag(cleared_flag)
			var card: CardData = card_by_id(plan.reward_card_id())
			if card != null:
				add_cards([card] as Array[CardData])
				result["card"] = card.display_name
			result["first_clear"] = true
		else:
			var gold_reward: int = DungeonBuilder.SIDE_REWARD_GOLD
			add_gold(gold_reward)
			result["gold"] = gold_reward
			var pack_id: String = plan.repeat_pack_id()
			if not pack_id.is_empty() and PackCatalog.find(pack_id) != null:
				add_pack(pack_id, 1)
				result["packs"] = [PackRewards.entry(pack_id, 1)]
	run = null
	dungeon_map = null
	mini_active = false
	town_side_active = false
	trial_finished = false
	pending_reward = null
	if zone_run != null and (failed or zone_run.is_down()):
		result["fee"] = zone_wake_at_hub("sent home from %s" % (plan.dungeon_name if plan != null else "the dungeon"))
		result["woke_at_hub"] = true
	pending_zone_result = result
	save_game()
	return result


## From the town: the Forgotten Vault under the old well (S-TOWN). A normal dungeon run at full HP; losing carries the party back to the town.
func enter_town_side_dungeon() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.side_for_zone("town")
	if plan == null or profile == null:
		return
	dungeon_key = plan.id
	dungeon_map = MainDungeons.build_map(plan.id)
	run = DungeonRun.enter(profile, deck, [] as Array[ModifierSource])
	mini_active = true
	town_side_active = true
	trial_finished = false
	pending_reward = null
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


# ---- The zone's final dungeon (brief 9, Part E) -------------------------------------------


## From the zone's dungeon entrance: a run that starts at the zone's current HP (no healing, zone HP
## rules). The map is the zone's final dungeon (`MainDungeons`).
func enter_main_dungeon() -> void:
	if zone_run == null or not MainDungeons.has_def(zone_run.zone_id):
		return
	dungeon_key = zone_run.zone_id
	dungeon_map = MainDungeons.build_map(zone_run.zone_id)
	run = DungeonRun.enter(profile, deck, zone_run.run.dungeon_sources)
	run.hp = clampi(zone_run.hp, 1, run.max_hp())
	mini_active = false
	main_dungeon_active = true
	boss_phase = 0
	boss_phase_pending = false
	boss_boons_given = false
	dungeon_story_seen = []
	trial_finished = false
	pending_reward = null
	SceneManager.change_scene("res://scenes/dungeon_map.tscn")


## Leaves the final dungeon back to the zone (retreat, a loss or the boss falling).
func finish_main_dungeon(cleared: bool, failed: bool = false) -> void:
	var result: Dictionary = resolve_main_dungeon(cleared, failed)
	if str(result.get("kind", "")) == "primm_defeated":
		SceneManager.change_scene(ENDING_SCENE)
		return
	SceneManager.change_scene(zone_def().scene_path)


## The state changes of leaving the final dungeon (no scene change, so tests can run it). Beating the
## boss the first time completes the zone: the unique card, gold and XP, then `complete_zone` (which
## fires the completion event and saves). Returns what the zone scene should announce.
func resolve_main_dungeon(cleared: bool, failed: bool = false) -> Dictionary:
	var zone_id: String = zone_def().id
	var dungeon: MainDungeonDef = MainDungeons.def(zone_id)
	var result: Dictionary = {"kind": "main", "cleared": cleared, "failed": failed}
	if zone_run != null and run != null:
		zone_run.hp = run.hp
	if cleared and dungeon != null:
		if not cleared_dungeons.has(dungeon.dungeon_name):
			cleared_dungeons.append(dungeon.dungeon_name)
		var first_clear: bool = not is_zone_completed(zone_id)
		_grant_dungeon_packs(zone_id, first_clear, result)
		if not first_clear:
			# Repeat clears of a main dungeon pay its Path Pack (above) and gold.
			add_gold(DungeonBuilder.MAIN_REPEAT_GOLD)
			result["repeat_gold"] = DungeonBuilder.MAIN_REPEAT_GOLD
		if not is_zone_completed(zone_id):
			var arena_before: bool = arena_unlocked()
			var alchemist_before: bool = alchemist_unlocked()
			var card: CardData = card_by_id(dungeon.reward_card_id)
			if card != null:
				add_cards([card] as Array[CardData])
				result["card"] = card.display_name
			add_gold(dungeon.reward_gold)
			pending_level_ups.append_array(add_xp(dungeon.reward_xp))
			complete_zone(zone_id)
			result["kind"] = "zone_freed"
			result["first_clear"] = true
			result["gold"] = dungeon.reward_gold
			result["xp"] = dungeon.reward_xp
			result["arena_opened"] = arena_unlocked() and not arena_before
			result["alchemist_opened"] = alchemist_unlocked() and not alchemist_before
			if zone_id == CapitalZone.ID:
				# Primm is down: the ending plays, the postgame unlocks (decks of 3+ Paths, the Alchemist's tri-Path hook).
				result["kind"] = "primm_defeated"
				result["postgame_unlocked"] = unlock_postgame()
	run = null
	dungeon_map = null
	boss_phase = 0
	boss_phase_pending = false
	main_dungeon_active = false
	trial_finished = false
	pending_reward = null
	if zone_run != null and (failed or zone_run.is_down()):
		result["fee"] = zone_wake_at_hub("sent home from %s" % (dungeon.dungeon_name if dungeon != null else "the final dungeon"))
		result["woke_at_hub"] = true
	pending_zone_result = result
	save_game()
	return result



## Brief 11: every clear of a zone's main dungeon awards that Path's Path Pack; the FIRST clear also grants a Gilded Pack, bonus gold and XP
## (`PackConfig`) and unlocks the Path Pack at the Pack Vendor (the zone-completed flag it checks is set by the caller). Primm's fall
## (the Capital) awards Prismatic Packs the first time. Fills `result` ("packs", "bonus_packs", "bonus_gold", "bonus_xp", "vendor_unlock").
func _grant_dungeon_packs(zone_id: String, first_clear: bool, result: Dictionary) -> void:
	var config: PackConfig = PackCatalog.config()
	var path: Affinity.Type = PackRules.path_for_zone(zone_id)
	if path == Affinity.Type.NEUTRAL:
		if zone_id == CapitalZone.ID and first_clear:
			grant_cosmetic("cloak_royal", true)  # the Royal Mantle: the one thing Primm left behind that is worth wearing
		if zone_id == CapitalZone.ID and not first_clear and profile != null and profile.postgame_unlocked:
			add_pack(PackRules.PRISMATIC_ID, 1)
			result["packs"] = [PackRewards.entry(PackRules.PRISMATIC_ID, 1)]
		if zone_id == CapitalZone.ID and first_clear and config.primm_prismatic_packs > 0:
			add_pack(PackRules.PRISMATIC_ID, config.primm_prismatic_packs)
			result["packs"] = [PackRewards.entry(PackRules.PRISMATIC_ID, config.primm_prismatic_packs)]
			pending_ending_packs = [PackRewards.labels(result["packs"] as Array)]
		return
	var path_pack: PackData = PackCatalog.path_pack(path)
	if path_pack == null:
		return
	add_pack(path_pack.id, config.dungeon_pack_count)
	result["packs"] = [PackRewards.entry(path_pack.id, config.dungeon_pack_count)]
	if not first_clear:
		return
	var bonus: Array = []
	if config.first_clear_gilded_packs > 0 and PackCatalog.gilded_pack(path) != null:
		add_pack(PackRules.gilded_pack_id(path), config.first_clear_gilded_packs)
		bonus.append(PackRewards.entry(PackRules.gilded_pack_id(path), config.first_clear_gilded_packs))
	result["bonus_packs"] = bonus
	if config.first_clear_bonus_gold > 0:
		add_gold(config.first_clear_bonus_gold)
		result["bonus_gold"] = config.first_clear_bonus_gold
	if config.first_clear_bonus_xp > 0:
		pending_level_ups.append_array(add_xp(config.first_clear_bonus_xp))
		result["bonus_xp"] = config.first_clear_bonus_xp
	result["vendor_unlock"] = path_pack.display_name

const ENDING_SCENE: String = "res://scenes/ending.tscn"


## Beating Primm: sets `postgame_unlocked` (3+ Path decks, the tri-Path crafting hook) and the `primm_defeated` flag. Returns true the
## first time.
func unlock_postgame() -> bool:
	set_flag(&"primm_defeated")
	# His fall frees the four Paths too (their rulers answered to him): the factions reunite.
	for zone_id: String in ZoneDefs.ids():
		if not is_zone_completed(zone_id):
			complete_zone(zone_id)
	if profile == null or profile.postgame_unlocked:
		return false
	profile.postgame_unlocked = true
	EventBus.collection_changed.emit()
	save_game()
	return true


## After the ending sequence (and its postgame announcement): back to the Capital, which has changed (a fresh visit at full HP).
func return_from_ending() -> void:
	begin_zone_visit(CapitalZone.ID)
	pending_zone_result = {"kind": "ending_return", "postgame_unlocked": bool(profile.postgame_unlocked) if profile != null else false}
	save_game()
	SceneManager.change_scene(ZoneDefs.get_def(CapitalZone.ID).scene_path)


## Applies a TREASURE node's loot (gold, XP, a heal, an item, a card, a piece of equipment) and returns what was
## granted, for the treasure screen to show.
func apply_treasure(node: DungeonMap.MapNode) -> Dictionary:
	var loot: Dictionary = node.treasure
	var granted: Dictionary = {}
	var gold_amount: int = int(loot.get("gold", 0))
	if gold_amount > 0:
		add_gold(gold_amount)
		granted["gold"] = gold_amount
	var xp_amount: int = int(loot.get("xp", 0))
	if xp_amount > 0:
		pending_level_ups.append_array(add_xp(xp_amount))
		granted["xp"] = xp_amount
	var heal_amount: int = int(loot.get("heal", 0))
	if heal_amount > 0 and run != null:
		run.heal(heal_amount)
		granted["heal"] = heal_amount
	var item: ItemData = content.item(str(loot.get("item", "")))
	if item != null:
		add_item(item)
		granted["item"] = item.display_name
	var card: CardData = content.card(str(loot.get("card", "")))
	if card != null:
		add_cards([card] as Array[CardData])
		if run != null:
			run.gain_card(card)
		granted["card"] = card.display_name
	var piece: EquipmentData = content.equipment_piece(str(loot.get("equipment", "")))
	if piece != null and grant_equipment(piece):
		granted["equipment"] = piece.source_name
	save_game()
	return granted


## Resolves one choice of a story event for the current dungeon run: HP/boons/cards go to the run, gold
## to the player. Returns the `EventResolver.Result` (ok = false when the choice could not be taken).
func resolve_dungeon_event(event: DungeonEvent, choice_index: int) -> EventResolver.Result:
	var result: EventResolver.Result = EventResolver.resolve(event, choice_index, run, content, gold)
	if result.ok:
		if result.gold_delta > 0:
			add_gold(result.gold_delta)
		elif result.gold_delta < 0:
			spend_gold(-result.gold_delta)
		if not result.cards.is_empty():
			add_cards(result.cards)
		save_game()
	return result


# ---- The Arena (brief 9, Part G) ----------------------------------------------------------

## Set by `_complete_arena_battle`, read once by the town (which reopens the Arena screen with the outcome): {id, won,
## first_clear, reward (resolved), replay_gold}. {} when there is nothing to show.
var pending_arena_result: Dictionary = {}


func is_arena_cleared(encounter_id: String) -> bool:
	return flag(ArenaDefs.flag_name(encounter_id))


func arena_cleared_count() -> int:
	var count: int = 0
	for encounter: ArenaEncounter in ArenaDefs.all():
		if is_arena_cleared(encounter.id):
			count += 1
	return count


## The duel of one arena encounter, using the player's real deck/profile (or the encounter's restricted deck).
func make_arena_battle(encounter_id: String) -> BattleContext:
	ensure_game()
	var encounter: ArenaEncounter = ArenaDefs.find(encounter_id)
	var game: GameState = ArenaScenario.build_game(content, encounter, profile, deck, rng.randi() % 1000000 + 1)
	var context: BattleContext = BattleContext.new()
	context.game = game
	context.ai = AIPlayer.new(ZoneDecks.personality(content, encounter.enemy_ai))
	context.enemy_name = encounter.enemy_name
	context.enemy_icon = "lorc/muscle-up" if encounter.tier < 3 else "delapouite/strong-man"
	context.is_boss = encounter.tier == 3 and not encounter.is_puzzle()
	context.arena_id = encounter_id
	context.board_key = "arena"
	return context


func start_arena_battle(encounter_id: String) -> void:
	start_battle(make_arena_battle(encounter_id))


## After an arena duel: the first clear of an encounter pays its prize (gold, XP, essence of Paths, equipment, an item, a
## card); replays only pay a small flat gold amount. Losing pays nothing and can always be retried.
func _complete_arena_battle(context: BattleContext) -> void:
	resolve_arena_battle(context)
	SceneManager.go_to_town()


## The state changes of a finished arena duel (no scene change, so tests can run it). Returns the result dictionary.
func resolve_arena_battle(context: BattleContext) -> Dictionary:
	var encounter: ArenaEncounter = ArenaDefs.find(context.arena_id)
	var won: bool = encounter.player_won(context.game)
	context.won = won
	var result: Dictionary = {"id": encounter.id, "won": won, "first_clear": false, "reward": {}, "replay_gold": 0}
	if won:
		if not is_arena_cleared(encounter.id):
			set_flag(ArenaDefs.flag_name(encounter.id))
			result["first_clear"] = true
			var reward: Dictionary = ArenaScenario.resolve_reward(encounter, profile.primary_affinity)
			result["reward"] = reward
			_grant_arena_reward(reward)
		else:
			result["replay_gold"] = encounter.replay_gold
			add_gold(encounter.replay_gold)
	pending_arena_result = result
	EventBus.arena_fight_finished.emit(encounter.id, won)
	save_game()
	return result


func _grant_arena_reward(reward: Dictionary) -> void:
	if reward.has("gold"):
		add_gold(int(reward["gold"]))
	if reward.has("xp"):
		pending_level_ups.append_array(add_xp(int(reward["xp"])))
	if reward.has("essence"):
		for path: Variant in (reward["essence"] as Dictionary).keys():
			profile.add_essence(int(path) as Affinity.Type, int((reward["essence"] as Dictionary)[path]))
	if reward.has("equipment"):
		var piece: EquipmentData = content.equipment_piece(str(reward["equipment"]))
		if piece != null:
			grant_equipment(piece)
	if reward.has("item"):
		var item: ItemData = content.item(str(reward["item"]))
		if item != null:
			add_item(item)
	if reward.has("card"):
		var card: CardData = card_by_id(str(reward["card"]))
		if card != null:
			add_cards([card] as Array[CardData])



# ---- Zone portals (Part G) ---------------------------------------------------------------

## Which placeholder zone (`ZonePortals.Info.id`) the placeholder scene should show.
var pending_zone_id: String = ""


func enter_zone_portal(zone_id: String) -> void:
	pending_zone_id = zone_id
	SceneManager.change_scene("res://scenes/zone_placeholder.tscn")


## Called by the battle screen when the player leaves the result panel.
func complete_battle(context: BattleContext) -> void:
	pending_battle = null
	if not context.arena_id.is_empty():
		_complete_arena_battle(context)
		return
	if not context.town_npc_id.is_empty():
		_complete_npc_challenge(context)
		return
	if context.zone_battle:
		_complete_zone_battle(context)
		return
	if context.is_graveyard_boss:
		_complete_graveyard_challenge(context)
		return
	if context.is_ninja_boss:
		_complete_ninja_challenge(context)
		return
	if not in_dungeon():
		SceneManager.go_to_town()
		return
	run.finish_encounter(context.game)
	if not context.won or run.failed:
		abandon_run("You were carried out of the Hollow. Your collection is safe.")
		return
	if context.boss_phase >= 0 and context.boss_phase < PrimmBoss.PHASES - 1:
		boss_phase = context.boss_phase + 1
		boss_phase_pending = true
		save_game()
		SceneManager.change_scene("res://scenes/dungeon_map.tscn")
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
		# reward picks infrastructure exactly on 45, but if the challenge went badly the player would
		# otherwise walk into town one card short of a legal deck. A basic infrastructure of their own
		# color always keeps it legal without changing the "3 on-element picks" story.
		if deck.size() < DeckValidator.MIN_DECK_SIZE:
			var infra: CardData = content.infrastructure[int(profile.primary_affinity)] as CardData
			while deck.size() < DeckValidator.MIN_DECK_SIZE:
				deck.cards.append(infra)
	profile.intro_dungeon_cleared = true
	set_flag(&"trial_cleared")
	run = null
	dungeon_map = null
	if not cleared_dungeons.has(TrialOfTheHollow.DUNGEON_NAME):
		cleared_dungeons.append(TrialOfTheHollow.DUNGEON_NAME)
	EventBus.collection_changed.emit()
	save_game()


func abandon_run(notice: String = "") -> void:
	if main_dungeon_active:
		finish_main_dungeon(false, run != null and (run.failed or run.hp <= 0))
		return
	if mini_active:
		finish_mini_dungeon(false, run != null and (run.failed or run.hp <= 0))
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


# ---- Debug helpers (packs) ---------------------------------------------------------------------------------


## Debug: one of every pack kind in the inventory (for the Dev Shrine and the e2e runs).
func grant_dev_packs(amount: int = 1) -> void:
	for pack: PackData in PackCatalog.all():
		add_pack(pack.id, amount)


## Debug: frees a zone as if its dungeon had been cleared for the first time (flag only; no rewards).
func dev_free_zone(zone_id: String) -> void:
	flags[str(ZoneCompletion.flag_name(zone_id))] = true
	_sync_freed_stories()
	refresh_quests()


# ---- Cosmetics (hats, cloaks, dyes: purely visual) ---------------------------------------------------------------------------------


## Adds a hat or cloak to the wardrobe. False for unknown ids or items already owned. Pass `announce` to toast it.
func grant_cosmetic(item_id: String, announce: bool = false) -> bool:
	if not cosmetics.grant(item_id):
		return false
	EventBus.cosmetics_changed.emit()
	if announce:
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		town_notice = "New %s: %s! (open the wardrobe with T)" % [item.slot_name().to_lower(), item.display_name]
	save_game()
	return true


## Buys a cosmetic at the tailor: pays the price (the vendor discount does not apply to clothes) and adds it.
func buy_cosmetic(item_id: String) -> bool:
	var item: CosmeticData = CosmeticCatalog.find(item_id)
	if item == null or not item.is_for_sale() or cosmetics.owns(item_id):
		return false
	if not Condition.met(item.unlock, unlock_state()):
		return false
	if not spend_gold(item.price):
		return false
	cosmetics.grant(item_id)
	bump_counter("cosmetics_bought")
	EventBus.cosmetics_changed.emit()
	save_game()
	return true


## Applies a (previewed) look: the equipped hat/cloak and dyes copied from `look`.
func apply_look(look: CosmeticState) -> void:
	cosmetics.hat_id = look.hat_id if cosmetics.owns(look.hat_id) else ""
	cosmetics.cloak_id = look.cloak_id if cosmetics.owns(look.cloak_id) else ""
	cosmetics.hat_dye = Dye.clamp_index(look.hat_dye)
	cosmetics.cloak_dye = Dye.clamp_index(look.cloak_dye)
	EventBus.cosmetics_changed.emit()
	save_game()


## The new-game choice: grants and equips the chosen starter hat and cloak ("" for none) and marks the look as chosen.
func choose_starting_look(hat_item: String, cloak_item: String, hat_dye_index: int, cloak_dye_index: int) -> void:
	for item_id: String in [hat_item, cloak_item]:
		if item_id != "":
			cosmetics.grant(item_id)
	cosmetics.equip(CosmeticData.Slot.HAT, hat_item)
	cosmetics.equip(CosmeticData.Slot.CLOAK, cloak_item)
	cosmetics.set_dye(CosmeticData.Slot.HAT, hat_dye_index)
	cosmetics.set_dye(CosmeticData.Slot.CLOAK, cloak_dye_index)
	cosmetics.look_chosen = true
	EventBus.cosmetics_changed.emit()
	save_game()


# ---- Chest rewards (polish round) ---------------------------------------------------------------------------------------------------------


## Pays out one hidden chest's contents and describes them for the reward box. `reward` is a chest table row: gold (int), item (item id), card (card id),
## equipment (equipment id), cosmetic (cosmetic id), pack (pack id) and xp (int), any of them optional (a missing/empty value means "none of that").
## The caller marks the chest found (`discover_secret`) and saves.
func grant_chest_reward(reward: Dictionary, title: String = "Hidden chest") -> RewardSummary:
	var summary: RewardSummary = RewardSummary.new()
	summary.kind = RewardSummary.Kind.CHEST
	summary.title = title
	var gold_amount: int = int(reward.get("gold", 0))
	if gold_amount > 0:
		add_gold(gold_amount)
		summary.gold = gold_amount
	var item_id: String = str(reward.get("item", ""))
	if not item_id.is_empty() and content.item(item_id) != null:
		add_item(content.item(item_id))
		summary.items.append(content.item(item_id))
	var card_id: String = str(reward.get("card", ""))
	if not card_id.is_empty() and card_by_id(card_id) != null:
		add_cards([card_by_id(card_id)] as Array[CardData])
		summary.cards.append(card_by_id(card_id))
	var equipment_id: String = str(reward.get("equipment", ""))
	if not equipment_id.is_empty():
		var piece: EquipmentData = content.equipment_piece(equipment_id)
		if piece != null and grant_equipment(piece):
			summary.equipment.append(piece)
	var cosmetic_id: String = str(reward.get("cosmetic", ""))
	if not cosmetic_id.is_empty() and grant_cosmetic(cosmetic_id):
		summary.cosmetics.append(CosmeticCatalog.find(cosmetic_id).display_name)
	var pack_id: String = str(reward.get("pack", ""))
	if not pack_id.is_empty() and add_pack(pack_id):
		var pack: PackData = PackCatalog.find(pack_id)
		summary.add_pack(pack_id, pack.display_name if pack != null else pack_id)
	var xp_amount: int = int(reward.get("xp", 0))
	if xp_amount > 0:
		summary.xp = xp_amount
		var gained: Array[LevelData] = add_xp(xp_amount)
		pending_level_ups.append_array(gained)
		for row: LevelData in gained:
			summary.levels_reached.append(row.level)
	return summary
