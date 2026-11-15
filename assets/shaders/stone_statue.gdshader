shader_type spatial;
// Fable Nov 15 (Part 3): a statue cut from a painted figure - the picture's light and shade as weathered stone (its colours pulled to
// grey, a little of the ruler's colour left in), cut out by the picture's alpha. Unshaded, like the other painted cards, so it reads the
// same in every zone's light; the scene fog still takes it with distance.
render_mode unshaded, cull_disabled;

uniform sampler2D picture : source_color, filter_linear_mipmap;
uniform vec4 stone : source_color = vec4(0.62, 0.62, 0.66, 1.0);
uniform vec4 accent : source_color = vec4(0.5, 0.2, 0.2, 1.0);
uniform float accent_amount = 0.14;
uniform float keep_colour = 0.08;
uniform float brightness = 1.0;

void fragment() {
	vec4 texel = texture(picture, UV);
	if (texel.a < 0.5) {
		discard;
	}
	float value = dot(texel.rgb, vec3(0.3, 0.55, 0.15));
	// carved stone: lift the darks and flatten the lights a little, so it never reads as a black cut-out or a white ghost
	value = 0.22 + 0.7 * smoothstep(0.02, 0.95, value);
	vec3 carved = stone.rgb * value;
	carved = mix(carved, carved * (0.6 + accent.rgb), accent_amount);
	carved = mix(carved, texel.rgb, keep_colour);
	ALBEDO = carved * brightness;
}
