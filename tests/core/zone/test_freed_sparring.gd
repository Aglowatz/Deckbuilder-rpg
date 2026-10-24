extends GutTest
## Overnight Oct 23, Part 2: once a zone is freed, its roamers spar with a two-Path deck (ZoneEnemies.freed_recipe); elites keep theirs.


func test_each_freed_zone_roamer_plays_two_paths_with_its_own_deck_size() -> void:
	var content: ContentSet = Session.content
	for zone_id: String in ZoneEnemies.FREED_DECKS.keys():
		for enemy_id: String in EncounterCatalog.ZONE_ROAMERS.get(zone_id, []) as Array:
			var recipe: Dictionary = ZoneEnemies.freed_recipe(zone_id, enemy_id)
			if EncounterCatalog.ZONE_ELITES.has(enemy_id):
				assert_true(recipe.is_empty(), "%s keeps its own deck" % enemy_id)
				continue
			assert_false(recipe.is_empty(), "%s:%s spars" % [zone_id, enemy_id])
			var deck: Deck = ZoneDecks.from_recipe(content, "spar", recipe)
			assert_eq(RewardPicks.deck_paths(deck).size(), 2, "%s:%s plays two Paths" % [zone_id, enemy_id])
			var own: int = 0
			for count: Variant in ZoneEnemies.info(zone_id, enemy_id).recipe.values():
				own += int(count)
			assert_almost_eq(deck.size(), own, 2, "about the roamer's own deck size")


func test_the_freed_seat_gets_more_hp_and_the_unfreed_one_is_unchanged() -> void:
	var content: ContentSet = Session.content
	var normal: PlayerSetup = ZoneEnemies.enemy_setup(content, "beefcake", "brute")
	var freed: PlayerSetup = ZoneEnemies.enemy_setup(content, "beefcake", "brute", true)
	assert_eq(freed.starting_hp, normal.starting_hp + ZoneEnemies.FREED_HP_BONUS)
	assert_ne(RewardPicks.deck_paths(freed.deck).size(), RewardPicks.deck_paths(normal.deck).size())
	assert_true(ZoneEnemies.freed_recipe(CapitalZone.ID, "officer").is_empty(), "the Capital has no freed variant")
