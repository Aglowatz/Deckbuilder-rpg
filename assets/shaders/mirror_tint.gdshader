shader_type canvas_item;
// Overnight Nov 4-5, Part 5 (The Shattered Gallery): a picture seen in cold silver glass - the Echoes' and The Perfect Copy's portraits are their
// originals' (or the hero's) art through this. Desaturated toward a cool silver, a soft sheen sweeping across, and the round medallion cut of
// circle_mask.gdshader when `circle` is on.
uniform bool circle = true;
uniform vec3 silver = vec3(0.78, 0.86, 0.96);
uniform float strength = 0.8;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float lum = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	vec3 cold = mix(base.rgb, vec3(lum) * silver * 1.15, strength);
	float band = UV.x + UV.y * 0.6 - mod(TIME * 0.25, 2.2) + 0.4;
	float sheen = smoothstep(0.0, 0.08, band) * (1.0 - smoothstep(0.08, 0.22, band));
	cold += vec3(0.35, 0.4, 0.45) * sheen;
	COLOR = vec4(cold, base.a) * COLOR;
	if (circle) {
		float d = distance(UV, vec2(0.5));
		COLOR.a *= 1.0 - smoothstep(0.47, 0.5, d);
	}
}
