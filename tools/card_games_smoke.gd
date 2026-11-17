class_name CardGamesSmoke
extends Node
## Fable Nov 16c (Part 5): the card games of all four Path zones in the real game, windowed, with real keys and clicks - in each zone:
## the minigame host's card game (Reps, Order Up, Sort It Out; the D.N.A.: Kyle's matching game is not a card minigame of this set, its
## terminal's File in Order is), the card quiz at the quiz-giver (How to play, four questions answered by clicking the answers, the
## result panel, the old trivia's reward and flags), and the one-time reward (the chest that replaced the puzzle in the Gainlands, the
## Buffet and the Dump; the Mail Room terminal's File in Order in the D.N.A.). Screenshots to _screenshots/card_games/.
##   bash tools/run_card_games_smoke.sh [zone ...]        Exit code 0 = every check passed.
## The older zone smokes (fifth to eighth brief) play the same things but start in town and no longer reach their zones.

const SHOT_DIR: String = "res://_screenshots/card_games/"
const TAG: String = "card_games_smoke"
const ZONES: Array[String] = ["beefcake", "gourmand", "refusemancer", "necrocrat"]
const PATHS: Dictionary = {"beefcake": Affinity.Type.BEEFCAKE, "gourmand": Affinity.Type.GOURMAND, "refusemancer": Affinity.Type.REFUSEMANCER, "necrocrat": Affinity.Type.NECROCRAT}
const GAMES: Dictionary = {"beefcake": "RepsCardScreen", "gourmand": "OrderCardScreen", "refusemancer": "SortCardScreen"}

var driver: UiDriver
var _failures: PackedStringArray = []
var _shots: int = 0


func run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	driver = UiDriver.new(get_tree())
	var wanted: Array[String] = []
	for zone_id: String in OS.get_environment("CARD_GAMES_ZONES").split(",", false):
		if ZONES.has(zone_id):
			wanted.append(zone_id)
	if wanted.is_empty():
		wanted = ZONES.duplicate()
	for zone_id: String in wanted:
		await _zone(zone_id)
	_finish(_failures.is_empty(), "%d zones: card game, card quiz, one-time reward (%d screenshots)" % [wanted.size(), _shots])


func _zone(zone_id: String) -> void:
	Session.new_game()
	Session.ensure_game(PATHS[zone_id] as Affinity.Type)
	Session.level_track_grants = false
	Session.set_flag(CorruptedNpcs.unlock_flag(zone_id))
	await driver.frames(5)
	var previous: Node = get_tree().current_scene
	Session.enter_zone(zone_id)
	var zone: ZoneScene = await _wait_for_zone(previous)
	_check(zone != null, "%s: the zone loads" % zone_id)
	if zone == null:
		return
	await driver.seconds(3.5)
	await _dismiss_dialogue(zone.dialogue)
	if GAMES.has(zone_id):
		await _minigame(zone, zone_id)
	await _quiz(zone, zone_id)
	await _reward(zone, zone_id)
	await _clear(zone)


## Stands on spot `id`, presses E and reads the talk away until an overlay opens (a host's long first talk needs a second E).
func _use(zone: ZoneScene, id: String) -> ZoneSpot:
	var spot: ZoneSpot = null
	for candidate: ZoneSpot in zone.spots:
		if candidate.id == id:
			spot = candidate
	_check(spot != null, "%s: the spot exists" % id)
	if spot == null:
		return null
	await _clear(zone)
	_teleport(zone, spot.position)
	await driver.seconds(0.5)
	for _attempt: int in range(4):
		if zone._overlay != null:
			break
		await driver.tap_key(KEY_E)
		await driver.seconds(0.35)
		await _dismiss_dialogue(zone.dialogue)
		await driver.seconds(0.5)
	return spot


