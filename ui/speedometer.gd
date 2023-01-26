extends Label

@export var f_string = "龍 %dkm/h"
@export var car: Node3D

func _process(_delta: float) -> void:
	text = f_string % (car.ball.linear_velocity.length_squared() / 12)
