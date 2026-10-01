class_name DnaMaterials
extends RefCounted
## The D.N.A.'s shared look. Every surface in the zone (floors, walls, cabinets, and the colours of
## the Kenney / KayKit props) is pushed through ONE palette - a sick, desaturated cold green with
## a few warm accents - so packs from different authors read as the same place. Floors and walls are
## small procedural shaders (no textures), fog and the lights come from `DnaLook`.

const FLOOR_SHADER: String = """
shader_type spatial;
uniform vec3 color_a : source_color = vec3(0.2, 0.3, 0.27);
uniform vec3 color_b : source_color = vec3(0.14, 0.2, 0.19);
uniform int pattern = 0;
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec2 p = wpos.xz;
	vec3 c = color_a;
	if (pattern == 0) {            // office carpet: speckle + faint cell grid
		float n = hash(floor(p * 9.0));
		c = color_a * (0.88 + 0.24 * n);
		vec2 f = fract(p / 2.0);
		c = mix(c, color_b, clamp(step(f.x, 0.018) + step(f.y, 0.018), 0.0, 1.0));
	} else if (pattern == 1) {     // lobby tile: checker with grout
		vec2 g = floor(p);
		float chk = mod(g.x + g.y, 2.0);
		c = mix(color_a, color_b, chk);
		vec2 f = fract(p);
		float grout = clamp(step(f.x, 0.035) + step(f.y, 0.035), 0.0, 1.0);
		c = mix(c, color_b * 0.45, grout);
	} else if (pattern == 2) {     // concrete: mottled
		float n = hash(floor(p * 5.0)) * 0.5 + hash(floor(p * 17.0)) * 0.5;
		c = color_a * (0.8 + 0.4 * n);
		vec2 f = fract(p / 3.0);
		c = mix(c, color_b, 0.7 * clamp(step(f.x, 0.012) + step(f.y, 0.012), 0.0, 1.0));
	} else if (pattern == 3) {     // executive carpet: diamond pattern
		vec2 q = fract(p * 0.5) - 0.5;
		float d = abs(q.x) + abs(q.y);
		c = mix(color_a, color_b, step(0.32, d) * 0.7);
		c *= 0.92 + 0.08 * hash(floor(p * 8.0));
	} else {                       // breakroom linoleum: big stripes
		c = mix(color_a, color_b, step(0.5, fract(p.x * 0.5)) * 0.55);
		c *= 0.94 + 0.06 * hash(floor(p * 6.0));
	}
	ALBEDO = c;
	ROUGHNESS = 0.92;
	SPECULAR = 0.1;
}
"""

const WALL_SHADER: String = """
shader_type spatial;
uniform vec3 wall_color : source_color = vec3(0.40, 0.56, 0.49);
uniform vec3 trim_color : source_color = vec3(0.16, 0.22, 0.21);
uniform vec3 cap_color : source_color = vec3(0.12, 0.17, 0.16);
uniform float drawers = 0.0;
varying vec3 wpos;
varying vec3 wnorm;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec3 c;
	if (wnorm.y > 0.5) {
		c = cap_color;
	} else {
		float h = wpos.y;
		float along = abs(wnorm.x) > 0.5 ? wpos.z : wpos.x;
		if (drawers > 0.5) {
			// filing cabinet: grey metal, drawer seams and handles
			c = wall_color * (0.9 + 0.1 * hash(vec2(floor(along * 1.0), 3.0)));
			float seam = step(fract(h / 0.36), 0.05);
			c = mix(c, trim_color, seam);
			float handle = step(abs(fract(along) - 0.5), 0.16) * step(abs(fract(h / 0.36) - 0.55), 0.045);
			c = mix(c, vec3(0.62, 0.66, 0.6), handle);
			c = mix(c, trim_color, step(h, 0.06));
		} else {
			c = wall_color;
			c = mix(c, c * 0.8, step(0.5, fract(along * 2.0)) * 0.35);   // vertical wallpaper stripes
			c = mix(c, trim_color, step(h, 0.16));                         // baseboard
			c = mix(c, trim_color * 1.4, step(abs(h - 0.78), 0.02));       // chair rail
		}
	}
	ALBEDO = c;
	EMISSION = c * 0.22;
	ROUGHNESS = 0.85;
}
"""

const GLOW_SHADER: String = """
shader_type spatial;
render_mode unshaded;
uniform vec4 glow_color : source_color = vec4(0.7, 1.0, 0.8, 1.0);
uniform float energy = 1.0;
void fragment() { ALBEDO = glow_color.rgb * energy; }
"""

static var _floor_materials: Dictionary = {}
static var _wall_material: ShaderMaterial
static var _cabinet_material: ShaderMaterial
static var _glow_materials: Dictionary = {}
static var _graded: Dictionary = {}

