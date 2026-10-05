class_name CapitalRifts
extends RefCounted
## The Capital's rifts (Brief 10): glowing tears in reality scattered through the zone. They damage the player on contact,
## distort the area around them, and spawn or empower corrupted enemies (`CapitalEnemies.WRETCH` / `SWARM`, and roaming
## enemies that stand near an unsealed rift are empowered). SMALL ones can be sealed for a reward once their guardian
## (a Rift Wretch) is beaten; BIG ones stay open until Primm falls. Sealing is saved (`cap_rift_<id>_sealed`).

## Roaming enemies whose home is this close to an unsealed rift are empowered.
const EMPOWER_RANGE: float = 9.0
## Empowered enemies fight with this much more life and +1/+1 on their creatures.
const EMPOWER_LIFE: int = 3
const EMPOWER_STAT: int = 1


## [{id, x, z, radius, big, sealable, reward}] in the order the map places them.
static func all() -> Array[Dictionary]:
	return [
		{"id": "out_a", "x": 30.0, "z": 78.0, "radius": 2.0, "big": false, "sealable": true, "reward": {"gold": 70, "item": "healing_draught"}},
		{"id": "out_b", "x": 92.0, "z": 74.0, "radius": 2.4, "big": false, "sealable": false, "reward": {}},
		{"id": "reek", "x": 22.0, "z": 51.0, "radius": 2.0, "big": false, "sealable": true, "reward": {"gold": 60, "card": "recycle_bin"}},
		{"id": "grave", "x": 20.0, "z": 25.0, "radius": 2.0, "big": false, "sealable": true, "reward": {"gold": 60, "item": "grave_dust"}},
		{"id": "transit", "x": 105.0, "z": 47.0, "radius": 3.2, "big": true, "sealable": false, "reward": {}},
		{"id": "hungry", "x": 106.0, "z": 27.0, "radius": 2.0, "big": false, "sealable": true, "reward": {"gold": 60, "item": "hearty_pie"}},
		{"id": "approach_w", "x": 38.0, "z": 8.0, "radius": 3.2, "big": true, "sealable": false, "reward": {}},
		{"id": "approach_e", "x": 82.0, "z": 8.0, "radius": 2.0, "big": false, "sealable": true, "reward": {"gold": 90, "item": "vitality_charm"}},
		{"id": "ward", "x": 104.0, "z": 4.0, "radius": 1.8, "big": false, "sealable": false, "reward": {}},
	] as Array[Dictionary]


static func find(rift_id: String) -> Dictionary:
	for entry: Dictionary in all():
		if str(entry["id"]) == rift_id:
			return entry
	return {}


static func sealed_flag(rift_id: String) -> StringName:
	return StringName("cap_rift_%s_sealed" % rift_id)


## The enemy that guards a sealable rift (its spawn id in the layout).
static func guardian_id(rift_id: String) -> String:
	return "guard_" + rift_id


## True once the rift is closed: sealed by the player, or all rifts closing when Primm fell.
static func is_sealed(flags: Dictionary, rift_id: String) -> bool:
	return bool(flags.get(str(sealed_flag(rift_id)), false)) or bool(flags.get(str(CapitalZone.FLAG_FREED), false))


static func open_count(flags: Dictionary) -> int:
	var count: int = 0
	for entry: Dictionary in all():
		if not is_sealed(flags, str(entry["id"])):
			count += 1
	return count


## How hard the rift hurts on contact.
static func damage_of(entry: Dictionary) -> int:
	return CapitalZone.BIG_RIFT_DAMAGE if bool(entry["big"]) else CapitalZone.RIFT_DAMAGE


## The unsealed rift (if any) that `pos_xz` is touching (inside its radius plus the player's body).
static func touching(flags: Dictionary, pos_xz: Vector2, body: float = 0.25) -> Dictionary:
	for entry: Dictionary in all():
		if is_sealed(flags, str(entry["id"])):
			continue
		if pos_xz.distance_to(Vector2(float(entry["x"]), float(entry["z"]))) <= float(entry["radius"]) + body:
			return entry
	return {}


## True when `home_xz` lies within the empowering range of an unsealed rift.
static func empowers(flags: Dictionary, home_xz: Vector2) -> bool:
	for entry: Dictionary in all():
		if is_sealed(flags, str(entry["id"])):
			continue
		if home_xz.distance_to(Vector2(float(entry["x"]), float(entry["z"]))) <= EMPOWER_RANGE:
			return true
	return false
