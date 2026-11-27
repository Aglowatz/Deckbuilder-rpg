extends GutTest
## Nov 27 day (Part A): fixes found by the random-play soak bot (`tools/soak_bot.gd`), one test each.


## The bot's first trial pressed Copy on the title's campaign screen in a `--no-save` run and copied campaign 1 over the owner's
## campaign 3: `--no-save` stopped the autosave but not the campaign screen's Copy and Delete. A `--no-save` run is now a protected
## run (SaveGuard redirects every save-system path under user://test_saves/), like a GUT run or WAYWARD_TEST_SAVES=1.
func test_a_no_save_run_is_protected_by_the_save_guard() -> void:
	assert_true(SaveGuard.detects(PackedStringArray(["--no-save"]), ""), "a --no-save run is a protected run")
	assert_true(SaveGuard.detects(PackedStringArray(["--no-save", "--script=x.txt"]), ""), "with other arguments too")
	assert_true(SaveGuard.detects(PackedStringArray([]), "1"), "WAYWARD_TEST_SAVES=1 still protects")
	assert_false(SaveGuard.detects(PackedStringArray(["--seed=3"]), ""), "a normal run is not redirected")
	assert_false(SaveGuard.detects(PackedStringArray([]), "0"), "WAYWARD_TEST_SAVES=0 is a normal run")


## Every tool that drives the real game window with `--no-save` therefore never reaches the player's campaign folders.
func test_the_campaign_folders_are_redirected_in_a_protected_run() -> void:
	assert_true(SaveGuard.test_mode(), "the test run is protected")
	for campaign: int in range(1, CampaignSlots.COUNT + 1):
		var real: String = "user://saves/" if campaign == 1 else "user://saves/campaign_%d/" % campaign
		assert_ne(SaveGuard.safe(real), real, "campaign %d is redirected" % campaign)
		assert_true(SaveGuard.safe(real).begins_with(SaveGuard.TEST_DIR), "under the test folder")


## The soak bot itself refuses to press Copy, Delete, Restore or Start Over, and refuses to run unless the save guard is on.
func test_the_soak_bot_never_presses_save_file_buttons() -> void:
	var source: String = FileAccess.get_file_as_string("res://tools/soak_bot.gd")
	for word: String in ["\"copy\"", "\"delete\"", "\"restore\"", "\"start over\"", "\"overwrite\""]:
		assert_true(source.contains(word), "the deny list holds %s" % word)
	assert_true(source.contains("SaveGuard.test_mode()"), "the bot checks the save guard before it plays")
	assert_true(FileAccess.get_file_as_string("res://tools/soak_bot.sh").contains("WAYWARD_TEST_SAVES=1"), "the wrapper sets the guard")


func _battle_hud() -> BattleHud:
	Session.ensure_game()
	var game: GameState = ArenaScenario.build_game(Session.content, ArenaDefs.find("arena_lethal_lunch"), Session.profile, Session.deck, 11)
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	hud.setup(game, "Lunch Rush", "lorc/imp")
	return hud


