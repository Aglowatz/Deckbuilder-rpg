class_name GraveyardBoss
extends RefCounted
## Fourth brief, Part F: the Graveyard's scripted battle - an ominous object (The Restless Cairn,
## in town) starts a duel against "The Restless Dead", who summons an increasingly powerful
## unit at the start of every one of their own turns (SCRIPTED_ESCALATING_SUMMON, a reusable
## engine-level rule - see core/data/modifier.gd and core/game/game_state.gd
## `_fire_scripted_summons` - so any future boss can reuse the exact same mechanic with its own
## stages). Single source of truth for the encounter, mirroring core/dungeon/corrupted_npcs.gd's
## shape; dialogue text lives in `StoryText` (core/data/story_text.gd), not here.

const DISPLAY_NAME: String = "The Restless Dead"
const STARTING_HP: int = 12
## A thin, mostly-defensive dark (Affinity D) deck - the escalating summon is the real engine of
## difficulty, not the boss's own hand; see docs/balance_report.md for how this was tuned.
const DECK_RECIPE: Dictionary = {
	"BAS-N": 20, "N-01": 3, "N-02": 3, "N-06": 1, "N-15": 1,
}
const AI_NAME: String = "Defensive"
const REWARD_GOLD: int = 220
const REWARD_XP: int = 150
## New brief, Part F: "a strong one-time reward... and something notable" - Thorned Loincloth
## (advanced armor, punishes every attacker for 1 whenever they attack you) both fits the fight
## thematically (surviving a horde by making the horde hurt itself) and is otherwise locked behind
## the level-10 equipment-vendor reward (D94) or 280 gold - this fight is a real, earlier way in.
const REWARD_EQUIPMENT_ID: String = "thorned_loincloth"


## The 6 escalating stages (tokens of the token sheet): Zombie Temp 1/1, Zombie Rat 2/2, Patchwork Body 2/2, Compost Golem 3/3,
## Hungry Ghost 1/1 Flying, and Compost Golem again (the cap - every activation past the 6th re-summons the last stage). Softer than
## the first tuning pass - see docs/balance_report.md/D-log.
static func summon_stages() -> Array[CardData]:
	var stages: Array[CardData] = []
	for id: String in ["T-10", "T-11", "T-21", "T-17", "T-19", "T-17"]:
		stages.append(TokenRegistry.data(id))
	return stages


static func _escalation_modifier() -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.SCRIPTED_ESCALATING_SUMMON
	modifier.tokens = summon_stages()
	modifier.label = "The graveyard will not stay quiet"
	return modifier


static func _deck(content: ContentSet) -> Deck:
	return ZoneDecks.from_recipe(content, DISPLAY_NAME, DECK_RECIPE)


static func personality(content: ContentSet) -> AIPersonality:
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == AI_NAME:
			return candidate
	return AIPersonality.balanced()


## The enemy seat for the Graveyard duel: their thin dark deck, STARTING_LIFE, and the
## escalating-summon modifier that makes this fight what it is.
static func enemy_setup(content: ContentSet) -> PlayerSetup:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "The Restless Cairn"
	source.source_kind = ModifierSource.SourceKind.DUNGEON
	source.modifiers = [_escalation_modifier()] as Array[Modifier]
	var setup: PlayerSetup = PlayerSetup.create(_deck(content), null, [source] as Array[ModifierSource], DISPLAY_NAME)
	setup.starting_hp = STARTING_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = STARTING_HP
	return setup


static func reward_equipment(content: ContentSet) -> EquipmentData:
	return content.equipment_piece(REWARD_EQUIPMENT_ID)
