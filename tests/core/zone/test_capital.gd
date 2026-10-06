extends GutTest
## Brief 10, Part A: the Capital zone - layout (size, connectivity, anchors, chests, rifts), the controlled gate, the secret
## entrance, the four broken-service debuffs (through the Modifier pipeline), rifts, interactables, the four Path quests, the
## enemies (slow battle-starters and a fast damage type), the text keys and the new modifier rules in the engine.

var _layout: CapitalLayout


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	_layout = CapitalLayout.new()
	_layout.build()


# ---- The zone def and registry -------------------------------------------------------------------------


func test_the_capital_is_registered_under_the_final_portal_id() -> void:
	assert_eq(CapitalZone.ID, ZonePortals.FINAL_ID, "the town's final entrance leads to the Capital")
	assert_true(ZoneDefs.has_def(CapitalZone.ID))
	assert_false(ZoneDefs.ids().has(CapitalZone.ID), "the four Path zones are what ZoneCompletion counts")
	assert_true(ZoneDefs.all_ids().has(CapitalZone.ID))
	assert_eq(ZoneDefs.get_def(CapitalZone.ID).scene_path, "res://scenes/capital_zone.tscn")


func test_the_final_entrance_is_open_from_the_start() -> void:
	assert_true(ZonePortals.find(ZonePortals.FINAL_ID).display_name.contains("Capital"))
	assert_eq(Session.completed_zone_count(), 0, "no zone needs to be free to reach the Capital")


# ---- Size, connectivity, anchors ---------------------------------------------------------------------------


func test_the_capital_is_at_least_as_large_as_the_other_zones() -> void:
	# The Buffet and the Dump are ~6,400 m2 of ground; the Gainlands ~4,700.
	assert_gt(_layout.walkable_cell_count(), 6400, "walkable ground")


func test_every_spot_anchor_exists_and_is_walkable() -> void:
	var builder: CapitalBuilder = _builder()
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	for entry: Dictionary in def.spots:
		var anchor_name: String = str(entry["anchor"])
		assert_true(builder.has_anchor(anchor_name), "anchor %s of spot %s" % [anchor_name, str(entry["id"])])
		if not builder.has_anchor(anchor_name):
			continue
		var pos: Vector3 = builder.anchor(anchor_name) + (entry["offset"] as Vector3)
		var reachable: bool = _near_walkable(builder, pos, float(entry["radius"]) + 0.2)
		assert_true(reachable, "spot %s (%s) is reachable on foot" % [str(entry["id"]), str(pos)])


func test_all_spots_hubs_chests_and_enemies_are_connected_to_the_spawn_through_the_gate() -> void:
	var builder: CapitalBuilder = _builder()
	builder.gate_open = true
	var reached: Dictionary = _flood(builder, builder.anchor("spawn"))
	for name_to_check: String in ["gate_inside", "gus", "tilda", "bram", "odile", "castle_door", "net_approach", "manhole", "facade_gate", "fountain", "ward_window", "castle_door"]:
		assert_true(_reaches(reached, builder.anchor(name_to_check)), "%s is reachable from the road" % name_to_check)
	for chest_id: Variant in builder.chest_positions().keys():
		assert_true(_reaches(reached, builder.chest_positions()[chest_id] as Vector3), "chest %s is reachable" % str(chest_id))
	for spawn: Dictionary in builder.enemy_spawns():
		assert_true(builder.is_walkable(spawn["home"] as Vector3, 0.25), "enemy home %s is on open ground" % str(spawn["home"]))
		assert_true(_reaches(reached, spawn["home"] as Vector3), "enemy home %s is reachable" % str(spawn["home"]))


func test_the_closed_gate_keeps_the_city_out_of_reach() -> void:
	var builder: CapitalBuilder = _builder()
	builder.gate_open = false
	var reached: Dictionary = _flood(builder, builder.anchor("spawn"))
	assert_false(_reaches(reached, builder.anchor("gate_inside")), "the barrier closes the 10 m opening")
	assert_false(_reaches(reached, builder.anchor("castle_door")))
	assert_true(_reaches(reached, builder.anchor("tunnel_in")), "the secret shaft is reachable from the road")
	assert_true(_reaches(reached, builder.anchor("exit")))
	builder.open_gate()
	assert_true(builder.gate_open)
	assert_true(_reaches(_flood(builder, builder.anchor("spawn")), builder.anchor("gate_inside")), "once open you can walk in")


