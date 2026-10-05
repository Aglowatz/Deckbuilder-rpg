class_name EleventhBriefSmoke
extends Node
## Brief 11 final e2e with human-style input (real injected keys and clicks): the Pack Vendor (locked, then stocked), a debug-forced zone
## dungeon clear (Path Pack, first-clear bonus, vendor unlock, the announcement), buying a General Pack and the Tier 2 unlock, the black
## market, opening every pack type from the Character screen (guarantees, the essence summary, a Legendary reveal), the quest reward line,
## full health on entering town and on switching zones, and free Gainlands portal rips.
## Deliberate shortcuts (stated): the dungeon clear is forced (`Session.finish_main_dungeon(true)`), zones are entered through
## `Session.enter_zone`, the second zone is freed with a debug flag, the RNG is seeded to make a Legendary / known cards come up, and the
## Capital's hideout hero is teleported next to Fig.
## Screenshots: _screenshots/brief11/.   Godot --path . res://tools/eleventh_brief_final_launcher.tscn

const SHOT_DIR: String = "res://_screenshots/brief11/"
const TAG: String = "eleventh_smoke"

var driver: UiDriver
var _failures: PackedStringArray = []
var _held: Dictionary = {}
var _shots: int = 0
var _only: String = ""


func run() -> void:
	_only = OS.get_environment("SMOKE_ONLY")
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.A)
	Session.gold = 5000
	driver = UiDriver.new(get_tree())
	await driver.frames(10)
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish(false, "town never loaded")
		return
	await driver.frames(10)
	if _only != "" and ("black_market" in _only or ("vendor_stocked" in _only and not "dungeon_clear" in _only)):
		Session.dev_free_zone(DnaZone.ID)  # state the skipped flows would have left
		if "black_market" in _only:
			Session.dev_free_zone(HeapZone.ID)
	for flow: Array in [["vendor_locked", _flow_vendor_locked.bind(town)], ["dungeon_clear", _flow_dungeon_clear], ["vendor_stocked", _flow_vendor_stocked_and_quest],
			["general", _flow_general_packs], ["open_packs", _flow_open_every_pack], ["black_market", _flow_black_market], ["health", _flow_health_and_rips]]:
		if _only == "" or String(flow[0]) in _only.split(","):
			await (flow[1] as Callable).call()
	_finish(_failures.is_empty(), "vendor, dungeon rewards, shops, every pack opened, health and free rips (%d screenshots)" % _shots)


# ---- 1: the Pack Vendor, nothing cleared yet --------------------------------------------------------------------------------


func _flow_vendor_locked(town: TownScene) -> void:
	await _walk_to(town, (town.town.anchors["npc_pack_vendor"] as Vector3) + Vector3(0.0, 0.0, 1.0), 1.5)
	await driver.seconds(0.4)
	await _shot("p01_pack_vendor_stall")
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	_check(town.dialogue.active, "Foil Fenwick talks")
	await _shot("p02_pack_vendor_dialogue")
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	var shop: PackShopScreen = _find_shop(town)
	_check(shop != null, "the Pack Vendor's stall opens")
	if shop == null:
		return
	for path: Affinity.Type in Affinity.colored_types():
		_check(shop.find_child("Buy_%s" % PackRules.path_pack_id(path), true, false) == null, "%s pack is a teaser before its dungeon is cleared" % Affinity.display_name(path))
	_check(shop.find_child("Buy_prismatic", true, false) == null, "the Prismatic Pack is hidden before the postgame")
	await _shot("p03_pack_vendor_all_locked")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)


# ---- 2: a zone dungeon clear (forced), the rewards and the announcement -------------------------------------------------------


