shader_type spatial;
render_mode cull_back, diffuse_lambert;
// Overnight Nov 18 (the D.N.A. as one grand hall): the polished checker marble (DNA-FLOOR-MARBLE, a 2x2-square tile) and the red runners
// (DNA-FLOOR-RUNNER) under the chandeliers. Marble tiles in world metres; a runner's UVs come from its mesh (u across, v along in tiles).
// Low roughness and some specular so the warm lamps glint on the stone as in the concept painting; a faint per-tile tone shift keeps the
// repeat from reading as wallpaper.
global uniform float style_desaturate;
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool world_uv = true;
uniform float tile = 2.5;
uniform vec3 tint : source_color = vec3(1.0);
uniform float roughness_value = 0.32;
uniform float specular_value = 0.55;
uniform float desaturate_scale = 0.35;
varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = world_uv ? wpos.xz / tile : UV;
	vec3 c = texture(albedo_tex, uv).rgb * tint;
	if (world_uv) {
		c *= 0.94 + 0.08 * hash(floor(wpos.xz / tile));
	}
	ALBEDO = mix(c, vec3(dot(c, vec3(0.299, 0.587, 0.114))), style_desaturate * desaturate_scale);
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
}
