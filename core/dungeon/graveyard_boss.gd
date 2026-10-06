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
	"infrastructure:D": 20, "bone_servant": 3, "grave_tender": 3, "martyr": 1, "soul_drain": 1,
}
const AI_NAME: String = "Defensive"
const REWARD_GOLD: int = 220
const REWARD_XP: int = 150
## New brief, Part F: "a strong one-time reward... and something notable" - Thorned Loincloth
## (advanced armor, punishes every attacker for 1 whenever they attack you) both fits the fight
## thematically (surviving a horde by making the horde hurt itself) and is otherwise locked behind
## the level-10 equipment-vendor reward (D94) or 280 gold - this fight is a real, earlier way in.
const REWARD_EQUIPMENT_ID: String = "thorned_loincloth"


## The 6 escalating stages: 1/1, 2/2, 3/3, 3/4 Bulldoze, 4/4 Flying, 4/5 Flying (the cap -
## every activation past the 6th re-summons this one). Named individually rather than numbered so
## a real battle log/board reads like a story, not a debug dump. Softer past stage 2 than the
## first tuning pass (which capped at 6/6 Flying+Bulldoze) - see docs/balance_report.md/D-log.
static func summon_stages() -> Array[CardData]:
	var trample: Array[CardEnums.Keyword] = [CardEnums.Keyword.BULLDOZE]
	var flying: Array[CardEnums.Keyword] = [CardEnums.Keyword.FLYING]
	return [
		CardBuilder.token("grave_stage_0", "Restless Bone", 1, 1),
		CardBuilder.token("grave_stage_1", "Grave Wight", 2, 2),
		CardBuilder.token("grave_stage_2", "Crypt Sentinel", 3, 3),
		CardBuilder.token("grave_stage_3", "Bone Colossus", 3, 4, trample),
		CardBuilder.token("grave_stage_4", "Grave Wraith", 4, 4, flying),
		CardBuilder.token("grave_stage_5", "The Devourer", 4, 5, flying),
	] as Array[CardData]


static func _escalation_modifier() -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.SCRIPTED_ESCALATING_SUMMON
	modifier.tokens = summon_stages()
	modifier.label = "The graveyard will not stay quiet"
	return modifier


static func _deck(content: ContentSet) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = DISPLAY_NAME
	for key: Variant in DECK_RECIPE.keys():
		var id: String = str(key)
		var card: CardData = null
		if id.begins_with("infrastructure:"):
			var color: Affinity.Type = ["", "A", "B", "C", "D"].find(id.substr(15)) as Affinity.Type
			card = content.infrastructure[int(color)] as CardData
		else:
			card = content.card(id)
		if card == null:
			push_warning("GraveyardBoss: unknown card %s" % id)
			continue
		for i: int in range(int(DECK_RECIPE[key])):
			deck.cards.append(card)
	return deck


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
