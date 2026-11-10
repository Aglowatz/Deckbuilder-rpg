class_name BossTempo
extends RefCounted
## Fable pass Nov 1 (Part 2, boss tempo): every boss opens with a SETUP WINDOW - for its first `setup_turns` turns its units do not
## attack, so the fight's gimmick (the Doppelganger's mask, Compostella's growth, a phase) is seen before the boss can kill a reasonable
## deck. Data-driven per boss: `setup_turns` in the boss block of `data/dungeons/dungeon_content.json` (0 turns it off; absent = the
## default below), `PrimmBoss.SETUP_TURNS` for the castle phases, the town bosses' own setups. The rule rides the normal encounter-rule
## pipeline (`EncounterModifiers.ensure_setup_rule` -> a `Modifier.Kind.SETUP_TURNS` on the foe's seat), so the node map, the pre-fight
## brief, the battle HUD and the balance sim all see the same "Setting Up" badge and the same rule.

const DEFAULT_SETUP_TURNS: int = 2
const RULE_NAME: String = "Setting Up"
const ICON: String = "lorc/hourglass"
## The boss data key.
const DATA_KEY: String = "setup_turns"

## Encounter key -> setup turns, registered when a boss is defined (`DungeonBuilder._add_foe`, `PrimmBoss.phase`, the town bosses). The
## first registration of a key wins. `EncounterModifiers.rules(key)` adds the "Setting Up" rule from here, so a reset of the JSON rules
## (tests) or a cached dungeon def never loses it.
static var _registered: Dictionary = {}


static func register(key: String, turns: int) -> void:
	if turns > 0 and not _registered.has(key):
		_registered[key] = turns


static func turns_for(key: String) -> int:
	return int(_registered.get(key, 0))


## Fix pass Nov 7 (item 10, C4c F7): said in the unit the HUD counts in. Fable pass Nov 10 (Part 2): that unit is the TURN (both players'
## turns: GameState.turn_number_of) - the boss takes its N-th turn inside Turn N whether it goes first or second, so the numbers are the
## same moment as before ("Setting Up: 2 turns left" beside the turn label, "from turn 3" in the panel, as the countdown agrees).
static func rule_text(turns: int) -> String:
	if turns == 1:
		return "Its units do not attack in turn 1; they can attack from turn 2. Watch what it builds."
	return "Its units do not attack in turns 1-%d; they can attack from turn %d. Watch what it builds." % [turns, turns + 1]


## The HUD's countdown under the turn label ("" once the window is over).
static func countdown_text(turns_left: int) -> String:
	if turns_left <= 0:
		return ""
	return "Setting Up: %d turn%s left" % [turns_left, "" if turns_left == 1 else "s"]


## The display rule with its modifier (null for 0 turns).
static func rule(turns: int) -> EncounterModifiers.Rule:
	if turns <= 0:
		return null
	var made: EncounterModifiers.Rule = EncounterModifiers.Rule.new()
	made.name = RULE_NAME
	made.text = rule_text(turns)
	made.icon = ICON
	made.side = "enemy"
	made.modifiers = [CardBuilder.modifier(Modifier.Kind.SETUP_TURNS, turns)] as Array[Modifier]
	return made


## The turns of a boss block ({"setup_turns": N}; absent = the default).
static func turns_of(boss: Dictionary) -> int:
	return maxi(0, int(boss.get(DATA_KEY, DEFAULT_SETUP_TURNS)))
