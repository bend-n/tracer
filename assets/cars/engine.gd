extends EngineNoise

@onready var car: Car = get_parent();

func _ready() -> void:
	set_stream($Player.get_stream_playback())
	r = 800

var r := 0.0
func _process(_d: float):
	r = move_toward(r, (car.rpm() * car.engine_force * 0.0015) + 800, 800)
	set_rpm(r)
	update()