func _flow_dungeon_clear() -> void:
	Session.enter_zone(DnaZone.ID)
	var zone: DnaScene = await _wait_for(DnaScene) as DnaScene
	_check(zone != null, "entered the D.N.A.")
	if zone == null:
		return
	zone._spawn_grace = 600.0
	await driver.seconds(1.5)
	await _clear_popups(zone)
	Session.enter_main_dungeon()
	await driver.seconds(1.5)
	_check(Session.main_dungeon_active, "inside the Hall of Final Approvals")
	var gold_before: int = Session.gold
	var config: PackConfig = PackCatalog.config()
	Session.finish_main_dungeon(true)  # shortcut: the boss is forced to fall
	zone = await _wait_for(DnaScene) as DnaScene
	await driver.seconds(1.8)
	_check(Session.is_zone_completed(DnaZone.ID), "the zone is freed")
	_check(Session.pack_count("path_necrocrat") == config.dungeon_pack_count, "the dungeon paid the Necrocrat Pack")
	_check(Session.pack_count("gilded_necrocrat") == config.first_clear_gilded_packs, "the first clear paid a Gilded Necrocrat Pack")
	_check(Session.gold >= gold_before + config.first_clear_bonus_gold, "the first clear paid bonus gold")
	var announcement: AnnouncementScreen = _find_announcement(zone)
	_check(announcement != null, "the zone-freed announcement shows")
	await _shot("p04_zone_freed_reward_screen")
	var guard: int = 0
	while _find_announcement(zone) != null and guard < 10:
		guard += 1
		await driver.click_button("Continue")
		await driver.seconds(0.5)
	await _clear_popups(zone)
	# A second clear pays the Path Pack again, but no extras.
	Session.enter_main_dungeon()
	await driver.seconds(1.2)
	var gilded_before: int = Session.pack_count("gilded_necrocrat")
	Session.finish_main_dungeon(true)
	zone = await _wait_for(DnaScene) as DnaScene
	await driver.seconds(1.5)
	_check(Session.pack_count("path_necrocrat") == config.dungeon_pack_count * 2, "every clear pays the Path Pack")
	_check(Session.pack_count("gilded_necrocrat") == gilded_before, "the Gilded Pack was a first-clear reward only")
	await _shot("p05_repeat_clear_toast")
	await _clear_popups(zone)


# ---- 3: the vendor now stocks the pack; a quest pays a pack -------------------------------------------------------------------


func _flow_vendor_stocked_and_quest() -> void:
	Session.leave_zone()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	_check(town != null and Session.zone_run == null, "back in town: no zone visit, a full heal")
	await driver.seconds(1.0)
	await _dismiss(town.dialogue)
	await _walk_to(town, (town.town.anchors["npc_pack_vendor"] as Vector3) + Vector3(0.0, 0.0, 1.0), 1.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	var shop: PackShopScreen = _find_shop(town)
	_check(shop != null, "the stall opens again")
	if shop == null:
		return
	var buy: Control = shop.find_child("Buy_path_necrocrat", true, false) as Control
	_check(buy != null, "the Necrocrat Pack is now for sale")
	_check(shop.find_child("Buy_path_beefcake", true, false) == null, "the other Paths are still teasers")
	await _shot("p06_pack_vendor_stocked")
	if buy != null:
		var gold_before: int = Session.gold
		var packs_before: int = Session.pack_count("path_necrocrat")
		await driver.click(driver.center_of_control(buy))
		await driver.seconds(0.6)
		_check(Session.pack_count("path_necrocrat") == packs_before + 1, "buying adds the pack to the inventory")
		_check(Session.gold == gold_before - PackShop.price_for(PackCatalog.find("path_necrocrat"), Session.profile), "and charges its price")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)
	# A quest that pays a pack: completing it shows the pack in the notice and the quest log.
	_check(Session.start_quest("dna_audit"), "the Compliance Audit starts")
	var packs: int = Session.pack_count("path_necrocrat")
	_check(Session.complete_quest("dna_audit"), "and completes (shortcut: objectives not played here)")
	_check(Session.pack_count("path_necrocrat") == packs + 1, "the quest paid a Necrocrat Pack")
	await driver.tap_key(KEY_J)
	await driver.seconds(0.8)
	await _shot("p07_quest_log_pack_reward")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)


# ---- 4: General Packs and the tier 2 unlock -------------------------------------------------------------------------------------