func test_the_hideout_is_a_separate_underground_hall() -> void:
	var builder: CapitalBuilder = _builder()
	var hub: Dictionary = _flood(builder, builder.anchor("crease_spawn"))
	for name_to_check: String in ["mabbit", "fig", "heal", "ladder_up", "tunnel_out", "fig_crate"]:
		assert_true(_reaches(hub, builder.anchor(name_to_check)), "%s is in the Crease" % name_to_check)
	assert_false(_reaches(hub, builder.anchor("spawn")), "the Crease is not connected on foot to the city")
	for destination: String in CapitalLayout.NETWORK_DESTINATIONS:
		assert_true(builder.has_anchor("shaft_" + destination))
		assert_true(builder.has_anchor("net_" + destination), "each shaft surfaces at a street anchor")
		assert_true(builder.is_walkable(builder.anchor("net_" + destination) + Vector3(0, 0, 1.0)), "net_%s is on open ground" % destination)


func test_the_hub_has_a_heal_a_vendor_and_resistance_npcs_and_no_enemies() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var kinds: Array[String] = []
	for entry: Dictionary in def.spots:
		kinds.append(str(entry["kind"]))
	assert_true(kinds.has("heal"))
	assert_true(kinds.has("vendor_npc"))
	for spawn: Dictionary in _layout.enemy_spawns:
		assert_lt((spawn["home"] as Vector3).z, 96.0, "no enemies in the underground hideout")
	assert_gt(def.vendor_ids.size(), 4, "a black market of rare cards")
	for card_id: String in def.vendor_ids:
		assert_not_null(Session.card_by_id(card_id), "black market card %s exists" % card_id)
	for item_id: String in CapitalZone.BLACK_MARKET_ITEMS.keys():
		assert_not_null(Session.content.item(item_id), "black market item %s exists" % item_id)


func test_districts_and_areas() -> void:
	var titles: Array[String] = []
	for area: CapitalLayout.Area in _layout.areas:
		titles.append(area.title)
	for expected: String in ["The Outskirts", "The Approved Gate", "Primm's Perfection", "The Reek", "Grave Row", "The Transit Yards", "The Hungry Quarter", "The Correction Ward", "The Castle Approach", "The Crease"]:
		assert_true(titles.has(expected), "area %s" % expected)


func test_the_facade_is_sixteen_identical_houses_and_painted_shops() -> void:
	var houses: int = 0
	var shops: int = 0
	for building: CapitalLayout.Building in _layout.buildings:
		if building.style == "house":
			houses += 1
		elif building.style == "shop":
			shops += 1
	assert_eq(houses + shops, 16, "a regular grid of houses")
	assert_gte(shops, 2, "painted storefronts")
	var citizens: int = 0
	for entry: Dictionary in ZoneDefs.get_def(CapitalZone.ID).npcs:
		if bool(entry.get("facade", false)):
			citizens += 1
	assert_gte(citizens, 8, "citizens in matching clothes")


# ---- Hidden things ---------------------------------------------------------------------------------------------


func test_at_least_six_hidden_chests_with_rewards() -> void:
	assert_gte(_layout.chests.size(), 6)
	for id: Variant in _layout.chests.keys():
		assert_true(CapitalZone.CHEST_REWARDS.has(str(id)), "reward for %s" % str(id))
		var reward: Dictionary = CapitalZone.CHEST_REWARDS[str(id)] as Dictionary
		var card_id: String = str(reward.get("card", ""))
		if not card_id.is_empty():
			assert_not_null(Session.card_by_id(card_id), "chest card %s exists" % card_id)
		var item_id: String = str(reward.get("item", ""))
		if not item_id.is_empty():
			assert_not_null(Session.content.item(item_id), "chest item %s exists" % item_id)
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	for entry: Dictionary in def.spots:
		assert_false(_layout.chests.has(str(entry["id"])), "chests are never spots (no marker)")
	for kind: int in MapPoi.Kind.values():
		assert_ne(MapPoi.kind_name(kind as MapPoi.Kind).to_lower(), "chest", "no minimap kind may reveal a chest")


func test_the_secret_tunnel_is_hidden_and_listed_in_the_secrets_doc() -> void:
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var spot: Dictionary = def.spot_def("tunnel_in")
	assert_true(bool(spot.get("hidden", false)), "no marker, no plate")
	assert_false(def.poi_kinds.has("tunnel_in"), "never on the minimap")
	var doc: String = FileAccess.get_file_as_string("res://docs/design/secrets.md")
	assert_true(doc.contains("Old Joint Works"), "documented in docs/design/secrets.md")
	assert_true(doc.contains("chest_wreck"))


