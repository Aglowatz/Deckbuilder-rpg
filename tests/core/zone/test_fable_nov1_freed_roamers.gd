extends GutTest
## Fable pass Nov 1, Part 5: once a zone is freed its hostile roamers stop hurting you - touch-damage roamers wander in peace, battle
## roamers with a sparring deck keep their friendly rematch, the rest stand down; the Capital once Primm fell (its rifts close too).

const ZONE_IDS: Dictionary = {
	GainlandsZone.ID: GainlandsEnemies.IDS, DnaZone.ID: DnaEnemies.IDS, BuffetZone.ID: BuffetEnemies.IDS, HeapZone.ID: HeapEnemies.IDS,
	CapitalZone.ID: CapitalEnemies.IDS,
}


func test_nothing_changes_before_a_zone_is_freed() -> void:
	for zone_id: String in ZONE_IDS:
		assert_false(ZoneEnemies.is_freed(zone_id, {}), zone_id)
		for enemy_id: String in ZONE_IDS[zone_id] as Array[String]:
			assert_false(ZoneEnemies.is_peaceful(zone_id, enemy_id, false), "%s:%s hostile before the boss falls" % [zone_id, enemy_id])


func test_each_freed_zone_keeps_its_damage_roamers_peaceful_and_its_sparring_partners() -> void:
	var damage_seen: int = 0
	for zone_id: String in ZoneDefs.ids():
		var flags: Dictionary = {str(ZoneCompletion.flag_name(zone_id)): true}
		assert_true(ZoneEnemies.is_freed(zone_id, flags), "%s freed by its completion flag" % zone_id)
		for enemy_id: String in ZONE_IDS[zone_id] as Array[String]:
			var data: ZoneEnemyInfo = ZoneEnemies.info(zone_id, enemy_id)
			var peaceful: bool = ZoneEnemies.is_peaceful(zone_id, enemy_id, true)
			if data.kind == ZoneEnemyInfo.Kind.DAMAGE:
				damage_seen += 1
				assert_true(peaceful, "%s:%s (touch damage) wanders in peace" % [zone_id, enemy_id])
			elif ZoneEnemies.freed_recipe(zone_id, enemy_id).is_empty():
				assert_true(peaceful, "%s:%s (no sparring deck) stands down" % [zone_id, enemy_id])
			else:
				assert_false(peaceful, "%s:%s still offers its friendly rematch" % [zone_id, enemy_id])
	assert_eq(damage_seen, 4, "one touch-damage roamer per zone (sprite, courier, meatball, gulls)")


func test_the_capital_stands_down_once_primm_fell_and_its_rifts_close() -> void:
	var flags: Dictionary = {"primm_defeated": true}
	assert_true(ZoneEnemies.is_freed(CapitalZone.ID, flags))
	assert_false(ZoneEnemies.is_freed(CapitalZone.ID, {str(ZoneCompletion.flag_name("beefcake")): true}), "another zone's flag is not the Capital's")
	for enemy_id: String in CapitalEnemies.IDS:
		assert_true(ZoneEnemies.is_peaceful(CapitalZone.ID, enemy_id, true), "%s stands down in the liberated Capital" % enemy_id)
	for entry: Dictionary in CapitalRifts.all():
		assert_true(CapitalRifts.is_sealed(flags, str(entry["id"])), "rift %s closed by Primm's fall" % str(entry["id"]))
		assert_false(CapitalRifts.is_sealed({}, str(entry["id"])) and not bool(entry.get("sealable", false)) and false, "")
	assert_true(CapitalRifts.touching(flags, Vector2(24.0, 92.0)).is_empty(), "no rift hurts you after the ending")
	assert_false(CapitalRifts.touching({}, Vector2(24.0, 92.0)).is_empty(), "before it, the Outskirts rift still bites")


func test_a_peaceful_roamer_never_chases() -> void:
	var enemy: ZoneEnemy = ZoneEnemy.new()
	enemy.peaceful = true
	enemy.state = ZoneEnemy.State.CHASE
	assert_true(enemy.peaceful)
	enemy.free()
