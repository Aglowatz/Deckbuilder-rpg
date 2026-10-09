shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;
// Reusable painted terrain (docs/art/style_guide.md, "Painted textures"). Up to five ground layers (layer 0 is the base, 1..4 are painted over it), a triplanar cliff material for
// steep faces, and the game's toon bands. Per layer, the data (data/art/texture_presets.json) picks how its mask is made:
//   0 base   1 key   the vertex colour the zone builder painted (the layout's own paths/rock/floor colours are the painted mask)
//   2 noise  soft two-octave noise            3 splat  a painted mask texture (R,G,B,A = layer 1..4)       4 disc  a noisy-edged disc (plaza)
// Anti-tiling: stochastic triangle-grid sampling (random rotation + offset per triangle), large-scale value/tint patches, and a distance blend to a big, low-frequency
// copy of each layer. Normal maps only lean the surface a little and only within `normal_far` metres (painted, not embossed).

#include "res://assets/shaders/style_painted_common.gdshaderinc"

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_ground_sat;

uniform sampler2D l0_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D l0_n : filter_linear_mipmap, repeat_enable;
uniform sampler2D l1_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D l1_n : filter_linear_mipmap, repeat_enable;
uniform sampler2D l2_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D l2_n : filter_linear_mipmap, repeat_enable;
uniform sampler2D l3_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D l3_n : filter_linear_mipmap, repeat_enable;
uniform sampler2D l4_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D l4_n : filter_linear_mipmap, repeat_enable;
uniform sampler2D cliff_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D splat : filter_linear, repeat_disable;

uniform int layer_count = 1;
uniform bool has_splat = false;
// 64x64 random value lattice: hardware bilinear filtering gives value noise in one tap (the iGPU is ALU-bound on hash-based noise).
uniform sampler2D noise_tex : filter_linear, repeat_enable;
// x = mode, y = splat channel (mode 3), z = softness, w = noise warp of the mask edge.
uniform vec4 layer_mode[5];
// mode 1: rgb = vertex colour to match (linear), a = match radius. mode 4: xy = centre (x,z), z = radius.
uniform vec4 layer_key[5];
// mode 2: x = noise scale (1/m), y = threshold, z = noise seed.
uniform vec4 layer_noise[5];
// rgb = the colour the builder painted for this layer (vertex colour tint is the ratio vertex/ref), a = how much of the original hue is kept (0..1).
uniform vec4 layer_ref[5];
// x = 1 for oriented art (plowed rows, planks, tiles): the stochastic tiling then shifts the texture but never rotates it.
uniform vec4 layer_extra[5];
// Metres per texture repeat.
uniform float layer_tile[5];
uniform float cliff_tile = 4.0;
uniform vec3 cliff_tint = vec3(1.0);
uniform float cliff_keep = 0.25;
uniform vec4 splat_rect = vec4(0.0, 0.0, 1.0, 1.0);

uniform float macro_amount = 0.2;
uniform float tint_amount = 0.5;
uniform float normal_strength = 0.5;
uniform float normal_far = 12.0;
uniform float sheen = 0.1;
uniform float brightness = 1.0;
uniform vec3 color_mul = vec3(1.0);
uniform float flatten = 0.85;
uniform float far_blend_start = 22.0;
uniform float far_blend_end = 46.0;
uniform float stochastic_far = 34.0;
// Optional soft dithered edge (overlay grids that sit on top of other ground): centre x,z, start, end radius. fade_end <= 0 disables it.
uniform vec4 edge_fade = vec4(0.0, 0.0, 0.0, 0.0);
// Flow (gravy rivers): scroll speed in m/s along flow_dir, 0 = still.
uniform float flow_speed = 0.0;
uniform vec2 flow_dir = vec2(1.0, 0.3);
uniform float brush_grain = 0.04;

float tnoise(vec2 p) {
	return texture(noise_tex, (p + 0.5) / 64.0).r;
}

float tfbm(vec2 p) {
	return tnoise(p) * 0.6 + tnoise(p * 2.13 + 7.0) * 0.4;
}

varying vec3 v_world;
varying float v_up;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_up = normalize(mat3(MODEL_MATRIX) * NORMAL).y;
}

