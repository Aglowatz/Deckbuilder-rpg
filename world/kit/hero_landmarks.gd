class_name HeroLandmarks
extends RefCounted
## The hero landmarks of a zone (Art Bible G-08, layer 3) once their concept art exists: `LandmarkKit.build` asks here first, and a zone that has modelled its landmarks
## after the approved concepts returns a textured model instead of the stand-in. One entry per zone kit prefix; a zone without a builder keeps the stand-ins.
## The returned node follows the stand-in contract: origin on the ground at the centre of the footprint, the front +z, meta "circles" (Array of Vector3 local x, z, radius),
## "footprint" (Vector2), "height", and optionally "spinner" (a child the scene turns slowly about its local z) and "lights".

## Kit id prefix -> the script with `static func build(spec: Dictionary) -> Node3D` (null when it has no model for that id).
const BUILDERS: Dictionary = {
	"GAIN-HERO-": "res://world/gainlands/gainlands_landmarks.gd",
	"DNA-HERO-": "res://world/dna/dna_landmarks.gd",
}

static var _scripts: Dictionary = {}


## The modelled landmark for `spec` ({id, size [w, h, d], ...}), or null when no zone has modelled it.
static func build(spec: Dictionary) -> Node3D:
	var id: String = str(spec.get("id", ""))
	for prefix: String in BUILDERS.keys():
		if not id.begins_with(prefix):
			continue
		var script: GDScript = _script(str(BUILDERS[prefix]))
		if script == null:
			return null
		return script.call("build", spec) as Node3D
	return null


static func has_model(id: String) -> bool:
	for prefix: String in BUILDERS.keys():
		if id.begins_with(prefix):
			var script: GDScript = _script(str(BUILDERS[prefix]))
			return script != null and bool(script.call("has_model", id))
	return false


static func _script(path: String) -> GDScript:
	if not _scripts.has(path):
		_scripts[path] = load(path) as GDScript
	return _scripts[path] as GDScript
