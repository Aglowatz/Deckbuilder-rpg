class_name PrimmBoss
extends RefCounted
## The final boss: Primm, "His Perfection" (Brief 10, Part D). An EXTREMELY challenging three-phase fight (balance is out of scope:
## the numbers are placeholders). The phases are three separate duels back to back on the same boss node, HP carrying over,
## with a cutscene between them (`CutsceneDefs`: primm_intro / primm_p1 / primm_p2 / primm_end).
##
##  1. STANDARDIZATION - he forces conformity: every unit (yours and his) has the same stats (3/3) and you may play at
##     most two non-infrastructure cards a turn ("Two Is the Perfect Number").
##  2. REFLECTION - he copies the player's cards: his deck is a copy of yours (he can only imitate, never create); he draws
##     an extra card each turn because he already knows what you hold.
##  3. UNRAVELING - his perfect rules break down: the arena cracks, his true selfishness shows. His units are stronger and he
##     draws more, but he loses 1 HP at the start of each of his turns as the rules he wrote stop working.
##
## THE LEADERS (Fable Nov 21 castle): a zone leader helps in all three phases when the player has won that leader's room in the castle
## in this run (`CastleAllies`: Flex joins the fight, the Grand Chef draws a card, Agnes cuts costs, Compostella strengthens units).
## All text: `data/story/capital_story.tres` (`boss.*`, `boon.<zone>.*`, `cutscene.primm_*`, `dungeon.primm_boss.*`).

const PHASES: int = 3
const STANDARD_ATTACK: int = 3
const STANDARD_DEFENSE: int = 3
const SPELL_CAP: int = 2
## Fable pass Nov 1 (boss tempo): each phase's setup window in turns (`BossTempo`).
const SETUP_TURNS: int = 2  # = BossTempo.DEFAULT_SETUP_TURNS (a const cannot reference another class here)
const UNRAVEL_HP_LOSS: int = 1
## Fable Nov 21 castle (Part 5.4): the cards in his opening hand, every phase (the normal hand is 5).
const OPENING_HAND: int = 8
## The enemy name of the boss node (the battle screen's title is the phase title).
const BOSS_FOE: String = "Primm"
const PHASE_KEYS: Array[String] = ["standardization", "reflection", "unraveling"]


class Phase:
	extends RefCounted
	var index: int = 0
	var key: String = ""
	var hp: int = 28
	var ai_name: String = "Balanced"
	## "Card ID -> copies" (BAS-x are the basic Infrastructure); empty when `mirror` (the player's deck is copied instead).
	var recipe: Dictionary = {}
	var mirror: bool = false
	var enemy_modifiers: Array[Modifier] = []
	var player_modifiers: Array[Modifier] = []
	var music: StringName = &"MUS-PRIMM-01"

	func title() -> String:
		return ZoneStoryText.for_zone(PrimmBoss.ZONE_ID).text("boss.phase.%s.title" % key)

	func rule_text() -> String:
		return ZoneStoryText.for_zone(PrimmBoss.ZONE_ID).text("boss.phase.%s.rule" % key)

const ZONE_ID: String = "final"


## The key of a phase's one-sided boss rules in data/encounters/modifiers.json ("Primm (standardization)"), on top of the phase's own rules.
static func rules_key(index: int) -> String:
	return "%s (%s)" % [BOSS_FOE, PHASE_KEYS[clampi(index, 0, PHASES - 1)]]


