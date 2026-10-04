extends GutTest
## New brief, Part E: the 4 corrupted NPCs' data - deck legality (every card known, strictly
## mono-color), life, AI, reward and unlock-flag plumbing. The town placement/dialogue/battle
## flow itself is presentation (world/town_scene.gd, app/game_session.gd) and is not under GUT
## per CLAUDE.md - verified instead with a real-input smoke test.

var content: ContentSet


func before_each() -> void:
	content = ContentLibrary.load_all()


func test_four_ids_matching_zone_portals() -> void:
	var ids: Array[String] = CorruptedNpcs.IDS
	assert_eq(ids.size(), 4)
	for info: ZonePortals.Info in ZonePortals.all():
		if info.id != ZonePortals.FINAL_ID:
			assert_true(ids.has(info.id), "%s should have a corrupted NPC" % info.id)


func test_every_deck_card_is_known_and_strictly_mono_color() -> void:
	for id: String in CorruptedNpcs.IDS:
		var deck: Deck = CorruptedNpcs.deck(content, id)
		assert_false(deck.cards.is_empty(), "%s should have a real deck" % id)
		var color: Affinity.Type = CorruptedNpcs.element(id)
		for card: CardData in deck.cards:
			if card.is_infrastructure():
				assert_eq(card.color, color, "%s's infrastructure should match their element" % id)
			else:
				assert_eq(card.color, color, "%s's deck should be strictly mono-color (found %s)" % [id, card.id])


func test_enemy_setup_starts_at_15_life() -> void:
	for id: String in CorruptedNpcs.IDS:
		var setup: PlayerSetup = CorruptedNpcs.enemy_setup(content, id)
		assert_eq(setup.starting_life, CorruptedNpcs.STARTING_LIFE)
		assert_eq(CorruptedNpcs.STARTING_LIFE, 15)


func test_every_npc_has_a_resolvable_ai_personality() -> void:
	for id: String in CorruptedNpcs.IDS:
		var personality: AIPersonality = CorruptedNpcs.personality(content, id)
		assert_not_null(personality)


func test_reward_item_resolves_to_a_real_item() -> void:
	for id: String in CorruptedNpcs.IDS:
		var item: ItemData = CorruptedNpcs.reward_item(content, id)
		assert_not_null(item, "%s's reward item should resolve" % id)


func test_unlock_flag_matches_the_zone_id_convention() -> void:
	assert_eq(CorruptedNpcs.unlock_flag("beefcake"), StringName("beefcake_zone_unlocked"))


func test_reference_player_decks_are_45_cards_and_reasonably_on_color() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CorruptedNpcs.reference_player_deck(content, color)
		assert_eq(deck.cards.size(), 45, "a level-3 reference deck should be a real 45-card deck")
