shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
// A warm light shaft (WorldAmbient): a soft additive strip along the sun's direction, turning round that axis to face the camera. UV.y runs 0 at the top to 1 at the ground.

uniform vec3 axis = vec3(0.4, -0.65, -0.65);
uniform float length_m = 9.0;
uniform float width_m = 2.4;
uniform vec3 color : source_color = vec3(1.0, 0.82, 0.5);
uniform float strength = 0.16;
uniform float seed = 0.0;

void vertex() {
	vec3 a = normalize(axis);
	vec3 to_cam = normalize(INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz);
	vec3 side = normalize(cross(a, to_cam));
	vec3 world = MODEL_MATRIX[3].xyz + side * (VERTEX.x * width_m) + a * (-VERTEX.y * length_m);
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
}

void fragment() {
	float across = 1.0 - abs(UV.x * 2.0 - 1.0);
	across = smoothstep(0.0, 0.7, across);
	float along = smoothstep(0.0, 0.18, UV.y) * (1.0 - smoothstep(0.55, 1.0, UV.y));
	float shimmer = 0.78 + 0.22 * sin(TIME * 0.6 + seed * 6.28 + UV.y * 4.0);
	ALBEDO = color * strength * across * along * shimmer;
	ALPHA = 1.0;
}
