class_name SpriteActor
extends Node3D
## The painted 2.5D stand-in for a 3D character model: `TownPlayer.model` is one of these for the hero (docs/art/world_rollout.md). It is the node the scenes' effects drive
## the way they drove the 3D model: `rotation.y` is where the body points, `scale` squashes and shrinks it (relative to `TownPlayer.MODEL_SCALE`), `rotation.x` / `.z` tumble
## it (the bounce pads, the slides), `position.y` lifts it (a mount) and `visible` blinks it. The card itself is a `WorldSprite` child; hat, cloak and dye come from the
## session's cosmetics (`EventBus.cosmetics_changed` refreshes them).
## Reusable for NPCs: set `character` (and `follow_cosmetics = false`) before adding it to the tree.

var character: String = "PLAYER"
## True for the hero: hat, cloak and dye follow `Session.cosmetics`.
var follow_cosmetics: bool = true
## The scale the owning node applies to its model when nothing special happens (`TownPlayer.MODEL_SCALE`): a scale of this much is "natural".
var natural_scale: float = 0.34
var sprite: WorldSprite
var _sun_found: bool = false


func _ready() -> void:
	sprite = WorldSprite.new()
	sprite.local_mode = true
	sprite.turn_rate_degrees = 3000.0
	add_child(sprite)
	sprite.setup(character, null, Vector3.ZERO)
	sprite.snap_heading(Vector3(sin(rotation.y), 0.0, cos(rotation.y)))
	if follow_cosmetics:
		apply_cosmetics()
		if not EventBus.cosmetics_changed.is_connected(apply_cosmetics):
			EventBus.cosmetics_changed.connect(apply_cosmetics)


func _exit_tree() -> void:
	if EventBus.cosmetics_changed.is_connected(apply_cosmetics):
		EventBus.cosmetics_changed.disconnect(apply_cosmetics)


func apply_cosmetics() -> void:
	if sprite != null and is_instance_valid(sprite):
		SpriteCosmetics.apply(sprite, Session.cosmetics)


func _process(delta: float) -> void:
	if sprite == null:
		return
	if not _sun_found and is_inside_tree():
		var sun: Node = get_tree().get_first_node_in_group(&"style_sun")
		if sun is DirectionalLight3D:
			sprite.set_sun(-(sun as DirectionalLight3D).global_basis.z)
			_sun_found = true
	# The card never inherits this node's scale (the contact shadow would shrink with it): the squash goes in through the shader instead.
	var s: Vector3 = scale
	if absf(s.x) > 0.0001 and absf(s.y) > 0.0001 and absf(s.z) > 0.0001:
		sprite.scale = Vector3(1.0 / s.x, 1.0 / s.y, 1.0 / s.z)
	var relative: float = 1.0 / maxf(natural_scale, 0.0001)
	sprite.set_body_scale(Vector2(absf(s.x) * relative, absf(s.y) * relative))
	sprite.roll_radians = rotation.x + rotation.z
	sprite.look_toward(Vector3(sin(rotation.y), 0.0, cos(rotation.y)))
	sprite.follow_parent(delta)
	if absf(s.y) > 0.0001:
		sprite.position.y /= s.y  # the walking bob is in world metres, the parent scales its children
