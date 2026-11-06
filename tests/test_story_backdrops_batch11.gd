extends GutTest
## Batch 11 (Nov 2): the twelve new story stills replace the icon stage behind Primm's three fight cutscenes, the rescue, the Test Kitchen
## reveal and seven epilogue beats. A beat with a still never shows the icon stage; the only cutscene beats left on the icon stage are
## Grandmaster Flex's beats 1-2 (his reveal still would give the reveal away before beat 3).

const NEW_STILLS: Array[String] = ["STORY-PRIMM-P1", "STORY-PRIMM-P2", "STORY-PRIMM-FALL", "STORY-RESCUE", "STORY-REVEAL-KITCHEN",
	"STORY-EPI-MODEL-FALLS", "STORY-EPI-RIFTS-CLOSE", "STORY-EPI-WRINKLES", "STORY-EPI-TOGETHER", "STORY-EPI-DECREE",
	"STORY-EPI-PRIMM-SEES", "STORY-EPI-FILE-COMPLETE"]

## The beats the brief names, scene -> {beat: still}.
const WIRED: Dictionary = {
	"primm_p1": {1: "STORY-PRIMM-P1", 2: "STORY-PRIMM-P1", 3: "STORY-PRIMM-P1", 4: "STORY-PRIMM-P1"},
	"primm_p2": {1: "STORY-PRIMM-P2", 2: "STORY-PRIMM-P2", 3: "STORY-PRIMM-P2", 4: "STORY-PRIMM-P2", 5: "STORY-PRIMM-P2"},
	# Fix pass Nov 4 (B): the giant-Primm still is parked until its redo; the broken model city stands in
	"primm_end": {1: "STORY-PRIMM-FALL", 2: "STORY-PRIMM-FALL", 3: "STORY-PRIMM-FALL", 4: "STORY-PRIMM-FALL", 5: "STORY-PRIMM-FALL",
		6: "STORY-PRIMM-FALL", 7: "STORY-PRIMM-FALL", 8: "STORY-PRIMM-FALL"},
	"rescue": {1: "STORY-RESCUE", 2: "STORY-RESCUE", 3: "STORY-RESCUE"},
	"reveal": {1: "STORY-REVEAL-KITCHEN", 2: "STORY-REVEAL-KITCHEN", 3: "STORY-REVEAL-KITCHEN", 4: "STORY-REVEAL-KITCHEN", 5: "STORY-DOPPEL"},
	"flex": {1: "STORY-CLENCH-THRONE", 2: "STORY-CLENCH-THRONE", 3: "STORY-FLEX", 4: "STORY-FLEX", 5: "STORY-FLEX"},
}

## Epilogue beat number (EndingDefs "n") -> its still.
const EPILOGUE: Dictionary = {1: "STORY-EPI-MODEL-FALLS", 3: "STORY-EPI-RIFTS-CLOSE", 4: "STORY-EPI-WRINKLES", 6: "STORY-EPI-TOGETHER",
	7: "STORY-EPI-DECREE", 9: "STORY-EPI-PRIMM-SEES", 10: "STORY-EPI-FILE-COMPLETE"}


func test_the_new_stills_are_in_the_game() -> void:
	for id: String in NEW_STILLS:
		assert_true(KeyArt.has(id), "%s imported" % id)
		assert_true(KeyArt.known_ids().has(id), "%s is a row of logo_title_art.csv" % id)
		assert_true(StoryStills.BACKDROP_IDS.has(id), "%s is a backdrop still" % id)


func test_cutscene_beats_wear_their_stills() -> void:
	for scene_id: String in WIRED.keys():
		var beats: Dictionary = WIRED[scene_id] as Dictionary
		for beat: int in beats.keys():
			assert_eq(StoryStills.cutscene_backdrop(scene_id, beat), str(beats[beat]), "%s beat %d" % [scene_id, beat])


func test_epilogue_beats_wear_their_stills() -> void:
	for beat: Dictionary in EndingDefs.BEATS:
		var n: int = int(beat["n"])
		if EPILOGUE.has(n):
			assert_eq(StoryStills.ending_backdrop(str(beat["fx"])), str(EPILOGUE[n]), "epilogue beat %d (%s)" % [n, beat["fx"]])


func test_beats_left_on_the_icon_stage() -> void:
	var icon_stage: Array[String] = []
	for scene_id: String in CutsceneDefs.SCENES.keys():
		for beat: Dictionary in CutsceneDefs.beats(scene_id):
			var still: String = StoryStills.cutscene_backdrop(scene_id, int(beat["n"]))
			if still == "" or not KeyArt.has(still):  # Overnight Nov 4-5: STORY-CLENCH-THRONE is wired before its art
				icon_stage.append("%s %d" % [scene_id, int(beat["n"])])
	assert_eq(icon_stage, [] as Array[String], "Batch 12: STORY-CLENCH-THRONE is in, so no cutscene beat keeps the icon stage")
	for beat: Dictionary in EndingDefs.BEATS:
		assert_ne(StoryStills.ending_backdrop(str(beat["fx"])), "", "epilogue beat %d has a still" % int(beat["n"]))


func test_the_screen_swaps_the_still_per_beat() -> void:
	var screen: CutsceneScreen = CutsceneScreen.make("primm_end")
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_eq(screen.backdrop_id(), "STORY-PRIMM-FALL", "Batch 12: the redone Primm still is back behind his defeat")
	assert_false(screen._stage_root.visible, "a beat with a still hides the icon stage")
	var flex: CutsceneScreen = CutsceneScreen.make("flex")
	add_child_autofree(flex)
	await get_tree().process_frame
	assert_eq(flex.backdrop_id(), "STORY-CLENCH-THRONE", "Batch 12: Flex's beat 1 shows Clench on his throne")
	assert_false(flex._stage_root.visible)
