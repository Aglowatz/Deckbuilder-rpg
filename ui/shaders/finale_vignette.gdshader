shader_type canvas_item;
// Fable Nov 12 (Part 4.2, the Primm build-up): a coloured vignette laid over the battleboard in Primm's Castle. It closes in from the
// corners, deeper with every room cleared, and breathes slowly (`pulse` 0 = still: Reduce motion, the Low-end preset). In the final
// phases thin cracks of light drift across it. Under the cards and the HUD: it never covers anything the player reads.
uniform vec4 tint : source_color = vec4(0.42, 0.2, 0.7, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.3;
uniform float pulse : hint_range(0.0, 1.0) = 0.0;
uniform float cracks : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 centred = UV - vec2(0.5);
	centred.x *= 1.35;
	float edge = smoothstep(0.28, 0.82, length(centred));
	float breath = 1.0 + pulse * 0.22 * sin(TIME * 1.3);
	float alpha = edge * strength * breath;
	vec3 colour = tint.rgb;
	if (cracks > 0.0) {
		// a few slanted hairlines of light, drifting; brightest near the edges where the vignette is
		float line = abs(fract((UV.x * 1.7 + UV.y * 0.9) * 3.0 + hash(floor(vec2(UV.y * 6.0, 1.0))) + TIME * 0.02 * pulse) - 0.5);
		float glint = (1.0 - smoothstep(0.0, 0.012, line)) * edge * cracks;
		colour = mix(colour, vec3(1.0, 0.9, 1.0), glint * 0.8);
		alpha = max(alpha, glint * 0.5);
	}
	COLOR = vec4(colour, clamp(alpha, 0.0, 0.85));
}
