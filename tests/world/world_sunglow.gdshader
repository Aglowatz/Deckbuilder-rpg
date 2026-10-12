shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled;
// The sun glow card (SKY-SUN): additive, always facing the camera, parked at the sun's direction far away.

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float size = 950.0;
uniform float strength = 0.9;

void vertex() {
	mat4 face = mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX = vec3(VERTEX.xy * size, 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * face;
}

void fragment() {
	vec4 c = texture(tex, UV);
	ALBEDO = c.rgb * c.a * strength;
	ALPHA = 1.0;
}
