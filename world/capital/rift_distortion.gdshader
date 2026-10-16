shader_type spatial;
// A lens of warped light around a rift: the screen behind a translucent sphere is sampled with a swirling offset, so the
// air round a tear in reality ripples and bends. Unshaded, no depth write, so it never hides the ground or the player. The
// lens has no visible edge (the art pass: the concept's rift has no bubble): the warp and a faint violet fade out toward the rim.
render_mode unshaded, cull_back, depth_draw_never, blend_mix;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform float strength : hint_range(0.0, 0.2) = 0.03;
uniform float speed : hint_range(0.0, 6.0) = 1.4;
uniform vec4 tint : source_color = vec4(0.7, 0.3, 1.0, 1.0);

void fragment() {
	float t = TIME * speed;
	vec3 n = normalize(NORMAL);
	float facing = clamp(n.z, 0.0, 1.0);
	float core = smoothstep(0.15, 0.85, facing);
	vec2 wobble = vec2(sin(SCREEN_UV.y * 36.0 + t), cos(SCREEN_UV.x * 28.0 - t * 1.3));
	vec2 offset = (n.xy * 0.5 + wobble * 0.35) * strength * core;
	vec3 col = texture(screen_tex, SCREEN_UV + offset).rgb;
	ALBEDO = mix(col, tint.rgb, 0.08 * core);
	ALPHA = core;
}
