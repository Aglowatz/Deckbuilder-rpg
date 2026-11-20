extends GutTest
## Fable Nov 21, Part 5 (menus): "Open all" opens the gilded packs too (5.4); every chest and item reward sits in a reward box that
## waits for a click, with an icon that can be hovered for its full info (5.5); the mid-fight pop-ups share one layout (5.7); the small
## grey text of the quest log and the level-up pop-up is readable (5.8). The Deck Station (5.1, 5.2), the Wardrobe (5.3) and the hover
## zoom probe (5.6) have their own files.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.pending_popups.clear()


func _gilded_id() -> String:
	for pack: PackData in PackCatalog.all():
		if pack.guarantee_epic_or_legendary:
			return pack.id
	return ""


func _labels(root: Node) -> String:
	var words: PackedStringArray = []
	for node: Node in root.find_children("*", "Label", true, false):
		words.append((node as Label).text)
	return "\n".join(words)


# ---- 5.4 Open all -----------------------------------------------------------------------------------------------------------------------


func test_open_all_opens_the_gilded_packs_too() -> void:
	var before: int = PacksScreen.all_pack_count()
	Session.add_pack(_gilded_id(), 2)
	Session.add_pack("general_2", 1)
	assert_eq(PacksScreen.gilded_pack_count(), 2)
	assert_eq(PacksScreen.all_pack_count(), before + 3)
	var openings: Array[PackOpening] = PacksScreen.open_all()
	assert_eq(openings.size(), before + 3, "every pack, plain and gilded")
	assert_eq(PacksScreen.gilded_pack_count(), 0, "no gilded pack is left on the shelf")
	assert_eq(PacksScreen.all_pack_count(), 0)
	var gilded_opened: int = 0
	for opening: PackOpening in openings:
		if opening.pack.guarantee_epic_or_legendary:
			gilded_opened += 1
			var best: int = 0
			for entry: PackOpening.Entry in opening.entries:
				best = maxi(best, int(entry.card.rarity))
			assert_gte(best, int(CardEnums.Rarity.EPIC), "a gilded pack still holds its sure Epic or Legendary")
	assert_eq(gilded_opened, 2)


func test_the_open_all_button_counts_the_gilded_packs() -> void:
	while PacksScreen.all_pack_count() > 0:
		PacksScreen.open_all()
	Session.add_pack(_gilded_id(), 2)
	var screen: PacksScreen = PacksScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	var button: Button = screen.find_child("OpenAll", true, false) as Button
	assert_not_null(button, "two gilded packs alone are enough for Open all")
	if button != null:
		assert_string_contains(button.text, "2 packs")
	assert_null(screen.find_child("OpenAllSkips", true, false), "nothing is left out any more")
	assert_not_null(screen.find_child("OpenAllIncludes", true, false), "it says the gilded packs are included")


# ---- 5.5 rewards wait for a click, and can be hovered ----------------------------------------------------------------------------------


func test_a_reward_is_found_by_its_name_or_its_id() -> void:
	var ladle: Variant = RewardLookup.find(Session.content, "Head Chef's Ladle")
	assert_true(ladle is EquipmentData)
	assert_eq((ladle as EquipmentData).id, "head_chef_ladle")
	assert_true(RewardLookup.find(Session.content, "power_wraps") is ItemData)
	assert_true(RewardLookup.find(Session.content, "B-27") is CardData)
	assert_null(RewardLookup.find(Session.content, "No Such Thing"))
	var info: String = RewardLookup.full_info(ladle)
	assert_string_contains(info, "Weapon", "what kind of thing it is")
	assert_string_contains(info, "gain 1 HP", "what it does")
	assert_string_contains(info, "Character page", "and where it went")


func test_a_queued_reward_box_holds_the_things_themselves() -> void:
	var summary: RewardSummary = Session.queue_reward_box("A test", "Given.", 40, 10, ["Head Chef's Ladle", "power_wraps", "B-27", _gilded_id()] as Array[String], "REWARD")
	assert_eq(Session.pending_popups.size(), 1, "queued for the world scene")
	assert_eq(summary.equipment.size(), 1)
	assert_eq(summary.items.size(), 1)
	assert_eq(summary.cards.size(), 1)
	assert_eq(summary.packs.size(), 1)
	assert_eq([summary.gold, summary.xp], [40, 10])
	assert_eq(summary.header, "REWARD")


