class_name Affinity
extends RefCounted
## Single source of truth for the four Paths (colors). The enum members stay A-D; to rename a Path for
## players, edit DISPLAY_NAMES only - code always uses the enum.
## A = Beefcake (Gainlands), B = Gourmand (Endless Buffet), C = Refusemancer (Verdant Dump),
## D = Necrocrat (D.N.A.).

enum Type { NEUTRAL, A, B, C, D }

const DISPLAY_NAMES: Dictionary = {
	Type.NEUTRAL: "Neutral",
	Type.A: "Beefcake",
	Type.B: "Gourmand",
	Type.C: "Refusemancer",
	Type.D: "Necrocrat",
}


static func display_name(type: Type) -> String:
	return str(DISPLAY_NAMES.get(type, "Unknown"))


## The four real (non-neutral) infrastructure types.
static func colored_types() -> Array[Type]:
	var result: Array[Type] = [Type.A, Type.B, Type.C, Type.D]
	return result
