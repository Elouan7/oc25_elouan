extends Button

func _ready():
	# Pour que le bouton fonctionne même si le jeu est manipulé
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _pressed():
	get_tree().quit() # Ferme le jeu instantanément
