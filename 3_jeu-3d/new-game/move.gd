@tool

extends CSGBox3D

@export var speed = 1:
	set(x):
		speed = x
		
@export var amplitude = 1:
	set(x):
		amplitude = x
		
var t = 0.0

func _process(delta: float) -> void:
	t += delta
	position.y = amplitude * sin(t * speed)
