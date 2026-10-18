shader_type spatial;
// Overnight Oct 17, Part 3: the glint over an unopened chest. A handful of camera-facing quads (one ArrayMesh); each quad's
// vertices carry its centre in VERTEX, its corner in UV and a phase in COLOR.r. Every glint flashes briefly, at its own
// moment, as a four-point star with a soft core. `fade` (0..1) is set by ChestSparkle from the hero's distance.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, skip_vertex_transform, fog_disabled;

uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(1.0, 0.88, 0.5, 1.0);
uniform float size = 0.2;
uniform float speed = 0.45;

varying float v_glint;

void vertex() {
	float cycle = fract(TIME * speed + COLOR.r);
	// A quick flash early in each cycle, dark the rest of the time.
	v_glint = smoothstep(0.0, 0.08, cycle) * (1.0 - smoothstep(0.08, 0.3, cycle));
	vec2 corner = UV * 2.0 - 1.0;
	vec3 centre = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	centre.xy += corner * size * (0.35 + 0.65 * v_glint);
	VERTEX = centre;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float star = max(0.0, 1.0 - abs(p.x) * 9.0) * max(0.0, 1.0 - abs(p.y));
	star += max(0.0, 1.0 - abs(p.y) * 9.0) * max(0.0, 1.0 - abs(p.x));
	float core = max(0.0, 1.0 - length(p) * 2.8);
	float a = clamp(star + core * 1.4, 0.0, 1.0) * v_glint * fade;
	ALBEDO = tint.rgb * a;
	ALPHA = a;
}
