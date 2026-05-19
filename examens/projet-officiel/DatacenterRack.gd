## DatacenterRack.gd
## Attach this script to a Node3D in your scene.
## It procedurally generates a full 42U datacenter rack with animated blinking LEDs.
##
## Usage:
##   1. Create a Node3D in your scene
##   2. Attach this script to it
##   3. Run the scene — the rack builds itself automatically
##
## Godot version: 4.6.2

extends Node3D

# ─── Rack configuration ───────────────────────────────────────────────────────
@export var rack_units: int = 42          # Total rack height in U
@export var unit_height: float = 0.04445  # 1U = 44.45mm in meters
@export var rack_width: float = 0.482     # 19-inch rack inner width
@export var rack_depth: float = 0.900     # Standard depth
@export var rack_wall_thickness: float = 0.003

# ─── LED configuration ────────────────────────────────────────────────────────
@export var led_light_range: float = 0.08
@export var led_light_energy: float = 1.2
@export var enable_lights: bool = true

# ─── Internal state ───────────────────────────────────────────────────────────
var _led_data: Array = []   # [{light: OmniLight3D, mesh: MeshInstance3D, type: String, phase: float, speed: float}]
var _time: float = 0.0

# LED type colours (linear color space)
const LED_COLORS = {
	"network": Color(0.0, 1.0, 0.1),    # green  — network activity
	"disk":    Color(1.0, 0.4, 0.0),    # orange — disk I/O
	"power":   Color(0.1, 0.4, 1.0),    # blue   — power OK
	"alert":   Color(1.0, 0.05, 0.05),  # red    — alert / error
}

# Blink speed ranges (Hz) per type
const LED_SPEEDS = {
	"network": [3.0, 8.0],
	"disk":    [1.0, 3.0],
	"power":   [0.05, 0.15],
	"alert":   [0.5, 1.0],
}

# ─── Server slot definitions ───────────────────────────────────────────────────
# Each entry: [height_in_U, label, base_color_hex, led_types_array]
const SERVER_TEMPLATES = [
	[1, "1U Server",       0x1a1a1a, ["power", "network", "disk"]],
	[2, "2U Server",       0x181818, ["power", "network", "disk", "disk"]],
	[1, "1U Switch",       0x0d1a0d, ["power", "network", "network", "network"]],
	[2, "2U Switch",       0x0d1520, ["power", "network", "network"]],
	[1, "Patch Panel",     0x111111, ["power"]],
	[1, "KVM",             0x1a1a0d, ["power", "disk"]],
	[2, "Storage Array",   0x0d0d1a, ["power", "disk", "disk", "alert"]],
	[1, "1U Firewall",     0x1a0d0d, ["power", "network", "alert"]],
]


func _ready() -> void:
	_build_rack()


func _process(delta: float) -> void:
	_time += delta
	_animate_leds()


# ══════════════════════════════════════════════════════════════════════════════
# BUILD
# ══════════════════════════════════════════════════════════════════════════════

func _build_rack() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	_build_chassis()
	_populate_servers(rng)
	_add_cable_management()


