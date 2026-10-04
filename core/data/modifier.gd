class_name Modifier
extends Resource
## One entry in the unified modifier pipeline. Equipment, items, zones, dungeon effects and
## boons all produce Modifiers; the engine only ever reads a ModifierSet.

enum Kind {
	## value = flat change to max life.
	MAX_LIFE,
	## value = flat change to life at the start of a duel (may exceed max life).
	STARTING_LIFE,
	## value = flat change to max hand size.
	MAX_HAND_SIZE,
	## value = flat change to opening hand size.
	OPENING_HAND_SIZE,
	## value = change to generic cost of matching non-infrastructure cards (min cost 0).
	COST_CHANGE,
	## value = power delta, value2 = toughness delta for matching creatures.
	STAT_CHANGE,
	## value = extra infrastructure/color types allowed in the deck.
	MAX_DECK_COLORS,
	## value = extra cards drawn in each draw step.
	EXTRA_DRAWS,
	## value = flat change to how many face-down traps may be set at once.
	MAX_TRAPS,
	## `effect` resolves for the owner when their combat phase begins.
	START_OF_COMBAT_EFFECT,
	## value = flat change to the minimum legal deck size (may be negative). Used to waive the
	## normal minimum while a starter deck is still being filled out (e.g. the tutorial dungeon).
	MIN_DECK_SIZE,
	## New brief, Part B: `effect` resolves for the owner when their turn begins (after the draw
	## step's triggers, alongside START_OF_TURN card triggers). Equipment equivalent of
	## START_OF_COMBAT_EFFECT but for the turn as a whole (e.g. Flamethrower).
	START_OF_TURN_EFFECT,
	## New brief, Part B: presence (any value) means this player always goes first, overriding the
	## normal coin flip - `GameOptions.first_player`, when explicitly set, still wins over this.
	## If both players somehow have it, falls back to the coin flip (see D-log).
	ALWAYS_FIRST,
	## New brief, Part B: value = extra cards drawn (on top of the normal turn-1 draw, which may
	## be 0 for whoever goes first) on a player's own first turn only, never again.
	FIRST_TURN_EXTRA_DRAW,
	## New brief, Part B: value = a CardEnums.Keyword ordinal granted to every creature the owner
	## controls, applied once when it enters the battlefield (equipment doesn't change mid-duel,
	## so this doesn't need to be recomputed continuously). `color` may restrict it like
	## STAT_CHANGE; ANY_COLOR means every creature.
	GRANT_KEYWORD_TO_CREATURES,
	## New brief, Part B: presence means every creature the owner controls can never be declared
	## as a blocker (applied once on entering the battlefield, same timing as the grant above).
	CANNOT_BLOCK,
	## New brief, Part B: value = the smallest cap (if several apply) on how many non-infrastructure cards
	## the owner may cast in one turn. Absent (no such modifier) means unlimited.
	MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN,
	## New brief, Part B: presence means the owner sees the opponent's hand face-up in the UI.
	## Never reveals set traps - see `docs/design/open_questions.md` D91/D92.
	REVEAL_OPPONENT_HAND,
	## New brief, Part B: `effect` resolves once against every declared attacker (TargetKind
	## .ALL_ATTACKERS), right after traps, whenever an opponent declares attackers against the
	## owner - regardless of whether those attackers are blocked or connect.
	RETALIATE_ON_ATTACK,
	## New brief, Part F: a reusable scripted-encounter rule ("at the start of each of the
	## opponent's turns, summon an increasingly powerful creature") - `tokens` is the ordered
	## escalation (stage 0 first, then 1, 2, ...); once past the last stage, every further
	## activation re-summons the last (strongest) one, so the escalation never actually stops.
	## Fires once per the owner's turn, right alongside START_OF_TURN_EFFECT - see
	## `PlayerState.scripted_summon_count` and `GameState._fire_scripted_summons`.
	SCRIPTED_ESCALATING_SUMMON,
	## Brief 8, Part C: `effect` resolves for the owner at the end of each of their own turns (after the end-of-turn
	## card triggers), e.g. the Compliance Clipboard.
	END_OF_TURN_EFFECT,
	## Brief 8, Part C: `effect` resolves for the owner every time a creature enters the battlefield under their
	## control (cast or summoned), e.g. the Spotter's Barbell.
	ON_CREATURE_ENTER_EFFECT,
	## Brief 8, Part C: value = extra life gained every time the owner gains life from a card effect or item
	## (only when some life is gained), e.g. the Head Chef's Toque.
	LIFE_GAIN_BONUS,
	## Brief 8, Part C: `effect` resolves for the owner every time one of THEIR creatures dies, e.g. the Compost Boots.
	ON_ALLY_DEATH_EFFECT,
	## Brief 9, Part C: creatures of a matching `color` (ANY_COLOR = every creature) enter the battlefield
	## exhausted (they cannot block until their controller's next ready step) - the Gainlands' "Processing
	## Time" debuff on Necrocrat creatures.
	ENTER_EXHAUSTED,
	## Brief 9, Part G (the Arena): `effect` resolves for the owner once, when the duel starts (after the
	## mulligans, before turn 1), e.g. the Champion's Laurels.
	START_OF_DUEL_EFFECT,
	## Part G: `effect` resolves for the owner every time THEY declare attackers (once per declaration), e.g. the
	## Crowd-Pleaser's Cape.
	ON_ATTACK_DECLARED_EFFECT,
	## Part G: `effect` resolves for the owner whenever an ENEMY creature enters the battlefield; its target
	## kind TRIGGERING_CARD means that creature, e.g. the Gladiator's Net.
	ON_ENEMY_CREATURE_ENTER_EFFECT,
	## Part G: `effect` resolves for the owner whenever they are dealt damage (not mere life loss), e.g. the
	## Bloodsand Boots.
	ON_PLAYER_DAMAGED_EFFECT,
	## Part G (a rule, not gear): presence means the owner may not cast creature cards (the Arena's "win without
	## casting creatures" puzzle).
	NO_CREATURE_CASTS,
}

## `color` value meaning "matches every card".
const ANY_COLOR: int = -1

@export var kind: Kind = Kind.MAX_LIFE
@export var value: int = 0
@export var value2: int = 0
## An Affinity.Type value, or ANY_COLOR.
@export var color: int = ANY_COLOR
@export var effect: EffectData
@export var label: String = ""
## New brief, Part F: SCRIPTED_ESCALATING_SUMMON's ordered token stages.
@export var tokens: Array[CardData] = []


func matches_color(card_color: Affinity.Type) -> bool:
	return color == ANY_COLOR or color == int(card_color)


## Whether this modifier applies to `card`: a multi-Path card is on both its Paths, so it receives every
## modifier (buff or debuff) aimed at either of them.
func matches_card(card: CardData) -> bool:
	return color == ANY_COLOR or card.is_on_path(color as Affinity.Type)
