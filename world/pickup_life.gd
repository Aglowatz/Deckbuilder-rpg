class_name PickupLife
extends RefCounted
## Fable Nov 12d (Part 4.1): a zone pickup (an ingredient in the Buffet, a bean or a crate in the Dump) bobs gently, a single model turns
## slowly, and its glowing ground ring breathes, so it reads as "take me" from across a yard. One looping tween per pickup (a handful per
## zone), no lights, no particles. Off on the Low-end preset and under Reduce motion (the pickup then stands as it always did).

const BOB_HEIGHT: float = 0.09
const BOB_SECONDS: float = 2.2
const TURN_SECONDS: float = 9.0
const RING_NODE: String = "Ring"
const RING_PULSE: float = 1.16


static func enabled() -> bool:
	return not GraphicsQuality.low_end and not Settings.reduce_motion


## Starts the motion on a pickup holder (its children: the model pieces and a node named "Ring"). `phase` (0..1) offsets the bob so a
## row of pickups does not move in step. Returns the tween, or null when motion is off or there is nothing to move.
static func attach(holder: Node3D, phase: float = 0.0) -> Tween:
	if holder == null or not enabled():
		return null
	var pieces: Array[Node3D] = []
	var bases: Array[float] = []
	var ring: Node3D = null
	for child: Node in holder.get_children():
		var piece: Node3D = child as Node3D
		if piece == null:
			continue
		if piece.name == RING_NODE:
			ring = piece
			continue
		pieces.append(piece)
		bases.append(piece.position.y)
	if pieces.is_empty() and ring == null:
		return null
	var turn: bool = pieces.size() == 1
	var start_yaw: float = pieces[0].rotation.y if turn else 0.0
	var ring_scale: Vector3 = ring.scale if ring != null else Vector3.ONE
	var step: Callable = func(t: float) -> void:
		var wave: float = 0.5 - 0.5 * cos((t + phase) * TAU)
		for index: int in range(pieces.size()):
			if is_instance_valid(pieces[index]):
				pieces[index].position.y = bases[index] + wave * BOB_HEIGHT
		if ring != null and is_instance_valid(ring):
			var grow: float = lerpf(1.0, RING_PULSE, 1.0 - wave)
			ring.scale = Vector3(ring_scale.x * grow, ring_scale.y, ring_scale.z * grow)
	var tween: Tween = holder.create_tween()
	tween.set_loops()
	# A single model also turns slowly, on its own linear loop (a full turn, so the loop has no snap).
	if turn:
		var spin: Tween = holder.create_tween()
		spin.set_loops()
		spin.tween_property(pieces[0], "rotation:y", start_yaw + TAU, TURN_SECONDS).from(start_yaw)
	tween.tween_method(step, 0.0, 1.0, BOB_SECONDS)
	return tween
