@tool
extends Node3D

@export var rack_scene: PackedScene
@export var number_of_racks: int = 5
@export var spacing: float = 2.5
@export var rotation_visuelle: float = 90.0

@export var CLIQUE_ICI_POUR_GENERER: bool = false:
	set(value):
		if value == true:
			_generer_le_datacenter()

func _generer_le_datacenter():
	# 1. NETTOYAGE
	for child in get_children():
		child.free()
	
	if not rack_scene:
		print("ERREUR : Glisse la scène de ton rack dans l'inspecteur !")
		return
		
	# 2. GENERATION
	for i in range(number_of_racks):
		var new_rack = rack_scene.instantiate()
		add_child(new_rack)
		
		# --- LA LIGNE MAGIQUE POUR EMPECHER LA DISPARITION ---
		if Engine.is_editor_hint():
			new_rack.owner = get_tree().edited_scene_root
		# -----------------------------------------------------
		
		new_rack.position = Vector3(0, 0, i * spacing)
		new_rack.rotation_degrees.y = rotation_visuelle
		
	print("Datacenter généré et SAUVEGARDÉ dans l'éditeur !")