void sample_layer(sampler2D a, sampler2D n, Tri t, vec2 p, vec2 dpx, vec2 dpy, float tile, bool aligned, bool plain, float dist_cam, bool want_normal, out vec3 col, out vec3 nr) {
	if (plain) {
		// Strictly regular art (checkers, stripes, tiles): one ordinary tap, no stochastic blending (it would smear the grid).
		col = textureGrad(a, p / tile, dpx / tile, dpy / tile).rgb;
		nr = vec3(0.0, 0.0, 0.8);
		if (want_normal && dist_cam < normal_far) {
			vec3 packed = textureGrad(n, p / tile, dpx / tile, dpy / tile).rgb;
			nr = vec3((packed.xy * 2.0 - 1.0) * vec2(1.0, -1.0), packed.z);
		}
		return;
	}
	nr = vec3(0.0, 0.0, 0.9);
	if (dist_cam < stochastic_far) {
		col = tri_color_grad(a, t, p, dpx, dpy, tile, aligned);
		if (want_normal && dist_cam < normal_far) {
			nr = tri_nr_grad(n, t, p, dpx, dpy, tile, aligned);
		}
	} else {
		col = texture(a, p / tile).rgb;
	}
	// Distance blend: a big, slow copy hides whatever repetition the stochastic tiling leaves far away.
	float far = smoothstep(far_blend_start, far_blend_end, dist_cam);
	if (far > 0.001) {
		vec3 big = texture(a, p / tile * 0.21 + 0.31).rgb;
		col = mix(col, big, far * 0.55);
	}
}

float layer_weight(int i, vec3 vc, vec2 p, float splat_value) {
	if (int(layer_mode[i].x + 0.5) == 3 && splat_value < 0.08) {
		return 0.0;
	}
	vec4 m = layer_mode[i];
	int mode = int(m.x + 0.5);
	float edge_noise = m.w > 0.0 && mode != 2 ? (tnoise(p * 0.9 + float(i) * 13.0) * 0.65 + tnoise(p * 2.1 + float(i) * 7.0) * 0.35 - 0.5) * m.w : 0.0;
	if (mode == 1) {
		float d = distance(vc, layer_key[i].rgb) + edge_noise * 0.4;
		return 1.0 - smoothstep(layer_key[i].a * (1.0 - m.z), layer_key[i].a, d);
	}
	if (mode == 2) {
		float v = tfbm(p * layer_noise[i].x + layer_noise[i].z) + (tnoise(p * layer_noise[i].x * 6.0 + 3.0) - 0.5) * 0.22;
		return smoothstep(layer_noise[i].y, layer_noise[i].y + max(m.z, 0.01), v);
	}
	if (mode == 3) {
		return smoothstep(0.5 - m.z, 0.5 + m.z, splat_value + edge_noise);
	}
	if (mode == 4) {
		float d = length(p - layer_key[i].xy) + edge_noise * 1.2;
		return 1.0 - smoothstep(layer_key[i].z - max(m.z, 0.05) * 4.0, layer_key[i].z + 0.1, d);
	}
	return 1.0;
}

