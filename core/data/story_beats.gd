class_name StoryBeats
extends RefCounted
## When the Oct 21 story beats play, as pure flag rules (no Session, no nodes), and how saves made before them catch up.
## Scene text: data/story/story_scenes.json (`StoryScenes`).
##
## - The capture (`pc_capture`, the castle gate's start node): once, the first time a castle run opens. Sets `elowen_seized` and
##   `rescuer_named` ({rescuer} reads "Elowen" from then on).
## - Maren's and Wren's reactions: the next talk with each after the capture (`maren_after_capture`, `wren_after_capture`).
## - Old saves: a save that already beat Primm went through the castle gate before the capture existed. `migrate` marks the capture as
##   having happened (the name too); Maren's reaction then tells it as news the next time they talk (a story note, not a replayed scene).

const FLAG_SEIZED: String = "elowen_seized"
const FLAG_NAMED: String = "rescuer_named"
const MAREN_CAPTURE: String = "maren_after_capture"
const WREN_CAPTURE: String = "wren_after_capture"


## Brings an old save's flags up to the new beats. Returns the flags it set (empty when nothing changed).
static func migrate(flags: Dictionary) -> Array[String]:
	var changed: Array[String] = []
	if bool(flags.get("primm_defeated", false)) and not bool(flags.get(FLAG_SEIZED, false)):
		for flag: String in [FLAG_SEIZED, FLAG_NAMED]:
			flags[flag] = true
			changed.append(flag)
	return changed


## Maren's next talk opens with this scene, or "" (none waiting).
static func maren_scene(flags: Dictionary) -> String:
	if bool(flags.get(FLAG_SEIZED, false)) and StoryScenes.should_play(MAREN_CAPTURE, flags):
		return MAREN_CAPTURE
	return ""


## Wren's next talk opens with this scene, or "".
static func wren_scene(flags: Dictionary) -> String:
	if bool(flags.get(FLAG_SEIZED, false)) and StoryScenes.should_play(WREN_CAPTURE, flags):
		return WREN_CAPTURE
	return ""


# ---- Elowen at the cave mouth (Part 2) ------------------------------------------------------------------------------------------

const CAVE_MOUTH_SCENES: int = 4


## The Cave Mouth scene waiting at Crosspath's cave mouth, or "": scene N once N zones are free and scenes 1..N-1 have played, until
## she is taken at the castle gate. Old saves past several zones get them one visit at a time, in order.
static func cave_mouth_scene(flags: Dictionary, zones_freed: int) -> String:
	if bool(flags.get(FLAG_SEIZED, false)):
		return ""
	for number: int in range(1, CAVE_MOUTH_SCENES + 1):
		var id: String = "cave_mouth_%d" % number
		if not StoryScenes.should_play(id, flags):
			continue
		return id if zones_freed >= number else ""
	return ""