# ---- Debuffs ------------------------------------------------------------------------------------------------------------


func test_each_service_debuff_is_active_until_its_zone_is_free() -> void:
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.all():
		assert_true(CapitalDebuffs.is_active(Session.flags, debuff.zone_id), debuff.zone_id)
	assert_eq(CapitalDebuffs.active(Session.flags).size(), 4)
	Session.complete_zone("beefcake")
	assert_false(CapitalDebuffs.is_active(Session.flags, "beefcake"))
	assert_eq(CapitalDebuffs.active(Session.flags).size(), 3)
	assert_false(CapitalDebuffs.darkness(Session.flags), "lights return when the Beefcakes are free")
	assert_true(CapitalInteractables.can_travel(Session.flags))
	assert_eq(CapitalDebuffs.speed_multiplier(Session.flags), 1.0)


func test_blackout_darkens_slows_blocks_travel_and_exhausts_your_units() -> void:
	assert_true(CapitalDebuffs.darkness(Session.flags))
	assert_lt(CapitalDebuffs.speed_multiplier(Session.flags), 1.0)
	assert_false(CapitalInteractables.can_travel(Session.flags))
	var player_mods: ModifierSource = CapitalDebuffs.player_source(Session.flags, Session.content)
	var set: ModifierSet = ModifierSet.new()
	set.add_source(player_mods)
	var data: CardData = Session.card_by_id("compliance_officer")
	assert_gt(set.sum_for_card(Modifier.Kind.ENTER_EXHAUSTED, data), 0)


func test_famine_lowers_max_hp_and_blocks_healing_items() -> void:
	var run: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	var before_famine: int = Session.profile.base_max_hp() + ModifierPipeline.build(Session.profile, null, [] as Array[ModifierSource]).sum(Modifier.Kind.MAX_HP)
	assert_eq(run.max_hp(), before_famine + CapitalDebuffs.FAMINE_MAX_HP, "Famine: max HP -5")
	assert_eq(run.hp, run.max_hp(), "a visit starts at full (reduced) HP")
	var salve: ItemData = Session.content.item("healing_salve")
	run.damage(4)
	assert_true(Session.healing_blocked_for(salve), "healing items do not work in the Capital under Famine")
	var hp_before: int = run.hp
	Session.add_item(salve)
	Session.use_item(salve)
	assert_eq(run.hp, hp_before, "no healing happened")
	Session.complete_zone("gourmand")
	assert_false(Session.healing_blocked_for(salve), "freed: food works again")
	var fresh: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	assert_eq(fresh.max_hp(), before_famine, "and the max HP is back")


func test_clutter_shuffles_junk_into_your_deck_in_every_capital_duel() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	var context: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "officer_0")
	var junk: int = 0
	for card: CardInstance in context.game.players[0].deck:
		if card.data.id == CapitalContent.JUNK_ID:
			junk += 1
	for card: CardInstance in context.game.players[0].hand:
		if card.data.id == CapitalContent.JUNK_ID:
			junk += 1
	assert_eq(junk, CapitalDebuffs.JUNK_COUNT, "three Heaps of Rubbish")
	Session.complete_zone("refusemancer")
	Session.begin_zone_visit(CapitalZone.ID)
	var clean: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "officer_0")
	for card: CardInstance in clean.game.players[0].deck:
		assert_ne(card.data.id, CapitalContent.JUNK_ID, "no junk once the Dump is free")


func test_restless_dead_makes_enemy_units_return_from_the_graveyard() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	var context: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "officer_0")
	var enemy_mods: ModifierSet = context.game.players[1].modifiers
	assert_eq(enemy_mods.sum(Modifier.Kind.GRAVEYARD_RETURN_CHANCE), CapitalDebuffs.RETURN_CHANCE_PERCENT)
	# Engine rule: with a 100% chance a dying unit comes straight back; tokens never do.
	var game: GameState = _plain_game()
	var modifier: Modifier = CardBuilder.modifier(Modifier.Kind.GRAVEYARD_RETURN_CHANCE, 100)
	game.players[1].modifiers.add(modifier)
	var unit: CardInstance = game.create_instance(Session.card_by_id("sellsword"), 1)
	game.players[1].field.append(unit)
	game.destroy_unit(unit)
	assert_true(game.players[1].field.has(unit), "returned from the graveyard")
	assert_false(game.players[1].refuse_pile.has(unit))
	var other: CardInstance = game.create_instance(Session.card_by_id("sellsword"), 0)
	game.players[0].field.append(other)
	game.destroy_unit(other)
	assert_false(game.players[0].field.has(other), "the player's side is not affected")
	Session.complete_zone("necrocrat")
	Session.begin_zone_visit(CapitalZone.ID)
	var calm: BattleContext = Session.make_zone_battle(CapitalEnemies.OFFICER, "officer_1")
	assert_eq(calm.game.players[1].modifiers.sum(Modifier.Kind.GRAVEYARD_RETURN_CHANCE), 0)


