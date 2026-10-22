shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;
#include "res://assets/shaders/style_ground_light.gdshaderinc"
// Paths of the Environment Kit (PathTool): a dirt or cobble ground ribbon (mode 0) with a soft, noise-eaten edge so it melts into the grass, the DEC-PATHEDGE strip along each
// side (mode 1) and round worn patches at doorsteps and junctions (mode 2, DEC-WORNPATCH). The ground texture is the kit slot (ENV-GROUND-DIRTPATH / ENV-GROUND-COBBLE) projected
// in world space so adjoining pieces and the square share one pattern. Lit with the same toon bands as everything else, so the sun's shadows fall across the path.

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_ground_sat;

uniform int mode = 0;
uniform sampler2D surface_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D edge_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool edge_rgb = false;
uniform vec4 tint : source_color = vec4(1.0);
uniform float tile = 3.0;
uniform float edge_soft = 0.32;
uniform float edge_noise = 0.4;
uniform float seed = 0.0;
uniform float opacity = 1.0;
uniform float edge_tile = 4.0;

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

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wp = v_world.xz;
	vec3 ground = texture(surface_tex, wp / tile).rgb * tint.rgb;
	float n = vnoise(wp * 1.1 + seed) * 0.6 + vnoise(wp * 3.3 + seed * 2.0) * 0.4;
	float alpha = 1.0;
	vec3 col = ground;
	if (mode == 0) {
		float across = abs(UV.x * 2.0 - 1.0);
		float inner = 1.0 - across;
		alpha = smoothstep(0.0, edge_soft, inner - edge_noise * (n - 0.35));
		// a slightly worn, lighter lane down the middle
		col *= 1.0 + 0.06 * smoothstep(0.55, 0.0, across);
	} else if (mode == 1) {
		vec4 e = texture(edge_tex, vec2(UV.y / edge_tile, UV.x));
		alpha = e.a;
		if (edge_rgb) {
			col = e.rgb * tint.rgb;
		}
		alpha *= smoothstep(0.0, 0.08, UV.x);
	} else {
		vec4 e = texture(edge_tex, UV);
		alpha = e.a;
		if (edge_rgb) {
			col = e.rgb * tint.rgb;
		}
	}
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma), style_desaturate);
	col = mix(col, vec3(luma), (1.0 - style_ground_sat) * 0.6);
	ALBEDO = ground_light_apply(col, v_world, 0.0, 1.0, 1.0, SCREEN_UV.y);
	ROUGHNESS = 1.0;
	ALPHA = alpha * opacity;
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = mix(0.74 * b1, 0.98, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
}