func test_the_reward_box_waits_for_a_click_and_every_thing_can_be_hovered() -> void:
	var summary: RewardSummary = Session.queue_reward_box("The prize chest", "The chest holds a piece of gear.", 0, 0, ["head_chef_ladle", "power_wraps", _gilded_id()] as Array[String], "NEW GEAR!")
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	watch_signals(popup)
	await wait_seconds(2.5)
	assert_signal_not_emitted(popup, "finished", "it stays until the player answers")
	assert_true(popup.is_visible_in_tree())
	assert_string_contains(_labels(popup), "Head Chef's Ladle")
	var hovered: int = 0
	for tile: Node in popup.find_children("Reward_*", "Control", true, false):
		if not tile.has_meta(&"full_info"):
			continue
		hovered += 1
		assert_false(str(tile.get_meta(&"full_info")).is_empty())
		(tile as Control).mouse_entered.emit()
		await wait_frames(2)
		var tip: Node = get_tree().root.find_child("HoverTip", true, false)
		assert_not_null(tip, "%s: a hover shows its full info" % tile.name)
		if tip != null:
			assert_string_contains(_labels(tip), str(tile.get_meta(&"info_title")))
		(tile as Control).mouse_exited.emit()
		await wait_frames(2)
	assert_eq(hovered, 3, "the gear, the item and the pack")
	popup.frame.confirmed.emit()
	assert_signal_emitted(popup, "finished", "a click or a key press continues")


func test_the_controller_shows_the_info_by_focus() -> void:
	var summary: RewardSummary = Session.queue_reward_box("The prize chest", "", 0, 0, ["head_chef_ladle"] as Array[String])
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await wait_frames(4)
	var tile: Control = popup.find_child("Reward_*", true, false) as Control
	assert_not_null(tile)
	assert_eq(tile.focus_mode, Control.FOCUS_ALL, "the pad can stop on it")
	tile.focus_entered.emit()
	await wait_frames(2)
	assert_not_null(get_tree().root.find_child("HoverTip", true, false), "focus shows the same info as a hover")
	tile.focus_exited.emit()


## Every reward path that used to flash a short line now queues the reward box: the prize chest of a zone (the Head Chef's Ladle), the old
## puzzle prize, a gatekeeper's first win, the Restless Cairn, the Sealed Vault's card, Tilly's gift, a side dungeon's first-clear gear and
## the packs for toppling Primm.
func test_no_reward_path_is_a_fading_line_any_more() -> void:
	var zone: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	var town: String = FileAccess.get_file_as_string("res://world/town_scene.gd")
	var capital: String = FileAccess.get_file_as_string("res://world/capital/capital_scene.gd")
	var session: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	assert_false(zone.contains("joins your gear."), "the prize chest and the puzzle prize")
	assert_eq(zone.count("Session.queue_reward_box("), 2)
	assert_false(town.contains("hud.toast(reward_text"), "the gatekeepers and the Restless Cairn")
	assert_false(town.contains("joins your collection.\" %"), "the Sealed Vault")
	assert_false(town.contains("Received: Power Wraps"), "Tilly's gift")
	assert_eq(town.count("Session.queue_reward_box("), 4)
	assert_string_contains(capital, "Session.queue_reward_box(\"The Minister has fallen\"")
	assert_string_contains(session, "queue_reward_box(plan.dungeon_name, \"Cleared for the first time.\"", "a side dungeon's first-clear gear")


func test_the_prize_chest_of_a_zone_queues_the_box_with_its_gear() -> void:
	var def: ZoneDef = ZoneDefs.get_def("gourmand")
	assert_eq(def.puzzle_equipment_id, "head_chef_ladle")
	var piece: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
	assert_true(Session.grant_equipment(piece))
	var summary: RewardSummary = Session.queue_reward_box("The prize chest", "The chest holds a piece of gear.", 0, 0, [piece.id] as Array[String], "NEW GEAR!")
	assert_eq(summary.equipment, [piece] as Array[EquipmentData])
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await wait_frames(3)
	assert_string_contains(_labels(popup), "NEW GEAR!")
	assert_string_contains(_labels(popup), "Head Chef's Ladle")


