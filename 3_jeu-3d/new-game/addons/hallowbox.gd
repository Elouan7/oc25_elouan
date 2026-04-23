@tool
extends CSGBox3D
class_name HollowBox

@export var thickness := 0.1:
	set(value):
		thickness = value
		create()

## Button action to rebuild the hollow tube.
@export_tool_button("Rebuild") var action := create

func _ready():
	create()
	
	func create():
	var inner = null
	# find a procedurally created node
	for child in get_children():
		if child.owner == null:
			inner = child
			break
			
if inner == null:
		inner = CSGBox3D.new()
		add_child(inner)
		inner.operation = CSGShape3D.OPERATION_SUBTRACTION
		
	if material:
		inner.material = material
	inner.size = size
	inner.size.x -= thickness * 2
	inner.size.y -= thickness * 2
	inner.size.z += 0.01 # Slightly taller to avoid "Z-fighting" or thin faces
