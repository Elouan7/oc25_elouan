## Script de clignotement intense (Calcul LLM) pour SpotLight3D
@tool
extends SpotLight3D

## Énergie maximale de ton projecteur
@export var energie_max: float = 5.0

## Vitesse du clignotement (plus c'est bas, plus c'est rapide et chaotique)
@export var vitesse_calcul: float = 0.06

var temps_ecoule: float = 0.0

func _process(delta: float) -> void:
	temps_ecoule += delta
	
	if temps_ecoule >= vitesse_calcul:
		temps_ecoule = 0.0
		
		var chance = randf()
		
		if chance > 0.5:
			# Calcul intense : pleine puissance dans le tunnel
			light_energy = energie_max
		elif chance > 0.2:
			# Petite baisse de régime
			light_energy = energie_max * 0.2
		else:
			# Micro-coupure
			light_energy = 0.0
