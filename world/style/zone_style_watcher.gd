class_name ZoneStyleWatcher
extends Node
## Debug-build hot reload of `data/zone_styles/<area>.json`: polls the current area's file and, when it changed, re-reads it and re-applies light, fog, grade, bloom and kit tints
## to the running scene (`StyleRig.set_preset`, `EnvKit.retint`). Material swaps need a scene reload. Does nothing in an exported build.

const POLL_SECONDS: float = 0.8

var style_rig: StyleRig
var _accum: float = 0.0
var _stamp: int = 0
var _area: String = ""


func _ready() -> void:
	set_process(OS.is_debug_build())


func _process(delta: float) -> void:
	_accum += delta
	if _accum < POLL_SECONDS:
		return
	_accum = 0.0
	var area: String = ZoneStyles.current
	if area == "":
		return
	var path: String = ProjectSettings.globalize_path(ZoneStyles.path_for(area))
	var stamp: int = FileAccess.get_modified_time(path)
	if area != _area:
		_area = area
		_stamp = stamp
		return
	if stamp == _stamp or stamp == 0:
		return
	_stamp = stamp
	ZoneStyles.reload()
	EnvKit.retint()
	if style_rig != null:
		style_rig.set_preset(style_rig.preset_id)
		var look: WorldLookRig = style_rig.get_parent().get_node_or_null("WorldLookRig") as WorldLookRig
		if look != null:
			look.refresh_style()