func _build_chassis() -> void:
	var total_h := rack_units * unit_height
	var mat_chassis := _make_metal_material(Color(0.08, 0.08, 0.10))
	var mat_rail    := _make_metal_material(Color(0.13, 0.13, 0.16))

	# ── Front frame (two vertical posts) ──
	for side in [-1, 1]:
		var post := _add_box(
			Vector3(side * (rack_width * 0.5 + rack_wall_thickness * 0.5), total_h * 0.5, 0.0),
			Vector3(rack_wall_thickness * 2.0, total_h, rack_depth),
			mat_chassis
		)
		post.name = "Post_" + ("L" if side < 0 else "R")

	# ── Top / bottom panels ──
	for sign in [-1, 1]:
		var panel := _add_box(
			Vector3(0.0, total_h * 0.5 + sign * (total_h * 0.5 + rack_wall_thickness * 0.5), 0.0),
			Vector3(rack_width + rack_wall_thickness * 4.0, rack_wall_thickness * 2.0, rack_depth),
			mat_chassis
		)
		panel.name = "Panel_" + ("Top" if sign > 0 else "Bottom")

	# ── Back panel ──
	var back := _add_box(
		Vector3(0.0, total_h * 0.5, -rack_depth * 0.5 + rack_wall_thickness),
		Vector3(rack_width, total_h, rack_wall_thickness * 2.0),
		mat_chassis
	)
	back.name = "BackPanel"

	# ── Inner rails (U-number strips) ──
	for side in [-1, 1]:
		var rail := _add_box(
			Vector3(side * (rack_width * 0.5 - 0.010), total_h * 0.5, rack_depth * 0.1),
			Vector3(0.018, total_h, 0.002),
			mat_rail
		)
		rail.name = "Rail_" + ("L" if side < 0 else "R")

	# ── PDU strip at the back-right ──
	var pdu := _add_box(
		Vector3(rack_width * 0.5 + 0.025, total_h * 0.5, -rack_depth * 0.1),
		Vector3(0.025, total_h * 0.9, 0.05),
		_make_metal_material(Color(0.06, 0.06, 0.08))
	)
	pdu.name = "PDU"
	_add_pdu_leds(pdu)


func _populate_servers(rng: RandomNumberGenerator) -> void:
	var total_h    := rack_units * unit_height
	var current_u  := 0
	var front_z    := rack_depth * 0.5 - 0.002  # flush with front face

	while current_u < rack_units - 1:
		var remaining := rack_units - current_u
		# Pick a random template that fits
		var candidates := SERVER_TEMPLATES.filter(func(t): return t[0] <= remaining)
		if candidates.is_empty():
			break
		var tmpl: Array = candidates[rng.randi() % candidates.size()]
		var u_size: int  = tmpl[0]
		var label: String = tmpl[1]
		var color_hex: int = tmpl[2]
		var led_types: Array = tmpl[3]

		var h       := u_size * unit_height
		var y_pos   := current_u * unit_height + h * 0.5
		var server  := _build_server_unit(
			Vector3(0.0, y_pos, front_z - 0.010),
			u_size, label, color_hex, led_types, rng
		)
		server.name = label.replace(" ", "_") + "_U%d" % current_u

		current_u += u_size

		# Occasionally leave a gap (empty 1U)
		if rng.randf() < 0.08 and current_u < rack_units - 1:
			current_u += 1


func _build_server_unit(
	pos: Vector3, u_size: int, label: String,
	color_hex: int, led_types: Array, rng: RandomNumberGenerator
) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	add_child(root)

	var h  := u_size * unit_height
	var w  := rack_width - 0.006
	var d  := 0.030  # server protrudes ~30mm from rail

	# Body
	var base_color := Color(
		((color_hex >> 16) & 0xff) / 255.0,
		((color_hex >> 8)  & 0xff) / 255.0,
		(color_hex         & 0xff) / 255.0
	)
	var mat_body   := _make_metal_material(base_color)
	var body_mesh  := _add_box(Vector3(0, 0, 0), Vector3(w, h - 0.001, d), mat_body, root)
	body_mesh.name = "Body"

	# Faceplate highlight strip (top edge)
	var mat_accent := _make_metal_material(base_color.lightened(0.15))
	_add_box(Vector3(0, h * 0.5 - 0.001, 0), Vector3(w, 0.002, d), mat_accent, root)

	# Ventilation grille (simple dark rect)
	var mat_grille := _make_metal_material(Color(0.03, 0.03, 0.03))
	_add_box(Vector3(-w * 0.15, 0, d * 0.5 + 0.0005), Vector3(w * 0.45, h * 0.6, 0.001), mat_grille, root)

	# LEDs
	var led_x_start := w * 0.5 - 0.008
	for i in led_types.size():
		var led_type: String = led_types[i]
		var led_x := led_x_start - i * 0.012
		_spawn_led(root, Vector3(led_x, 0.0, d * 0.5 + 0.001), led_type, rng)

	return root


