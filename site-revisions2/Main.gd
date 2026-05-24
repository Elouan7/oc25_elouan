## Main.gd — Datacenter Scene with CIPHER
## Godot 4.6.2
##
## INSTALLATION :
##   1. Nouvelle scène > Node3D comme racine
##   2. Attache ce script au Node3D racine
##   3. Lance (F6)
##
## CONTRÔLES :
##   Clic gauche + glisser  → orbiter
##   Molette                → zoom
##   Clic droit + glisser   → panoramique

extends Node3D

# PARAMETRES EXPORTES
@export_group("Rack")
@export var rack_units        : int   = 42
@export var unit_height       : float = 0.04445
@export var rack_width        : float = 0.482
@export var rack_depth        : float = 0.900
@export var rack_wall         : float = 0.003

@export_group("LEDs")
@export var enable_lights     : bool  = true
@export var led_range         : float = 0.10
@export var led_energy        : float = 1.5

@export_group("CIPHER")
@export var spawn_cipher      : bool  = true
@export var cipher_position   : Vector3 = Vector3(1.2, 0.0, 0.3)

# ETAT INTERNE
var _leds   : Array = []
var _cipher : Node3D
var _time   : float = 0.0

# Caméra orbit
var _cam            : Camera3D
var _orbit_yaw      : float   = 30.0
var _orbit_pitch    : float   = -18.0
var _orbit_dist     : float   = 3.5
var _orbit_target   : Vector3 = Vector3(0.5, 0.8, 0.0)
var _drag_left      : bool    = false
var _drag_right     : bool    = false
var _last_mouse     : Vector2 = Vector2.ZERO

# DONNEES LED
const LED_COLORS = {
	"power":   Color(0.05, 0.30, 1.00),
	"network": Color(0.00, 1.00, 0.15),
	"disk":    Color(1.00, 0.45, 0.00),
	"alert":   Color(1.00, 0.04, 0.04),
	"visor":   Color(0.00, 1.00, 0.55),
}
const LED_SPEEDS = {
	"power":   [0.05, 0.20],
	"network": [3.00, 9.00],
	"disk":    [1.00, 3.50],
	"alert":   [0.40, 1.00],
	"visor":   [2.00, 4.00],
}

# TEMPLATES SERVEURS
const TEMPLATES = [
	[1, "1U Server",    0x1a1a1a, ["power", "network", "disk"]],
	[2, "2U Server",    0x181818, ["power", "network", "disk", "disk"]],
	[1, "1U Switch",    0x0d1a0d, ["power", "network", "network", "network"]],
	[2, "2U Switch",    0x0d1520, ["power", "network", "network"]],
	[1, "Patch Panel",  0x111111, ["power"]],
	[1, "KVM",          0x1a1a0d, ["power", "disk"]],
	[2, "Storage 2U",   0x0d0d1a, ["power", "disk", "disk", "alert"]],
	[1, "Firewall",     0x1a0d0d, ["power", "network", "alert"]],
	[1, "1U Blank",     0x0d0d0d, []],
]

# READY / PROCESS
func _ready() -> void:
	_setup_environment()
	_setup_lights()
	_setup_camera()
	_build_rack()
	if spawn_cipher:
		_build_cipher()

func _process(delta: float) -> void:
	_time += delta
	_animate_leds()
	_animate_cipher()
	_update_camera()

# ENVIRONNEMENT
func _setup_environment() -> void:
	var env                        := Environment.new()
	env.background_mode             = Environment.BG_COLOR
	env.background_color            = Color(0.04, 0.04, 0.07)
	env.ambient_light_source        = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color         = Color(0.12, 0.16, 0.28)
	env.ambient_light_energy        = 0.7
	env.tonemap_mode                = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled                = true
	env.glow_intensity              = 0.8
	env.glow_bloom                  = 0.15
	env.glow_hdr_threshold          = 0.7
	var we                         := WorldEnvironment.new()
	we.environment                  = env
	add_child(we)

