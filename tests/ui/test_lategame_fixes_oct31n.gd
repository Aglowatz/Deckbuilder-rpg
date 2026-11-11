extends GutTest
## Overnight Oct 31 - Nov 1, Part 6: the late-game critic's fix-now items (docs/review/fresh_eyes_lategame_oct31n_triage.md).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_cutscene_keeps_running_and_blocks_the_pause_menu_while_up() -> void:
	SceneManager.pause_allowed = true
	var first: CutsceneScreen = CutsceneScreen.make("primm_intro")
	add_child(first)
	await wait_frames(1)
	assert_eq(first.process_mode, Node.PROCESS_MODE_ALWAYS, "a stray pause cannot freeze the scene")
	assert_false(SceneManager.pause_allowed, "Esc belongs to the scene, not the pause menu")
	var second: CutsceneScreen = CutsceneScreen.make("primm_intro")
	add_child(second)
	await wait_frames(1)
	first.queue_free()
	await wait_frames(2)
	assert_false(SceneManager.pause_allowed, "still blocked while the next scene is up")
	second.queue_free()
	await wait_frames(2)
	assert_true(SceneManager.pause_allowed, "the map's pause comes back after the last scene")


func test_the_capital_battle_panel_reads_the_real_services() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	assert_true(source.contains("hud.set_capital_panels(Session.flags, context.rules_text)"), "not {} (that read as every service broken)")
	var all_freed: Dictionary = {}
	for zone_id: String in [GainlandsZone.ID, DnaZone.ID, BuffetZone.ID, HeapZone.ID]:
		all_freed[str(ZoneCompletion.flag_name(zone_id))] = true
	assert_eq(CapitalDebuffs.active(all_freed).size(), 0, "four freed zones: nothing broken")


func test_the_defeat_line_only_mentions_a_dungeon_inside_one() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	assert_true(source.contains("The dungeon starts over from its first room.\" if Session.run != null else"), "Fix pass Nov 7 (D1, D2) / Fable pass Nov 10 (Part 4.1): the dungeon line only inside one")


func test_gear_that_lowers_max_hp_is_not_a_zone_rule() -> void:
	var glass: EquipmentData = EquipmentData.new()
	glass.id = "test_glass_jaw"
	glass.slot = EquipmentData.Slot.WEAPON
	glass.rarity = EquipmentData.Rarity.COMMON
	var penalty: Modifier = CardBuilder.modifier(Modifier.Kind.MAX_HP, -3)
	penalty.label = "Glass Jaw"
	glass.modifiers = [penalty] as Array[Modifier]
	Session.profile.level = 20
	Session.profile.max_hp = 21
	for slot: Variant in EquipmentData.Slot.values():
		Session.profile.unlock_equipment_slot(slot as EquipmentData.Slot)
	Session.profile.owned_equipment.append(glass)
	assert_true(Session.profile.equip(glass))
	assert_eq(Session.usual_max_hp(), Session.profile.base_max_hp() - 3, "the piece costs max HP everywhere")
	Session.begin_zone_visit(GainlandsZone.ID)
	assert_eq(Session.zone_run.max_hp(), Session.usual_max_hp(), "the Gainlands has no max-HP rule of its own")
	assert_eq(Session.hp_pool_notice(), "", "so no 'Max HP here' banner for gear")


func test_an_npc_answers_from_beside_them_not_only_from_in_front() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	assert_true(source.contains("var body: Vector3 = npc_body_position(spot)"), "the NPC's body counts for reach (Old Man Mountain, Spotless)")


func test_first_hour_fixes() -> void:
	assert_true(TownScene.poi_label("vendor", "Card Vendor").ends_with(" - Card Vendor"), "the map names Sable, as the quest does")
	assert_ne(TownScene.poi_label("vendor", "Card Vendor"), "Card Vendor")
	assert_eq(TownScene.poi_label("deck", "Deck Station"), "Deck Station", "places without a person keep their title")
	var rewards: String = FileAccess.get_file_as_string("res://ui/dungeon/rewards_screen.gd")
	assert_true(rewards.contains("not is_instance_valid(_take_button) or key == null"), "no input on a freed Take button (20 SCRIPT ERRORs on E)")
	assert_true(rewards.contains("ConfirmKey.attach(self, home)"), "E steps outside after the cave")
	SceneManager.pause_allowed = true
	var choice: ElementChoiceScreen = ElementChoiceScreen.new()
	add_child(choice)
	await wait_frames(1)
	assert_false(SceneManager.pause_allowed, "no pause menu over the Path choice")
	choice.queue_free()
	await wait_frames(2)
	assert_true(SceneManager.pause_allowed)


func test_the_closing_e_does_not_reopen_a_conversation() -> void:
	var box: DialogueBox = DialogueBox.new()
	add_child_autofree(box)
	await wait_frames(1)
	box.start("Bertram", ["One line."] as Array[String])
	await wait_frames(1)
	box.close_now()
	assert_gt(box.closed_msec, 0, "the box stamps its closing time")
	var source: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	assert_true(source.contains("dialogue_closed_msec() < REOPEN_GUARD_MS"), "the town ignores the E that closed it")