static func phase(index: int) -> Phase:
	var made: Phase = Phase.new()
	made.index = clampi(index, 0, PHASES - 1)
	# Each phase has its own music slot (MUS-PRIMM-01..03): the cue follows the actual phase, never a timer.
	made.music = StringName("MUS-PRIMM-%02d" % (made.index + 1))
	made.key = PHASE_KEYS[made.index]
	EncounterModifiers.ensure_setup_rule(rules_key(made.index), SETUP_TURNS)
	var hand: Modifier = _mod(Modifier.Kind.OPENING_HAND_SIZE, OPENING_HAND - PlayerProfile.new().base_opening_hand(), "A Full Desk")
	match made.index:
		0:
			made.hp = 40  # Fable Nov 21 castle (Part 6): 56 -> 40 (see docs/balance_report_nov21.md, section 5). Fable pass Nov 1: 44 -> 56 (100 % at L22 at the new HP curve; 83 % at 50 with 3 Militia). XP pass Oct 30: 40 -> 44. Oct 29: 36 -> 40 (the sequence was 82% with the L22 gear; Overnight Oct 18 Part 2: 100% at 30)
			made.ai_name = "Balanced"
			made.recipe = EnemyDecks.with_cards(EnemyDecks.mixed("colorless_regime", 30, [Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND] as Array[Affinity.Type], 12), {"C-30": 2, "C-32": 2})  # Overnight Oct 18 Part 2: 100% with 16 basics
			made.enemy_modifiers = [_mod(Modifier.Kind.STANDARDIZE_UNITS, STANDARD_ATTACK, "Standardization", STANDARD_DEFENSE)] as Array[Modifier]
			made.player_modifiers = [_mod(Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, SPELL_CAP, "Two Is the Perfect Number")] as Array[Modifier]
		1:
			made.hp = 46  # Fable Nov 21 castle (Part 6): 52 -> 46. Fable pass Nov 1: 42 -> 52 (and Boss skill, AIPlayer.SKILL_OVERRIDES: 100 % at 48 / Elite). XP pass Oct 30: 36 -> 42. Oct 29: 32 -> 36
			made.ai_name = "Balanced"
			made.mirror = true
			# Fable pass Nov 1: He Already Knows draws 2 extra (was 1; the mirror phase was 100 % at L22).
			made.enemy_modifiers = [_mod(Modifier.Kind.EXTRA_DRAWS, 1, "He Already Knows")] as Array[Modifier]
		_:
			made.hp = 44  # Fable Nov 21 castle (Part 6): 50 -> 44. Fable pass Nov 1: 42 -> 50. XP pass Oct 30: 36 -> 42. Oct 29: 32 -> 36 (Overnight Oct 18 Part 2: 83% at 28)
			made.ai_name = "Aggressive"
			made.recipe = EnemyDecks.with_cards(EnemyDecks.mixed("colorless_regime", 28, [Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT] as Array[Affinity.Type], 16), {"P4-03": 1, "P4-01": 1, "C-30": 2})
			made.enemy_modifiers = [
				_mod(Modifier.Kind.STAT_CHANGE, 2, "Everything He Cannot Control", 2),  # Fable pass Nov 1: +2/+2 -> +3/+3. XP pass Oct 30: +1/+1 -> +2/+2 (the sequence was 78 % at L22)
				_mod(Modifier.Kind.EXTRA_DRAWS, 1, "Panic"),
				_unraveling_effect(),
			] as Array[Modifier]
	if hand.value != 0:
		made.enemy_modifiers.append(hand)  # Fable Nov 21 castle (Part 5.4): he opens every phase with 8 cards (was 5)
	return made


static func _mod(kind: Modifier.Kind, value: int, label: String, value2: int = 0) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.value2 = value2
	modifier.label = label
	return modifier


## "As the rules he wrote stop working, he loses HP at the start of each of his turns."
static func _unraveling_effect() -> Modifier:
	var modifier: Modifier = _mod(Modifier.Kind.START_OF_TURN_EFFECT, 0, "The Rules Break Down")
	modifier.effect = CardBuilder.effect(CardEnums.Trigger.START_OF_TURN, CardEnums.TargetKind.CONTROLLER, CardEnums.EffectOp.LOSE_HP, UNRAVEL_HP_LOSS)
	return modifier


## Fable Nov 21 castle (Part 6), "A Plan for Everyone": he has prepared for each leader who walks in with you. For each of them he has
## `HP_PER_LEADER` more HP in every phase; to answer Grandmaster Flex (a unit on your side) he posts a guard (a Militia, T-16) at the
## start of every phase, and one more when all four leaders came. Without the plan the four leaders' help took the fight from about
## 1 win in 10 to 9 in 10, and Flex alone was worth as much as the other three together; the owner's targets are about 30 % alone and
## 65 % with all four (docs/balance_report_nov21.md, section 5).
const HP_PER_LEADER: int = 8
const PLAN_RULE_NAME: String = "A Plan for Everyone"
const FLEX_ZONE: String = "beefcake"


static func hp_for(index: int, leaders: int) -> int:
	return phase(index).hp + HP_PER_LEADER * clampi(leaders, 0, 4)


## The guards he posts at the start of each phase for these leaders (zone ids).
static func guards_for(zones: Array[String]) -> int:
	return (1 if zones.has(FLEX_ZONE) else 0) + (1 if zones.size() >= 4 else 0)


