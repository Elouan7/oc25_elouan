
extends CSGCombiner3D
class_name GridInstantiate
## Instantiates a 3D grid of CSC boxes

@export var material : BaseMaterial3D
@export var dimension = Vector3i(1, 2, 2):
	set(value):
		dimension = value
		# Only run if we are inside the editor tree to avoid startup errors
		if is_inside_tree():
			create()
		
@export var step = Vector3(1.5, 1.5, 1.5)


## Instantiates a 3D grid CSG box.
func create():
	delete_all()
	
	# Safety check for the scene root
	var root = get_tree().edited_scene_root
	if not root:
		return
	
	for x in dimension.x:
		for y in dimension.y:
			for z in dimension.z:
				var node = CSGBox3D.new()
				
				# Unique naming helps with organization
				node.name = "Box_%d_%d_%d" % [x, y, z]
				node.material = material
				
				add_child(node, true)
				node.position = Vector3(x, y, z) * step
				node.owner = get_tree().edited_scene_root

## Deletes all children.
func delete_all():
	for child in get_children():
		child.free()
