shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_disabled;
// Painted liquid (the Endless Buffet's gravy rivers and ponds): the painted surface texture drifting slowly along `flow_dir` in two layers at different speeds so it reads as
// gentle current, under the game's toon bands with one hard glossy highlight band. World-space, so a long ribbon and a round pond share the same flow.

#include "res://assets/shaders/style_painted_common.gdshaderinc"

global uniform vec3 style_highlight;
global uniform float style_band_soft;
global uniform float style_desaturate;

uniform sampler2D liquid_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 flow_dir = vec2(1.0, 0.0);
uniform float flow_speed = 0.18;
uniform float tile = 5.0;
uniform vec4 tint : source_color = vec4(1.0);
uniform float alpha = 0.95;
uniform float glow = 0.16;
uniform float gloss = 0.5;

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 dir = normalize(flow_dir);
	vec2 uv = v_world.xz / tile;
	vec3 a = texture(liquid_tex, uv + dir * TIME * flow_speed / tile * 3.0).rgb;
	vec3 b = texture(liquid_tex, uv * 0.63 + vec2(0.37, 0.11) + dir * TIME * flow_speed * 0.55 / tile * 3.0).rgb;
	vec3 col = mix(a, b, 0.45) * tint.rgb;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(luma), style_desaturate);
	ALBEDO = col;
	EMISSION = col * glow;
	ALPHA = alpha;
	ROUGHNESS = 0.2;
}

void light() {
	float t = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float b2;
	DIFFUSE_LIGHT += toon_bands(LIGHT_COLOR, t, style_band_soft, style_highlight, 0.74, 0.98, b2);
	float spec = smoothstep(0.93, 0.96, dot(NORMAL, normalize(LIGHT + VIEW))) * ATTENUATION;
	DIFFUSE_LIGHT += LIGHT_COLOR * spec * gloss / PI * 2.0;
}
