extends AudioStreamPlayer3D
class_name EngineNoise

@onready var strem: EngineStream = stream
@onready var car = get_parent()
var volume: float = 1: set = set_v, get = get_v

func _ready() -> void:
	set_process(false)
	for i in 4:
		await RenderingServer.frame_post_draw # buffer underrun causes it to stop, and the cpu is busy when loading the track and rendering and stuff. https://github.com/godotengine/godot/pull/73162
	play()
	strem.set_stream(get_stream_playback())
	set_process(true)

func _process(_d: float):
	strem.engine_rpm = car.engine_rpm
	strem.update()

func set_v(v: float) -> void:
	strem.engine_volume = v

func get_v() -> float:
	return strem.engine_volume