func test_debuff_text_and_tooltips_come_from_the_story_file() -> void:
	for debuff: CapitalDebuffs.Debuff in CapitalDebuffs.all():
		assert_false(debuff.name_text().begins_with("[missing"), debuff.zone_id)
		assert_false(debuff.flavor_text().begins_with("[missing"))
		assert_false(debuff.freed_text().begins_with("[missing"))
		assert_gt(debuff.mechanic_text().length(), 10)
		assert_true(debuff.tooltip(true).contains(debuff.name_text()))
		assert_true(debuff.tooltip(false).contains("restored"))
	var panel: ServiceDebuffsPanel = ServiceDebuffsPanel.make(Session.flags)
	add_child_autofree(panel)
	assert_not_null(panel)


# ---- Rifts ----------------------------------------------------------------------------------------------------------------------


func test_rifts_hurt_on_contact_and_empower_nearby_enemies() -> void:
	assert_gte(CapitalRifts.all().size(), 6)
	var out_a: Dictionary = CapitalRifts.find("out_a")
	var inside: Vector2 = Vector2(float(out_a["x"]), float(out_a["z"]))
	assert_false(CapitalRifts.touching(Session.flags, inside).is_empty(), "standing in a rift touches it")
	assert_true(CapitalRifts.touching(Session.flags, inside + Vector2(20, 0)).is_empty())
	assert_eq(CapitalRifts.damage_of(CapitalRifts.find("transit")), CapitalZone.BIG_RIFT_DAMAGE, "big rifts hurt more")
	assert_eq(CapitalRifts.damage_of(out_a), CapitalZone.RIFT_DAMAGE)
	assert_true(CapitalRifts.empowers(Session.flags, inside + Vector2(3, 0)))
	assert_false(CapitalRifts.empowers(Session.flags, Vector2(60, 90)), "far from any rift")


func test_an_empowered_enemy_fights_with_more_hp_and_stronger_units() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	var plain: BattleContext = Session.make_zone_battle(CapitalEnemies.WRETCH, "wretch_0")
	Session.zone_empower_next = true
	var strong: BattleContext = Session.make_zone_battle(CapitalEnemies.WRETCH, "wretch_1")
	assert_eq(strong.game.players[1].hp, plain.game.players[1].hp + CapitalRifts.EMPOWER_HP)
	assert_eq(strong.game.players[1].modifiers.stat_bonus(Affinity.Type.NEUTRAL), Vector2i(CapitalRifts.EMPOWER_STAT, CapitalRifts.EMPOWER_STAT))
	assert_false(Session.zone_empower_next, "the flag is consumed")


func test_some_rifts_can_be_sealed_for_a_reward_after_their_guardian_falls() -> void:
	var run: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	var sealable: int = 0
	for entry: Dictionary in CapitalRifts.all():
		if bool(entry["sealable"]):
			sealable += 1
			assert_true(_layout.anchors.has("seal_" + str(entry["id"])), "a rift-stone for %s" % str(entry["id"]))
			var guardian_found: bool = false
			for spawn: Dictionary in _layout.enemy_spawns:
				if str(spawn.get("id", "")) == CapitalRifts.guardian_id(str(entry["id"])):
					guardian_found = true
			assert_true(guardian_found, "guardian for %s" % str(entry["id"]))
		else:
			assert_false(CapitalInteractables.seal_rift(run, str(entry["id"]))["ok"], "big/unsealable rifts stay")
	assert_gte(sealable, 3)
	assert_false(CapitalInteractables.seal_rift(run, "out_a")["ok"], "the guardian must fall first")
	run.mark_defeated(CapitalRifts.guardian_id("out_a"))
	var gold_before: int = Session.gold
	var result: Dictionary = CapitalInteractables.seal_rift(run, "out_a")
	assert_true(bool(result["ok"]))
	assert_gt(Session.gold, gold_before, "the reward")
	assert_true(CapitalRifts.is_sealed(Session.flags, "out_a"))
	assert_true(CapitalRifts.touching(Session.flags, Vector2(30, 78)).is_empty(), "a sealed rift no longer hurts")
	assert_false(CapitalInteractables.seal_rift(run, "out_a")["ok"], "only once")


