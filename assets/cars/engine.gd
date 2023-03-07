extends EngineNoise

@onready var car: Car = get_parent();

func _ready() -> void:
	set_stream($Player.get_stream_playback())

func _process(_d: float):
	set_rpm(car.engine_rpm)
	update()