## Per-floor-kind colours: [a, b, pattern].
const FLOOR_STYLES: Dictionary = {
	DnaLayout.Floor.CARPET: [Color(0.2, 0.3, 0.27), Color(0.13, 0.2, 0.19), 0],
	DnaLayout.Floor.TILE: [Color(0.3, 0.4, 0.36), Color(0.24, 0.33, 0.3), 1],
	DnaLayout.Floor.CONCRETE: [Color(0.27, 0.31, 0.3), Color(0.14, 0.17, 0.17), 2],
	DnaLayout.Floor.EXEC: [Color(0.3, 0.14, 0.15), Color(0.17, 0.08, 0.1), 3],
	DnaLayout.Floor.LINO: [Color(0.4, 0.5, 0.4), Color(0.3, 0.38, 0.32), 4],
}


static func floor_material(kind: DnaLayout.Floor) -> ShaderMaterial:
	if not _floor_materials.has(kind):
		var shader: Shader = Shader.new()
		shader.code = FLOOR_SHADER
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		var style: Array = FLOOR_STYLES.get(kind, FLOOR_STYLES[DnaLayout.Floor.CARPET]) as Array
		material.set_shader_parameter("color_a", style[0] as Color)
		material.set_shader_parameter("color_b", style[1] as Color)
		material.set_shader_parameter("pattern", int(style[2]))
		_floor_materials[kind] = material
	return _floor_materials[kind] as ShaderMaterial


static func wall_material() -> ShaderMaterial:
	if _wall_material == null:
		var shader: Shader = Shader.new()
		shader.code = WALL_SHADER
		_wall_material = ShaderMaterial.new()
		_wall_material.shader = shader
	return _wall_material


static func cabinet_material() -> ShaderMaterial:
	if _cabinet_material == null:
		var shader: Shader = Shader.new()
		shader.code = WALL_SHADER
		_cabinet_material = ShaderMaterial.new()
		_cabinet_material.shader = shader
		_cabinet_material.set_shader_parameter("drawers", 1.0)
		_cabinet_material.set_shader_parameter("wall_color", Color(0.4, 0.46, 0.44))
		_cabinet_material.set_shader_parameter("cap_color", Color(0.13, 0.16, 0.16))
	return _cabinet_material


## A shared emissive material per flicker group (0 = steady). Changing `energy` on it flickers every
## fixture of that group at once.
static func glow_material(group: int, color: Color = Color(0.72, 1.0, 0.82)) -> ShaderMaterial:
	var key: String = "%d|%s" % [group, color.to_html()]
	if not _glow_materials.has(key):
		var shader: Shader = Shader.new()
		shader.code = GLOW_SHADER
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("glow_color", color)
		material.set_shader_parameter("energy", 1.0)
		material.set_meta("group", group)
		_glow_materials[key] = material
	return _glow_materials[key] as ShaderMaterial


static func glow_materials() -> Array:
	return _glow_materials.values()


static func reset_cache() -> void:
	_floor_materials.clear()
	_wall_material = null
	_cabinet_material = null
	_glow_materials.clear()
	_graded.clear()


# ---- Prop colour grading ---------------------------------------------------------------------


## The shared palette applied to every imported prop material: ~45% desaturated and multiplied by a
## cold green tint, rougher and less metallic.
static func grade_color(color: Color) -> Color:
	var lum: float = color.r * 0.3 + color.g * 0.59 + color.b * 0.11
	var muted: Color = Color(lum, lum, lum).lerp(color, 0.7)
	return Color(muted.r * 0.92, muted.g * 1.0, muted.b * 0.95, color.a)


static func grade_material(source: Material) -> Material:
	if not (source is StandardMaterial3D):
		return source
	var key: int = source.get_instance_id()
	if _graded.has(key):
		return _graded[key] as Material
	var copy: StandardMaterial3D = (source as StandardMaterial3D).duplicate() as StandardMaterial3D
	copy.albedo_color = grade_color(copy.albedo_color)
	copy.roughness = maxf(copy.roughness, 0.75)
	copy.metallic = minf(copy.metallic, 0.2)
	_graded[key] = copy
	return copy


## A copy of `mesh` with every surface material graded.
static func graded_mesh(mesh: Mesh) -> Mesh:
	var key: int = mesh.get_instance_id()
	if _graded.has(key):
		return _graded[key] as Mesh
	var copy: Mesh = mesh.duplicate() as Mesh
	for surface: int in range(copy.get_surface_count()):
		var material: Material = mesh.surface_get_material(surface)
		if material != null:
			copy.surface_set_material(surface, grade_material(material))
	_graded[key] = copy
	return copy


## Grades every mesh material under `node` in place (for characters/props instanced directly).
static func grade_node(node: Node, strength: float = 1.0) -> void:
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var material: Material = mesh_instance.get_active_material(surface)
			if material is StandardMaterial3D:
				var copy: StandardMaterial3D = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
				copy.albedo_color = copy.albedo_color.lerp(grade_color(copy.albedo_color), strength)
				mesh_instance.set_surface_override_material(surface, copy)
