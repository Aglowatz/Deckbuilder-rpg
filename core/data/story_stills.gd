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
