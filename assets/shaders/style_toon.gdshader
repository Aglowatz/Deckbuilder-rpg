shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_back;
// The unified toon material for every world mesh and character (docs/art/style_guide.md, section 2).
// Banded lighting with soft edges (the bands also step lantern pools), the coloured shadow comes from the zone's tinted ambient light,
// a thresholded rim, optional emission, vertex-colour or atlas albedo, shader wind for foliage, and a desaturation mode (the D.N.A.)
// that spares objects with `colour_keep`.

global uniform vec3 style_rim_color;
global uniform vec3 style_highlight;
global uniform float style_desaturate;
global uniform float style_band_soft;
global uniform vec3 style_accent;
global uniform float style_wind;
global uniform float style_ground_sat;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo : source_color = vec4(1.0);
uniform bool use_texture = true;
uniform bool use_vertex_color = false;
uniform bool vertex_color_srgb = false;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0);
uniform vec3 emission_color : source_color = vec3(0.0);
uniform float emission_energy = 1.0;
uniform float rim_strength = 0.28;
uniform float wind_amount = 0.0;
uniform float alpha_scissor = -1.0;
uniform float band_mid = 0.74;
uniform float band_lit = 0.98;
uniform float grain_amount = 0.05;
uniform float gloss = 0.0;

instance uniform float colour_keep : hint_range(0.0, 1.0) = 0.0;
instance uniform float accent_mix : hint_range(0.0, 1.0) = 0.0;

varying vec3 v_world;

// Cheap value noise for the paper/brush grain (world space, so it does not swim with the camera).
float hash31(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.71, 0.113, 0.419));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float value_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash31(i), hash31(i + vec3(1, 0, 0)), f.x), mix(hash31(i + vec3(0, 1, 0)), hash31(i + vec3(1, 1, 0)), f.x), f.y),
			mix(mix(hash31(i + vec3(0, 0, 1)), hash31(i + vec3(1, 0, 1)), f.x), mix(hash31(i + vec3(0, 1, 1)), hash31(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (wind_amount > 0.0) {
		vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float sway = sin(TIME * 1.7 + world.x * 0.55 + world.z * 0.45) + 0.5 * sin(TIME * 3.1 + world.z * 0.9);
		float height = max(VERTEX.y, 0.0);
		VERTEX.x += sway * wind_amount * style_wind * height * height * 0.12;
		VERTEX.z += sway * 0.6 * wind_amount * style_wind * height * height * 0.12;
	}
}

void fragment() {
	vec2 uv = UV * uv1_scale.xy + uv1_offset.xy;
	vec4 base = albedo;
	if (use_texture) {
		base *= texture(albedo_tex, uv);
	}
	if (use_vertex_color) {
		vec3 vc = COLOR.rgb;
		if (vertex_color_srgb) {
			vc = mix(pow((vc + vec3(0.055)) / 1.055, vec3(2.4)), vc / 12.92, vec3(lessThan(vc, vec3(0.04045))));
		}
		base.rgb *= vc;
	}
	if (alpha_scissor > 0.0 && base.a < alpha_scissor) {
		discard;
	}
	vec3 col = base.rgb;
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	float desat = style_desaturate * (1.0 - colour_keep);
	col = mix(col, vec3(luma), desat);
	// Faint brush grain: two octaves of world-space noise nudge the value so flat colours stop looking like plastic.
	float grain = value_noise(v_world * 6.0) * 0.6 + value_noise(v_world * 17.0) * 0.4;
	col *= 1.0 + (grain - 0.5) * 2.0 * grain_amount;
	// Ground calmer than props (style guide section 4): up-facing surfaces are pulled towards their luma by the zone's ground saturation.
	float ground = smoothstep(0.8, 0.95, (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).y);
	col = mix(col, vec3(dot(col, vec3(0.299, 0.587, 0.114))), ground * (1.0 - style_ground_sat) * (1.0 - colour_keep));
	ALBEDO = col;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.0;
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.5);
	// Rim per material class: up-facing surfaces (ground, roofs) get almost none, characters and walls keep it.
	float up = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).y;
	float rim = smoothstep(0.55, 0.8, fres) * rim_strength * (1.0 - 0.85 * smoothstep(0.8, 0.97, up));
	vec3 rim_col = mix(style_rim_color, style_accent, accent_mix);
	EMISSION = emission_color * emission_energy + rim_col * (rim + accent_mix * 0.35 * fres);
}

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float t = clamp(ndl * 0.5 + 0.5, 0.0, 1.0) * ATTENUATION;
	float soft = max(style_band_soft, 0.005);
	float b1 = smoothstep(0.30 - soft, 0.30 + soft, t);
	float b2 = smoothstep(0.62 - soft, 0.62 + soft, t);
	float level = band_mid * b1;
	level = mix(level, band_lit, b2);
	DIFFUSE_LIGHT += LIGHT_COLOR * level / PI * mix(vec3(1.0), style_highlight, b2);
	if (gloss > 0.0) {
		// Optional glossy band (the Buffet): one hard-edged highlight, painted on top of the diffuse bands.
		float spec = smoothstep(0.93, 0.96, dot(NORMAL, normalize(LIGHT + VIEW))) * ATTENUATION;
		DIFFUSE_LIGHT += LIGHT_COLOR * spec * gloss / PI * 2.0;
	}
}