## Soak seed 103: the battle's gold button read "Confirm Blocks (1)  [Space]", grew to 334 px from x 1640 and ran 54 px past the screen.
## It now grows to the left: whatever its text, its right edge stays at 1890 and it is never narrower than 250 px.
func test_the_battle_primary_button_grows_to_the_left() -> void:
	var hud: BattleHud = _battle_hud()
	await wait_frames(2)
	for text: String in ["Combat", "No Blocks  [Space]", "Confirm Blocks (1)  [Space]", "Confirm Blocks (12)  [Space]  [Space]"]:
		hud.primary_button.text = text
		hud.fit_primary()
		await wait_frames(1)
		var rect: Rect2 = Rect2(hud.primary_button.position, hud.primary_button.size)
		assert_almost_eq(rect.end.x, BattleHud.PRIMARY_RIGHT, 1.0, "%s: right edge kept" % text)
		assert_true(rect.end.x <= 1920.0, "%s: on the screen" % text)
		assert_true(rect.size.x >= 250.0, "%s: at least the old width" % text)
		assert_true(rect.size.x >= hud.primary_button.get_combined_minimum_size().x - 0.5, "%s: the text fits" % text)
	assert_true(FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd").contains("hud.fit_primary()"), "the battle screen refits it whenever the text changes")


## Soak seed 103: "MIRRORS COPIED COURIER PIGEON" at 92 px ran off both sides of the screen. Long banners shrink to fit the 1200 px box;
## short ones ("VICTORY!") keep the full size.
func test_a_long_battle_banner_shrinks_to_fit() -> void:
	var hud: BattleHud = _battle_hud()
	await wait_frames(2)
	assert_eq(hud.banner_font_size("VICTORY!"), BattleHud.BANNER_FONT, "a short word keeps the full size")
	for text: String in ["MIRRORS COPIED COURIER PIGEON", "MIRRORS COPIED MIDDLE MANAGEMENT ZOMBIE", "MIRRORS COPIED THE GRAND ARCHIVIST OF FORGOTTEN THINGS"]:
		var size_px: int = hud.banner_font_size(text)
		assert_lt(size_px, BattleHud.BANNER_FONT, "%s shrinks" % text)
		var font: Font = hud._banner.get_theme_font("font")
		var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		assert_true(width <= BattleHud.BANNER_WIDTH or size_px == BattleHud.BANNER_FONT_MIN, "%s fits the box (%d px at %d)" % [text, int(width), size_px])
	hud.show_banner("Mirrors copied Middle Management Zombie", Color.WHITE, 0.1)
	await wait_frames(2)
	var rect: Rect2 = hud._banner.get_global_rect()
	assert_true(rect.position.x >= 0.0 and rect.end.x <= 1920.0, "the shown banner stays on the screen (%s)" % str(rect))


## Soak seeds 101-103: the in-world Menu list ended past the right edge (its buttons are 226 px with "Character (C)"; x 1650 + panel
## margins > 1920), so its frame was cut in every zone, dungeon and Crosspath. It moves left to keep a 12 px gap.
func test_the_world_menu_list_stays_on_the_screen() -> void:
	var hud: TownHud = TownHud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	hud.toggle_menu()
	await wait_frames(3)
	var panel: Control = hud._menu_panel
	var width: float = hud.get_viewport().get_visible_rect().size.x
	assert_true(panel.visible, "the menu opened")
	assert_true(panel.position.x + panel.size.x * panel.scale.x <= width - TownHud.MENU_MARGIN + 0.5, "right edge %.0f inside %.0f" % [panel.position.x + panel.size.x, width])
	for button: Node in panel.find_children("Menu_*", "Control", true, false):
		assert_true((button as Control).get_global_rect().end.x <= width, "%s on the screen" % button.name)
	assert_true(panel.position.x <= TownHud.MENU_X, "it only ever moves left")


## Part B (the Extra Pocket measured): the sim's item policy follows the game's rule - with the Pocket the second use of an item in a duel
## is free, even when its only copy was spent by the first; without it the second use never happens. Sim only.
func test_the_sim_makes_the_pockets_free_second_use() -> void:
	var content: ContentSet = Session.content
	for pocket: bool in [false, true]:
		var game: GameState = GameFactory.blank_game(5)
		GameFactory.add_infrastructure_cards(game, 0, 3)
		game.players[0].item_uses_per_battle = 2 if pocket else 1
		var items: Dictionary = {"healing_salve": 1}
		game.players[0].hp = 3
		assert_true(SimItemPolicy.act(game, 0, items, content, {}), "the first heal (pocket %s)" % str(pocket))
		assert_eq(int(items["healing_salve"]), 0, "the first use spends the copy")
		game.players[0].hp = 3
		var second: bool = SimItemPolicy.act(game, 0, items, content, {})
		assert_eq(second, pocket, "a second heal with the last copy gone only with the Pocket")
		assert_eq(int(items["healing_salve"]), 0, "the second use is free (the bag never goes below 0)")
		assert_eq(game.players[0].hp, 7 if pocket else 3)
		assert_false(SimItemPolicy.act(game, 0, items, content, {}), "never a third use")


## Soak seed 1: a save written and loaded back lost a card (deck 48 -> 47, collection 29 -> 28). The fast-forwarded game (`ensure_game`,
## used by the tools, the bots and most tests) added the trial's sample picks past the copy cap - the starter already held three of
## Beefcake's B-05 and of three Refusemancer cards - and the first load trimmed the fourth into essence. Every Path's fast-forwarded game
## now writes, loads and writes again the same deck, collection and essence.
func test_a_fast_forwarded_game_loads_back_the_same() -> void:
	var saving: bool = Session.save_enabled
	Session.save_enabled = false
	for path: Affinity.Type in Affinity.colored_types():
		Session.profile = null
		Session.ensure_game(path)
		var before: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
		assert_true(Session.from_dict(before.duplicate(true)), "%s loads" % Affinity.display_name(path))
		var after: Dictionary = JSON.parse_string(JSON.stringify(Session.to_dict())) as Dictionary
		for key: String in ["deck", "owned", "decks", "gold"]:
			assert_eq(JSON.stringify(after[key]), JSON.stringify(before[key]), "%s: %s comes back the same" % [Affinity.display_name(path), key])
		assert_true(CopyCaps.excess(Session.profile.owned_cards, Session.profile.level).is_empty(), "nothing over a copy cap")
		assert_gte(Session.deck.size(), DeckValidator.MIN_DECK_SIZE, "still a legal deck")
	Session.save_enabled = saving


## Soak seed 2: "Lambda capture at index 0 was freed" as a fight began. An area's title banner waits (a timer, every 0.25 s) while a
## conversation is open; when the scene was freed in between, the timer's lambda called back with the freed scene. It now holds a weak
## reference: the freed scene arrives as null and the banner is thrown away quietly.
func test_a_waiting_title_banner_survives_its_scene_being_freed() -> void:
	var talk: DialogueBox = DialogueBox.new()
	add_child_autofree(talk)
	talk.active = true
	talk.visible = true
	await wait_frames(2)
	assert_true(QuestNoticeLayer.dialogue_open(get_tree()), "a conversation holds the banner")
	var scene: Node = Node.new()
	add_child(scene)
	var card: ZoneTitleCard = ZoneTitleCard.new()
	ZoneTitleCard._add_when_quiet(scene, card)
	assert_null(card.get_parent(), "the banner waits")
	scene.free()
	await wait_seconds(0.6)
	assert_false(is_instance_valid(card), "the banner is thrown away once its scene is gone")
	assert_true(FileAccess.get_file_as_string("res://ui/screens/zone_title_card.gd").contains("weakref(scene)"), "the wait holds a weak reference")
