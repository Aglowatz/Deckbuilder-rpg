class_name PrimmsCastleDungeon
extends RefCounted
## PRIMM'S CASTLE (the final dungeon, Brief 10 Part C): the palace of His Perfection, entered from the heart of the Capital. 30 nodes
## and heavy branching on the shared node-map system. SIDE BRANCHES DEAD-END (a treasure, an encounter, an event, lore) and the party
## doubles back to the branch point (`MapNode.return_to`). Sections, in order:
##   the Great Hall -> the Portrait Gallery (endless "improved" portraits) -> the Hall of Mirrors (mirrors that reflect only him)
##   -> the Ministry of Correction -> the Four Wings (one for each Path: the Doppelganger's lab notes, the coup orders, the
##   notarized paperwork, the corrupted seed; each a dead-end branch) -> the Archive of Good Intentions (his early journals and
##   blueprints) -> the Scale Model Chamber (a giant model of the kingdom he rearranges by hand) and the boss, PRIMM.
## Mixes battles, elites, deck challenges, events, shrines, treasure and story nodes. Serious beats: the corrected citizens, the Archive's
## journals, the last journal (he truly believes he is the hero). Text: data/story/capital_story.tres (`dungeon.pc_*`, `event.pc_*`,
## `challenge.pc_*`, `cutscene.primm_*`). The boss is `PrimmBoss` (three phases).

const ZONE_ID: String = "final"
const REWARD_CARD_ID: String = "the_paths_united"
const K := DungeonMap.Kind


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "Primm's Castle"
	def.backdrop = "castle"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 500
	def.reward_xp = 400
	var D: String = "infrastructure:D"
	var B: String = "infrastructure:B"
	var A: String = "infrastructure:A"
	var C: String = "infrastructure:C"
	def.add_foe("Hall Guard", 14, "Balanced", {D: 8, B: 8, "gate_guard": 4, "compliance_officer": 4, "citation": 3, "decree_of_order": 2, "perfection_inspector": 2}, "delapouite/guards")
	def.add_foe("Gallery Curator", 15, "Defensive", {D: 8, B: 8, "perfection_inspector": 4, "compliance_officer": 3, "tidy_bot": 3, "citation": 3, "decree_of_order": 2, "middle_manager": 2}, "delapouite/portrait")
	def.add_foe("Mirror Knight", 16, "Aggressive", {A: 8, D: 8, "gate_guard": 3, "ironclad": 3, "bloodthirst_wolf": 3, "citation": 3, "decree_of_order": 3, "hr_reaper": 1}, "delapouite/shinto-shrine-mirror")
	def.add_foe("Ministry Clerk", 15, "Balanced", {D: 9, B: 7, "compliance_officer": 4, "soul_auditor": 3, "citation": 4, "mandatory_fun_day": 2, "death_benefits": 2, "middle_manager": 2}, "delapouite/stamper")
	def.add_foe("Chief Corrector", 21, "Aggressive", {D: 8, A: 8, "perfection_inspector": 4, "hr_reaper": 2, "citation": 4, "decree_of_order": 3, "approved_gate_captain": 1, "performance_review": 2}, "cathelineau/nun-face")
	def.add_foe("Doppelganger Technician", 17, "Balanced", {B: 9, D: 7, "souffle_sprite": 3, "sneeze_guard": 3, "meatloaf_golem": 3, "food_fight": 2, "soup_of_the_day": 2, "citation": 2}, "lorc/acid-blob")
	def.add_foe("Regime Enforcer", 17, "Aggressive", {A: 9, D: 7, "gym_rat": 3, "pump_chaser": 3, "protein_golem": 3, "leg_day": 2, "compliance_officer": 3}, "delapouite/viking-head")
	def.add_foe("Notary Wraith", 17, "Defensive", {D: 10, B: 6, "soul_auditor": 3, "cubicle_zombie": 3, "middle_manager": 3, "take_a_number": 2, "performance_review": 2}, "delapouite/stamper")
	def.add_foe("Rotting Gardener", 17, "Balanced", {C: 9, D: 7, "compost_golem": 3, "landfill_hog": 3, "dung_beetle": 3, "vine_snare": 2, "moss_titan": 1, "citation": 2}, "cathelineau/tree-face")
	def.add_foe("Servant Corps", 16, "Balanced", {D: 8, B: 8, "tidy_bot": 4, "compliance_officer": 4, "gate_guard": 3, "citation": 3, "decree_of_order": 2}, "delapouite/guards")
	def.add_foe("Archive Warden", 17, "Defensive", {D: 9, B: 7, "perfection_inspector": 4, "gate_guard": 4, "middle_manager": 3, "citation": 3, "soul_auditor": 2}, "delapouite/book-cover")
	def.add_foe("Archive Automaton", 22, "Balanced", {D: 8, B: 8, "approved_gate_captain": 2, "perfection_inspector": 4, "tidy_bot": 4, "citation": 4, "decree_of_order": 3, "primm_standard_issue": 2}, "delapouite/cyborg-face")
	def.add_foe("Model Warden", 25, "Aggressive", {A: 5, B: 5, C: 5, D: 5, "approved_gate_captain": 2, "primm_perfect_citizen": 4, "primm_standard_issue": 3, "citation": 4, "decree_of_order": 3, "primm_correction": 1}, "delapouite/castle")
	def.add_foe(PrimmBoss.BOSS_FOE, PrimmBoss.phase(0).hp, "Balanced", PrimmBoss.phase(0).recipe, "cathelineau/old-king")
	_challenges(def)
	_events(def)
	return def