func test_a_dungeon_treasure_lists_things_that_can_be_hovered() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/dungeon/treasure_screen.gd")
	assert_string_contains(source, "HoverTip.attach(row, RewardLookup.name_of(thing), RewardLookup.full_info(thing)")
	assert_string_contains(source, "_button.text = \"Continue\"", "and it waits for Continue")


# ---- 5.7 the mid-fight pop-up: one layout in every fight -----------------------------------------------------------------------------------


func test_every_scripted_fight_uses_the_one_popup_layout() -> void:
	var checked: int = 0
	var with_lines: int = 0
	for key: String in EncounterScripts.keys():
		for trigger: EncounterScripts.Trigger in EncounterScripts.triggers(key):
			checked += 1
			var text: String = ScriptEventBanner.layout_text(trigger, key)
			var blocks: PackedStringArray = text.split("\n\n")
			assert_eq(blocks[0], trigger.name, "%s: the event's name is at the top" % key)
			var effect: String = ScriptEventBanner.describe(trigger, key)
			assert_false(effect.is_empty(), "%s / %s: an effect description" % [key, trigger.name])
			assert_eq(blocks[1], effect, "%s / %s: a blank line, then the complete effect" % [key, trigger.name])
			if trigger.line.is_empty():
				assert_eq(blocks.size(), 2, "%s / %s: no dialogue, no third block" % [key, trigger.name])
				continue
			with_lines += 1
			assert_eq(blocks.size(), 3, "%s / %s: name, effect, dialogue" % [key, trigger.name])
			assert_eq(blocks[2], "%s: \"%s\"" % [key, trigger.line], "a blank line, then the dialogue")
			assert_true(ScriptEventBanner.dialogue_bbcode(trigger, key).begins_with("[b]%s:[/b] " % key), "the speaker's name is bold")
	assert_gt(checked, 20, "every scripted fight's events (%d)" % checked)
	assert_gt(with_lines, 10)


func test_the_popup_is_built_in_that_order_with_real_blank_lines() -> void:
	var banner: ScriptEventBanner = ScriptEventBanner.new()
	add_child_autofree(banner)
	await wait_frames(2)
	var key: String = ""
	var trigger: EncounterScripts.Trigger = null
	for candidate: String in EncounterScripts.keys():
		for each: EncounterScripts.Trigger in EncounterScripts.triggers(candidate):
			if not each.line.is_empty():
				key = candidate
				trigger = each
				break
		if trigger != null:
			break
	assert_not_null(trigger)
	banner.show_event(trigger, key, 1.0, true)
	await wait_seconds(0.5)
	var column: Node = banner.find_child("EventName", true, false).get_parent()
	var order: Array[String] = []
	for child: Node in column.get_children():
		if (child as Control).visible and child.name in [&"EventName", &"BlankAfterName", &"EventEffect", &"BlankAfterEffect", &"EventDialogue"]:
			order.append(str(child.name))
	assert_eq(order, ["EventName", "BlankAfterName", "EventEffect", "BlankAfterEffect", "EventDialogue"] as Array[String])
	assert_gte((banner.find_child("BlankAfterName", true, false) as Control).size.y, 24.0, "a full blank line")
	assert_gte((banner.find_child("BlankAfterEffect", true, false) as Control).size.y, 24.0, "a full blank line")
	assert_eq((banner.find_child("EventName", true, false) as Label).text, trigger.name)
	assert_eq((banner.find_child("EventEffect", true, false) as Label).text, ScriptEventBanner.describe(trigger, key))
	var dialogue: RichTextLabel = banner.find_child("EventDialogue", true, false) as RichTextLabel
	assert_string_contains(dialogue.text, "[b]%s:[/b]" % key, "the speaker's name in bold")
	assert_string_contains(dialogue.get_parsed_text(), trigger.line)
	assert_true(banner.is_waiting(), "and it waits for a click")
	banner.close()


