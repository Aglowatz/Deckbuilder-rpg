class_name DnaZone
extends RefCounted
## Constants shared by the D.N.A. (Department of Necrotic Affairs) zone: the Necrocrat zone that
## the town's Necrocrat entrance leads to. Text lives in ZoneStoryText, not here.

const ID: String = "necrocrat"
const DISPLAY_NAME: String = "The D.N.A."
const FULL_NAME: String = "Department of Necrotic Affairs"

const NPC_DOLORES: String = "Dolores"
const NPC_BARNABY: String = "Barnaby"
const NPC_PIP: String = "Pip"

## Counters / flags the zone sets (quest objectives read these as Conditions).
const COUNTER_PUNCHED_IN: String = "dna_punched_in"
const COUNTER_COFFEE: String = "dna_coffee_brewed"
const COUNTER_CHESTS: String = "dna_chests_opened"
const FLAG_QUIZ_DONE: StringName = &"dna_quiz_done"
const FLAG_PUZZLE_SOLVED: StringName = &"dna_puzzle_solved"
const FLAG_MINI_DUNGEON_CLEARED: StringName = &"dna_mini_dungeon_cleared"
const FLAG_MATCH_FIRST: StringName = &"dna_match_first_clear"