static func _challenges(def: MainDungeonDef) -> void:
	# The Hall of Mirrors (node 6): a mirror shows you what you really lead with.
	var mirror: ChallengeData = MainDungeonDef.make_challenge("pc_mirror_test", "", "", ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3)
	mirror.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain the boon Unreflected."), MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 2, "Heal 2 HP.")] as Array[ChallengeOutcome]
	mirror.on_success[0].boon = MainDungeonDef.boon_source("Unreflected", [CardBuilder.modifier(Modifier.Kind.STARTING_HP, 2)] as Array[Modifier])
	mirror.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 2, "Lose 2 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(mirror)
	# The Ministry's desk (node 9): a form of correction. Do you have the bodies to put on it?
	var desk: ChallengeData = MainDungeonDef.make_challenge("pc_ministry_desk", "", "", ChallengeData.Kind.TOP_N_TYPE_COUNT, 5, 2)
	desk.card_type = CardEnums.CardType.UNIT
	desk.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 3, "Heal 3 HP.")] as Array[ChallengeOutcome]
	desk.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(desk)
	# The Escalation Shelf (node 25): reforms that got out of hand; can your deck keep its footing?
	var shelf: ChallengeData = MainDungeonDef.make_challenge("pc_escalation_shelf", "", "", ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT, 5, 2)
	shelf.on_success = [MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, 4, "Heal 4 HP.")] as Array[ChallengeOutcome]
	shelf.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(shelf)


