class_name Affinity
extends RefCounted
## Single source of truth for the four Paths. Energy symbols: (B) Beefcake, (N) Necrocrat, (G) Gourmand,
## (R) Refusemancer. The enum order is stored in saves and .tres files (Beefcake = Gainlands, Gourmand =
## Endless Buffet, Refusemancer = Verdant Dump, Necrocrat = D.N.A.), so only ever append.

enum Type { NEUTRAL, BEEFCAKE, GOURMAND, REFUSEMANCER, NECROCRAT }

const DISPLAY_NAMES: Dictionary = {
	Type.NEUTRAL: "Colorless",
	Type.BEEFCAKE: "Beefcake",
	Type.GOURMAND: "Gourmand",
	Type.REFUSEMANCER: "Refusemancer",
	Type.NECROCRAT: "Necrocrat",
}

## The energy symbol letter used in costs, e.g. "(B)".
const SYMBOLS: Dictionary = {
	Type.NEUTRAL: "",
	Type.BEEFCAKE: "B",
	Type.GOURMAND: "G",
	Type.REFUSEMANCER: "R",
	Type.NECROCRAT: "N",
}


static func display_name(type: Type) -> String:
	return str(DISPLAY_NAMES.get(type, "Unknown"))


static func symbol(type: Type) -> String:
	return str(SYMBOLS.get(type, ""))


## The Path for an energy symbol letter ("B", "N", "G", "R"), or NEUTRAL.
static func from_symbol(letter: String) -> Type:
	for type: Variant in SYMBOLS.keys():
		if str(SYMBOLS[type]) == letter.to_upper() and letter != "":
			return int(type) as Type
	return Type.NEUTRAL


## The four real (non-neutral) Paths.
static func colored_types() -> Array[Type]:
	var result: Array[Type] = [Type.BEEFCAKE, Type.GOURMAND, Type.REFUSEMANCER, Type.NECROCRAT]
	return result
