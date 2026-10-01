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

@export var necrocrat_npc_intro_lines: Array[String] = [
	"I buried them all, you know. Every last one, with my own two hands.",
	"Afterlife Services and Labor filed me under Pending and I have been Pending ever since. Come closer. It wants to meet you.",
]
@export var necrocrat_npc_victory_lines: Array[String] = [
	"...I can hear my own thoughts again.",
	"Whatever is down in the D.N.A., it is not finished with the dead, and HR will not intervene. Go carefully. Or file a form.",
]
@export var necrocrat_npc_defeat_lines: Array[String] = [
	"Not yet, then. The Necrocrats keep no schedule.",
	"Return whenever you're ready to lose again.",
]

## Fourth brief, Part C: Wendell Cobb, "Assistant to the Regional Merchant" - the equipment
## vendor. An original character, not a reference to any real show - the brief asked for the
## flavor (rule-obsessed, beet-farming, security-protocol-minded office life), not the specifics.
@export var equipment_vendor_intro_lines: Array[String] = [
	"Halt. ...Or don't. I'm not a gate, I'm a merchant's assistant. But you were going to stop anyway - I could see it in your gait. Security Protocol One: assess the gait.",
	"Wendell Cobb. Assistant to the Regional Merchant. Not the Regional Merchant. Assistant TO. Say it with me. No? Fine. It matters to me.",
	"Everything on this rack is inventoried, oiled, and accounted for under Security Protocol Seven, which I will not explain, because it is need-to-know and you do not need to know.",
	"I keep the rest under the counter. Do not reach for the drawer. The drawer is not for you. The drawer has never been for anyone.",
]
@export var equipment_vendor_return_lines: Array[String] = [
	"Back again. Good - returning customers are the backbone of a healthy economy, and of my personal employee-of-the-month case file.",
	"The beets are coming in early this year. I'm choosing to see that as a sign.",
	"There's a bear that comes around some nights. We've reached an understanding: it doesn't ask about the beets, and I don't ask why it's there.",
]

## Fourth brief, Part F: The Restless Cairn - the ominous object that starts the Graveyard's
## scripted battle. Placeholder dialogue, shown before the fight (every time) and after (once per
## outcome) - see world/town_scene.gd `_talk_graveyard`/`_show_graveyard_result`.
@export var graveyard_intro_lines: Array[String] = [
	"The stones here were stacked by hands that stopped moving a long time ago.",
	"Something under the cairn is still keeping count of its turns.",
	"Touch it, and it will not stop counting until one of you does.",
]
@export var graveyard_victory_lines: Array[String] = [
	"The counting stops. For now.",
	"Whatever was keeping time down there has nothing left to spend it on.",
	"The stones are just stones again. Take what it was guarding.",
]
@export var graveyard_defeat_lines: Array[String] = [
	"It is still counting.",
	"Come back when you have more turns to spare than it does.",
]


## Part B: what quest givers say. Keys are "<quest id>.offer" (shown when the quest is offered),
## ".active" (reminder while it is running), ".ready" (objectives done, handing in) and ".done"
## (after it was completed). Each value is an Array of lines. Add a quest, add its keys here.
@export var quest_dialogue: Dictionary = {}


func quest_lines(key: String) -> Array[String]:
	var lines: Array[String] = []
	for line: Variant in (quest_dialogue.get(key, []) as Array):
		lines.append(str(line))
	return lines


func npc_intro_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_intro_lines
		"tide":
			return tide_npc_intro_lines
		"root":
			return root_npc_intro_lines
		"necrocrat":
			return necrocrat_npc_intro_lines
	return []


func npc_victory_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_victory_lines
		"tide":
			return tide_npc_victory_lines
		"root":
			return root_npc_victory_lines
		"necrocrat":
			return necrocrat_npc_victory_lines
	return []


func npc_defeat_lines(id: String) -> Array[String]:
	match id:
		"ember":
			return ember_npc_defeat_lines
		"tide":
			return tide_npc_defeat_lines
		"root":
			return root_npc_defeat_lines
		"necrocrat":
			return necrocrat_npc_defeat_lines
	return []