static func _events(def: MainDungeonDef) -> void:
	var portraits: DungeonEvent = DungeonEvent.make("pc_improved_portraits")
	portraits.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Sees Through the Frame", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	portraits.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	portraits.choice([DungeonEvent.gold(50), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	def.add_event(portraits)
	var honest: DungeonEvent = DungeonEvent.make("pc_honest_mirror")
	honest.choice([DungeonEvent.heal(4), DungeonEvent.boon(MainDungeonDef.boon_source("Seen As You Are", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	honest.choice([DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	def.add_event(honest)
	var corrected: DungeonEvent = DungeonEvent.make("pc_corrected_citizens")
	corrected.choice([DungeonEvent.boon(MainDungeonDef.boon_source("They Were Heard", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 3)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.heal(5), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	corrected.choice([DungeonEvent.gold(60)] as Array[DungeonEvent.Outcome])
	def.add_event(corrected)
	var wings: DungeonEvent = DungeonEvent.make("pc_four_wings")
	wings.choice([DungeonEvent.heal(2)] as Array[DungeonEvent.Outcome])
	wings.choice([DungeonEvent.gold(40)] as Array[DungeonEvent.Outcome])
	def.add_event(wings)
	var staircase: DungeonEvent = DungeonEvent.make("pc_grand_staircase")
	staircase.choice([DungeonEvent.damage(1), DungeonEvent.gold(70)] as Array[DungeonEvent.Outcome])
	staircase.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	staircase.choice([DungeonEvent.boon(MainDungeonDef.boon_source("The Servants' Way", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	def.add_event(staircase)
	var journals: DungeonEvent = DungeonEvent.make("pc_early_journals")
	journals.choice([DungeonEvent.boon(MainDungeonDef.boon_source("A Good Man's Plans", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2), CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	journals.choice([DungeonEvent.heal(4)] as Array[DungeonEvent.Outcome])
	def.add_event(journals)
	var last: DungeonEvent = DungeonEvent.make("pc_last_journal")
	last.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Understanding", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	last.choice([DungeonEvent.heal(5)] as Array[DungeonEvent.Outcome])
	def.add_event(last)


## Normalised x of a column of the map (14 columns, the boss in the last).
static func _x(column: float) -> float:
	return 0.04 + column * 0.0615


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var hall: String = "the Great Hall"
	var gallery: String = "the Portrait Gallery"
	var mirrors: String = "the Hall of Mirrors"
	var ministry: String = "the Ministry of Correction"
	var wings: String = "the Four Wings"
	var archive: String = "the Archive of Good Intentions"
	var model: String = "the Scale Model Chamber"

	# Column 0-1: the great doors and the hall.
	var gate: DungeonMap.MapNode = def.node(map, K.START, "pc_gate", Vector2(_x(0.0), 0.46), hall)                                                       # 0
	var great_hall: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_hall", Vector2(_x(1.0), 0.46), "Hall Guard", hall)                                # 1
	# Column 2-4: the Portrait Gallery and the Hall of Mirrors.
	var portraits: DungeonMap.MapNode = def.event_node(map, "pc_portraits", Vector2(_x(2.0), 0.28), "pc_improved_portraits", gallery)                    # 2
	var curator: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_curator", Vector2(_x(2.0), 0.64), "Gallery Curator", gallery)                        # 3
	var alcove: DungeonMap.MapNode = def.treasure_node(map, "pc_alcove", Vector2(_x(2.0), 0.1), {"gold": 90, "xp": 40, "item": "scroll_of_insight"}, gallery)  # 4 (dead end)
	var mirror_knight: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_mirror_knight", Vector2(_x(3.0), 0.28), "Mirror Knight", mirrors)             # 5
	var mirror_test: DungeonMap.MapNode = def.challenge_node(map, "pc_mirror_test", Vector2(_x(3.0), 0.64), "pc_mirror_test", mirrors)                    # 6
	var honest: DungeonMap.MapNode = def.event_node(map, "pc_honest_mirror", Vector2(_x(3.0), 0.82), "pc_honest_mirror", mirrors)                       # 7 (dead end)
	var mirror_shrine: DungeonMap.MapNode = def.shrine_node(map, "pc_mirror_shrine", Vector2(_x(4.0), 0.46), 6, mirrors)                                 # 8
	# Column 5-7: the Ministry of Correction.
	var desk: DungeonMap.MapNode = def.challenge_node(map, "pc_desk", Vector2(_x(5.0), 0.28), "pc_ministry_desk", ministry)                              # 9
	var clerk: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_clerk", Vector2(_x(5.0), 0.64), "Ministry Clerk", ministry)                            # 10
	var corrector: DungeonMap.MapNode = def.battle(map, K.ELITE, "pc_corrector", Vector2(_x(6.0), 0.46), "Chief Corrector", ministry)                    # 11
	var corrected: DungeonMap.MapNode = def.event_node(map, "pc_corrected", Vector2(_x(6.0), 0.1), "pc_corrected_citizens", ministry)                  # 12 (dead end)
	# Column 7-8: the junction of the four wings (each wing a dead-end branch) and two ways on.
	var junction: DungeonMap.MapNode = def.event_node(map, "pc_junction", Vector2(_x(7.0), 0.46), "pc_four_wings", wings)                                 # 13
	var wing_gourmand: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_wing_gourmand", Vector2(_x(7.0), 0.1), "Doppelganger Technician", "the Gourmand Wing")     # 14
	var wing_beefcake: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_wing_beefcake", Vector2(_x(8.0), 0.1), "Regime Enforcer", "the Beefcake Wing")           # 15
	var wing_necrocrat: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_wing_necrocrat", Vector2(_x(7.0), 0.82), "Notary Wraith", "the Necrocrat Wing")          # 16
	var wing_refusemancer: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_wing_refusemancer", Vector2(_x(8.0), 0.82), "Rotting Gardener", "the Refusemancer Wing")  # 17
	for wing: DungeonMap.MapNode in [wing_gourmand, wing_beefcake, wing_necrocrat, wing_refusemancer]:
		wing.card_choices = 3
		wing.gold_reward = 40
	var servants: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_servants", Vector2(_x(8.0), 0.28), "Servant Corps", wings)                           # 18
	var staircase: DungeonMap.MapNode = def.event_node(map, "pc_staircase", Vector2(_x(8.0), 0.64), "pc_grand_staircase", wings)                         # 19
	var vault: DungeonMap.MapNode = def.treasure_node(map, "pc_vault", Vector2(_x(9.0), 0.46), {"gold": 100, "xp": 50, "card": "primm_correction"}, wings)     # 20
	# Column 10-12: the Archive of Good Intentions.
	var archive_gate: DungeonMap.MapNode = def.battle(map, K.BATTLE, "pc_archive_gate", Vector2(_x(10.0), 0.28), "Archive Warden", archive)             # 21
	var journals: DungeonMap.MapNode = def.event_node(map, "pc_journals", Vector2(_x(10.0), 0.64), "pc_early_journals", archive)                         # 22
	var reading_room: DungeonMap.MapNode = def.shrine_node(map, "pc_reading_room", Vector2(_x(11.0), 0.46), 6, archive)                                  # 23
	var blueprints: DungeonMap.MapNode = def.treasure_node(map, "pc_blueprints", Vector2(_x(11.0), 0.1), {"gold": 110, "xp": 60, "item": "vitality_charm"}, archive)  # 24 (dead end)
	var shelf: DungeonMap.MapNode = def.challenge_node(map, "pc_shelf", Vector2(_x(12.0), 0.28), "pc_escalation_shelf", archive)                          # 25
	var automaton: DungeonMap.MapNode = def.battle(map, K.ELITE, "pc_automaton", Vector2(_x(12.0), 0.64), "Archive Automaton", archive)                  # 26
	var last_journal: DungeonMap.MapNode = def.event_node(map, "pc_last_journal", Vector2(_x(13.0), 0.46), "pc_last_journal", archive)                   # 27
	# The Scale Model Chamber and Primm.
	var warden: DungeonMap.MapNode = def.battle(map, K.ELITE, "pc_model_warden", Vector2(_x(14.0), 0.46), "Model Warden", model)                         # 28
	var boss: DungeonMap.MapNode = def.battle(map, K.BOSS, "pc_boss", Vector2(_x(15.0), 0.46), PrimmBoss.BOSS_FOE, model)                                 # 29
	boss.scene = "primm_intro"
	boss.after_scene = "primm_end"
	# Dead-end side branches double back to the branch point they hang off.
	for branch: Array in [[alcove, portraits], [honest, mirror_test], [corrected, corrector], [wing_gourmand, junction], [wing_beefcake, junction], [wing_necrocrat, junction],
			[wing_refusemancer, junction], [blueprints, reading_room]]:
		(branch[0] as DungeonMap.MapNode).return_to = (branch[1] as DungeonMap.MapNode).id
	# The forward links (branching, rejoining, and the dead ends hanging off).
	def.link(map, [gate.id], great_hall.id)
	def.link(map, [great_hall.id], portraits.id)
	def.link(map, [great_hall.id], curator.id)
	def.link(map, [portraits.id], alcove.id)
	def.link(map, [portraits.id], mirror_knight.id)
	def.link(map, [curator.id], mirror_test.id)
	def.link(map, [mirror_test.id], honest.id)
	def.link(map, [mirror_knight.id, mirror_test.id], mirror_shrine.id)
	def.link(map, [mirror_shrine.id], desk.id)
	def.link(map, [mirror_shrine.id], clerk.id)
	def.link(map, [desk.id, clerk.id], corrector.id)
	def.link(map, [corrector.id], corrected.id)
	def.link(map, [corrector.id], junction.id)
	def.link(map, [junction.id], wing_gourmand.id)
	def.link(map, [junction.id], wing_beefcake.id)
	def.link(map, [junction.id], wing_necrocrat.id)
	def.link(map, [junction.id], wing_refusemancer.id)
	def.link(map, [junction.id], servants.id)
	def.link(map, [junction.id], staircase.id)
	def.link(map, [servants.id, staircase.id], vault.id)
	def.link(map, [vault.id], archive_gate.id)
	def.link(map, [vault.id], journals.id)
	def.link(map, [archive_gate.id, journals.id], reading_room.id)
	def.link(map, [reading_room.id], blueprints.id)
	def.link(map, [reading_room.id], shelf.id)
	def.link(map, [reading_room.id], automaton.id)
	def.link(map, [shelf.id, automaton.id], last_journal.id)
	def.link(map, [last_journal.id], warden.id)
	def.link(map, [warden.id], boss.id)
	return map
