shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;
// Painted terrain for the vertex-coloured zone ground (docs/art/graphics_loop.md, G-08): the zone builders paint a base colour per triangle, this shader
// hides the triangles: world-space macro value/tint patches (so no flat field survives), a fine brush grain, optional mowed stripes, normals flattened on
// up-facing ground (no faceted shading), ground saturation, and the same soft toon bands as every other surface.

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_ground_sat;

uniform float macro_amount = 0.12;
uniform float tint_amount = 0.5;
uniform float grain_amount = 0.05;
uniform float stripe_amount = 0.0;
uniform vec2 stripe_dir = vec2(0.8, 0.6);
uniform float stripe_width = 2.4;
uniform float flatten = 0.8;

varying vec3 v_world;
varying float v_up;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x), mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_up = normalize(mat3(MODEL_MATRIX) * NORMAL).y;
}

void fragment() {
	vec3 vc = COLOR.rgb;
	vc = mix(pow((vc + vec3(0.055)) / 1.055, vec3(2.4)), vc / 12.92, vec3(lessThan(vc, vec3(0.04045))));
	float ground = smoothstep(0.55, 0.85, abs(v_up));
	vec2 wp = v_world.xz;
	// Macro patches: two soft octaves of value variation plus a warm/cool tint patch.
	float macro = vnoise(wp * 0.11) * 0.6 + vnoise(wp * 0.29 + 7.0) * 0.4;
	float tint_n = vnoise(wp * 0.07 + 31.0);
	vec3 col = vc * (1.0 + (macro - 0.5) * 2.0 * macro_amount * ground);
	col *= mix(vec3(1.0), mix(vec3(1.06, 1.01, 0.92), vec3(0.93, 1.0, 1.08), tint_n), tint_amount * ground);
	// Fine brush grain.
	float grain = vnoise(wp * 7.0) * 0.6 + vnoise(wp * 19.0) * 0.4;
	col *= 1.0 + (grain - 0.5) * 2.0 * grain_amount;
	// Mowed stripes (grass fields).
	if (stripe_amount > 0.0) {
		float s = sin(dot(wp, normalize(stripe_dir)) / stripe_width * 3.14159);
		col *= 1.0 + stripe_amount * (smoothstep(-0.12, 0.12, s) - 0.5) * ground;
	}
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, mix(1.0, style_ground_sat, ground));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	ROUGHNESS = 1.0;
	vec3 up_view = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	NORMAL = normalize(mix(NORMAL, up_view, flatten * ground));
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
}
