class_name OldWellSmoke
extends Node
## Overnight Oct 19-20, Part 6: the windowed check of the Old Well secret quest ("The Water Under the Well"), end to end like a player.
## A new Beefcake game with one Path zone freed (the way tests/core/dungeon/test_old_well_quest.gd does it); in Crosspath the well's spot is used
## (TownScene._interact, what E calls) and E taps through the vision: the hidden quest is active and the hero is not left locked. The two hums
## are found in the Verdant Dump and the Endless Buffet (each zone loaded, its hum spot used through ZoneScene._interact); set
## OLD_WELL_SMOKE_API=1 to set them through the Session API instead (lighter on memory). Back in town the well asks (the confirm, a real click
## on "Reach in"), the deck picker if any, the Echo's lines, the "Before the fight" brief lists "The Spring Remembers", Continue starts the duel
## (enemy name, rule badges, is_old_well_boss, the vault's battle song); a forced win (as tools/story_playthrough.gd) brings the reveal; the
## quest completes, the Phial of First Water is owned once and the stage is DONE. Screenshots to _screenshots/old_well_*.png.
## Run alone:  bash tools/run_old_well_smoke.sh

const TAG: String = "old_well_smoke"
const RULE_NAME: String = "The Spring Remembers"

var driver: UiDriver
var _failures: PackedStringArray = []
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.set_flag(ZoneCompletion.flag_name("beefcake"))  # one Path zone free: the well's vision can start the quest
	Session.set_flag(CorruptedNpcs.unlock_flag(HeapZone.ID))
	Session.set_flag(CorruptedNpcs.unlock_flag(BuffetZone.ID))
	driver = UiDriver.new(get_tree())
	var town: TownScene = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish("town never loaded")
		return
	await driver.seconds(1.5)
	await _settle(town.dialogue)
	if town._overlay != null:
		town._close_overlay()
		await driver.seconds(0.3)
	# 1. The first touch: the vision, then the hidden quest.
	_check(Session.old_well_stage() == OldWellQuest.Stage.HIDDEN, "before the touch the quest is hidden (stage HIDDEN)")
	_check(Session.old_well_can_begin(), "with a zone free the well can start the quest")
	var well: TownScene.Spot = _well_spot(town)
	_check(well != null, "the town has the Old Well spot")
	if well == null:
		_finish("no well spot")
		return
	town._interact(well)
	await driver.seconds(0.8)
	_check(town.dialogue.active, "touching the well plays the vision")
	await _shot("01_vision")
	await _tap_through(town.dialogue)
	await driver.seconds(0.6)
	_check(Session.quest_log.is_active(OldWellQuest.QUEST_ID), "after the vision the quest is active")
	_check(Session.old_well_stage() == OldWellQuest.Stage.LISTENING, "the stage is LISTENING")
	var quest: QuestData = QuestCatalog.find(OldWellQuest.QUEST_ID)
	_check(quest != null and quest.category == QuestData.Category.SIDE and not quest.auto_give and quest.giver_npc.is_empty(), "the quest is a secret side quest (no giver, never auto-given)")
	var markers: int = 0
	if quest != null:
		for objective: QuestObjective in quest.objectives:
			if objective.has_marker():
				markers += 1
	_check(markers == 0, "no objective has a world marker (%d)" % markers)
	_check(not town._locked, "the vision and its sting leave the hero free to move (town._locked false)")
	_check(not town.dialogue.active, "the vision's dialogue is closed")
	await _settle(town.dialogue)
	# 2. The two hums.
	if OS.get_environment("OLD_WELL_SMOKE_API") == "1":
		_check(Session.find_old_well_hum(HeapZone.ID), "API: the Dump's hum is found")
		_check(Session.find_old_well_hum(BuffetZone.ID), "API: the Buffet's hum is found")
	else:
		await _find_hum_in_zone(HeapZone.ID, HeapScene)
		await _find_hum_in_zone(BuffetZone.ID, BuffetScene)
	_check(Session.flag(OldWellQuest.FLAG_HEAP), "the Dump's flag is set")
	_check(Session.flag(OldWellQuest.FLAG_BUFFET), "the Buffet's flag is set")
	_check(Session.old_well_stage() == OldWellQuest.Stage.READY, "both hums found: the stage is READY")
	if not (get_tree().current_scene is TownScene):
		SceneManager.go_to_town()
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish("town never came back after the zones")
		return
	await driver.seconds(1.5)
	await _settle(town.dialogue)
	if town._overlay != null:
		town._close_overlay()
		await driver.seconds(0.3)
	# 3. The well again: the confirm, the deck picker if any, the Echo's lines, the brief, the duel.
	well = _well_spot(town)
	if well == null:
		_finish("no well spot on the way back")
		return
	_check(town._prompt_text(well) == OldWellStory.shared().text("prompt.well.ready"), "the well's prompt reads '%s'" % town._prompt_text(well))
	town._interact(well)
	await driver.seconds(0.6)
	await _tap_through(town.dialogue)
	await driver.seconds(0.6)
	var confirm: ConfirmDialog = _find_confirm(town)
	_check(confirm != null, "the well asks before the duel (confirm dialog)")
	if confirm == null:
		_finish("no confirm dialog")
		return
	_check(str(confirm.get_meta("title", "")) == OldWellStory.shared().text("confirm.title"), "the confirm is titled '%s'" % str(confirm.get_meta("title", "")))
	await _shot("02_confirm")
	var yes_text: String = OldWellStory.shared().text("confirm.yes")
	_check(await driver.click_button(yes_text), "'%s' is clickable" % yes_text)
	await driver.seconds(0.6)
	var picker: DeckPicker = get_tree().root.find_child("DeckPicker", true, false) as DeckPicker
	if picker != null:
		var use: Button = picker.find_child("UseButton0", true, false) as Button
		_check(use != null, "the deck picker has a Use button")
		if use != null:
			await driver.click(driver.button_center(use))
			await driver.seconds(0.6)
	await _tap_through(town.dialogue)
	await driver.seconds(0.6)
	var brief: RulesBrief = get_tree().root.find_child("RulesBrief", true, false) as RulesBrief
	_check(brief != null, "the 'Before the fight' brief shows")
	if brief == null:
		_finish("no brief")
		return
	var names: Array[String] = []
	for badge: RuleBadges.Badge in brief.badges:
		names.append(badge.name)
	_check(names.has(RULE_NAME), "the brief lists %s (%s)" % [RULE_NAME, ", ".join(names)])
	_check(brief.find_child("RuleIconRow", true, false) != null, "the brief has the rule icons")
	await driver.seconds(0.4)
	await _shot("03_brief")
	_check(await driver.click_button("Continue"), "the brief's Continue is clickable")
	var battle: BattleScreen = await _wait_for(BattleScreen) as BattleScreen
	_check(battle != null, "Continue starts the duel")
	if battle == null:
		_finish("no battle")
		return
	await driver.seconds(1.5)
	var context: BattleContext = battle.context
	_check(context != null and context.enemy_name == OldWellQuest.DISPLAY_NAME, "the enemy is %s" % OldWellQuest.DISPLAY_NAME)
	_check(context != null and context.is_old_well_boss, "the context is the Old Well boss")
	_check(context != null and not context.rule_badges.is_empty(), "the duel carries rule badges (%d)" % (context.rule_badges.size() if context != null else 0))
	var row: RuleIconRow = battle.find_child("RuleIconRow", true, false) as RuleIconRow
	_check(row != null and not row.badges.is_empty(), "the battle HUD shows the rule icons")
	var song: String = MusicDirector.for_battle(context, Session.flags) if context != null else ""
	_check(song == "MUS-VAULT-BATTLE", "the duel plays MUS-VAULT-BATTLE (%s)" % song)
	await _shot("04_battle")
	await _force_win(battle)
	# 4. Back in town: the reveal, the quest's reward.
	town = await _wait_for(TownScene) as TownScene
	if town == null:
		_finish("town never came back after the duel")
		return
	await driver.seconds(1.5)
	_check(town.dialogue.active, "the first win plays the final vision")
	await _shot("05_reveal")
	await _settle(town.dialogue)
	_check(Session.quest_log.is_completed(OldWellQuest.QUEST_ID), "the quest is completed")
	_check(Session.flag(OldWellQuest.FLAG_DEFEATED), "the Echo's flag is set")
	_check(Session.owned_equipment_ids().count(OldWellQuest.REWARD_EQUIPMENT_ID) == 1, "the Phial of First Water is owned once (%d)" % Session.owned_equipment_ids().count(OldWellQuest.REWARD_EQUIPMENT_ID))
	_check(Session.old_well_stage() == OldWellQuest.Stage.DONE, "the stage is DONE")
	_check(Session.pending_old_well_result.is_empty(), "the result is shown once")
	_check(not town._locked, "the hero is free to move after the reveal")
	_finish("")


