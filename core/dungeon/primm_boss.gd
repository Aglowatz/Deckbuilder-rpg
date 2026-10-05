class_name PrimmBoss
extends RefCounted
## The final boss: Primm, "His Perfection" (Brief 10, Part D). An EXTREMELY challenging three-phase fight (balance is out of scope:
## the numbers are placeholders). The phases are three separate duels back to back on the same boss node, life carrying over,
## with a cutscene between them (`CutsceneDefs`: primm_intro / primm_p1 / primm_p2 / primm_end).
##
##  1. STANDARDIZATION - he forces conformity: every creature (yours and his) has the same stats (3/3) and you may cast at
##     most two non-infrastructure cards a turn ("Two Is the Perfect Number").
##  2. REFLECTION - he copies the player's cards: his deck is a copy of yours (he can only imitate, never create); he draws
##     an extra card each turn because he already knows what you hold.
##  3. UNRAVELING - his perfect rules break down: the arena cracks, his true selfishness shows. His creatures are stronger and he
##     draws more, but he loses 1 life at the start of each of his turns as the rules he wrote stop working.
##
## FREED LEADERS lend a boon: for every completed Path zone, that zone's freed leader (Heartlift, Aurelio, Vellum, Fernwick) stands
## beside you when the boss is entered and adds a dungeon-wide boon (`leader_boon`) for the fight.
## All text: `data/story/capital_story.tres` (`boss.*`, `boon.<zone>.*`, `cutscene.primm_*`, `dungeon.primm_boss.*`).

const PHASES: int = 3
const STANDARD_POWER: int = 3
const STANDARD_TOUGHNESS: int = 3
const SPELL_CAP: int = 2
const UNRAVEL_LIFE_LOSS: int = 1
## The enemy name of the boss node (the battle screen's title is the phase title).
const BOSS_FOE: String = "Primm"
const PHASE_KEYS: Array[String] = ["standardization", "reflection", "unraveling"]


class Phase:
	extends RefCounted
	var index: int = 0
	var key: String = ""
	var life: int = 28
	var ai_name: String = "Balanced"
	## "id or infrastructure:X -> copies"; empty when `mirror` (the player's deck is copied instead).
	var recipe: Dictionary = {}
	var mirror: bool = false
	var enemy_modifiers: Array[Modifier] = []
	var player_modifiers: Array[Modifier] = []
	var music: StringName = &"primm"

	func title() -> String:
		return ZoneStoryText.for_zone(PrimmBoss.ZONE_ID).text("boss.phase.%s.title" % key)

	func rule_text() -> String:
		return ZoneStoryText.for_zone(PrimmBoss.ZONE_ID).text("boss.phase.%s.rule" % key)

const ZONE_ID: String = "final"


static func phase(index: int) -> Phase:
	var made: Phase = Phase.new()
	made.index = clampi(index, 0, PHASES - 1)
	made.key = PHASE_KEYS[made.index]
	match made.index:
		0:
			made.life = 30
			made.ai_name = "Balanced"
			made.recipe = {
				"infrastructure:D": 8, "infrastructure:B": 8, "primm_perfect_citizen": 5, "primm_standard_issue": 4, "citation": 3,
				"decree_of_order": 3, "compliance_officer": 3, "perfection_inspector": 2,
			}
			made.enemy_modifiers = [_mod(Modifier.Kind.STANDARDIZE_CREATURES, STANDARD_POWER, "Standardization", STANDARD_TOUGHNESS)] as Array[Modifier]
			made.player_modifiers = [_mod(Modifier.Kind.MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN, SPELL_CAP, "Two Is the Perfect Number")] as Array[Modifier]
		1:
			made.life = 32
			made.ai_name = "Balanced"
			made.mirror = true
			made.enemy_modifiers = [_mod(Modifier.Kind.EXTRA_DRAWS, 1, "He Already Knows")] as Array[Modifier]
		_:
			made.life = 28
			made.ai_name = "Aggressive"
			made.recipe = {
				"infrastructure:A": 4, "infrastructure:B": 4, "infrastructure:C": 4, "infrastructure:D": 4, "primm_correction": 4,
				"primm_perfect_citizen": 4, "approved_gate_captain": 2, "decree_of_order": 4, "citation": 4, "hr_reaper": 2, "moss_titan": 2,
			}
			made.enemy_modifiers = [
				_mod(Modifier.Kind.STAT_CHANGE, 1, "Everything He Cannot Control", 1),
				_mod(Modifier.Kind.EXTRA_DRAWS, 1, "Panic"),
				_unraveling_effect(),
			] as Array[Modifier]
	return made


