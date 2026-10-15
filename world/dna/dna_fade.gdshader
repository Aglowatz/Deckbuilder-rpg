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
global uniform float style_desaturate;

varying float v_fade;
varying vec3 v_tint;

void vertex() {
	vec3 origin = vec3(CUSTOM0.x, 0.0, CUSTOM0.y);
	float half_w = CUSTOM0.z;
	float top = CUSTOM0.w;
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	vec3 hero = hero_pos + vec3(0.0, 0.7, 0.0);
	vec2 ab = hero.xz - cam.xz;
	float ab_len2 = max(dot(ab, ab), 0.0001);
	float t = clamp(dot(origin.xz - cam.xz, ab) / ab_len2, 0.0, 1.0);
	vec2 closest = cam.xz + ab * t;
	float side = length(origin.xz - closest);
	float corridor = 1.0 - smoothstep(half_w * 0.6, half_w + fade_reach, side);
	float in_front = 1.0 - smoothstep(0.9, 1.0, t);
	float sight_y = mix(cam.y, hero.y, t);
	float tall_enough = 1.0 - smoothstep(top - 0.35, top + 0.4, sight_y);
	float enabled = step(-999.0, hero_pos.y);
	v_fade = corridor * in_front * tall_enough * enabled * fade_strength;
	v_tint = COLOR.rgb;
}

void fragment() {
	vec3 c = albedo.rgb * v_tint;
	if (use_texture) {
		c *= texture(albedo_tex, UV / tile).rgb;
	}
	ALBEDO = mix(c, vec3(dot(c, vec3(0.299, 0.587, 0.114))), style_desaturate);
	ROUGHNESS = 0.95;
	ALPHA = 1.0 - v_fade;
}
