extends Label

@export var f_string = " %drpm"
var car: Car

func _process(_delta: float) -> void:
	text = f_string % car.rpm()

func assigned(_car: Car) -> void:
	car = _car
