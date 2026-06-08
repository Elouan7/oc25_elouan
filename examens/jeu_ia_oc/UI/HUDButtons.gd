extends CanvasLayer

@onready var btn_recommencer: Button = $MarginContainer/VBoxContainer/BtnRecommencer
@onready var btn_quitter: Button    = $MarginContainer/VBoxContainer/BtnQuitter


func _ready() -> void:
	btn_recommencer.pressed.connect(_on_recommencer)
	btn_quitter.pressed.connect(_on_quitter)


func _on_recommencer() -> void:
	get_tree().change_scene_to_file("uid://wee1qbby6p5l")


func _on_quitter() -> void:
	get_tree().quit()
