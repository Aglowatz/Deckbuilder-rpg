shader_type canvas_item;
// The minimap's picture inside UI-MINIMAP-FRAME (Overnight Nov 16, Part 2.7). The map is one texel per metre cell; stretched to the
// window it was a blur in the small forest and stair-stepped blocks in the Capital. Here every screen pixel takes the colour that holds
// the most bilinear weight among its four nearest cells, with a one-pixel soft edge: an edge between two kinds of ground is a crisp line,
// a diagonal staircase becomes a slanted line and corners are rounded. Also draws the dark backdrop and clips to the frame's circle.
uniform sampler2D map_tex : filter_nearest, repeat_disable;
uniform vec2 tex_size = vec2(64.0, 64.0);
// The part of the map shown, in texels.
uniform vec2 region_pos = vec2(0.0, 0.0);
uniform vec2 region_size = vec2(42.0, 42.0);
// The circle the picture is clipped to (the frame of the minimap); 0 or less = no clip (the full map draws the whole rectangle).
uniform float radius = 88.0;
// How many screen pixels the shown region is drawn across (for the one-pixel soft edge).
uniform float pixels_across = 176.0;
uniform vec4 backdrop : source_color = vec4(0.04, 0.05, 0.08, 0.9);
varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

vec4 cell(vec2 at) {
	return texture(map_tex, (at + 0.5) / tex_size);
}

float same(vec4 a, vec4 b) {
	vec4 d = abs(a - b);
	return max(max(d.r, d.g), max(d.b, d.a)) < 0.02 ? 1.0 : 0.0;
}

void fragment() {
	vec2 q = region_pos + UV * region_size - 0.5;
	vec2 base = floor(q);
	vec2 f = q - base;
	vec4 c0 = cell(base);
	vec4 c1 = cell(base + vec2(1.0, 0.0));
	vec4 c2 = cell(base + vec2(0.0, 1.0));
	vec4 c3 = cell(base + vec2(1.0, 1.0));
	float w0 = (1.0 - f.x) * (1.0 - f.y);
	float w1 = f.x * (1.0 - f.y);
	float w2 = (1.0 - f.x) * f.y;
	float w3 = f.x * f.y;
	float t0 = w0 + w1 * same(c0, c1) + w2 * same(c0, c2) + w3 * same(c0, c3);
	float t1 = w1 + w0 * same(c1, c0) + w2 * same(c1, c2) + w3 * same(c1, c3);
	float t2 = w2 + w0 * same(c2, c0) + w1 * same(c2, c1) + w3 * same(c2, c3);
	float t3 = w3 + w0 * same(c3, c0) + w1 * same(c3, c1) + w2 * same(c3, c2);
	vec4 best = c0;
	float best_t = t0;
	if (t1 > best_t) { best = c1; best_t = t1; }
	if (t2 > best_t) { best = c2; best_t = t2; }
	if (t3 > best_t) { best = c3; best_t = t3; }
	vec4 second = best;
	float second_t = 0.0;
	if (same(c0, best) < 0.5 && t0 > second_t) { second = c0; second_t = t0; }
	if (same(c1, best) < 0.5 && t1 > second_t) { second = c1; second_t = t1; }
	if (same(c2, best) < 0.5 && t2 > second_t) { second = c2; second_t = t2; }
	if (same(c3, best) < 0.5 && t3 > second_t) { second = c3; second_t = t3; }
	// texels per screen pixel: the lead of the winning colour changes by about two per texel across an edge
	float per_pixel = region_size.x / max(pixels_across, 1.0);
	float edge = clamp(0.5 + (best_t - second_t) / (4.0 * per_pixel), 0.0, 1.0);
	vec4 map = mix(second, best, edge);
	vec4 shown = vec4(mix(backdrop.rgb, map.rgb, map.a), max(backdrop.a, map.a));
	if (radius > 0.0) {
		float d = length(local_position - vec2(radius, radius));
		shown.a *= 1.0 - smoothstep(radius - 1.5, radius, d);
	}
	COLOR = shown;
}
