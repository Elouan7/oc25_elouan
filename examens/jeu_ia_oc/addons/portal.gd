@tool
extends CSGBox3D
class_name BluePortalBox
## Crée un portail creux qui émet des particules et de la lumière.

@export var thickness := 0.2:
	set(value):
		thickness = value
		create()

@export var portal_color := Color(0.2, 0.6, 1.0, 1.0): 
	set(value):
		portal_color = value
		create()

var _last_size := Vector3.ZERO

func _ready():
	_last_size = size
	create()

func _process(_delta):
	if size != _last_size:
		_last_size = size
		create()

func create():
	var inner_hole : CSGBox3D = null
	var particles : GPUParticles3D = null
	var portal_light : OmniLight3D = null # On ajoute une variable pour la lumière
	
	# 1. On cherche les enfants procéduraux
	for child in get_children():
		if child.owner == null:
			if child is CSGBox3D:
				inner_hole = child
			elif child is GPUParticles3D:
				particles = child
			elif child is OmniLight3D:
				portal_light = child
			
	# 2. Le Trou
	if inner_hole == null:
		inner_hole = CSGBox3D.new()
		inner_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
		add_child(inner_hole)
		
	inner_hole.size = size
	inner_hole.size.x -= thickness * 2
	inner_hole.size.y -= thickness * 2
	inner_hole.size.z += 0.1
	
	# 3. La Vraie Lumière (NOUVEAU)
	if portal_light == null:
		portal_light = OmniLight3D.new()
		add_child(portal_light)
		
	# On configure la lumière pour qu'elle éclaire la pièce
	portal_light.light_color = portal_color
	portal_light.light_energy = 5.0 # Très intense !
	portal_light.omni_range = max(size.x, size.y) * 2.0 # La lumière porte loin en fonction de la taille du portail
	
	# 4. Les Particules
	if particles == null:
		particles = GPUParticles3D.new()
		add_child(particles)
		
		var pass_mesh = QuadMesh.new()
		pass_mesh.size = Vector2(0.15, 0.15) # Particules un peu plus grosses
		
		var mat_mesh = StandardMaterial3D.new()
		mat_mesh.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat_mesh.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat_mesh.emission_enabled = true
		pass_mesh.surface_set_material(0, mat_mesh)
		particles.draw_pass_1 = pass_mesh
		
		var p_mat = ParticleProcessMaterial.new()
		p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		p_mat.direction = Vector3(0, 0, 1)
		p_mat.spread = 20.0
		p_mat.gravity = Vector3(0, 1.5, 0)
		p_mat.initial_velocity_min = 0.5
		p_mat.initial_velocity_max = 1.5
		particles.process_material = p_mat

	# 5. Mise à jour dynamique
	if particles.process_material is ParticleProcessMaterial:
		var extents = Vector3((size.x - thickness*2) / 2.0, (size.y - thickness*2) / 2.0, 0.1)
		particles.process_material.emission_box_extents = extents
		particles.process_material.color = portal_color
		
	if particles.draw_pass_1 and particles.draw_pass_1.surface_get_material(0) is StandardMaterial3D:
		var mat = particles.draw_pass_1.surface_get_material(0) as StandardMaterial3D
		mat.albedo_color = portal_color
		mat.emission = portal_color
		mat.emission_energy_multiplier = 8.0 # <-- On a boosté la brillance des particules ici (de 2.0 à 8.0)
