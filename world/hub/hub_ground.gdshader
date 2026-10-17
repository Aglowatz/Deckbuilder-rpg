shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;
// Overnight Oct 16: the hub's land beyond the town (HubLand): painted grass in world space with slow large-scale colour drift (meadow / darker woods / dry grass),
// so the land reads as one continuous country instead of a sea. `woods` and `dry` are world-space patches baked into a small mask texture (r = woods, g = dry, b = road dust).

uniform sampler2D grass_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mask_tex : filter_linear, repeat_disable;
uniform vec4 mask_rect = vec4(-200.0, -200.0, 450.0, 450.0);
uniform float tile_size = 9.0;
uniform vec3 woods_tint : source_color = vec3(0.62, 0.74, 0.52);
uniform vec3 dry_tint : source_color = vec3(1.08, 0.98, 0.72);
// The Gainlands gorge: a rectangle (centre, the road's direction, half sizes along / across) cut out of the land; zero size = none.
uniform vec3 gorge_center = vec3(0.0);
uniform vec3 gorge_along = vec3(0.0, 0.0, 1.0);
uniform vec2 gorge_size = vec2(0.0);

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 g = v_world.xz - gorge_center.xz;
	vec2 along_dir = normalize(gorge_along.xz);
	float ga = abs(dot(g, along_dir));
	float gc = abs(dot(g, vec2(-along_dir.y, along_dir.x)));
	if (gorge_size.x > 0.0 && ga < gorge_size.x && gc < gorge_size.y) {
		discard;
	}
	vec2 p = v_world.xz / tile_size;
	vec3 grass = texture(grass_tex, p).rgb * vec3(1.04, 1.08, 0.96);
	vec3 dirt = texture(dirt_tex, p * 0.7).rgb;
	vec2 m_uv = (v_world.xz - mask_rect.xy) / mask_rect.zw;
	vec3 m = texture(mask_tex, m_uv).rgb;
	vec3 col = grass * mix(vec3(1.0), woods_tint, m.r) * mix(vec3(1.0), dry_tint, m.g);
	col = mix(col, dirt, m.b);
	ALBEDO = col;
	EMISSION = ALBEDO * 0.27;
	ROUGHNESS = 1.0;
}
