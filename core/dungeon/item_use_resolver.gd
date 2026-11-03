class_name ItemUseResolver
extends RefCounted
## Resolves a consumable ItemData's effect against a DungeonRun (Part E). Items are used between
## encounters (the character screen, the dungeon map), not as an in-duel action, so only the
## operations that make sense outside a duel are supported; anything else is a documented no-op.
## Extending this to real in-battle item use is future work (see docs/design/open_questions.md).

const SUPPORTED_OPS: Array[CardEnums.EffectOp] = [CardEnums.EffectOp.GAIN_HP, CardEnums.EffectOp.LOSE_HP]


static func can_apply(item: ItemData) -> bool:
	return item != null and item.effect != null and SUPPORTED_OPS.has(item.effect.op)


## Overnight Nov 2-3, Part 2: whether the last `apply` backfired (the item hurt its user instead; the screen says so).
static var last_backfired: bool = false


## Applies the item to `run` if possible. Returns true if something happened. `roll` (0..1) decides a reckless item's backfire (random when
## omitted; tests pass one).
static func apply(item: ItemData, run: DungeonRun, roll: float = -1.0) -> bool:
	last_backfired = false
	if not can_apply(item) or run == null:
		return false
	if item.backfire_chance > 0.0 and item.backfires(roll if roll >= 0.0 else randf()):
		last_backfired = true
		run.lose_hp(item.backfire_damage)
		return true
	match item.effect.op:
		CardEnums.EffectOp.GAIN_HP:
			run.heal(item.effect.amount)
			return true
		CardEnums.EffectOp.LOSE_HP:
			run.lose_hp(item.effect.amount)
			return true
	return false
