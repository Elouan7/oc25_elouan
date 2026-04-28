extends CSGBox3D

@export var duration : float = 0.8
@export var jump_height : float = 3.0

var is_performing : bool = false
var timer : float = 0.0
var start_pos_y : float = 0.0
var start_rot : Vector3

func _ready():
	# On stocke la position de départ
	start_pos_y = position.y
	start_rot = rotation

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and not is_performing:
		is_performing = true
		timer = 0.0
	
	if is_performing:
		timer += delta
		var t = timer / duration # t va de 0.0 à 1.0
		
		if t <= 1.0:
			# 1. CALCUL DU SAUT (Parabole)
			# Formule : 4 * hauteur * t * (1 - t)
			var height_offset = 4 * jump_height * t * (1 - t)
			position.y = start_pos_y + height_offset
			
			# 2. CALCUL DU CORK (Rotation)
			# On ajoute 360 degrés (2 * PI) sur X et Y proportionnellement à t
			rotation.x = start_rot.x + (t * TAU) # TAU = 2 * PI (un tour complet)
			rotation.y = start_rot.y + (t * TAU)
		else:
			# FIN DE LA FIGURE
			is_performing = false
			position.y = start_pos_y
			rotation = start_rot
