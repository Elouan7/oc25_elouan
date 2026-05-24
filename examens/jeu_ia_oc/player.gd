extends RigidBody3D
@export var mouse_sensitivity := 0.001
@export var speed: float = 50.0
@export var jump_impulse: float = 5.0
		
@onready var twist_pivot: Node3D = $TwistPivot
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot
var twist_input := 0.0
var pitch_input := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lock_rotation = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_right", "move_left")
	input.z = Input.get_axis("move_backward", "move_forward")
	
	if input.length() > 1.0:
		input = input.normalized()
	
	var direction = (transform.basis * input)
	apply_central_force(direction * speed)
	
	# Jump ici avec la physique
	if Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector3.UP * jump_impulse)
	
	var vel = linear_velocity
	vel.x = lerp(vel.x, 0.0, 0.1)
	vel.z = lerp(vel.z, 0.0, 0.1)
	linear_velocity = vel
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30),
	)
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