static func _mod(kind: Modifier.Kind, value: int, label: String, value2: int = 0) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.value2 = value2
	modifier.label = label
	return modifier


## "As the rules he wrote stop working, he loses life at the start of each of his turns."
static func _unraveling_effect() -> Modifier:
	var modifier: Modifier = _mod(Modifier.Kind.START_OF_TURN_EFFECT, 0, "The Rules Break Down")
	modifier.effect = CardBuilder.effect(CardEnums.Trigger.START_OF_TURN, CardEnums.TargetKind.CONTROLLER, CardEnums.EffectOp.LOSE_LIFE, UNRAVEL_LIFE_LOSS)
	return modifier


## The seat for phase `index`: a mirror phase copies `player_deck` (his deck is yours), the others use their recipe. `content` is
## the card library; enemy modifiers are added to the seat (the caller adds the Capital's debuffs).
static func enemy_setup(content: ContentSet, index: int, player_deck: Deck) -> PlayerSetup:
	var stage: Phase = phase(index)
	var deck: Deck
	if stage.mirror:
		deck = Deck.new()
		deck.deck_name = "A Perfect Copy"
		deck.cards = player_deck.cards.duplicate()
	else:
		deck = ZoneDecks.from_recipe(content, Villain.display_name(), stage.recipe)
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], Villain.display_name())
	setup.starting_life = stage.life
	setup.profile = PlayerProfile.new()
	setup.profile.max_life = stage.life
	setup.modifiers.add_source(CardBuilder.modifier_source("Primm: %s" % stage.key, ModifierSource.SourceKind.ZONE, stage.enemy_modifiers))
	return setup


## The rule source for the PLAYER in phase `index` (null when the phase restricts nothing).
static func player_rules(index: int) -> ModifierSource:
	var stage: Phase = phase(index)
	if stage.player_modifiers.is_empty():
		return null
	return CardBuilder.modifier_source("Primm: %s" % stage.key, ModifierSource.SourceKind.ZONE, stage.player_modifiers)


# ---- The freed leaders' boons --------------------------------------------------------------------------------------------------


## Zone id -> the freed leader who lends the boon.
const LEADERS: Dictionary = {
	"beefcake": "Heartlift", "gourmand": "Aurelio", "necrocrat": "Director Vellum", "refusemancer": "Fernwick",
}


## The boon `zone_id`'s freed leader lends for the fight (null for an unknown zone).
static func leader_boon(zone_id: String) -> ModifierSource:
	var story: ZoneStoryText = ZoneStoryText.for_zone(ZONE_ID)
	var name: String = story.text("boon.%s.name" % zone_id)
	var path: int = int(ZoneEffects.path_of(zone_id))
	var mods: Array[Modifier] = [CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 2)] as Array[Modifier]
	match zone_id:
		"beefcake":
			mods.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, path, 0))
		"gourmand":
			mods.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, path, 1))
			mods.append(CardBuilder.modifier(Modifier.Kind.LIFE_GAIN_BONUS, 1))
		"necrocrat":
			mods.append(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1, path))
		"refusemancer":
			mods.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, path, 2))
		_:
			return null
	return CardBuilder.modifier_source(name, ModifierSource.SourceKind.BOON, mods)


## The boons of every completed Path zone.
static func leader_boons(flags: Dictionary) -> Array[ModifierSource]:
	var result: Array[ModifierSource] = []
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		if ZoneCompletion.is_completed(flags, zone_id):
			var boon: ModifierSource = leader_boon(zone_id)
			if boon != null:
				result.append(boon)
	return result


## Story keys (in order) of what the freed leaders say as they join you.
static func leader_lines(flags: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var story: ZoneStoryText = ZoneStoryText.for_zone(ZONE_ID)
	var count: int = 0
	for zone_id: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
		if ZoneCompletion.is_completed(flags, zone_id):
			count += 1
			result.append_array(story.get_lines("boon.%s.line" % zone_id))
	if count == 0:
		result.append_array(story.get_lines("boon.none.line"))
	return result
