shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_disabled;
// A painted decal (DEC- art) laid on ground, roads or walls: the texture's own alpha, tinted/faded per vertex colour, lit with the game's toon bands. One mesh per decal id.

#include "res://assets/shaders/style_painted_common.gdshaderinc"

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;
global uniform float style_paint;

uniform sampler2D decal_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float glow = 0.0;
uniform float fade_start = 40.0;
uniform float fade_end = 60.0;

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 t = texture(decal_tex, UV);
	vec3 col = t.rgb * COLOR.rgb;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	EMISSION = col * glow;
	float dist_cam = distance(v_world, CAMERA_POSITION_WORLD);
	ALPHA = t.a * COLOR.a * style_paint * (1.0 - smoothstep(fade_start, fade_end, dist_cam));
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float b2;
	DIFFUSE_LIGHT += toon_bands(LIGHT_COLOR, t, style_band_soft, style_highlight, 0.74, 0.98, b2);
}
