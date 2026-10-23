class_name AIProfiles
extends RefCounted
## Battle AI upgrade, Part 3 (Oct 23): Path personalities and boss signatures as data. `blend` reads a seat's deck (every non-infrastructure
## card in deck, hand, field and Refuse Pile) and nudges a copy of the base personality toward the Paths it finds, in proportion to
## their share, so a Necrocrat/Gourmand foe plays a mix of both. The identities follow data/source/design_guidance.csv:
## - Beefcake: aggressive and bursty - presses the race, spends Iron, values attack over defense, fears the crack-back less.
## - Necrocrat: orderly and grindy - goes wide with tokens, keeps Red Tape and Contracts for the biggest threat, values cards.
## - Gourmand: defensive and controlling - values HP and high defense, blocks, cooks Ingredients, races less.
## - Refusemancer: resilient - Garbage is fuel, ramps, hates the foe's Tools and Wonders, spends HP for value.
## Signatures (`AIPersonality.signature`) are short board-driven adjustments for bosses, applied every turn by `apply_signature`.

const PROFILES: Dictionary = {
	Affinity.Type.BEEFCAKE: {
		"attack_bias": 0.5, "race_weight": 0.8, "enemy_hp_weight": 0.3, "threat_weight": -0.2, "attack_value": 0.2,
		"iron_hold_value": -0.25, "hp_weight": -0.1,
	},
	Affinity.Type.NECROCRAT: {
		"width_weight": 0.4, "red_tape_hold_value": 0.3, "threat_weight": 0.15, "hand_weight": 0.2, "board_weight": 0.1,
	},
	Affinity.Type.GOURMAND: {
		"hp_weight": 0.3, "defense_value": 0.3, "threat_weight": 0.3, "attack_bias": -0.3, "fuel_value": 0.4, "block_bias": 0.3,
		"race_weight": -0.3,
	},
	Affinity.Type.REFUSEMANCER: {
		"fuel_value": 0.4, "energy_weight": 0.3, "artifact_weight": 0.6, "hp_weight": -0.1, "width_weight": 0.2,
	},
}

const PROFILE_NAMES: Dictionary = {
	"beefcake": Affinity.Type.BEEFCAKE, "necrocrat": Affinity.Type.NECROCRAT, "gourmand": Affinity.Type.GOURMAND, "refusemancer": Affinity.Type.REFUSEMANCER,
}


## The share of each colored Path among a seat's non-infrastructure cards (sums to 1.0; empty for a colorless deck).
static func path_mix(state: GameState, who: int) -> Dictionary:
	var counts: Dictionary = {}
	var total: int = 0
	var player: PlayerState = state.players[who]
	for pile: Array[CardInstance] in [player.deck, player.hand, player.field, player.refuse_pile, player.traps]:
		for card: CardInstance in pile:
			if card.data.is_infrastructure() or card.data.is_token:
				continue
			for path: Affinity.Type in card.data.paths():
				if path == Affinity.Type.NEUTRAL:
					continue
				counts[path] = int(counts.get(path, 0)) + 1
				total += 1
	var mix: Dictionary = {}
	for path: Variant in counts.keys():
		mix[path] = float(counts[path]) / float(maxi(1, total))
	return mix


## A working copy of `base` nudged toward the Paths in `mix` ({Affinity.Type: share}). A share below 0.15 is ignored (a splash).
static func blend(base: AIPersonality, mix: Dictionary) -> AIPersonality:
	var made: AIPersonality = base.duplicate_personality()
	for path: Variant in mix.keys():
		var share: float = float(mix[path])
		if share < 0.15 or not PROFILES.has(path):
			continue
		var deltas: Dictionary = PROFILES[path] as Dictionary
		for key: Variant in deltas.keys():
			var property: String = str(key)
			made.set(property, float(made.get(property)) + float(deltas[key]) * share)
	made.attack_value = maxf(0.5, made.attack_value)
	made.defense_value = maxf(0.5, made.defense_value)
	made.fuel_value = maxf(0.2, made.fuel_value)
	return made


## The mix a personality asks for: "auto" reads the deck, a Path name is that Path alone, "none" keeps the base weights.
static func mix_for(personality: AIPersonality, state: GameState, who: int) -> Dictionary:
	var wanted: String = personality.path_profile.to_lower()
	if wanted == "none":
		return {}
	if PROFILE_NAMES.has(wanted):
		return {PROFILE_NAMES[wanted]: 1.0}
	return path_mix(state, who)


## Boss signatures: short, readable habits on top of the Path profile, recomputed each turn from the board. `working` is the
## blended personality of the seat (mutated in place); `rest` holds the blended values to reset from.
static func apply_signature(signature: String, working: AIPersonality, rest: AIPersonality, state: GameState, who: int) -> void:
	working.attack_bias = rest.attack_bias
	working.block_bias = rest.block_bias
	working.race_weight = rest.race_weight
	working.red_tape_hold_value = rest.red_tape_hold_value
	working.threat_weight = rest.threat_weight
	var mine: PlayerState = state.players[who]
	var foe: PlayerState = state.players[1 - who]
	match signature:
		"all_in":
			# Presses hard once its board is at least as wide as the foe's, or the foe is at 8 HP or less.
			if mine.units().size() >= foe.units().size() or foe.hp <= 8:
				working.attack_bias = rest.attack_bias + 1.0
				working.race_weight = rest.race_weight + 1.0
		"patience":
			# Builds a board first (the Restless Dead's summons keep coming): no attacks until three units stand, then everything.
			if mine.units().size() < 3:
				working.attack_bias = rest.attack_bias - 3.0
			else:
				working.attack_bias = rest.attack_bias + 0.5
		"trickster":
			# Loves a set trap and attacks into open boards; hates blocking.
			working.block_bias = rest.block_bias - 0.5
			working.attack_bias = rest.attack_bias + (0.6 if not mine.traps.is_empty() else 0.0)
		"paperwork":
			# Red Tape is for using: every turn the biggest attacker of the foe gets taped.
			working.red_tape_hold_value = 0.2
			working.threat_weight = rest.threat_weight + 0.3
		"fortress":
			# Never races: blocks, heals, and attacks only when the foe cannot answer.
			working.block_bias = rest.block_bias + 0.8
			working.attack_bias = rest.attack_bias - 0.5
			working.race_weight = maxf(0.3, rest.race_weight - 0.8)
