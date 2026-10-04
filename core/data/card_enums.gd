class_name CardEnums
extends RefCounted
## Shared enums for card and effect data.

enum CardType { INFRASTRUCTURE, CREATURE, SPELL, TRAP, ARTIFACT }

## Exactly four tiers - see docs/design/combat_rules.md "Rarity". Values are stored by ordinal
## in every saved .tres card, so the order must never change (only append would be safe).
enum Rarity { COMMON, UNCOMMON, EPIC, LEGENDARY }

enum Keyword {
	FLYING,
	REACH,
	HASTE,
	DEFENDER,
	TRAMPLE,
	FIRST_STRIKE,
	LIFESTEAL,
	GUARD,
	## Attacking does not activate this creature.
	VIGILANCE,
}

## When an effect fires. For spells, ON_ENTER fires when the spell resolves.
enum Trigger {
	ON_ENTER,
	ON_DEATH,
	ON_ATTACK,
	ON_BLOCK,
	START_OF_TURN,
	END_OF_TURN,
	ON_DAMAGE_TAKEN,
	ACTIVATED,
	## Trap conditions (only meaningful on TRAP cards while set face-down).
	TRAP_OPPONENT_ATTACKS,
	TRAP_OPPONENT_CREATURE,
	TRAP_OPPONENT_SPELL,
	TRAP_PLAYER_DAMAGED,
}

enum TargetKind {
	SELF,
	CONTROLLER,
	OPPONENT,
	TRIGGERING_CARD,
	CHOSEN_CREATURE_ANY,
	CHOSEN_CREATURE_ENEMY,
	CHOSEN_CREATURE_ALLY,
	CHOSEN_PLAYER,
	ALL_CREATURES,
	ALL_ENEMY_CREATURES,
	ALL_ALLY_CREATURES,
	ALL_PLAYERS,
	ALL_ATTACKERS,
	RANDOM_CREATURE,
	RANDOM_ENEMY_CREATURE,
	RANDOM_ALLY_CREATURE,
}

enum EffectOp {
	DEAL_DAMAGE,
	HEAL,
	DRAW,
	DISCARD,
	DESTROY,
	BUFF,
	SUMMON_TOKEN,
	RETURN_TO_HAND,
	MILL,
	GAIN_LIFE,
	LOSE_LIFE,
	GRANT_KEYWORD,
}

enum Duration { PERMANENT, END_OF_TURN }
