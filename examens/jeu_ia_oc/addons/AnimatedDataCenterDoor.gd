@tool
extends Node3D
class_name AnimatedDataCenterDoor

@export_group("Settings")
## Ouvre ou ferme la porte.
@export var is_open: bool = false:
	set(v):
		is_open = v
		if Engine.is_editor_hint() or not is_inside_tree():
			_update_door_position_instant()
		else:
			_animate_doors()

@export var door_speed := 0.8 ## Temps en secondes pour l'ouverture.
@export var portal_color := Color(0.0, 0.7, 1.0, 1.0):
	set(v): portal_color = v; create()

# Références pour l'animation
var door_l : CSGBox3D
var door_r : CSGBox3D

func _ready():
	create()
	_update_door_position_instant()

func create():
	for child in get_children():
		child.queue_free()
	
	# 1. LE CADRE (Statique)
	var frame = CSGBox3D.new()
	frame.size = Vector3(3.2, 3.5, 0.6)
	add_child(frame)
	
	var hole = CSGBox3D.new()
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	hole.size = Vector3(2.2, 2.8, 1.0)
	frame.add_child(hole)
	
	var mat_frame = StandardMaterial3D.new()
	mat_frame.albedo_color = Color(0.05, 0.05, 0.05)
	mat_frame.metallic = 0.5
	frame.material = mat_frame

	# 2. LES PANNEAUX DE PORTE (Mobiles)
	door_l = _create_door_panel(-1)
	door_r = _create_door_panel(1)
	
	# 3. LUMIÈRE & NÉONS
	_create_decoration()

	if Engine.is_editor_hint():
		for c in get_children(): c.owner = get_tree().edited_scene_root

func _create_door_panel(side: int) -> CSGBox3D:
	var p = CSGBox3D.new()
	p.size = Vector3(1.15, 2.8, 0.2) # La moitié de la largeur du trou
	add_child(p)
	
	var mat_door = StandardMaterial3D.new()
	mat_door.albedo_color = Color(0.15, 0.15, 0.15)
	mat_door.metallic = 0.9
	mat_door.roughness = 0.1
	p.material = mat_door
	return p

func _create_decoration():
	# Ajout d'une petite barre néon sur chaque porte pour le style
	for d in [door_l, door_r]:
		var neon = CSGBox3D.new()
		neon.size = Vector3(0.05, 2.0, 0.25)
		neon.position.z = 0.05
		d.add_child(neon)
		
		var mat_n = StandardMaterial3D.new()
		mat_n.emission_enabled = true
		mat_n.emission = portal_color
		mat_n.emission_energy_multiplier = 5.0
		neon.material = mat_n

# --- LOGIQUE D'ANIMATION ---

## Déplace les portes instantanément (utile pour l'éditeur)
func _update_door_position_instant():
	if not door_l or not door_r: return
	var offset = 1.05 if is_open else 0.55
	door_l.position.x = -offset
	door_r.position.x = offset

## Crée une transition fluide
func _animate_doors():
	var tween = create_tween()
	# On définit la position cible selon si c'est ouvert ou fermé
	var target_offset = 1.1 if is_open else 0.55
	
	# Transition parallèle pour les deux portes
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(door_l, "position:x", -target_offset, door_speed)
	tween.tween_property(door_r, "position:x", target_offset, door_speed)
	
	# Optionnel : changer la couleur du néon quand ça s'ouvre ?
	var target_color = portal_color if is_open else portal_color * 0.5
	# (On pourrait tweener la couleur ici aussi)
