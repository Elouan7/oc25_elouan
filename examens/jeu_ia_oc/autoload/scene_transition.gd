# scene_transition.gd
extends CanvasLayer

var _next_scene := "" # Vide au départ

func _ready():
	# Crée un écran noir pour le fondu
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.name = "Overlay"
	add_child(overlay)

func change_scene(path: String) -> void:
	_next_scene = path # On stocke le chemin ici
	_fade_out() # Puis on lance le fondu
 
func _fade_out() -> void:
	var overlay = $Overlay
	var tween = create_tween()
	# Fondu au noir en 0.5s
	tween.tween_property(overlay, "color:a", 1.0, 0.5)
	tween.tween_callback(_do_change)

func _do_change() -> void:
	get_tree().change_scene_to_file(_next_scene)
	_fade_in()

func _fade_in() -> void:
	var overlay = $Overlay
	var tween = create_tween() # Retour depuis le noir en 0.5s
	tween.tween_property(overlay, "color:a", 0.0, 0.5)
