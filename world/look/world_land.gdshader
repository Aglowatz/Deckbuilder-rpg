shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;
// The far shore (WorldScenery): a flat ring of painted grass between the treeline and the water, with a sandy lip on its water side.
// UV.x runs along the ring, UV.y from the water side (0) to the land side (1).

uniform sampler2D grass_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D sand_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float tile_size = 9.0;

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_world.xz / tile_size;
	vec3 grass = texture(grass_tex, p).rgb;
	vec3 sand = texture(sand_tex, p * 0.8).rgb;
	float sandy = 1.0 - smoothstep(0.0, 0.18, UV.y);
	ALBEDO = mix(grass * vec3(0.95, 1.0, 0.85), sand, sandy);
	EMISSION = ALBEDO * 0.22;
	ROUGHNESS = 1.0;
}
