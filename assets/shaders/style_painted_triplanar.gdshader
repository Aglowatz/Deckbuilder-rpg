shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_back;
// Triplanar painted material for surfaces without good UVs (cliffs, boulders, island undersides, cheese wheels): world-space projection on three axes blended by the
// normal (two taps at most), toned by the original flat colour (`tint`, kept as a subtle hue), under the game's toon bands. Switches with the global `style_paint`.

#include "res://assets/shaders/style_painted_common.gdshaderinc"

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_paint;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D flat_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float tile = 4.0;
uniform float keep_hue = 0.0;
uniform vec3 flat_color : source_color = vec3(0.6);
uniform float gloss = 0.0;
uniform float brightness = 1.0;

instance uniform float colour_keep : hint_range(0.0, 1.0) = 0.0;
instance uniform float occlusion_fade : hint_range(0.0, 1.0) = 0.0;

varying vec3 v_world;
varying vec3 v_normal;

const float BAYER[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

void fragment() {
	if (occlusion_fade > 0.0 && (BAYER[(int(FRAGCOORD.y) % 4) * 4 + (int(FRAGCOORD.x) % 4)] + 0.5) / 16.0 < occlusion_fade) {
		discard;
	}
	vec3 painted = triplanar_color(albedo_tex, v_world, normalize(v_normal), tile);
	float luma = dot(flat_color, vec3(0.299, 0.587, 0.114));
	vec3 chroma = clamp(flat_color / max(luma, 0.03), vec3(0.6), vec3(1.6));
	painted *= tint.rgb * mix(vec3(1.0), chroma, keep_hue) * brightness;
	// Painted mode off: the old flat colour.
	vec3 col = mix(flat_color * tint.rgb, painted, style_paint);
	float l2 = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(l2), style_desaturate * (1.0 - colour_keep));
	ALBEDO = col;
	ROUGHNESS = 1.0;
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float b2;
	DIFFUSE_LIGHT += toon_bands(LIGHT_COLOR, t, style_band_soft, style_highlight, 0.74, 0.98, b2);
	if (gloss > 0.0) {
		float spec = smoothstep(0.93, 0.96, dot(NORMAL, normalize(LIGHT + VIEW))) * ATTENUATION;
		DIFFUSE_LIGHT += LIGHT_COLOR * spec * gloss / PI * 2.0;
	}
}