func _flow_general_packs() -> void:
	var town: TownScene = get_tree().current_scene as TownScene
	if _only != "" and not "vendor_stocked" in _only and not "dungeon_clear" in _only:
		Session.dev_free_zone(DnaZone.ID)  # state the skipped flows would have left
	await _clear_town_overlays(town)
	_note("level %d zones %d" % [Session.unlock_state().player_level, Session.unlock_state().zones_completed])
	_check(not PackShop.tier2_unlocked(Session.unlock_state()), "tier 2 is locked (level 1, one zone free)")
	await _walk_to(town, (town.town.anchors["npc_market"] as Vector3) + Vector3(0.0, 0.0, 1.0), 1.5)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	_check(await driver.click_button("Card Packs"), "the card vendor has a Card Packs button")
	await driver.seconds(0.6)
	var shop: PackShopScreen = _find_shop(town)
	_check(shop != null, "Sable's pack stall opens")
	if shop == null:
		return
	_check(shop.find_child("Buy_general_1", true, false) != null, "General Pack tier 1 is for sale from the start")
	_check(shop.find_child("Buy_general_2", true, false) == null, "tier 2 is a teaser")
	await _shot("p08_card_vendor_tier1")
	var buy: Control = shop.find_child("Buy_general_1", true, false) as Control
	var before: int = Session.pack_count("general_1")
	await driver.click(driver.center_of_control(buy))
	await driver.seconds(0.5)
	_check(Session.pack_count("general_1") == before + 1, "a General Pack was bought")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)
	# The second zone is freed (debug flag): tier 2 and the vendor's expanded selection unlock.
	var listed_before: int = VendorData.graduated(Session.content, Session.deck.colors(), null).available_card_ids(Session.unlock_state()).size()
	Session.dev_free_zone(HeapZone.ID)
	_check(PackShop.tier2_unlocked(Session.unlock_state()), "two zones free unlock tier 2")
	var listed_after: int = VendorData.graduated(Session.content, Session.deck.colors(), null).available_card_ids(Session.unlock_state()).size()
	_check(listed_after > listed_before, "and the vendor's expanded selection (%d -> %d cards)" % [listed_before, listed_after])
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(town.dialogue)
	await driver.seconds(0.6)
	await driver.click_button("Card Packs")
	await driver.seconds(0.6)
	shop = _find_shop(town)
	var tier2: Control = shop.find_child("Buy_general_2", true, false) as Control if shop != null else null
	_check(tier2 != null, "General Pack tier 2 is now for sale")
	await _shot("p09_card_vendor_tier2_unlocked")
	if tier2 != null:
		var count: int = Session.pack_count("general_2")
		await driver.click(driver.center_of_control(tier2))
		await driver.seconds(0.5)
		_check(Session.pack_count("general_2") == count + 1, "a tier 2 pack was bought")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.5)


# ---- 5: every pack type, opened from the Character screen ----------------------------------------------------------------------


func _flow_open_every_pack() -> void:
	var town: TownScene = get_tree().current_scene as TownScene
	Session.grant_dev_packs(1)  # debug helper
	Session.profile.postgame_unlocked = true  # debug flag: the Prismatic Pack's condition
	await driver.tap_key(KEY_C)
	await driver.seconds(0.8)
	var screen: CharacterScreen = _find_character(town)
	_check(screen != null, "the Character screen opens")
	if screen == null:
		return
	await _shot("p10_character_screen_packs")
	# A Path Pack whose first card is a fourth-copy-owner: the summary shows the essence conversion.
	await _open_pack(town, "path_beefcake", {"own_first": true, "shot": "p11_path_pack_summary_essence"})
	# A Gilded Pack with a Legendary: the big moment.
	await _open_pack(town, "gilded_beefcake", {"legendary": true, "shot_legendary": "p12_gilded_pack_legendary_reveal", "shot": "p13_gilded_pack_summary"})
	await _open_pack(town, "prismatic", {"shot": "p14_prismatic_pack_summary"})
	await _open_pack(town, "general_1", {})
	await _open_pack(town, "general_2", {})
	await _open_pack(town, "gilded_necrocrat", {"shot_tear": "p15_gilded_pack_tear"})
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)