func test_primm_falling_closes_every_rift() -> void:
	assert_gt(CapitalRifts.open_count(Session.flags), 0)
	Session.flags[str(CapitalZone.FLAG_FREED)] = true
	assert_eq(CapitalRifts.open_count(Session.flags), 0)


# ---- Interactables ------------------------------------------------------------------------------------------------------------


func test_defacing_propaganda_pays_a_small_reward_once_each() -> void:
	var gold: int = Session.gold
	assert_true(bool(CapitalInteractables.deface("portrait_f1")["ok"]))
	assert_eq(Session.gold, gold + CapitalZone.DEFACE_REWARD)
	assert_false(bool(CapitalInteractables.deface("portrait_f1")["ok"]), "only once")
	assert_eq(Session.counter(CapitalZone.COUNTER_DEFACED), 1)
	assert_gte(CapitalZone.DEFACE_SPOTS.size(), 4)


func test_the_complaint_box_replies_differently_and_has_a_limit() -> void:
	var run: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	var replies: Array[String] = []
	var first: Dictionary = CapitalInteractables.complaint(run)
	var second: Dictionary = CapitalInteractables.complaint(run)
	replies.append(str(first["reply"]))
	replies.append(str(second["reply"]))
	assert_ne(replies[0], replies[1], "the reply cycles")
	assert_false(bool(CapitalInteractables.complaint(run)["ok"]), "two complaints per visit")
	var fresh: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	assert_true(bool(CapitalInteractables.complaint(fresh)["ok"]), "a new visit")
	# The four replies and their real effects.
	var gold: int = Session.gold
	var run2: ZoneRun = Session.begin_zone_visit(CapitalZone.ID)
	Session.counters[CapitalZone.COUNTER_COMPLAINTS] = 0
	assert_eq(CapitalInteractables.complaint(run2)["reply"], "compensation")
	assert_eq(Session.gold, gold + CapitalInteractables.COMPENSATION_GOLD)
	var hp: int = run2.hp
	run2.visit_counts.clear()
	Session.counters[CapitalZone.COUNTER_COMPLAINTS] = 3
	assert_eq(CapitalInteractables.complaint(run2)["reply"], "inspector")
	assert_eq(run2.hp, hp - CapitalInteractables.INSPECTOR_DAMAGE)


func test_the_four_path_quests_exist_with_rewards_and_an_insight() -> void:
	var ids: Array[String] = [CapitalZone.QUEST_BURIAL, CapitalZone.QUEST_WHEELS, CapitalZone.QUEST_RECIPES, CapitalZone.QUEST_UNTIDY]
	var givers: Array[String] = []
	for quest_id: String in ids:
		var quest: QuestData = QuestCatalog.find(quest_id)
		assert_not_null(quest, "quest %s is in data/quests (run tools/generate_quests.gd)" % quest_id)
		if quest == null:
			continue
		givers.append(quest.giver_npc)
		assert_gt(quest.reward_gold, 0)
		assert_gt(quest.reward_xp, 0)
		assert_false(quest.reward_card_ids.is_empty() and quest.reward_item_ids.is_empty(), "a card or item")
		assert_true(quest.reward_summary().contains("Insight into"), "story insight into Primm")
		assert_eq(quest.objectives.size(), 2)
		var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
		for situation: String in ["offer", "active", "ready", "done"]:
			assert_false(story.get_lines("quest.%s.%s" % [quest_id, situation])[0].begins_with("[missing"), "%s.%s" % [quest_id, situation])
		for card_id: String in quest.reward_card_ids:
			assert_not_null(Session.card_by_id(card_id), "reward card %s" % card_id)
	assert_eq(givers.size(), 4)
	var unique_givers: Dictionary = {}
	for giver: String in givers:
		unique_givers[giver] = true
	assert_eq(unique_givers.size(), 4, "four different citizens")


func test_the_necrocrat_quest_plays_out_through_its_interactables() -> void:
	Session.start_quest(CapitalZone.QUEST_BURIAL)
	assert_false(bool(CapitalInteractables.lay_to_rest()["ok"]), "no burial without the stamp")
	assert_true(bool(CapitalInteractables.pick_up("stamp")["ok"]))
	assert_false(bool(CapitalInteractables.pick_up("stamp")["ok"]), "once")
	assert_true(bool(CapitalInteractables.lay_to_rest()["ok"]))
	var before_gold: int = Session.gold
	Session.turn_in_quest(CapitalZone.QUEST_BURIAL)
	assert_gt(Session.gold, before_gold)
	assert_true(Session.flag(CapitalZone.insight_flag("necrocrat")), "the insight is recorded")
	assert_gt(Session.owned_count("grandfather_marrow"), 0)
	assert_eq(CapitalInteractables.insight_count(Session.flags), 1)


