@tool
extends Node3D
class_name SimpleMazeGenerator

@export var rack_scene: PackedScene 

# La taille de ton labyrinthe
@export var grid_width: int = 10
@export var grid_height: int = 10
@export var spacing: float = 1.0 # Mets ici la taille que tu as trouvée tout à l'heure !

# Le nombre de pas que va faire notre "creuseur"
@export var steps: int = 60 

@export_tool_button("Générer Labyrinthe") var generate_btn = generate_maze

func generate_maze():
	# 1. On nettoie la scène (on supprime l'ancien labyrinthe)
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	
	if rack_scene == null:
		print("N'oublie pas de glisser ton datacenter_rack.tscn dans l'inspecteur !")
		return
		
	# 2. On crée une grille entièrement remplie de Racks (1 = Rack, 0 = Vide)
	var grid = []
	for x in range(grid_width):
		var column = []
		for z in range(grid_height):
			column.append(1) # On remplit tout de "1"
		grid.append(column)
		
	# 3. L'algorithme du "Creuseur fou" (Marche aléatoire)
	@warning_ignore("integer_division")
	var current_x = grid_width / 2 # On place notre robot au milieu de la grille
	@warning_ignore("integer_division")
	var current_z = grid_height / 2
	
	for i in range(steps):
		# Le robot détruit le rack sur la case où il se trouve
		grid[current_x][current_z] = 0 
		
		# Le robot choisit une direction au hasard (0: Droite, 1: Gauche, 2: Bas, 3: Haut)
		var direction = randi() % 4
		
		# Il avance, mais on vérifie qu'il ne sort pas de la carte !
		if direction == 0 and current_x < grid_width - 1:
			current_x += 1
		elif direction == 1 and current_x > 0:
			current_x -= 1
		elif direction == 2 and current_z < grid_height - 1:
			current_z += 1
		elif direction == 3 and current_z > 0:
			current_z -= 1

	# 4. On place les vrais modèles 3D là où il reste des "1"
	for x in range(grid_width):
		for z in range(grid_height):
			if grid[x][z] == 1:
				var new_rack = rack_scene.instantiate()
				add_child(new_rack)
				
				# On positionne sur X et Z (pour s'étaler sur le sol)
				new_rack.position = Vector3(x * spacing, 0, z * spacing)
				
				# J'ai gardé la rotation de 90 degrés dont on a parlé tout à l'heure !
				new_rack.rotation_degrees.y = 90
				
				if Engine.is_editor_hint():
					new_rack.owner = get_tree().edited_scene_root
