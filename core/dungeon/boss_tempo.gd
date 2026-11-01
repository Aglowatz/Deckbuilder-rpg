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


static func rule_text(turns: int) -> String:
	if turns == 1:
		return "On its first turn its units do not attack. Watch what it builds."
	return "For its first %d turns its units do not attack. Watch what it builds." % turns


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