func test_the_other_quests_objects() -> void:
	for n: int in range(1, 4):
		assert_true(bool(CapitalInteractables.free_wheel(n)["ok"]))
		assert_false(bool(CapitalInteractables.free_wheel(n)["ok"]))
	assert_eq(Session.counter(CapitalZone.COUNTER_WHEELS), 3)
	assert_true(bool(CapitalInteractables.cut_cable()["ok"]))
	for recipe: String in ["recipe_1", "recipe_2", "recipe_3"]:
		assert_true(bool(CapitalInteractables.pick_up(recipe)["ok"]))
	assert_eq(Session.counter(CapitalZone.COUNTER_RECIPES), 3)
	assert_true(bool(CapitalInteractables.spoil_paste()["ok"]))
	for heap: String in ["heap_1", "heap_2", "heap_3"]:
		assert_true(bool(CapitalInteractables.pick_up(heap)["ok"]))
	assert_false(bool(CapitalInteractables.plant_seed()["ok"]), "no seed yet")
	assert_true(bool(CapitalInteractables.pick_up("seed")["ok"]))
	assert_true(bool(CapitalInteractables.plant_seed()["ok"]))
	assert_gte(CapitalInteractables.PERMIT_LOOPS.size(), 3)


# ---- Enemies and the gate ------------------------------------------------------------------------------------------------------------


func test_enemy_types_use_the_framework_slow_battle_starters_and_fast_damagers() -> void:
	for id: String in [CapitalEnemies.OFFICER, CapitalEnemies.INSPECTOR, CapitalEnemies.WRETCH]:
		var info: ZoneEnemyInfo = ZoneEnemies.info(CapitalZone.ID, id)
		assert_eq(info.kind, ZoneEnemyInfo.Kind.BATTLE)
		assert_true(ZoneEnemies.is_slow(CapitalZone.ID, id), "%s is slower than the player" % id)
		var deck: Deck = ZoneEnemies.deck(Session.content, CapitalZone.ID, id)
		assert_gt(deck.size(), 20, "%s has a real deck" % id)
	for id: String in [CapitalEnemies.TIDYBOT, CapitalEnemies.SWARM]:
		var info: ZoneEnemyInfo = ZoneEnemies.info(CapitalZone.ID, id)
		assert_eq(info.kind, ZoneEnemyInfo.Kind.DAMAGE)
		assert_false(ZoneEnemies.is_slow(CapitalZone.ID, id), "%s is fast" % id)
		assert_gt(info.damage, 0)
	var types: Dictionary = {}
	for spawn: Dictionary in _layout.enemy_spawns:
		types[str(spawn["type"])] = true
	assert_true(types.has("officer") and types.has("inspector") and types.has("tidybot") and types.has("wretch") and types.has("swarm"))


func test_the_gate_battle_is_challenging_and_winning_it_opens_the_gate() -> void:
	var captain: ZoneEnemyInfo = ZoneEnemies.info(CapitalZone.ID, CapitalEnemies.GATE_CAPTAIN)
	var officer: ZoneEnemyInfo = ZoneEnemies.info(CapitalZone.ID, CapitalEnemies.OFFICER)
	assert_gt(captain.hp, officer.hp, "tougher than a roamer")
	assert_gt(captain.gold_reward, officer.gold_reward)
	Session.begin_zone_visit(CapitalZone.ID)
	assert_false(Session.flag(CapitalZone.FLAG_GATE_OPEN))
	var context: BattleContext = Session.make_zone_battle(CapitalEnemies.GATE_CAPTAIN, CapitalEnemies.GATE_CAPTAIN)
	context.won = true
	context.game.players[0].hp = 12
	var result: Dictionary = Session.resolve_zone_battle(context)
	assert_true(bool(result.get("gate_opened", false)))
	assert_true(Session.flag(CapitalZone.FLAG_GATE_OPEN))
	assert_true(Session.flag(CapitalZone.FLAG_INSIDE))


