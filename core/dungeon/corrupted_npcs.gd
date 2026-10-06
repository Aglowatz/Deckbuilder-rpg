class_name CorruptedNpcs
extends RefCounted
## New brief, Part E: the 4 corrupted NPCs in town, one per element zone. Single source of truth
## for their deck/HP/AI/reward - `world/town_scene.gd` handles placement, dialogue and the
## battle flow; dialogue text itself lives in `data/story/corrupted_npcs_story.tres`
## (`CorruptedNpcStory`), not here, per the brief ("keep all dialogue in the story data file").
##
## Ids match `ZonePortals` ids (beefcake/gourmand/refusemancer/necrocrat) - defeating one sets that same zone's
## unlock flag (`TownScene._portal_unlock_flag`), per the Part C contract (D66).

const IDS: Array[String] = ["beefcake", "gourmand", "refusemancer", "necrocrat"]
const STARTING_HP: int = 15

const DISPLAY_NAMES: Dictionary = {
	"beefcake": "Torvin the Over-Pumped", "gourmand": "Maris the Over-Seasoned",
	"refusemancer": "Old Thistlebark the Over-Composted", "necrocrat": "Corwyn the Filed-Away",
}
## Which AIPersonality (by name, see core/ai/ai_personality.gd) plays each - matched to their
## element identity (aggressive Beefcake, defensive Gourmand, patient/growing Refusemancer, opportunistic Necrocrat).
const AI_NAMES: Dictionary = {
	"beefcake": "Aggressive", "gourmand": "Defensive", "refusemancer": "Passive", "necrocrat": "Balanced",
}
## Reward item per NPC (Part D/F's small item pool) - thematically matched. Only 3 items exist
## before Part F; Necrocrat reuses Gourmand's (a real item pool arrives in Part F).
const REWARD_ITEMS: Dictionary = {
	"beefcake": "reckless_tonic", "gourmand": "healing_draught", "refusemancer": "vitality_charm",
	"necrocrat": "healing_draught",
}


## The single source of truth for "has this corrupted NPC been defeated" - the same flag Part C's
## zone entrances check to unlock (TownScene._portal_unlock_flag delegates here; see D66/D68).
static func unlock_flag(id: String) -> StringName:
	return StringName("%s_zone_unlocked" % id)


static func element(id: String) -> Affinity.Type:
	match id:
		"beefcake":
			return Affinity.Type.BEEFCAKE
		"gourmand":
			return Affinity.Type.GOURMAND
		"refusemancer":
			return Affinity.Type.REFUSEMANCER
		"necrocrat":
			return Affinity.Type.NECROCRAT
	return Affinity.Type.NEUTRAL


static func display_name(id: String) -> String:
	return str(DISPLAY_NAMES.get(id, "A Corrupted Wanderer"))


## One deck per Path (Card ID -> copies; see `EnemyDecks`) - see
## docs/balance_report.md for how these were tuned against a typical level-3 player deck.
static func recipe(id: String) -> Dictionary:
	match id:
		"beefcake":
			return EnemyDecks.trimmed("beefcake_rush", 26, 16)
		"gourmand":
			return EnemyDecks.trimmed("gourmand_control", 26, 16)
		"refusemancer":
			return EnemyDecks.trimmed("refuse_garbage", 27, 17)
		"necrocrat":
			return EnemyDecks.trimmed("necro_control", 26, 16)
	return {}


## Builds a Deck from a recipe (Card ID -> copies).
static func _deck_from_recipe(content: ContentSet, deck_name: String, deck_recipe: Dictionary) -> Deck:
	return ZoneDecks.from_recipe(content, deck_name, deck_recipe)


static func deck(content: ContentSet, id: String) -> Deck:
	return _deck_from_recipe(content, display_name(id), recipe(id))


static func personality(content: ContentSet, id: String) -> AIPersonality:
	var wanted: String = str(AI_NAMES.get(id, "Balanced"))
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == wanted:
			return candidate
	return AIPersonality.balanced()


## The enemy seat for a corrupted-NPC duel: their mono-color deck, STARTING_LIFE (15).
static func enemy_setup(content: ContentSet, id: String) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(deck(content, id), null, [] as Array[ModifierSource], display_name(id))
	setup.starting_hp = STARTING_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = STARTING_HP
	return setup


## Reward for defeating `id` the first time - reuses the existing difficulty-scaled table
## (Elite tier: a corrupted NPC with a real curated deck and 15 HP is a real fight, not a
## throwaway encounter).
static func reward_gold() -> int:
	return EncounterRewards.gold_for(DungeonMap.Difficulty.ELITE)


static func reward_xp() -> int:
	return EncounterRewards.xp_for(DungeonMap.Difficulty.ELITE)


static func reward_item(content: ContentSet, id: String) -> ItemData:
	return content.item(str(REWARD_ITEMS.get(id, "")))


## New brief, Part E balance target: a "typical level-3 player deck" (the 42-card starter plus 3
## on-element picks, roughly what 3 tutorial-battle rewards would add) for each of the 4 starting
## elements - used only by the balance simulation (tools/run_corrupted_npc_simulation.gd), not by
## real gameplay (a real player's actual deck is whatever they built).
const REFERENCE_EXTRA_PICKS: Dictionary = {
	Affinity.Type.BEEFCAKE: ["B-06", "B-24", "B-14"],
	Affinity.Type.GOURMAND: ["G-05", "G-07", "G-17"],
	Affinity.Type.REFUSEMANCER: ["R-07", "R-22", "R-26"],
	Affinity.Type.NECROCRAT: ["N-06", "N-26", "N-23"],
}


static func reference_player_deck(content: ContentSet, color: Affinity.Type) -> Deck:
	var deck_result: Deck = CampaignStart.starter_deck(content, color)
	deck_result.deck_name = "Level-3 %s reference" % Affinity.display_name(color)
	for id: Variant in REFERENCE_EXTRA_PICKS.get(color, []):
		deck_result.cards.append(content.card(str(id)))
	return deck_result
