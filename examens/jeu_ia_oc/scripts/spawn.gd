# Script de gestion du niveau courant
extends Node3D

func _ready():
	var spawn = $SpawnPoint
	var player = $PlayerN
	
	# Aligne la position et la rotation du joueur sur le point de spawn
	player.global_position = spawn.global_position
	player.global_rotation = spawn.global_rotation
	
	# Force la souris à se capturer pour éviter les bugs de caméra
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
