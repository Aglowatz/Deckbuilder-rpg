shader_type spatial;
render_mode unshaded, cull_back;
// Nov 25 night (Part B): the Cracked Mirror's glass - a deep silvered blue with a slow sheen sweeping across it, cracks radiating from an
// impact point (thin, bright, pulsing gently as if lit from behind) and two broken rings round the impact. Procedural: no texture.

uniform vec4 glass_dark : source_color = vec4(0.05, 0.07, 0.13, 1.0);
uniform vec4 glass_light : source_color = vec4(0.30, 0.44, 0.64, 1.0);
uniform vec4 crack_color : source_color = vec4(0.80, 0.92, 1.0, 1.0);
uniform vec2 impact = vec2(0.58, 0.40);
uniform float sheen_speed = 0.11;
uniform float pulse_speed = 1.6;

float crack_line(vec2 d, float angle, float reach) {
	vec2 dir = vec2(cos(angle), sin(angle));
	float along = dot(d, dir);
	if (along < 0.0 || along > reach) {
		return 0.0;
	}
	float across = abs(d.x * dir.y - d.y * dir.x);
	float width = mix(0.012, 0.003, along / reach);
	return 1.0 - smoothstep(width * 0.4, width, across);
}

void fragment() {
	vec2 uv = UV;
	vec2 d = (uv - impact) * vec2(1.0, 1.85);
	float shade = smoothstep(1.2, 0.0, length(uv - vec2(0.5, 0.35)));
	vec3 base = mix(glass_dark.rgb, glass_light.rgb, shade * 0.85);
	// the sheen: a soft diagonal band sweeping across every few seconds
	float s = fract(TIME * sheen_speed + (uv.x * 0.7 + uv.y * 0.5));
	float band = smoothstep(0.0, 0.05, s) * (1.0 - smoothstep(0.05, 0.14, s));
	base += vec3(0.55, 0.65, 0.8) * band * 0.35;
	// the cracks: nine lines from the impact, and two broken rings
	float cracks = 0.0;
	cracks = max(cracks, crack_line(d, 0.35, 0.9));
	cracks = max(cracks, crack_line(d, 1.2, 0.75));
	cracks = max(cracks, crack_line(d, 1.95, 1.0));
	cracks = max(cracks, crack_line(d, 2.6, 0.6));
	cracks = max(cracks, crack_line(d, 3.3, 0.85));
	cracks = max(cracks, crack_line(d, 3.9, 1.1));
	cracks = max(cracks, crack_line(d, 4.6, 0.7));
	cracks = max(cracks, crack_line(d, 5.2, 1.2));
	cracks = max(cracks, crack_line(d, 5.85, 0.65));
	float r = length(d);
	float ring1 = (1.0 - smoothstep(0.004, 0.009, abs(r - 0.12))) * step(0.5, fract(atan(d.y, d.x) * 1.3));
	float ring2 = (1.0 - smoothstep(0.004, 0.008, abs(r - 0.27))) * step(0.35, fract(atan(d.y, d.x) * 0.9 + 0.2));
	cracks = max(cracks, max(ring1, ring2));
	float pulse = 0.7 + 0.3 * sin(TIME * pulse_speed);
	vec3 colour = mix(base, crack_color.rgb * (1.1 + 0.5 * pulse), cracks);
	// a cold glow round the impact
	colour += crack_color.rgb * 0.22 * pulse * (1.0 - smoothstep(0.0, 0.25, r));
	ALBEDO = colour;
}
