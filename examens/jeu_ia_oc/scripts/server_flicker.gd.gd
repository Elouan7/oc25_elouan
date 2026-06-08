## Script pour simuler le clignotement d'un serveur ou terminal IA
@tool
extends OmniLight3D

## Énergie maximale de la lumière quand elle brille
@export var energie_max: float = 3.0

## Vitesse de rafraîchissement du clignotement (en secondes)
@export var vitesse_calcul: float = 0.08

var temps_ecoule: float = 0.0

func _process(delta: float) -> void:
	temps_ecoule += delta
	
	# Toutes les X fractions de seconde, on change l'état de la lumière
	if temps_ecoule >= vitesse_calcul:
		temps_ecoule = 0.0
		
		# On simule un comportement aléatoire de "traitement de données"
		var chance = randf()
		
		if chance > 0.6:
			# Pic d'activité : pleine puissance
			light_energy = energie_max
		elif chance > 0.3:
			# Activité moyenne : lumière tamisée
			light_energy = energie_max * 0.3
		else:
			# Pause de calcul : éteint
			light_energy = 0.0
