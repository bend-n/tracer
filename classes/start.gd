extends StaticBody3D
class_name Start

var editor := false
@export var mesh: MeshInstance3D

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER
	else:
		input_ray_pickable = false
