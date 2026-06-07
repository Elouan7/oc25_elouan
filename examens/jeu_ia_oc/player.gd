# Attache ce script sur le noeud racine "Player"
extends CharacterBody3D

# --- Paramètres ---
@export var speed := 5.0
@export var sprint_speed := 9.0
@export var jump_velocity := 8.0  # Une très grosse valeur pour être sûr de le voir décoller
@export var mouse_sensitivity := 0.002
@export var pitch_limit := 80.0

# --- Références ---
@onready var twist_pivot = $TwistPivot
@onready var pitch_pivot = $TwistPivot/PitchPivot

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("!!! DIAGNOSTIC : Le script du joueur est bien actif et s'exécute !!!")

func _input(event):
	if event is InputEventMouseMotion:
		twist_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		pitch_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# --- Gravité basique ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	# --- SAUT FORCE BRUTE (Sans aucune condition de sol + détection physique de la touche) ---
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
		print("-> TOUCHE ESPACE DETECTEE ! Force appliquée : ", jump_velocity)
		velocity.y = jump_velocity

	# --- Déplacement WASD (Inversé pour ton niveau) ---
	var input_dir := Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var direction = (twist_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
