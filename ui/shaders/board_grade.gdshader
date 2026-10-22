shader_type canvas_item;
// Graphics Tier 1, Part 3 (docs/art/graphics_tier1.md): the battleboard's own colour grade per area, from the zone style's grade block (BattleGrade):
// warmth, saturation, a split tint (shadows / highlights) and contrast on the painted board only - never on the cards or the HUD. The board still
// takes the effect lights (no `unshaded`).

uniform float warmth = 0.0;
uniform float saturation = 1.0;
uniform float contrast = 1.0;
uniform vec3 shadow_tint : source_color = vec3(1.0);
uniform vec3 highlight_tint : source_color = vec3(1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 col = c.rgb;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	vec3 warm = vec3(1.0 + 0.11 * warmth, 1.0 + 0.025 * warmth, 1.0 - 0.15 * warmth);
	col *= mix(vec3(1.0), warm, 0.6 + 0.4 * luma);
	luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, saturation);
	float split = smoothstep(0.12, 0.8, luma);
	col *= mix(shadow_tint, highlight_tint, split);
	col = (col - 0.5) * contrast + 0.5;
	COLOR = vec4(col, c.a);
}
