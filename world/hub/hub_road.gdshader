shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled, depth_draw_never;
// Overnight Oct 16: a road of the hub (HubLand): its texture along the ribbon with soft, slightly ragged edges, so it sinks into the grass.
// UV.x runs across (0..1), UV.y is metres along.

uniform sampler2D road_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float width = 3.0;

void fragment() {
	vec2 uv = vec2(UV.x * width, UV.y) / 3.0;
	vec3 col = texture(road_tex, uv).rgb * tint;
	float edge = min(UV.x, 1.0 - UV.x) * width;
	float ragged = 0.35 + 0.25 * sin(UV.y * 1.7) + 0.15 * sin(UV.y * 4.3 + UV.x * 3.0);
	ALBEDO = col;
	EMISSION = col * 0.22;
	ROUGHNESS = 1.0;
	ALPHA = smoothstep(0.0, max(0.2, ragged), edge);
}
