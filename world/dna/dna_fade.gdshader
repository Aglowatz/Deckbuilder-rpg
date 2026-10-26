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
// Frosted glass (base alpha under 1) and the fluorescent tubes (emission) share the shader.
uniform float base_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float emission_strength = 0.0;
global uniform float style_desaturate;

varying float v_fade;
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
