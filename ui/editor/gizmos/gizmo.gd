extends Node3D
class_name Gizmo

@onready var camera := get_viewport().get_camera_3d()
var snapping := false

func _physics_process(_delta: float) -> void:
	var distance := (camera.global_position - global_position).length()
	var size := distance * .00015 * camera.fov
	scale = size * Vector3.ONE

@export_node_path("Node3D") var path: NodePath = ".."
@onready var object: Node3D = get_node(path)
