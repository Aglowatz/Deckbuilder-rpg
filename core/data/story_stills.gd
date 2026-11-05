class_name StoryStills
extends RefCounted
## The story stills (STORY-* key art): full-screen illustrations with a caption box, shown at seven moments of the story. This class says which still belongs where and
## where its captions live: the story file `data/story/intro_story.tres`, keys `still.<name>` (`still.wake`, `still.flex`, ...), each a list of caption lines advanced by a click.
## The screen is `StoryStillScreen`.

const WAKE: String = "STORY-WAKE"
const FLEX: String = "STORY-FLEX"
const DOPPEL: String = "STORY-DOPPEL"
const APPROVAL: String = "STORY-APPROVAL"
const ROTHEART: String = "STORY-ROTHEART"
const PRIMM: String = "STORY-PRIMM"
const REUNION: String = "STORY-REUNION"
## Art import Oct 31: the opening plays at night, so the wake-up shows the night version. It has no captions of its own (dialogue freeze):
## it reads STORY-WAKE's (`CAPTION_FROM`). STORY-WAKE stays in the game as the fallback when the night art is missing.
const WAKE_NIGHT: String = "STORY-WAKE-NIGHT"

const IDS: Array[String] = [WAKE, FLEX, DOPPEL, APPROVAL, ROTHEART, PRIMM, REUNION]

## Cutscene beat effects that bring up a still: "<scene id>|<fx>" -> still. Grandmaster Flex throwing off his coat (House of Gains), the Test Kitchen's impostor losing its face.
const CUTSCENE_FX: Dictionary = {
	"flex|muscle_reveal": FLEX,
	"reveal|reveal_form": DOPPEL,
}

## Dungeon (`DungeonCatalog` id) -> the still after its boss falls, between the boss's closing lines and its aftermath scene.
const AFTER_BOSS: Dictionary = {
	"D-HFA": APPROVAL,
	"D-ROT": ROTHEART,
	"D-PC": PRIMM,
}

## Ending beat effects that bring up a still: the four Paths meeting in the Capital.
const ENDING_FX: Dictionary = {
	"reunion": REUNION,
}

## The flag that remembers the opening still was shown in this run (a new game clears the flags).
const FLAG_WAKE_SEEN: StringName = &"wake_still_seen"


## Stills that show another still's captions.
const CAPTION_FROM: Dictionary = {
	WAKE_NIGHT: WAKE,
}


static func caption_key(still_id: String) -> String:
	var source: String = str(CAPTION_FROM.get(still_id, still_id))
	return "still.%s" % source.trim_prefix("STORY-").to_lower()


## The still of the opening wake-up: the night one when it is in the game, else STORY-WAKE.
static func opening_wake() -> String:
	return WAKE_NIGHT if KeyArt.has(WAKE_NIGHT) else WAKE


## The caption lines of a still (a visible "[missing text: ...]" line when the story file has none).
static func captions(still_id: String) -> Array[String]:
	return StoryText.shared().get_lines(caption_key(still_id))


static func for_cutscene_fx(scene_id: String, fx: String) -> String:
	return str(CUTSCENE_FX.get("%s|%s" % [scene_id, fx], ""))


static func after_boss(dungeon_id: String) -> String:
	return str(AFTER_BOSS.get(dungeon_id, ""))


static func for_ending_fx(fx: String) -> String:
	return str(ENDING_FX.get(fx, ""))

## Art import Oct 29: stills that sit BEHIND a scene's own narration (no captions of their own, so no new text): the scene draws its
## words over the picture (`StillBackdrop`). A missing file keeps the scene's old look.
const CAPTURE: String = "STORY-CAPTURE"
const THRONE: String = "STORY-THRONE"
const WONDER: String = "STORY-WONDER"
const VACANCY: String = "STORY-VACANCY"
const SEVER: String = "STORY-SEVER"
const MODEL_ROOM: String = "STORY-MODEL-ROOM"
const KEPT_FACE: String = "STORY-KEPT-FACE"
const FACADE_FALLS: String = "STORY-FACADE-FALLS"
const CELL_4: String = "STORY-CELL-4"
const FUNERAL: String = "STORY-FUNERAL"
const HOME: String = "STORY-HOME"
const MEMORIES: Array[String] = ["STORY-MEMORY-1", "STORY-MEMORY-2", "STORY-MEMORY-3", "STORY-MEMORY-4"]
## Batch 11 (Nov 2): Primm's three fight cutscenes, the rescue in the cells, the Test Kitchen reveal and seven epilogue beats.
const PRIMM_P1: String = "STORY-PRIMM-P1"
const PRIMM_P2: String = "STORY-PRIMM-P2"
const PRIMM_FALL: String = "STORY-PRIMM-FALL"
const RESCUE: String = "STORY-RESCUE"
const REVEAL_KITCHEN: String = "STORY-REVEAL-KITCHEN"
const EPI_MODEL_FALLS: String = "STORY-EPI-MODEL-FALLS"
const EPI_RIFTS_CLOSE: String = "STORY-EPI-RIFTS-CLOSE"
const EPI_WRINKLES: String = "STORY-EPI-WRINKLES"
const EPI_TOGETHER: String = "STORY-EPI-TOGETHER"
const EPI_DECREE: String = "STORY-EPI-DECREE"
const EPI_PRIMM_SEES: String = "STORY-EPI-PRIMM-SEES"
const EPI_FILE_COMPLETE: String = "STORY-EPI-FILE-COMPLETE"

