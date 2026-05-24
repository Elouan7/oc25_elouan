@tool
extends Node3D
class_name RackGenerator

# C'est ici que tu vas glisser ton fichier "datacenter_rack.tscn"
@export var rack_scene: PackedScene 

@export var number_of_racks: int = 5:
	set(value):
		number_of_racks = max(1, value) # Empêche d'avoir moins de 1 rack

@export var spacing: float = 1.5 # L'écartement entre chaque rack

@export_tool_button("Générer les Racks") var generate_btn = generate_racks


func generate_racks():
	# 1. On supprime les anciens racks
	for child in get_children():
		child.queue_free()
		
	await get_tree().process_frame
	
	if rack_scene == null:
		print("Attention : Glisse ton fichier datacenter_rack.tscn dans l'inspecteur !")
		return
		
	# 3. Création des racks
	for i in range(number_of_racks):
		var new_rack = rack_scene.instantiate()
		add_child(new_rack)
		
		# Position sur l'axe X
		new_rack.position = Vector3(i * spacing, 0, 0)
		
		# --- NOUVEAU : On fait pivoter le rack de 90 degrés sur l'axe Y ---
		new_rack.rotation_degrees.y = 90 
		# Note : Si tu vois qu'ils te tournent le dos, change 90 par -90 !
		
		if Engine.is_editor_hint():
			new_rack.owner = get_tree().edited_scene_root
			
	print(str(number_of_racks) + " racks générés avec succès !")
