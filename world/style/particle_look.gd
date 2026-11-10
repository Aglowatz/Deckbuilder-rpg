class_name ParticleLook
extends RefCounted
## Fable pass Nov 10 (Part 1.5, the mid critic's "milky white sheets"): a steam or mist puff is a translucent billboard a metre or two across;
## when the camera glides into a plume (the Low camera behind the hero at the Soup Fountain, the hub's chimneys) each puff fills a quarter
## of the screen as a flat white polygon. Puff materials fade out as they come near the lens (fully gone within NEAR metres, whole from
## FAR), so a plume reads as steam from any distance and never as a sheet. Each emitter gets its own copy of the shared material.

const NEAR: float = 2.5
const FAR: float = 9.0


## A copy of `material` that fades out near the lens (StandardMaterial3D only; anything else is returned as it is).
static func near_fade(material: Material) -> Material:
	var standard: StandardMaterial3D = material as StandardMaterial3D
	if standard == null:
		return material
	var copy: StandardMaterial3D = standard.duplicate() as StandardMaterial3D
	copy.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_ALPHA
	copy.distance_fade_min_distance = NEAR
	copy.distance_fade_max_distance = FAR
	return copy
