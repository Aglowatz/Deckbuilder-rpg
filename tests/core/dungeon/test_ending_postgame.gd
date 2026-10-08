extends GutTest
## Brief 10, Part E: the ending sequence (text, the screen), the postgame unlock (3+ Path decks are legal, the Alchemist's tri-Path hook),
## the Paths freed by Primm's fall, and the changed Capital.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	ZoneStoryText.set_zone_freed(CapitalZone.ID, false)
	for zone_id: String in ZoneDefs.ids():
		ZoneStoryText.set_zone_freed(zone_id, false)


# ---- Text and the screen ---------------------------------------------------------------------------------------


func test_every_ending_text_key_exists() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	var missing: Array[String] = []
	for beat: Dictionary in EndingDefs.BEATS:
		for key: String in [EndingDefs.beat_key(int(beat["n"])), EndingDefs.beat_title_key(int(beat["n"]))]:
			if story.get_lines(key)[0].begins_with("[missing"):
				missing.append(key)
	for index: int in range(1, EndingDefs.CREDITS_LINES + 1):
		if story.get_lines("ending.credits.%d" % index)[0].begins_with("[missing"):
			missing.append("ending.credits.%d" % index)
	for index: int in range(1, EndingDefs.POSTGAME_LINES + 1):
		if story.get_lines("ending.postgame.line.%d" % index)[0].begins_with("[missing"):
			missing.append("ending.postgame.line.%d" % index)
	for key: String in ["ending.postgame.title", "ending.postgame.body", "ending.return", "fx.ending_return", "freed_npc.heartlift", "freed_npc.grandchef", "freed_npc.agnes", "freed_npc.compostella"]:
		if story.get_lines(key)[0].begins_with("[missing"):
			missing.append(key)
	assert_eq(missing, [] as Array[String], "missing ending text")


func test_the_ending_carries_the_theme() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	var all: String = ""
	for beat: Dictionary in EndingDefs.BEATS:
		all += story.text(EndingDefs.beat_key(int(beat["n"]))) + "\n"
	assert_true(all.contains("facade") or all.contains("Facade"), "the facade crumbles")
	assert_true(all.contains("rifts"), "the rifts close")
	assert_true(all.contains("Paths come home") or all.contains("Paths meet"), "the four factions reunite")
	assert_true(all.contains("one way for everyone"), "Primm demanded one way for everyone")
	assert_true(all.contains("Different Paths, working together"), "different Paths working together is what made the kingdom strong")


func test_the_ending_screen_plays_through_credits_and_the_postgame_announcement() -> void:
	var screen: EndingScreen = EndingScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	for step: int in range(EndingDefs.BEATS.size()):
		screen.advance()
		screen.advance()
	assert_true(screen._credits_running, "the credits start after the last beat")
	screen._show_postgame()
	var announcement: Node = screen.get_node_or_null("PostgameAnnouncement")
	assert_not_null(announcement, "the postgame announcement")
	assert_eq((announcement as AnnouncementScreen).title, "The Paths Unbound")
	assert_eq((announcement as AnnouncementScreen).extra_lines.size(), EndingDefs.POSTGAME_LINES)


func test_the_ending_scene_loads() -> void:
	var packed: PackedScene = load("res://scenes/ending.tscn") as PackedScene
	assert_not_null(packed)
	assert_eq(Session.ENDING_SCENE, "res://scenes/ending.tscn")


# ---- The postgame unlock ------------------------------------------------------------------------------------------


func test_a_three_path_deck_is_illegal_before_and_legal_after_the_postgame_unlock() -> void:
	var deck: Deck = _three_path_deck()
	assert_eq(deck.colors().size(), 3)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, Session.profile), DeckValidator.Problem.TOO_MANY_COLORS), "2 Paths until Primm falls")
	assert_true(Session.unlock_postgame(), "the first unlock")
	assert_true(Session.profile.postgame_unlocked)
	assert_false(DeckValidator.has_problem(DeckValidator.validate(deck, Session.profile), DeckValidator.Problem.TOO_MANY_COLORS), "3 Paths after")
	assert_eq(DeckValidator.max_colors(Session.profile), 4, "and 4 Paths, all of them")
	var four: Deck = _three_path_deck()
	for index: int in range(10):
		four.cards.append(Session.content.infrastructure[int(Affinity.Type.NECROCRAT)] as CardData)
	assert_eq(four.colors().size(), 4)
	assert_false(DeckValidator.has_problem(DeckValidator.validate(four, Session.profile), DeckValidator.Problem.TOO_MANY_COLORS))


