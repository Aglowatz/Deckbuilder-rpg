shader_type spatial;
render_mode depth_prepass_alpha, cull_back, diffuse_lambert, specular_disabled;
// The D.N.A.'s batched solid pieces (filing cabinets, cubicle partitions: hundreds per room, one merged mesh per chunk) with the camera occlusion fade computed PER PIECE
// (Gainlands correction GC-4, the rule for this zone: an indoor-feeling area never hides the player). Every vertex carries its piece in CUSTOM0 = (centre x, centre z,
// half width, top y), so the same test the painted cards use (kit_card.gdshader) runs here: a piece whose centre stands in the camera -> hero corridor, in front of the
// hero and tall enough to cross the sight line, fades to a smooth ghost. Plain alpha, never a dither. `hero_pos` is set every frame by DnaScene (y -1000 = off).
// Lit by the scene's lights (plain lambert plus the ambient, like the kit materials); textured with a kit surface tiled in metres (the UVs come in metres from DnaFadeMesh).

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo : source_color = vec4(1.0);
uniform bool use_texture = true;
uniform float tile = 2.56;
uniform vec3 hero_pos = vec3(0.0, -1000.0, 0.0);
uniform float fade_strength : hint_range(0.0, 1.0) = 0.86;
uniform float fade_reach = 1.1;
// Oct 19 (the office interior): the reach grows by this much for a piece at the lens (t = 0), so a full-height wall near the camera cuts away wide.
uniform float near_reach = 0.0;
// Fixes Oct 26 (10 m walls): a full-height wall that stands nearer the camera than the hero (along the view) fades whether or not it sits on the sight line,
// so the hero's whole room shows (a dollhouse cut at the hero's depth) instead of a slot through its near wall; walls beyond the hero stay up.
uniform bool cut_front = false;
// Fixes Oct 27 (walls popping): a full-height wall uses the ROOM cut instead of the hero sight line, the lens reach and the depth cut above. The hero's room (or
// corridor) is a floor rectangle (min x, min z, max x, max z); a wall piece fades when it stands in the region swept from the camera to that rectangle, before
// the rectangle along the ray - every wall that hides some of the room's floor, and nothing else: no fade by distance, and the room's other walls and every
// wall elsewhere stay solid. Every term is continuous in the camera's position, so a wall eases out as the camera glides instead of switching. Changing room
// blends up to three rectangles by weights that ease on the CPU (DnaRoomCut: the new room's weight rises to 1 over 0.6 s).
uniform bool room_cut = false;
uniform vec4 room_a = vec4(0.0, 0.0, -1.0, -1.0);
uniform vec4 room_b = vec4(0.0, 0.0, -1.0, -1.0);
uniform vec4 room_c = vec4(0.0, 0.0, -1.0, -1.0);
uniform vec3 room_w = vec3(1.0, 0.0, 0.0);
// Frosted glass (base alpha under 1) and the fluorescent tubes (emission) share the shader.
uniform float base_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float emission_strength = 0.0;
global uniform float style_desaturate;

varying float v_fade;

float cross2(vec2 a, vec2 b) {
	return a.x * b.y - a.y * b.x;
}

// Signed distance from p to the triangle (a, b, c) (negative inside; the usual 2D form).
float tri_distance(vec2 p, vec2 a, vec2 b, vec2 c) {
	vec2 e0 = b - a;
	vec2 e1 = c - b;
	vec2 e2 = a - c;
	vec2 v0 = p - a;
	vec2 v1 = p - b;
	vec2 v2 = p - c;
	vec2 p0 = v0 - e0 * clamp(dot(v0, e0) / max(dot(e0, e0), 1e-6), 0.0, 1.0);
	vec2 p1 = v1 - e1 * clamp(dot(v1, e1) / max(dot(e1, e1), 1e-6), 0.0, 1.0);
	vec2 p2 = v2 - e2 * clamp(dot(v2, e2) / max(dot(e2, e2), 1e-6), 0.0, 1.0);
	float s = cross2(e0, e2) >= 0.0 ? 1.0 : -1.0;
	vec2 d = min(min(vec2(dot(p0, p0), s * cross2(v0, e0)), vec2(dot(p1, p1), s * cross2(v1, e1))), vec2(dot(p2, p2), s * cross2(v2, e2)));
	return -sqrt(d.x) * sign(d.y);
}

