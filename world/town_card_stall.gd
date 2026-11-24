class_name TownCardStall
extends RefCounted
## Nov 18 day (Part 5.2): the Deck Station is a card-trader's market stall at the mouth of the Gate Road, on the square, where every new player
## walks down from the cave and Elder Maren's home (it was a plain inn on Champions' Road that nobody found). Built only from existing pieces:
## the kit's market stall (ENV-PROP-STALL look: plank counter, timber posts, ENV-AWNING-01, a hanging lantern) without its produce, the
## hanging card sign (ENV-SIGN-CARDS) under the awning, three painted card backs (UI-CARDBACK-*) standing on the counter and sacks beside it. The map / minimap pin uses the deck icon and the screen label reads "Deck Station" (`TownScene`).

## The stall's centre and facing (yaw 0 = its front faces +z, the square and the camera). The interaction spot stands `DOOR` in front.
## Fable big pass Nov 23 (the owner: "move the Deck Station to the other side of the main fountain"): from the Gate Road's mouth on
## the north-west (21.8, 4.0), where the fountain hid it from the arrival point, to the fountain's south side, four steps west of
## where the hero arrives, facing the camera (the south-east is hidden by the inn's roof from the arrival camera).
const CENTER: Vector3 = Vector3(21.0, 0.0, 20.0)
const YAW: float = 0.0
const DOOR: float = 2.1
const CARD_BACKS: Array[String] = ["UI-CARDBACK-B", "UI-CARDBACK-N", "UI-CARDBACK-G", "UI-CARDBACK-R"]


## Builds the stall under `root` at `center` facing `yaw` and adds its collision circles to `obstacles` (Vector3(x, z, radius)).
static func build(root: Node3D, center: Vector3, yaw: float, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "DeckStationStall"
	root.add_child(holder)
	holder.position = center
	holder.rotation_degrees.y = yaw
	var stall: Node3D = PropKit.stall(0, false)
	holder.add_child(stall)
	_sign(holder)
	_card_backs(holder)
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	# [local x, local z, radius]: the counter's two halves and the sacks on the right.
	for circle: Vector3 in [Vector3(-0.85, 0.2, 0.95), Vector3(0.85, 0.2, 0.95), Vector3(2.35, 0.25, 0.45)]:
		var at: Vector3 = center + basis * Vector3(circle.x, 0.0, circle.y)
		obstacles.append(Vector3(at.x, at.z, circle.z))
	return holder


## The interaction spot: in front of the counter.
static func door_spot(center: Vector3 = CENTER, yaw: float = YAW) -> Vector3:
	return center + Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3(0.0, 0.0, DOOR)


## The hanging card sign (ENV-SIGN-CARDS) under the awning's front edge, beside the lantern; a placeholder board when the art is missing.
static func _sign(holder: Node3D) -> void:
	var quad: QuadMesh = QuadMesh.new()
	var width: float = 1.05
	var aspect: float = EnvKit.aspect("ENV-SIGN-CARDS") if EnvKit.has_art("ENV-SIGN-CARDS") else 1.0
	quad.size = Vector2(width, width / maxf(aspect, 0.2))
	var sign: MeshInstance3D = MeshInstance3D.new()
	sign.name = "CardSign"
	sign.mesh = quad
	sign.material_override = EnvKit.material("ENV-SIGN-CARDS", true)
	sign.position = Vector3(0.95, 2.45 - quad.size.y * 0.5, 1.42)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(sign)
	for x: float in [0.95 - width * 0.35, 0.95 + width * 0.35]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var rod: BoxMesh = BoxMesh.new()
		rod.size = Vector3(0.025, 0.12, 0.025)
		chain.mesh = rod
		chain.material_override = EnvKit.flat(Color("3b3530"), "iron")
		chain.position = Vector3(x, 2.5, 1.42)
		holder.add_child(chain)


## Three painted card backs standing on the counter, leaning back a little, and one lying flat: it reads "cards" from across the square.
static func _card_backs(holder: Node3D) -> void:
	var size: Vector2 = Vector2(0.34, 0.5)
	for index: int in range(3):
		var texture: Texture2D = UiArt.texture(CARD_BACKS[index]) if UiArt.has(CARD_BACKS[index]) else null
		var card: MeshInstance3D = MeshInstance3D.new()
		card.name = "CardBack%d" % index
		var quad: QuadMesh = QuadMesh.new()
		quad.size = size
		card.mesh = quad
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = texture
		material.albedo_color = Color.WHITE if texture != null else Color("6b4a8a")
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = 0.8
		card.material_override = material
		card.position = Vector3(-0.85 + 0.85 * float(index), 1.07 + size.y * 0.5, 0.62)
		card.rotation_degrees = Vector3(-12.0, -10.0 + 10.0 * float(index), 0.0)
		holder.add_child(card)
