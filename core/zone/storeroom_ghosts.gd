class_name StoreroomGhosts
extends RefCounted
## Oct 20, Part 4: the first scripted encounter - three petty ghosts haunting the store room beside Tilly Tonic's shop (Maren's third
## errand, `QuestDefinitions.GHOSTS`). The door is a spot in Crosspath (`SPOT_ID`); the room itself is never walked into: the duel starts
## at the door on the town battleboard. One-sided rule "Haunted Inventory" (`RULES_KEY` in data/encounters/modifiers.json): at the start
## of each of the ghosts' turns a 1/1 Ghost token joins them. Easy on purpose: every Path's level-3 deck wins about 90% in 5-8 turns
## (sim group `town:storeroom`, docs/design/balance_log.md). Pure data: Session builds the battle (`make_storeroom_battle`).

const SPOT_ID: String = "storeroom"
const ENEMY_NAME: String = "Store Room Ghosts"
const RULES_KEY: String = "town:storeroom"
const FLAG_CLEARED: StringName = &"storeroom_ghosts_cleared"
const BOARD_KEY: String = "town"
const AI_NAME: String = "Aggressive (tutorial)"
## The sim's expected level for the fight (the cave's 150 XP, Meet the Merchants and Make It Yours: level 4 just about).
const EXPECTED_LEVEL: int = 3
const HP: int = 3
const GOLD: int = 15
const XP: int = 30


static func recipe() -> Dictionary:
	# A thin deck of weak bodies on plain Necrocrat energy (no Red Tape from the infrastructure): the threat is the Ghosts that keep coming.
	return {"INF-02": 18, "C-01": 2}


static func deck(content: ContentSet) -> Deck:
	return ZoneDecks.from_recipe(content, ENEMY_NAME, recipe())


## The enemy seat: the ghosts' thin deck at their small HP total plus the one-sided rule.
static func enemy_setup(content: ContentSet) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(deck(content), null, [] as Array[ModifierSource], ENEMY_NAME)
	setup.starting_hp = HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = HP
	EncounterModifiers.apply_to_enemy(setup, RULES_KEY)
	return setup