func test_a_lost_gate_battle_wakes_you_outside_with_a_fee() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	var context: BattleContext = Session.make_zone_battle(CapitalEnemies.GATE_CAPTAIN, CapitalEnemies.GATE_CAPTAIN)
	context.won = false
	context.game.players[0].hp = 0
	var gold: int = Session.gold
	var result: Dictionary = Session.resolve_zone_battle(context)
	assert_true(bool(result.get("woke_at_hub", false)))
	assert_false(Session.flag(CapitalZone.FLAG_GATE_OPEN))
	assert_eq(Session.gold, gold - CapitalZone.FEE)
	assert_eq(ZoneDefs.get_def(CapitalZone.ID).fee, CapitalZone.FEE)


func test_modifier_engine_rules_standardize_units_and_junk() -> void:
	var game: GameState = _plain_game()
	var standard: Modifier = CardBuilder.modifier(Modifier.Kind.STANDARDIZE_UNITS, 3, Modifier.ANY_COLOR, 3)
	game.players[1].modifiers.add(standard)
	var big: CardInstance = game.create_instance(Session.card_by_id("ironclad"), 0)
	var small: CardInstance = game.create_instance(Session.card_by_id("sellsword"), 1)
	game.players[0].field.append(big)
	game.players[1].field.append(small)
	assert_eq(game.get_attack(big), 3, "every unit has the same stats (both sides)")
	assert_eq(game.get_defense(big), 3)
	assert_eq(game.get_attack(small), 3)
	assert_eq(game.get_defense(small), 3)


# ---- Text -------------------------------------------------------------------------------------------------------------------------------


func test_every_text_key_the_capital_uses_exists() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	var missing: Array[String] = []
	for sign_data: CapitalLayout.Sign in _layout.signs:
		_check(story, sign_data.key, missing)
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	for entry: Dictionary in def.npcs:
		var id: String = str(entry["id"])
		if bool(entry.get("facade", false)):
			var n: int = int(id.trim_prefix("citizen_"))
			for variant: String in ["approved", "approved2", "slip"]:
				_check(story, "facade.citizen.%d.%s" % [n, variant], missing)
		elif ["mabbit", "fig", "hesper", "gus", "tilda", "bram", "odile", "gate_captain", "guard_height", "guard_queue", "guard_in_1", "guard_in_2", "exit_clerk", "patient"].has(id):
			_check(story, "npc.%s.intro" % id, missing)
			_check(story, "npc.%s.return" % id, missing)
	for key: String in ["hud.objective", "hud.objective.inside", "hud.objective.freed", "ui.exit.title", "ui.exit.body", "ui.gate.title", "ui.gate.body", "ui.gate.button",
			"ui.main.title", "ui.main.body", "ui.main.body_cleared", "ui.main.button", "fx.main_dungeon", "fx.heal_couch", "fx.heal_already", "fx.hit", "fx.wake", "fx.wake_outside", "fx.chest", "fx.inside",
			"fx.no_travel", "fx.shaft", "fx.ladder", "fx.tunnel_out", "fx.tunnel_in", "fx.tunnel_found", "fx.manhole", "fx.manhole_first", "npc.gate_captain.open", "npc.gate_captain.defeated",
			"prop.facade_arch", "prop.complaint_box", "prop.compost_shack", "prop.parlor", "prop.permit_office", "prop.paste_dispenser", "fx.ward_window"]:
		_check(story, key, missing)
	for suffix: String in ["deface", "deface_again", "complaint_compensation", "complaint_tea", "complaint_noted", "complaint_inspector", "complaint_limit", "seal", "seal_guarded", "seal_done", "seal_cannot",
			"pickup_recipe", "pickup_compost", "pickup_stamp", "pickup_seed", "pickup_again", "pickup_unknown", "wheel_1", "wheel_2", "wheel_3", "wheel_again", "cable", "cable_again", "paste", "paste_again",
			"plot", "plot_again", "plot_locked", "patch", "patch_again", "patch_locked", "permit_1", "permit_2", "permit_3"]:
		_check(story, "fx." + suffix, missing)
	for n: int in range(1, 5):
		_check(story, "facade.door.%d" % n, missing)
		_check(story, "npc.mabbit.insight.%d" % n, missing)
	for n: int in range(1, 4):
		for index: int in range(3):
			_check(story, "facade.speaker.%d.%d" % [n, index], missing)
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		for suffix: String in ["name", "flavor", "freed"]:
			_check(story, "debuff.%s.%s" % [zone_id, suffix], missing)
	for rule: String in ["darkness", "slow", "no_travel", "no_food_heal"]:
		_check(story, "debuff.rule." + rule, missing)
	assert_eq(missing, [] as Array[String], "missing story keys")


