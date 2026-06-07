## Portal.gd — Godot 4.6.2  (v3 — Ultra personnalisable)
##
## INSTALLATION :
##   1. Node3D → attache ce script
##   2. Règle next_scene dans l'Inspector
##   3. Tout le reste se configure dans l'Inspector sous les groupes ci-dessous
@tool
extends Node3D

# ═══════════════════════════════════════════════════════════════
#  SCÈNE
# ═══════════════════════════════════════════════════════════════
@export_file("*.tscn")
var next_scene  : String = ""
@export var auto_travel : bool = true

# ═══════════════════════════════════════════════════════════════
#  TAILLE & FORME
# ═══════════════════════════════════════════════════════════════
@export_group("Taille & Forme")
## Rayon du cercle (moitié de la largeur visible)
@export var portal_radius    : float = 2.5
## Étirement vertical (1.0 = cercle parfait, >1.0 = ellipse haute, <1.0 = ellipse large)
@export var vertical_stretch : float = 1.0
## Épaisseur de l'anneau lumineux (0 = invisible)
@export var ring_thickness   : float = 0.10

# ═══════════════════════════════════════════════════════════════
#  COULEURS
# ═══════════════════════════════════════════════════════════════
@export_group("Couleurs")
## Couleur du caractère en tête de traîne (le plus lumineux)
@export var color_head       : Color = Color(0.80, 1.00, 0.85)
## Couleur de la traîne (bas des colonnes)
@export var color_trail      : Color = Color(0.00, 0.65, 0.22)
## Couleur de fond du portail (alpha = opacité)
@export var color_background : Color = Color(0.00, 0.04, 0.01, 0.70)
## Couleur de l'anneau et des particules
@export var color_ring       : Color = Color(0.00, 1.00, 0.35)
## Intensité de l'émission de l'anneau (0 = éteint)
@export var ring_glow        : float = 4.0

# ═══════════════════════════════════════════════════════════════
#  PLUIE MATRICIELLE
# ═══════════════════════════════════════════════════════════════
@export_group("Pluie matricielle")
## Vitesse de défilement des colonnes
@export var rain_speed       : float = 1.5
## Nombre de colonnes de caractères
@export var rain_columns     : int   = 20
## Longueur de la traîne (0.05 = courte, 0.6 = très longue)
@export var trail_length     : float = 0.30
## Vitesse de rotation du plan (0 = statique)
@export var swirl_speed      : float = 0.05

## Style de caractères affiché dans le portail
enum CharSet { MATRIX, BINAIRE, HEXADECIMAL, SYMBOLES, ADN, MORSE }
@export var char_set : CharSet = CharSet.MATRIX

## Densité de remplissage des colonnes (0.3 = épars, 1.0 = dense)
@export var column_density   : float = 0.75
## Taille relative des glyphes (0.5 = petits, 1.5 = gros)
@export var glyph_size       : float = 1.0

# ═══════════════════════════════════════════════════════════════
#  CADRE (optionnel)
# ═══════════════════════════════════════════════════════════════
@export_group("Cadre (optionnel)")
## Afficher les piliers et le linteau
@export var show_frame       : bool  = false
@export var frame_color      : Color = Color(0.04, 0.09, 0.05)
@export var frame_metallic   : float = 0.65
@export var pillar_height    : float = 5.5
@export var pillar_radius    : float = 0.18

# ═══════════════════════════════════════════════════════════════
#  PARTICULES
# ═══════════════════════════════════════════════════════════════
@export_group("Particules")
@export var particle_count   : int   = 120
@export var particle_size    : float = 0.07
## Couleur des particules (si différente de color_ring)
@export var color_particles  : Color = Color(0.00, 1.00, 0.35)
@export var show_particles   : bool  = true

# ═══════════════════════════════════════════════════════════════
#  ANIMATION ANNEAU
# ═══════════════════════════════════════════════════════════════
@export_group("Animation anneau")
@export var pulse_speed      : float = 2.6
@export var pulse_amplitude  : float = 0.45   # 0 = constant, 1 = clignote fort

# ═══════════════════════════════════════════════════════════════
#  SHADER
# ═══════════════════════════════════════════════════════════════
const MATRIX_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

