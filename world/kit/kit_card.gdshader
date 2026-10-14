shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
// A painted card for the Environment Kit (trees ENV-TREE-*): an upright quad that turns round the vertical axis to face the camera, bends a little in the wind (more at the
// top), is lit with the sun and ambient colours of the zone (faked, like the foliage layer) and is darker towards its roots. The texture is the kit art or its placeholder.
//
// Camera occlusion (GC-4): a card standing between the camera and the hero (`hero_pos`, set every frame by OcclusionFader through KitFoliage.set_hero) fades to a
// smooth ghost instead of filling the screen with canopy. The test is per card, so it works for the MultiMesh tree fields too: the card's trunk point is projected on the
// camera -> hero line; cards near that line, in front of the hero and tall enough to reach the sight line, fade by `fade_strength`. Plain alpha, never a dither.

uniform sampler2D card_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 light_color : source_color = vec3(1.0, 0.92, 0.78);
uniform vec3 ambient_color : source_color = vec3(0.55, 0.6, 0.78);
uniform vec3 mood_tint : source_color = vec3(1.0);
uniform float sway = 0.035;
uniform float speed = 0.9;
uniform float base_dark = 0.7;
uniform vec3 hero_pos = vec3(0.0, -1000.0, 0.0);
uniform float fade_strength : hint_range(0.0, 1.0) = 0.86;
// How far (metres) beyond the card's half width the fade corridor reaches.
uniform float fade_reach = 1.6;

varying float v_fade;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float sx = length(MODEL_MATRIX[0].xyz);
	float sy = length(MODEL_MATRIX[1].xyz);
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	float h = clamp(VERTEX.y, 0.0, 1.0);
	float phase = origin.x * 0.31 + origin.z * 0.23;
	float bend = (sin(TIME * speed + phase) * 0.7 + sin(TIME * speed * 2.3 + phase * 1.7) * 0.3) * sway;
	vec3 world = origin + right * (VERTEX.x * sx + bend * h * h * sy) + vec3(0.0, VERTEX.y * sy, 0.0);
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world, 1.0);
	// Occlusion: where does this card stand relative to the camera -> hero line?
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	vec3 hero = hero_pos + vec3(0.0, 0.9, 0.0);
	vec2 ab = hero.xz - cam.xz;
	float ab_len2 = max(dot(ab, ab), 0.0001);
	float t = clamp(dot(origin.xz - cam.xz, ab) / ab_len2, 0.0, 1.0);
	vec2 closest = cam.xz + ab * t;
	float side = length(origin.xz - closest);
	float half_w = sx * 0.5;
	float corridor = 1.0 - smoothstep(half_w * 0.5, half_w + fade_reach, side);
	// only cards in front of the hero (not behind it) ...
	float in_front = 1.0 - smoothstep(0.93, 1.0, t);
	// ... that actually reach up to the sight line at that point
	float sight_y = mix(cam.y, hero.y, t);
	float top = origin.y + sy;
	float tall_enough = 1.0 - smoothstep(top - 0.6, top + 0.8, sight_y);
	float enabled = step(-999.0, hero_pos.y);  // the default hero_pos (y -1000) disables the fade
	v_fade = corridor * in_front * tall_enough * enabled * fade_strength;
}

void fragment() {
	vec4 c = texture(card_tex, UV);
	if (c.a < 0.5) {
		discard;
	}
	float base = smoothstep(1.0, 0.7, UV.y);
	vec3 lit = ambient_color * 0.55 + light_color * 0.62;
	ALBEDO = c.rgb * mood_tint * lit * mix(base_dark, 1.0, base);
	ALPHA = 1.0 - v_fade;
}
