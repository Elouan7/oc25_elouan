@tool
extends CSGBox3D

var speed = 0.5

func _process(delta: float) -> void:
	rotation.x += delta * speed	
