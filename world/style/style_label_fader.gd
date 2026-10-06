class_name StyleLabelFader
extends Node
## Keeps the scene's Label3D text legible: every couple of seconds it finds new labels under `root` and tunes them (`StyleLabel.tune`); every frame it fades the
## ones hanging above the hero (name plates and signs the hero walks under), so they never cover the character.

const SCAN_INTERVAL: float = 2.0
const FADE_START: float = 0.9
const FADE_END: float = 2.4
const MIN_ALPHA: float = 0.22

var root: Node
var hero: Node3D

var _labels: Array[Label3D] = []
var _scan_timer: float = 0.0


func _process(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = SCAN_INTERVAL
		_scan()
	if hero == null or not is_instance_valid(hero):
		return
	var origin: Vector3 = hero.global_position
	for label: Label3D in _labels:
		if not is_instance_valid(label):
			continue
		var base_alpha: float = float(label.get_meta(&"base_alpha", 1.0))
		var target: float = 1.0
		var offset: Vector3 = label.global_position - origin
		if offset.y > 1.0 and offset.y < 4.5:
			var flat: float = Vector2(offset.x, offset.z).length()
			target = lerpf(MIN_ALPHA, 1.0, smoothstep(FADE_START, FADE_END, flat))
		var current: float = label.modulate.a / maxf(base_alpha, 0.001)
		label.modulate.a = base_alpha * lerpf(current, target, minf(1.0, delta * 8.0))


func _scan() -> void:
	if root == null or not is_instance_valid(root):
		return
	_labels.clear()
	for node: Node in root.find_children("*", "Label3D", true, false):
		var label: Label3D = node as Label3D
		StyleLabel.tune(label)
		_labels.append(label)
