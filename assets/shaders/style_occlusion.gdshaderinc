// Fable Nov 19 (Part 1): the see-through window round the hero (OcclusionFader).
// A tall thing that hides the hero is never faded as a whole: only the part of it inside a soft circle round the hero, nearer the
// lens than the hero, goes see-through (an ordered dither that keeps `occlusion_window.y` of the surface), and its foot (the band up
// to `occlusion_window.z` metres above the hero's ground) stays solid so the place it blocks still reads.
//   occlusion_hero    the hero's feet (world); y -1000 = off
//   occlusion_window  x = radius of the window in metres at the hero's depth, y = how much of the surface is kept inside it (0..1),
//                     z = height of the solid foot (metres)
global uniform vec3 occlusion_hero;
global uniform vec4 occlusion_window;

const float OCCLUSION_BAYER[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);

// True when the fragment should be dropped. `amount` is the mesh's eased share (the instance uniform `occlusion_fade`), `view_pos` the
// fragment in view space (VERTEX in fragment()), `world_pos` in world space.
bool occlusion_window_cut(float amount, vec3 view_pos, vec3 world_pos, mat4 view_matrix, vec2 frag_coord) {
	if (amount <= 0.0 || occlusion_hero.y < -999.0) {
		return false;
	}
	vec3 h = (view_matrix * vec4(occlusion_hero + vec3(0.0, 1.0, 0.0), 1.0)).xyz;
	// only what stands nearer the lens than the hero (view z is negative ahead of the lens)
	float nearer = smoothstep(0.15, 0.7, view_pos.z - h.z);
	// the fragment projected onto the hero's depth: its distance from the hero there, in metres
	vec2 p = view_pos.xy * (h.z / min(view_pos.z, -0.05));
	float d = length((p - h.xy) * vec2(1.0, 0.88));
	float radius = occlusion_window.x;
	float mask = 1.0 - smoothstep(radius * 0.5, radius, d);
	float foot = smoothstep(occlusion_hero.y + occlusion_window.z * 0.55, occlusion_hero.y + occlusion_window.z, world_pos.y);
	float cut = amount * mask * nearer * foot * (1.0 - occlusion_window.y);
	int index = (int(frag_coord.y) % 4) * 4 + (int(frag_coord.x) % 4);
	return (OCCLUSION_BAYER[index] + 0.5) / 16.0 < cut;
}
