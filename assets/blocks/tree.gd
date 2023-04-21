extends Decoration

@export var hl_top_mat: BaseMaterial3D
@export var hl_trunk_mat: BaseMaterial3D
@export var top_mat: BaseMaterial3D
@export var trunk_mat: BaseMaterial3D

func get_aabb():
	return %trunk.get_aabb().merge(%top.get_aabb())

func highlight() -> void:
	%trunk.set_surface_override_material(0, hl_trunk_mat)
	%top.set_surface_override_material(0, hl_top_mat)

func un_highlight() -> void:
	%trunk.set_surface_override_material(0, trunk_mat)
	%top.set_surface_override_material(0, top_mat)
