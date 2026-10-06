class_name ResourceKind
extends RefCounted
## The five Resources (Design Guidance): token permanents that live in their own zone per player.
## Iron (Beefcake), Red Tape (Necrocrat), Contract (Necrocrat), Ingredient (Gourmand), Garbage (Refusemancer).
## Iron, Red Tape and Contract have a built-in "pay 1, use one" ability; Ingredient and Garbage do nothing alone
## (cards spend them).

enum Kind { IRON, RED_TAPE, CONTRACT, INGREDIENT, GARBAGE }

const NONE: int = -1

## Card/token ids. Contract and Red Tape are listed in the token sheet (T-13, T-14); the other three are
## defined here because the sheet only describes them in the Design Guidance.
const IDS: Dictionary = {
	Kind.IRON: "RES-IRON",
	Kind.RED_TAPE: "T-14",
	Kind.CONTRACT: "T-13",
	Kind.INGREDIENT: "RES-INGREDIENT",
	Kind.GARBAGE: "RES-GARBAGE",
}

const NAMES: Dictionary = {
	Kind.IRON: "Iron",
	Kind.RED_TAPE: "Red Tape",
	Kind.CONTRACT: "Contract",
	Kind.INGREDIENT: "Ingredient",
	Kind.GARBAGE: "Garbage",
}

const PLURALS: Dictionary = {
	Kind.IRON: "Iron",
	Kind.RED_TAPE: "Red Tape",
	Kind.CONTRACT: "Contracts",
	Kind.INGREDIENT: "Ingredients",
	Kind.GARBAGE: "Garbage",
}

## The Path each resource belongs to (Contract is the second Necrocrat resource).
const PATHS: Dictionary = {
	Kind.IRON: Affinity.Type.BEEFCAKE,
	Kind.RED_TAPE: Affinity.Type.NECROCRAT,
	Kind.CONTRACT: Affinity.Type.NECROCRAT,
	Kind.INGREDIENT: Affinity.Type.GOURMAND,
	Kind.GARBAGE: Affinity.Type.REFUSEMANCER,
}

const DESCRIPTIONS: Dictionary = {
	Kind.IRON: "Pay 1 energy, use an Iron: target unit gets +1 attack permanently. Your turn only.",
	Kind.RED_TAPE: "Pay 1 energy, use a Red Tape: target unit gets -1 attack permanently. Your turn only.",
	Kind.CONTRACT: "Pay 1 energy, use a Contract: exhaust target unit. It doesn't refresh during its controller's next turn. Your turn only.",
	Kind.INGREDIENT: "Does nothing on its own. Spent by Gourmand cards (Cook, golems, recipes).",
	Kind.GARBAGE: "Does nothing on its own. Spent by Refusemancer cards (Eat Garbage).",
}

## Short tray labels / glyphs (the tray draws a coloured coin with this text).
const GLYPHS: Dictionary = {
	Kind.IRON: "Fe",
	Kind.RED_TAPE: "RT",
	Kind.CONTRACT: "Ct",
	Kind.INGREDIENT: "In",
	Kind.GARBAGE: "Gb",
}

const COLORS: Dictionary = {
	Kind.IRON: Color("e0a43a"),
	Kind.RED_TAPE: Color("d04a4a"),
	Kind.CONTRACT: Color("8fd1a0"),
	Kind.INGREDIENT: Color("e8d09a"),
	Kind.GARBAGE: Color("8fae52"),
}


static func all() -> Array[Kind]:
	var result: Array[Kind] = [Kind.IRON, Kind.RED_TAPE, Kind.CONTRACT, Kind.INGREDIENT, Kind.GARBAGE]
	return result


static func card_id(kind: Kind) -> String:
	return str(IDS[kind])


static func display_name(kind: Kind) -> String:
	return str(NAMES[kind])


static func path_of(kind: Kind) -> Affinity.Type:
	return PATHS[kind] as Affinity.Type


## True for the three resources that have their own "pay 1, use one" ability.
static func has_use_ability(kind: Kind) -> bool:
	return kind == Kind.IRON or kind == Kind.RED_TAPE or kind == Kind.CONTRACT


## The resource a basic Infrastructure of `path` creates when it enters, or NONE.
static func created_by_basic(path: Affinity.Type) -> int:
	match path:
		Affinity.Type.BEEFCAKE:
			return Kind.IRON
		Affinity.Type.NECROCRAT:
			return Kind.RED_TAPE
		Affinity.Type.GOURMAND:
			return Kind.INGREDIENT
		Affinity.Type.REFUSEMANCER:
			return Kind.GARBAGE
	return NONE


## The kind for a script word ("iron", "redtape", "red_tape", "contract", "ingredient", "garbage"), or NONE.
static func from_word(word: String) -> int:
	match word.to_lower().replace("-", "_").replace(" ", "_"):
		"iron":
			return Kind.IRON
		"redtape", "red_tape", "tape":
			return Kind.RED_TAPE
		"contract", "contracts":
			return Kind.CONTRACT
		"ingredient", "ingredients":
			return Kind.INGREDIENT
		"garbage":
			return Kind.GARBAGE
	return NONE


## The kind of a resource token card id ("RES-IRON", "T-14"...), or NONE.
static func from_card_id(id: String) -> int:
	for kind: Variant in IDS.keys():
		if str(IDS[kind]) == id:
			return int(kind)
	return NONE