func _minigame(zone: ZoneScene, zone_id: String) -> void:
	await _use(zone, "minigame")
	var screen: CardGameScreen = zone._overlay as CardGameScreen
	_check(screen != null and screen.get_script().get_global_name() == str(GAMES[zone_id]), "%s: the host opens %s" % [zone_id, str(GAMES[zone_id])])
	if screen == null:
		return
	_check(screen.how_is_open(), "%s: it opens on How to play" % zone_id)
	await _shot("%s_1_game_how" % zone_id)
	await driver.click_button("Play")
	await driver.seconds(0.6)
	_check(screen.state == "playing", "%s: Play starts the game" % zone_id)
	await _shot("%s_2_game_table" % zone_id)
	var gold: int = Session.gold
	await screen.shot_state("win")
	await driver.seconds(0.6)
	_check(screen.state == "done" and screen.result_panel() != null and bool(screen.result_panel().get_meta("won", false)), "%s: a won game ends on the win panel" % zone_id)
	_check(Session.gold > gold, "%s: the first win pays (%d -> %d gold)" % [zone_id, gold, Session.gold])
	_check(Session.flag(zone.def.flag_minigame_first), "%s: the first win is recorded" % zone_id)
	await _shot("%s_3_game_won" % zone_id)
	await _leave(zone)
	await driver.seconds(0.6)
	# (a level-up or reward pop-up may open as the game closes: the game itself must be gone)
	_check(not (zone._overlay is CardGameScreen), "%s: Leave closes the game (now open: %s)" % [zone_id, zone._overlay.get_script().get_global_name() if zone._overlay != null else "nothing"])


func _quiz(zone: ZoneScene, zone_id: String) -> void:
	await _use(zone, "quiz")
	var quiz: CardQuizScreen = zone._overlay as CardQuizScreen
	_check(quiz != null, "%s: the quiz-giver opens the card quiz" % zone_id)
	if quiz == null:
		return
	_check(quiz.how_is_open(), "%s: the card quiz opens on How to play" % zone_id)
	_check(not quiz.host_portrait().is_empty(), "%s: the teacher is at the desk (%s)" % [zone_id, quiz.host_name()])
	await driver.click_button("Play")
	await driver.seconds(0.5)
	_check(quiz.game.questions.size() == CardQuizGame.QUESTIONS, "%s: four questions are dealt" % zone_id)
	var path: Affinity.Type = ZoneEffects.path_of(zone_id)
	for question: CardQuizGame.Question in quiz.game.questions:
		var paths: Array[Affinity.Type] = question.card.paths()
		_check(paths.is_empty() or (paths.size() == 1 and paths[0] == path), "%s: %s is a card of the zone's Path or colourless" % [zone_id, question.card.display_name])
	await _shot("%s_4_quiz_question" % zone_id)
	var gold: int = Session.gold
	quiz.feedback_seconds = 0.3
	var guard: int = 0
	while not quiz.game.is_over() and guard < 6:
		guard += 1
		var right: Button = quiz.find_child("Answer%d" % (quiz.game.current().correct + 1), true, false) as Button
		_check(right != null, "%s: the right answer is a button" % zone_id)
		if right == null:
			break
		await driver.click(driver.button_center(right))
		await driver.seconds(1.4)
	await driver.seconds(0.6)
	_check(quiz.game.correct_count() == CardQuizGame.QUESTIONS, "%s: four right answers by clicking (%d)" % [zone_id, quiz.game.correct_count()])
	_check(quiz.state == "done" and quiz.result_panel() != null, "%s: the quiz ends on its result panel" % zone_id)
	_check(Session.flag(zone.def.flag_quiz_passed) and Session.flag(zone.def.flag_quiz_done), "%s: the pass and the attempt are recorded (the old trivia's flags)" % zone_id)
	var story: ZoneStoryText = ZoneStoryText.for_zone(zone_id)
	_check(Session.gold - gold == int(story.quiz_rewards[4]["gold"]), "%s: a perfect first pass pays the trivia's top reward (%d gold)" % [zone_id, Session.gold - gold])
	await _shot("%s_5_quiz_passed" % zone_id)
	await _leave(zone)
	await driver.seconds(0.6)
	# (a level-up or reward pop-up may open as the game closes: the game itself must be gone)
	_check(not (zone._overlay is CardGameScreen), "%s: Leave closes the quiz (now open: %s)" % [zone_id, zone._overlay.get_script().get_global_name() if zone._overlay != null else "nothing"])


