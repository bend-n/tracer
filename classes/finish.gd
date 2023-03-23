extends StaticBody3D
class_name Finish

signal collected

var editor := false
@export var mesh: MeshInstance3D
@export var player_detector: Area3D

func enter() -> void:
	collected.emit()

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER
		player_detector.queue_free()
	else:
		input_ray_pickable = false
