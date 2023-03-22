extends EngineNoise

@onready var car := owner.get_parent();
@onready var player: AudioStreamPlayer3D = owner;

func _ready() -> void:
	set_process(false)
	for i in 4:
		await RenderingServer.frame_post_draw # buffer underrun causes it to stop, and the cpu is busy when loading the track and rendering and stuff. https://github.com/godotengine/godot/pull/73162
	player.play()
	set_stream(player.get_stream_playback())
	set_process(true)

func _process(_d: float):
	set_rpm(car.engine_rpm)
	update()
