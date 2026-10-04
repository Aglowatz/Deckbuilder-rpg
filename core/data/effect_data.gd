class_name EffectData
extends Resource
## One data-driven effect: "when <trigger>, apply <op> to <target>".

@export var trigger: CardEnums.Trigger = CardEnums.Trigger.ON_ENTER
@export var target: CardEnums.TargetKind = CardEnums.TargetKind.SELF
@export var op: CardEnums.EffectOp = CardEnums.EffectOp.DEAL_DAMAGE
## Main amount: damage, cards, life, power delta for BUFF, token count for SUMMON_TOKEN.
@export var amount: int = 0
## Secondary amount: toughness delta for BUFF.
@export var amount2: int = 0
@export var duration: CardEnums.Duration = CardEnums.Duration.PERMANENT
## Keyword granted by GRANT_KEYWORD.
@export var keyword: CardEnums.Keyword = CardEnums.Keyword.FLYING
## Token summoned by SUMMON_TOKEN.
@export var token: CardData
## Generic Path energy paid to use an ACTIVATED effect (once per turn per card).
@export var activation_cost: int = 0
@export var description: String = ""


## True when the acting player must pick a target (spells) rather than the engine.
func needs_chosen_target() -> bool:
	return (
		target == CardEnums.TargetKind.CHOSEN_CREATURE_ANY
		or target == CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY
		or target == CardEnums.TargetKind.CHOSEN_CREATURE_ALLY
		or target == CardEnums.TargetKind.CHOSEN_PLAYER
	)


## New brief, Part B: a plain-language targeting requirement for tooltips (item bar, character
## screen, item vendor). Only the target kinds an item can actually carry need real wording; any
## other kind falls back to "No target needed" rather than guessing at unused cases.
func target_requirement_text() -> String:
	match target:
		CardEnums.TargetKind.CHOSEN_CREATURE_ANY:
			return "Requires a target: any creature."
		CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY:
			return "Requires a target: an enemy creature."
		CardEnums.TargetKind.CHOSEN_CREATURE_ALLY:
			return "Requires a target: one of your creatures."
		CardEnums.TargetKind.CHOSEN_PLAYER:
			return "Requires a target: a player."
		_:
			return "No target needed."