## Opens `pack_id` from the Character screen the way a player does (click Open, click the pack, click each card, Done) and checks what
## came out against the pack's rules.
func _open_pack(town: TownScene, pack_id: String, options: Dictionary) -> void:
	var pack: PackData = PackCatalog.find(pack_id)
	_check(Session.pack_count(pack_id) > 0, "%s is in the inventory" % pack.display_name)
	_prepare_rng(pack, bool(options.get("legendary", false)), bool(options.get("own_first", false)))
	var screen: CharacterScreen = _find_character(town)
	var button: Control = screen.find_child("Open_%s" % pack_id, true, false) as Control
	_check(button != null, "an Open button for %s" % pack.display_name)
	if button == null:
		return
	var essence_before: int = Session.profile.total_essence()
	await driver.click(driver.center_of_control(button))
	await driver.seconds(1.4)
	var opening_screen: PackOpeningScreen = _find_opening(town)
	_check(opening_screen != null, "%s: the opening screen plays" % pack.display_name)
	if opening_screen == null:
		return
	var opening: PackOpening = opening_screen.opening
	await _shot(str(options.get("shot_tear", "p_tmp_pack"))) if options.has("shot_tear") else await driver.frames(1)
	var center: Vector2 = Vector2(960, 540)
	await driver.click(center)  # tear it
	var guard: int = 0
	var legendary_shot: bool = false
	while opening_screen._phase != PackOpeningScreen.Phase.SUMMARY and guard < 60:
		guard += 1
		await driver.seconds(0.4)
		if guard % 5 == 1:
			_note("pack phase %d busy %s next %d hover %s" % [opening_screen._phase, str(opening_screen._busy), opening_screen._next, str(get_viewport().gui_get_hovered_control().get_path()) if get_viewport().gui_get_hovered_control() != null else "none"])
		if opening_screen._phase == PackOpeningScreen.Phase.REVEAL and not opening_screen._busy:
			await driver.click(center)  # reveal the next card (the last click goes on to the summary)
			var flipped: int = opening_screen._next - 1
			if options.has("shot_legendary") and not legendary_shot and flipped >= 0 and flipped < opening.entries.size() and int(opening.entries[flipped].card.rarity) == CardEnums.Rarity.LEGENDARY:
				await driver.seconds(1.8)
				await _shot(str(options["shot_legendary"]))
				legendary_shot = true
	await driver.seconds(1.0)
	_check(opening_screen._phase == PackOpeningScreen.Phase.SUMMARY, "%s: reached the summary" % pack.display_name)
	if options.has("shot"):
		await _shot(str(options["shot"]))
	# The rules.
	_check(opening.entries.size() == pack.card_count, "%s: %d cards" % [pack.display_name, pack.card_count])
	if pack.guarantee_epic_or_legendary:
		_check(opening.cards().any(func(card: CardData) -> bool: return card.rarity >= CardEnums.Rarity.EPIC), "%s: an Epic or Legendary is guaranteed" % pack.display_name)
	if pack.guarantee_multipath:
		_check(opening.cards().any(func(card: CardData) -> bool: return card.is_multipath()), "%s: a multi-Path card is guaranteed" % pack.display_name)
	for card: CardData in opening.cards():
		_check(not card.not_in_packs, "%s: %s is allowed in packs" % [pack.display_name, card.id])
		if pack.kind == PackData.Kind.GENERAL and pack.general_tier == 1:
			_check(card.rarity <= CardEnums.Rarity.UNCOMMON, "%s: %s is a Common or Uncommon" % [pack.display_name, card.id])
	if bool(options.get("own_first", false)):
		_check(opening.converted_count() >= 1, "%s: the fourth-copy cards converted" % pack.display_name)
		_check(Session.profile.total_essence() - essence_before == _sum(opening.essence_totals()), "%s: the summary's essence matches what was added" % pack.display_name)
	if bool(options.get("legendary", false)):
		_check(opening.has_legendary(), "%s: the Legendary came up" % pack.display_name)
	await driver.click_button("Done")
	await driver.seconds(0.8)
	_check(_find_opening(town) == null, "%s: the screen closed" % pack.display_name)
	_check(Session.pack_count(pack_id) == 0 or pack_id == "", "%s: the pack was used up" % pack.display_name)


func _sum(totals: Dictionary) -> int:
	var total: int = 0
	for value: Variant in totals.values():
		total += int(value)
	return total


## Seeds the Session RNG so the next opening of `pack` is known: with a Legendary, or with the first card already owned four times.
func _prepare_rng(pack: PackData, want_legendary: bool, own_first: bool) -> void:
	var content: ContentSet = Session.content
	var seed_value: int = 100
	var found: bool = false
	while not found and seed_value < 5000:
		seed_value += 1
		var probe: RandomNumberGenerator = RandomNumberGenerator.new()
		probe.seed = seed_value
		var rolled: Array[CardData] = PackRoller.roll(pack, content, probe)
		found = not want_legendary or rolled.any(func(card: CardData) -> bool: return card.rarity == CardEnums.Rarity.LEGENDARY)
	Session.rng.seed = seed_value
	if own_first:
		var probe: RandomNumberGenerator = RandomNumberGenerator.new()
		probe.seed = seed_value
		var preview: Array[CardData] = PackRoller.roll(pack, content, probe)
		for card: CardData in preview.slice(0, 2):
			while Session.owned_count(card.id) < DeckValidator.MAX_COPIES:
				Session.add_cards([card] as Array[CardData])


