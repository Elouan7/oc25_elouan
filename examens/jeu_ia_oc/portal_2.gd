## TorusPortal.gd
@tool
extends CSGTorus3D
class_name TorusPortal
## Crée un portail circulaire basé sur un Torus qui émet des particules et de la lumière.

@export var portal_color := Color(0.5, 0.0, 1.0, 1.0): # Violet par défaut pour le LLM
	set(value):
		portal_color = value
		create()

# Variables pour détecter les changements de rayon dans l'éditeur
var _last_inner_radius := 0.0
var _last_outer_radius := 0.0

func _ready():
	_last_inner_radius = inner_radius
	_last_outer_radius = outer_radius
	create()

func _process(_delta):
	# Si tu agrandis ou rétrécis le Torus dans l'inspecteur, ça met à jour les particules
	if inner_radius != _last_inner_radius or outer_radius != _last_outer_radius:
		_last_inner_radius = inner_radius
		_last_outer_radius = outer_radius
		create()

func create():
	var particles : GPUParticles3D = null
	var portal_light : OmniLight3D = null
	
	# 1. On cherche les enfants déjà existants (pour éviter de les dupliquer)
	for child in get_children():
		if child.owner == null:
			if child is GPUParticles3D:
				particles = child
			elif child is OmniLight3D:
				portal_light = child
				
	# 2. La Lumière Omnidirectionnelle
	if portal_light == null:
		portal_light = OmniLight3D.new()
		add_child(portal_light)
		
	portal_light.light_color = portal_color
	portal_light.light_energy = 5.0 # Intensité d'origine
	portal_light.omni_range = outer_radius * 3.0 # Proportionnel à la taille de ton anneau
	
	# 3. Les Particules (Adaptées à la forme circulaire)
	if particles == null:
		particles = GPUParticles3D.new()
		add_child(particles)
		
		# Visuel de la particule
		var pass_mesh = QuadMesh.new()
		pass_mesh.size = Vector2(0.15, 0.15)
		
		var mat_mesh = StandardMaterial3D.new()
		mat_mesh.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat_mesh.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat_mesh.emission_enabled = true
		pass_mesh.surface_set_material(0, mat_mesh)
		particles.draw_pass_1 = pass_mesh
		
		# Comportement des particules (Forme en Anneau/Ring)
		var p_mat = ParticleProcessMaterial.new()
		p_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		p_mat.emission_ring_axis = Vector3(0, 1, 0) # Aligné avec l'ouverture du Torus
		p_mat.direction = Vector3(0, 1, 0) # Propulsées vers le haut/l'avant
		p_mat.spread = 15.0
		p_mat.gravity = Vector3(0, 0, 0) # Pas de gravité pour qu'elles flottent droit
		p_mat.initial_velocity_min = 0.5
		p_mat.initial_velocity_max = 2.0
		particles.process_material = p_mat

	# 4. Mise à jour dynamique de la taille et des couleurs
	if particles.process_material is ParticleProcessMaterial:
		# L'anneau de particules s'ajuste pile à l'ouverture intérieure du Torus
		particles.process_material.emission_ring_radius = inner_radius
		particles.process_material.emission_ring_inner_radius = 0.0 # Remplit tout l'intérieur du cercle
		particles.process_material.color = portal_color
		
	if particles.draw_pass_1 and particles.draw_pass_1.surface_get_material(0) is StandardMaterial3D:
		var mat = particles.draw_pass_1.surface_get_material(0) as StandardMaterial3D
		mat.albedo_color = portal_color
		mat.emission = portal_color
		mat.emission_energy_multiplier = 8.0 # Ton boost de brillance max !