func test_the_deck_editor_allows_a_third_path_after_the_unlock() -> void:
	var infrastructure: Array[CardData] = []
	for infra: Variant in Session.content.infrastructure.values():
		infrastructure.append(infra as CardData)
	var waiver: ModifierSet = ModifierSet.new()
	waiver.add_source(TrialOfTheHollow.deck_size_waiver())
	var editor: DeckEditor = DeckEditor.from(Session.profile, CampaignStart.starter_deck(Session.content, Affinity.Type.BEEFCAKE), infrastructure, waiver)
	Session.profile.owned_cards.append(Session.content.card("G-01"))
	Session.profile.owned_cards.append(Session.content.card("R-02"))
	assert_true(editor.add(Session.content.card("G-01")), "a second Path is fine")
	assert_ne(editor.why_not_add(Session.content.card("R-02")), "", "a third Path is refused before Primm falls")
	Session.unlock_postgame()
	assert_eq(editor.why_not_add(Session.content.card("R-02")), "", "legal after the postgame unlock")
	assert_true(editor.add(Session.content.card("R-02")))
	assert_eq(editor.deck.colors().size(), 3, "a 3-Path deck")


func test_the_alchemists_tri_path_hook_opens() -> void:
	assert_false(Alchemy.tri_path_unlocked(Session.profile))
	assert_eq(Alchemy.max_craft_paths(Session.profile), 2)
	Session.unlock_postgame()
	assert_true(Alchemy.tri_path_unlocked(Session.profile))
	assert_eq(Alchemy.max_craft_paths(Session.profile), 3)
	assert_gt(Alchemy.tri_path_cards(Session.content, [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER] as Array[Affinity.Type]).size(), 0, "the Beefcake/Gourmand/Refusemancer tri-Path cards exist")


func test_the_postgame_unlock_is_saved() -> void:
	Session.unlock_postgame()
	var data: Dictionary = Session.to_dict()
	assert_true(bool(data["postgame"]))
	assert_true(bool((data["flags"] as Dictionary).get("primm_defeated", false)))


func test_primms_fall_frees_the_four_paths_so_the_factions_reunite() -> void:
	assert_eq(Session.completed_zone_count(), 0)
	Session.unlock_postgame()
	assert_eq(Session.completed_zone_count(), 4, "his fall frees every Path")
	assert_true(Session.arena_unlocked() and Session.alchemist_unlocked(), "and everything they open")
	assert_eq(CapitalDebuffs.active(Session.flags).size(), 0, "no service is broken any more")
	assert_false(Session.unlock_postgame(), "only the first time reports an unlock")


# ---- The changed Capital ----------------------------------------------------------------------------------------------------


func test_the_capital_is_changed_after_the_ending() -> void:
	Session.unlock_postgame()
	Session.complete_zone(CapitalZone.ID)
	assert_true(Session.flag(CapitalZone.FLAG_FREED))
	assert_eq(CapitalRifts.open_count(Session.flags), 0, "every rift is closed")
	var state: Dictionary = CapitalBuilder.story_context()
	assert_true(bool(state["final"]))
	assert_false(bool(state["dark"]))
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	assert_true(story.text("sign.facade_smile").contains("ENCOURAGED"), "new signs")
	assert_true(story.text("npc.wren.return").contains("mending"), "new dialogue")
	assert_ne(story.text("facade.citizen.2.approved"), "", "citizens have lines of their own")
	assert_true(story.text("facade.citizen.2.approved").contains("bakery"), "and they are free")
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	assert_eq(def.freed_npcs.size(), 4, "the freed leaders stand in the Crease")


func test_a_free_capital_builds_and_the_facade_is_down() -> void:
	Session.unlock_postgame()
	Session.complete_zone(CapitalZone.ID)
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.build(parent)
	assert_true(builder.gate_open, "no checkpoint")
	assert_eq(builder.rift_nodes.size(), 0, "no rifts")
	var houses: int = 0
	for child: Node in parent.get_node("Capital").get_children():
		if child.name == "HouseBodies":
			houses += 1
	assert_eq(houses, 0, "the identical houses are gone: the facade has crumbled")


# ---- Helpers ----------------------------------------------------------------------------------------------------------------------------


func _three_path_deck() -> Deck:
	var deck: Deck = Deck.new()
	for color: Affinity.Type in [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]:
		for index: int in range(16):
			deck.cards.append(Session.content.infrastructure[int(color)] as CardData)
	return deck
