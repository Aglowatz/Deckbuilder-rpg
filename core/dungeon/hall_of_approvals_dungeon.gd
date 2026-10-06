class_name HallOfApprovalsDungeon
extends RefCounted
## THE HALL OF FINAL APPROVALS (Necrocrats): the ultimate bureaucratic nightmare - a massive government
## complex where every aspect of HP, death, resurrection and the afterlife requires authorization.
## Absurd departments, paperwork, waiting rooms, regulations and undead bureaucrats; nodes include
## bureaucratic challenges ("take a number" waits, forms that require other forms). Boss: the Registrar of
## Final Approvals, the authority that now controls the Necrocrats. 14 nodes, three branch points that rejoin.
## Text: data/story/dna_story.tres (`dungeon.ha_*`, `event.ha_*`).

const ZONE_ID: String = "necrocrat"
const REWARD_CARD_ID: String = "N-33"


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "The Hall of Final Approvals"
	def.backdrop = "hall"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 220
	def.reward_xp = 160
	def.add_foe("Intake Clerk", 12, "Balanced", EnemyDecks.trimmed("necro_zombies", 27, 16), "delapouite/tie")
	def.add_foe("Duplicate Forms Zombie", 14, "Defensive", EnemyDecks.trimmed("necro_zombies", 28, 16), "delapouite/shambling-zombie")
	def.add_foe("Mailroom Wraith", 14, "Aggressive", EnemyDecks.trimmed("necro_control", 28, 16), "lorc/ghost")
	def.add_foe("Compliance Enforcement Officer", 18, "Balanced", EnemyDecks.trimmed("necro_control", 31, 15), "delapouite/warlock-eye")
	def.add_foe("Appeals Judge", 16, "Defensive", EnemyDecks.trimmed("necro_control", 30, 16), "delapouite/full-folder")
	def.add_foe("Senior Clerk of Final Approvals", 22, "Balanced", EnemyDecks.trimmed("necro_zombies", 34, 15), "delapouite/stamper")
	def.add_foe("The Registrar of Final Approvals", 28, "Balanced", EnemyDecks.with_cards(EnemyDecks.recipe("necro_control", 17), {"N-33": 1, "N-32": 1}), "delapouite/stamper")
	# The Audit (node 6): your deck is examined for compliance.
	var audit: ChallengeData = MainDungeonDef.make_challenge("ha_audit", "The Audit", "", ChallengeData.Kind.TOP_N_TOTAL_COST, 3, 6)
	var stamp: ChallengeOutcome = MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +1 max hand size for the dungeon.")
	stamp.boon = MainDungeonDef.boon_source("Stamped and Approved", [CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, 1)] as Array[Modifier])
	audit.on_success = [stamp] as Array[ChallengeOutcome]
	audit.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP (a fine).")] as Array[ChallengeOutcome]
	def.add_challenge(audit)
	# Take a Number (node 1): a wait.
	var number: DungeonEvent = DungeonEvent.make("ha_take_a_number")
	number.choice([DungeonEvent.heal(2), DungeonEvent.gold(25)] as Array[DungeonEvent.Outcome])
	number.choice([DungeonEvent.pay_gold(30), DungeonEvent.heal(2)] as Array[DungeonEvent.Outcome])
	number.choice([DungeonEvent.damage(2)] as Array[DungeonEvent.Outcome])
	def.add_event(number)
	# Forms about forms (node 3): a chain - each form requires another form.
	var form_a: DungeonEvent = DungeonEvent.make("ha_form_a")
	form_a.choice([DungeonEvent.next("ha_form_b")] as Array[DungeonEvent.Outcome])
	form_a.choice([DungeonEvent.pay_gold(25), DungeonEvent.gold(0)] as Array[DungeonEvent.Outcome])
	var form_b: DungeonEvent = DungeonEvent.make("ha_form_b")
	form_b.choice([DungeonEvent.next("ha_form_c")] as Array[DungeonEvent.Outcome])
	form_b.choice([DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	var form_c: DungeonEvent = DungeonEvent.make("ha_form_c")
	form_c.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Form 13-B (Approved)", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier])), DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	form_c.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	def.add_event(form_a)
	def.add_event(form_b)
	def.add_event(form_c)
	# The Notary's Counter (node 11).
	var notary: DungeonEvent = DungeonEvent.make("ha_notary")
	notary.choice([DungeonEvent.pay_gold(50), DungeonEvent.boon(MainDungeonDef.boon_source("Notarized", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	notary.choice([DungeonEvent.heal(5), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	notary.choice([DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	def.add_event(notary)
	return def


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var start: DungeonMap.MapNode = def.node(map, DungeonMap.Kind.START, "ha_lobby", Vector2(0.06, 0.5))
	var number: DungeonMap.MapNode = def.event_node(map, "ha_number", Vector2(0.15, 0.5), "ha_take_a_number")
	var intake: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "ha_intake", Vector2(0.24, 0.5), "Intake Clerk")
	var forms: DungeonMap.MapNode = def.event_node(map, "ha_forms", Vector2(0.33, 0.27), "ha_form_a")
	var duplicates: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "ha_duplicates", Vector2(0.33, 0.73), "Duplicate Forms Zombie")
	var waiting: DungeonMap.MapNode = def.shrine_node(map, "ha_waiting", Vector2(0.42, 0.5), 6)
	var audit: DungeonMap.MapNode = def.challenge_node(map, "ha_audit", Vector2(0.51, 0.27), "ha_audit")
	var mailroom: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "ha_mailroom", Vector2(0.51, 0.73), "Mailroom Wraith")
	var lost: DungeonMap.MapNode = def.treasure_node(map, "ha_lost", Vector2(0.6, 0.5), {"gold": 85, "xp": 40, "item": "healing_salve"})
	var compliance: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "ha_compliance", Vector2(0.69, 0.5), "Compliance Enforcement Officer")
	var appeals: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "ha_appeals", Vector2(0.78, 0.27), "Appeals Judge")
	var notary: DungeonMap.MapNode = def.event_node(map, "ha_notary", Vector2(0.78, 0.73), "ha_notary")
	var clerk: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "ha_clerk", Vector2(0.87, 0.5), "Senior Clerk of Final Approvals")
	var boss: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BOSS, "ha_boss", Vector2(0.95, 0.5), "The Registrar of Final Approvals")
	def.link(map, [start.id], number.id)
	def.link(map, [number.id], intake.id)
	def.link(map, [intake.id], forms.id)
	def.link(map, [intake.id], duplicates.id)
	def.link(map, [forms.id, duplicates.id], waiting.id)
	def.link(map, [waiting.id], audit.id)
	def.link(map, [waiting.id], mailroom.id)
	def.link(map, [audit.id, mailroom.id], lost.id)
	def.link(map, [lost.id], compliance.id)
	def.link(map, [compliance.id], appeals.id)
	def.link(map, [compliance.id], notary.id)
	def.link(map, [appeals.id, notary.id], clerk.id)
	def.link(map, [clerk.id], boss.id)
	return map
