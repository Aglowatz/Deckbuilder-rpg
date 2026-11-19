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


static func build(root: Node3D, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "ForgottenCaveMouth"
	root.add_child(holder)
	KitPieces.stand(holder, "OF-HERO-CAVE-MOUTH", CENTER, MOUTH_HEIGHT)
	# brush over the lower corners and either side, the mouth peeking out between
	KitPieces.stand(holder, "OF-PROP-BRAMBLES", CENTER + Vector3(-1.75, 0.0, 0.45), 1.35)
	KitPieces.stand(holder, "OF-PROP-BRAMBLES", CENTER + Vector3(1.8, 0.0, 0.55), 1.25)
	KitPieces.stand(holder, "OF-PROP-BRAMBLES", CENTER + Vector3(-2.9, 0.0, -0.2), 1.1)
	KitPieces.stand(holder, "OF-PROP-BRAMBLES", CENTER + Vector3(3.0, 0.0, -0.1), 1.05)
	KitPieces.stand(holder, "ENV-HEDGE", CENTER + Vector3(-1.1, 0.0, 1.05), 0.7)
	KitPieces.stand(holder, "ENV-HEDGE", CENTER + Vector3(1.25, 0.0, 1.1), 0.65)
	KitPieces.stand(holder, "ENV-PROP-LANTERN", CENTER + Vector3(2.1, 0.0, 1.5), 1.5)
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "LanternGlow"
	glow.light_color = Color("ffb45a")
	glow.light_energy = 0.9
	glow.omni_range = 3.2
	glow.position = CENTER + Vector3(2.1, 1.35, 1.5)
	holder.add_child(glow)
	obstacles.append(Vector3(CENTER.x, CENTER.z, 1.5))
	obstacles.append(Vector3(CENTER.x - 2.2, CENTER.z + 0.2, 0.9))
	obstacles.append(Vector3(CENTER.x + 2.3, CENTER.z + 0.3, 0.9))
	return holder
