extends Label

@export var f_string = "龍 %dkm/h"
var car

func _process(_delta: float) -> void:
	text = f_string % car.kph()

func car_assigned(_car) -> void:
	car = _car