void fragment() {
	vec2 p = v_world.xz;
	vec2 dpx = dFdx(p);
	vec2 dpy = dFdy(p);
	float dist_cam = distance(v_world, CAMERA_POSITION_WORLD);
	vec3 vc = COLOR.rgb;
	vc = mix(pow((vc + vec3(0.055)) / 1.055, vec3(2.4)), vc / 12.92, vec3(lessThan(vc, vec3(0.04045))));
	float ground = smoothstep(0.55, 0.85, abs(v_up));

	vec4 splat_v = vec4(0.0);
	vec2 splat_uv = (p - splat_rect.xy) / splat_rect.zw;
	if (has_splat) {
		splat_v = texture(splat, clamp(splat_uv, vec2(0.0), vec2(1.0)));
	}

	Tri tri = make_tri(p, 7.0, 1.0, 5.0);
	vec3 col = vec3(0.0);
	vec3 nr = vec3(0.0, 0.0, 0.9);
	float weight_sum_check = 0.0;
	for (int i = 0; i < layer_count; i++) {
		float sv = i == 1 ? splat_v.r : (i == 2 ? splat_v.g : (i == 3 ? splat_v.b : splat_v.a));
		float w = i == 0 ? 1.0 : layer_weight(i, vc, p, sv);
		if (w < 0.004) {
			continue;
		}
		vec3 c;
		vec3 n;
		if (i == 0) {
			sample_layer(l0_a, l0_n, tri, p, dpx, dpy, layer_tile[0], layer_extra[0].x > 0.5, layer_extra[0].y > 0.5, dist_cam, w > 0.35, c, n);
		} else if (i == 1) {
			sample_layer(l1_a, l1_n, tri, p, dpx, dpy, layer_tile[1], layer_extra[1].x > 0.5, layer_extra[1].y > 0.5, dist_cam, w > 0.35, c, n);
		} else if (i == 2) {
			sample_layer(l2_a, l2_n, tri, p, dpx, dpy, layer_tile[2], layer_extra[2].x > 0.5, layer_extra[2].y > 0.5, dist_cam, w > 0.35, c, n);
		} else if (i == 3) {
			sample_layer(l3_a, l3_n, tri, p, dpx, dpy, layer_tile[3], layer_extra[3].x > 0.5, layer_extra[3].y > 0.5, dist_cam, w > 0.35, c, n);
		} else {
			sample_layer(l4_a, l4_n, tri, p, dpx, dpy, layer_tile[4], layer_extra[4].x > 0.5, layer_extra[4].y > 0.5, dist_cam, w > 0.35, c, n);
		}
		// Keep the builder's hue: tint by vertex colour relative to the colour the builder painted for this layer.
		vec3 ratio = clamp(vc / max(layer_ref[i].rgb, vec3(0.02)), vec3(0.55), vec3(1.7));
		c *= mix(vec3(1.0), ratio, layer_ref[i].a) * layer_noise[i].w;
		col = i == 0 ? c : mix(col, c, w);
		nr = i == 0 ? n : mix(nr, n, w);
	}

	// Steep faces: triplanar cliff material (cliffs, island undersides, table rims).
	float cliff = 1.0 - ground;
	vec3 slope_lean = vec3(nr.xy, 0.0);
	if (cliff > 0.01) {
		vec3 world_n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
		vec3 rock = triplanar_color(cliff_a, v_world, world_n, cliff_tile);
		float vl = dot(vc, vec3(0.299, 0.587, 0.114));
		rock *= cliff_tint * mix(vec3(1.0), clamp(vc / max(vl, 0.02), vec3(0.6), vec3(1.6)), cliff_keep) * clamp(0.55 + vl * 1.4, 0.6, 1.25);
		col = mix(col, rock, cliff);
		nr.xy *= ground;
	}

	// Large-scale value + tint variation (the tile grid never lines up with it).
	float macro = tfbm(p * 0.09 + 40.0) * 0.55 + tnoise(p * 0.27 + 5.0) * 0.45;
	float tint_n = tnoise(p * 0.06 + 31.0);
	col *= 1.0 + (macro - 0.5) * 2.0 * macro_amount * ground;
	col *= mix(vec3(1.0), mix(vec3(1.07, 1.02, 0.9), vec3(0.92, 1.0, 1.08), tint_n), tint_amount * ground);
	col *= 1.0 + (tnoise(p * 7.0) - 0.5) * 2.0 * brush_grain;
	col *= brightness * color_mul;

	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, mix(1.0, style_ground_sat, ground));
	col = mix(col, vec3(luma), style_desaturate);
	if (flow_speed > 0.0) {
		float shimmer = tnoise(p * 2.2 + normalize(flow_dir) * TIME * flow_speed * 2.0) * 0.5 + tnoise(p * 5.0 - normalize(flow_dir) * TIME * flow_speed * 3.0) * 0.5;
		col *= 0.92 + shimmer * 0.2;
	}
	ALBEDO = col;
	ROUGHNESS = nr.z;

	vec3 up_view = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	vec3 flat_normal = normalize(mix(NORMAL, up_view, flatten * ground));
	float fade_normal = 1.0 - smoothstep(normal_far * 0.6, normal_far, dist_cam);
	vec2 lean = nr.xy * normal_strength * fade_normal * ground;
	vec3 n_world = normalize(vec3(lean.x, 1.0, lean.y));
	vec3 leaned = normalize((VIEW_MATRIX * vec4(n_world, 0.0)).xyz);
	// The leaned normal is relative to straight up; on tilted ground keep the mesh's own shading.
	NORMAL = normalize(mix(flat_normal, normalize(flat_normal + (leaned - up_view)), ground));

	if (edge_fade.w > 0.0) {
		float fade = 1.0 - smoothstep(edge_fade.z, edge_fade.w, length(p - edge_fade.xy));
		if (fade < hash21(floor(FRAGCOORD.xy))) {
			discard;
		}
	}
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	vec3 half_vec = normalize(LIGHT + VIEW);
	float glint = smoothstep(0.55, 0.9, pow(max(dot(NORMAL, half_vec), 0.0), mix(6.0, 40.0, 1.0 - ROUGHNESS))) * (1.0 - ROUGHNESS) * sheen * b2;
	DIFFUSE_LIGHT += LIGHT_COLOR * (level + glint) / PI * mix(vec3(1.0), style_highlight, b2);
}