static func plan_text(zones: Array[String]) -> String:
	var words: String = "He has prepared for everyone who came with you: %d more HP in each phase for each leader at your side (+%d now)" % [HP_PER_LEADER, HP_PER_LEADER * mini(zones.size(), 4)]
	var guards: int = guards_for(zones)
	if guards == 1:
		words += ", and a Militia at the start of each phase to answer Grandmaster Flex"
	elif guards > 1:
		words += ", and %d Militia at the start of each phase (one to answer Grandmaster Flex, one because all four came)" % guards
	return words + "."


## The guards of the plan as a rule on his seat (null when he posts none).
static func plan_source(zones: Array[String]) -> ModifierSource:
	var count: int = guards_for(zones)
	var guard: CardData = TokenRegistry.data("T-16")
	if count <= 0 or guard == null:
		return null
	var posted: Modifier = _mod(Modifier.Kind.STARTING_UNITS, count, PLAN_RULE_NAME)
	posted.tokens = [guard] as Array[CardData]
	return CardBuilder.modifier_source(PLAN_RULE_NAME, ModifierSource.SourceKind.ZONE, [posted] as Array[Modifier])


## The seat for phase `index`: a mirror phase copies `player_deck` (his deck is yours), the others use their recipe. `content` is
## the card deck; enemy modifiers are added to the seat (the caller adds the Capital's debuffs).
static func enemy_setup(content: ContentSet, index: int, player_deck: Deck, leaders: Array[String] = [] as Array[String]) -> PlayerSetup:
	var stage: Phase = phase(index)
	stage.hp = hp_for(index, leaders.size())
	var deck: Deck
	if stage.mirror:
		deck = Deck.new()
		deck.deck_name = "A Perfect Copy"
		deck.cards = player_deck.cards.duplicate()
	else:
		deck = ZoneDecks.from_recipe(content, Villain.display_name(), stage.recipe)
	var setup: PlayerSetup = PlayerSetup.create(deck, null, [] as Array[ModifierSource], Villain.display_name())
	setup.starting_hp = stage.hp
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = stage.hp
	setup.modifiers.add_source(CardBuilder.modifier_source("Primm: %s" % stage.key, ModifierSource.SourceKind.ZONE, stage.enemy_modifiers))
	var plan: ModifierSource = plan_source(leaders)
	if plan != null:
		setup.modifiers.add_source(plan)
	return setup


## The rule source for the PLAYER in phase `index` (null when the phase restricts nothing).
static func player_rules(index: int) -> ModifierSource:
	var stage: Phase = phase(index)
	if stage.player_modifiers.is_empty():
		return null
	return CardBuilder.modifier_source("Primm: %s" % stage.key, ModifierSource.SourceKind.ZONE, stage.player_modifiers)


# ---- The leaders ------------------------------------------------------------------------------------------------------------------
# Fable Nov 21 castle (Part 3): the passive boons every freed leader lent at this door ("Grandmaster Flex's Heart", "The Grand Chef's
# Feast", "Agnes's Appeal", "Compostella's Roots") are gone. A leader helps when the player has won that leader's room in the castle in
# this run (`CastleAllies`): the help is added to the player's seat in each phase by `Session.make_dungeon_battle`.


## Zone id -> the freed leader.
const LEADERS: Dictionary = CastleAllies.LEADERS


## What is said at the Model Room's door: who stands with you in this run.
static func leader_lines(run: DungeonRun) -> Array[String]:
	return CastleAllies.door_lines(run)


## Fable Nov 15 (Part 4): the phase's own rules as a badge (the fight itself is unchanged). The phase's rule line was only the gold panel
## under the HUD; the "Before the fight" card and the rule icons did not list it. Named after the phase, its text the phase's rule line.
const PHASE_ICON: String = "delapouite/checklist"


static func phase_badge(index: int) -> RuleBadges.Badge:
	var stage: Phase = phase(index)
	var covered: Array[Modifier] = []
	covered.append_array(stage.enemy_modifiers)
	covered.append_array(stage.player_modifiers)
	if covered.is_empty():
		return null
	var badge: RuleBadges.Badge = RuleBadges.special(stage.title(), stage.rule_text(), PHASE_ICON, covered)
	badge.side = RuleBadges.SIDE_BOTH if not stage.player_modifiers.is_empty() else RuleBadges.SIDE_ENEMY
	return badge
