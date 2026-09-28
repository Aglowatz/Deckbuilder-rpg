class_name StoryText
extends Resource
## All narrative/placeholder dialogue text that isn't tied to a specific NPC's own script, kept
## in one place so it is easy to find and rewrite. Currently just the wake-up scene that opens
## the game; add more exported arrays here as the story grows instead of hardcoding lines in
## scene scripts.

## The hero wakes up alone and talks to themselves, before noticing the way out.
@export var awakening_lines: Array[String] = [
	"Where am I?",
	"What happened?",
	"My head...",
	"...There. Light, through the rocks. That must be the way out.",
]

## New brief, Part E: the 4 corrupted NPCs (one per element zone, see core/dungeon/
## corrupted_npcs.gd). Each has 3 sets of lines - before the fight (corrupted, hinting at what
## happened in their zone), after a win (freed/calmer, hinting at their zone), after a loss
## (short - they can be challenged again). Kept here, not hardcoded in town_scene.gd, so they can
## be rewritten without touching code.
@export var ember_npc_intro_lines: Array[String] = [
	"The fire... it doesn't go out anymore. It's UNDER my skin now.",
	"Ember Reaches burned itself into me, and it won't let go.",
	"Stand still and let it OUT of me!",
]
@export var ember_npc_victory_lines: Array[String] = [
	"...it's quiet. First time in - I don't know how long. Thank you.",
	"The Reaches did something to the fire there. Turned it wrong.",
	"Be careful, if you ever go.",
]
@export var ember_npc_defeat_lines: Array[String] = [
	"Ha! The fire's still mine.",
	"Come back when you're hotter-blooded.",
]

@export var tide_npc_intro_lines: Array[String] = [
	"Down... down where the tide never turns back. I hear it still, singing under my ribs.",
	"You want to go there? You'll have to get through me first, little one.",
]
@export var tide_npc_victory_lines: Array[String] = [
	"The tide let go. I can breathe again.",
	"There is something down in the Tide, deeper than water should go. It doesn't want visitors.",
]
@export var tide_npc_defeat_lines: Array[String] = [
	"The tide takes the weak first.",
	"Try again when you've learned to swim.",
]

@export var root_npc_intro_lines: Array[String] = [
	"The roots took hold of me long before I noticed. I stopped fighting it.",
	"Now the grove speaks through my mouth, and it says: LEAVE.",
]
@export var root_npc_victory_lines: Array[String] = [
	"The roots have loosened their grip. My apologies for the grove's rudeness.",
	"Something took root down in Root that shouldn't have. Watch your step, if you go looking.",
]
@export var root_npc_defeat_lines: Array[String] = [
	"The grove is patient.",
	"It will wait for you to grow stronger.",
]

@export var grave_npc_intro_lines: Array[String] = [
	"I buried them all, you know. Every last one, with my own two hands.",
	"Now the grave has buried something in me instead. Come closer. It wants to meet you.",
]
@export var grave_npc_victory_lines: Array[String] = [
	"...I can hear my own thoughts again.",
	"Whatever's down in the Grave, it isn't finished with the dead. Go carefully. Or don't go at all.",
]
@export var grave_npc_defeat_lines: Array[String] = [
	"Not yet, then. The grave keeps no schedule.",
	"Return whenever you're ready to lose again.",
]


func npc_intro_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_intro_lines
		"tide":
			return tide_npc_intro_lines
		"root":
			return root_npc_intro_lines
		"grave":
			return grave_npc_intro_lines
	return []


func npc_victory_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_victory_lines
		"tide":
			return tide_npc_victory_lines
		"root":
			return root_npc_victory_lines
		"grave":
			return grave_npc_victory_lines
	return []


func npc_defeat_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_defeat_lines
		"tide":
			return tide_npc_defeat_lines
		"root":
			return root_npc_defeat_lines
		"grave":
			return grave_npc_defeat_lines
	return []
