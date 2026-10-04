class_name Affinity
extends RefCounted
## Single source of truth for infrastructure/color types.
## To rename a type for players, edit DISPLAY_NAMES only; code always uses the enum.

enum Type { NEUTRAL, A, B, C, D }

const DISPLAY_NAMES: Dictionary = {
	Type.NEUTRAL: "Neutral",
	Type.A: "Affinity A",
	Type.B: "Affinity B",
	Type.C: "Affinity C",
	Type.D: "Affinity D",
}


static func display_name(type: Type) -> String:
	return str(DISPLAY_NAMES.get(type, "Unknown"))


## The four real (non-neutral) infrastructure types.
static func colored_types() -> Array[Type]:
	var result: Array[Type] = [Type.A, Type.B, Type.C, Type.D]
	return result
