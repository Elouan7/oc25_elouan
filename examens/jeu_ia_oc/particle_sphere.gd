## floating_sphere.gd
@tool

extends Node3D

@export_group("Paramètres de Flottaison")
## La hauteur maximale du déplacement (en mètres) au-dessus et en dessous du point de départ
@export var amplitude : float = 0.4

## La vitesse du mouvement de haut en bas (plus la valeur est haute, plus ça va vite)
@export var vitesse : float = 2.5

# Variables internes pour stocker l'état
var _position_depart_y : float
var _temps_ecoule      : float = 0.0

func _ready() -> void:
	# On enregistre la position Y d'origine pour flotter par rapport à ce point
	_position_depart_y = position.y

func _process(delta: float) -> void:
	# On accumule le temps qui passe
	_temps_ecoule += delta
	
	# La fonction sin() renvoie une valeur fluide entre -1 et 1.
	# En la multipliant par l'amplitude, on obtient un va-et-vient parfait.
	position.y = _position_depart_y + sin(_temps_ecoule * vitesse) * amplitude