func _reward(zone: ZoneScene, zone_id: String) -> void:
	var piece: EquipmentData = Session.content.equipment_piece(zone.def.puzzle_equipment_id)
	_check(piece != null and not Session.profile.owned_equipment.has(piece), "%s: the one-time reward is not owned yet" % zone_id)
	if zone_id == "necrocrat":
		await _use(zone, "puzzle")
		var filing: FileCardScreen = zone._overlay as FileCardScreen
		_check(filing != null, "necrocrat: the Mail Room terminal opens File in Order")
		if filing == null:
			return
		await driver.click_button("Play")
		await driver.seconds(0.5)
		await _shot("necrocrat_2_file_table")
		await filing.shot_state("win")
		await driver.seconds(0.8)
		_check(Session.flag(zone.def.flag_puzzle_solved), "necrocrat: an approved file sets the one-time flag")
		_check(Session.profile.owned_equipment.has(piece), "necrocrat: and gives the Soul Courier's Lanyard")
		await _shot("necrocrat_3_file_approved")
		await _leave(zone)
		await driver.seconds(0.6)
		return
	var spot: ZoneSpot = await _use(zone, "puzzle")
	if spot == null:
		return
	await driver.seconds(0.9)
	_check(spot.kind == "reward_chest", "%s: the puzzle's spot is a chest" % zone_id)
	_check(zone._overlay == null, "%s: no puzzle screen opens" % zone_id)
	_check(Session.flag(zone.def.flag_puzzle_solved), "%s: opening the chest sets the one-time flag" % zone_id)
	_check(Session.profile.owned_equipment.has(piece), "%s: the chest holds %s" % [zone_id, piece.source_name if piece != null else "?"])
	_check(zone.reward_chest_node != null and ChestKit.is_open(zone.reward_chest_node), "%s: the chest stands open" % zone_id)
	await _shot("%s_6_chest_open" % zone_id)
	var owned: int = Session.profile.owned_equipment.size()
	await driver.tap_key(KEY_E)
	await driver.seconds(0.5)
	_check(Session.profile.owned_equipment.size() == owned, "%s: a second look gives nothing more" % zone_id)


## Clicks the result panel's own Leave button (the header's close button reads "Leave (Esc)" too).
func _leave(zone: ZoneScene) -> void:
	var screen: CardGameScreen = zone._overlay as CardGameScreen
	var button: Button = screen.result_panel().find_child("LeaveButton", true, false) as Button if screen != null and screen.result_panel() != null else null
	_check(button != null, "the result panel has a Leave button")
	if button != null:
		await driver.click(driver.button_center(button))


func _clear(zone: ZoneScene) -> void:
	await _dismiss_dialogue(zone.dialogue)
	var guard: int = 0
	while zone._overlay != null and guard < 5:
		guard += 1
		await driver.tap_key(KEY_ESCAPE)
		await driver.seconds(0.4)


func _teleport(zone: ZoneScene, pos: Vector3) -> void:
	pos.y = zone.builder.height_at(pos)
	zone.player.position = pos
	for field: String in ["last_safe"]:
		if field in zone:
			zone.set(field, pos)
	zone._spawn_grace = 100000.0
	zone._invulnerable = 100000.0
	zone._camera.position = zone.player.position + CameraRig.shape(zone.camera_offset)


func _wait_for_zone(previous: Node) -> ZoneScene:
	var elapsed: float = 0.0
	while elapsed < 40.0:
		var scene: Node = get_tree().current_scene
		if scene is ZoneScene and scene != previous and not SceneManager.busy and (scene as ZoneScene).player != null:
			return scene as ZoneScene
		await driver.frames(5)
		elapsed += 5.0 / 60.0
	return null


func _dismiss_dialogue(dialogue: DialogueBox) -> void:
	await driver.frames(5)
	var guard: int = 0
	while dialogue != null and dialogue.active and guard < 30:
		guard += 1
		await driver.tap_key(KEY_E)
		await driver.seconds(0.15)


func _shot(shot_name: String) -> void:
	_shots += 1
	await driver.frames(2)
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var texture: Texture2D = get_tree().root.get_texture()
	if texture == null:
		return
	texture.get_image().save_png(ProjectSettings.globalize_path("%s%s.png" % [SHOT_DIR, shot_name]))
	print("%s: screenshot -> %s.png" % [TAG, shot_name])


func _check(condition: bool, message: String) -> void:
	if condition:
		print("%s: ok    %s" % [TAG, message])
	else:
		_failures.append(message)
		print("%s: FAIL  %s" % [TAG, message])


func _finish(ok: bool, reason: String) -> void:
	print("%s: %s - %s" % [TAG, "OK" if ok else "FAILED", reason])
	await driver.frames(3)
	get_tree().quit(0 if ok else 1)