func _add_pdu_leds(pdu_node: MeshInstance3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 6:
		var y := -0.05 + i * 0.08
		_spawn_led(pdu_node, Vector3(0.0, y, 0.026), "power", rng)


func _add_cable_management() -> void:
	var total_h := rack_units * unit_height
	var mat_cable := StandardMaterial3D.new()
	mat_cable.albedo_color = Color(0.05, 0.05, 0.05)
	mat_cable.roughness = 0.9

	# Vertical cable tray on the right
	_add_box(
		Vector3(rack_width * 0.5 - 0.005, total_h * 0.5, rack_depth * 0.2),
		Vector3(0.015, total_h, 0.015),
		mat_cable
	)


# ══════════════════════════════════════════════════════════════════════════════
# LED SPAWNING
# ══════════════════════════════════════════════════════════════════════════════

func _spawn_led(parent: Node3D, local_pos: Vector3, led_type: String, rng: RandomNumberGenerator) -> void:
	var color: Color = LED_COLORS.get(led_type, Color.WHITE)
	var speed_range: Array = LED_SPEEDS.get(led_type, [1.0, 2.0])
	var speed := rng.randf_range(speed_range[0], speed_range[1])
	var phase := rng.randf_range(0.0, TAU)

	# Tiny emissive mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color       = color
	mat.emission_enabled   = true
	mat.emission           = color
	mat.emission_energy_multiplier = 2.0

	var sphere_mesh        := SphereMesh.new()
	sphere_mesh.radius     = 0.003
	sphere_mesh.height     = 0.006
	sphere_mesh.radial_segments = 6
	sphere_mesh.rings      = 4

	var mi                 := MeshInstance3D.new()
	mi.mesh                = sphere_mesh
	mi.material_override   = mat
	mi.position            = local_pos
	parent.add_child(mi)

	var entry := { "mesh": mi, "mat": mat, "type": led_type, "phase": phase, "speed": speed, "color": color }

	# Optional point light for glow
	if enable_lights:
		var light            := OmniLight3D.new()
		light.position       = local_pos
		light.light_color    = color
		light.light_energy   = 0.0
		light.omni_range     = led_light_range
		light.shadow_enabled = false
		parent.add_child(light)
		entry["light"] = light
	else:
		entry["light"] = null

	_led_data.append(entry)


# ══════════════════════════════════════════════════════════════════════════════
# ANIMATION
# ══════════════════════════════════════════════════════════════════════════════

func _animate_leds() -> void:
	for entry in _led_data:
		var t      : float           = _time
		var phase  : float           = entry["phase"]
		var speed  : float           = entry["speed"]
		var led_type: String         = entry["type"]
		var mat    : StandardMaterial3D = entry["mat"]
		var light  : OmniLight3D     = entry["light"]
		var color  : Color           = entry["color"]
		var brightness: float

		match led_type:
			"power":
				# Slow gentle pulse
				brightness = 0.75 + 0.25 * sin(t * speed * TAU + phase)
			"network":
				# Fast random-feeling flicker
				brightness = abs(sin(t * speed * TAU + phase)) * abs(cos(t * speed * 1.3 * TAU + phase + 1.1))
			"disk":
				# Short bursts
				var raw := sin(t * speed * TAU + phase)
				brightness = 1.0 if raw > 0.6 else 0.05
			"alert":
				# Sharp on/off blink
				brightness = 1.0 if sin(t * speed * TAU + phase) > 0.0 else 0.0
			_:
				brightness = 1.0

		var lit_color := color * brightness
		mat.albedo_color = lit_color
		mat.emission     = lit_color
		mat.emission_energy_multiplier = 1.5 + brightness * 2.5

		if light:
			light.light_energy = brightness * led_light_energy


# ══════════════════════════════════════════════════════════════════════════════
# HELPERS
# ══════════════════════════════════════════════════════════════════════════════

func _add_box(
	pos: Vector3, size: Vector3,
	mat: Material, parent: Node3D = self
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi   := MeshInstance3D.new()
	mi.mesh  = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi


func _make_metal_material(color: Color) -> StandardMaterial3D:
	var mat                    := StandardMaterial3D.new()
	mat.albedo_color            = color
	mat.metallic                = 0.7
	mat.roughness               = 0.45
	mat.metallic_specular       = 0.5
	return mat
