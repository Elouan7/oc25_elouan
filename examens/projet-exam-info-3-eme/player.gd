extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const GRAVITY = 9.81

func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Déplacement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide() 
