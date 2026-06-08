# ════════════════════════════════════════════════════════════════
#  SNIPPET D'INTÉGRATION — à coller dans ton script de scène principale
#  (ou dans TokenPlayer.gd si tu préfères gérer la pause depuis le joueur)
# ════════════════════════════════════════════════════════════════

# 1. Ajoute PauseMenu comme enfant de ta scène principale dans l'éditeur,
#    OU charge-le dynamiquement via ce code dans _ready() :

@onready var pause_menu = $PauseMenu   # si ajouté manuellement dans la scène
# OU
# var _pause_scene = preload("res://UI/PauseMenu.tscn")
# @onready var pause_menu = _pause_scene.instantiate()


# 2. Dans _ready(), si chargement dynamique :
func _ready():
	# add_child(pause_menu)   # décommente si chargement dynamique
	pass


# 3. Dans _unhandled_input(), gère l'ouverture/fermeture avec Échap :
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):   # touche Échap par défaut
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()