# ---- 6: the black market ---------------------------------------------------------------------------------------------------------


func _flow_black_market() -> void:
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	Session.enter_zone(CapitalZone.ID)
	var zone: CapitalScene = await _wait_for(CapitalScene) as CapitalScene
	_check(zone != null, "in the Capital's hideout")
	if zone == null:
		return
	zone._spawn_grace = 600.0
	await driver.seconds(1.5)
	await _clear_popups(zone)
	var fig: ZoneSpot = null
	for spot: ZoneSpot in zone.spots:
		if spot.id == "fig":
			fig = spot
	_check(fig != null, "Fig Sly's stall exists")
	if fig == null:
		return
	zone.player.position = fig.position + Vector3(0.0, 0.0, 0.4)  # shortcut: teleport next to Fig
	await driver.seconds(0.5)
	var opened: bool = false
	for attempt: int in range(4):  # the first E can land before the prompt is live; a player would simply press it again
		await driver.tap_key(KEY_E)
		await driver.seconds(0.5)
		await _clear_popups(zone)
		await driver.seconds(0.6)
		opened = await driver.click_button("Card Packs")
		if opened:
			break
	_check(opened, "the black market has a Card Packs button")
	await driver.seconds(0.6)
	var shop: PackShopScreen = _find_shop(zone)
	_check(shop != null, "Fig's Gilded stall opens")
	if shop != null:
		_check(shop.find_child("Buy_gilded_necrocrat", true, false) != null, "the Gilded Necrocrat Pack is for sale (that zone is free)")
		_check(shop.find_child("Buy_gilded_refusemancer", true, false) != null, "and the Refusemancer one (also free)")
		_check(shop.find_child("Buy_gilded_beefcake", true, false) == null, "the Gilded Beefcake Pack is not (that zone is not free)")
		await _shot("p16_black_market_gilded")
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)
	await driver.tap_key(KEY_ESCAPE)
	await driver.seconds(0.4)


# ---- 7: full health and free portal rips -----------------------------------------------------------------------------------------


func _flow_health_and_rips() -> void:
	Session.leave_zone()
	var town: TownScene = await _wait_for(TownScene) as TownScene
	await driver.seconds(1.0)
	_check(Session.zone_run == null, "arriving in town ends the zone visit (a full heal)")
	Session.enter_zone(DnaZone.ID)
	var dna: DnaScene = await _wait_for(DnaScene) as DnaScene
	await driver.seconds(1.2)
	dna._spawn_grace = 600.0
	await _clear_popups(dna)
	_check(Session.zone_run.life == Session.zone_run.max_life(), "entering a zone from town: full life")
	Session.zone_run.damage(6)
	Session.unlock_fast_travel(GainlandsZone.ID)
	_check(Session.fast_travel_to(GainlandsZone.ID), "a rift trip from the D.N.A. to the Gainlands")
	var gain: GainlandsScene = await _wait_for(GainlandsScene) as GainlandsScene
	await driver.seconds(1.5)
	_check(Session.zone_run.zone_id == GainlandsZone.ID and Session.zone_run.life == Session.zone_run.max_life(), "switching zones: full life (%d/%d)" % [Session.zone_run.life, Session.zone_run.max_life()])
	await _shot("p17_new_zone_full_health")
	# Free rips inside the Gainlands: life and gold untouched.
	gain._spawn_grace = 600.0
	await _clear_popups(gain)
	Session.set_flag(GainlandsZone.FLAG_WHEEL_POWERED)  # shortcut: the wheel run is covered by the brief 6 e2e
	Session.zone_run.damage(4)
	var life_before: int = Session.zone_run.life
	var gold_before: int = Session.gold
	var spot: ZoneSpot = _spot(gain, "travel_ripper_delt")
	await _walk_to(gain, spot.position, spot.radius)
	await driver.tap_key(KEY_E)
	await driver.seconds(0.4)
	await _dismiss(gain.dialogue)
	await driver.seconds(0.4)
	await _shot("p18_portal_ripper_confirm_free")
	await driver.click_button("Step through")
	await driver.seconds(1.0)
	await _wait_not_airborne(gain, 12.0)
	await driver.seconds(0.8)
	var island: GainlandsLayout.Island = gain.gain.island_under(gain.player.position)
	_check(island != null and island.id == "delt", "the rip led to Delt Deck")
	_check(Session.gold == gold_before, "the rip cost no gold")
	_check(Session.zone_run.life == life_before, "and no life (still %d, not healed either: zone life rules apply inside a zone)" % life_before)
	await _shot("p19_after_the_free_rip")


