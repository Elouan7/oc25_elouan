# portal_trigger.gd
extends Area3D

# Tu pourras modifier ce chemin directement depuis l'Inspecteur à droite
@export var next_scene : String = "uid://cyjjsoxur5dwi"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Vérifie si le corps physique fait partie du groupe "player"
	if body.is_in_group("player"):
		SceneTransition.change_scene(next_scene) # Lance la transition automatique
