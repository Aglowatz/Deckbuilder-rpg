shader_type spatial;
render_mode cull_disabled, diffuse_lambert, specular_disabled;
// Grass blades (docs/art/graphics_loop.md, G-06): clumps of tapered blades in a MultiMesh. Base-to-tip colour gradient, per-clump hue/value variation
// (hashed from the instance position), travelling wind gusts plus a flutter, and the hero tramples the blades flat around their feet
// (`style_player_pos`). Lit with the same soft toon bands as everything else; blade normals lean towards up so a clump shades like ground cover.

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_wind;
global uniform float style_ground_sat;
global uniform vec3 style_player_pos;

uniform vec4 base_color : source_color = vec4(0.26, 0.5, 0.22, 1.0);
uniform vec4 tip_color : source_color = vec4(0.66, 0.84, 0.36, 1.0);
uniform float wind_strength = 0.32;
uniform float gust_speed = 1.6;
uniform float trample_radius = 1.0;

varying float v_height;
varying float v_variation;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float h = clamp(UV.y, 0.0, 1.0);
	v_height = h;
	v_variation = hash21(origin.xz * 3.7);
	float scale_sq = max(dot(MODEL_MATRIX[0].xyz, MODEL_MATRIX[0].xyz), 0.0001);
	// Wind: a gust wave travelling across the field, plus a quick per-blade flutter.
	float gust = sin(dot(origin.xz, vec2(0.62, 0.41)) - TIME * gust_speed);
	gust = gust * 0.5 + 0.5;
	gust *= gust;
	float flutter = sin(TIME * 2.6 + origin.x * 1.9 + origin.z * 1.4 + VERTEX.x * 9.0);
	vec2 push = vec2(1.0, 0.4) * (0.25 + gust * 0.9 + flutter * 0.18) * wind_strength * style_wind * h * h;
	// Trample: blades near the hero lean away from him and lose height.
	vec2 away = origin.xz - style_player_pos.xz;
	float dist = length(away);
	float t = 1.0 - smoothstep(0.15, trample_radius, dist);
	push += (away / max(dist, 0.001)) * t * 0.55 * h;
	VERTEX.y -= t * 0.55 * h * (1.0 / sqrt(scale_sq));
	// World-space push into the instance's local space (uniform scale + yaw).
	vec3 world_push = vec3(push.x, 0.0, push.y);
	VERTEX += (transpose(mat3(MODEL_MATRIX)) * world_push) / scale_sq;
}

void fragment() {
	vec3 base = base_color.rgb;
	vec3 tip = tip_color.rgb;
	// Per-clump variation: a hue nudge between yellower and bluer greens and a value change.
	base = mix(base, base.gbr * 0.9 + base * 0.1, (v_variation - 0.5) * 0.25);
	tip = mix(tip, vec3(tip.r * 1.12, tip.g, tip.b * 0.85), (v_variation - 0.5) * 0.6);
	vec3 col = mix(base, tip, pow(v_height, 0.85)) * (0.88 + 0.24 * v_variation);
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, mix(1.0, style_ground_sat, 0.5));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	ROUGHNESS = 1.0;
	// Blades shade like the ground they stand on.
	vec3 up_view = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	NORMAL = normalize(mix(NORMAL, up_view, 0.8));
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
}
