extends GutTest
## Overnight Oct 31 - Nov 1, Part 4: the mid-game critic's fix-now items (docs/review/fresh_eyes_midgame_oct31n_triage.md).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_click_on_the_cutscene_text_panel_reaches_the_screen() -> void:
	var scene: CutsceneScreen = CutsceneScreen.make("reveal")
	add_child_autofree(scene)
	await wait_frames(2)
	var panels: Array[Node] = scene.find_children("*", "PanelContainer", false, false)
	assert_gt(panels.size(), 0)
	for panel: Node in panels:
		assert_eq((panel as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, "the text panel lets clicks through (critic #3)")
	var before: int = scene._index
	scene._text.visible_ratio = 1.0
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	scene._gui_input(click)
	assert_eq(scene._index, before + 1, "a click advances the scene")


func test_energy_codes_read_as_words_in_plain_tooltips() -> void:
	assert_eq(KeywordInfo.plain_rules("Exhaust: add (B)."), "Exhaust: add one Beefcake energy.")
	assert_eq(KeywordInfo.plain_rules("Pay (N)(N): draw."), "Pay two Necrocrat energy: draw.")
	assert_false(KeywordInfo.plain_rules("Exhaust: add (G), (R).").contains("("), "no raw code left")


func test_the_rotheart_rule_no_longer_shares_the_dump_effects_name() -> void:
	var names: Array[String] = []
	for rule: Dictionary in DungeonRules._entries("D-ROT"):
		names.append(str(rule["name"]))
	assert_true(names.has("Wild Growth"))
	assert_false(names.has("Overgrowth"), "the Dump's +2 defence zone effect keeps that name")


func _unit_test_challenge() -> ChallengeData:
	var challenge: ChallengeData = ChallengeData.new()
	challenge.id = "test_panel"
	challenge.kind = ChallengeData.Kind.TOP_N_TYPE_COUNT
	challenge.card_type = CardEnums.CardType.UNIT
	challenge.reveal_count = 5
	challenge.threshold = 2
	return challenge


func test_a_deck_test_states_its_rule_and_odds_before_the_reveal() -> void:
	var challenge: ChallengeData = _unit_test_challenge()
	assert_eq(ChallengeResolver.rule_text(challenge), "The test: draw 5 cards from your deck - 2+ must be Unit cards.")
	var units: Array[CardData] = []
	var infra: Array[CardData] = []
	for i: int in range(20):
		units.append(GameFactory.vanilla(2, 2))
		infra.append(GameFactory.infra())
	assert_eq(ChallengeResolver.odds(challenge, units), 1.0)
	assert_eq(ChallengeResolver.odds(challenge, infra), 0.0)
	var half: Array[CardData] = units.slice(0, 10) + infra.slice(0, 10)
	var chance: float = ChallengeResolver.odds(challenge, half)
	assert_between(chance, 0.75, 0.95, "10 units in 20: about 87 %")
	assert_true(ChallengeResolver.passes(challenge, units.slice(0, 5)))
	assert_false(ChallengeResolver.passes(challenge, infra.slice(0, 5)))


func test_only_the_well_speaks_of_the_well() -> void:
	var screen: ChallengeScreen = ChallengeScreen.new()
	screen.challenge = _unit_test_challenge()
	assert_eq(screen.headline_text(true), "Passed!")
	assert_eq(screen.headline_text(false), "Not this time.")
	screen.challenge.id = TrialOfTheHollow.CHALLENGE_ID
	assert_eq(screen.headline_text(false), "The well stays silent.")
	screen.free()


func test_escape_closes_a_deck_station_popup_before_the_station() -> void:
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_frames(2)
	var closed: Array[bool] = [false]
	screen.closed.connect(func() -> void: closed[0] = true)
	var built: Array[Control] = screen._layer("TestLayer", "A popup", "")
	assert_eq(screen.topmost_layer(), built[0])
	screen.request_close()
	assert_true(built[0].is_queued_for_deletion(), "Esc closed the popup")
	assert_false(closed[0], "the station stays open")


func test_where_to_names_places_not_yet_walked_to() -> void:
	var points: Array[MapPoi] = [MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3.ZERO, "The Hall of Records")] as Array[MapPoi]
	for i: int in range(30):
		points.append(MapPoi.make(MapPoi.Kind.VENDOR, Vector3(i, 0, 0), "Shop %d" % i))
	var places: Array[MapPoi] = FullMapScreen.where_to_places(points)
	assert_eq(places.size(), FullMapScreen.WHERE_TO_MAX, "capped")
	var source: String = FileAccess.get_file_as_string("res://ui/minimap/full_map_screen.gd")
	assert_true(source.contains("where_to_entries(_pois)"), "the list is built from every point, not only the revealed ones")
	var few: Array[MapPoi] = FullMapScreen.where_to_places([MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3.ZERO, "The Hall of Records")] as Array[MapPoi])
	assert_eq(few[0].label, "The Hall of Records", "the Hall of Records and the Deck Station are listed")


