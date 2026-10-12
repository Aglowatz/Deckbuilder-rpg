shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;
// A painted cloud card (WorldSky): an upright billboard that turns to the camera around the vertical axis; origin at the cloud's base centre.
// The farther / lower the cloud, the more it dissolves into the horizon haze.

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec2 card_size = vec2(300.0, 180.0);
uniform vec3 haze : source_color = vec3(0.96, 0.82, 0.64);
uniform float haze_amount : hint_range(0.0, 1.0) = 0.3;
uniform float opacity : hint_range(0.0, 1.0) = 0.95;
uniform vec3 warm : source_color = vec3(1.0, 0.93, 0.82);
uniform vec3 tint : source_color = vec3(1.0);

void vertex() {
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec3 back = normalize(vec3(INV_VIEW_MATRIX[2].x, 0.0, INV_VIEW_MATRIX[2].z));
	mat4 face = mat4(vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(back, 0.0), MODEL_MATRIX[3]);
	VERTEX = vec3(VERTEX.x * card_size.x, VERTEX.y * card_size.y, 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * face;
}

void fragment() {
	vec4 c = texture(tex, UV);
	vec3 col = c.rgb * warm * tint;
	// The lower edge of the card melts into the haze (clouds sit in the same air as the mountains).
	float low = 1.0 - smoothstep(0.0, 0.35, UV.y);
	col = mix(col, haze, clamp(haze_amount + low * 0.15, 0.0, 1.0));
	ALBEDO = col;
	ALPHA = c.a * opacity;
}
