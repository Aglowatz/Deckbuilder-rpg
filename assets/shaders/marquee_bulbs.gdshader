shader_type spatial;
render_mode unshaded, shadows_disabled;
// The Shuffle House's marquee bulbs (Fable Nov 25): small warm lamps that glow and twinkle gently, each on its own slow beat
// (a MultiMesh; the beat comes from the instance's number). Bright enough for the bloom to pick up.

uniform vec4 warm : source_color = vec4(1.0, 0.86, 0.52, 1.0);
uniform float energy = 2.4;
uniform float twinkle = 0.22;

varying float beat;

void vertex() {
	beat = fract(float(INSTANCE_ID) * 0.61803);
}

void fragment() {
	float pulse = 1.0 - twinkle + twinkle * sin(TIME * (1.6 + beat * 2.2) + beat * 6.2832);
	ALBEDO = warm.rgb * energy * pulse;
}
