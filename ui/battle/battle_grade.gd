class_name BattleGrade
extends RefCounted
## Graphics Tier 1, Part 3: the battleboard's colour grade per area (ui/shaders/board_grade.gdshader). The values come from the zone style of the
## area the duel is fought in (`ArenaTheme.for_zone(zone_id).preset_id` -> data/zone_styles/<area>.json `grade`), at half strength: the boards are
## painted for their zone already, the grade only ties them to the world's look (Crosspath warm, D.N.A. cool, the Buffet copper...).
## The neutral board (no zone) keeps a plain material.

const SHADER: String = "res://ui/shaders/board_grade.gdshader"
const STRENGTH: float = 0.5


static func values_for(zone_id: String) -> Dictionary:
	var theme: ArenaTheme = ArenaTheme.for_zone(zone_id)
	var area: String = ZoneStyles.area_for_preset(theme.preset_id)
	var style: Dictionary = ZoneStyles.style(area)
	var grade: Dictionary = style.get("grade", {}) as Dictionary
	var result: Dictionary = {"warmth": 0.0, "saturation": 1.0, "contrast": 1.0, "shadow_tint": Color.WHITE, "highlight_tint": Color.WHITE}
	if grade.is_empty():
		return result
	result["warmth"] = float(grade.get("warmth", 0.0)) * STRENGTH
	result["saturation"] = lerpf(1.0, float(grade.get("post_saturation", grade.get("saturation", 1.0))), STRENGTH)
	result["contrast"] = lerpf(1.0, float(grade.get("post_contrast", 1.0)), STRENGTH)
	result["shadow_tint"] = Color.WHITE.lerp(Color.html(str(grade.get("shadow_tint", "#ffffff"))), STRENGTH)
	result["highlight_tint"] = Color.WHITE.lerp(Color.html(str(grade.get("highlight_tint", "#ffffff"))), STRENGTH)
	return result


static func material_for(zone_id: String) -> ShaderMaterial:
	var values: Dictionary = values_for(zone_id)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHADER) as Shader
	for key: String in values.keys():
		material.set_shader_parameter(key, values[key])
	return material