## Loads `zone_id`, uses its hum (ZoneScene._interact, what E calls), taps through the find and checks the step.
func _find_hum_in_zone(zone_id: String, kind: Variant) -> void:
	Session.enter_zone(zone_id)
	var zone: ZoneScene = await _wait_for(kind, 90.0) as ZoneScene
	_check(zone != null, "%s: the zone loads" % zone_id)
	if zone == null:
		Session.find_old_well_hum(zone_id)  # carry on with the API so the rest of the flow is still checked
		return
	await driver.seconds(3.5)  # the zone title card
	await _settle(zone.dialogue)
	var hum: ZoneSpot = null
	for spot: ZoneSpot in zone.spots:
		if spot.id == OldWellSpot.SPOT_ID:
			hum = spot
	_check(hum != null and hum.kind == OldWellQuest.SPOT_KIND, "%s: the hum's spot is there while its step is open" % zone_id)
	_check(zone.get_node_or_null(OldWellSpot.GLOW_NAME) != null, "%s: the hum's glow is there" % zone_id)
	if hum == null:
		Session.find_old_well_hum(zone_id)
		return
	zone._interact(hum)
	await driver.seconds(0.6)
	_check(zone.dialogue.active, "%s: using the hum plays the find" % zone_id)
	await _tap_through(zone.dialogue)
	_check(Session.flag(OldWellQuest.flag_for(zone_id)), "%s: the step is recorded" % zone_id)
	_check(not zone.spots.has(hum), "%s: the hum's spot is gone" % zone_id)
	await driver.seconds(0.6)


