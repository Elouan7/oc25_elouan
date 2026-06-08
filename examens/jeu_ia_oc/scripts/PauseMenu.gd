extends CanvasLayer

# Chemin vers ta scène principale (à adapter si besoin)
@export var main_scene_path: String = "res://Worlds/World_DataCenter.tscn"

@onready var btn_recommencer: Button = $CenterContainer/VBoxContainer/BtnRecommencer
@onready var btn_quitter: Button    = $CenterContainer/VBoxContainer/BtnQuitter


func _ready() -> void:
	# Cache le menu au démarrage
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	btn_recommencer.pressed.connect(_on_recommencer)
	btn_quitter.pressed.connect(_on_quitter)


func open() -> void:
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ── Bouton Recommencer ───────────────────────────────────────────────────────
func _on_recommencer() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


# ── Bouton Quitter ───────────────────────────────────────────────────────────
func _on_quitter() -> void:
	get_tree().paused = false
	get_tree().quit()
