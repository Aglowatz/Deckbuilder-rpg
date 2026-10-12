shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
// The foam strip along the far shore (WorldScenery): DEC-SHOREFOAM repeated round the ring, water side up (UV y = 0 at the water).

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform float opacity : hint_range(0.0, 1.0) = 0.95;

void fragment() {
	vec4 c = texture(tex, vec2(UV.x, clamp(UV.y, 0.0, 1.0)));
	float pulse = 0.88 + 0.12 * sin(TIME * 0.7 + UV.x * 3.0);
	ALBEDO = c.rgb * 1.04;
	ALPHA = c.a * opacity * pulse;
}
