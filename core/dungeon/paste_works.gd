class_name PasteWorks
extends RefCounted
## The Paste Works (S-PASTE, Oct 21): the Capital's second side dungeon, Colonel Crumb's factory of Primm's Perfect Nutrient Paste. Three
## battles (Ration Line, the Vat Floor, the Colonel's Kitchen); rules Bland Diet (healing does nothing) and Real Food (the player's Gourmand
## cards cost 1 less) in `DungeonRules`. Reached through Chef Marlo's second quest (`QUEST_ID`), offered once The Recipe Box is done and the
## Endless Buffet is free (Crumb fled there). The way in is the shuttered stall at the Hungry Quarter's south-west corner (`SPOT_ID`).
## The first win against Crumb pays his relic (`Lieutenants`); the first clear sets `FLAG_CLEARED`.

const DUNGEON_ID: String = "S-PASTE"
const QUEST_ID: String = "cap_paste_works"
const SPOT_ID: String = "paste_works"
## Set the first time the hero opens the stall's ration hatch (the quest's first step).
const FLAG_FOUND: StringName = &"paste_works_found"
const FLAG_CLEARED: StringName = &"paste_works_cleared"


## Marlo offers the quest once his recipes are back and the Buffet is free (that is when the Colonel ran to the Capital).
static func prerequisite() -> Condition:
	return Condition.all_of([Condition.quest_completed(CapitalZone.QUEST_RECIPES), Condition.flag(str(ZoneCompletion.flag_name("gourmand")))] as Array[Condition])


## The hatch is there while the quest runs, and afterwards for repeat runs.
static func door_open(flags: Dictionary, quest_active: bool, quest_done: bool) -> bool:
	return quest_active or quest_done or bool(flags.get(str(FLAG_CLEARED), false))
