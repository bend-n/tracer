extends Block
class_name Start

@export var mesh: MeshInstance3D

func un_highlight():
	if !_previous_material:
		push_error("no mat!")
		return
	mesh.set_surface_override_material(0, _previous_material)

var _previous_material: BaseMaterial3D
func highlight() -> void:
	_previous_material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, MatMap.get_highlight(_previous_material))
