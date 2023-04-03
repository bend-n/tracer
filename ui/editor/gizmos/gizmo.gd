extends Node3D
class_name Gizmo

signal clicked
signal rotated(change: Vector3)
signal displaced(offset: Vector3)
signal scaled(change: Vector3)
signal finalize

@onready var camera := get_viewport().get_camera_3d()

func _physics_process(_delta: float) -> void:
	update_scale()

func update_scale():
	var distance := (camera.global_position - global_position).length()
	var size := distance * .00015 * camera.fov
	scale = size * Vector3.ONE

func _ready() -> void:
	for c in get_children():
		if c.has_signal(&"clicked"):
			c.clicked.connect(emit_signal.bind(&"clicked"))
