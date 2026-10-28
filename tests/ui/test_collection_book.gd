extends GutTest
## Overnight Oct 17, Part 10: the Collection Book (cards by Path and rarity, silhouettes, completion, x/cap, filters, sort, inspect)
## and the Bestiary (every enemy and boss, unknown until met, met/defeated counts, discovery milestones).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_dungeon_foe_and_boss_has_an_entry() -> void:
	var parsed: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary
	for dungeon_id: Variant in (parsed["dungeons"] as Dictionary).keys():
		var foes: Dictionary = ((parsed["dungeons"] as Dictionary)[dungeon_id] as Dictionary).get("foes", {}) as Dictionary
		for foe: Variant in foes.values():
			var name: String = str((foe as Dictionary)["name"]) if foe is Dictionary else str(foe)
			assert_not_null(Bestiary.find(name), "%s (%s) is in the Bestiary" % [name, dungeon_id])
	for name: String in ["Cave Scavenger", "Hollow Stalker", "Hollow Warden", NinjaBoss.DISPLAY_NAME, GraveyardBoss.DISPLAY_NAME, VaultGuardian.DISPLAY_NAME]:
		assert_not_null(Bestiary.find(name), name)
	assert_not_null(Bestiary.find("Primm - Standardization"), "Primm's phases are one entry")


func test_every_zone_roamer_has_an_entry() -> void:
	for id: String in GainlandsEnemies.IDS:
		assert_not_null(Bestiary.find(GainlandsEnemies.info(id).display_name))
	for id: String in DnaEnemies.IDS:
		assert_not_null(Bestiary.find(DnaEnemies.info(id).display_name))
	for id: String in BuffetEnemies.IDS:
		assert_not_null(Bestiary.find(BuffetEnemies.info(id).display_name))
	for id: String in HeapEnemies.IDS:
		assert_not_null(Bestiary.find(HeapEnemies.info(id).display_name))
	for id: String in CapitalEnemies.IDS:
		assert_not_null(Bestiary.find(CapitalEnemies.info(id).display_name))


func test_entries_have_a_fun_line_a_place_and_a_real_icon() -> void:
	for entry: Bestiary.Entry in Bestiary.all():
		assert_false(entry.blurb.is_empty(), entry.name)
		assert_false(entry.where.is_empty(), entry.name)
		assert_true(ResourceLoader.exists(CardIcons.BASE + entry.icon + ".svg"), "%s icon %s" % [entry.name, entry.icon])


func test_meeting_and_beating_are_counted() -> void:
	assert_false(Bestiary.is_known(Session.counters, "Quota Spotter"))
	Session.bestiary_meet("Quota Spotter")
	assert_true(Bestiary.is_known(Session.counters, "Quota Spotter"))
	Session.bestiary_defeat("Quota Spotter")
	Session.bestiary_defeat("Quota Spotter")
	assert_eq(Bestiary.won_count(Session.counters, "Quota Spotter"), 2)
	Session.bestiary_meet("Nobody In Particular")
	assert_false(Session.counters.has(Bestiary.MET_PREFIX + "Nobody In Particular"), "unknown names are ignored")


func test_discovery_milestones_pay_once() -> void:
	var gold: int = Session.gold
	var quarter: int = int(ceil(Bestiary.all().size() * 0.25))
	for index: int in range(quarter):
		Session.bestiary_meet(Bestiary.all()[index].name)
	assert_true(Session.flag(&"bestiary_25"))
	assert_eq(Session.gold, gold + 100)
	Session.pay_completion_milestones()
	assert_eq(Session.gold, gold + 100, "paid once")


func test_the_book_shows_both_tabs_silhouettes_and_x_of_cap() -> void:
	var screen: CodexScreen = CodexScreen.new()
	add_child_autofree(screen)
	await wait_process_frames(2)
	for _wait: int in range(120):
		if not screen.is_building():
			break
		await wait_process_frames(1)
	assert_false(screen.is_building(), "the grid finishes building over a few frames")
	assert_not_null(screen.find_child("TabCards", true, false))
	assert_not_null(screen.find_child("TabBestiary", true, false))
	assert_not_null(screen.find_child("Path_beefcake", true, false))
	var owned_id: String = Session.profile.owned_cards[0].id
	var tile: Button = screen.find_child("Card_%s" % owned_id, true, false) as Button
	assert_not_null(tile, "an owned card has a tile")
	var texts: PackedStringArray = []
	for label: Node in tile.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	assert_true(" ".join(texts).contains("Own %d/" % Session.owned_count(owned_id)), " ".join(texts))
	var progress: Vector2i = screen.card_progress("all")
	assert_gt(progress.y, progress.x, "most cards are still silhouettes")
	screen.inspect(Session.profile.owned_cards[0])
	assert_not_null(screen.find_child("CardZoom", true, false))
	screen.request_close()
	await wait_process_frames(1)
	assert_null(screen.find_child("CardZoom", true, false), "Esc closes the zoom first")
	screen.show_tab("Bestiary")
	assert_not_null(screen.find_child("Beast_Quota Spotter", true, false))
