extends Label
class_name GameTimer

var elapsed_time: float = 0.0

func _ready() -> void:
	stop()

func start() -> void:
	set_process(true)

func stop() -> void:
	set_process(false)

## format a number of seconds into m:s.ms
static func format(time: float) -> String:
	return "%01d:%02d.%02d" % [time / 60, fmod(time, 60), fmod(time * 1000, 100)]

func _process(delta: float) -> void:
	elapsed_time += delta
	text = "祥 %s" % GameTimer.format(elapsed_time)