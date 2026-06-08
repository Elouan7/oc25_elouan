extends Button

func _ready():
	# Sécurité pour que le bouton fonctionne même si le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _pressed():
	# TRÈS IMPORTANT : On relance le temps si le jeu était figé
	get_tree().paused = false 
	
	# On recharge la première scène
	# ⚠️ ATTENTION : Remplace "res://scene_1.tscn" par le VRAI nom et chemin de ton fichier de la scène 1 !
	get_tree().change_scene_to_file("uid://wee1qbby6p5l")