uniform vec4  u_color_head  : source_color = vec4(0.80, 1.0, 0.85, 1.0);
uniform vec4  u_color_trail : source_color = vec4(0.00, 0.65, 0.22, 1.0);
uniform vec4  u_color_bg    : source_color = vec4(0.00, 0.04, 0.01, 0.70);
uniform float u_speed       : hint_range(0.1, 8.0)   = 1.5;
uniform float u_columns     : hint_range(4.0, 60.0)  = 20.0;
uniform float u_trail       : hint_range(0.02, 0.70) = 0.30;
uniform float u_density     : hint_range(0.1, 1.0)   = 0.75;
uniform float u_glyph       : hint_range(0.3, 2.0)   = 1.0;
uniform float u_stretch     : hint_range(0.2, 4.0)   = 1.0;
// 0=Matrix 1=Binaire 2=Hexa 3=Symboles 4=ADN 5=Morse
uniform int   u_charset     = 0;

float h11(float n) { return fract(sin(n * 127.1) * 43758.5453); }
float h21(vec2 p)  { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

// Dessine un glyphe selon le charset (simulation procédurale)
float glyph(vec2 cell_uv, float char_id, int cs) {
	vec2 p = cell_uv;
	float v = 0.0;
	if (cs == 0) {
		// Matrix : formes variées (certaines ont des courbes simulées)
		float t = floor(char_id * 7.3);
		float rows = 5.0 + mod(t, 3.0);
		float px = step(0.15, p.x) * step(p.x, 0.85);
		float py = step(0.10, p.y) * step(p.y, 0.90);
		float stripe = step(0.35, fract(p.y * rows)) * step(fract(p.y * rows), 0.80);
		float diag   = step(0.4, fract((p.x + p.y) * 3.0));
		v = px * py * mix(stripe, diag, mod(t, 2.0));
	} else if (cs == 1) {
		// Binaire : bâtonnets verticaux (0 ou 1)
		float bit = step(0.5, h11(char_id));
		if (bit > 0.5) {
			// '1' : barre verticale fine au centre
			v = step(0.38, p.x) * step(p.x, 0.62)
			  * step(0.08, p.y) * step(p.y, 0.92);
		} else {
			// '0' : anneau
			float d = length(p - 0.5) * 2.0;
			v = smoothstep(0.55, 0.45, d) * smoothstep(0.25, 0.35, d);
		}
	} else if (cs == 2) {
		// Hexa : formes à angles droits
		float t   = floor(h11(char_id) * 16.0);
		float seg = mod(t, 4.0);
		float px  = step(0.12, p.x) * step(p.x, 0.88);
		float py  = step(0.08, p.y) * step(p.y, 0.92);
		float hbar = step(0.08, p.y) * step(p.y, 0.22) * px;
		float hbar2= step(0.78, p.y) * step(p.y, 0.92) * px;
		float vbar = step(0.12, p.x) * step(p.x, 0.28) * py;
		float vbar2= step(0.72, p.x) * step(p.x, 0.88) * py;
		float mid  = step(0.42, p.y) * step(p.y, 0.58) * px;
		v = mix(hbar + hbar2 + vbar + vbar2, mid + hbar + hbar2 + vbar, seg / 3.0);
		v = clamp(v, 0.0, 1.0);
	} else if (cs == 3) {
		// Symboles : formes géométriques variées
		float t = mod(floor(h11(char_id) * 8.0), 4.0);
		vec2  c = p - 0.5;
		if (t < 1.0) {
			// Croix
			v = (step(abs(c.x), 0.12) + step(abs(c.y), 0.12));
		} else if (t < 2.0) {
			// Losange
			v = step(abs(c.x) + abs(c.y), 0.35) * (1.0 - step(abs(c.x) + abs(c.y), 0.20));
		} else if (t < 3.0) {
			// Triangle
			v = step(c.y, c.x * 1.7 + 0.2) * step(c.y, -c.x * 1.7 + 0.2)
			  * step(-0.35, c.y);
		} else {
			// Étoile simplifiée
			float ang = atan(c.y, c.x);
			float r   = length(c);
			float star= 0.15 + 0.12 * cos(ang * 5.0);
			v = step(r, star) * (1.0 - step(r, 0.06));
		}
		v = clamp(v, 0.0, 1.0);
	} else if (cs == 4) {
		// ADN : formes A T C G simplifiées (alternance)
		float base = mod(floor(char_id * 4.0), 4.0);
		float px   = step(0.12, p.x) * step(p.x, 0.88);
		if (base < 1.0) {
			// A : deux barres obliques + barre centrale
			float l = step(abs(p.x - p.y * 0.6 + 0.05), 0.08);
			float r = step(abs(p.x + p.y * 0.6 - 1.05), 0.08);
			float m = step(0.40, p.y) * step(p.y, 0.55) * px;
			v = clamp(l + r + m, 0.0, 1.0);
		} else if (base < 2.0) {
			// T : barre hori haut + barre verti
			float top = step(0.78, p.y) * step(p.y, 0.92) * px;
			float stem= step(0.42, p.x) * step(p.x, 0.58)
			          * step(0.08, p.y) * step(p.y, 0.90);
			v = clamp(top + stem, 0.0, 1.0);
		} else if (base < 3.0) {
			// C : arc ouvert à droite
			float d = length(p - 0.5) * 2.0;
			float arc = smoothstep(0.55, 0.45, d) * (1.0 - smoothstep(0.28, 0.38, d));
			arc *= step(p.x, 0.55);
			v = arc;
		} else {
			// G : C avec petit crochet
			float d = length(p - 0.5) * 2.0;
			float arc = smoothstep(0.55, 0.45, d) * (1.0 - smoothstep(0.28, 0.38, d));
			arc *= step(p.x, 0.55);
			float hook = step(0.50, p.x) * step(p.x, 0.75)
			           * step(0.42, p.y) * step(p.y, 0.56);
			v = clamp(arc + hook, 0.0, 1.0);
		}
	} else {
		// Morse : points et tirets
		float t  = mod(floor(h11(char_id) * 6.0), 3.0);
		float py = step(0.35, p.y) * step(p.y, 0.65);
		if (t < 1.0) {
			// Point
			float d = length(p - 0.5);
			v = step(d, 0.18);
		} else if (t < 2.0) {
			// Tiret
			v = step(0.10, p.x) * step(p.x, 0.90) * py;
		} else {
			// Point + tiret
			float d   = length(vec2(p.x - 0.2, p.y - 0.5));
			float dot = step(d, 0.12);
			float dash= step(0.38, p.x) * step(p.x, 0.88) * py;
			v = clamp(dot + dash, 0.0, 1.0);
		}
	}
	return v;
}

void fragment() {
	vec2 uv = UV;

	// Masque circulaire (avec étirement vertical)
	vec2  c    = uv - 0.5;
	c.y       /= u_stretch;
	float r    = length(c) * 2.0;
	float mask = smoothstep(1.02, 0.78, r);
	if (mask < 0.005) discard;

	// Fond du portail
	float bg_mask = smoothstep(1.0, 0.70, r);

	// ── Pluie ────────────────────────────────────────────────
	float cols  = u_columns;
	float ci    = floor(uv.x * cols);
	float cu    = fract(uv.x * cols);

	// Vitesse et phase par colonne
	float spd   = u_speed * (0.45 + h11(ci + 3.7) * 0.9);
	float off   = h11(ci) * 20.0;
	float t_col = TIME * spd + off;

	// Activité de la colonne selon densité
	float active = step(1.0 - u_density, h11(ci + 99.1));

	// Tête de traîne
	float head  = fract(t_col * 0.2);

	// Traîne exponentielle
	float dy    = mod(uv.y - head + 1.0, 1.0);
	float trail = exp(-dy / max(u_trail, 0.01)) * step(dy, u_trail);

	// Tête lumineuse
	float is_head = smoothstep(0.03, 0.0, abs(uv.y - head));

	// Cellule de glyphe
	float glyph_rows = 18.0 / u_glyph;
	float gc_id  = floor(uv.y * glyph_rows) + ci * 31.7;
	float gc_t   = floor(t_col * 5.0);
	float char_id= h21(vec2(gc_id, gc_t));
	vec2  cell_uv= vec2(cu, fract(uv.y * glyph_rows));
	float g      = glyph(cell_uv, char_id, u_charset);

	// Scintillement
	float flicker= step(0.4, h21(vec2(gc_id, floor(t_col * 8.0))));
	float bright = (trail * (0.55 + 0.45 * flicker) + is_head * 2.0) * g * active;

	vec3 col  = mix(u_color_trail.rgb, u_color_head.rgb, is_head + trail * 0.3) * bright;
	float a   = bright * mask;

	// Fond
	vec3  final_col = u_color_bg.rgb * bg_mask * u_color_bg.a + col;
	float final_a   = max(u_color_bg.a * bg_mask * (1.0 - bright * 0.5), a);

	if (final_a < 0.004) discard;

	ALBEDO   = final_col;
	ALPHA    = final_a;
	EMISSION = col * 2.2;
}
"""

# ═══════════════════════════════════════════════════════════════
#  ÉTAT INTERNE
# ═══════════════════════════════════════════════════════════════
var _time        : float = 0.0
var _player_near : bool  = false
var _portal_mat  : ShaderMaterial
var _glow_mat    : StandardMaterial3D
var _led_mats    : Array[StandardMaterial3D] = []
var _ring_mats   : Array[StandardMaterial3D] = []
var _area        : Area3D

# ═══════════════════════════════════════════════════════════════
#  CONSTRUCTION
# ═══════════════════════════════════════════════════════════════
func _ready() -> void:
	_build_portal()

func _build_portal() -> void:
	_build_face()
	_build_ring()
	if show_frame:
		_build_pillar(-portal_radius - 0.18, "pillar_L")
		_build_pillar( portal_radius + 0.18, "pillar_R")
		_build_lintel()
		_build_base()
	_build_light()
	if show_particles:
		_build_particles()
	_build_area()

# ── Face matricielle ─────────────────────────────────────────
func _build_face() -> void:
	var sh       := Shader.new()
	sh.code       = MATRIX_SHADER
	_portal_mat   = ShaderMaterial.new()
	_portal_mat.shader = sh
	_update_shader_params()

	var plane             := PlaneMesh.new()
	plane.size             = Vector2(portal_radius * 2.0, portal_radius * 2.0 * vertical_stretch)
	plane.subdivide_width  = 1
	plane.subdivide_depth  = 1

	var mi                := MeshInstance3D.new()
	mi.name                = "PortalFace"
	mi.mesh                = plane
	mi.material_override   = _portal_mat
	mi.position            = Vector3(0.0, portal_radius * vertical_stretch, 0.0)
	mi.rotation_degrees    = Vector3(90.0, 0.0, 0.0)
	add_child(mi)

# Envoie tous les paramètres au shader
func _update_shader_params() -> void:
	if not _portal_mat: return
	_portal_mat.set_shader_parameter("u_color_head",  color_head)
	_portal_mat.set_shader_parameter("u_color_trail", color_trail)
	_portal_mat.set_shader_parameter("u_color_bg",    color_background)
	_portal_mat.set_shader_parameter("u_speed",       rain_speed)
	_portal_mat.set_shader_parameter("u_columns",     float(rain_columns))
	_portal_mat.set_shader_parameter("u_trail",       trail_length)
	_portal_mat.set_shader_parameter("u_density",     column_density)
	_portal_mat.set_shader_parameter("u_glyph",       glyph_size)
	_portal_mat.set_shader_parameter("u_stretch",     vertical_stretch)
	_portal_mat.set_shader_parameter("u_charset",     int(char_set))

# ── Anneau ────────────────────────────────────────────────────
func _build_ring() -> void:
	if ring_thickness <= 0.0: return
	var t        := TorusMesh.new()
	t.outer_radius = portal_radius + ring_thickness
	t.inner_radius = portal_radius
	t.rings        = 64
	t.ring_segments = 14

	var mat                         := StandardMaterial3D.new()
	mat.albedo_color                 = color_ring
	mat.emission_enabled             = true
	mat.emission                     = color_ring
	mat.emission_energy_multiplier   = ring_glow
	_glow_mat = mat

	var mi               := MeshInstance3D.new()
	mi.name               = "PortalRing"
	mi.mesh               = t
	mi.material_override  = mat
	mi.position           = Vector3(0.0, portal_radius * vertical_stretch, 0.0)
	mi.rotation_degrees   = Vector3(90.0, 0.0, 0.0)
	add_child(mi)

# ── Piliers ───────────────────────────────────────────────────
func _build_pillar(x: float, n: String) -> void:
	var root      := Node3D.new()
	root.name      = n
	root.position  = Vector3(x, 0.0, 0.0)
	add_child(root)

	var cyl               := CylinderMesh.new()
	cyl.top_radius         = pillar_radius
	cyl.bottom_radius      = pillar_radius
	cyl.height             = pillar_height
	cyl.radial_segments    = 16

	var mat                := StandardMaterial3D.new()
	mat.albedo_color        = frame_color
	mat.metallic            = frame_metallic
	mat.roughness           = 1.0 - frame_metallic

	var mi                := MeshInstance3D.new()
	mi.mesh                = cyl
	mi.material_override   = mat
	mi.position            = Vector3(0.0, pillar_height * 0.5, 0.0)
	root.add_child(mi)

	for i in 5:
		var ry   := pillar_height * 0.10 + i * pillar_height * 0.19
		var rm   := StandardMaterial3D.new()
		rm.albedo_color              = color_ring
		rm.emission_enabled          = true
		rm.emission                  = color_ring
		rm.emission_energy_multiplier = 1.2
		_ring_mats.append(rm)
		var rt            := TorusMesh.new()
		rt.outer_radius    = pillar_radius + 0.06
		rt.inner_radius    = pillar_radius - 0.02
		rt.rings           = 12; rt.ring_segments = 8
		var ri            := MeshInstance3D.new()
		ri.mesh            = rt
		ri.material_override = rm
		ri.position        = Vector3(0.0, ry, 0.0)
		root.add_child(ri)

	var lm := StandardMaterial3D.new()
	lm.albedo_color              = color_ring
	lm.emission_enabled          = true
	lm.emission                  = color_ring
	lm.emission_energy_multiplier = 6.0
	_led_mats.append(lm)
	var ls    := SphereMesh.new()
	ls.radius  = pillar_radius * 0.75; ls.height = pillar_radius * 1.5
	var li    := MeshInstance3D.new()
	li.mesh    = ls; li.material_override = lm
	li.position = Vector3(0.0, pillar_height + 0.15, 0.0)
	root.add_child(li)

func _build_lintel() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = frame_color
	mat.metallic = frame_metallic; mat.roughness = 1.0 - frame_metallic
	var bx := BoxMesh.new()
	bx.size = Vector3(portal_radius * 2.0 + 0.72, 0.28, 0.32)
	var mi  := MeshInstance3D.new()
	mi.mesh  = bx; mi.material_override = mat
	mi.position = Vector3(0.0, pillar_height + 0.14, 0.0)
	add_child(mi)

func _build_base() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = frame_color
	mat.metallic = frame_metallic; mat.roughness = 1.0 - frame_metallic
	var bx := BoxMesh.new()
	bx.size = Vector3(portal_radius * 2.0 + 0.90, 0.22, 0.44)
	var mi  := MeshInstance3D.new()
	mi.mesh  = bx; mi.material_override = mat
	mi.position = Vector3(0.0, 0.11, 0.0)
	add_child(mi)

# ── Lumière ───────────────────────────────────────────────────
func _build_light() -> void:
	var l            := OmniLight3D.new()
	l.light_color     = color_ring
	l.light_energy    = 3.0
	l.omni_range      = portal_radius * 4.0
	l.shadow_enabled  = false
	l.position        = Vector3(0.0, portal_radius * vertical_stretch, 0.5)
	add_child(l)

# ── Particules ────────────────────────────────────────────────
func _build_particles() -> void:
	var p            := GPUParticles3D.new()
	p.amount          = particle_count
	p.lifetime        = 2.5
	p.emitting        = true
	p.position        = Vector3(0.0, portal_radius * vertical_stretch, 0.0)
	p.visibility_aabb = AABB(
		Vector3(-portal_radius * 2.0, -portal_radius * 2.5, -portal_radius * 2.0),
		Vector3(portal_radius * 4.0,  portal_radius * 5.0,  portal_radius * 4.0))

	var proc                        := ParticleProcessMaterial.new()
	proc.emission_shape              = ParticleProcessMaterial.EMISSION_SHAPE_RING
	proc.emission_ring_radius        = portal_radius + 0.1
	proc.emission_ring_inner_radius  = portal_radius
	proc.emission_ring_height        = 0.1
	proc.emission_ring_axis          = Vector3(0.0, 0.0, 1.0)
	proc.direction                   = Vector3.ZERO
	proc.spread                      = 180.0
	proc.initial_velocity_min        = 0.05
	proc.initial_velocity_max        = 0.30
	proc.gravity                     = Vector3.ZERO
	proc.scale_min                   = particle_size * 0.6
	proc.scale_max                   = particle_size
	proc.color                       = color_particles
	var grad  := Gradient.new()
	grad.set_color(0, Color(color_particles.r, color_particles.g, color_particles.b, 0.0))
	grad.set_color(1, Color(color_particles.r, color_particles.g, color_particles.b, 0.9))
	var gt   := GradientTexture1D.new()
	gt.gradient = grad
	proc.color_ramp = gt
	p.process_material = proc
	var q   := QuadMesh.new()
	q.size   = Vector2(particle_size, particle_size)
	p.draw_pass_mesh = q
	add_child(p)

# ── Zone de détection ─────────────────────────────────────────
func _build_area() -> void:
	_area          = Area3D.new()
	_area.position = Vector3(0.0, portal_radius * vertical_stretch, 0.0)
	var sh         := CollisionShape3D.new()
	var cs         := CylinderShape3D.new()
	cs.radius       = portal_radius * 0.88
	cs.height       = portal_radius * vertical_stretch * 1.7
	sh.shape        = cs
	_area.add_child(sh)
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	add_child(_area)

# ═══════════════════════════════════════════════════════════════
#  PROCESS
# ═══════════════════════════════════════════════════════════════
func _process(delta: float) -> void:
	_time += delta

	# Anneau
	if _glow_mat:
		var p := pulse_amplitude * sin(_time * pulse_speed)
		_glow_mat.emission_energy_multiplier = ring_glow * (1.0 - pulse_amplitude * 0.4 + p * 0.4)
		_glow_mat.emission = color_ring * (0.7 + p * 0.3)

	# LEDs piliers
	for i in _led_mats.size():
		var b := 0.5 + 0.5 * sin(_time * 3.8 + float(i) * PI)
		_led_mats[i].emission_energy_multiplier = 3.0 + b * 6.0

	# Anneaux déco
	for i in _ring_mats.size():
		var w = 0.2 + 0.8 * abs(sin(_time * 1.8 + float(i) * 0.9))
		_ring_mats[i].emission_energy_multiplier = 0.4 + w * 2.5

	# Swirl
	if swirl_speed != 0.0:
		var face := get_node_or_null("PortalFace")
		if face: face.rotation.y += delta * swirl_speed

	if not auto_travel and _player_near and Input.is_action_just_pressed("interact"):
		_travel()

# ═══════════════════════════════════════════════════════════════
#  DÉTECTION & VOYAGE
# ═══════════════════════════════════════════════════════════════
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body is RigidBody3D or body is CharacterBody3D:
		_player_near = true
		if auto_travel: _travel()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") or body is RigidBody3D or body is CharacterBody3D:
		_player_near = false

func _travel() -> void:
	if next_scene.is_empty():
		push_warning("Portal: next_scene est vide !")
		return
	_fade_and_travel()

func _fade_and_travel() -> void:
	var canvas := CanvasLayer.new()
	var rect   := ColorRect.new()
	rect.color  = Color(0.0, 0.0, 0.0, 0.0)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(rect)
	get_tree().root.add_child(canvas)
	var tw := create_tween()
	tw.tween_property(rect, "color", Color(0, 0, 0, 1), 0.7).set_ease(Tween.EASE_IN)
	await tw.finished
	get_tree().change_scene_to_file(next_scene)
