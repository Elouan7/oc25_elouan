## Effet d'écriture automatique style IA (Typewriter)
@tool
## Effet d'écriture automatique à deux messages séquentiels
extends Label3D

@export_multiline var message_1: String = "IA : Traitement terminé. Réponse générée avec succès."
@export_multiline var message_2: String = "Merci d'avoir joué !"

@export var vitesse_lettre: float = 0.04
## Temps d'attente (en secondes) à la fin du premier texte avant de l'effacer
@export var temps_pause: float = 2.0 

var index_lettre: int = 0
var temps_ecoule: float = 0.0

# Les phases : 1 = Message 1, 2 = Pause lecture, 3 = Message 2, 4 = Terminé
var phase_actuelle: int = 1 

func _ready() -> void:
	# On commence avec un écran vide
	text = ""

func _process(delta: float) -> void:
	match phase_actuelle:
		1:
			# ÉTAPE 1 : On écrit le premier message lettre par lettre
			if index_lettre < message_1.length():
				temps_ecoule += delta
				if temps_ecoule >= vitesse_lettre:
					temps_ecoule = 0.0
					text += message_1[index_lettre]
					index_lettre += 1
			else:
				# Dès que le texte 1 est fini, on passe à l'attente
				phase_actuelle = 2
				temps_ecoule = 0.0
		
		2:
			# ÉTAPE 2 : On attend que le joueur lise le texte
			temps_ecoule += delta
			if temps_ecoule >= temps_pause:
				# Le temps est écoulé : on efface tout et on prépare le texte 2
				text = ""
				index_lettre = 0
				temps_ecoule = 0.0
				phase_actuelle = 3
		
		3:
			# ÉTAPE 3 : On écrit le deuxième message
			if index_lettre < message_2.length():
				temps_ecoule += delta
				if temps_ecoule >= vitesse_lettre:
					temps_ecoule = 0.0
					text += message_2[index_lettre]
					index_lettre += 1
			else:
				# Tout est fini !
				phase_actuelle = 4
