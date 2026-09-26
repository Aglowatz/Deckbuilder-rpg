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
## Generic mana paid to use an ACTIVATED effect (once per turn per card).
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