func _well_spot(town: TownScene) -> TownScene.Spot:
	for spot: TownScene.Spot in town.spots:
		if spot.id == "well":
			return spot
	return null


func _find_confirm(town: TownScene) -> ConfirmDialog:
	for node: Node in town._overlay_layer.find_children("*", "ConfirmDialog", true, false):
		return node as ConfirmDialog
	for node: Node in get_tree().root.find_children("*", "ConfirmDialog", true, false):
		return node as ConfirmDialog
	return null


## Taps E while `dialogue` is open (a chain of beats re-opens it at once; a short idle check makes sure the chain is over).
func _tap_through(dialogue: DialogueBox) -> void:
	var idle: int = 0
	var guard: int = 0
	while guard < 120 and idle < 4:
		guard += 1
		if dialogue.active:
			idle = 0
			await driver.tap_key(KEY_E)
			await driver.seconds(0.25)
		else:
			idle += 1
			await driver.frames(4)


## Clears whatever the arrival or the quest pays out: dialogue, reward boxes (Continue), level-ups (Next level).
func _settle(dialogue: DialogueBox) -> void:
	var idle: int = 0
	var guard: int = 0
	while guard < 80 and idle < 6:
		guard += 1
		if dialogue.active:
			idle = 0
			await driver.tap_key(KEY_E)
			await driver.seconds(0.25)
		elif driver.find_button("Next level") != null:
			idle = 0
			await driver.seconds(PopupFrame.GUARD_TIME + 0.2)
			await driver.click_button("Next level")
			await driver.seconds(0.4)
		elif driver.find_button("Continue") != null:
			idle = 0
			await driver.seconds(PopupFrame.GUARD_TIME + 0.2)
			await driver.click_button("Continue")
			await driver.seconds(0.4)
		else:
			idle += 1
			await driver.seconds(0.2)


## As tools/story_playthrough.gd `_force_win`.
func _force_win(battle: BattleScreen) -> void:
	var context: BattleContext = battle.context
	await driver.seconds(0.8)
	if context == null:
		return
	context.game.players[0].hp = maxi(context.game.players[0].hp, 1)
	context.game._end_game(0, false)
	context.won = true
	Session.complete_battle(context)
	await driver.seconds(1.0)


func _shot(label: String) -> void:
	if _shots >= 6:
		return
	_shots += 1
	await driver.frames(2)
	get_viewport().get_texture().get_image().save_png("res://_screenshots/old_well_%s.png" % label)


func _wait_for(kind: Variant, timeout: float = 45.0) -> Node:
	var elapsed: float = 0.0
	while elapsed < timeout:
		var scene: Node = get_tree().current_scene
		if scene != null and is_instance_of(scene, kind) and not SceneManager.busy:
			return scene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])
		push_error("%s: %s" % [TAG, message])


func _finish(reason: String) -> void:
	var ok: bool = _failures.is_empty() and reason.is_empty()
	print("%s: %s%s" % [TAG, "OK" if ok else "FAILED", (" - " + reason) if not reason.is_empty() else ""])
	get_tree().quit(0 if ok else 1)
