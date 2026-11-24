class_name TownShuffleHouse
extends RefCounted
## Fable big pass Nov 23 (Parts 4 and 5): the Shuffle House, Octavia Eightfold's draft arena, on the north-east corner of
## Crosspath's square. A carnival-casino house (the painted TOWN-HERO-SHUFFLEHOUSE, Batch 20) standing ten metres back from the
## square's corner behind an open forecourt (the plain north-east row house is gone): it is seen from the fountain through the
## corner between Fenwick's and Pip's, its striped big top and flags rise over the shop roofs, and a paved path leads from the
## square's rim to its door ("shuffle_path" in `TownLayout.roads`). The forecourt is deep on purpose: with the low camera a
## hero standing close behind Pip's shop is hidden by its roof, and the door must be seen. The hanging sign
## (TOWN-SIGN-SHUFFLEHOUSE) is on a post at the corner where the path leaves the square.
## It is there from the start; it opens when all four zone drafts are won or three zones are freed (`DraftArena.is_open`).

const KEY: String = "shuffle_house"
const PAINTED: String = "TOWN-HERO-SHUFFLEHOUSE"
const SIGN: String = "TOWN-SIGN-SHUFFLEHOUSE"
## The painted front: its base line (the building's middle on the ground) and its height (the art is 3:4, so about 7.6 m wide).
const CENTER: Vector3 = Vector3(41.6, 0.0, -10.0)
const HEIGHT: float = 10.2
const WIDTH: float = 7.6
## The footprint that keeps lamps, plants and props out (width x depth), and how far in front of the centre the door spot is.
const FOOTPRINT: Vector2 = Vector2(7.8, 3.6)
const DOOR: float = 2.7
## Where Octavia stands when the house is open: beside the door, on the forecourt.
const HOST_OFFSET: Vector3 = Vector3(2.3, 0.0, 2.2)
## The sign post, where the door path leaves the square's rim.
const SIGN_POST: Vector3 = Vector3(37.2, 0.0, -0.1)
const SIGN_HEIGHT: float = 3.4
const SIGN_WIDTH: float = 1.9
## The paved path from the square to the door.
const PATH: Array[Vector3] = [Vector3(33.6, 0.0, 4.0), Vector3(37.6, 0.0, 1.1), Vector3(40.4, 0.0, -2.6), Vector3(41.6, 0.0, -7.0)]
## The hedge that closes the east side of the Secret Dealer's alley now that the row house is gone: from / to along x = HEDGE_X.
const HEDGE_X: float = 37.25
const HEDGE_Z: Array[float] = [-5.0, -2.0]


static func door_spot() -> Vector3:
	return CENTER + Vector3(0.0, 0.0, DOOR)


static func host_spot() -> Vector3:
	return CENTER + HOST_OFFSET


## Builds the house and its sign under `root` and adds their collision circles to `obstacles` (Vector3(x, z, radius)).
static func build(root: Node3D, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "ShuffleHouse"
	root.add_child(holder)
	var painted: Node3D = KitPieces.stand(holder, PAINTED, CENTER, HEIGHT, true, 1.05)
	holder.set_meta(&"painted", painted != null)
	if painted == null:
		# the art is not imported: a plain striped block stands in so the place is still there
		var block: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(WIDTH, 6.0, 3.0)
		block.mesh = box
		block.material_override = EnvKit.flat(Color("a8323c"), "cloth")
		block.position = CENTER + Vector3(0.0, 3.0, -0.6)
		holder.add_child(block)
	# the front is a wall as wide as the painting: a row of circles along its base
	var count: int = 5
	for index: int in range(count):
		var x: float = CENTER.x - WIDTH * 0.5 + WIDTH * (float(index) + 0.5) / float(count)
		obstacles.append(Vector3(x, CENTER.z - 0.5, WIDTH / float(count) * 0.62))
	_sign(holder, obstacles)
	# the alley keeps its east side: two lengths of hedge where the row house's wall stood
	for z: float in HEDGE_Z:
		var hedge: Node3D = PropKit.make("hedge", 3.2, int(absf(z) * 10.0))
		ModelKit.place(holder, hedge, Vector3(HEDGE_X, 0.0, z), 90.0, 1.0)
		for step: float in [-1.1, 0.0, 1.1]:
			obstacles.append(Vector3(HEDGE_X, z + step, 0.55))
	# a warm pool of light on the forecourt and the marquee's glow on the front
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "MarqueeGlow"
	glow.light_color = Color("ffc56a")
	glow.light_energy = 1.1
	glow.omni_range = 6.5
	glow.position = CENTER + Vector3(0.0, 3.2, 2.4)
	holder.add_child(glow)
	return holder


## The hanging sign on its own post at the mouth of the door path: seen from the square, off the paving (`SignPlacement`).
static func _sign(holder: Node3D, obstacles: Array[Vector3]) -> void:
	var post: MeshInstance3D = MeshInstance3D.new()
	post.name = "SignPost"
	var shaft: BoxMesh = BoxMesh.new()
	shaft.size = Vector3(0.16, SIGN_HEIGHT, 0.16)
	post.mesh = shaft
	post.material_override = EnvKit.flat(Color("4a3626"), "wood")
	post.position = SIGN_POST + Vector3(0.0, SIGN_HEIGHT * 0.5, 0.0)
	holder.add_child(post)
	obstacles.append(Vector3(SIGN_POST.x, SIGN_POST.z, 0.25))
	if not EnvKit.has(SIGN) or not EnvKit.has_art(SIGN):
		return
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(SIGN_WIDTH, SIGN_WIDTH / maxf(EnvKit.aspect(SIGN), 0.2))
	var sign: MeshInstance3D = MeshInstance3D.new()
	sign.name = "ShuffleHouseSign"
	sign.mesh = quad
	sign.material_override = EnvKit.material(SIGN, true)
	# the painted bracket is on the sign's left edge: it meets the post there
	sign.position = SIGN_POST + Vector3(SIGN_WIDTH * 0.5 - 0.1, SIGN_HEIGHT - quad.size.y * 0.5 + 0.2, 0.06)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sign.set_meta(&"no_occlusion_fade", true)
	holder.add_child(sign)
