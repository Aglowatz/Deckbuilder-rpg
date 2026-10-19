shader_type spatial;
// Overnight Oct 18, Phase 2 cycle 15: the endless floor under a zone (WorldScenery's apron) as big dim tiles instead of one flat colour -
// faint grout lines and a little brightness change per tile, unshaded so the scene fog still dissolves it into the background.
render_mode unshaded, cull_disabled;

uniform vec4 base_color : source_color = vec4(0.31, 0.36, 0.35, 1.0);
uniform float tile_size = 4.0;
uniform float grout_width = 0.035;
uniform float grout_darken = 0.16;
uniform float tile_variation = 0.07;

varying vec3 world_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 cell = world_pos.xz / tile_size;
	vec2 id = floor(cell);
	vec2 f = fract(cell);
	float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y));
	float grout = 1.0 - smoothstep(grout_width * 0.5, grout_width, edge);
	float shade = 1.0 + (hash(id) - 0.5) * 2.0 * tile_variation;
	vec3 color = base_color.rgb * shade;
	color = mix(color, color * (1.0 - grout_darken), grout);
	ALBEDO = color;
}
