class_name ItemUseResolver
extends RefCounted
## Resolves a consumable ItemData's effect against a DungeonRun (Part E). Items are used between
## encounters (the character screen, the dungeon map), not as an in-duel action, so only the
## operations that make sense outside a duel are supported; anything else is a documented no-op.
## Extending this to real in-battle item use is future work (see docs/design/open_questions.md).

const SUPPORTED_OPS: Array[CardEnums.EffectOp] = [CardEnums.EffectOp.GAIN_LIFE, CardEnums.EffectOp.LOSE_LIFE]


static func can_apply(item: ItemData) -> bool:
	return item != null and item.effect != null and SUPPORTED_OPS.has(item.effect.op)


## Applies the item to `run` if possible. Returns true if something happened.
static func apply(item: ItemData, run: DungeonRun) -> bool:
	if not can_apply(item) or run == null:
		return false
	match item.effect.op:
		CardEnums.EffectOp.GAIN_LIFE:
			run.heal(item.effect.amount)
			return true
		CardEnums.EffectOp.LOSE_LIFE:
			run.lose_life(item.effect.amount)
			return true
	return false
