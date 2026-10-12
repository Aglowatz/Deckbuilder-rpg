shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled, depth_prepass_alpha;
// Painted 2.5D character card (docs/art/world_look_test.md). An upright billboard: it turns to face the camera around the vertical axis only, so the figure keeps
// true perspective on the ground at low camera angles. Feet are on the node origin.
//  - lit by the real sun, lamp pools and ambient (light() below): warm and bright in sun, cooler and darker in a building's shadow
//  - a subtle rim light on the edge that faces the sun (a texture-alpha lookup toward the light, so there is no extra geometry)
//  - the next pass draws the sheared ground shadow of the card (world_sprite_shadow.gdshader)

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform bool flip_h = false;
// World size of the whole canvas, and how far the feet sit above the canvas bottom (world metres).
uniform vec2 card_size = vec2(1.0, 1.5);
uniform float feet_lift = 0.03;
// Breathing / squash about the feet.
uniform vec2 stretch = vec2(1.0, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;
// Light response.
uniform float warm_gain = 1.0;
uniform vec3 shade_color : source_color = vec3(0.34, 0.4, 0.62);
uniform float shade_amount = 0.9;
uniform float floor_light : hint_range(0.0, 1.0) = 0.16;
// Rim light: screen-space direction (x right, y up) towards the sun, strength, width in uv units.
uniform vec2 rim_dir = vec2(-0.7, 0.7);
uniform vec3 rim_color : source_color = vec3(1.0, 0.82, 0.55);
uniform float rim_strength = 0.42;
uniform float rim_width = 0.012;

void vertex() {
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec3 back = normalize(vec3(INV_VIEW_MATRIX[2].x, 0.0, INV_VIEW_MATRIX[2].z));
	float x = VERTEX.x * card_size.x * stretch.x;
	float y = (VERTEX.y * card_size.y - feet_lift) * stretch.y;
	mat4 face = mat4(vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(back, 0.0), MODEL_MATRIX[3]);
	VERTEX = vec3(x, y, 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * face;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 uv = UV;
	if (flip_h) {
		uv.x = 1.0 - uv.x;
	}
	vec4 c = texture(tex, uv);
	ALPHA = c.a * fade;
	ALPHA_SCISSOR_THRESHOLD = 0.58;
	vec3 col = c.rgb;
	// Rim: edge pixels whose neighbour towards the sun is empty.
	vec2 o = vec2(flip_h ? -rim_dir.x : rim_dir.x, -rim_dir.y) * rim_width;
	float edge = c.a * (1.0 - texture(tex, uv + o).a) + c.a * (1.0 - texture(tex, uv + o * 2.2).a) * 0.5;
	ALBEDO = col;
	EMISSION = col * floor_light + rim_color * clamp(edge, 0.0, 1.0) * rim_strength;
	ROUGHNESS = 1.0;
	// The card faces the camera: lean its normal towards the sky so a high sun does not light it edge-on.
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(NORMAL, up_view, 0.5));
}

void light() {
	// ATTENUATION carries the shadow-map result: a card inside a building's shadow loses the sun, and lamp pools tint it.
	float ndl = clamp(dot(NORMAL, LIGHT) * 0.5 + 0.5, 0.0, 1.0);
	float wrap = mix(smoothstep(0.1, 0.9, ndl), 1.0, 0.55);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * wrap * warm_gain * 0.98 / PI;
	if (LIGHT_IS_DIRECTIONAL) {
		// In the sun's shadow the card cools towards the shade colour instead of just darkening.
		DIFFUSE_LIGHT += (1.0 - ATTENUATION) * shade_color * shade_amount * 0.5;
	}
}
