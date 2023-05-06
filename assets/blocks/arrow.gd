extends Decoration


@export var hl_metal: BaseMaterial3D
@export var metal: BaseMaterial3D

func get_aabb():
	return %stool.get_aabb().merge(%holder.get_aabb())

func highlight() -> void:
	%stool.set_surface_override_material(0, hl_metal)
	%holder.set_surface_override_material(0, hl_metal)

func un_highlight() -> void:
	%stool.set_surface_override_material(0, metal)
	%holder.set_surface_override_material(0, metal)
