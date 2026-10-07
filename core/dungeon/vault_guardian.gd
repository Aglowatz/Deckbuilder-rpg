class_name VaultGuardian
extends RefCounted
## Brief 16, Group G: the Four-Seal Vault in the main town and the Warden who keeps it. Four hidden levers, one in each Path zone, break the vault's four seals
## (any order); once all four are pulled the vault can be opened and the Warden of the Four Seals - an EXTREMELY hard four-Path guardian - must be beaten.
## Single source of truth for ids, texts, the boss deck and the rewards. The world side is `world/vault/` (levers, seals) and `TownScene` (the vault door).

const NPC_ID: String = "NPC-VAULTWARDEN"
const DISPLAY_NAME: String = "The Warden of the Four Seals"
const QUEST_ID: String = "four_seals"
const FLAG_DEFEATED: StringName = &"vault_warden_defeated"
const COUNTER_LEVERS: String = "vault_levers_pulled"
const FLAG_PREFIX: String = "vault_lever_"
## The four zones (ZoneDefs ids) that each hide one lever, in the order of the seals on the door: Gainlands, Endless Buffet, Verdant Dump, D.N.A.
const ZONE_IDS: Array[String] = ["beefcake", "gourmand", "refusemancer", "necrocrat"]
const STARTING_HP: int = 40
const AI_NAME: String = "Aggressive"

## The boss deck: every Path's heaviest hitters and removal (Beefcake bruisers, Gourmand golems, Refusemancer walls, Necrocrat control) and the Champion of the Four Paths.
const DECK_RECIPE: Dictionary = {
	"BAS-B": 5, "BAS-G": 5, "BAS-N": 5, "BAS-R": 5,
	"B-11": 2, "B-28": 1, "B-29": 1, "B-12": 2, "B-27": 1, "B-25": 1,
	"G-22": 2, "G-29": 1, "G-33": 1, "G-20": 1,
	"N-28": 1, "N-33": 1, "N-30": 1, "N-15": 2, "N-29": 1, "N-32": 1,
	"R-29": 1, "R-33": 1, "R-09": 2, "R-19": 1,
	"P4-01": 1, "C-30": 1,
}
## It also summons, at the start of each of its own turns, a stronger unit than the turn before (a Zombie Rat, a Poo Golem, a Cake Golem, a Masterpiece Golem, a
## Protein Golem, a Wedding Cake Colossus): one stage per Path and then the heaviest two.
const SUMMON_STAGES: Array[String] = ["T-11", "T-01", "T-06", "T-18", "T-20", "T-07"]

# ---- Rewards (what was chosen, and why, is in docs/design/secrets.md) ----------------------------------------------
const REWARD_PACKS_PER_PATH: int = 1
const REWARD_ESSENCE_PER_PATH: int = 40
const REWARD_XP: int = 600
const REWARD_EQUIPMENT_ID: String = "four_seal_signet"
const REWARD_COSMETIC_ID: String = "cloak_four_seals"

const LEVER_LINES: Dictionary = {
	"beefcake": "A rusted barbell stand with a lever bolted to its side, behind the farthest weight racks.",
	"gourmand": "A dumbwaiter handle hidden behind the furthest corner of the table.",
	"refusemancer": "A pump handle sunk in the heap, half buried in compost.",
	"necrocrat": "A fire-alarm lever labelled DO NOT PULL, at the very end of the office.",
}

const BEFORE_LINES: Array[String] = [
	"[calm] Four seals broken. Four Paths proven. Only the vault remains.",
	"[calm] I am the Warden. I keep what the Paths agreed to bury. Show me that you can use all of them, or be buried too.",
]
const WIN_LINES: Array[String] = [
	"[angry] The seals... are yours. Every Path bows to you.",
	"[calm] Take what was buried here. Use it wisely. Or at least loudly.",
]
const LOSE_LINES: Array[String] = [
	"[calm] The seals hold. Come back stronger. The vault is not going anywhere.",
]
const SEALED_LINES: Array[String] = [
	"A great door of stone, carved with four seals.",
	"It is cold to the touch. The seals do not move. Something, somewhere far away, must open them.",
]
const EMPTY_LINES: Array[String] = ["The vault stands open. Its Warden is gone, and so is everything it kept."]


static func flag_for(zone_id: String) -> StringName:
	return StringName(FLAG_PREFIX + zone_id)


static func is_lever_zone(zone_id: String) -> bool:
	return ZONE_IDS.has(zone_id)


## How many of the four levers are pulled, given the flags.
static func levers_pulled(flags: Dictionary) -> int:
	var count: int = 0
	for zone_id: String in ZONE_IDS:
		if flags.get(String(flag_for(zone_id)), false) == true:
			count += 1
	return count


static func all_pulled(flags: Dictionary) -> bool:
	return levers_pulled(flags) == ZONE_IDS.size()


## The text of the cutaway when a lever is pulled: something happened far away.
static func pulled_message(count: int) -> String:
	if count >= ZONE_IDS.size():
		return "Far away, the last seal shatters. The great vault door grinds open... (4/4)"
	return "Far away, a great lock grinds open... (%d/%d)" % [count, ZONE_IDS.size()]


static func _escalation_modifier() -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.SCRIPTED_ESCALATING_SUMMON
	var stages: Array[CardData] = []
	for id: String in SUMMON_STAGES:
		stages.append(TokenRegistry.data(id))
	modifier.tokens = stages
	modifier.label = "The seals send guardians"
	return modifier


static func deck(content: ContentSet) -> Deck:
	return ZoneDecks.from_recipe(content, DISPLAY_NAME, DECK_RECIPE)


static func personality(content: ContentSet) -> AIPersonality:
	return ZoneDecks.personality(content, AI_NAME)


static func enemy_setup(content: ContentSet) -> PlayerSetup:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "The Four-Seal Vault"
	source.source_kind = ModifierSource.SourceKind.DUNGEON
	source.modifiers = [_escalation_modifier()] as Array[Modifier]
	var setup: PlayerSetup = PlayerSetup.create(deck(content), null, [source] as Array[ModifierSource], DISPLAY_NAME)
	setup.starting_hp = STARTING_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = STARTING_HP
	return setup


static func reward_equipment(content: ContentSet) -> EquipmentData:
	return content.equipment_piece(REWARD_EQUIPMENT_ID)
