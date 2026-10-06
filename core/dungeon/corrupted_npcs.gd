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


## Mono-color deck recipes (card id, or "infrastructure:<A|B|C|D>", -> copies) - see
## docs/balance_report.md for how these were tuned against a typical level-3 player deck.
static func recipe(id: String) -> Dictionary:
	match id:
		"beefcake":
			return {
				"infrastructure:A": 16, "beefcake_imp": 2, "blade_dancer": 2, "raider": 2,
				"blazing_charger": 1, "firebolt": 2, "flame_burst": 1, "warcry": 1,
			}
		"gourmand":
			return {
				"infrastructure:B": 16, "frost_sentry": 3, "sage": 2, "whispering_shade": 2,
				"sea_warden": 1, "deep_insight": 1, "dissolve": 2, "snare": 1,
			}
		"refusemancer":
			return {
				"infrastructure:C": 17, "mossback_bear": 2, "rampaging_boar": 1, "stag_warden": 2,
				"thornback_colossus": 1, "growth": 1, "rejuvenate": 1,
			}
		"necrocrat":
			return {
				"infrastructure:D": 16, "bone_servant": 2, "martyr": 2, "grave_tender": 2,
				"bloodthirst_wolf": 2, "necromancer": 2, "soul_drain": 1, "dark_bargain": 1,
			}
	return {}


## Builds a Deck from a recipe (same "id, or infrastructure:<color>, -> copies" convention as
## TrialOfTheHollow.enemy_deck).
static func _deck_from_recipe(content: ContentSet, deck_name: String, deck_recipe: Dictionary) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = deck_name
	for key: Variant in deck_recipe.keys():
		var id: String = str(key)
		var card: CardData = null
		if id.begins_with("infrastructure:"):
			var color: Affinity.Type = ["", "A", "B", "C", "D"].find(id.substr(15)) as Affinity.Type
			card = content.infrastructure[int(color)] as CardData
		else:
			card = content.card(id)
		if card == null:
			push_warning("CorruptedNpcs: unknown card %s" % id)
			continue
		for i: int in range(int(deck_recipe[key])):
			deck.cards.append(card)
	return deck


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
	Affinity.Type.BEEFCAKE: ["blade_dancer", "raider", "blazing_charger"],
	Affinity.Type.GOURMAND: ["frost_sentry", "sage", "sea_warden"],
	Affinity.Type.REFUSEMANCER: ["mossback_bear", "stag_warden", "ancient_treant"],
	Affinity.Type.NECROCRAT: ["bone_servant", "grave_tender", "necromancer"],
}


static func reference_player_deck(content: ContentSet, color: Affinity.Type) -> Deck:
	var deck_result: Deck = CampaignStart.starter_deck(content, color)
	deck_result.deck_name = "Level-3 %s reference" % Affinity.display_name(color)
	for id: Variant in REFERENCE_EXTRA_PICKS.get(color, []):
		deck_result.cards.append(content.card(str(id)))
	return deck_result
