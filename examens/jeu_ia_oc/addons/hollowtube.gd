@tool
extends CSGCylinder3D
class_name HollowTube

## Règle directement la grandeur du trou à l'intérieur
@export var rayon_du_trou := 0.4:
	set(value):
		rayon_du_trou = value
		if is_inside_tree():
			create()

func _ready():
	create()

func create():
	# Sécurité pour éviter les bugs de l'éditeur Godot
	if not is_inside_tree(): 
		return

	var inner = null
	for child in get_children():
		if child.owner == null:
			inner = child
			break
			
	if inner == null:
		inner = CSGCylinder3D.new()
		inner.operation = CSGShape3D.OPERATION_SUBTRACTION
		add_child(inner)
		
	if material:
		inner.material = material
		
	# La magie est ici : le cylindre intérieur (le trou) prend la grandeur exacte que tu as choisie
	inner.radius = rayon_du_trou
	inner.height = height * 1.01 # Un peu plus grand pour éviter les bugs d'affichage
	inner.sides = sides
	inner.cone = cone
