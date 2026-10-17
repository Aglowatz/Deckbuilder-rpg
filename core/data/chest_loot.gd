class_name ChestLoot
extends RefCounted
## Overnight Oct 16, Block 2: chests across the game can roll a piece of equipment or a pack on top of what they always hold. Tiers: 1 = the
## town and the first zones' hidden chests and side dungeons, 2 = the later zones and main dungeons, 3 = the Capital and the Lab. A chest never
## rolls a piece the player already owns (it rolls a pack instead, or nothing), and never replaces a fixed equipment reward.

## Chest-rollable pieces per tier (quest and dungeon pieces stay special and are never rolled).
const TIER_GEAR: Dictionary = {
	1: ["lucky_sock", "saucepan_helmet", "cardboard_cuirass", "flip_flops"],
	2: ["dog_eared_bookmark", "sucker_punch_mitts", "lucky_sock", "flip_flops"],
	3: ["sucker_punch_mitts", "dog_eared_bookmark"],
}
const GEAR_CHANCE: Dictionary = {1: 0.2, 2: 0.25, 3: 0.3}
const PACK_CHANCE: Dictionary = {1: 0.12, 2: 0.18, 3: 0.25}

## Area / zone id -> chest tier.
const ZONE_TIER: Dictionary = {"town": 1, "forest": 1, "beefcake": 1, "necrocrat": 1, "gourmand": 2, "refusemancer": 2, "final": 3}


static func tier_for(area: String) -> int:
	return int(ZONE_TIER.get(area, 1))


## The roll on its own: {"equipment": id} or {"pack": id} or {}. `owned` = equipment ids the player has.
static func roll(tier: int, area: String, owned: Array[String], rng: RandomNumberGenerator) -> Dictionary:
	var clamped: int = clampi(tier, 1, 3)
	if rng.randf() < float(GEAR_CHANCE[clamped]):
		var pool: Array[String] = []
		for id: Variant in TIER_GEAR[clamped] as Array:
			if not owned.has(str(id)):
				pool.append(str(id))
		if not pool.is_empty():
			return {"equipment": pool[rng.randi() % pool.size()]}
	if rng.randf() < float(PACK_CHANCE[clamped]):
		return {"pack": pack_for(area)}
	return {}


## A chest's fixed reward with the roll added (the fixed reward always wins: a chest that already holds equipment or a pack rolls nothing).
static func with_roll(reward: Dictionary, area: String, owned: Array[String], rng: RandomNumberGenerator) -> Dictionary:
	if reward.has("equipment") or reward.has("pack"):
		return reward
	var result: Dictionary = reward.duplicate()
	result.merge(roll(tier_for(area), area, owned, rng))
	return result


## The pack a chest rolls: the area's own Path Pack in a Path zone, a General Pack anywhere else.
static func pack_for(area: String) -> String:
	if area in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		return "path_%s" % area
	return "general_1"
