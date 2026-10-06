shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;
// Toon water (docs/art/graphics_loop.md, G-05): a shallow-to-deep gradient driven by the depth below the surface, banded foam where the
// water meets land, two scrolling caustic line layers, gentle vertex waves and sky-tinted sparkles. `use_depth` is switched off on Low
// quality (no depth texture read: a flat gradient with a noise-based fake shore).

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;

uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec4 shallow_color : source_color = vec4(0.36, 0.78, 0.9, 1.0);
uniform vec4 deep_color : source_color = vec4(0.12, 0.45, 0.78, 1.0);
uniform vec4 foam_color : source_color = vec4(0.95, 0.98, 1.0, 1.0);
uniform vec4 sparkle_color : source_color = vec4(1.0, 0.97, 0.85, 1.0);
uniform float depth_range = 1.4;
uniform float foam_width = 0.28;
uniform float wave_height = 0.025;
uniform float flow_speed = 0.35;
uniform float caustic_strength = 0.22;
uniform float sparkle_amount = 1.0;
uniform bool use_depth = true;

varying vec3 v_world;

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

// Thin bright lines where two noise fields cross: cheap caustics.
float caustic(vec2 p, float t) {
	float a = vnoise(p + vec2(t, t * 0.6));
	float b = vnoise(p * 1.3 - vec2(t * 0.8, t));
	float line = 1.0 - smoothstep(0.0, 0.07, abs(a - b));
	return line;
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float w = sin(v_world.x * 1.3 + TIME * 1.1) + sin(v_world.z * 1.7 - TIME * 0.9);
	VERTEX.y += w * wave_height;
}

void fragment() {
	float diff = depth_range;
	if (use_depth) {
		float depth = texture(depth_tex, SCREEN_UV).r;
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
		vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view.xyz /= view.w;
		diff = max(-view.z - (-VERTEX.z), 0.0);
	} else {
		diff = depth_range * (0.35 + 0.65 * vnoise(v_world.xz * 0.35));
	}
	vec2 wp = v_world.xz;
	float t = TIME * flow_speed;
	float depth01 = smoothstep(0.0, depth_range, diff);
	vec3 col = mix(shallow_color.rgb, deep_color.rgb, depth01);
	// Painted value bands in the body of the water, a slow drifting patch pattern.
	float patch = vnoise(wp * 0.45 + vec2(t * 0.3, -t * 0.2));
	col *= 0.93 + 0.14 * smoothstep(0.35, 0.65, patch);
	// Caustic lines show in the shallows.
	float c = caustic(wp * 1.6, t) * 0.65 + caustic(wp * 3.1 + 7.0, -t * 1.3) * 0.35;
	col += foam_color.rgb * c * caustic_strength * (1.0 - depth01 * 0.8);
	// Banded foam along the shore, wobbling with noise so the edge is not a clean contour.
	float wob = vnoise(wp * 2.4 + vec2(t, -t * 0.5)) * 0.5 + vnoise(wp * 6.0 - vec2(t * 1.4, 0.0)) * 0.25;
	float shore = foam_width * (0.55 + wob);
	float foam = 1.0 - smoothstep(shore - 0.04, shore, diff);
	float foam_ring = smoothstep(shore + 0.05, shore + 0.09, diff) * (1.0 - smoothstep(shore + 0.12, shore + 0.16, diff)) * 0.5;
	col = mix(col, foam_color.rgb, max(foam, foam_ring * step(0.5, wob)));
	// Sky-tinted sparkles: tiny bright cells that twinkle.
	vec2 sp = wp * 9.0;
	vec2 cell = floor(sp);
	float h = hash21(cell);
	float dot_mask = 1.0 - smoothstep(0.08, 0.22, length(fract(sp) - 0.5 + (vec2(hash21(cell + 3.1), hash21(cell + 7.7)) - 0.5) * 0.4));
	float twinkle = step(0.982, h) * dot_mask * (0.5 + 0.5 * sin(TIME * (2.0 + h * 5.0) + h * 30.0));
	col += sparkle_color.rgb * twinkle * sparkle_amount * 0.8;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	ROUGHNESS = 1.0;
	// Slightly under 1 so the surface goes through the transparent pass and may read the opaque depth beneath it.
	ALPHA = use_depth ? 0.985 : 1.0;
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.78 * b1, 1.0, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
}
