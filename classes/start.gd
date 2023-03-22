extends PathFollow3D
class_name Start

@export var needs_collision := true
var editor := false
var collision: PhysicsBody3D
@export var mesh: MeshInstance3D

func _ready() -> void:
	if editor:
		collision.collision_layer = Globals.DEFAULT_EDITOR_LAYER
	elif not needs_collision:
		collision.queue_free()
	else:
		collision.input_ray_pickable = false
