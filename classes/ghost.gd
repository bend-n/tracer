extends Node3D
class_name GhostCar

@onready var right_wheel := $frontright as MeshInstance3D
@onready var left_wheel := $frontleft as MeshInstance3D

func update(_origin: Vector3, _rotation: Vector3, steering: float) -> void:
    right_wheel.rotation.y = steering * .75
    left_wheel.rotation.y = steering * .75
    global_rotation = _rotation
    global_position = _origin