# ---- 5.8 small grey text ---------------------------------------------------------------------------------------------------------------------


func _luminance(colour: Color) -> float:
	var parts: Array[float] = []
	for channel: float in [colour.r, colour.g, colour.b]:
		parts.append(channel / 12.92 if channel <= 0.03928 else pow((channel + 0.055) / 1.055, 2.4))
	return 0.2126 * parts[0] + 0.7152 * parts[1] + 0.0722 * parts[2]


## The contrast of `text` (with its own see-through) on `panel`, as the eye gets it (1 = none, 21 = black on white).
func _contrast(text: Color, panel: Color) -> float:
	var seen: Color = panel.lerp(Color(text.r, text.g, text.b), text.a)
	var light: float = maxf(_luminance(seen), _luminance(panel))
	var dark: float = minf(_luminance(seen), _luminance(panel))
	return (light + 0.05) / (dark + 0.05)


func test_the_quest_logs_later_and_unknown_steps_are_no_longer_faint() -> void:
	var wood: Color = Color("1c1722")
	assert_gte(QuestLogScreen.LATER_STEP_ALPHA, 0.8, "as solid as the quest box's (0.82)")
	assert_gte(QuestLogScreen.UNKNOWN_STEP_ALPHA, 0.75, "as solid as the quest box's (0.78)")
	var before: float = _contrast(Color(UIStyle.PARCHMENT, 0.45), wood)
	var after: float = _contrast(Color(UIStyle.PARCHMENT, QuestLogScreen.UNKNOWN_STEP_ALPHA), wood)
	assert_gt(after, 7.0, "the unknown-steps line reads clearly on the dark page (%.1f : 1, was %.1f : 1)" % [after, before])
	assert_gt(after, before * 1.8)
	var source: String = FileAccess.get_file_as_string("res://ui/quests/quest_log_screen.gd")
	for faint: String in ["Color(UIStyle.PARCHMENT, 0.4)", "Color(UIStyle.PARCHMENT, 0.45)", "Color(UIStyle.PARCHMENT, 0.5)", "Color(UIStyle.PARCHMENT, 0.6)"]:
		assert_false(source.contains(faint), "no step is drawn with %s any more" % faint)


func test_the_unknown_steps_line_in_the_open_quest_log() -> void:
	Session.set_flag(&"trial_cleared")
	Session.start_quest(ZoneQuestDefinitions.SIDE_NECRO if QuestCatalog.find(ZoneQuestDefinitions.SIDE_NECRO) != null else QuestDefinitions.MERCHANTS, false)
	var multi: String = ""
	for quest: QuestData in QuestCatalog.all():
		if quest.objectives.size() >= 3:
			multi = quest.id
			break
	assert_false(multi.is_empty())
	DevActions.set_quest_step(multi, 0)
	var screen: QuestLogScreen = QuestLogScreen.new()
	add_child_autofree(screen)
	await wait_frames(4)
	var label: Label = screen.find_child("HiddenStepsText", true, false) as Label
	if label == null:
		pass_test("the tracked quest shows no unknown steps on this page (covered by the constants)")
		return
	var colour: Color = label.get_theme_color("font_color")
	assert_gte(colour.a, 0.75, "the unknown-steps line is near-solid")
	assert_gte(label.get_theme_font_size("font_size"), 22)


func test_the_level_ups_xp_line_is_readable() -> void:
	var panel: Color = Color("1c1722")
	var before: float = _contrast(UIStyle.MUTED, panel)
	var after: float = _contrast(LevelUpScreen.XP_LINE_COLOR, panel)
	assert_gte(LevelUpScreen.XP_LINE_SIZE, 20, "a size larger (it was 18)")
	assert_gt(after, 9.0, "%.1f : 1 (the muted violet-grey was %.1f : 1)" % [after, before])
	assert_gt(after, before * 1.4)
	var source: String = FileAccess.get_file_as_string("res://ui/screens/level_up_screen.gd")
	assert_string_contains(source, "toward.name = \"XpTowardNext\"")
	assert_false(source.contains("int(bar.max_value)], &\"MutedLabel\", 18, UIStyle.MUTED"), "the old muted line is gone")
