shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
// DEC-SHOREFOAM cards laid along every coastline (WorldScenery): foam lapping in and out, the card's wet-sand side towards the land.
// Instance custom data: x = phase offset.

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float opacity : hint_range(0.0, 1.0) = 0.9;
uniform float lap = 0.16;

varying float v_phase;

void vertex() {
	v_phase = INSTANCE_CUSTOM.x;
	// Lap in and out along the card's local z (towards the land).
	VERTEX.z += sin(TIME * 0.75 + v_phase * 6.283) * lap;
}

void fragment() {
	vec4 c = texture(tex, UV);
	float pulse = 0.82 + 0.18 * sin(TIME * 0.75 + v_phase * 6.283 + 1.2);
	ALBEDO = c.rgb * 1.04;
	ALPHA = c.a * opacity * pulse;
}
