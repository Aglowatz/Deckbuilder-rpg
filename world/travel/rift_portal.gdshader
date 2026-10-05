shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// The torn-open rift of a Beefcake Rift Station (brief 10b): a jagged glowing tear with a swirling core.
// `width` is how far it is torn open (a thin seam while the station is dormant), `charge` its brightness.
uniform float charge : hint_range(0.0, 4.0) = 1.0;
uniform float width : hint_range(0.04, 1.0) = 0.55;
uniform vec4 core_color : source_color = vec4(0.3, 0.85, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.55, 0.2, 1.0);

void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;
	float ang = atan(p.y, p.x);
	float jag = 0.07 * sin(ang * 9.0 + TIME * 1.7) + 0.05 * sin(ang * 17.0 - TIME * 2.3) + 0.03 * sin(ang * 31.0 + TIME * 4.0);
	vec2 q = vec2(p.x / width, p.y);
	float d = length(q);
	float edge = 0.9 + jag;
	float inside = smoothstep(edge, edge - 0.12, d);
	float rim = smoothstep(edge - 0.3, edge - 0.05, d) * inside;
	float swirl = 0.5 + 0.5 * sin(d * 14.0 - TIME * 3.5 + ang * 2.0);
	vec3 col = mix(core_color.rgb * (0.4 + 0.6 * swirl), edge_color.rgb, rim);
	ALBEDO = col * charge;
	ALPHA = inside * clamp(0.35 + 0.65 * charge, 0.0, 1.0);
}
