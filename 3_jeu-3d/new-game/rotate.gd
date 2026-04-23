@tool

extends CSGBox3D

var speed = 1

func _process(delta: float) -> void:
	rotation.x += delta * speed	
