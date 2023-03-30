extends StaticBody3D
class_name CheckPoint

signal collected

var editor := false
@export var mesh: MeshInstance3D
@export var player_detector: Area3D

func enter(_var = null):
	collected.emit()

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER
		player_detector.queue_free()
	else:
		player_detector.body_entered.connect(enter)
		input_ray_pickable = false
