class_name TownCaveMouth
extends RefCounted
## Overnight Nov 19 (Part 8.2): the Forgotten Cave's way out into Crosspath - a small cave mouth in the rocks on the north edge of town where
## the forest comes down, a few steps from Elder Maren's house, half hidden by brush: the painted cave mouth (OF-HERO-CAVE-MOUTH), bramble
## thickets either side (OF-PROP-BRAMBLES), a low hedge in front, a lantern on its post (ENV-PROP-LANTERN). Existing art only. (Its door in the
## stone hut near the middle of town is gone; the hut is a plain house now.)

const CENTER: Vector3 = Vector3(30.0, 0.0, -24.6)
## Where the hero stands to use it (the travel prompt, the map icon and the quest markers): just in front of the mouth, inside the walkable edge.
const SPOT: Vector3 = Vector3(30.0, 0.0, -22.6)
const MOUTH_HEIGHT: float = 3.4
const PAINTED: String = "TOWN-PROP-CAVE-MOUTH-BRUSH"
const PAINTED_HEIGHT: float = 4.4


static func build(root: Node3D, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "ForgottenCaveMouth"
	root.add_child(holder)
	# Batch 18 (Nov 20): one painted piece (TOWN-PROP-CAVE-MOUTH-BRUSH: the low mouth in mossy rocks, bramble and fern over it, its own
	# lantern on a crooked post at the left) replaces the assembled mouth, brambles, hedges and lantern. The glow sits on the painted lantern.
	var painted: Node3D = KitPieces.stand(holder, PAINTED, CENTER + Vector3(0.0, 0.0, 0.4), PAINTED_HEIGHT)
	var lantern: Vector3 = Vector3(-PAINTED_HEIGHT * 0.36, PAINTED_HEIGHT * 0.6, 0.6)
	if painted == null:
		KitPieces.stand(holder, "OF-HERO-CAVE-MOUTH", CENTER, MOUTH_HEIGHT)
		lantern = Vector3(2.1, 1.35, 1.5)
		KitPieces.stand(holder, "ENV-PROP-LANTERN", CENTER + Vector3(2.1, 0.0, 1.5), 1.5)
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "LanternGlow"
	glow.light_color = Color("ffb45a")
	glow.light_energy = 0.9
	glow.omni_range = 3.2
	glow.position = CENTER + lantern
	holder.add_child(glow)
	obstacles.append(Vector3(CENTER.x, CENTER.z, 1.5))
	obstacles.append(Vector3(CENTER.x - 2.2, CENTER.z + 0.2, 0.9))
	obstacles.append(Vector3(CENTER.x + 2.3, CENTER.z + 0.3, 0.9))
	return holder
