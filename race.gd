extends Node3D

@export var car: Car

func _on_track_place_car(at: Vector3, rot: Vector3) -> void:
		# await car.ready
		car.ball.global_position = at + (Vector3.UP * 2)
		car.ball.global_rotation = rot