func test_the_capital_story_has_a_freed_variant_for_its_key_signs_and_people() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	var oppressed: String = story.text("sign.facade_smile")
	assert_true(oppressed.contains("MANDATORY"))
	Session.complete_zone(CapitalZone.ID)
	assert_true(story.is_freed(), "the Capital's own freed state")
	assert_ne(story.text("sign.facade_smile"), oppressed)
	assert_true(story.text("sign.facade_smile").contains("ENCOURAGED"))
	ZoneStoryText.set_zone_freed(CapitalZone.ID, false)


func test_the_villains_name_lives_in_one_place() -> void:
	assert_eq(Villain.display_name(), "Primm")
	assert_eq(Villain.title(), "His Perfection")
	assert_eq(Villain.fill("{villain} wants {villain_title}"), "Primm wants His Perfection")
	var all_text: String = ""
	for path: String in ["res://data/story/dna_story.tres", "res://data/story/gainlands_story.tres", "res://data/story/gourmand_story.tres", "res://data/story/refusemancer_story.tres", "res://data/story/intro_story.tres", "res://data/story/capital_story.tres"]:
		all_text += FileAccess.get_file_as_string(path)
	assert_false(all_text.contains("Malvane"), "the old placeholder is gone")
	assert_false(all_text.contains("Usurper"))


func test_new_cards_and_the_junk_token_exist() -> void:
	for id: String in ["compliance_officer", "perfection_inspector", "tidy_bot", "gate_guard", "approved_gate_captain", "rift_wretch", "shard_swarm", "citation", "decree_of_order", "freed_wheel_crew", "odiles_real_recipe", "grandfather_marrow", "rescued_compost_heap", "the_paths_united", CapitalContent.JUNK_ID]:
		assert_not_null(Session.card_by_id(id), id)


# ---- Helpers ---------------------------------------------------------------------------------------------------------------------------


func _check(story: ZoneStoryText, key: String, missing: Array[String]) -> void:
	if story.get_lines(key)[0].begins_with("[missing text"):
		missing.append(key)


func _builder() -> CapitalBuilder:
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = _layout
	builder.ctx = {"free": {}, "dark": true, "final": false}
	for obstacle: Vector3 in _layout.obstacles:
		builder.add_blocker(Vector3(obstacle.x, 0.0, obstacle.y), obstacle.z)
	return builder


func _near_walkable(builder: CapitalBuilder, pos: Vector3, radius: float) -> bool:
	for dx: int in range(-4, 5):
		for dz: int in range(-4, 5):
			var candidate: Vector3 = pos + Vector3(float(dx) * radius * 0.25, 0.0, float(dz) * radius * 0.25)
			if candidate.distance_to(pos) <= radius and builder.is_walkable(candidate, 0.22):
				return true
	return false


## All 1 m cells the player can reach from `start` (4-neighbour flood fill on a 0.5 m lattice).
func _flood(builder: CapitalBuilder, start: Vector3) -> Dictionary:
	var seen: Dictionary = {}
	var begin: Vector2i = Vector2i(int(roundf(start.x * 2.0)), int(roundf(start.z * 2.0)))
	var queue: Array[Vector2i] = [begin]
	if not builder.is_walkable(start):
		# Start on the nearest open cell.
		for radius: int in range(1, 6):
			var found: bool = false
			for dx: int in range(-radius, radius + 1):
				for dz: int in range(-radius, radius + 1):
					var candidate: Vector2i = begin + Vector2i(dx, dz)
					if builder.is_walkable(Vector3(float(candidate.x) * 0.5, 0.0, float(candidate.y) * 0.5)):
						queue = [candidate]
						found = true
						break
				if found:
					break
			if found:
				break
	seen[queue[0]] = true
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next_cell: Vector2i = current + step
			if seen.has(next_cell):
				continue
			if builder.is_walkable(Vector3(float(next_cell.x) * 0.5, 0.0, float(next_cell.y) * 0.5)):
				seen[next_cell] = true
				queue.append(next_cell)
	return seen


func _reaches(reached: Dictionary, pos: Vector3) -> bool:
	var base: Vector2i = Vector2i(int(roundf(pos.x * 2.0)), int(roundf(pos.z * 2.0)))
	for dx: int in range(-4, 5):
		for dz: int in range(-4, 5):
			if reached.has(base + Vector2i(dx, dz)):
				return true
	return false


func _plain_game() -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 99
	var game: GameState = GameState.new(options)
	var deck: Deck = Session.content.deck("Beefcake & Gourmand")
	for seat: int in range(2):
		var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], "P%d" % seat)
		game.add_player(setup)
	game.start()
	return game
