shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;
// Ground decals (docs/art/style_guide.md, section 8): procedural cobbles, dirt, moss and flowerbed soil with soft organic edges, lit by the same
// toon bands as everything else. Placed as flat discs and ribbons just above the hex tiles.

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;

uniform int pattern = 0; // 0 cobble, 1 dirt, 2 moss, 3 soil
uniform int shape = 0; // 0 radial (disc), 1 ribbon (uv.x across)
uniform vec4 color_a : source_color = vec4(0.78, 0.66, 0.5, 1.0);
uniform vec4 color_b : source_color = vec4(0.62, 0.52, 0.5, 1.0);
uniform vec4 gap_color : source_color = vec4(0.32, 0.24, 0.26, 1.0);
uniform float scale = 2.2;
uniform float edge_soft = 0.28;
uniform float opacity = 1.0;
uniform float seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
	float n = hash21(p);
	return vec2(n, hash21(p + n + 17.0));
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wp = v_world.xz + seed * 7.31;
	float edge;
	if (shape == 0) {
		float d = length(UV - vec2(0.5)) * 2.0;
		edge = 1.0 - d;
	} else {
		edge = min(UV.x, 1.0 - UV.x) * 2.0;
	}
	float wob = vnoise(wp * 1.7) * 0.5 + vnoise(wp * 4.1) * 0.25;
	float mask = smoothstep(0.0, edge_soft, edge - 0.18 * wob);
	vec3 col;
	if (pattern == 0) {
		vec2 g = wp * scale;
		vec2 gi = floor(g);
		vec2 gf = fract(g);
		float f1 = 8.0;
		float f2 = 8.0;
		vec2 cell_id = vec2(0.0);
		for (int y = -1; y <= 1; y++) {
			for (int x = -1; x <= 1; x++) {
				vec2 nb = vec2(float(x), float(y));
				vec2 pt = hash22(gi + nb);
				vec2 diff = nb + pt - gf;
				float dist = dot(diff, diff);
				if (dist < f1) {
					f2 = f1;
					f1 = dist;
					cell_id = gi + nb;
				} else if (dist < f2) {
					f2 = dist;
				}
			}
		}
		float border = sqrt(f2) - sqrt(f1);
		float stone = smoothstep(0.02, 0.16, border);
		float tone = hash21(cell_id);
		vec3 stone_col = mix(color_a.rgb, color_b.rgb, tone);
		stone_col *= 0.9 + 0.2 * vnoise(wp * 9.0);
		stone_col *= 0.9 + 0.2 * smoothstep(0.0, 0.5, border);
		col = mix(gap_color.rgb, stone_col, stone);
	} else if (pattern == 1) {
		float n = vnoise(wp * 3.0) * 0.6 + vnoise(wp * 11.0) * 0.4;
		col = mix(color_a.rgb, color_b.rgb, n);
		float pebble = step(0.93, hash21(floor(wp * 14.0)));
		col = mix(col, gap_color.rgb, pebble * 0.5);
	} else if (pattern == 2) {
		float n = vnoise(wp * 2.2) * 0.55 + vnoise(wp * 7.0) * 0.45;
		col = mix(color_a.rgb, color_b.rgb, smoothstep(0.25, 0.8, n));
	} else {
		float n = vnoise(wp * 8.0);
		col = mix(color_a.rgb, color_b.rgb, n);
	}
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	ROUGHNESS = 1.0;
	ALPHA = mask * opacity;
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
}