const BACKDROP_IDS: Array[String] = [CAPTURE, THRONE, WONDER, VACANCY, SEVER, MODEL_ROOM, KEPT_FACE, FACADE_FALLS, CELL_4, FUNERAL, HOME,
		"STORY-MEMORY-1", "STORY-MEMORY-2", "STORY-MEMORY-3", "STORY-MEMORY-4", PRIMM_P1, PRIMM_P2, PRIMM_FALL, RESCUE, REVEAL_KITCHEN,
		EPI_MODEL_FALLS, EPI_RIFTS_CLOSE, EPI_WRINKLES, EPI_TOGETHER, EPI_DECREE, EPI_PRIMM_SEES, EPI_FILE_COMPLETE]

## Fix pass Nov 4 (B): backdrop stills kept in the game but shown nowhere until their redo (docs/art/art_needed_nov4.csv).
const PARKED: Array[String] = [PRIMM_FALL]

## Overnight Nov 4-5, Part 7: Clench on his throne with Flex in chains, behind the flex cutscene's beats 1-2 (before the reveal). Wired
## before its art exists (docs/art/art_needed_nov4.csv): until then `StillBackdrop.make` finds no file and the beats keep the icon stage.
## Moves into BACKDROP_IDS once imported.
const CLENCH_THRONE: String = "STORY-CLENCH-THRONE"
const AWAITING_ART: Array[String] = [CLENCH_THRONE]

## Dungeon cutscene (`CutsceneDefs` id) -> its backdrop: the true Chef's dish, Agnes takes the office, letting the seed die, Primm at his
## model before the fight, "I kept your face".
const CUTSCENE_BACKDROPS: Dictionary = {
	"wonder": WONDER,
	"vacancy": VACANCY,
	"sever": SEVER,
	"primm_intro": MODEL_ROOM,
	"primm_reveal": KEPT_FACE,
	"primm_p1": PRIMM_P1,
	"primm_p2": PRIMM_P2,
	# Fix pass Nov 4 (B), Part 5.1: STORY-PRIMM-FALL paints Primm as a giant beside a tiny hero; until its redo (docs/art/art_needed_nov4.csv) his
	# defeat plays over the broken model city with nobody in it (no scene ever shows him scaled up).
	"primm_end": EPI_MODEL_FALLS,
	"rescue": RESCUE,
}

## Batch 11 (Nov 2): a still for some beats of a scene only (beat number -> still); a beat not listed falls back to the scene's
## CUTSCENE_BACKDROPS entry, else the icon stage. Grandmaster Flex's coat: his reveal still (STORY-FLEX, shown full screen on beat 3)
## stays behind beats 3-5 - before the reveal it would give it away, so beats 1-2 show Clench on his throne (CLENCH_THRONE) instead. The Test Kitchen: beats 1-4 in the
## kitchen, beat 5 (after the STORY-DOPPEL still) behind the revealed form.
const CUTSCENE_BEAT_BACKDROPS: Dictionary = {
	"flex": {1: CLENCH_THRONE, 2: CLENCH_THRONE, 3: FLEX, 4: FLEX, 5: FLEX},
	"reveal": {1: REVEAL_KITCHEN, 2: REVEAL_KITCHEN, 3: REVEAL_KITCHEN, 4: REVEAL_KITCHEN, 5: DOPPEL},
}

## Ending beat effect -> its backdrop: the Pathwork Throne, the facade falling.
const ENDING_BACKDROPS: Dictionary = {
	"throne": THRONE,
	"facade": FACADE_FALLS,
	# Batch 11 (Nov 2): epilogue beats 1, 3, 4, 6, 7, 9, 10; the reunion (beat 5) keeps its still behind its words after the full-screen view
	"crumble": EPI_MODEL_FALLS,
	"rifts": EPI_RIFTS_CLOSE,
	"wrinkles": EPI_WRINKLES,
	"reunion": REUNION,
	"unite": EPI_TOGETHER,
	"dove": EPI_DECREE,
	"primm_sees": EPI_PRIMM_SEES,
	"stamp": EPI_FILE_COMPLETE,
}

## Story scene (`StoryScenes` id, played in the dialogue box) -> its backdrop: Elowen taken at the castle gate, the Prince's old cell,
## the royal funeral, Isla's homecoming.
const SCENE_BACKDROPS: Dictionary = {
	"pc_capture": CAPTURE,
	"lab_cell4": CELL_4,
	"royal_funeral": FUNERAL,
	"isla_homecoming": HOME,
}


## The still behind beat `beat` (1-based, 0 = the scene as a whole) of a cutscene; "" = the icon stage.
static func cutscene_backdrop(scene_id: String, beat: int = 0) -> String:
	var per_beat: Dictionary = CUTSCENE_BEAT_BACKDROPS.get(scene_id, {}) as Dictionary
	if per_beat.has(beat):
		return str(per_beat[beat])
	return str(CUTSCENE_BACKDROPS.get(scene_id, ""))


static func ending_backdrop(fx: String) -> String:
	return str(ENDING_BACKDROPS.get(fx, ""))


static func scene_backdrop(scene_id: String) -> String:
	return str(SCENE_BACKDROPS.get(scene_id, ""))


## Memory fragment N (1-4) -> its backdrop.
static func memory_backdrop(number: int) -> String:
	if number < 1 or number > MEMORIES.size():
		return ""
	return MEMORIES[number - 1]
