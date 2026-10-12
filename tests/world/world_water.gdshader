shader_type spatial;
render_mode depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;
// Town water for the World Look Test (docs/art/world_look_test.md): the painted TEX-TOWN-WATER texture in world space, two layers drifting against each other (gentle
// ripples), animated sparkles and a slow patchy depth tint. Opaque on purpose: the town's outline pass reads the opaque depth, and a see-through water would show the
// outlines of the tiles under it. (An earlier version read the depth texture for shoreline foam; the DEC-SHOREFOAM cards do that job now.)
// Used for the hex water tiles and for the huge plane that runs out to the horizon, so there is no water edge anywhere.


uniform sampler2D water_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 shallow_tint : source_color = vec3(1.0, 1.0, 0.95);
uniform vec3 deep_tint : source_color = vec3(0.52, 0.7, 0.95);
uniform float tile_size = 14.0;
uniform float flow_speed = 1.0;
uniform float lift = 0.26;
uniform float sparkle_strength = 1.6;

varying vec3 v_world;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_world.xz / tile_size;
	float t = TIME * 0.02 * flow_speed;
	vec2 uv_a = p + vec2(t, t * 0.55);
	// The second layer is turned and a little finer so the two never line up.
	vec2 uv_b = vec2(p.x * 0.866 - p.y * 0.5, p.x * 0.5 + p.y * 0.866) * 1.37 + vec2(-t * 0.8, t * 1.1) + 0.31;
	vec3 a = texture(water_tex, uv_a).rgb;
	vec3 b = texture(water_tex, uv_b).rgb;
	vec3 col = mix(a, b, 0.42);
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	// A slow, wide patchy tint (deeper blue / shallower turquoise) in place of a true depth read.
	float patch = 0.5 + 0.5 * sin(v_world.x * 0.045 + t * 20.0) * sin(v_world.z * 0.05 - t * 14.0);
	col *= mix(shallow_tint, deep_tint, 0.45 + 0.45 * patch);
	// Glints: the brightest specks of the texture, twinkling.
	float spec = smoothstep(0.72, 0.95, luma);
	float twinkle = 0.55 + 0.45 * sin(TIME * 2.2 + hash21(floor(uv_a * 40.0)) * 40.0);
	float sparkle = spec * twinkle * sparkle_strength;
	ALBEDO = col;
	EMISSION = col * lift + vec3(1.0, 0.95, 0.8) * sparkle * 0.55;
	ROUGHNESS = 1.0;
}
