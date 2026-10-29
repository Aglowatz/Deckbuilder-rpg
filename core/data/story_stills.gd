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


static func caption_key(still_id: String) -> String:
	return "still.%s" % still_id.trim_prefix("STORY-").to_lower()


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

const BACKDROP_IDS: Array[String] = [CAPTURE, THRONE, WONDER, VACANCY, SEVER, MODEL_ROOM, KEPT_FACE, FACADE_FALLS, CELL_4, FUNERAL, HOME,
		"STORY-MEMORY-1", "STORY-MEMORY-2", "STORY-MEMORY-3", "STORY-MEMORY-4"]

## Dungeon cutscene (`CutsceneDefs` id) -> its backdrop: the true Chef's dish, Agnes takes the office, letting the seed die, Primm at his
## model before the fight, "I kept your face".
const CUTSCENE_BACKDROPS: Dictionary = {
	"wonder": WONDER,
	"vacancy": VACANCY,
	"sever": SEVER,
	"primm_intro": MODEL_ROOM,
	"primm_reveal": KEPT_FACE,
}

## Ending beat effect -> its backdrop: the Pathwork Throne, the facade falling.
const ENDING_BACKDROPS: Dictionary = {
	"throne": THRONE,
	"facade": FACADE_FALLS,
}

## Story scene (`StoryScenes` id, played in the dialogue box) -> its backdrop: Elowen taken at the castle gate, the Prince's old cell,
## the royal funeral, Isla's homecoming.
const SCENE_BACKDROPS: Dictionary = {
	"pc_capture": CAPTURE,
	"lab_cell4": CELL_4,
	"royal_funeral": FUNERAL,
	"isla_homecoming": HOME,
}


static func cutscene_backdrop(scene_id: String) -> String:
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
