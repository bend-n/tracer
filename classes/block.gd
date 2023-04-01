extends StaticBody3D
class_name Block

@export var mesh: MeshInstance3D
var editor := false

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER
