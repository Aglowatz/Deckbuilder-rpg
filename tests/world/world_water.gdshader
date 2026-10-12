shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;
// Town water for the World Look Test (docs/art/world_look_test.md): the painted TEX-TOWN-WATER texture in world space, two layers drifting against each other (gentle
// ripples), a slightly deeper colour where the water is deeper (depth texture), animated sparkles, and a thin foam line where anything touches the surface.
// Used for the hex water tiles and for the huge plane that runs out to the horizon, so there is no water edge anywhere.


uniform sampler2D water_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec3 shallow_tint : source_color = vec3(1.08, 1.06, 0.98);
uniform vec3 deep_tint : source_color = vec3(0.62, 0.78, 0.98);
uniform float tile_size = 14.0;
uniform float flow_speed = 1.0;
uniform float lift = 0.32;
uniform float sparkle_strength = 1.6;
uniform vec3 foam_color : source_color = vec3(1.0, 0.99, 0.94);

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
	// Depth below the surface: shallow turquoise near shores, deeper blue away from them.
	float depth = texture(depth_tex, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float diff = max(-view.z - (-VERTEX.z), 0.0);
	float deep = smoothstep(0.15, 3.2, diff);
	col *= mix(shallow_tint, deep_tint, deep);
	// Glints: the brightest specks of the texture, twinkling.
	float spec = smoothstep(0.72, 0.95, luma);
	float twinkle = 0.55 + 0.45 * sin(TIME * 2.2 + hash21(floor(uv_a * 40.0)) * 40.0);
	float sparkle = spec * twinkle * sparkle_strength;
	// Foam line where geometry meets the surface.
	float edge = 1.0 - smoothstep(0.0, 0.22, diff);
	float wob = 0.6 + 0.4 * sin(v_world.x * 3.1 + TIME * 1.3) * sin(v_world.z * 2.7 - TIME * 1.1);
	col = mix(col, foam_color, edge * wob * 0.85);
	ALBEDO = col;
	EMISSION = col * lift + vec3(1.0, 0.95, 0.8) * sparkle * 0.55;
	ROUGHNESS = 1.0;
}
