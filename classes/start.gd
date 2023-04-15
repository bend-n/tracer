extends Block
class_name Start

@export var mesh: MeshInstance3D

func un_highlight(): mesh.set_surface_override_material(0, MatMap.map[mat])
func highlight() -> void: mesh.set_surface_override_material(0, MatMap.get_highlight(mat))
func default_mat(): return 32
