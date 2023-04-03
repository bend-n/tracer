extends StaticBody3D
class_name Block

@export var mesh: MeshInstance3D
var editor := false

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER

func get_aabb() -> AABB:
	return mesh.get_aabb()

@onready var _previous_material: BaseMaterial3D
func highlight() -> void:
	_previous_material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, MatMap.HIGHLIGHT[_previous_material.resource_path])

func un_highlight() -> void:
	if !_previous_material:
		push_error("no mat!")
		return
	mesh.set_surface_override_material(0, _previous_material)
