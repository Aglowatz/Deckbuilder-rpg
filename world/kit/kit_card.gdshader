shader_type spatial;
render_mode unshaded, cull_disabled;
// A painted card for the Environment Kit (trees ENV-TREE-*): an upright quad that turns round the vertical axis to face the camera, bends a little in the wind (more at the
// top), is lit with the sun and ambient colours of the zone (faked, like the foliage layer) and is darker towards its roots. The texture is the kit art or its placeholder.

uniform sampler2D card_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 light_color : source_color = vec3(1.0, 0.92, 0.78);
uniform vec3 ambient_color : source_color = vec3(0.55, 0.6, 0.78);
uniform vec3 mood_tint : source_color = vec3(1.0);
uniform float sway = 0.035;
uniform float speed = 0.9;
uniform float base_dark = 0.7;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float sx = length(MODEL_MATRIX[0].xyz);
	float sy = length(MODEL_MATRIX[1].xyz);
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	float h = clamp(VERTEX.y, 0.0, 1.0);
	float phase = origin.x * 0.31 + origin.z * 0.23;
	float bend = (sin(TIME * speed + phase) * 0.7 + sin(TIME * speed * 2.3 + phase * 1.7) * 0.3) * sway;
	vec3 world = origin + right * (VERTEX.x * sx + bend * h * h * sy) + vec3(0.0, VERTEX.y * sy, 0.0);
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
}

void fragment() {
	vec4 c = texture(card_tex, UV);
	if (c.a < 0.5) {
		discard;
	}
	float base = smoothstep(1.0, 0.7, UV.y);
	vec3 lit = ambient_color * 0.55 + light_color * 0.62;
	ALBEDO = c.rgb * mood_tint * lit * mix(base_dark, 1.0, base);
}
