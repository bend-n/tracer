extends Label

@export var f_string = "龍 %dkm/h"
var car: Node3D

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	text = f_string % (car.linear_velocity.length_squared() / 12)

func _on_race_created_car(_car: Car) -> void:
	car = _car.ball
	set_process(true)
