extends Label

@export var f_string = "龍 %dkm/h"
var car: Car

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	text = f_string % car.kph()

func _on_race_created_car(_car: Car) -> void:
	car = _car
	set_process(true)
