shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled, depth_prepass_alpha;
#include "res://assets/shaders/style_ground_light.gdshaderinc"
varying vec3 v_feet;
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
// Per-copy colour variety (a citizen's coat), and the alpha / scissor of a translucent character (a ghost keeps its soft edges).
uniform vec3 tint : source_color = vec3(1.0);
uniform float base_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float scissor : hint_range(0.0, 1.0) = 0.58;
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
// Graphics Tier 1: the frame's generated normal map (SpriteLibrary.normal_frame) and how far it bends the card's normal.
uniform sampler2D normal_tex : filter_linear_mipmap, repeat_disable;
uniform bool use_normal = false;
uniform float normal_amount = 0.7;

// Placement of an overlay card (a hat): where its bottom-centre sits relative to the feet (world metres), and a nudge towards the camera so it wins the depth test.
uniform vec2 offset = vec2(0.0);
uniform float depth_nudge = 0.0;
// A tumble (radians, in the card plane) about the body's middle, for flips and spins.
uniform float roll = 0.0;
uniform float pivot_y = 0.6;

// Dye: recolours the pixels whose hue is near `dye_hue` (the cloak) to `dye_color`, keeping the painted shading. dye_amount 0 = natural colours.
uniform vec3 dye_color : source_color = vec3(0.8, 0.2, 0.2);
uniform float dye_amount : hint_range(0.0, 1.0) = 0.0;
uniform float dye_hue = 0.5;
uniform float dye_width = 0.07;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void vertex() {
	vec3 right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z));
	vec3 back = normalize(vec3(INV_VIEW_MATRIX[2].x, 0.0, INV_VIEW_MATRIX[2].z));
	float x = (VERTEX.x * card_size.x + offset.x) * stretch.x;
	float y = (VERTEX.y * card_size.y - feet_lift + offset.y) * stretch.y;
	if (roll != 0.0) {
		float cr = cos(roll);
		float sr = sin(roll);
		vec2 q = vec2(x, y - pivot_y);
		x = cr * q.x - sr * q.y;
		y = sr * q.x + cr * q.y + pivot_y;
	}
	mat4 face = mat4(vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(back, 0.0), MODEL_MATRIX[3]);
	v_feet = MODEL_MATRIX[3].xyz;
	VERTEX = vec3(x, y, depth_nudge);
	MODELVIEW_MATRIX = VIEW_MATRIX * face;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 uv = UV;
	if (flip_h) {
		uv.x = 1.0 - uv.x;
	}
	vec4 c = texture(tex, uv);
	ALPHA = c.a * fade * base_alpha;
	ALPHA_SCISSOR_THRESHOLD = scissor;
	vec3 col = c.rgb * tint;
	if (dye_amount > 0.001) {
		vec3 hsv = rgb2hsv(col);
		float dh = abs(hsv.x - dye_hue);
		dh = min(dh, 1.0 - dh);
		float m = (1.0 - smoothstep(dye_width, dye_width * 1.9, dh)) * smoothstep(0.1, 0.28, hsv.y) * dye_amount;
		vec3 target = rgb2hsv(dye_color);
		vec3 dyed = hsv2rgb(vec3(target.x, clamp(hsv.y * target.y / 0.5, 0.0, 1.0), hsv.z * clamp(target.z / 0.55, 0.55, 1.5)));
		col = mix(col, dyed, m);
	}
	// Rim: edge pixels whose neighbour towards the sun is empty.
	vec2 o = vec2(flip_h ? -rim_dir.x : rim_dir.x, -rim_dir.y) * rim_width;
	float edge = c.a * (1.0 - texture(tex, uv + o).a) + c.a * (1.0 - texture(tex, uv + o * 2.2).a) * 0.5;
	ALBEDO = ground_light_apply(col, v_feet, 0.0, 1.0, 0.55, SCREEN_UV.y);
	EMISSION = col * floor_light + rim_color * clamp(edge, 0.0, 1.0) * rim_strength;
	ROUGHNESS = 1.0;
	// The card faces the camera: lean its normal towards the sky so a high sun does not light it edge-on.
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	vec3 facing = normalize(mix(NORMAL, up_view, 0.5));
	if (use_normal) {
		// Graphics Tier 1: the generated normal map (tools/sprite_normals.gd) tilts the card's normal in its own frame: x along the camera's right (mirrored with
		// the art), y up the card, z out of it. Kept soft so the painting stays painterly: the sun, lanterns and effect lights shape the figure, never gloss it.
		vec3 nm = texture(normal_tex, uv).rgb * 2.0 - 1.0;
		vec3 right_view = normalize((VIEW_MATRIX * vec4(normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[0].z)), 0.0)).xyz);
		vec3 shaped = normalize(right_view * (flip_h ? -nm.x : nm.x) + up_view * nm.y + NORMAL * nm.z);
		NORMAL = normalize(mix(facing, shaped, normal_amount));
	} else {
		NORMAL = facing;
	}
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
