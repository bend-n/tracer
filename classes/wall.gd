extends StaticBody3D
class_name Wall

@export var mesh: MeshInstance3D

# this works till i need a 2 part wall ._.
func un_highlight():
	if !_previous_material:
		push_error("no mat!")
		return
	mesh.set_surface_override_material(0, _previous_material)

var _previous_material: BaseMaterial3D
func highlight() -> void:
	_previous_material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, MatMap.get_highlight(_previous_material))
