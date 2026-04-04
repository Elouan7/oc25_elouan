extends CharacterBody3D

@export var speed = 7.0
@export var jump_velocity = 4.5
@export var sensitivity = 0.003

# On crée la tête et la caméra automatiquement si elles n'existent pas
var head : Node3D
var camera : Camera3D

func _ready():
	# Configuration automatique de la hiérarchie
	setup_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func setup_player():
	# Création de la tête (pivot pour la vue)
	head = Node3D.new()
	head.name = "Head"
	add_child(head)
	head.position.y = 1.8 # Hauteur des yeux
	
	# Création de la caméra
	camera = Camera3D.new()
	head.add_child(camera)
	
	# Création d'une forme de collision basique si absente
	if get_child_count() < 2:
		var col = CollisionShape3D.new()
		var shape = CapsuleShape3D.new()
		col.shape = shape
		add_child(col)
		col.position.y = 1.0

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		head.rotate_x(-event.relative.y * sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Mouvement (ZQSD par défaut sur Godot sont mappés sur ui_up, ui_down, etc. ou les flèches)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
