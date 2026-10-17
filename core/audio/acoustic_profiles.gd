class_name AcousticProfiles
extends RefCounted
## Per-place acoustics (docs/audio/sound_direction.md, "Space"): the reverb the World bus gives footsteps, doors and every other world sound, so the
## same boot sounds different in the open meadow, the stone plaza or the office halls. Values are Godot `AudioEffectReverb` settings; `wet` is linear
## (0.0-1.0), `predelay` milliseconds, `hipass` 0-1 (keeps low rumble out of the tail). The battle bus has its own small, dry room.

const PROFILES: Dictionary = {
	# No space: menus, the title.
	"dry": {"room": 0.1, "damping": 0.8, "wet": 0.0, "dry": 1.0, "predelay": 10.0, "spread": 0.5, "hipass": 0.2},
	# The starting forest: soft, absorbed, a little leafy depth.
	"forest": {"room": 0.45, "damping": 0.85, "wet": 0.07, "dry": 1.0, "predelay": 24.0, "spread": 0.9, "hipass": 0.25},
	# Gainlands and other open fields: almost dry, a faint far reflection.
	"open_meadow": {"room": 0.3, "damping": 0.75, "wet": 0.04, "dry": 1.0, "predelay": 40.0, "spread": 1.0, "hipass": 0.3},
	# Crosspath's square: stone walls close by, a short bright slap.
	"stone_plaza": {"room": 0.42, "damping": 0.45, "wet": 0.1, "dry": 1.0, "predelay": 18.0, "spread": 0.8, "hipass": 0.25},
	# The D.N.A.: long gloomy office halls, a grey tail.
	"office_halls": {"room": 0.68, "damping": 0.55, "wet": 0.16, "dry": 0.95, "predelay": 30.0, "spread": 0.7, "hipass": 0.2},
	# The Endless Buffet: a warm, busy kitchen, tiled and bright but not big.
	"kitchen": {"room": 0.5, "damping": 0.35, "wet": 0.11, "dry": 1.0, "predelay": 14.0, "spread": 0.8, "hipass": 0.3},
	# The Verdant Dump: open and damp; junk walls give a dull, short return.
	"wetlands": {"room": 0.38, "damping": 0.9, "wet": 0.07, "dry": 1.0, "predelay": 28.0, "spread": 1.0, "hipass": 0.3},
	# Outside the Capital: vast and empty, a late, thin echo off the white walls.
	"wasteland": {"room": 0.85, "damping": 0.7, "wet": 0.09, "dry": 1.0, "predelay": 120.0, "spread": 1.0, "hipass": 0.45},
	# Inside the wall: hard perfect paving and identical facades, a too-clean, slightly long ring.
	"perfect_plaza": {"room": 0.6, "damping": 0.2, "wet": 0.13, "dry": 1.0, "predelay": 22.0, "spread": 0.6, "hipass": 0.35},
	# Battles: a small dry room so impacts keep their punch.
	"battle": {"room": 0.25, "damping": 0.6, "wet": 0.05, "dry": 1.0, "predelay": 8.0, "spread": 0.7, "hipass": 0.3},
}

## Area keys (`Areas` / the ambience profile names) -> their acoustic profile.
const AREA_PROFILE: Dictionary = {
	"forest": "forest", "town": "stone_plaza", "gainlands": "open_meadow", "dna": "office_halls", "buffet": "kitchen", "heap": "wetlands",
	"capital_out": "wasteland", "capital_in": "perfect_plaza", "dungeon": "dry", "title": "dry",
}


static func profile(profile_name: String) -> Dictionary:
	return PROFILES.get(profile_name, PROFILES["dry"]) as Dictionary


static func for_area(area: String) -> String:
	return str(AREA_PROFILE.get(area, "dry"))
