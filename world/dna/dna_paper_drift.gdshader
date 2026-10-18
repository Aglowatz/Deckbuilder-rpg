shader_type spatial;
render_mode cull_disabled, unshaded;
// Overnight Oct 17 (Phase 2 cycle 18): loose paperwork drifting in the D.N.A.'s limbo. Each sheet tumbles about its own axis and bobs slowly;
// INSTANCE_CUSTOM = (phase, spin speed, axis angle, bob height).
uniform vec4 paper : source_color = vec4(0.84, 0.86, 0.8, 1.0);
uniform vec4 ink : source_color = vec4(0.55, 0.58, 0.55, 1.0);

mat3 axis_rotation(vec3 axis, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	float t = 1.0 - c;
	return mat3(
		vec3(t * axis.x * axis.x + c, t * axis.x * axis.y + s * axis.z, t * axis.x * axis.z - s * axis.y),
		vec3(t * axis.x * axis.y - s * axis.z, t * axis.y * axis.y + c, t * axis.y * axis.z + s * axis.x),
		vec3(t * axis.x * axis.z + s * axis.y, t * axis.y * axis.z - s * axis.x, t * axis.z * axis.z + c));
}

void vertex() {
	vec4 data = INSTANCE_CUSTOM;
	vec3 axis = normalize(vec3(cos(data.z), 0.6, sin(data.z)));
	mat3 spin = axis_rotation(axis, TIME * data.y + data.x * 6.2832);
	VERTEX = spin * VERTEX;
	NORMAL = spin * NORMAL;
	VERTEX.y += sin(TIME * 0.35 + data.x * 6.2832) * data.w;
}

void fragment() {
	// a few faint lines of "writing" across the sheet
	float lines = step(0.82, fract(UV.y * 7.0)) * step(0.12, UV.x) * step(UV.x, 0.88) * step(0.15, UV.y) * step(UV.y, 0.85);
	ALBEDO = mix(paper.rgb, ink.rgb, lines * 0.6);
	ALBEDO *= 0.7;
}