// How much a piece at q hides the floor rectangle r from the camera at c (0 = not at all, 1 = fully in the way). An empty rectangle (max < min) = 0.
// The floor the camera can see past a wall is the union of the triangles (camera, edge) over the rectangle's edges that face the camera; a 1 m wall piece
// is fully cut when its centre is within half a metre of that union and stands again a metre out. Each edge's triangle counts as much as the camera stands
// outside that edge's line (none 0.3 m inside it, all of it half a metre out: a camera over the near wall's own cell cuts it fully, and the hero never stands
// close enough to a side wall to cut it), so nothing switches when the camera crosses a line. Corners are pulled in a quarter metre
// along their edges, so the wall cell diagonally past a corner (it hides no floor) stays up.
float room_fade(vec2 q, vec2 c, vec4 r) {
	if (r.z < r.x || r.w < r.y) {
		return 0.0;
	}
	vec2 lo = r.xy;
	vec2 hi = r.zw;
	float inset = min(0.25, 0.25 * min(hi.x - lo.x, hi.y - lo.y));
	// the four edges: (start, end, outward normal)
	vec2 a[4] = vec2[4](vec2(lo.x + inset, lo.y), vec2(hi.x, lo.y + inset), vec2(hi.x - inset, hi.y), vec2(lo.x, hi.y - inset));
	vec2 b[4] = vec2[4](vec2(hi.x - inset, lo.y), vec2(hi.x, hi.y - inset), vec2(lo.x + inset, hi.y), vec2(lo.x, lo.y + inset));
	vec2 n[4] = vec2[4](vec2(0.0, -1.0), vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(-1.0, 0.0));
	float line[4] = float[4](lo.y, hi.x, hi.y, lo.x);
	float fade = 0.0;
	for (int k = 0; k < 4; k++) {
		float outside = k == 0 ? line[k] - c.y : (k == 1 ? c.x - line[k] : (k == 2 ? c.y - line[k] : line[k] - c.x));
		float weight = smoothstep(-0.35, 0.65, outside);
		if (weight <= 0.0) {
			continue;
		}
		float dist = tri_distance(q, c, a[k], b[k]);
		fade = max(fade, weight * (1.0 - smoothstep(0.5, 1.3, dist)));
	}
	return fade;
}

varying vec3 v_tint;
// Fixes Oct 26: CUSTOM1.yzw = (disc u, disc v, 1) on a soft glow disc (DnaFadeMesh.disc): alpha and emission fall off round its centre, so a lamp's glow on
// its wall is a soft round pool with no edges (the old flat plate read as a rectangle).
varying vec3 v_disc;

void vertex() {
	vec3 origin = vec3(CUSTOM0.x, 0.0, CUSTOM0.y);
	float half_w = CUSTOM0.z;
	float top = CUSTOM0.w;
	// Oct 19: CUSTOM1.x = the piece's bottom (0 for walls and cabinets, the underside of a ceiling beam or light strip).
	float bottom = CUSTOM1.x;
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	// the sight line runs to the hero's body centre: a piece blocks when its span (bottom..top) covers the line where the piece stands
	vec3 hero = hero_pos + vec3(0.0, 0.4, 0.0);
	vec2 ab = hero.xz - cam.xz;
	float ab_len2 = max(dot(ab, ab), 0.0001);
	float ab_len = sqrt(ab_len2);
	float t_raw = dot(origin.xz - cam.xz, ab) / ab_len2;
	float t = clamp(t_raw, 0.0, 1.0);
	vec2 closest = cam.xz + ab * t;
	float side = length(origin.xz - closest);
	float reach = fade_reach + near_reach * (1.0 - t);
	float corridor = 1.0 - smoothstep(half_w * 0.6, half_w + reach, side);
	// only pieces that stand at least a little before the hero (in metres, not a fraction of the distance). Overnight Oct 19: the ramp is 0.45 -> 0.05 m
	// (was 0.9 -> 0.25): with full-height walls a hero pressed against a wall (its centre ~0.5 m in front) stayed two-thirds hidden behind it
	float in_front = 1.0 - smoothstep(ab_len - 0.45, ab_len - 0.05, t_raw * ab_len);
	float sight_y = mix(cam.y, hero.y, t);
	float covers = (1.0 - smoothstep(top - 0.3, top + 0.35, sight_y)) * smoothstep(bottom - 0.6, bottom + 0.05, sight_y);
	float enabled = step(-999.0, hero_pos.y);
	// a wall standing at the lens cuts away whether or not it blocks the hero: the camera never looks at a wall face in the foreground
	float at_lens = (1.0 - smoothstep(near_reach * 0.45, near_reach, length(origin.xz - cam.xz))) * step(0.5, near_reach);
	float front = cut_front ? in_front * step(0.0, t_raw) * (1.0 - smoothstep(top - 0.3, top + 0.35, cam.y)) : 0.0;
	v_fade = max(max(corridor * in_front * covers, at_lens), front) * enabled * fade_strength;
	if (room_cut) {
		vec2 q = origin.xz;
		float cut = room_w.x * room_fade(q, cam.xz, room_a);
		if (room_w.y > 0.0) {
			cut += room_w.y * room_fade(q, cam.xz, room_b);
		}
		if (room_w.z > 0.0) {
			cut += room_w.z * room_fade(q, cam.xz, room_c);
		}
		v_fade = cut * enabled * fade_strength;
	}
	v_tint = COLOR.rgb;
	v_disc = CUSTOM1.yzw;
}

void fragment() {
	vec3 c = albedo.rgb * v_tint;
	if (use_texture) {
		c *= texture(albedo_tex, UV / tile).rgb;
	}
	ALBEDO = mix(c, vec3(dot(c, vec3(0.299, 0.587, 0.114))), style_desaturate);
	ROUGHNESS = 0.95;
	float soft = 1.0;
	if (v_disc.z > 0.5) {
		soft = 1.0 - smoothstep(0.0, 1.0, length(v_disc.xy));
		soft *= soft;
	}
	EMISSION = c * emission_strength * soft;
	ALPHA = base_alpha * (1.0 - v_fade) * soft;
}
