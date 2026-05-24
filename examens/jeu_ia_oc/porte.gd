## script_porte.gd
extends Node3D

@onready var mesh_porte : MeshInstance3D = $MeshInstance3D # Ajuste le nom si nécessaire
var porte_ouverte : bool = false

func _ready() -> void:
	# On connecte automatiquement le signal de l'Area3D s'il s'appelle "ZoneDetection"
	if has_node("ZoneDetection"):
		$ZoneDetection.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# On vérifie si le corps qui entre est bien dans le groupe "joueur"
	if body.is_in_group("joueur") and not porte_ouverte:
		ouvrir_la_porte()

func ouvrir_la_porte() -> void:
	porte_ouverte = true
	
	# Un Tween déplace proprement ta porte en code
	var tween := create_tween().set_parallel(false)
	
	# Exemple 1 : Fait monter la porte de 4 mètres vers le haut en 1.0 seconde
	tween.tween_property(mesh_porte, "position:y", mesh_porte.position.y + 4.0, 1.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
	# Exemple 2 (Si tu préfères qu'elle pivote, commente le bloc du haut et utilise celui-ci) :
	# tween.tween_property(mesh_porte, "rotation:y", mesh_porte.rotation.y + deg_to_rad(90), 1.0)