func test_toasts_wait_while_a_reward_pick_holds_them() -> void:
	var layer: ToastLayer = ToastLayer.new()
	add_child_autofree(layer)
	await wait_frames(1)
	layer.hold()
	layer.show_toast("Feat: Test", UIStyle.GOLD, null)
	assert_false(layer._column.visible, "held toasts are hidden")
	assert_eq(layer._column.get_child_count(), 1, "but kept")
	layer.release()
	assert_true(layer._column.visible)
	assert_false(layer.is_held())


func test_a_freed_zone_says_so_once_per_visit() -> void:
	Session.begin_zone_visit(DnaZone.ID)
	assert_eq(Session.freed_zone_notice(), "", "not freed yet")
	Session.flags[str(ZoneCompletion.flag_name(DnaZone.ID))] = true
	Session.begin_zone_visit(DnaZone.ID)
	assert_string_contains(Session.freed_zone_notice(), "is free")
	assert_eq(Session.freed_zone_notice(), "", "once per visit")


func test_open_all_opens_every_plain_pack_with_one_summary() -> void:
	Session.add_pack("general_2", 3)
	var plain_before: int = PacksScreen.plain_pack_count()
	assert_gte(plain_before, 3)
	var owned_before: int = Session.profile.owned_cards.size()
	var openings: Array[PackOpening] = PacksScreen.open_all()
	assert_eq(openings.size(), plain_before, "every plain pack opened")
	assert_eq(PacksScreen.plain_pack_count(), 0)
	assert_gt(Session.profile.owned_cards.size(), owned_before, "the cards joined the collection")
	var lines: PackedStringArray = PacksScreen.summary_lines(openings)
	assert_string_contains(lines[0], "Opened %d packs" % plain_before)
	var screen: PacksScreen = PacksScreen.new()
	add_child_autofree(screen)
	await wait_frames(2)
	assert_null(screen.find_child("OpenAll", true, false), "no button with nothing left to open")


func test_vendors_answer_from_their_bark_range_and_prompts_name_them() -> void:
	assert_gte(TownScene.VENDOR_REACH * StorybookScale.INTERACT_FACTOR, NpcBarks.RANGE, "E reaches as far as the bark carries")
	assert_string_contains(TownScene.talk_prompt("vendor"), "Talk to ")
	assert_ne(TownScene.talk_prompt("vendor"), "Talk to ", "a name follows")
	assert_eq(TownScene.talk_prompt("no_such_spot"), "Talk")


func test_quit_game_asks_and_saves_first() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/screens/pause_menu.gd")
	assert_true(source.contains("quit.pressed.connect(_ask_quit)"))
	assert_true(source.contains("Session.save_game()\n\t\tSceneManager.quit_game()"))


func test_clicking_another_hand_card_leaves_target_choice() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd").replace("\r\n", "\n")  # Fixes Nov 8: a CRLF working copy (git autocrlf) must not fail it
	var at: int = source.find("		Mode.TARGETING:\n			if button_event.pressed and _target_options.has(uid):")
	assert_gt(at, 0)
	assert_true(source.substr(at, 700).contains("_cancel_targeting()"), "a click on a hand card cancels the target choice")
