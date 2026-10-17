class_name DialogueVoice
extends RefCounted
## The little voice of each speaker's typed text (docs/audio/sound_direction.md, "The interface family"): a soft woody tok per typing step, pitched by
## the speaker's kind (small creatures higher, big ones lower, ghosts and skeletons breathy), with a small steady offset from the name so two people of
## one kind never sound identical. Pure: a speaker's species (`NpcRegistry`) and name in, an event and a pitch out.

const SMALL: Array[String] = ["mouse", "frog", "magpie", "rabbit", "hedgehog", "weasel", "mole", "gnome", "opossum", "birdfolk", "crane", "fox", "persian cat", "cat"]
const BIG: Array[String] = ["bear", "walrus", "minotaur", "stone troll", "rhinoceros", "yeti", "tortoise"]
const SPOOKY: Array[String] = ["ghost", "ghoul", "skeleton", "otherworldly being"]


## {"event": StringName, "pitch": float} for a speaker.
static func for_speaker(species: String, speaker_name: String) -> Dictionary:
	var kind: String = species.strip_edges().to_lower()
	# A steady -5 %..+5 % from the name.
	var offset: float = (float(absi(speaker_name.hash()) % 1000) / 1000.0 - 0.5) * 0.1
	if SPOOKY.has(kind):
		return {"event": &"dialogue_airy", "pitch": 0.92 + offset * 0.5}
	if SMALL.has(kind):
		return {"event": &"dialogue", "pitch": 1.28 + offset}
	if BIG.has(kind):
		return {"event": &"dialogue", "pitch": 0.74 + offset * 0.6}
	return {"event": &"dialogue", "pitch": 1.0 + offset}
