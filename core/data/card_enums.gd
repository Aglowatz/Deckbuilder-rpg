class_name CardEnums
extends RefCounted
## Shared enums for card and effect data.

## Stored by ordinal in saved .tres cards: only ever append.
enum CardType { INFRASTRUCTURE, UNIT, SPELL, TRAP, WONDER, TOOL, RESOURCE, TOKEN }

## Exactly four tiers - see docs/design/combat_rules.md "Rarity". Values are stored by ordinal
## in every saved .tres card, so the order must never change (only append would be safe).
enum Rarity { COMMON, UNCOMMON, EPIC, LEGENDARY }

enum Keyword {
	FLYING,
	## Can block units with Flying.
	SWAT,
	## Can attack and activate the turn it enters.
	HUSTLE,
	## Can't attack.
	WALLFLOWER,
	## Excess combat damage beyond the blocker's defense hits the opponent.
	BULLDOZE,
	## Deals combat damage before units without it.
	SUCKER_PUNCH,
	## Damage this deals also heals you that much.
	NOURISH,
	## Attacking doesn't activate (exhaust) this unit.
	OVERTIME,
	## Deals both Sucker Punch and regular combat damage.
	ONE_TWO_PUNCH,
	## Any damage this deals to a unit destroys it.
	TOXIC,
	## Can't be blocked.
	ELUSIVE,
	## Can't be targeted by your opponent's cards.
	UNTOUCHABLE,
	## Can't be destroyed by damage or destroy effects.
	UNBREAKABLE,
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
	TRAP_OPPONENT_UNIT,
	TRAP_OPPONENT_SPELL,
	TRAP_PLAYER_DAMAGED,
}

enum TargetKind {
	SELF,
	CONTROLLER,
	OPPONENT,
	TRIGGERING_CARD,
	CHOSEN_UNIT_ANY,
	CHOSEN_UNIT_ENEMY,
	CHOSEN_UNIT_ALLY,
	CHOSEN_PLAYER,
	ALL_UNITS,
	ALL_ENEMY_UNITS,
	ALL_ALLY_UNITS,
	ALL_PLAYERS,
	ALL_ATTACKERS,
	RANDOM_UNIT,
	RANDOM_ENEMY_UNIT,
	RANDOM_ALLY_UNIT,
}

enum EffectOp {
	DEAL_DAMAGE,
	HEAL,
	DRAW,
	TOSS,
	DESTROY,
	BUFF,
	SUMMON_TOKEN,
	SEND_BACK,
	BURY,
	GAIN_HP,
	LOSE_HP,
	GRANT_KEYWORD,
	## Brief 14: create resources (`amount` = ResourceKind ordinal, `amount2` = how many, default 1) for the target player.
	CREATE_RESOURCE,
}

enum Duration { PERMANENT, END_OF_TURN }