# ---- Helpers ----------------------------------------------------------------------------------------------------------------


func _find_shop(root: Node) -> PackShopScreen:
	for node: Node in root.find_children("*", "Control", true, false):
		if node is PackShopScreen:
			return node as PackShopScreen
	return null


func _find_opening(root: Node) -> PackOpeningScreen:
	for node: Node in root.find_children("*", "Control", true, false):
		if node is PackOpeningScreen:
			return node as PackOpeningScreen
	return null


func _find_character(root: Node) -> CharacterScreen:
	for node: Node in root.find_children("*", "Control", true, false):
		if node is CharacterScreen:
			return node as CharacterScreen
	return null


func _find_announcement(root: Node) -> AnnouncementScreen:
	for node: Node in root.find_children("*", "Control", true, false):
		if node is AnnouncementScreen:
			return node as AnnouncementScreen
	return null


func _spot(zone: ZoneScene, id: String) -> ZoneSpot:
	for spot: ZoneSpot in zone.spots:
		if spot.id == id:
			return spot
	return null


func _wait_not_airborne(zone: GainlandsScene, limit: float) -> void:
	var waited: float = 0.0
	while (zone.player.airborne or zone._locked) and waited < limit:
		await driver.frames(3)
		waited += 3.0 / 60.0


func _dismiss(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue.active and guard < 40:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.2)


## Closes whatever blocks the world: a dialogue, a level-up popup, an announcement.
func _clear_popups(zone: ZoneScene) -> void:
	zone._spawn_grace = maxf(zone._spawn_grace, 600.0)
	var guard: int = 0
	while guard < 25 and (zone.dialogue.active or zone._overlay is LevelUpScreen or _find_announcement(zone) != null):
		guard += 1
		if zone.dialogue.active:
			await driver.tap_key(KEY_E)
			await driver.seconds(0.15)
		else:
			await driver.click_button("Continue")
			await driver.seconds(0.4)


func _wait_for(kind: Variant) -> Node:
	var elapsed: float = 0.0
	while elapsed < 30.0:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _walk_to(scene: Node, target: Vector3, radius: float) -> void:
	var player: Node3D = scene.player
	var elapsed: float = 0.0
	while elapsed < 14.0:
		var offset: Vector3 = target - player.position
		offset.y = 0.0
		if offset.length() < radius * 0.55:
			break
		await _hold(KEY_W, offset.z < -0.35)
		await _hold(KEY_S, offset.z > 0.35)
		await _hold(KEY_A, offset.x < -0.35)
		await _hold(KEY_D, offset.x > 0.35)
		await driver.frames(2)
		elapsed += 2.0 / 60.0
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		await _hold(key, false)
	if Vector2(player.position.x - target.x, player.position.z - target.z).length() >= radius:
		_note("walk fell back to a short teleport near %s" % str(target))
		player.position = target + Vector3(0.0, 0.0, 0.4)
		await driver.frames(3)


func _hold(key: Key, down: bool) -> void:
	if bool(_held.get(key, false)) == down:
		return
	_held[key] = down
	await driver.key(key, down)


func _shot(name: String) -> void:
	_shots += 1
	await driver.frames(3)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var image: Image = get_tree().root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, name]))
	print("%s: screenshot -> %s.png" % [TAG, name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	get_tree().quit(0 if ok else 1)


func _note(message: String) -> void:
	print("%s: note  %s" % [TAG, message])


## A quest reward can leave a level-up or reward overlay open in town; close it the way a player would.
func _clear_town_overlays(town: TownScene) -> void:
	var guard: int = 0
	while guard < 12 and town._overlay != null:
		guard += 1
		if not await driver.click_button("Continue"):
			await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.4)