func _setup_lights() -> void:
	var dir              := DirectionalLight3D.new()
	dir.light_color       = Color(0.88, 0.92, 1.00)
	dir.light_energy      = 0.9
	dir.shadow_enabled    = true
	dir.rotation_degrees  = Vector3(-42, 28, 0)
	add_child(dir)

	var fill             := OmniLight3D.new()
	fill.light_color      = Color(0.30, 0.50, 1.00)
	fill.light_energy     = 0.6
	fill.omni_range       = 6.0
	fill.position         = Vector3(-2.0, 1.5, 1.5)
	fill.shadow_enabled   = false
	add_child(fill)

	var rack_fill             := OmniLight3D.new()
	rack_fill.light_color      = Color(0.10, 0.80, 0.30)
	rack_fill.light_energy     = 0.25
	rack_fill.omni_range       = 3.0
	rack_fill.position         = Vector3(-0.5, 0.9, 1.2)
	rack_fill.shadow_enabled   = false
	add_child(rack_fill)

# CAMERA ORBIT
func _setup_camera() -> void:
	_cam       = Camera3D.new()
	_cam.fov   = 52.0
	_cam.near  = 0.01
	add_child(_cam)
	_update_camera()

func _update_camera() -> void:
	if not _cam:
		return
	var yr  := deg_to_rad(_orbit_yaw)
	var pr  := deg_to_rad(_orbit_pitch)
	var off := Vector3(
		_orbit_dist * cos(pr) * sin(yr),
		_orbit_dist * sin(pr),
		_orbit_dist * cos(pr) * cos(yr)
	)
	_cam.position = _orbit_target + off
	_cam.look_at(_orbit_target, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_drag_left  = event.pressed
				_last_mouse = event.position
			MOUSE_BUTTON_RIGHT:
				_drag_right = event.pressed
				_last_mouse = event.position
			MOUSE_BUTTON_WHEEL_UP:
				_orbit_dist = max(0.5, _orbit_dist - 0.15)
			MOUSE_BUTTON_WHEEL_DOWN:
				_orbit_dist = min(8.0, _orbit_dist + 0.15)
	elif event is InputEventMouseMotion:
		var delta_mouse: Vector2 = event.position - _last_mouse
		_last_mouse = event.position
		if _drag_left:
			_orbit_yaw   -= delta_mouse.x * 0.35
			_orbit_pitch  = clamp(_orbit_pitch + delta_mouse.y * 0.25, -85.0, 85.0)
		if _drag_right:
			var right := _cam.global_transform.basis.x
			_orbit_target -= right    * delta_mouse.x * 0.001 * _orbit_dist
			_orbit_target += Vector3.UP * delta_mouse.y * 0.001 * _orbit_dist

# RACK - CHASSIS
func _build_rack() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_build_chassis()
	_populate_servers(rng)

func _build_chassis() -> void:
	var total_h  := rack_units * unit_height
	var mat_dark := _metal(Color(0.07, 0.07, 0.09))
	var mat_mid  := _metal(Color(0.11, 0.11, 0.14))
	var mat_rail := _metal(Color(0.17, 0.17, 0.21))

	for sx in [-1, 1]:
		_box(Vector3(sx * (rack_width * 0.5 + rack_wall), total_h * 0.5, 0.0),
			 Vector3(rack_wall * 2.0, total_h + rack_wall * 2.0, rack_depth + rack_wall * 2.0),
			 mat_dark)

	for sy in [-1, 1]:
		_box(Vector3(0.0, total_h * 0.5 + sy * (total_h * 0.5 + rack_wall), 0.0),
			 Vector3(rack_width + rack_wall * 4.0, rack_wall * 2.0, rack_depth + rack_wall * 2.0),
			 mat_dark)

	_box(Vector3(0.0, total_h * 0.5, -(rack_depth * 0.5 + rack_wall)),
		 Vector3(rack_width, total_h, rack_wall * 2.0), mat_mid)

	for sx in [-1, 1]:
		_box(Vector3(sx * (rack_width * 0.5 - 0.010), total_h * 0.5, rack_depth * 0.15),
			 Vector3(0.018, total_h, 0.002), mat_rail)

	_box(Vector3(rack_width * 0.5 + 0.030, total_h * 0.5, -rack_depth * 0.05),
		 Vector3(0.028, total_h * 0.92, 0.055), _metal(Color(0.05, 0.05, 0.07)))

	_box(Vector3(0.0, -0.025, 0.0),
		 Vector3(rack_width + 0.06, 0.05, rack_depth + 0.06),
		 _metal(Color(0.09, 0.09, 0.11)))

func _populate_servers(rng: RandomNumberGenerator) -> void:
	var current_u := 0
	var front_z   := rack_depth * 0.5 - 0.001
	while current_u < rack_units - 1:
		var remaining  := rack_units - current_u
		var candidates := TEMPLATES.filter(func(t): return t[0] <= remaining)
		if candidates.is_empty():
			break
		var tmpl      : Array  = candidates[rng.randi() % candidates.size()]
		var u_size    : int    = tmpl[0]
		var hex_col   : int    = tmpl[2]
		var led_types : Array  = tmpl[3]
		var h         := u_size * unit_height
		var y_pos     := current_u * unit_height + h * 0.5
		_build_server(Vector3(0.0, y_pos, front_z - 0.012),
					  u_size, hex_col, led_types, rng)
		current_u += u_size
		if rng.randf() < 0.06 and current_u < rack_units - 1:
			current_u += 1

func _build_server(pos: Vector3, u_size: int, hex_col: int,
				   led_types: Array, rng: RandomNumberGenerator) -> void:
	var root      := Node3D.new()
	root.position  = pos
	add_child(root)
	var h := u_size * unit_height
	var w := rack_width - 0.008
	var d := 0.032
	var base := Color(
		((hex_col >> 16) & 0xff) / 255.0,
		((hex_col >>  8) & 0xff) / 255.0,
		( hex_col        & 0xff) / 255.0)
	_box(Vector3.ZERO, Vector3(w, h - 0.0015, d), _metal(base), root)
	_box(Vector3(0, h*0.5 - 0.0008, 0), Vector3(w, 0.0016, d),
		 _metal(base.lightened(0.22)), root)
	_box(Vector3(-w*0.12, 0, d*0.5 + 0.0005), Vector3(w*0.42, h*0.55, 0.001),
		 _metal(Color(0.02, 0.02, 0.02)), root)
	var led_x_start := w * 0.5 - 0.008
	for i in led_types.size():
		_spawn_led(root,
			Vector3(led_x_start - i * 0.013, 0.0, d * 0.5 + 0.001),
			led_types[i], rng)

# CIPHER - PERSONNAGE
var _cipher_visor_mat  : StandardMaterial3D
var _cipher_visor_mesh : MeshInstance3D
var _cipher_ant_led    : MeshInstance3D
var _cipher_ant_light  : OmniLight3D
var _cipher_arm_l      : Node3D
var _cipher_arm_r      : Node3D
var _cipher_cloak_parts: Array = []

func _build_cipher() -> void:
	_cipher          = Node3D.new()
	_cipher.name     = "CIPHER"
	_cipher.position = cipher_position
	add_child(_cipher)

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for sx in [-1, 1]:
		var leg_root      := Node3D.new()
		leg_root.position  = Vector3(sx * 0.12, 0.0, 0.0)
		_cipher.add_child(leg_root)
		_box(Vector3(0, -0.28, 0), Vector3(0.14, 0.38, 0.13),
			 _metal(Color(0.09, 0.14, 0.20)), leg_root)
		_box(Vector3(0, -0.48, 0.04), Vector3(0.12, 0.06, 0.04),
			 _metal(Color(0.15, 0.22, 0.32)), leg_root)
		_box(Vector3(0, -0.68, 0.01), Vector3(0.11, 0.32, 0.12),
			 _metal(Color(0.07, 0.12, 0.18)), leg_root)
		_box(Vector3(0, -0.87, 0.03), Vector3(0.13, 0.08, 0.17),
			 _metal(Color(0.05, 0.08, 0.12)), leg_root)
		_box(Vector3(0.04 * sx, -0.62, 0.065), Vector3(0.02, 0.28, 0.005),
			 _metal(Color(0.0, 0.20, 0.60)), leg_root)

	var torso_root      := Node3D.new()
	torso_root.position  = Vector3(0, 0.28, 0)
	_cipher.add_child(torso_root)
	_box(Vector3(0, 0, 0), Vector3(0.48, 0.52, 0.20),
		 _metal(Color(0.08, 0.14, 0.22)), torso_root)
	for sx2 in [-1, 1]:
		_box(Vector3(sx2 * 0.10, 0.05, 0.11), Vector3(0.16, 0.26, 0.02),
			 _metal(Color(0.12, 0.20, 0.30)), torso_root)
	for sx2 in [-1, 1]:
		_box(Vector3(sx2 * 0.30, 0.20, 0), Vector3(0.14, 0.08, 0.24),
			 _metal(Color(0.14, 0.24, 0.36)), torso_root)
		_box(Vector3(sx2 * 0.30, 0.10, 0), Vector3(0.13, 0.22, 0.20),
			 _metal(Color(0.10, 0.18, 0.28)), torso_root)
	_box(Vector3(0, 0, 0.105), Vector3(0.035, 0.45, 0.015),
		 _metal(Color(0.05, 0.10, 0.18)), torso_root)
	_box(Vector3(0, -0.27, 0), Vector3(0.46, 0.06, 0.18),
		 _metal(Color(0.10, 0.16, 0.24)), torso_root)

	_cipher_arm_l           = Node3D.new()
	_cipher_arm_l.position   = Vector3(-0.30, 0.28, 0)
	_cipher.add_child(_cipher_arm_l)
	_build_arm(-1, _cipher_arm_l, rng)

	_cipher_arm_r           = Node3D.new()
	_cipher_arm_r.position   = Vector3(0.30, 0.28, 0)
	_cipher.add_child(_cipher_arm_r)
	_build_arm(1, _cipher_arm_r, rng)

	_box(Vector3(0, 0.58, 0), Vector3(0.10, 0.09, 0.10),
		 _metal(Color(0.07, 0.12, 0.18)), _cipher)

	_build_cipher_head(rng)

	for i in 7:
		var cp      := Node3D.new()
		cp.position  = Vector3(0, 0.10 - i * 0.16, -0.12)
		_cipher.add_child(cp)
		var cw := 0.50 + i * 0.03
		var ch := 0.13 + i * 0.01
		var mi := _box(Vector3(0, 0, 0), Vector3(cw, ch, 0.015),
				  _metal(Color(0.04, 0.07, 0.12)), cp)
		_cipher_cloak_parts.append({"node": cp, "index": i, "mesh": mi})

func _build_arm(sx: int, parent: Node3D, rng: RandomNumberGenerator) -> void:
	_box(Vector3(0, -0.10, 0), Vector3(0.11, 0.30, 0.11),
		 _metal(Color(0.09, 0.15, 0.22)), parent)
	_box(Vector3(0, -0.27, 0.01), Vector3(0.10, 0.06, 0.10),
		 _metal(Color(0.14, 0.22, 0.32)), parent)
	_box(Vector3(0, -0.43, 0.01), Vector3(0.09, 0.28, 0.10),
		 _metal(Color(0.07, 0.12, 0.18)), parent)
	_box(Vector3(0, -0.55, 0.01), Vector3(0.11, 0.04, 0.12),
		 _metal(Color(0.12, 0.20, 0.30)), parent)
	_box(Vector3(0, -0.64, 0.01), Vector3(0.09, 0.10, 0.10),
		 _metal(Color(0.06, 0.10, 0.16)), parent)
	_box(Vector3(sx * 0.04, -0.42, 0.055), Vector3(0.015, 0.22, 0.005),
		 _metal(Color(0.0, 0.18, 0.55)), parent)

func _build_cipher_head(rng: RandomNumberGenerator) -> void:
	var head_root      := Node3D.new()
	head_root.position  = Vector3(0, 0.72, 0)
	_cipher.add_child(head_root)

	_box(Vector3(0, 0.08, 0), Vector3(0.36, 0.34, 0.28),
		 _metal(Color(0.08, 0.14, 0.22)), head_root)
	for sx in [-1, 1]:
		_box(Vector3(sx * 0.19, 0.08, 0), Vector3(0.03, 0.26, 0.25),
			 _metal(Color(0.06, 0.10, 0.18)), head_root)
	_box(Vector3(0, -0.10, 0.02), Vector3(0.26, 0.08, 0.22),
		 _metal(Color(0.07, 0.12, 0.19)), head_root)

	var visor_mat                        := StandardMaterial3D.new()
	visor_mat.albedo_color                = Color(0.00, 0.05, 0.15, 0.92)
	visor_mat.emission_enabled            = true
	visor_mat.emission                    = Color(0.0, 0.8, 0.4)
	visor_mat.emission_energy_multiplier  = 1.5
	visor_mat.transparency                = BaseMaterial3D.TRANSPARENCY_ALPHA
	visor_mat.metallic                    = 0.1
	visor_mat.roughness                   = 0.05
	_cipher_visor_mat = visor_mat

	var visor_mesh       := BoxMesh.new()
	visor_mesh.size       = Vector3(0.28, 0.18, 0.005)
	var visor_mi         := MeshInstance3D.new()
	visor_mi.mesh         = visor_mesh
	visor_mi.material_override = visor_mat
	visor_mi.position     = Vector3(0, 0.10, 0.145)
	head_root.add_child(visor_mi)
	_cipher_visor_mesh = visor_mi

	_box(Vector3(0, 0.10, 0.140), Vector3(0.32, 0.22, 0.004),
		 _metal(Color(0.10, 0.22, 0.38)), head_root)

	_box(Vector3(0.07, 0.28, 0.02), Vector3(0.02, 0.12, 0.02),
		 _metal(Color(0.12, 0.20, 0.30)), head_root)

	var ant_mat                       := StandardMaterial3D.new()
	ant_mat.albedo_color               = Color(0.0, 0.7, 1.0)
	ant_mat.emission_enabled           = true
	ant_mat.emission                   = Color(0.0, 0.7, 1.0)
	ant_mat.emission_energy_multiplier = 4.0
	var ant_sm     := SphereMesh.new()
	ant_sm.radius   = 0.014
	ant_sm.height   = 0.028
	var ant_mi     := MeshInstance3D.new()
	ant_mi.mesh     = ant_sm
	ant_mi.material_override = ant_mat
	ant_mi.position = Vector3(0.07, 0.37, 0.02)
	head_root.add_child(ant_mi)
	_cipher_ant_led = ant_mi

	if enable_lights:
		var ant_light            := OmniLight3D.new()
		ant_light.position        = ant_mi.position
		ant_light.light_color     = Color(0.0, 0.7, 1.0)
		ant_light.light_energy    = 2.0
		ant_light.omni_range      = 0.5
		ant_light.shadow_enabled  = false
		head_root.add_child(ant_light)
		_cipher_ant_light = ant_light

	if enable_lights:
		var vl              := OmniLight3D.new()
		vl.position          = Vector3(0, 0.10, 0.20)
		vl.light_color       = Color(0.0, 1.0, 0.5)
		vl.light_energy      = 0.8
		vl.omni_range        = 0.35
		vl.shadow_enabled    = false
		head_root.add_child(vl)
		_leds.append({
			"mat": visor_mat, "type": "visor",
			"phase": 0.0, "speed": 2.5,
			"color": Color(0.0, 1.0, 0.55), "light": vl
		})

# ANIMATION CIPHER
func _animate_cipher() -> void:
	if not _cipher:
		return

	_cipher.position.y = cipher_position.y + sin(_time * 0.9) * 0.015

	if _cipher_arm_l:
		_cipher_arm_l.rotation.x = sin(_time * 1.1) * 0.12
	if _cipher_arm_r:
		_cipher_arm_r.rotation.x = sin(_time * 1.1 + PI) * 0.12

	if _cipher_visor_mesh:
		_cipher_visor_mesh.get_parent().rotation.y = sin(_time * 0.6) * 0.06

	if _cipher_ant_led:
		var pulse := 0.5 + 0.5 * sin(_time * 3.5)
		var mat   := _cipher_ant_led.material_override as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = 2.0 + pulse * 5.0
	if _cipher_ant_light:
		_cipher_ant_light.light_energy = 1.0 + sin(_time * 3.5) * 0.8

	for entry in _cipher_cloak_parts:
		var cp  : Node3D = entry["node"]
		var idx : int    = entry["index"]
		cp.rotation.x = sin(_time * 1.3 + idx * 0.4) * 0.08
		cp.position.z  = -0.12 - idx * 0.008 + sin(_time * 0.9 + idx * 0.5) * 0.012

	if _cipher_visor_mat:
		var flicker := 0.7 + 0.3 * sin(_time * 4.0 + sin(_time * 13.0) * 0.5)
		_cipher_visor_mat.emission_energy_multiplier = flicker * 2.5

# LEDs RACK
func _spawn_led(parent: Node3D, local_pos: Vector3,
				led_type: String, rng: RandomNumberGenerator) -> void:
	var color  : Color = LED_COLORS.get(led_type, Color.WHITE)
	var speeds : Array = LED_SPEEDS.get(led_type, [1.0, 2.0])
	var speed  := rng.randf_range(speeds[0], speeds[1])
	var phase  := rng.randf_range(0.0, TAU)

	var mat                           := StandardMaterial3D.new()
	mat.albedo_color                   = color
	mat.emission_enabled               = true
	mat.emission                       = color
	mat.emission_energy_multiplier     = 3.0

	var sm           := SphereMesh.new()
	sm.radius         = 0.0028
	sm.height         = 0.0056
	sm.radial_segments = 6
	sm.rings          = 3

	var mi              := MeshInstance3D.new()
	mi.mesh              = sm
	mi.material_override = mat
	mi.position          = local_pos
	parent.add_child(mi)

	var entry := { "mat": mat, "type": led_type, "phase": phase,
				   "speed": speed, "color": color, "light": null }

	if enable_lights:
		var light            := OmniLight3D.new()
		light.position        = local_pos
		light.light_color     = color
		light.light_energy    = 0.0
		light.omni_range      = led_range
		light.shadow_enabled  = false
		parent.add_child(light)
		entry["light"] = light

	_leds.append(entry)

func _animate_leds() -> void:
	for e in _leds:
		var brightness : float
		match e["type"]:
			"power":
				brightness = 0.70 + 0.30 * sin(_time * e["speed"] * TAU + e["phase"])
			"network":
				brightness = (abs(sin(_time * e["speed"] * TAU + e["phase"]))
							* abs(cos(_time * e["speed"] * 1.4 * TAU + e["phase"] + 1.2)))
			"disk":
				brightness = 1.0 if sin(_time * e["speed"] * TAU + e["phase"]) > 0.5 else 0.04
			"alert":
				brightness = 1.0 if sin(_time * e["speed"] * TAU + e["phase"]) > 0.0 else 0.0
			"visor":
				brightness = 0.6 + 0.4 * abs(sin(_time * e["speed"] + e["phase"]))
			_:
				brightness = 1.0

		var c   : Color               = e["color"] * brightness
		var mat : StandardMaterial3D  = e["mat"]
		mat.albedo_color               = c
		mat.emission                   = c
		mat.emission_energy_multiplier = 1.0 + brightness * 4.0

		var light : OmniLight3D = e["light"]
		if light:
			light.light_energy = brightness * led_energy

# HELPERS
func _box(pos: Vector3, size: Vector3, mat: Material,
		  parent: Node3D = self) -> MeshInstance3D:
	var bm  := BoxMesh.new()
	bm.size  = size
	var mi  := MeshInstance3D.new()
	mi.mesh  = bm
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi

func _metal(color: Color) -> StandardMaterial3D:
	var m             := StandardMaterial3D.new()
	m.albedo_color     = color
	m.metallic         = 0.75
	m.roughness        = 0.38
	m.metallic_specular = 0.5
	return m
